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
  card {
    sql   = query.created_in_last_7_days.sql
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
  container {
    chart {
      title = "ELN documents created by Month"
      sql   = query.rspace_doc_created_by_month.sql
      width = 6
    }
  }
  container {
    chart {
      title = "Samples created by Month"
      sql   = query.rspace_samples_created_by_month.sql
      width = 6
    }
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

query "rspace_doc_created_by_month" {
  sql = <<-EOQ
    SELECT
      to_char(date_trunc('month', timestamp), 'YYYY-MM') as "Month",
      count(*) as "total"
    from rspace_event
    WHERE domain = 'RECORD' and action ='CREATE'
    GROUP BY
      "Month";
  EOQ
}

query "rspace_samples_created_by_month" {
  sql = <<-EOQ
    select
      to_char(date_trunc('month', timestamp), 'YYYY-MM') as "Month",
      count(*) as "total"
    from rspace_event
    WHERE domain = 'INV_SAMPLE' and action ='CREATE'
    group by
      "Month";
  EOQ
}
