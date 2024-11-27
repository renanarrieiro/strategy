class ZCL_HTTP_METHOD definition
  public
  create public .

public section.

  interfaces zif_http_method.

  aliases GET_METHOD
    for zif_http_method~GET_METHOD .

  METHODS constructor
    IMPORTING
        method TYPE zif_http_method~ty_method.

protected section.
private section.

  aliases METHOD
    for zif_http_method~METHOD .
ENDCLASS.

CLASS ZCL_HTTP_METHOD IMPLEMENTATION.

  method constructor.
    me->method = method.
  endmethod.

  method zif_http_method~GET_METHOD.
    result = me->method.
  endmethod.
ENDCLASS.
