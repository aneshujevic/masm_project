.MODEL small
.DATA
    enter_message DB "Welcome to the most advanced statistics program ever.", 0Ah, "Enter 10 numbers to get the arithmetic mean:", 0Ah, "[PRESS ENTER TO INPUT NEXT NUMBER]$"
    array_message DB "Array is:", 0Ah, "$"
    quotient_message DB "Quotient is: $"
    remainder_message DB "Remainder is: $"
    exit_message DB "Zzzzzz... Going to sleep now, bye, bye..$"
    dividend DW 0Ah
    multiplier DB 0Ah
    array DW 0h DUP(10)
.STACK
.CODE

COMMENT @
	2.Napisati program u asembleru za x86 kojim se učitava niz pozitivnih celih brojeva od 10 elemenata,
	određuje i ispisuje srednja vrednost niza (celobrojni deo srednje vrednosti i ostatak), a zatim ispisuju svi elementi niza.
	Ulaz i izlaz podataka treba da bude praćen odgovarajućim tekstom.
@

intro_message MACRO
    mov dx, OFFSET enter_message
    
    mov ah, 09h
    int 21h
    print_newline

ENDM

out_message MACRO
    mov dx, OFFSET exit_message
    mov ah, 09h
    int 21h
ENDM

print_digit_dx MACRO
    add dx, 30h
    mov ah, 02h
    int 21h
ENDM

print_newline MACRO
    mov dl, 0Ah
    mov ah, 02h
    int 21h
ENDM

print_space MACRO
    mov dl, 20h
    mov ah, 02h
    int 21h
ENDM

print_message MACRO
    mov ah, 09h
    int 21h
ENDM

print_quotient_message MACRO
    mov dx, offset quotient_message
    print_message
ENDM

print_remainder_message MACRO
    mov dx, offset remainder_message
    print_message
ENDM

print_array_message MACRO
    mov dx, offset array_message
    print_message
ENDM

read_number_ax PROC NEAR
    mov bx, 0h
    mov dx, 0h

    loopa:
        mov ah, 01h                     ; read character
        int 21h

        cmp al, 0Dh                     ; compare if the character is ,,ENTER'' button
    je exit
        mov ah, 0h                      ; set higher bits to zero
        sub al, 30h                     ; get the hex value of number entered 

        xchg ax, bx                     ; temporary save ax (value entered) to bx
        mul dividend                    ; multiply by 10 (0Ah - 1W)
        add ax, bx                      ; add value read (from bx) to ax
        add ax, dx                      ; add higher bits of result of multiplication to ax
        xchg ax, bx                     ; save to bx for next iteration
    jmp loopa
    
    exit:
    mov ax, bx                          ; when number is read, save it to ax for future use
    ret
read_number_ax ENDP

print_number_ax PROC NEAR
    mov dx, 0h
    mov cx, 0h

    div_loop:
        div dividend                    ; divide by 10 (0Ah - 1W)                             
        push dx                         ; push the remainder onto the stack
        mov dx, 0h                      ; reset remainder to 0 for next divison
        inc cx                          ; increment counter needed for print loop
        cmp ax, 0h                      ; check if the quotient of divion is 0
    jne div_loop

    print_digit_loop:                   
        pop dx                          ; pop digits from stack
        print_digit_dx                  ; print poped digit
    loop print_digit_loop               ; do it while cx != 0

    ret
print_number_ax ENDP

Start:
    mov ax, @DATA
    mov ds, ax

    intro_message

    mov cx, 0h
    mov dx, 0h
    mov di, 0h
    
    read_loop:
        push dx                             ; save dx (sum of entered numbers so far)
        call read_number_ax                 ; read a number
        pop dx                              ; get dx from stack

        add dx, ax                          ; add a read number to the sum

        mov array[di], ax                   ; put read number into appropriate place in array
        inc di                              ; increment pointer twice (1W)
        inc di
        
        inc cx                              ; increment counter until 10 (0Ah)
        cmp cx, 0Ah
    jne read_loop

    mov ax, dx                              ; mov sum to ax so we can calculate the mean
    mov dx, 0h                              ; reset dx to 0
    div dividend                            ; divide sum with 10 (0Ah - 1W)

    push dx                                 ; save dx (remainder)
    push ax                                 ; save ax (quotient)
    print_quotient_message                  ; print quotient message
    pop ax                                  ; get ax needed for printing (quotient)
    call print_number_ax                    ; print number from ax
    print_newline                           ; newline
    pop dx                                  ; get dx (remainder)

    push dx                                 ; save dx (remainder)
    print_remainder_message                 ; print remainder message
    pop dx                                  ; get dx (remainder)
    mov ax, dx                              ; move it to ax
    call print_number_ax                    ; print ax (remainder)
    print_newline                           ; newline

    print_array_message

    mov cx, 0h
    mov di, 0h
    print_loop:
        mov ax, array[di]                   ; get element from array to ax
        inc di                              ; increment pointer twice (1W)
        inc di

        push cx                             ; save counter
        call print_number_ax                ; print element
        pop cx                              ; get counter
        print_space                         ; print space

        inc cx                              ; increment counter
        cmp cx, 0Ah                         ; loop until 10 iterations(0Ah)
    jne print_loop

    print_newline                           ; print newline
    out_message                             ; print out message

    mov ax, 4c00h
    int 21h
END Start
