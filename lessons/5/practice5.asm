
; ============================================================

; Practical 5: Sum of digits and division (unsigned)

; Input: positive number x (1..2_000_000_000)

; Output: 

;   1) sumDigits(x)

;   2) len(x)

;   3) sumDigits(x) + len(x)

; ============================================================



section .data

    buffer_in    db 16 dup(0)

    buffer_out   db 16 dup(0)

    newline      db 10



section .bss

    x            resd 1

    sum_digits   resd 1

    length_num   resd 1



section .text

    global _start



; ========== I/O: atoi ==========

; Convert ASCII string to integer

; Input: ESI -> string

; Output: EAX = number

atoi:

    push    ebx

    push    ecx

    xor     eax, eax

    xor     ecx, ecx

.atoi_loop:

    movzx   ebx, byte [esi + ecx]

    cmp     bl, 10

    je      .atoi_done

    cmp     bl, 0

    je      .atoi_done

    sub     bl, '0'

    jb      .atoi_done

    cmp     bl, 9

    ja      .atoi_done

    imul    eax, eax, 10

    add     eax, ebx

    inc     ecx

    jmp     .atoi_loop

.atoi_done:

    pop     ecx

    pop     ebx

    ret



; ========== I/O: itoa ==========

; Convert integer to ASCII string

; Input: EAX = number

; Output: prints to stdout

print_num:

    push    eax

    push    ebx

    push    ecx

    push    edx

    push    edi

    

    mov     ecx, 10

    mov     edi, buffer_out + 15

    mov     byte [edi], 0

    dec     edi

    

    cmp     eax, 0

    jne     .convert

    mov     byte [edi], '0'

    dec     edi

    jmp     .print

    

.convert:

    xor     edx, edx

    div     ecx

    add     dl, '0'

    mov     [edi], dl

    dec     edi

    test    eax, eax

    jnz     .convert

    

.print:

    inc     edi

    mov     ecx, edi

    mov     edx, buffer_out + 15

    sub     edx, edi

    

    mov     eax, 4

    mov     ebx, 1

    int     0x80

    

    pop     edi

    pop     edx

    pop     ecx

    pop     ebx

    pop     eax

    ret



; ========== MAIN ==========

_start:

    ; ========== I/O: read input ==========

    mov     eax, 3

    mov     ebx, 0

    mov     ecx, buffer_in

    mov     edx, 16

    int     0x80



    ; ========== PARSE: convert to integer ==========

    mov     esi, buffer_in

    call    atoi

    mov     [x], eax



    ; ========== MATH: calculate sum of digits ==========

    ; ========== LOOP: while x > 0 ==========

    mov     eax, [x]

    mov     ecx, eax

    mov     dword [sum_digits], 0



.sum_loop:

    cmp     ecx, 0

    je      .sum_done

    

    ; ========== DIV: unsigned division ==========

    xor     edx, edx          ; clear EDX before div

    mov     eax, ecx

    mov     ebx, 10

    div     ebx               ; EDX:EAX / 10, EAX = quotient, EDX = remainder

    

    add     [sum_digits], edx ; add remainder to sum

    mov     ecx, eax          ; continue with quotient

    jmp     .sum_loop

.sum_done:



    ; ========== LOGIC: calculate length (number of digits) ==========

    ; ========== LOOP: count digits ==========

    mov     eax, [x]

    mov     ecx, eax

    mov     dword [length_num], 0

    

    cmp     ecx, 0

    jne     .len_loop

    mov     dword [length_num], 1

    jmp     .len_done

    

.len_loop:

    cmp     ecx, 0

    je      .len_done

    inc     dword [length_num]

    

    ; ========== DIV: unsigned division ==========

    xor     edx, edx          ; clear EDX before div

    mov     eax, ecx

    mov     ebx, 10

    div     ebx               ; EDX:EAX / 10

    

    mov     ecx, eax

    jmp     .len_loop

.len_done:



    ; ========== I/O: print sumDigits(x) ==========

    mov     eax, [sum_digits]

    call    print_num

    

    mov     eax, 4

    mov     ebx, 1

    mov     ecx, newline

    mov     edx, 1

    int     0x80



    ; ========== I/O: print len(x) ==========

    mov     eax, [length_num]

    call    print_num

    

    mov     eax, 4

    mov     ebx, 1

    mov     ecx, newline

    mov     edx, 1

    int     0x80



    ; ========== I/O: print sumDigits(x) + len(x) ==========

    mov     eax, [sum_digits]

    add     eax, [length_num]

    call    print_num

    

    mov     eax, 4

    mov     ebx, 1

    mov     ecx, newline

    mov     edx, 1

    int     0x80



    ; ========== EXIT ==========

    mov     eax, 1

    xor     ebx, ebx

    int     0x80

