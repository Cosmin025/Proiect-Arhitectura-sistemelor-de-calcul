    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA
encoded     DB  80 DUP(0)
temp        DB  '0x', 160 DUP(0)
fileHandler DW  ?
filename    DB  'in/in.txt', 0          ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'out/out.txt', 0        ; Trebuie sa existe acest director 'out'!
message     DB  80 DUP(0)
msglen      DW  ?
padding     DW  0
iterations  DW  0 
x           DW  ?
x0          DW  ?
a           DW  0
b           DW  0

;MY VARIABLES
;time variables
last_x dw 0
ora DB ?  ;CH
minut DB ?  ;CL
secunda DB ?  ;DH
sutimE DB ?  ;DL

nume db 'Vasilache'
LEN_NUME EQU $-NUME
prenume db 'Cosmin'
LEN_PRENUME EQU $-PRENUME

;encoding alphabet
cod64 db 'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW4ly5EkrqsnAxubTV03a=L/d'

extended_message db 80 dup(0)

nr_blocuri db ?
len_extendedMessage db 0    ;lungime mesajului extins
nr_padding db 0             ;numar caractere de padding
len_coded db 0            ;lungime mesajului codat
counter db 0                ;pozitia caracterului din alfabetul de codare

    ;.386
    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX
;;;;;
    
;;;;;;
    CALL    FILE_INPUT                  ; NU MODIFICATI!

    call CALCULEAZA_A
    call CALCULEAZA_B

    mov ax,A
    mov ax,B

 
    CALL    SEED                        ; TODO - Trebuie implementata

;implementare test
    mov ax,13
    mov x0,ax
    MOV x,ax

    MOV AX,104
    mov a,ax
    MOV AX,200
    mov b,ax
    
    CALL    ENCRYPT                     ; TODO - Trebuie implementata
    
    CALL    ENCODE                      ; TODO - Trebuie implementata
    

    mov al,len_coded
    mov ch,0
    mov cl,al
    mov si,offset encoded
    

    p:
        mov ax,[si]
        ;mov [di],ax
        mov ah,2
        mov dl,al
        int 21h


        inc si

    loop p
                                        ; Mai jos se regaseste partea de
                                        ; afisare pe baza valorilor care se
                                        ; afla in variabilele x0, a, b, respectiv
                                        ; in sirurile message si encoded.
                                        ; NU MODIFICATI!
    MOV     AH, 3CH                     ; BIOS Int - Open file
    MOV     CX, 0
    MOV     AL, 1                       ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile          ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    CALL    WRITE                       ; NU MODIFICATI!

    MOV     AH, 4CH                     ; Bios Int - Terminate with return code
    MOV     AL, 0                       ; AL - Return code
    INT     21H

CALCULEAZA_A:
    MOV CX,len_prenume
    MOV SI,OFFSET PRENUME
    MOV AX,0
    MOV DX,0

    AGAIN_CALC_A:
        MOV AX,[SI]
        MOV AH,0
        ADD [A],AX
        MOV AX,[A]
        INC SI
    LOOP AGAIN_CALC_A

    MOV AX,A
    MOV BX,255
    DIV BX
    MOV [A],DX
    MOV AX,0
    MOV DX,0
    
RET


CALCULEAZA_B:
    MOV CX,len_nume
    MOV SI,OFFSET NUME
    MOV AX,0
    MOV DX,0
    
    AGAIN_CALC_B:
        MOV AX,[SI]
        MOV AH,0
        ADD [B],AX
        MOV AX,[B]
        INC SI
    LOOP AGAIN_CALC_B

    MOV AX,B
    MOV BX,255
    DIV BX
    MOV [B],DX
    MOV AX,0
    MOV DX,0

RET    

FILE_INPUT:
    MOV     AH, 3DH                     ; BIOS Int - Open file
    MOV     AL, 0                       ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName         ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    MOV     AH, 3FH                     ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]           ; BX - File handler
    MOV     CX, 80                      ; CX - Number of bytes to read
    MOV     DX, OFFSET message          ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                ; Return: AX - number of read bytes

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H

    RET



SEED:
    MOV     AH, 2CH                     ; BIOS Int - Get System Time
    INT     21H
                                        ; TODO1: Completati subrutina SEED
                                        ; astfel incat la final sa fie salvat
                                        ; in variabila 'x' si 'x0' continutul 
                                        ; termenului initial

     ;CALCUL X0            
    mov ch,0Eh 
    mov cl,17h 
    mov dh,26h
    mov dl,4Ch

    MOV [ora],CH
    MOV [MINUT],CL
    MOV [secunda],DH
    MOV [SUTIME],DL

    mov ah,0
    mov al,[ora]
    mov bx,60
    mul bx
    
    add al,minut
    mov bx,60
    mul bx

    add al,secunda
    mov bx,100
    mul bx
    add al,[sutime]

    mov bx,255
    div bx
    mov ax,DX
    ;SALVARE IN X SI XO
    MOV [X],AX
    MOV [X0],AX

    RET

ENCRYPT:
    MOV     CX, [msglen]
    MOV     SI, OFFSET message
                                            ; TODO3: Completati subrutina ENCRYPT
                                            ; astfel incat in cadrul buclei sa fie
                                            ; XOR-at elementul curent din sirul de
                                            ; intrare cu termenul corespunzator din
                                            ; sirul generat, iar mai apoi sa fie generat
                                            ; si termenul urmator

    ;;;;;;;;           
    encrypt_letter:
        MOV BX,[X]
        mov last_x,bx
        MOV AX,[SI]
        XOR AX,bx
        MOV [SI],AX 
        CALL RAND
        INC SI
    LOOP encrypt_letter

    MOV bx,last_x
    mov x,bx
    ;;;;;;;;                            

    RET
RAND:
    MOV     AX, [x]
                                            ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'

    ;;;;;;;;
     MOV BX,[A]
    MUL BX      
    ADD AX,[B]     
    MOV BX,255
    DIV BX 
    MOV [X],DX
    MOV AX,0 
    MOV BX,0                           
    ;;;;;;;;

    RET
ENCODE:

    ;;;;;;;
    mov cx,[msglen]
    mov si,offset message
    mov di,offset extended_message

    push cx
copy:
    mov al,[si]
    mov [di],al
    inc si 
    inc di
    loop copy

    pop cx
    mov ax,cx
    mov bx,3
    div bl

    cmp ah,0
    jz rest0;
    jnz cu_rest

rest0:
    ;lungime mesaj extins
    mov len_extendedMessage,cl

    ;numar caractere dupa criptare
    mov al,cl
    mov bl,8 
    mul bl
    mov bl,6 
    div bl
    mov len_coded,al
    
    ;numar caractere padding
    mov nr_padding,0

    ;numarare blocuri
    mov ax,cx
    mov bx,3
    div bl
    mov nr_blocuri,al

    jmp GO_CODE_MESSAGE

cu_rest:
    sub bl,ah
    add cx,bx
    ;numar caractere padding
    mov nr_padding,bl

    ;lungime mesaj extins
    mov len_extendedMessage,cl

    ;lungimea mesajului codat
    mov al,cl
    mov bl,8 
    mul bl
    mov bl,6 
    div bl
    mov len_coded,al


    ;numarare blocuri
    mov ax,cx
    mov len_extendedMessage,al
    mov bx,3
    div bl
    mov nr_blocuri,al

GO_CODE_MESSAGE:
  
    mov ch,0
    mov cl,nr_blocuri
    mov si,OFFSET extended_message
    MOV DI,offset encoded

code_block:
    ;c1
    mov al,[si]
    shr al,2
    push di
    mov di,offset cod64
    mov ah,0
    add di,ax
    mov al,[di]
    pop di

    mov [di],al
    inc di

    ;c2
    mov al,[si]
    and al,00000011b
    shl al,4

    inc si
    mov bl,[si]
    and bl,11110000b
    shr bl,4
    add al,bl 
    
    push di
    mov di,offset cod64
    mov ah,0
    add di,ax
    mov al,[di]
    pop di
    
    mov [di],al
    inc di

    ;c3
    mov al,[si]
    and al,00001111b
    shl al,2

    inc si
    mov bl,[si]
    and bl,11000000b
    shr bl,6
    add al,bl 
   
    push di
    mov di,offset cod64
    mov ah,0
    add di,ax
    mov al,[di]
    pop di
    
    mov [di],al
    inc di

    ;c4
    mov al,[si]
    and al,00111111b
    
    push di
    mov di,offset cod64
    mov ah,0
    add di,ax
    mov al,[di]
    pop di
    
    mov [di],al
    inc di
    inc si

loop code_block

;add padding caracters
mov al,nr_padding

cmp al,0
jz finish

mov ch,0
mov cl,al

mov si,offset encoded
mov bh,0
mov bl,len_coded
sub bl,nr_padding
add si,bx

    addpadding:
        mov al,'+'
        mov [si],al
   
        inc si

    loop addpadding



finish:
    mov al,len_coded
    mov ch,0
    mov cl,al
    mov si,offset encoded

    mov al,nr_blocuri
    mov ah,0
    mov iterations,ax

    RET


WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX
DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL
next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL
AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET
WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h

    MOV     AX, [iterations]
    MOV     BX, 4
    MUL     BX
    MOV     CX, AX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET
    END START