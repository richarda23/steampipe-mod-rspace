dashboard "rspace_dashboard" {
  title = "RSpace Dashboard"
  text {
    value = "Information on RSpace activity"
  }
  benchmark {
    title       = "Recommended RSpace practices"
    description = "Examples of usage and good practices in ELN"
    children    = [
      control.records_created_last_7d,
      control.untitled_documents
    ]
  }

  input "rspace_event_domain" {
  title = "Event Domain"
  type  = "select"
  width = 3

  sql  = <<-EOQ
    with domains as (select d from unnest(array['AUDIT',
     'RECORD', 'NOTEBOOK','INV_SAMPLE', 'INV_SUBSAMPLE', 'INV_CONTAINER', 'USER','GROUP']) as d)
    select d as label,
     d as value 
    from
      domains
  EOQ
}
input "rspace_event_interval" {

  title = "Interval (days)"
  type = "select"
  width = 3
  sql = <<-EOQ
    with intervals as (select i from unnest(array[7,14,30,182,365]) as i )
    select i  as label,
      i as value 
    from intervals
  EOQ
}

card {
  query = query.items_created_in_last_days
  args = {
    domain=self.input.rspace_event_domain
    intervals = self.input.rspace_event_interval
  }
  width = 6
}

input "rspace_event_action" {
  title = "Event Action"
  type  = "select"
  width = 3

  sql  = <<-EOQ
    with actions as (select distinct(action) as a from rspace_event)
    select a as label,
     a as value 
    from
      actions;
  EOQ
}

card {
  query = query.actions_in_last_7_days
  args = {
   action = self.input.rspace_event_action
  }
  width = 9
}

  card {
    query   = query.created_in_last_7_days
    width = 4
  }
  card {
    sql   = query.created_in_last_28_days.sql
    width = 4
  }
  card {
    sql   = query.created_this_calendar_year.sql
    width = 4
  }
    chart {
      title = "ELN documents created by Month"
      query   = query.rspace_items_created_by_month
      args = {
        "domain" ="RECORD"
      }
      width = 4
    }
    chart {
      title = "Samples created by Month"
      query   = query.rspace_items_created_by_month
      args = {
        "domain" ="INV_SAMPLE"
      }
      width = 4
    }
  chart {
    title = "Containers created by Month"
    query   = query.rspace_items_created_by_month
    args = {
      "domain" ="INV_CONTAINER"
    }
    width = 4
  }

  chart {
    title = "User accounts created by Month"
    query   = query.rspace_items_created_by_month
    args = {
      "domain" ="USER"
    }
    width = 4
  }

  chart {
    title = "LabGroups  created by Month"
    query   = query.rspace_items_created_by_month
    args = {
      "domain" ="GROUP"
    }
    width = 4
  }
}

query "actions_in_last_7_days" {
  sql = <<-END
  SELECT 'actions in last 7 days' as label, count(*) as value  from rspace_event
    WHERE action = $1
    AND timestamp > now() - interval '7d'
  END
  param "action" {
    description = "An event action"
    default="CREATE"
  }
}

query "items_created_in_last_days" {
  sql = <<-END
  SELECT 'Items created for chosen domain in last N days' as label, count(*) as value  from rspace_event
    WHERE domain = $1
    AND action ='CREATE'
    AND timestamp > now() - interval '1d' * $2
  END
  param "domain" {
    description = "An event domain"
  }
  param "intervals" {
    description = "Interval in days"
   
  }
}

query "created_in_last_7_days" {
  sql = <<-END
  SELECT 'ELN documents created in last 7 days' as label, count(*) as value  from rspace_event
    WHERE domain = 'RECORD'
    AND action ='CREATE'
    AND timestamp > now() - interval '7d'
  END
}

query "created_in_last_28_days" {
  sql = <<-END
  SELECT 'ELN documents created in last 28 days' as label, count(*) as value  from rspace_event
    WHERE domain = 'RECORD' and action ='CREATE'
    AND timestamp > now() - interval '28d'
  END
}

query "created_this_calendar_year" {
  sql = <<-END
  SELECT 'ELN resources created this calendar year' as label, count(*) as value  from rspace_event
    WHERE domain = 'RECORD' and action ='CREATE'
    AND timestamp > date_trunc('year', now())
  END
}

query "rspace_items_created_by_month" {
  sql = <<-EOQ
    select
      to_char(date_trunc('month', timestamp), 'YYYY-MM') as "Month",
      count(*) as "total"
    from rspace_event
    WHERE domain = $1 and action ='CREATE'
    group by
      "Month";
  EOQ
  param "domain" {
    default = "INV_SAMPLE"
  }
}
