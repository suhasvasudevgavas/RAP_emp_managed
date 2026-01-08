CLASS lhc_proj DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR proj RESULT result.
    METHODS valenddate FOR VALIDATE ON SAVE
      IMPORTING keys FOR proj~valenddate.

ENDCLASS.

CLASS lhc_proj IMPLEMENTATION.
  METHOD get_instance_features.
    READ ENTITIES OF zsvg_i_emp IN LOCAL MODE
         ENTITY proj
         FIELDS ( Active )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_active).

    LOOP AT lt_active INTO DATA(lwa_active).
      IF lwa_active-Active IS NOT INITIAL.
        APPEND VALUE #( %is_draft      = lwa_active-%is_draft
                        id             = lwa_active-Id
                        empid          = lwa_active-EmpId
                        %field-enddate = if_abap_behv=>fc-f-read_only ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD ValEndDate.
    READ ENTITIES OF zsvg_i_emp IN LOCAL MODE
         ENTITY proj
         FIELDS ( StartDate EndDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_date).

    LOOP AT lt_date INTO DATA(lwa_date).
      IF lwa_date-EndDate IS NOT INITIAL AND lwa_date-StartDate >= lwa_date-EndDate.
        APPEND VALUE #( %tky = lwa_date-%tky ) TO failed-proj.
        APPEND VALUE #( %tky = lwa_date-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'End date should be greater than start date.' ) ) TO reported-proj.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_emp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR emp RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR emp RESULT result.
    METHODS valdob FOR VALIDATE ON SAVE
      IMPORTING keys FOR emp~valdob.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE emp.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE emp.

ENDCLASS.

CLASS lhc_emp IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD valdob.
    READ ENTITIES OF zsvg_i_emp IN LOCAL MODE
         ENTITY emp
         FIELDS ( Dob )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_dob).

    failed-emp = VALUE #( FOR lwa_dob IN lt_dob WHERE ( Dob > '20080101' )
                          ( %tky = lwa_dob-%tky ) ).

    reported-emp = VALUE #( FOR lwa_dob IN lt_dob WHERE ( Dob > '20080101' )
                            ( %tky = lwa_dob-%tky
                              %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                            text     = 'Age cannot be less than 18.' ) ) ).
  ENDMETHOD.

  METHOD precheck_create.
    failed-emp = VALUE #( FOR lwa_entity IN entities WHERE ( Dob > '20080101' )
                          ( %key = lwa_entity-%key
                            %is_draft = lwa_entity-%is_draft ) ).

    reported-emp = VALUE #( FOR lwa_entity IN entities WHERE ( Dob > '20080101' )
                            ( %key = lwa_entity-%key
                              %is_draft = lwa_entity-%is_draft
                              %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                            text     = 'Age cannot be less than 18.' ) ) ).
  ENDMETHOD.

  METHOD precheck_update.
    failed-emp = VALUE #( FOR lwa_entity IN entities WHERE ( Dob > '20080101' )
                          ( %key      = lwa_entity-%key
                            %is_draft = lwa_entity-%is_draft ) ).

    reported-emp = VALUE #( FOR lwa_entity IN entities WHERE ( Dob > '20080101' )
                            ( %key      = lwa_entity-%key
                              %is_draft = lwa_entity-%is_draft
                              %msg      = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                 text     = 'Age cannot be less than 18.' ) ) ).
  ENDMETHOD.

ENDCLASS.
