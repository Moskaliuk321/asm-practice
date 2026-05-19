section .data
str_min db 0xA, "Min: ", 0
str_max db 0xA, "Max: ", 0
str_idx db " Index: ", 0
space db " ", 0
newline db 0xA

section .bss
array resd 50
input resb 12
output resb 12
n_val resd 1

section .text
global _start
_start:
; I/O: read n
mov eax, 3
mov ebx, 0
mov ecx, input
mov edx, 12
int 0x80

; parse: atoi
mov esi, input
xor eax, eax
xor ebx, ebx
.atoi_loop:
mov bl, [esi]
cmp bl, 0xA
je .atoi_done
sub bl, '0'
imul eax, 10
add eax, ebx
inc esi
jmp .atoi_loop
.atoi_done:
mov [n_val], eax

; memory: заповнення масиву
; loops: цикл генерації
mov ecx, [n_val]
xor edi, edi
.loop_gen:
cmp edi, ecx
jge .gen_done
; math: формула генерації array[i] = i * 4 + 3
mov eax, edi
imul eax, 4
add eax, 3
mov [array + edi*4], eax
inc edi
jmp .loop_gen
.gen_done:

; I/O: виведення масиву в один рядок
xor edi, edi
.loop_print_arr:
cmp edi, [n_val]
jge .print_arr_done
mov eax, [array + edi*4]
call print_number
mov eax, 4
mov ebx, 1
mov ecx, space
mov edx, 1
int 0x80
inc edi
jmp .loop_print_arr
.print_arr_done:

; logic: пошук min/max та їх індексів
mov eax, [array] ; eax = min_val
xor ebx, ebx     ; ebx = min_idx
mov edx, [array] ; edx = max_val
xor esi, esi     ; esi = max_idx
mov ecx, 1
.loop_find:
cmp ecx, [n_val]
jge .find_done
mov ebp, [array + ecx*4]
cmp ebp, eax
jge .chk_max
mov eax, ebp
mov ebx, ecx
.chk_max:
cmp ebp, edx
jle .next_item
mov edx, ebp
mov esi, ecx
.next_item:
inc ecx
jmp .loop_find
.find_done:

; Зберігання значень у стеку перед викликом системного виводу
push esi
push edx
push ebx
push eax

; I/O: друк "Min: "
mov eax, 4
mov ebx, 1
mov ecx, str_min
mov edx, 6
int 0x80

pop eax
call print_number

; I/O: друк " Index: "
mov eax, 4
mov ebx, 1
mov ecx, str_idx
mov edx, 8
int 0x80

pop eax
call print_number

; I/O: друк "Max: "
mov eax, 4
mov ebx, 1
mov ecx, str_max
mov edx, 6
int 0x80

pop eax
call print_number

; I/O: друк " Index: "
mov eax, 4
mov ebx, 1
mov ecx, str_idx
mov edx, 8
int 0x80

pop eax
call print_number

; I/O: переведення рядка
mov eax, 4
mov ebx, 1
mov ecx, newline
mov edx, 1
int 0x80

; exit
mov eax, 1
xor ebx, ebx
int 0x80

; memory: підпрограма itoa (число в рядок і друк)
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