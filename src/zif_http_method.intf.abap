interface ZIF_HTTP_METHOD
  public .

  types TY_METHOD type STRING .

  constants:
    begin of http_methods,
      method_get type string value 'GET' ##no_text,
      method_post type string value 'POST' ##no_text,
      method_delete type string value 'DELETE' ##no_text,
    end of http_methods .

  data METHOD type TY_METHOD .

  methods GET_METHOD
    returning
      value(RESULT) type TY_METHOD .
endinterface.
