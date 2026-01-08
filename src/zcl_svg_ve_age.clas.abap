CLASS zcl_svg_ve_age DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_svg_ve_age IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_emp TYPE STANDARD TABLE OF zsvg_c_emp.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    lt_emp = CORRESPONDING #( it_original_data ).

    LOOP AT lt_emp ASSIGNING FIELD-SYMBOL(<fs>) WHERE Dob IS NOT INITIAL.
      ASSIGN COMPONENT 'DOB' OF STRUCTURE <fs> TO FIELD-SYMBOL(<fs_dob>).
      ASSIGN COMPONENT 'AGE' OF STRUCTURE <fs> TO FIELD-SYMBOL(<fs_age>).
      <fs_age> = lv_today+0(4) - <fs_dob>+0(4).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_emp ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
