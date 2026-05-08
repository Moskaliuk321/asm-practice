; practice6.asm – Signed vs Unsigned comparison
; Assemble: nasm -f elf32 practice6.asm -o practice6.o
; Link:     ld -m elf_i386 -o practice6 practice6.o

section .data
    prompt      db  "Enter two numbers: ", 0
    prompt_len  equ $ - prompt

    msg_signed  db  "SIGNED: ", 0
    msg_unsign  db  "UNSIGNED: ", 0
    msg_lt      db  "a < b", 0
    msg_eq      db  "a = b", 0
    msg_gt      db  "a > b", 0
    msg_max_s   db  "max_signed: ", 0
    msg_max_u   db  "max_unsigned: ", 0
    newline     db  0xA

section .bss
    buffer      resb    128         ; input buffer
    outbuf      resb    12          ; temporary for int->str

section .text
    global _start

_start:
    ; ----- I/O: print prompt -----
    mov     eax, 4                  ; sys_write
    mov     ebx, 1                  ; stdout
    mov     ecx, prompt
    mov     edx, prompt_len
    int     0x80

    ; ----- I/O: read input -----
    mov     eax, 3                  ; sys_read
    mov     ebx, 0                  ; stdin
    mov     ecx, buffer
    mov     edx, 128
    int     0x80

    ; ----- PARSE: extract a and b -----
    mov     esi, eax                ; save bytes read
    mov     ecx, buffer
    call    parse_int
    mov     edi, eax                ; edi = a
    mov     ecx, edx                ; update pointer
    call    parse_int
    mov     ebp, eax                ; ebp = b

    ; ----- LOGIC: signed comparison -----
    mov     eax, msg_signed
    call    print_str

    cmp     edi, ebp
    je      .seq
    jl      .slt
    mov     eax, msg_gt
    call    print_str
    jmp     .signed_done
.slt:
    mov     eax, msg_lt
    call    print_str
    jmp     .signed_done
.seq:
    mov     eax, msg_eq
    call    print_str
.signed_done:
    call    print_newline

    ; ----- LOGIC: unsigned comparison -----
    mov     eax, msg_unsign
    call    print_str

    cmp     edi, ebp
    je      .ueq
    jb      .ult
    mov     eax, msg_gt
    call    print_str
    jmp     .unsigned_done
.ult:
    mov     eax, msg_lt
    call    print_str
    jmp     .unsigned_done
.ueq:
    mov     eax, msg_eq
    call    print_str
.unsigned_done:
    call    print_newline

    ; ----- MATH: max_signed -----
    mov     eax, msg_max_s
    call    print_str

    cmp     edi, ebp
    jge     .max_s_edi
    mov     eax, ebp
    call    print_signed
    jmp     .max_s_done
.max_s_edi:
    mov     eax, edi
    call    print_signed
.max_s_done:
    call    print_newline

    ; ----- MATH: max_unsigned -----
    mov     eax, msg_max_u
    call    print_str

    cmp     edi, ebp
    jae     .max_u_edi
    mov     eax, ebp
    call    print_unsigned
    jmp     .max_u_done
.max_u_edi:
    mov     eax, edi
    call    print_unsigned
.max_u_done:
    call    print_newline

    ; ----- Exit -----
    mov     eax, 1                  ; sys_exit
    xor     ebx, ebx
    int     0x80

; ============================================================
; parse_int – parse a 32-bit signed integer from buffer
; Input:  ecx = pointer into buffer
; Output: eax = integer value, edx = pointer after parsing
; ============================================================
parse_int:
    push    ebx
    xor     eax, eax                ; accumulator
    xor     ebx, ebx                ; sign flag (0=positive, 1=negative)

.skip_space:
    mov     dl, byte [ecx]
    cmp     dl, ' '
    je      .advance
    cmp     dl, 0x09                ; tab
    je      .advance
    cmp     dl, 0x0A                ; newline
    je      .advance
    cmp     dl, 0x0D                ; carriage return
    je      .advance
    jmp     .check_sign
.advance:
    inc     ecx
    jmp     .skip_space

.check_sign:
    cmp     dl, '-'
    jne     .check_plus
    mov     ebx, 1                  ; negative
    inc     ecx
    jmp     .digit_loop
.check_plus:
    cmp     dl, '+'
    jne     .digit_loop
    inc     ecx

.digit_loop:
    mov     dl, byte [ecx]
    cmp     dl, '0'
    jb      .done
    cmp     dl, '9'
    ja      .done
    imul    eax, eax, 10
    sub     dl, '0'
    movsx   edx, dl
    add     eax, edx
    inc     ecx
    jmp     .digit_loop

.done:
    cmp     ebx, 1
    jne     .finish
    neg     eax
.finish:
    mov     edx, ecx                ; return updated pointer
    pop     ebx
    ret

; ============================================================
; print_str – print a null-terminated string
; Input: eax = string address
; ============================================================
print_str:
    push    eax
    push    ebx
    push    ecx
    push    edx
    mov     edx, eax
    xor     ecx, ecx
.strlen:
    cmp     byte [edx + ecx], 0
    je      .write
    inc     ecx
    jmp     .strlen
.write:
    mov     edx, ecx                ; length
    mov     ecx, eax                ; string address
    mov     eax, 4                  ; sys_write
    mov     ebx, 1                  ; stdout
    int     0x80
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

; ============================================================
; print_newline
; ============================================================
print_newline:
    push    eax
    push    ebx
    push    ecx
    push    edx
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, newline
    mov     edx, 1
    int     0x80
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

; ============================================================
; print_signed – print a signed 32-bit integer
; Input: eax = value
; ============================================================
print_signed:
    push    eax
    push    ebx
    push    ecx
    push    edx

    cmp     eax, 0x80000000         ; special case: -2147483648
    jne     .not_min
    mov     eax, min_int_str
    call    print_str
    jmp     .ps_done

.not_min:
    test    eax, eax
    jns     .positive
    push    eax
    ; print minus sign
    mov     byte [outbuf], '-'
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, outbuf
    mov     edx, 1
    int     0x80
    pop     eax
    neg     eax                     ; make positive
.positive:
    call    print_unsigned          ; reuse working print_unsigned
.ps_done:
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

; ============================================================
; print_unsigned – print an unsigned 32-bit integer
; Input: eax = value
; ============================================================
print_unsigned:
    push    eax
    push    ebx
    push    ecx
    push    edx

    call    uint_to_str
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, outbuf
    ; edx = length from uint_to_str
    int     0x80

    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

; ============================================================
; uint_to_str – convert unsigned integer to decimal string
; Input:  eax = unsigned integer
; Output: outbuf = decimal string, edx = length
; ============================================================
uint_to_str:
    push    eax
    push    ebx
    push    ecx
    push    edi

    mov     edi, outbuf + 11
    mov     byte [edi], 0
    dec     edi
    mov     ecx, 10
    mov     ebx, eax

    test    ebx, ebx
    jnz     .convert
    mov     byte [outbuf], '0'
    mov     edx, 1
    jmp     .uint_done

.convert:
    xor     edx, edx
    mov     eax, ebx
    div     ecx
    add     dl, '0'
    mov     [edi], dl
    dec     edi
    mov     ebx, eax
    test    ebx, ebx
    jnz     .convert

    mov     eax, outbuf + 11
    sub     eax, edi
    sub     eax, 1
    mov     edx, eax
    inc     edi
    mov     esi, edi
    mov     edi, outbuf
    mov     ecx, edx
    cld
    rep movsb

.uint_done:
    pop     edi
    pop     ecx
    pop     ebx
    pop     eax
    ret

section .data
    min_int_str db "-2147483648", 0