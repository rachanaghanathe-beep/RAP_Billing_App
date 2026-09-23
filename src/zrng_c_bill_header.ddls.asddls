@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View of Billing Doc Header'
@Metadata.allowExtensions: true
define root view entity zrng_c_bill_header
  provider contract transactional_query
  as projection on ZRNG_I_BILL_HEADER
{
  key BillId,
      BillType,
      BillDate,
      CustomerId,
      @Semantics.amount.currencyCode: 'Currency'
      NetAmount,
      Currency,
      SalesOrg,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangeDat,
      LocalLastChangeDat,
      
      _item: redirected to composition child Zrng_C_Bill_Item
}
