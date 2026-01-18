CLASS zcl_eml_op_tester DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_eml_op_tester IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lv_op TYPE c LENGTH 3 VALUE 'D'.

    CASE lv_op.
      WHEN 'R'.
        " Read emp
        READ ENTITIES OF zsvg_i_emp
             ENTITY emp
             ALL FIELDS
             WITH VALUE #( ( id = 'C2D1058E34EB1FD0BCAAEA947CE7F03B' ) )
             RESULT DATA(lt_emp)
             FAILED DATA(lt_fail)
             " TODO: variable is assigned but never used (ABAP cleaner)
             REPORTED DATA(lt_rep).

        IF lt_fail IS INITIAL.
          out->write( lt_emp ).
        ENDIF.

        " Read proj
        READ ENTITIES OF zsvg_i_emp
             ENTITY proj
             ALL FIELDS
             WITH VALUE #( ( id = 'C2D1058E34EB1FD0BCAAEAB5B54EF03B' EmpId = 'C2D1058E34EB1FD0BCAAEA947CE7F03B' ) )
             RESULT DATA(lt_proj)
             FAILED lt_fail
             REPORTED lt_rep.

        IF lt_fail IS INITIAL.
          out->write( lt_proj ).
        ENDIF.

      WHEN 'RBA'.
        " Read the project details w.r.t to emp
        READ ENTITIES OF zsvg_i_emp
             ENTITY emp
             BY \_proj
             ALL FIELDS
             WITH VALUE #( ( id = 'C2D1058E34EB1FD0BCAAEA947CE7F03B' ) ) " Key field of emp entity
             RESULT DATA(lt_proj_rba)
             LINK DATA(lt_link)
             FAILED lt_fail
             REPORTED lt_rep.

        IF lt_fail IS INITIAL.
          out->write( lt_proj_rba ).
          out->write( lt_link ).
        ENDIF.

      WHEN 'C'.
        " Create
        DATA lt_emp_c TYPE TABLE FOR CREATE zsvg_i_emp.

        lt_emp_c = VALUE #( ( %cid     = '1'
                              %data    = VALUE #( Fname = 'f'
                                                  Lname = 'l'
                                                  Dob   = '19900101'
                                                  Loc   = 'HYD' )
                              %control = VALUE #( Fname = if_abap_behv=>mk-on
                                                  Lname = if_abap_behv=>mk-on
                                                  Dob   = if_abap_behv=>mk-on
                                                  Loc   = if_abap_behv=>mk-on ) ) ).

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY emp
               CREATE
               FROM lt_emp_c
               MAPPED DATA(lt_map)
               FAILED lt_fail
               REPORTED lt_rep.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.

          out->write( lt_map ).

          READ ENTITIES OF zsvg_i_emp
               ENTITY emp
               ALL FIELDS
               WITH VALUE #( FOR key IN lt_map-emp
                             ( Id = key-Id ) )
               RESULT lt_emp
               FAILED lt_fail
               REPORTED lt_rep.

          IF lt_fail IS INITIAL.
            out->write( lt_emp ).
          ENDIF.
        ENDIF.

      WHEN 'CBA'.
        DATA lt_proj_cba TYPE TABLE FOR CREATE zsvg_i_emp\_proj.
        lt_emp_c = VALUE #( ( %cid     = '1'
                              %data    = VALUE #( Fname = 'ff'
                                                  Lname = 'll'
                                                  Dob   = '19900101'
                                                  Loc   = 'PUN' )
                              %control = VALUE #( Fname = if_abap_behv=>mk-on
                                                  Lname = if_abap_behv=>mk-on
                                                  Dob   = if_abap_behv=>mk-on
                                                  Loc   = if_abap_behv=>mk-on ) ) ).

        lt_proj_cba = VALUE #( ( %cid_ref = '1'
                                 %target  = VALUE #( ( %cid     = '2'
                                                       %data    = VALUE #( Name      = 'p10'
                                                                           Loc       = 'PUN'
                                                                           Alloc     = '100'
                                                                           StartDate = '20200101'
                                                                           Active    = 'X' )
                                                       %control = VALUE #( Name      = if_abap_behv=>mk-on
                                                                           Loc       = if_abap_behv=>mk-on
                                                                           Alloc     = if_abap_behv=>mk-on
                                                                           StartDate = if_abap_behv=>mk-on
                                                                           Active    = if_abap_behv=>mk-on ) ) ) ) ).

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY emp
               CREATE
               FROM lt_emp_c
               ENTITY emp
               CREATE BY \_proj
               FROM lt_proj_cba
               MAPPED lt_map
               FAILED lt_fail
               REPORTED lt_rep.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.

          READ ENTITIES OF zsvg_i_emp
               ENTITY emp
               ALL FIELDS
               WITH VALUE #( FOR emp IN lt_map-emp
                             ( Id = emp-Id ) )
               RESULT lt_emp
               ENTITY emp
               BY \_proj
               ALL FIELDS
               WITH VALUE #( FOR proj IN lt_map-proj
                             ( Id = proj-EmpId ) )
               RESULT lt_proj
               LINK lt_link
               FAILED lt_fail
               REPORTED lt_rep.

          IF lt_fail IS INITIAL.
            out->write( lt_emp ).
            out->write( lt_proj ).
            out->write( lt_link ).
          ENDIF.
        ENDIF.

      WHEN 'U'.
        DATA lt_emp_u  TYPE TABLE FOR UPDATE zsvg_i_emp.
        DATA lt_proj_u TYPE TABLE FOR UPDATE zsvg_i_proj.

        lt_emp_u = VALUE #( ( id             = 'EE3D176152061FD0BD874218AC58F1C9'
                              Fname          = 'u1'
                              %control-Fname = if_abap_behv=>mk-on ) ).

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY emp
               UPDATE
               FIELDS ( Fname )
               WITH lt_emp_u
               FAILED lt_fail
               REPORTED lt_rep.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.

          READ ENTITIES OF zsvg_i_emp
               ENTITY emp
               ALL FIELDS
               WITH VALUE #( ( id = 'EE3D176152061FD0BD874218AC58F1C9' ) )
               RESULT lt_emp
               FAILED lt_fail
               REPORTED lt_rep.

          IF lt_fail IS INITIAL.
            out->write( lt_emp ).
          ENDIF.
        ENDIF.

        lt_proj_u = VALUE #( ( id            = 'EE3D176152061FD0BD874218AC5911C9'
                               EmpId         = 'EE3D176152061FD0BD874218AC58F1C9'
                               Name          = 'u1'
                               %control-name = if_abap_behv=>mk-on ) ).

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY proj
               UPDATE
               FIELDS ( name )
               WITH lt_proj_u
               FAILED lt_fail
               REPORTED lt_rep.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.

          READ ENTITIES OF zsvg_i_emp
               ENTITY proj
               ALL FIELDS
               WITH VALUE #( ( id = 'EE3D176152061FD0BD874218AC5911C9' EmpId = 'EE3D176152061FD0BD874218AC58F1C9' ) )
               RESULT lt_proj
               FAILED lt_fail
               REPORTED lt_rep.

          IF lt_fail IS INITIAL.
            out->write( lt_proj ).
          ENDIF.
        ENDIF.

      WHEN 'D'.
        DATA lt_emp_d  TYPE TABLE FOR DELETE zsvg_i_emp.
        DATA lt_proj_d TYPE TABLE FOR DELETE zsvg_i_proj.

        lt_emp_d = VALUE #( ( id = 'C2D1058E34EB1FD0BCAAEA947CE7F03B' ) ).
        lt_proj_d = VALUE #( ( id = 'C2D1058E34EB1FD0BCA8A6C5AAE8303B' EmpId = 'C2D1058E34EB1FD0BCA8A6C5AAE7F03B' ) ).

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY emp
               DELETE
               FROM lt_emp_d
               FAILED lt_fail
               REPORTED lt_rep.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.
        ENDIF.

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY proj
               DELETE
               FROM lt_proj_d
               FAILED lt_fail
               REPORTED lt_rep.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.
        ENDIF.

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
