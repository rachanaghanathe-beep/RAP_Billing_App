CLASS lhc_ZRNG_I_BILL_HEADER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR ZRNG_I_BILL_HEADER RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR header RESULT result.

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

ENDCLASS.
