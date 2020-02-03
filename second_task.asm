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

print_digit MACRO
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

read_number PROC NEAR
    mov bx, 0h
    mov dx, 0h

    loopa:
        mov ah, 01h
        int 21h

        cmp al, 0Dh
    je exit
        mov ah, 0h
        sub al, 30h

        xchg ax, bx
        mul dividend
        add ax, bx
        add ax, dx
        xchg ax, bx
    jmp loopa
    
    exit:
    mov ax, bx
    ret
read_number ENDP

print_number PROC NEAR
    push cx
    mov dx, 0h
    mov cx, 0h
    loops:
        div dividend
        push dx
        mov dx, 0h
        inc cx
        cmp ax, 0h
    jne loops

    loopsa:
        pop dx
        print_digit
    loop loopsa

    pop cx
    ret
print_number ENDP

Start:
    mov ax, @DATA
    mov ds, ax

    intro_message

    mov cx, 0h
    mov dx, 0h
    mov di, 0h
    read_loop:
        push dx
        call read_number
        pop dx

        add dx, ax

        mov array[di], ax
        inc di
        inc di
        
        inc cx
        cmp cx, 0Ah
    jne read_loop

    mov ax, dx
    mov dx, 0h
    div dividend

    push dx
    push ax
    print_quotient_message
    pop ax
    call print_number
    print_newline
    pop dx

    push dx
    print_remainder_message
    pop dx
    mov ax, dx
    call print_number
    print_newline

    print_array_message

    mov cx, 0h
    mov di, 0h
    print_loop:
        mov ax, array[di]
        inc di
        inc di

        call print_number
        print_space

        inc cx
        cmp cx, 0Ah
    jne print_loop

    print_newline
    out_message

    mov ax, 4c00h
    int 21h
END Start
