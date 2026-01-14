CLASS lhc_proj DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR proj RESULT result.
    METHODS valenddate FOR VALIDATE ON SAVE
      IMPORTING keys FOR proj~valenddate.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR proj RESULT result.

    METHODS end_project FOR MODIFY
      IMPORTING keys FOR ACTION proj~end_project RESULT result.

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
        APPEND VALUE #( %is_draft           = lwa_active-%is_draft
                        id                  = lwa_active-Id
                        empid               = lwa_active-EmpId
                        %field-enddate      = if_abap_behv=>fc-f-read_only
                        %action-end_project = if_abap_behv=>fc-o-enabled ) TO result.
      ELSE.
        APPEND VALUE #( %is_draft           = lwa_active-%is_draft
                        id                  = lwa_active-Id
                        empid               = lwa_active-EmpId
                        %field-enddate      = if_abap_behv=>fc-f-unrestricted
                        %action-end_project = if_abap_behv=>fc-o-disabled ) TO result.
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

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD end_project.
    DATA lt_proj_up TYPE TABLE FOR UPDATE zsvg_i_proj.

    lt_proj_up = VALUE #( FOR key IN keys
                          ( id       = key-Id
                            EmpId    = key-EmpId
                            Active   = ''
                            EndDate  = cl_abap_context_info=>get_system_date( )
                            %control = VALUE #( Active  = if_abap_behv=>mk-on
                                                EndDate = if_abap_behv=>mk-on ) ) ).

    MODIFY ENTITIES OF zsvg_i_emp IN LOCAL MODE
           ENTITY proj
           UPDATE
           FIELDS ( Active EndDate )
           WITH lt_proj_up
           FAILED DATA(lt_fail).

    IF lt_fail IS INITIAL.
      READ ENTITIES OF zsvg_i_emp IN LOCAL MODE
           ENTITY proj
           ALL FIELDS
           WITH CORRESPONDING #( keys )
           RESULT DATA(lt_proj)
           FAILED lt_fail.

      IF lt_fail IS INITIAL.
        result = VALUE #( FOR lwa_proj IN lt_proj
                          ( Id        = lwa_proj-Id
                            %is_draft = lwa_proj-%is_draft
                            %param    = CORRESPONDING #( lwa_proj ) ) ).
      ENDIF.
    ENDIF.
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
    METHODS copy_instance FOR MODIFY
      IMPORTING keys FOR ACTION emp~copy_instance.
    METHODS new_instance FOR MODIFY
      IMPORTING keys FOR ACTION emp~new_instance.
    METHODS detstate FOR DETERMINE ON SAVE
      IMPORTING keys FOR emp~detstate.

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

  METHOD copy_instance.
    DATA lt_emp_cr  TYPE TABLE FOR CREATE zsvg_i_emp.
    DATA lt_proj_cr TYPE TABLE FOR CREATE zsvg_i_emp\_proj.

    " Read the data with keys
    READ ENTITIES OF zsvg_i_emp IN LOCAL MODE
         ENTITY emp
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_emp)
         ENTITY emp BY \_proj
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_proj)
         FAILED DATA(lt_fail).

    IF lt_fail IS NOT INITIAL.
      RETURN.
    ENDIF.

    " Fill itab for create
    lt_emp_cr = VALUE #(
        FOR lwa_emp IN lt_emp
        ( %cid      = keys[ Id = lwa_emp-Id ]-%cid
          %is_draft = keys[ Id = lwa_emp-Id ]-%param-%is_draft
          %data     = CORRESPONDING #( lwa_emp EXCEPT Id CreatedBy CreatedAt LastchangedBy LastchangedAt LocinstLastchangedAt )
          %control  = VALUE #( Fname = if_abap_behv=>mk-on
                               Lname = if_abap_behv=>mk-on
                               Dob   = if_abap_behv=>mk-on
                               Loc   = if_abap_behv=>mk-on ) ) ).

    lt_proj_cr = VALUE #(
        FOR lwa_emp IN lt_emp
        FOR lwa_proj IN lt_proj
        ( %cid_ref  = keys[ Id = lwa_emp-Id ]-%cid
          %is_draft = keys[ Id = lwa_emp-Id ]-%param-%is_draft
          %target   = VALUE #(
              ( %cid      = '1'
                %is_draft = keys[ Id = lwa_emp-Id ]-%param-%is_draft
                %data     = CORRESPONDING #( lwa_proj EXCEPT Id EmpId CreatedBy CreatedAt LastchangedBy LastchangedAt LocinstLastchangedAt )
                %control  = VALUE #( name      = if_abap_behv=>mk-on
                                     loc       = if_abap_behv=>mk-on
                                     Alloc     = if_abap_behv=>mk-on
                                     StartDate = if_abap_behv=>mk-on
                                     Active    = if_abap_behv=>mk-on
                                     endDate   = if_abap_behv=>mk-on ) ) ) ) ).

    " Create
    MODIFY ENTITIES OF zsvg_i_emp IN LOCAL MODE
           ENTITY emp
           CREATE
           FROM lt_emp_cr
           ENTITY emp
           CREATE BY \_proj
           FROM lt_proj_cr
           MAPPED DATA(lt_map)
           FAILED lt_fail.

    " Fill mapped
    IF lt_fail IS INITIAL.
      mapped = CORRESPONDING #( lt_map ).
    ENDIF.
  ENDMETHOD.

  METHOD new_instance.
    DATA lt_emp_cr  TYPE TABLE FOR CREATE zsvg_i_emp.
    DATA lt_proj_cr TYPE TABLE FOR CREATE zsvg_i_emp\_proj.

    " Fill itab for create
    lt_emp_cr = VALUE #( ( %cid      = keys[ 1 ]-%cid
                           %is_draft = keys[ 1 ]-%param-%is_draft
                           %data     = VALUE #( Fname = 'fname'
                                                Lname = 'lname'
                                                Dob   = '19900101'
                                                Loc   = 'ban' )
                           %control  = VALUE #( Fname = if_abap_behv=>mk-on
                                                Lname = if_abap_behv=>mk-on
                                                Dob   = if_abap_behv=>mk-on
                                                Loc   = if_abap_behv=>mk-on ) ) ).

    lt_proj_cr = VALUE #( ( %cid_ref  = keys[ 1 ]-%cid
                            %is_draft = keys[ 1 ]-%param-%is_draft
                            %target   = VALUE #( ( %cid      = '2'
                                                   %is_draft = keys[ 1 ]-%param-%is_draft
                                                   %data     = VALUE #( name      = 'name'
                                                                        loc       = 'ban'
                                                                        Alloc     = '100'
                                                                        StartDate = '20000101'
                                                                        Active    = 'X' )

                                                   %control  = VALUE #( name      = if_abap_behv=>mk-on
                                                                        loc       = if_abap_behv=>mk-on
                                                                        Alloc     = if_abap_behv=>mk-on
                                                                        StartDate = if_abap_behv=>mk-on
                                                                        Active    = if_abap_behv=>mk-on ) ) ) ) ).

    " Create
    MODIFY ENTITIES OF zsvg_i_emp IN LOCAL MODE
           ENTITY emp
           CREATE
           FROM lt_emp_cr
           ENTITY emp
           CREATE BY \_proj
           FROM lt_proj_cr
           MAPPED DATA(lt_map)
           FAILED DATA(lt_fail)
           REPORTED DATA(lt_repo).

    " Fill mapped
    IF lt_fail IS INITIAL.
      mapped = CORRESPONDING #( lt_map ).
    ENDIF.
  ENDMETHOD.

  METHOD detstate.
    DATA lt_emp_up TYPE TABLE FOR UPDATE zsvg_i_emp.

    READ ENTITIES OF zsvg_i_emp IN LOCAL MODE
         ENTITY emp
         FIELDS ( Loc )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_emp)
         FAILED DATA(lt_fail).

    IF lt_fail IS NOT INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_emp INTO DATA(lwa_emp).
      CASE lwa_emp-Loc.
        WHEN 'BAN'.
          APPEND VALUE #( %tky           = lwa_emp-%tky
                          State          = 'KA'
                          %control-State = if_abap_behv=>mk-on ) TO lt_emp_up.
        WHEN 'PUN'.
          APPEND VALUE #( %tky           = lwa_emp-%tky
                          State          = 'MH'
                          %control-State = if_abap_behv=>mk-on ) TO lt_emp_up.
        WHEN 'HYD'.
          APPEND VALUE #( %tky           = lwa_emp-%tky
                          State          = 'TL'
                          %control-State = if_abap_behv=>mk-on ) TO lt_emp_up.
        WHEN 'CHN'.
          APPEND VALUE #( %tky           = lwa_emp-%tky
                          State          = 'TN'
                          %control-State = if_abap_behv=>mk-on ) TO lt_emp_up.
      ENDCASE.
    ENDLOOP.

    MODIFY ENTITIES OF zsvg_i_emp IN LOCAL MODE
           ENTITY emp
           UPDATE
           FIELDS ( State )
           WITH lt_emp_up
           FAILED lt_fail.
  ENDMETHOD.

ENDCLASS.
