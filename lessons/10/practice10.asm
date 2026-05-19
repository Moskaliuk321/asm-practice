section .bss
    input    resb 12
    line_buf resb 64

section .text
    global _start

_start:
    ; === I/O: читаємо число ===
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 12
    int 0x80

    ; === parse: atoi ===
    mov esi, input
    call atoi
    mov ebx, eax

    ; === logic: двійковий вивід (32 біти, групи по 4) ===
    mov ecx, 32
    mov edi, line_buf
.bin_loop:
    mov eax, ecx
    and eax, 3
    test eax, eax
    jnz .no_space
    cmp ecx, 32
    je  .no_space
    mov byte [edi], ' '
    inc edi
.no_space:
    push ecx
    dec ecx
    mov eax, ebx
    shr eax, cl
    and eax, 1
    add al, '0'
    mov [edi], al
    inc edi
    pop ecx
    loop .bin_loop
    mov byte [edi], 10
    inc edi
    mov eax, 4
    mov ebx, 1
    mov ecx, line_buf
    mov edx, edi
    sub edx, ecx
    int 0x80

    ; === math: popcount ===
    mov esi, input
    call atoi
    mov ebx, eax
    mov eax, ebx
    xor ecx, ecx
.pop_loop:
    test eax, eax
    jz   .pop_done
    mov  edx, eax
    and  edx, 1
    add  ecx, edx
    shr  eax, 1
    jmp  .pop_loop
.pop_done:
    ; === I/O: друкуємо "popcount: N" ===
    mov edi, line_buf
    mov dword [edi], 'popc'
    add edi, 4
    mov dword [edi], 'ount'
    add edi, 4
    mov word  [edi], ': '
    add edi, 2
    mov eax, ecx
    mov ebx, edi
    call itoa
    add edi, edx
    mov byte [edi], 10
    inc edi
    mov eax, 4
    mov ebx, 1
    mov ecx, line_buf
    mov edx, edi
    sub edx, ecx
    int 0x80

    ; === logic: set bits 2,5 / clear bit 3 ===
    mov esi, input
    call atoi
    mov ebx, eax
    or  ebx, (1<<2)
    or  ebx, (1<<5)
    and ebx, ~(1<<3)

    ; === I/O: друкуємо "result: N" ===
    mov edi, line_buf
    mov dword [edi], 'resu'
    add edi, 4
    mov dword [edi], 'lt: '
    add edi, 4
    mov eax, ebx
    mov ebx, edi
    call itoa
    add edi, edx
    mov byte [edi], 10
    inc edi
    mov eax, 4
    mov ebx, 1
    mov ecx, line_buf
    mov edx, edi
    sub edx, ecx
    int 0x80

    ; === sys_exit ===
    mov eax, 1
    xor ebx, ebx
    int 0x80

; itoa: eax=число, ebx=буфер -> edx=довжина
itoa:
    push edi
    push esi
    push ecx
    mov  edi, ebx
    mov  esi, ebx
    mov  ecx, 10
    test eax, eax
    jnz  .itoa_l
    mov  byte [edi], '0'
    inc  edi
    jmp  .itoa_done
.itoa_l:
    xor  edx, edx
    div  ecx
    add  dl, '0'
    mov  [edi], dl
    inc  edi
    test eax, eax
    jnz  .itoa_l
.itoa_rev:
    mov  ecx, edi
    dec  ecx
.itoa_rev_l:
    cmp  esi, ecx
    jge  .itoa_done
    mov  al, [esi]
    mov  ah, [ecx]
    mov  [esi], ah
    mov  [ecx], al
    inc  esi
    dec  ecx
    jmp  .itoa_rev_l
.itoa_done:
    mov  edx, edi
    sub  edx, ebx
    pop  ecx
    pop  esi
    pop  edi
    ret

; atoi: esi=рядок -> eax
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