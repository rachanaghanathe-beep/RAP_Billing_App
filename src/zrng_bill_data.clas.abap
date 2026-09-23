CLASS zrng_bill_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zrng_bill_data IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA lt_bill_header TYPE STANDARD TABLE OF zrng_bill_header.

    DELETE FROM zrng_bill_header.

    lt_bill_header = VALUE #(
      ( client      = sy-mandt bill_id = '1000000001' bill_type = 'F2' bill_date = '20250401' customer_id = '100001' net_amount = '1500.00' currency = 'INR' sales_org = '1000' )
      ( client      = sy-mandt bill_id = '1000000002' bill_type = 'F2' bill_date = '20250402' customer_id = '100002' net_amount = '2500.00' currency = 'INR' sales_org = '1000' )
      ( client      = sy-mandt bill_id = '1000000003' bill_type = 'F8' bill_date = '20250403' customer_id = '100003' net_amount = '1800.00' currency = 'USD' sales_org = '2000' )
      ( client      = sy-mandt bill_id = '1000000004' bill_type = 'F2' bill_date = '20250404' customer_id = '100004' net_amount = '3000.00' currency = 'EUR' sales_org = '3000' )
      ( client      = sy-mandt bill_id = '1000000005' bill_type = 'F2' bill_date = '20250405' customer_id = '100005' net_amount = '2200.00' currency = 'INR' sales_org = '1000' )
    ).

    INSERT zrng_bill_header FROM TABLE @lt_bill_header.
    out->write( 'Billing data is inserted' ).
  ENDMETHOD.
ENDCLASS.
