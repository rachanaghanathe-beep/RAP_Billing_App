@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View of Billing Doc Item'
@Metadata.allowExtensions: true
define view entity Zrng_C_Bill_Item
  as projection on zrng_i_bill_item
{
  key BillId,
  key ItemNo,
      MaterialId,
      Description,
      Quantity,
      ItemAmount,
      Currency,
      Uom,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _header : redirected to parent ZRNG_C_BILL_HEADER
}
