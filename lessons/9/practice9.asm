section .bss
    freq     resd 10
    line_buf resb 512
    input    resb 12

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 12
    int 0x80
    mov esi, input
    call atoi
    mov ecx, eax

    mov ebx, 12345
.gen:
    push ecx
    imul ebx, ebx, 1103515245
    add  ebx, 12345
    mov  eax, ebx
    xor  edx, edx
    mov  ecx, 10
    div  ecx
    inc  dword [freq + edx*4]
    pop  ecx
    loop .gen

    xor edi, edi
.loop:
    cmp edi, 10
    je  .exit

    ; скидаємо esi = 0 на початку кожного рядка
    xor esi, esi

    ; "D: " або "0: "
    mov eax, edi
    add al, '0'
    mov [line_buf], al
    mov byte [line_buf+1], ':'
    mov byte [line_buf+2], ' '
    mov esi, 3

    ; freq[i] / 5 хешиків
    mov eax, [freq + edi*4]
    xor edx, edx
    mov ecx, 5
    div ecx
    mov ecx, eax
.hashes:
    test ecx, ecx
    jz  .open
    mov byte [line_buf+esi], '#'
    inc esi
    dec ecx
    jmp .hashes

.open:
    mov byte [line_buf+esi], ' '
    inc esi
    mov byte [line_buf+esi], '('
    inc esi

    ; itoa(freq[i])
    mov eax, [freq + edi*4]
    mov ebx, line_buf
    add ebx, esi
    call itoa
    add esi, edx

    mov byte [line_buf+esi], ')'
    mov byte [line_buf+esi+1], 10
    add esi, 2

    mov eax, 4
    mov ebx, 1
    mov ecx, line_buf
    mov edx, esi
    int 0x80

    inc edi
    jmp .loop

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

itoa:
    push edi
    push esi
    mov  edi, ebx
    mov  esi, ebx
    mov  ecx, 10
.itoa_l:
    xor  edx, edx
    div  ecx
    add  dl, '0'
    mov  [edi], dl
    inc  edi
    test eax, eax
    jnz  .itoa_l
    mov  ecx, edi
    dec  ecx
.itoa_rev:
    cmp  esi, ecx
    jge  .itoa_done
    mov  al, [esi]
    mov  ah, [ecx]
    mov  [esi], ah
    mov  [ecx], al
    inc  esi
    dec  ecx
    jmp  .itoa_rev
.itoa_done:
    mov  edx, edi
    sub  edx, ebx
    pop  esi
    pop  edi
    ret

atoi:
    xor eax, eax
.atoi_l:
    movzx ecx, byte [esi]
    cmp   ecx, '0'
    jb    .atoi_d
    cmp   ecx, '9'
    ja    .atoi_d
    sub   ecx, '0'
    imul  eax, eax, 10
    add   eax, ecx
    inc   esi
    jmp   .atoi_l
.atoi_d:
    ret