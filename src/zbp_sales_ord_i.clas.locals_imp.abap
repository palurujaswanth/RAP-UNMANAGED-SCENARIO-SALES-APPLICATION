CLASS lhc_SalesOrderItm DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE SalesOrderItm.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE SalesOrderItm.

    METHODS read FOR READ
      IMPORTING keys FOR READ SalesOrderItm RESULT result.

    METHODS rba_Salesheader FOR READ
      IMPORTING keys_rba FOR READ SalesOrderItm\_Salesheader FULL result_requested RESULT result LINK association_links.
ENDCLASS.

CLASS lhc_SalesOrderItm IMPLEMENTATION.
  METHOD update.
    DATA ls_sales_itm TYPE zsales_ord_i.

    LOOP AT entities INTO DATA(ls_entities).
      ls_sales_itm = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).

      IF ls_sales_itm-salesdocument IS NOT INITIAL AND ls_sales_itm-salesitemnumber IS NOT INITIAL.
        SELECT FROM zsales_ord_i
          FIELDS salesdocument
          WHERE salesdocument   = @ls_sales_itm-salesdocument
            AND salesitemnumber = @ls_sales_itm-salesitemnumber
          INTO TABLE @DATA(lt_sales_hdr).

        IF sy-subrc = 0.
          DATA(lo_util) = zsales_ord_util=>get_instance( ).
          lo_util->set_itm_value(
            EXPORTING im_sales_itm = ls_sales_itm
            IMPORTING ex_created   = DATA(lv_created)
          ).

          IF lv_created = abap_true.
            APPEND VALUE #( %tky = ls_entities-%tky ) TO mapped-salesorderitm.

            APPEND VALUE #( %tky = ls_entities-%tky
                            %msg = new_message( id       = 'ZSALES_MSG'
                                                number   = '001'
                                                v1       = 'Sales Item Updation Successful'
                                                severity = if_abap_behv_message=>severity-success )
                          ) TO reported-salesorderitm.
          ENDIF.
        ELSE.
          APPEND VALUE #( %tky = ls_entities-%tky ) TO failed-salesorderitm.

          APPEND VALUE #( %tky = ls_entities-%tky
                          %msg = new_message( id       = 'ZSALES_MSG'
                                              number   = '001'
                                              v1       = 'Sales Item Not Found'
                                              severity = if_abap_behv_message=>severity-error )
                        ) TO reported-salesorderitm.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA ls_sales_itm TYPE zsales_ord_util=>ty_sales_item.
    DATA(lo_util) = zsales_ord_util=>get_instance( ).

    LOOP AT keys INTO DATA(ls_key).
      CLEAR ls_sales_itm.
      ls_sales_itm-salesdocument   = ls_key-salesdocument.
      ls_sales_itm-salesitemnumber = ls_key-SalesItemNumber.

      lo_util->set_itm_t_deletion( im_sales_itm_info = ls_sales_itm ).

      APPEND VALUE #( %tky = ls_key-%tky
                      %msg = new_message( id       = 'ZSALES_MSG'
                                          number   = '001'
                                          v1       = 'Sales Item Deletion Successful'
                                          severity = if_abap_behv_message=>severity-success )
                    ) TO reported-salesorderitm.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zsales_ord_i
        FIELDS *
        WHERE salesdocument   = @ls_key-salesdocument
          AND salesitemnumber = @ls_key-SalesItemNumber
        INTO @DATA(ls_item).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_item ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Salesheader.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT SINGLE FROM zsales_ord_h
        FIELDS *
        WHERE salesdocument = @ls_key-salesdocument
        INTO @DATA(ls_hdr).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_hdr ) TO result.
        APPEND VALUE #( source-salesdocument   = ls_key-salesdocument
                        source-salesitemnumber = ls_key-SalesItemNumber
                        target-salesdocument   = ls_hdr-salesdocument ) TO association_links.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
