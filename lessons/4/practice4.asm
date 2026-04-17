section .data
    prompt db "Enter number: ", 0
    prompt_len equ $ - prompt
    newline db 0xA

section .bss
    input_buf  resb 10
    output_buf resb 10

section .text
    global _start

_start:
    ; I/O: print prompt "Enter number: "
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; I/O: read string
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 10
    int 0x80

    ; parse: String to Int
    mov esi, input_buf
    xor eax, eax
    xor ebx, ebx

.str_to_int:
    mov bl, [esi]
    cmp bl, 0xA
    je .done_parse
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .str_to_int

.done_parse:
    ; math: Int to String
    mov edi, output_buf
    add edi, 9
    mov ecx, 0
    mov ebx, 10

.int_to_str:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    inc ecx
    test eax, eax
    jnz .int_to_str

    ; I/O: print result
    inc edi
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, edi
    int 0x80

    ; I/O: newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80