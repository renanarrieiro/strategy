CLASS zcl_feature_toggle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  METHODS constructor
    IMPORTING
        proccess_name type string.

  METHODS get_constant_value
    IMPORTING
        constant_name type string
    RETURNING
        VALUE(result) type string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_feature_toggle IMPLEMENTATION.
METHOD constructor.
ENDMETHOD.

METHOD get_constant_value.
ENDMETHOD.
ENDCLASS.
