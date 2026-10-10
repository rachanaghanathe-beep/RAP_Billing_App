CLASS lsc_zrng_i_bill_header DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zrng_i_bill_header IMPLEMENTATION.

  METHOD save_modified.

  DATA: lt_log TYPE TABLE OF zrng_audit_log.

  TRY.

    IF create-header IS NOT INITIAL.
      LOOP AT create-header INTO DATA(ls_create).
        APPEND VALUE #(
          client     = sy-mandt
          uuid       = cl_system_uuid=>create_uuid_x16_static( )
          bill_id    = ls_create-BillId
          operation  = 'CREATE'
          field_name = 'BillType'
          old_value  = ''
          new_value  = ls_create-BillType
          changed_by = cl_abap_context_info=>get_user_technical_name( )
*          changed_at = cl_abap_context_info=>get_system_time( )
        ) TO lt_log.

        APPEND VALUE #(
          client     = sy-mandt
          uuid       = cl_system_uuid=>create_uuid_x16_static( )
          bill_id    = ls_create-BillId
          operation  = 'CREATE'
          field_name = 'CustomerId'
          old_value  = ''
          new_value  = ls_create-CustomerId
          changed_by = cl_abap_context_info=>get_user_technical_name( )
*          changed_at = cl_abap_context_info=>get_system_time( )
        ) TO lt_log.

        APPEND VALUE #(
          client     = sy-mandt
          uuid       = cl_system_uuid=>create_uuid_x16_static( )
          bill_id    = ls_create-BillId
          operation  = 'CREATE'
          field_name = 'NetAmount'
          old_value  = ''
          new_value  = CONV #( ls_create-NetAmount )
          changed_by = cl_abap_context_info=>get_user_technical_name( )
*          changed_at = cl_abap_context_info=>get_system_time( )
        ) TO lt_log.
      ENDLOOP.
    ENDIF.

    IF update-header IS NOT INITIAL.
      LOOP AT update-header INTO DATA(ls_update).
        IF ls_update-%control-BillType = if_abap_behv=>mk-on.
          APPEND VALUE #(
            client     = sy-mandt
            uuid       = cl_system_uuid=>create_uuid_x16_static( )
            bill_id    = ls_update-BillId
            operation  = 'UPDATE'
            field_name = 'BillType'
            old_value  = ''
            new_value  = ls_update-BillType
            changed_by = cl_abap_context_info=>get_user_technical_name( )
*            changed_at = cl_abap_context_info=>get_system_time( )
          ) TO lt_log.
        ENDIF.

        IF ls_update-%control-CustomerId = if_abap_behv=>mk-on.
          APPEND VALUE #(
            client     = sy-mandt
            uuid       = cl_system_uuid=>create_uuid_x16_static( )
            bill_id    = ls_update-BillId
            operation  = 'UPDATE'
            field_name = 'CustomerId'
            old_value  = ''
            new_value  = ls_update-CustomerId
            changed_by = cl_abap_context_info=>get_user_technical_name( )
*            changed_at = cl_abap_context_info=>get_system_time( )
          ) TO lt_log.
        ENDIF.

        IF ls_update-%control-NetAmount = if_abap_behv=>mk-on.
          APPEND VALUE #(
            client     = sy-mandt
            uuid       = cl_system_uuid=>create_uuid_x16_static( )
            bill_id    = ls_update-BillId
            operation  = 'UPDATE'
            field_name = 'NetAmount'
            old_value  = ''
            new_value  = CONV #( ls_update-NetAmount )
            changed_by = cl_abap_context_info=>get_user_technical_name( )
*            changed_at = cl_abap_context_info=>get_system_time( )
          ) TO lt_log.
        ENDIF.
      ENDLOOP.
    ENDIF.

    CATCH cx_uuid_error.
  ENDTRY.

  IF lt_log IS NOT INITIAL.
    INSERT zrng_audit_log FROM TABLE @lt_log.
  ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZRNG_I_BILL_HEADER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR ZRNG_I_BILL_HEADER RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR header RESULT result.
    METHODS precheck_create FOR PRECHECK
      entities FOR CREATE header.

    METHODS validateamount FOR VALIDATE ON SAVE
      keys FOR header~validateamount.
    METHODS updatebillingdate FOR MODIFY
      keys FOR ACTION header~updatebillingdate RESULT result.
    METHODS copybillingdoc FOR MODIFY
      keys FOR ACTION header~copybillingdoc.
    METHODS setdefaults FOR DETERMINE ON MODIFY
      keys FOR header~setdefaults.

    METHODS earlynumbering_create FOR NUMBERING
      entities FOR CREATE header.

    METHODS earlynumbering_cba_item FOR NUMBERING
      entities FOR CREATE header\_item.

ENDCLASS.

CLASS lhc_ZRNG_I_BILL_HEADER IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

   DATA: entity      TYPE STRUCTURE FOR CREATE zrng_i_bill_header,
        max_bill_id TYPE zrng_bill_header-bill_id.

  SELECT MAX( bill_id ) FROM zrng_bill_header INTO @max_bill_id.

  LOOP AT entities INTO entity WHERE BillId IS NOT INITIAL.
    APPEND CORRESPONDING #( entity ) TO mapped-header.
  ENDLOOP.

  DATA(entities_wo_id) = entities.
  DELETE entities_wo_id WHERE BillId IS NOT INITIAL.

  LOOP AT entities_wo_id INTO entity.
    max_bill_id += 1.
    entity-BillId = max_bill_id.
    APPEND VALUE #(
      %cid      = entity-%cid
      %is_draft = entity-%is_draft
      %key      = entity-%key
    ) TO mapped-header.
  ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Item.

  DATA: max_item_no TYPE zrng_bill_item-item_no.

  READ ENTITIES OF zrng_i_bill_header IN LOCAL MODE
    ENTITY header BY \_item
    FROM CORRESPONDING #( entities )
    LINK DATA(links).

  LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_group>)
    GROUP BY <travel_group>-BillId.

    LOOP AT links INTO DATA(ls_link)
      WHERE source-BillId = <travel_group>-BillId.
      IF max_item_no < ls_link-target-ItemNo.
        max_item_no = ls_link-target-ItemNo.
      ENDIF.
    ENDLOOP.

    LOOP AT entities INTO DATA(ls_entity) USING KEY entity
      WHERE BillId = <travel_group>-BillId.
      LOOP AT ls_entity-%target INTO DATA(ls_target).
        IF ls_target-ItemNo IS INITIAL.
          max_item_no += 1.
          ls_target-ItemNo = max_item_no.
        ENDIF.
        APPEND VALUE #(
          %cid      = ls_target-%cid
          %is_draft = ls_target-%is_draft
          %key      = ls_target-%key
        ) TO mapped-item.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
  ENDMETHOD.

  METHOD updateBillingDate.

    MODIFY ENTITIES OF Zrng_I_BILL_HEADER IN LOCAL MODE
        ENTITY Zrng_I_BILL_HEADER
           UPDATE FROM VALUE #( FOR key IN keys
           ( %tky   = key-%tky
             BillDate = cl_abap_context_info=>get_system_date( )
             %control-BillDate = if_abap_behv=>mk-on ) )
           FAILED failed
           REPORTED reported.

  "Read changed data for action result
  READ ENTITIES OF Zrng_I_BILL_HEADER IN LOCAL MODE
    ENTITY Zrng_I_BILL_HEADER
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_billdocs).

  result = VALUE #( FOR ls_billdoc IN lt_billdocs
           ( %tky   = ls_billdoc-%tky
             %param = ls_billdoc ) ).
  ENDMETHOD.

  METHOD precheck_create.

  LOOP AT entities INTO DATA(ls_entity).

      IF ls_entity-CustomerId IS NOT INITIAL.

        SELECT SINGLE * FROM /DMO/I_Customer
            WHERE CustomerID = @ls_entity-CustomerId
            INTO @DATA(ls_customer).
        IF sy-subrc NE 0.
          APPEND VALUE #( %key = ls_entity-%key ) TO failed-header.
          APPEND VALUE #( %key = ls_entity-%key
                        %element-CustomerId = if_abap_behv=>mk-on
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text = 'Customer does not exists' )
                       ) TO reported-header.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateAmount.

     READ ENTITIES OF zrng_i_bill_header IN LOCAL MODE
    ENTITY Header
    FIELDS ( NetAmount ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_billdoc).

  LOOP AT lt_billdoc INTO DATA(ls_billdoc).
    IF ls_billdoc-NetAmount IS NOT INITIAL AND ls_billdoc-NetAmount < 1000.
      APPEND VALUE #( %tky = ls_billdoc-%tky ) TO failed-header.
      APPEND VALUE #( %tky = ls_billdoc-%tky
                      %element-NetAmount = if_abap_behv=>mk-on
                      %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'Net Amount cannot be less than 1000' )
                     ) TO reported-header.
    ENDIF.
  ENDLOOP.

  ENDMETHOD.



  METHOD CopyBillingDoc.

      READ ENTITIES OF zrng_i_bill_header IN LOCAL MODE
    ENTITY Header
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_billdocs).

  LOOP AT lt_billdocs INTO DATA(ls_billdoc).
    MODIFY ENTITIES OF zrng_i_bill_header IN LOCAL MODE
      ENTITY Header
      CREATE FIELDS ( BillType BillDate CustomerId NetAmount Currency SalesOrg )
      WITH VALUE #( (
        %cid       = keys[ KEY entity %tky = ls_billdoc-%tky ]-%cid
        BillType   = ls_billdoc-BillType
        BillDate   = ls_billdoc-BillDate
        CustomerId = ls_billdoc-CustomerId
        NetAmount  = ls_billdoc-NetAmount
        Currency   = ls_billdoc-Currency
        SalesOrg   = ls_billdoc-SalesOrg
      ) )
      MAPPED DATA(mapped_create).

    mapped-header = mapped_create-header.
  ENDLOOP.

  ENDMETHOD.

  METHOD setDefaults.

  MODIFY ENTITIES OF zrng_i_bill_header IN LOCAL MODE
    ENTITY Header
    UPDATE FIELDS ( BillType )
    WITH VALUE #( FOR key IN keys
      ( %tky     = key-%tky
        BillType = 'V3' ) )
    REPORTED DATA(rep).

  ENDMETHOD.

ENDCLASS.
