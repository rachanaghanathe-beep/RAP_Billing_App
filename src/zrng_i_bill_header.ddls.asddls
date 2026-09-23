@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing document header - Root entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZRNG_I_BILL_HEADER
  as select from zrng_bill_header
  composition [0..*] of zrng_i_bill_item as _item
{
    
     key bill_id               as BillId,
      bill_type             as BillType,
      bill_date             as BillDate,
      customer_id           as CustomerId,
      
      @Semantics.amount.currencyCode : 'Currency'
      net_amount            as NetAmount,
      currency              as Currency,
      
      sales_org             as SalesOrg,
      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangeDat,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangeDat,
      
      _item
}
