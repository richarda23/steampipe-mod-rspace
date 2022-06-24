
control "records_created_last_7d" {
 title = "RSpace is being used"
  description = "Documents have been read, written or created in the last 7 days"
 sql = <<EOT
select q.total as items_created, 'items created' as resource,
case  when q.total  > 0
   then  'ok'
   else 'info'
   end  as status,
case  when q.total  > 0
   then  'items created, edited or viewed'
   else 'No items created, edited or viewed in last 7d'
   end  as reason
from   (select count(*)as total  from rspace_event where domain = 'RECORD' and timestamp > now() - interval '7d' )q;
  EOT
}

control "untitled_documents" {
  title ="Untitled documents"
  description = "Leaving documents with no title is poor practice, and makes searching  and navigation more difficult"
  sql = <<EOT
   select global_id as resource,  'info'  as status, concat(global_id, ' has no title')  as reason  from rspace_document where name ='Untitled document';
EOT
}
