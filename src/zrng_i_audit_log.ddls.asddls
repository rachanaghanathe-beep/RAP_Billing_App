@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Audit Log View'
@Metadata.allowExtensions: true
define view entity ZRNG_I_AUDIT_LOG
  as select from zrng_audit_log
{
  key uuid       as Uuid,
      bill_id    as BillId,
      operation  as Operation,
      field_name as FieldName,
      old_value  as OldValue,
      new_value  as NewValue,
      changed_by as ChangedBy
}
