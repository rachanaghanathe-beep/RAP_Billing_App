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

 DATA lt_bill_item TYPE STANDARD TABLE OF zrng_bill_item.

    DELETE FROM zrng_bill_item.

    lt_bill_item = VALUE #(
      ( client = sy-mandt bill_id = '1000000001' item_no = '000001' material_id = 'MAT001' description = 'USB Cable'      quantity = '2.000' item_amount = '500.00'  currency = 'INR' uom = 'EA' )
      ( client = sy-mandt bill_id = '1000000001' item_no = '000002' material_id = 'MAT002' description = 'Charger'        quantity = '1.000' item_amount = '1000.00' currency = 'INR' uom = 'EA' )

      ( client = sy-mandt bill_id = '1000000002' item_no = '000001' material_id = 'MAT003' description = 'Headphones'     quantity = '1.000' item_amount = '2500.00' currency = 'INR' uom = 'EA' )

      ( client = sy-mandt bill_id = '1000000003' item_no = '000001' material_id = 'MAT004' description = 'Keyboard'       quantity = '1.000' item_amount = '800.00'  currency = 'USD' uom = 'EA' )
      ( client = sy-mandt bill_id = '1000000003' item_no = '000002' material_id = 'MAT005' description = 'Mouse'          quantity = '2.000' item_amount = '1000.00' currency = 'USD' uom = 'EA' )

      ( client = sy-mandt bill_id = '1000000004' item_no = '000001' material_id = 'MAT006' description = 'Monitor'        quantity = '1.000' item_amount = '3000.00' currency = 'EUR' uom = 'EA' )

      ( client = sy-mandt bill_id = '1000000005' item_no = '000001' material_id = 'MAT007' description = 'Webcam'         quantity = '1.000' item_amount = '2200.00' currency = 'INR' uom = 'EA' )
    ).

    INSERT zrng_bill_item FROM TABLE @lt_bill_item.
    out->write( 'Billing item data is inserted' ).

  ENDMETHOD.
ENDCLASS.
