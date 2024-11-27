CLASS zcl_http_method_delete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM zcl_http_method.

  PUBLIC SECTION.
    METHODS constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_http_method_delete IMPLEMENTATION.

    METHOD constructor.
        super->constructor( zif_http_method~http_methods-method_delete ).
    ENDMETHOD.

ENDCLASS.
