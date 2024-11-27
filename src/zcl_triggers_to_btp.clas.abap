CLASS zcl_triggers_to_btp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM zcl_s4_to_btp.

  PUBLIC SECTION.

    ALIASES feature_toggle_process
        FOR zif_s4_to_btp~feature_toggle_process.

    METHODS constructor.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_triggers_to_btp IMPLEMENTATION.

    METHOD constructor.
        super->constructor( 'open_triggers_destination' ).
    ENDMETHOD.

ENDCLASS.
