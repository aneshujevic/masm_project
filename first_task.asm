.MODEL small
.DATA
    intro_message DB "Started calculating..", 0Ah, "Sum is: $"
    exit_message DB "Zzzzzz... Going to sleep now, bye, bye..$"
    dividend DW 0Ah
.STACK
.CODE

COMMENT @
    1.	Napisati programu u asembleru za x86 kojim se određuje i ispisuje sledeća suma:
    S = 1! - 2! + 3! - ... + (-1) (n+1) n!,  n<8
    Ulaz i izlaz podataka treba da bude praćen odgovarajućim tekstom.
@

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

in_message MACRO
    mov dx, OFFSET intro_message
    mov ah, 09h
    int 21h
ENDM

out_message MACRO
    mov dx, OFFSET exit_message
    mov ah, 09h
    int 21h
ENDM

COMMENT @
    Prvo delimo broj i njegov ostatak stavljamo na stog,
    nakon toga sa stoga kupimo ostatke pri deljenju sa 10 (decimalni sistem)
    i ispisujemo iste
    dx predstavlja ostatak dok se u ax cuva kolicnik jer radimo sa deljenikom od 16 bita (word)
@
write_number_sum PROC NEAR
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
    ret
write_number_sum ENDP

COMMENT @
    Prvo proveravamo da li je brojac paran ili nije
    ako nije paran preskacemo instrukciju za negaciju registra ax u koji cuvamo faktorijel
    ako jeste paran ukljucujemo instrukciju promene znaka
    i racunamo faktorijel sa tim predznakom
@
fact PROC NEAR
    mov ax, cx
    mov dx, 2h
    div dl
    cmp ah, 1h
    mov ax, 1h
    je positive
        neg ax
    positive: 
    mov dx, 0h
    loopa:
        mul cx
    loop loopa
    ret 
fact ENDP

Start:
    mov ax, @DATA
    mov ds, ax

    in_message

    mov dx, 0h
    mov cx, 7h
    push dx
    factoriel_loop:
        push cx
        call fact
        pop cx
        pop dx
        add dx, ax
        push dx
    loop factoriel_loop

    pop ax
    call write_number_sum
    print_newline

    out_message

    mov ax, 4c00h
    int 21h

END Start
