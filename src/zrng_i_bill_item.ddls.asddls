@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Billing Doc Item'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zrng_i_bill_item
  as select from zrng_bill_item
  association to parent ZRNG_I_BILL_HEADER as _header 
    on $projection.BillId = _header.BillId
{

key bill_id               as BillId,
  key item_no               as ItemNo,
      material_id           as MaterialId,
      description           as Description,
      quantity              as Quantity,
      
      @Semantics.amount.currencyCode: 'Currency'
      item_amount           as ItemAmount,
      currency              as Currency,
      uom                   as Uom,
      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by        as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt,
      
      _header

      }
      
