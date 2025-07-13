;                        PA,2 -|1   \__/ 18|- PA,1:
;                        PA,3 -|2        17|- PA,0:
;                   OUT  PA,4 -|3   PIC  16|- OSC  R
;                      Reset  -|4  16F84 15|- OSC
;                      Masa   -|5        14|- Vcc
;                RST IN  PB,0 -|6        13|- PB,7: CLK
;                        PB,1 -|7        12|- PB,6:
;                        PB,2 -|8        11|- PB,5:
;                        PB,3 -|9________10|- PB,4:
; By MrFlower revision h
        LIST P=PIC16F84
        #INCLUDE P16F84.INC
        
CONBIT  EQU     0x0C            ; Registro contador de bits de un byte
PRUEBA  EQU     0x0D            ; Si es 1 se ha borrado un bit=1
SAVE    EQU     0x0E            ; Guarda el contenido de EEDATA
R1      EQU     0x0F
R2      EQU     0x10
PA      EQU     PORTA
PB      EQU     PORTB
ESTADO  EQU     STATUS


        ORG     0x2100
        DE      0xE0,0x3C,0x00,0x00
        DE      0x00,0x00,0x00,0x00
        DE      0x00,0x0F,0x00,0x3F
        DE      0x0F,0xFF,0xFF,0xFF

        ORG     0               ; Vector de Reset
        goto    INICIO
        ORG     4               ; Vector de Interrupci¢n

;------RUTINA DE COMPROBACION DE SI ES RST,WRITE o WRITECARRY-----------------
        bcf     PA,4            ; Si RST=1 I/O=0
RSTW    btfsc   PB,7            ; Detecta si CLK es 1 para RST 1 si es asi
        goto    RST             ; se produce RST
        btfsc   PB,0            ; Si RST=0 sin CLK puede ser borrado o
        goto    RSTW            ; writecarry
        btfsc   EEDATA,7        ; Si RST=0 ha de tener el valor del ultimo
        bsf     PA,4            ; bit leido
        btfss   PRUEBA,0        ; Si PRUEBA es 1 se prudujo un borrado antes
        goto    WRITE           ; por lo que pasara a hacer writecarry
        goto    WRITECA

;------CONFIGURACION DEL PIC--------------------------------------------------
INICIO  bsf     ESTADO,5
        clrf    TRISA           ; PA salidas, PB entradas (por defecto)
        bcf     ESTADO,5        
        movlw   0x88            ; Direccionamiento indirecto de EECON1
        movwf   FSR
        btfsc   PB,0            ; Mira si RST=1 justo despues de que Vcc=1
        bcf     PA,4            ; por si RST estaba antes a 1 que Vcc

;------RESET DE LA TARJETA----------------------------------------------------
RST     clrf    EEADR           ; Se direcciona al byte 0
        bsf     INDF,0          ; Se lee el byte 0
        clrf    PRUEBA          ; Se desabilita la posibilidad de writecarry
        movlw   8               ; Resetea el contador de bits
        movwf   CONBIT          ; 

RSToff  btfsc   PB,0            ; Espera que RST=0
        goto    RSToff
        bsf     PA,4            ; 1§bit despues del RST a 1
        movlw   b'10010000'     ; Activa interrupcion para PB,0 (RST)
        movwf   INTCON            

;------RUTINA DE CLK----------------------------------------------------------
CLK     btfss   PB,7
        goto    CLK
        clrf    PRUEBA          ; Se desabilita la posibilidad de writecarry
        rlf     EEDATA,F        ; Rota el siguiente bit a la izquierda
        decfsz  CONBIT,F        ; Quita un contador de bits, si=0 se han leido
        goto    CLKoff          ; todos los bits del byte
        movlw   8               ; Resetea el contador de bits
        movwf   CONBIT
        incf    EEADR,F         ; Incrementa el contador de bytes
        btfsc   EEADR,4         ; Comprueba si se han leido los 15 bytes
        clrf    EEADR           ; Direcionando byte 0
        bsf     INDF,0          ; Lee byte
        
CLKoff  btfsc   PB,7            ; Espera a que CLK=0
        goto    CLKoff
        btfss   EEDATA,7        ; Bit 7 de EEDATA a PB,4(I/O)
        bcf     PA,4
        btfsc   EEDATA,7
        bsf     PA,4
        goto    CLK

;------RUTINA DE BORRADO------------------------------------------------------
WRITE   btfss   PB,7            ; Espera el pulso de clk para escribir
        goto    WRITE

;------RUTINA DE PROTECCION DE BYTES, BLOQUEO Y WRITE-------------------------
PROTEC  movf    EEADR,W
        addwf   PCL,F
        goto    noWRITE         ; Byte0
        goto    BLOQUEO         ; Byte1
        goto    BLOQUEO
        goto    BLOQUEO
        goto    BLOQUEO
        goto    BLOQUEO
        goto    BLOQUEO
        goto    BLOQUEO         ; Byte7
        goto    WRITEok         ; Byte8
        goto    WRITEok
        goto    WRITEok
        goto    WRITEok
        goto    WRITEok         ; Byte12
        goto    BLOQUEO
        goto    BLOQUEO
        goto    BLOQUEO         ; Byte15

WRITEok btfss   EEDATA,7        ; Si EEDATA,7=1 pone PRUEBA=1 para saber
        goto    noWRITE         ; que se ha producido un borrado de un bit=1
        bsf     PRUEBA,0        ; si es 0 no se produce borrado.
        bcf     PA,4            ; I/O=0
        bcf     EEDATA,7        ; A 0 por si se intenta borrar varias veces
        movf    EEDATA,W        ; Guarda EEDATA para recuperarlo mas tarde
        movwf   SAVE
        bsf     INDF,0          ; Lee el byte en el que se quedo EEADR
        movf    CONBIT,W        ; Comprobamos que bit fue el ultimo leido
        addwf   CONBIT,W        ; para pasar a ponerlo a 0
        addwf   PCL,F           
        NOP
        NOP                     
        bcf     EEDATA,0        ; Bit0
        goto    EndBit
        bcf     EEDATA,1        ; Bit1
        goto    EndBit          
        bcf     EEDATA,2        ; Bit2
        goto    EndBit
        bcf     EEDATA,3        ; Bit3
        goto    EndBit
        bcf     EEDATA,4        ; Bit4
        goto    EndBit
        bcf     EEDATA,5        ; Bit5
        goto    EndBit
        bcf     EEDATA,6        ; Bit6
        goto    EndBit
        bcf     EEDATA,7        ; Bit7
        
EndBit  call    Eeprom
Wend    movf    SAVE,W          ; Restaura el contenido de EEDATA
        movwf   EEDATA
noWRITE btfsc   PB,7            ; Espera a que CLK=0
        goto    noWRITE
        movlw   b'10010000'     ; Activa interrupcion para PB,0 (RST)
        movwf   INTCON            
        goto    CLK

BLOQUEO movlw   b'10010000'     ; Activa interrupcion para PB,0 (RST)
        movwf   INTCON          ; lo unico que saca del BLOQUEO es RST o Vcc=0  
        goto    BLOQUEO

;------RUTINA DE WRITECARRY---------------------------------------------------
WRITECA movf    EEDATA,W        ; Guarda EEDATA para recuperarlo despues de
        movwf   SAVE            ; writecarry
        clrf    PRUEBA          ; Se deshabilita la posibilidad de writecarry
        incf    EEADR,F         ; Incrementa EEADR al siguiente al ultimo
        movlw   0xFF            ; leido y lo pone a FF
        movwf   EEDATA
        call    Eeprom
        decf    EEADR,F         ; Pone EEADR donde estaba
        goto    Wend            

;------RUTINA DE ESCRITURA EN LA EEPROM---------------------------------------
Eeprom  bsf     ESTADO,RP0      ; Guarda el bit en la eeprom
        bsf     EECON1,WREN
        movlw   0x55
        movwf   EECON2
        movlw   0xAA
        movwf   EECON2
        bsf     EECON1,WR
Wcomp   btfss   EECON1,EEIF     ; Espera a que finalize la operacion de 
        goto    Wcomp           ; esritura
        bcf     EECON1,EEIF     
        bcf     EECON1,WREN
        bcf     ESTADO,RP0      ;Bank 0
        return

        END
