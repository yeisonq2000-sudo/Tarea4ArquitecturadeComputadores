.MODEL SMALL
.STACK 100H

.DATA
    msg1 DB 13,10,'Ingrese un numero hexadecimal (00-FF): $'

    menu DB 13,10,'Seleccione una operacion:',13,10
         DB '1. AND - Apagar bits',13,10
         DB '2. OR  - Encender bits',13,10
         DB '3. XOR - Invertir bits',13,10
         DB 'Opcion: $'

    msg2 DB 13,10,'Resultado binario: $'
    error DB 13,10,'Entrada invalida.$'

    buffer DB 3,0,3 DUP(?)
    dato DB ?
    resultado DB ?

.CODE

MAIN PROC

    MOV AX, @DATA
    MOV DS, AX

    ; Leer numero hexadecimal
    LEA DX, msg1
    MOV AH, 09H
    INT 21H

    CALL LeerByte
    JNC DatoOK
    JMP ErrorEntrada

DatoOK:
    MOV dato, AL

    ; Mostrar menu
    LEA DX, menu
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H

    CMP AL, '1'
    JE AplicarAND

    CMP AL, '2'
    JE AplicarOR

    CMP AL, '3'
    JE AplicarXOR

    JMP ErrorEntrada

; OPERACION AND

AplicarAND:
    MOV AL, dato
    AND AL, 0FH
    JMP Guardar

; OPERACION OR

AplicarOR:
    MOV AL, dato
    OR AL, 80H
    JMP Guardar

; OPERACION XOR

AplicarXOR:
    MOV AL, dato
    XOR AL, 0FH

Guardar:
    MOV resultado, AL

    ; Mostrar resultado en binario
    LEA DX, msg2
    MOV AH, 09H
    INT 21H

    MOV BL, resultado
    MOV CX, 8

ImprimirBits:
    SHL BL, 1

    MOV DL, '0'
    JNC MostrarBit

    MOV DL, '1'

MostrarBit:
    MOV AH, 02H
    INT 21H

    LOOP ImprimirBits

    ; Salto de linea
    MOV DL, 13
    MOV AH, 02H
    INT 21H

    MOV DL, 10
    MOV AH, 02H
    INT 21H

    JMP Salir

ErrorEntrada:
    LEA DX, error
    MOV AH, 09H
    INT 21H

Salir:
    MOV AX, 4C00H
    INT 21H

MAIN ENDP

; LEER NUMERO HEXADECIMAL

LeerByte PROC

    MOV BYTE PTR [buffer+1], 0
    LEA DX, buffer
    MOV AH, 0AH
    INT 21H

    CMP BYTE PTR [buffer+1], 2
    JNE EntradaMala

    MOV AL, [buffer+2]
    CALL HexToNibble
    JC EntradaMala

    MOV BL, AL

    MOV AL, [buffer+3]
    CALL HexToNibble
    JC EntradaMala

    MOV CL, 4
    SHL BL, CL
    OR AL, BL

    CLC
    RET

EntradaMala:
    STC
    RET

LeerByte ENDP

; CONVERTIR HEXADECIMAL

HexToNibble PROC

    CMP AL, '0'
    JB Invalido

    CMP AL, '9'
    JBE Numero

    AND AL, 0DFH

    CMP AL, 'A'
    JB Invalido

    CMP AL, 'F'
    JA Invalido

    SUB AL, 'A'-10
    CLC
    RET

Numero:
    SUB AL, '0'
    CLC
    RET

Invalido:
    STC
    RET

HexToNibble ENDP

END MAIN
