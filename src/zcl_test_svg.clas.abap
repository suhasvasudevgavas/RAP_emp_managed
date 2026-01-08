CLASS zcl_test_svg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_test_svg IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lv_op TYPE c LENGTH 3 VALUE 'U'.

    CASE lv_op.

      " Read employee
      WHEN 'R'.
        READ ENTITIES OF zsvg_i_emp
             ENTITY emp
             ALL FIELDS
             WITH VALUE #( ( Id = '2ECDA033CCF51FD0BAFBC042BC3E0916' ) )
             RESULT DATA(lt_emp)
             FAILED DATA(lt_fail).

        IF lt_fail IS INITIAL.
          out->write( lt_emp ).
        ENDIF.

        " Read project
        READ ENTITIES OF zsvg_i_emp
             ENTITY proj
             ALL FIELDS
             WITH VALUE #( ( Id = '865DE97A44891FD0B8B061C914C502BA' EmpId = 'CA8C3B6EC0741FE0B8B01A39F11CBFCD' ) )
             RESULT DATA(lt_proj)
             FAILED lt_fail.

        IF lt_fail IS INITIAL.
          out->write( lt_proj ).
        ENDIF.

        " Read by association
        READ ENTITIES OF zsvg_i_emp
             ENTITY emp
             BY \_proj
             ALL FIELDS
             WITH VALUE #( ( Id = 'CA8C3B6EC0741FE0B8B01A39F11CBFCD' ) )
             RESULT DATA(lt_proj_rba)
             FAILED lt_fail.

        IF lt_fail IS INITIAL.
          out->write( lt_proj_rba ).
        ENDIF.

      WHEN 'C'.
        " Create
        DATA lt_emp_cr TYPE TABLE FOR CREATE zsvg_i_emp.
        lt_emp_cr = VALUE #( ( %cid     = '1'
                               %data    = VALUE #( Fname = 'f3'
                                                   Lname = 'l3'
                                                   Dob   = '19900101'
                                                   Loc   = 'cob' )
                               %control = VALUE #( Fname = if_abap_behv=>mk-on
                                                   Lname = if_abap_behv=>mk-on
                                                   Dob   = if_abap_behv=>mk-on
                                                   Loc   = if_abap_behv=>mk-on ) ) ).

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY emp
               CREATE
               FROM lt_emp_cr
               MAPPED DATA(lt_map)
               FAILED lt_fail.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.
          out->write( lt_map ).
        ENDIF.

      WHEN 'CBA'.
        " Create by association
        DATA lt_proj_cr TYPE TABLE FOR CREATE zsvg_i_emp\_proj.
        lt_emp_cr = VALUE #( ( %cid     = '2'
                               %data    = VALUE #( Fname = 'f4'
                                                   Lname = 'l4'
                                                   Dob   = '19900101'
                                                   Loc   = 'cob' )
                               %control = VALUE #( Fname = if_abap_behv=>mk-on
                                                   Lname = if_abap_behv=>mk-on
                                                   Dob   = if_abap_behv=>mk-on
                                                   Loc   = if_abap_behv=>mk-on ) ) ).

        lt_proj_cr = VALUE #( ( %cid_ref = '2'
                                %target  = VALUE #( ( %cid     = '11'
                                                      %data    = VALUE #( Name      = 'p4'
                                                                          Loc       = 'ban'
                                                                          Alloc     = '100'
                                                                          StartDate = '20250101'
                                                                          Active    = 'X' )
                                                      %control = VALUE #( Name      = if_abap_behv=>mk-on
                                                                          Loc       = if_abap_behv=>mk-on
                                                                          Alloc     = if_abap_behv=>mk-on
                                                                          StartDate = if_abap_behv=>mk-on
                                                                          Active    = if_abap_behv=>mk-on ) ) ) ) ).

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY emp
               CREATE
               FROM lt_emp_cr
               ENTITY emp
               CREATE BY \_proj
               FROM lt_proj_cr
               MAPPED lt_map
               FAILED lt_fail.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.
          out->write( lt_map ).
        ENDIF.

      WHEN 'U'.
        " Update employee
        DATA lt_emp_u TYPE TABLE FOR UPDATE zsvg_i_emp.

        lt_emp_u = VALUE #( ( %data    = VALUE #( Id    = '2ECDA033CCF51FD0BAFCEF02127A6916'
                                                  Fname = 'up2' )
                              %control = VALUE #( Fname = if_abap_behv=>mk-on )    ) ).

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY emp
               UPDATE
               FROM lt_emp_u
               FAILED lt_fail.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.
        ENDIF.

        " Update project
        DATA lt_proj_u TYPE TABLE FOR UPDATE zsvg_i_proj.

        lt_proj_u = VALUE #( ( %data    = VALUE #( Id    = '2ECDA033CCF51FD0BAFCEF02127A8916'
                                                   EmpId = '2ECDA033CCF51FD0BAFCEF02127A6916'
                                                   Alloc = '001' )
                               %control = VALUE #( Alloc = if_abap_behv=>mk-on )    ) ).

        MODIFY ENTITIES OF zsvg_i_emp
               ENTITY proj
               UPDATE
               FROM lt_proj_u
               FAILED lt_fail.

        IF lt_fail IS INITIAL.
          COMMIT ENTITIES.
        ENDIF.

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
