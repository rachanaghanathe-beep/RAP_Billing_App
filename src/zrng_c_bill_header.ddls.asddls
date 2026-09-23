@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing document header - Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZRNG_C_BILL_HEADER
  provider contract transactional_query as projection on ZRNG_I_BILL_HEADER
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
      LocalLastChangeDat
}
