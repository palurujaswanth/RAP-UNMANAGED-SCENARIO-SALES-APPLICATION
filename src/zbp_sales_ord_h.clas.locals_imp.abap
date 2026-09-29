CLASS lhc_SalesOrderHdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR SalesOrderHdr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR SalesOrderHdr RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE SalesOrderHdr.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE SalesOrderHdr.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE SalesOrderHdr.

    METHODS read FOR READ
      IMPORTING keys FOR READ SalesOrderHdr RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK SalesOrderHdr.

    METHODS rba_Salesitem FOR READ
      IMPORTING keys_rba FOR READ SalesOrderHdr\_Salesitem FULL result_requested RESULT result LINK association_links.

    METHODS cba_Salesitem FOR MODIFY
      IMPORTING entities_cba FOR CREATE SalesOrderHdr\_Salesitem.
ENDCLASS.

CLASS lhc_SalesOrderHdr IMPLEMENTATION.
  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ELSE.
      result-%create = if_abap_behv=>auth-unauthorized.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky    = ls_key-%tky
                      %update = if_abap_behv=>auth-allowed
                      %delete = if_abap_behv=>auth-allowed ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    DATA ls_sales_hdr TYPE zsales_ord_h.

    LOOP AT entities INTO DATA(ls_entities).
      ls_sales_hdr = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).

      IF ls_sales_hdr-salesdocument IS NOT INITIAL.
        SELECT FROM zsales_ord_h
          FIELDS salesdocument
          WHERE salesdocument = @ls_sales_hdr-salesdocument
          INTO TABLE @DATA(lt_sales_hdr).

        IF sy-subrc NE 0.
          DATA(lo_util) = zsales_ord_util=>get_instance( ).
          lo_util->set_hdr_value(
            EXPORTING im_sales_hdr = ls_sales_hdr
            IMPORTING ex_created   = DATA(lv_created)
          ).

          IF lv_created = abap_true.
            APPEND VALUE #( %cid          = ls_entities-%cid
                            salesdocument = ls_sales_hdr-salesdocument ) TO mapped-salesorderhdr.

            APPEND VALUE #( %cid          = ls_entities-%cid
                            salesdocument = ls_sales_hdr-salesdocument
                            %msg          = new_message( id       = 'ZSALES_MSG'
                                                         number   = '001'
                                                         v1       = 'Sales Order Creation Successful'
                                                         severity = if_abap_behv_message=>severity-success )
                          ) TO reported-salesorderhdr.
          ENDIF.
        ELSE.
          APPEND VALUE #( %cid          = ls_entities-%cid
                          salesdocument = ls_sales_hdr-salesdocument ) TO failed-salesorderhdr.

          APPEND VALUE #( %cid          = ls_entities-%cid
                          salesdocument = ls_sales_hdr-salesdocument
                          %msg          = new_message( id       = 'ZSALES_MSG'
                                                         number   = '001'
                                                         v1       = 'Duplicate Sales Order'
                                                         severity = if_abap_behv_message=>severity-error )
                        ) TO reported-salesorderhdr.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA ls_sales_hdr TYPE zsales_ord_h.

    LOOP AT entities INTO DATA(ls_entities).
      ls_sales_hdr = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).

      IF ls_sales_hdr-salesdocument IS NOT INITIAL.
        SELECT FROM zsales_ord_h
          FIELDS salesdocument
          WHERE salesdocument = @ls_sales_hdr-salesdocument
          INTO TABLE @DATA(lt_sales_hdr).

        IF sy-subrc = 0.
          DATA(lo_util) = zsales_ord_util=>get_instance( ).
          lo_util->set_hdr_value(
            EXPORTING im_sales_hdr = ls_sales_hdr
            IMPORTING ex_created   = DATA(lv_created)
          ).

          IF lv_created = abap_true.
            APPEND VALUE #( %tky = ls_entities-%tky ) TO mapped-salesorderhdr.

            APPEND VALUE #( %tky = ls_entities-%tky
                            %msg = new_message( id       = 'ZSALES_MSG'
                                                number   = '001'
                                                v1       = 'Sales Order Updation Successful'
                                                severity = if_abap_behv_message=>severity-success )
                          ) TO reported-salesorderhdr.
          ENDIF.
        ELSE.
          APPEND VALUE #( %tky = ls_entities-%tky ) TO failed-salesorderhdr.

          APPEND VALUE #( %tky = ls_entities-%tky
                          %msg = new_message( id       = 'ZSALES_MSG'
                                              number   = '001'
                                              v1       = 'Sales Order Not Found!'
                                              severity = if_abap_behv_message=>severity-error )
                        ) TO reported-salesorderhdr.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA ls_sales_hdr TYPE zsales_ord_util=>ty_sales_hdr.
    DATA(lo_util) = zsales_ord_util=>get_instance( ).

    LOOP AT keys INTO DATA(ls_key).
      CLEAR ls_sales_hdr.
      ls_sales_hdr-salesdocument = ls_key-salesdocument.
      lo_util->set_hdr_t_deletion( im_sales_doc = ls_sales_hdr ).
      lo_util->set_hdr_deletion_flag( im_so_delete = abap_true ).

      APPEND VALUE #( %tky = ls_key-%tky
                      %msg = new_message( id       = 'ZSALES_MSG'
                                          number   = '001'
                                          v1       = 'Sales Order Deletion Successful'
                                          severity = if_abap_behv_message=>severity-success )
                    ) TO reported-salesorderhdr.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zsales_ord_h
        FIELDS *
        WHERE salesdocument = @ls_key-salesdocument
        INTO @DATA(ls_hdr).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_hdr ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Salesitem.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT FROM zsales_ord_i
        FIELDS *
        WHERE salesdocument = @ls_key-salesdocument
        INTO TABLE @DATA(lt_items).

      LOOP AT lt_items INTO DATA(ls_item).
        APPEND CORRESPONDING #( ls_item ) TO result.
        APPEND VALUE #( source-salesdocument   = ls_key-salesdocument
                        target-salesdocument   = ls_item-salesdocument
                        target-salesitemnumber = ls_item-salesitemnumber ) TO association_links.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Salesitem.
    DATA ls_sales_itm TYPE zsales_ord_i.

    LOOP AT entities_cba INTO DATA(ls_entities_cba).
      ls_sales_itm = CORRESPONDING #( ls_entities_cba-%target[ 1 ] ).

      IF ls_sales_itm-salesdocument IS NOT INITIAL AND ls_sales_itm-salesitemnumber IS NOT INITIAL.
        SELECT FROM zsales_ord_i
          FIELDS salesdocument
          WHERE salesdocument   = @ls_sales_itm-salesdocument
            AND salesitemnumber = @ls_sales_itm-salesitemnumber
          INTO TABLE @DATA(lt_sales_itm).

        IF sy-subrc NE 0.
          DATA(lo_util) = zsales_ord_util=>get_instance( ).
          lo_util->set_itm_value(
            EXPORTING im_sales_itm = ls_sales_itm
            IMPORTING ex_created   = DATA(lv_created)
          ).

          IF lv_created = abap_true.
            APPEND VALUE #( %cid            = ls_entities_cba-%target[ 1 ]-%cid
                            salesdocument   = ls_sales_itm-salesdocument
                            salesitemnumber = ls_sales_itm-salesitemnumber ) TO mapped-salesorderitm.

            APPEND VALUE #( %cid            = ls_entities_cba-%target[ 1 ]-%cid
                            salesdocument   = ls_sales_itm-salesdocument
                            %msg            = new_message( id       = 'ZSALES_MSG'
                                                           number   = '001'
                                                           v1       = 'Sales Item Creation Successful'
                                                           severity = if_abap_behv_message=>severity-success )
                          ) TO reported-salesorderitm.
          ENDIF.
        ELSE.
          APPEND VALUE #( %cid            = ls_entities_cba-%target[ 1 ]-%cid
                          salesdocument   = ls_sales_itm-salesdocument
                          salesitemnumber = ls_sales_itm-salesitemnumber ) TO failed-salesorderitm.

          APPEND VALUE #( %cid            = ls_entities_cba-%target[ 1 ]-%cid
                          salesdocument   = ls_sales_itm-salesdocument
                          salesitemnumber = ls_sales_itm-salesitemnumber
                          %msg            = new_message( id       = 'ZSALES_MSG'
                                                         number   = '002'
                                                         v1       = 'Duplicate Sales Item'
                                                         severity = if_abap_behv_message=>severity-error )
                        ) TO reported-salesorderitm.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
