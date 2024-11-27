INTERFACE zif_s4_to_btp
  PUBLIC .

  TYPES json TYPE /ui2/cl_json=>json.

  CONSTANTS:
    BEGIN OF header_request,
      grant_type       TYPE string VALUE 'grant_type=client_credentials' ##no_text,
      accept           TYPE string VALUE 'accept' ##no_text,
      application_json TYPE string VALUE 'application/json' ##no_text,
      content_type     TYPE string VALUE 'content-type' ##no_text,
    END OF header_request .

  CONSTANTS:
    BEGIN OF http_status,
      status_ok      TYPE int4 VALUE 200 ##no_text,
      status_created TYPE int4 VALUE 201 ##no_text,
    END OF http_status.

  DATA request TYPE REF TO if_http_client.
  DATA feature_toggle_process TYPE string.

  METHODS create_http_client
    IMPORTING
        feature_toggle_process type string.

  METHODS set_header_fields_values.

  METHODS send_get
    RETURNING
      VALUE(result) TYPE json.

  METHODS send_post
    IMPORTING
      !request_body_content TYPE any
    RETURNING
      VALUE(result)         TYPE json .

  METHODS send_delete
    IMPORTING
      !request_body_content TYPE any
    RETURNING
      VALUE(result)         TYPE json.

  METHODS call_api
    RETURNING
      VALUE(result) TYPE json.

  METHODS prepare_request
    IMPORTING
      !http_method TYPE REF TO zif_http_method .

  METHODS convert_internal_table_to_json
    IMPORTING
      internal_table TYPE any
    RETURNING
      VALUE(result)  TYPE json.

  METHODS set_body_to_request
    IMPORTING
      !request_body_content TYPE json.

  METHODS validate_response
    RETURNING
      VALUE(result) TYPE json.


  METHODS get_destination
    IMPORTING
      feature_toggle_name TYPE string
      destination_name    TYPE string
    RETURNING
      VALUE(result)       TYPE rfcdest.

  METHODS set_default_parameters.

ENDINTERFACE.
