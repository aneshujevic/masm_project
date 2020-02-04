.MODEL small
.DATA
    intro_message DB "Started calculating..", 0Ah, "Enter n: $"
    summary_message DB "Sum is: $"
    exit_message DB "Zzzzzz... Going to sleep now, bye, bye..$"
    dividend DW 0Ah
    sign DW 01h
    times DW ?
.STACK
.CODE

COMMENT @
    1.	Napisati programu u asembleru za x86 kojim se određuje i ispisuje sledeća suma:
    S = 1! - 2! + 3! - ... + (-1) (n+1) n!,  n<8
    Ulaz i izlaz podataka treba da bude praćen odgovarajućim tekstom.
@

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

print_minus MACRO
    push ax
    mov dl, 2Dh 
    mov ah, 02h
    int 21h
    pop ax
ENDM

in_message MACRO
    mov dx, OFFSET intro_message
    mov ah, 09h
    int 21h
ENDM

sum_message MACRO
    mov dx, OFFSET summary_message
    mov ah, 09h
    int 21h
ENDM

out_message MACRO
    mov dx, OFFSET exit_message
    mov ah, 09h
    int 21h
ENDM

read_number_ax PROC NEAR
    mov ah, 01h
    int 21h

    mov ah, 0h                              ; set higher bits to 0
    sub al, 30h                             ; calculate the hex not ASCII value

    ret
read_number_ax ENDP

write_number_ax PROC NEAR
    cmp ax, 0                               ; compare with 0 to see the sign
    jge positive
        print_minus                         ; print minus if not positive
        neg ax                              ; negate ax so we can print it nicely

    positive:
        mov dx, 0h                          ; set appropriate register to 0
        mov cx, 0h                          ; set appropriate register to 0

    remainder_loop:
        div dividend                        ; divide number in ax by 10 (0Ah)
        push dx                             ; push the remainder onto the stack
        mov dx, 0h                          ; set remainder register to 0
        inc cx                              ; increment counter needed for printing
        cmp ax, 0h                          ; check if quotient is 0
    jne remainder_loop

    print_digit_loop:
        pop dx                              ; pop digit from stack
        print_digit_dx                      ; print popped digit 
    loop print_digit_loop

    ret
write_number_ax ENDP

fact_ax PROC NEAR
    push cx                                 ; save counter
    mov ax, 01h                             ; setting ax 1
    mov dx, 0h                              ; set dx as 0

    fact_calculate:                         ; while counter is not 0
        mul cx                              ; multiply ax by that counter
    loop fact_calculate

    pop cx                                  ; get counter
    ret                                     ; return
fact_ax ENDP

Start:
    mov ax, @DATA
    mov ds, ax

    in_message                              ; print intro message

    call read_number_ax                     ; read number to ax
    mov times, ax                           ; use it for a counter
    mov cx, 1h                              ; init counter

    mov dx, 0h                              ; dx is used as sum
    push dx                                 ; push it because we pop it in the first iteration
    factoriel_loop:
        call fact_ax                        ; calculate factoriel to ax

        pop dx                              ; get sum until now
        cmp sign, 0h                        ; we change the sign so we know if we should add or sub
        jge positive
            sub dx, ax                      ; we subtract
            jmp save                        ; skip the add part

        positive:
            add dx, ax                      ; add factoriel to the sum

        save:
            neg sign                        ; inverting the sign
            push dx                         ; save the sum for next iteration
        
        inc cx
        cmp cx, times
    jle factoriel_loop                      ; we loop until we've done n times

    print_newline
    sum_message                             ; print sum message
    pop ax                                  ; pop the sum from loop before to ax
    call write_number_ax                    ; print the sum
    print_newline

    out_message                             ; print outro message

    mov ax, 4c00h
    int 21h

END Start
