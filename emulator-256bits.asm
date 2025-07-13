;************************************************************************************************
; EMULADOR DE 256 BITS 
; Actualidad : Funionando con $2.30 y con recarga
;************************************************************************************************ 
;
; RA2 --------------> RST
; RA3 --------------> R/W
; RA4 --------------> CLK
; RB7 --------------> I/O
; OSC --------------> RC = 3.3K & 22pF
;
;************************************************************************************************



            LIST      P=16F84A, F=INHX8M
            include "P16F84A.inc"


            ORG     0x0000

            GOTO    Label_0001
            ORG     0x0004
            RETFIE
Label_0001  BCF     STATUS    , RP0
            MOVLW   0x00
            MOVWF   0x0C
            MOVLW   0x1D
            MOVWF   EEADR
            BSF     STATUS    , RP0
            BSF     EECON1    , 00
            BCF     STATUS    , RP0
            MOVF    EEDATA    , W
            SUBWF   0x0C      , W
            BTFSS   STATUS    , C
            GOTO    Label_0002

;************************************************************************************************
;******************************************* RECARGA ********************************************
                               ;*********************************;

       movlw     0x1E
       movwf     EEADR
       bsf       STATUS , RP0
       bsf       EECON1 , 0
       bcf       STATUS , RP0
       movlw     0x00
       xorwf     EEDATA , W
       btfsc     STATUS , Z
       goto      SEGUIR
       movlw     0x01
       xorwf     EEDATA , W
       btfsc     STATUS , Z
       goto      SEGUIR
  
       MOVLW     0X20
       MOVWF     EEADR 
       bsf       STATUS , RP0
       bsf       EECON1 , 0
       bcf       STATUS , RP0
       MOVLW     0X00
       XORWF     EEDATA,W
       BTFSS     STATUS,Z
       GOTO      SIGO 
       MOVLW     0X01            
       MOVWF     EEDATA         
       CALL      ESCRIVE
       goto      SEGUIR

SIGO   MOVLW     0x00   
       MOVWF     EEDATA
       MOVLW     0X1D
       MOVWF     EEADR
REC    INCF      EEADR
       MOVLW     0X21
       XORWF     EEADR,W
       BTFSC     STATUS,Z 
       goto      SEGUIR     
       CALL      ESCRIVE  
       GOTO      REC 



;************************************************************************************************
;************************************************************************************************

SEGUIR      
            BSF     STATUS    , RP0
            MOVLW   0x1F
            MOVWF   TRISA
            MOVLW   0x00
            MOVWF   TRISB
            BCF     STATUS    , RP0
            CLRF    PORTB
            CLRF    PORTA
Label_0004  BCF     STATUS    , RP0
            MOVLW   0x00
            MOVWF   0x0E
            MOVLW   0x00
            MOVWF   EEADR
            MOVLW   0xAD                       ;<------- 1∞ Byte 
            MOVWF   PORTB
            CLRF    0x0D
Label_0003  BTFSS   PORTA     , 02
            GOTO    Label_0003
Label_0006  BTFSS   PORTA     , 02
            GOTO    Label_0004
            BTFSC   PORTA     , 03
            CALL    Label_0005
            BTFSC   PORTA     , 04
            GOTO    Label_0006
Label_0007  BTFSS   PORTA     , 02
            GOTO    Label_0004
            BTFSC   PORTA     , 03
            CALL    Label_0005
            BTFSS   PORTA     , 04
            GOTO    Label_0007
            INCF    0x0D      , f
            BTFSC   0x0D      , 03
            GOTO    Label_0008
            RLF     PORTB     , f
            GOTO    Label_0006
Label_0008  BCF     STATUS    , RP0
            INCF    0x0E      , f
            MOVLW   0x0E
            XORWF   0x0E      , W
            BTFSC   STATUS    , Z
            GOTO    Label_0009
            INCF    EEADR     , f
            CLRF    0x0D
            CALL    Label_000A
            MOVWF   PORTB
            GOTO    Label_0006
Label_000B  BTFSS   PORTA     , 02
            GOTO    Label_0004
            BTFSC   PORTA     , 03
            CALL    Label_0005
            BTFSC   PORTA     , 04
            GOTO    Label_000B
Label_000C  BTFSS   PORTA     , 02
            GOTO    Label_0004
            BTFSC   PORTA     , 03
            CALL    Label_0005
            BTFSS   PORTA     , 04
            GOTO    Label_000C
            INCF    0x0D      , f
            BTFSC   0x0D      , 03
            GOTO    Label_0009
            RLF     PORTB     , f
            GOTO    Label_000B
Label_0009  BCF     STATUS    , RP0
            INCF    EEADR     , f
            MOVLW   0x20
            XORWF   EEADR     , W
            BTFSC   STATUS    , Z
            GOTO    Label_0004
            CLRF    0x0D
            BSF     STATUS    , RP0
            BSF     EECON1    , 00
            BCF     STATUS    , RP0
            MOVF    EEDATA    , W
            MOVWF   PORTB
            GOTO    Label_000B
Label_0005  BCF     STATUS    , RP0
            MOVLW   0x0C
            SUBWF   EEADR     , W
            BTFSS   STATUS    , C
            GOTO    Label_000D
            BSF     PORTB     , 07
            MOVF    0x0D      , W
            ADDWF   PCL       , f
            GOTO    Label_000E
            GOTO    Label_000F
            GOTO    Label_0010
            GOTO    Label_0011
            GOTO    Label_0012
            GOTO    Label_0013
            GOTO    Label_0014
            GOTO    Label_0015
Label_000E  BSF     EEDATA    , 07
            GOTO    Label_0016
Label_000F  BSF     EEDATA    , 06
            GOTO    Label_0016
Label_0010  BSF     EEDATA    , 05
            GOTO    Label_0016
Label_0011  BSF     EEDATA    , 04
            GOTO    Label_0016
Label_0012  BSF     EEDATA    , 03
            GOTO    Label_0016
Label_0013  BSF     EEDATA    , 02
            GOTO    Label_0016
Label_0014  BSF     EEDATA    , 01
            GOTO    Label_0016
Label_0015  BSF     EEDATA    , 00
            GOTO    Label_0016
Label_0016  BSF     STATUS    , RP0
            BSF     EECON1    , 02
            BCF     EECON1    , 04
            MOVLW   0x55
            MOVWF   EECON2
            MOVLW   0xAA
            MOVWF   EECON2
            BSF     EECON1    , 01
Label_0017  BTFSS   EECON1    , 04
            GOTO    Label_0017
            BCF     EECON1    , 04
            BCF     EECON1    , 02
            BCF     STATUS    , RP0
Label_000D  BTFSC   PORTA     , 03
            GOTO    Label_000D
            RETURN
Label_000A  MOVF    0x0E      , W
            ADDWF   PCL       , f
            NOP
;************************************************************************************************
;******************************************* DATA BASE ******************************************
                                  ;*****************************;     

            RETLW   0x83
            RETLW   0xFF
            RETLW   0xFF
            RETLW   0x5A
            RETLW   0xC4
            RETLW   0xA3
            RETLW   0xF6
            RETLW   0x00
            RETLW   0x01
            RETLW   0x1E
            RETLW   0x28
            RETLW   0xFF
            RETLW   0xC0

;************************************************************************************************
;************************************************************************************************

Label_0002  BCF     STATUS    , RP0
            MOVLW   0x14
            MOVWF   0x0C
            MOVLW   0x20
            MOVWF   EEADR
Label_0019  DECF    EEADR     , f
            MOVLW   0x00
            MOVWF   EEDATA


ESCRIVE     BSF     STATUS    , RP0
            BSF     EECON1    , 02
            BCF     EECON1    , 04
            MOVLW   0x55
            MOVWF   EECON2
            MOVLW   0xAA
            MOVWF   EECON2
            BSF     EECON1    , 01
Label_0018  BTFSS   EECON1    , 04
            GOTO    Label_0018
            CLRF    EECON1
            BCF     STATUS    , RP0
            RETURN

            DECFSZ  0x0C      , f
            GOTO    Label_0019
Label_001A  GOTO    Label_001A                    ; <-----  ERROR EN TARJETA
            MOVF    0x0E      , W
            ADDWF   PCL       , f
            NOP

;************************************************************************************************
;******************************************* DATA BASE ******************************************
                                  ;*****************************;     


            RETLW   0x83
            RETLW   0xFF
            RETLW   0xFF
            RETLW   0x5A
            RETLW   0xC4
            RETLW   0xA3
            RETLW   0xF6
            RETLW   0x00
            RETLW   0x01
            RETLW   0x1E
            RETLW   0x28
            RETLW   0xFF
            RETLW   0xC0

;************************************************************************************************
;************************************************************************************************

            BCF     STATUS    , RP0
            MOVLW   0x00
            MOVWF   0x0C
            MOVLW   0x1D
            MOVWF   EEADR
            BSF     STATUS    , RP0
            BSF     EECON1    , 00
            BCF     STATUS    , RP0
            MOVF    EEDATA    , W
            SUBWF   0x0C      , W
            BTFSS   STATUS    , C
            GOTO    Label_0002

;************************************************************************************************
;******************************************* RECARGA ********************************************
                               ;*********************************;

       movlw     0x1E
       movwf     EEADR
       bsf       STATUS , RP0
       bsf       EECON1 , 0
       bcf       STATUS , RP0
       movlw     0x00
       xorwf     EEDATA , W
       btfsc     STATUS , Z
       goto      SEGUIR
       movlw     0x01
       xorwf     EEDATA , W
       btfsc     STATUS , Z
       goto      SEGUIR
  
       MOVLW     0X20
       MOVWF     EEADR 
       bsf       STATUS , RP0
       bsf       EECON1 , 0
       bcf       STATUS , RP0
       MOVLW     0X00
       XORWF     EEDATA,W
       BTFSS     STATUS,Z
       GOTO      SIGO2 
       MOVLW     0X01            
       MOVWF     EEDATA         
       CALL      ESCRIVE
       goto      SEGUIR

SIGO2   MOVLW     0x00   
       MOVWF     EEDATA
       MOVLW     0X1D
       MOVWF     EEADR
REC2    INCF      EEADR
       MOVLW     0X21
       XORWF     EEADR,W
       BTFSC     STATUS,Z 
       goto      SEGUIR     
       CALL      ESCRIVE  
       GOTO      REC2 



;***********************************************************************************************
;***********************************************************************************************

            BSF     STATUS    , RP0
            MOVLW   0x1F
            MOVWF   TRISA
            MOVLW   0x00
            MOVWF   TRISB
            BCF     STATUS    , RP0
            CLRF    PORTB
            CLRF    PORTA
            BCF     STATUS    , RP0
            MOVLW   0x00
            MOVWF   0x0E
            MOVLW   0x00
            MOVWF   EEADR
            MOVLW   0xAD                        ;<------- 1∞ Byte 
            MOVWF   PORTB
            CLRF    0x0D
            BTFSS   PORTA     , 02
            GOTO    Label_0003
            BTFSS   PORTA     , 02
            GOTO    Label_0004
            BTFSC   PORTA     , 03
            CALL    Label_0005
            BTFSC   PORTA     , 04
            GOTO    Label_0006
            BTFSS   PORTA     , 02
            GOTO    Label_0004
            BTFSC   PORTA     , 03
            CALL    Label_0005
            BTFSS   PORTA     , 04
            GOTO    Label_0007
            INCF    0x0D      , f
            BTFSC   0x0D      , 03
            GOTO    Label_0008
            RLF     PORTB     , f
            GOTO    Label_0006
            BCF     STATUS    , RP0
            INCF    0x0E      , f
            MOVLW   0x0E
            XORWF   0x0E      , W
            BTFSC   STATUS    , Z
 
            ORG     0x2000
            DATA    0x0F
            DATA    0x0F
            DATA    0x0F
            DATA    0x0F
 
            ORG     0x2007
            DATA    0x1F
 
            ORG     0x2100
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00                    ; <------------- 0x1D ; Aca realiza el descuento
            DATA    0x00                    ; <------------- 0x1E ; para el valor de esta 
            DATA    0x00                    ; <------------- 0x1F ; tarjeta
            DATA    0x00                    ; Implementacion de la recarga jugando con las tres
            DATA    0x00                    ; direcciones anteriores
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00
            DATA    0x00

            END
