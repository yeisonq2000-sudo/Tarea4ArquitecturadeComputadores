.MODEL SMALL
.STACK 100H

.DATA
    msg1 DB 13,10,'Ingrese primer numero hexadecimal: $'
    msg2 DB 13,10,'Ingrese segundo numero hexadecimal: $'
    msg3 DB 13,10,'Ingrese operador (+ o -): $'
    msg4 DB 13,10,'Resultado: $'
    error DB 13,10,'Entrada invalida.$'

    buffer DB 3,0,3 DUP(?)
    num1 DB ?
    num2 DB ?
    resultado DW ?
    negativo DB 0

.CODE

MAIN PROC

    MOV AX, @DATA
    MOV DS, AX

    ; Leer primer numero
    LEA DX, msg1
    MOV AH, 09H
    INT 21H

    CALL LeerByte
    JNC PrimerOK
    JMP ErrorEntrada

PrimerOK:
    MOV num1, AL

    ; Leer segundo numero
    LEA DX, msg2
    MOV AH, 09H
    INT 21H

    CALL LeerByte
    JNC SegundoOK
    JMP ErrorEntrada

SegundoOK:
    MOV num2, AL

    ; Leer operador
    LEA DX, msg3
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H

    CMP AL, '+'
    JE Suma

    CMP AL, '-'
    JE Resta

    JMP ErrorEntrada

; SUMA

Suma:
    XOR AX, AX
    MOV AL, num1
    ADD AL, num2
    ADC AH, 0

    MOV resultado, AX
    MOV negativo, 0
    JMP Mostrar

; RESTA

Resta:
    XOR AX, AX
    MOV AL, num1
    SUB AL, num2

    MOV negativo, 0
    JNC Guardar

    NEG AL
    MOV negativo, 1

Guardar:
    MOV resultado, AX
    JMP Mostrar

; MOSTRAR RESULTADO

Mostrar:
    LEA DX, msg4
    MOV AH, 09H
    INT 21H

    CMP negativo, 1
    JNE Imprimir

    MOV DL, '-'
    MOV AH, 02H
    INT 21H

Imprimir:
    MOV BX, resultado

    MOV AL, BH
    CALL ImprimirHex

    MOV AL, BL
    MOV CL, 4
    SHR AL, CL
    CALL ImprimirHex

    MOV AL, BL
    AND AL, 0FH
    CALL ImprimirHex

    MOV DL, 'h'
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

; IMPRIMIR DIGITO HEXADECIMAL

ImprimirHex PROC

    AND AL, 0FH
    CMP AL, 9
    JBE Digito

    ADD AL, 7

Digito:
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    RET

ImprimirHex ENDP

END MAIN
