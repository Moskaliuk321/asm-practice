section .data
    msg_first db "First index: ", 0
    msg_count db 0xA, "Count: ", 0
    msg_list  db 0xA, "Indices: ", 0
    msg_minus db "-1", 0
    space     db " ", 0
    newline   db 0xA

section .bss
    array       resd 100
    input       resb 12
    output      resb 12
    n_val       resd 1
    target      resd 1
    first_idx   resd 1
    total_found resd 1

section .text
    global _start

_start:
    ; I/O: read n
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 12
    int 0x80

    ; parse: atoi для n
    mov esi, input
    call atoi
    mov [n_val], eax

    ; memory: зчитування n елементів масиву
    xor edi, edi
.loop_read_arr:
    cmp edi, [n_val]
    jge .read_target

    push edi
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 12
    int 0x80
    
    mov esi, input
    call atoi
    pop edi
    
    mov [array + edi*4], eax
    inc edi
    jmp .loop_read_arr

.read_target:
    ; I/O: read target
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 12
    int 0x80

    ; parse: atoi для target
    mov esi, input
    call atoi
    mov [target], eax

    ; logic: ініціалізація змінних для пошуку
    mov dword [first_idx], -1
    mov dword [total_found], 0
    xor edi, edi ; поточний індекс циклу

    ; loops: лінійний пошук по масиву
.loop_search:
    cmp edi, [n_val]
    jge .search_done

    mov eax, [array + edi*4]
    cmp eax, [target]
    jne .next_item

    ; Знайдено збіг!
    inc dword [total_found]
    cmp dword [first_idx], -1
    jne .next_item
    mov [first_idx], edi ; фіксуємо перший індекс

.next_item:
    inc edi
    jmp .loop_search
.search_done:

    ; I/O: вивід першого індексу
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_first
    mov edx, 13
    int 0x80

    mov eax, [first_idx]
    cmp eax, -1
    je .print_minus1
    call print_number
    jmp .print_cnt

.print_minus1:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_minus
    mov edx, 2
    int 0x80

.print_cnt:
    ; I/O: вивід кількості входжень
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_count
    mov edx, 8
    int 0x80

    mov eax, [total_found]
    call print_number

    ; I/O: вивід списку всіх індексів
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_list
    mov edx, 10
    int 0x80

    cmp dword [total_found], 0
    je .exit_prog

    ; loops: повторний цикл для виведення індексів
    xor edi, edi
.loop_print_idx:
    cmp edi, [n_val]
    jge .exit_prog

    mov eax, [array + edi*4]
    cmp eax, [target]
    jne .next_idx

    ; Друк індексу
    mov eax, edi
    call print_number

    ; Друк пробілу
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

.next_idx:
    inc edi
    jmp .loop_print_idx

.exit_prog:
    ; I/O: новий рядок
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; logic: sys_exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

; math: підпрограма atoi (рядок в ESI -> число в EAX)
atoi:
    xor eax, eax
    xor ebx, ebx
.atoi_loop:
    mov bl, [esi]
    cmp bl, 0xA
    je .atoi_end
    cmp bl, 0
    je .atoi_end
    cmp bl, ' '
    je .atoi_end
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .atoi_loop
.atoi_end:
    ret

; memory: підпрограма itoa (число в EAX -> друк на екран)
print_number:
    push ecx
    push edx
    push ebx
    push edi
    mov edi, output
    add edi, 11
    mov byte [edi], 0
    mov ebx, 10
    xor ecx, ecx
.itoa_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    test eax, eax
    jnz .itoa_loop
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, edi
    int 0x80
    pop edi
    pop ebx
    pop edx
    pop ecx
    ret