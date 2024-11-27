class ZCL_S4_TO_BTP definition
  public
  create public .

public section.

  interfaces ZIF_S4_TO_BTP .

  aliases SEND_DELETE
    for ZIF_S4_TO_BTP~SEND_DELETE .
  aliases SEND_GET
    for ZIF_S4_TO_BTP~SEND_GET .
  aliases SEND_POST
    for ZIF_S4_TO_BTP~SEND_POST .

  methods CONSTRUCTOR
    importing
      !FEATURE_TOGGLE_PROCESS type STRING .
  PROTECTED SECTION.
private section.

  aliases FEATURE_TOGGLE_PROCESS
    for ZIF_S4_TO_BTP~FEATURE_TOGGLE_PROCESS .
  aliases HEADER_REQUEST
    for ZIF_S4_TO_BTP~HEADER_REQUEST .
  aliases HTTP_STATUS
    for ZIF_S4_TO_BTP~HTTP_STATUS .
  aliases REQUEST
    for ZIF_S4_TO_BTP~REQUEST .
  aliases CALL_API
    for ZIF_S4_TO_BTP~CALL_API .
  aliases CONVERT_INTERNAL_TABLE_TO_JSON
    for ZIF_S4_TO_BTP~CONVERT_INTERNAL_TABLE_TO_JSON .
  aliases CREATE_HTTP_CLIENT
    for ZIF_S4_TO_BTP~CREATE_HTTP_CLIENT .
  aliases GET_DESTINATION
    for ZIF_S4_TO_BTP~GET_DESTINATION .
  aliases PREPARE_REQUEST
    for ZIF_S4_TO_BTP~PREPARE_REQUEST .
  aliases SET_BODY_TO_REQUEST
    for ZIF_S4_TO_BTP~SET_BODY_TO_REQUEST .
  aliases SET_DEFAULT_PARAMETERS
    for ZIF_S4_TO_BTP~SET_DEFAULT_PARAMETERS .
  aliases SET_HEADER_FIELDS_VALUES
    for ZIF_S4_TO_BTP~SET_HEADER_FIELDS_VALUES .
  aliases VALIDATE_RESPONSE
    for ZIF_S4_TO_BTP~VALIDATE_RESPONSE .
  aliases JSON
    for ZIF_S4_TO_BTP~JSON .
ENDCLASS.



CLASS ZCL_S4_TO_BTP IMPLEMENTATION.


  METHOD constructor.
    me->feature_toggle_process = feature_toggle_process.
    create_http_client( feature_toggle_process ).
    set_default_parameters( ).
  ENDMETHOD.


  METHOD zif_s4_to_btp~send_get.
    CHECK request IS BOUND.

    DATA(http_get) = NEW zcl_http_method_get( ).
    prepare_request( http_get ).
    result = call_api( ).
  ENDMETHOD.


  METHOD zif_s4_to_btp~send_post.
    CHECK request IS BOUND.

    DATA(mrm_data_json) = convert_internal_table_to_json( request_body_content ).
    IF mrm_data_json IS INITIAL.
      " Exception - blank body
      RETURN.
    ENDIF.

    DATA(http_post) = NEW zcl_http_method_post( ).
    prepare_request( http_post ).
    set_body_to_request( mrm_data_json ).

    result = call_api( ).
  ENDMETHOD.


  METHOD zif_s4_to_btp~send_delete.
    CHECK request IS BOUND.

    DATA(http_delete) = NEW zcl_http_method_delete( ).
    prepare_request( http_delete ).
    set_body_to_request( request_body_content ).

    result = call_api( ).
  ENDMETHOD.


  METHOD ZIF_S4_TO_BTP~call_api.
    request->send( ).
    request->receive( ).

    validate_response( ).

    result = request->response->get_cdata( ).
  ENDMETHOD.


  METHOD zif_s4_to_btp~convert_internal_table_to_json.
    DATA(internal_table_json) = /ui2/cl_json=>serialize( data = internal_table ).
    result = TEXT-002 && internal_table_json && TEXT-003.
  ENDMETHOD.


  METHOD zif_s4_to_btp~prepare_request.
    request->request->set_method( http_method->get_method( ) ).
    cl_http_utility=>set_request_uri(
      request = request->request
      uri     = ''
    ).
  ENDMETHOD.


  METHOD zif_s4_to_btp~set_body_to_request.
    request->request->set_cdata( zif_s4_to_btp=>header_request-grant_type ).
    request->request->set_cdata( data = request_body_content ).
  ENDMETHOD.


  METHOD ZIF_S4_TO_BTP~VALIDATE_RESPONSE.
    request->response->get_status( IMPORTING code = DATA(response_status) ).

    IF response_status NE zif_s4_to_btp=>http_status-status_ok AND
       response_status NE zif_s4_to_btp=>http_status-status_created.

*      raise exception type zcx_mm_mrm
*                  message id 'zmm_mrm' number 035
*                  with requisition->response->get_cdata( ).

    ENDIF.
  ENDMETHOD.


  METHOD create_http_client.
    CONSTANTS ft_parameter_name_destination TYPE string VALUE 'destination_name'.

    DATA(destination) = get_destination(
        feature_toggle_name = feature_toggle_process
        destination_name = ft_parameter_name_destination
    ).

    cl_http_client=>create_by_destination(
      EXPORTING
        destination = destination
      IMPORTING
        client = request
    ).

    IF sy-subrc <> 0.
      "exception
      RETURN.
    ENDIF.

    set_default_parameters( ).
  ENDMETHOD.


  METHOD ZIF_S4_TO_BTP~GET_DESTINATION.
    result = NEW zcl_feature_toggle( feature_toggle_name )->get_constant_value( destination_name ).
  ENDMETHOD.


  METHOD ZIF_S4_TO_BTP~SET_DEFAULT_PARAMETERS.
    request->propertytype_logon_popup = request->co_disabled.
    request->propertytype_accept_cookie = if_http_client=>co_disabled.
  ENDMETHOD.


  METHOD zif_s4_to_btp~set_header_fields_values.
    request->request->set_header_field(
      name = zif_s4_to_btp=>header_request-accept
      value = zif_s4_to_btp=>header_request-application_json
    ).

    request->request->set_header_field(
        name = zif_s4_to_btp=>header_request-content_type
        value = zif_s4_to_btp=>header_request-application_json
    ).
  ENDMETHOD.
ENDCLASS.
