section .data
	prompt db "Enter an operation (from +, -, *, /, %): ", 10, 0
	prompt1 db "Enter number 1: ", 10, 0
	prompt2 db "Enter number 2: ", 10, 0
	buffer times 16 db 0

section .bss
	opr resb 1
	num1 resd 1
	num2 resd 1
	num3 resd 1

; Seems like I messed up
; I needed to create a _toAscii, and a _toInteger first
; I need to convert the num1 and num2 inputs to Integer using the _toInteger function
; For now I think i'll need a reverse function
; I've to convert num1 and num2 to integer
; and I'll also need to convert num3 to ascii later
; after that I can actually print something
; https://stackoverflow.com/a/12386915/12352926 has a good implementation of itoa
; https://www.geeksforgeeks.org/write-your-own-atoi/ a good implementation of atoi

section .text
	global _start
_start:
	call _initOpr
	call _initNums
	call _doOprs
	call _printAnswer

	mov rax, 60
	mov rdx, 0
	syscall

_printAnswer:
	mov rdi, [num3]
	mov rsi, buffer
	mov rdx, 10
	call itoa
	
	mov rax, buffer
	call _print	

_doOprs:
	mov rax, [num1]
	mov rbx, [num2]

	mov bl, [opr]
	cmp bl, 43
	je _add

	cmp bl, 45
	je _sub

	cmp bl, 42
	je _mul

	cmp bl, 47
	je _div

	cmp bl, 37
	je _mod

	mov dword [num3], eax
	
	ret

_add:
	add rax, rbx

	ret

_sub:
	sub rax, rbx

	ret	

_mul:
	mov rdx, 0
	mov eax, [num1]
	mov ebx, [num2]
	mul ebx

	ret
	
_div:
	mov rdx, 0
	mov eax, [num1]
	mov ebx, [num2]
	div ebx
	
	ret

_mod:
	call _div
	mov rax, rdx

	ret

_initOpr:
	mov rax, prompt
	call _print

	mov rax, 0
	mov rdi, 0
	mov rsi, opr
	mov rdx, 1
	syscall

	ret

_initNums:
	mov rax, prompt1
	call _print
	
	mov rbx, num1
	call _getNum
	mov rdi, rbx
	call atoi
	mov dword [num1], eax

	mov rax, prompt2
	call _print
	
	mov rbx, num2
	call _getNum
	mov rdi, rbx
	call atoi
	mov dword [num2], eax

	ret
	
_getNum:
	mov rax, 0
	mov rdi, 0
	mov rsi, rbx
	mov rdx, 4
	syscall

	ret

_print:
	push rax
	mov rbx, 0

_printLoop:
	inc rax
	inc rbx
	mov cl, [rax]
	cmp cl, 0
	jne _printLoop
	; This kind of loop is dangerous, as there is a risk of infinite loop,
	; if the first char itself is a NULL byte

	mov rax, 1
	mov rdi, 1
	pop rsi
	mov rdx, rbx
	syscall

	ret

itoa:
  cmp rdi, 0
  jge _itoa_pos
  neg rdi ; convert negative to positive
  mov byte [rsi], '-' store the first byte as negative
  mov rbx, 1
_itoa_pos:
  mov rbx, 0
_itoa_div:
  mov rdx, 0
  mov rax, rdi
  mov ecx, 10
  div ecx
  cmp rdx, 0
  je _itoa_zero
  add rdx, '0'
  mov [rsi + rbx], rdx
  inc rbx
  jmp _itoa_div
_itoa_zero:
  inc rbx
  mov byte [rsi + rbx], 0
  
  ret

atoi:
    ; Initialize result and sign
    xor rax, rax  ; res = 0
    mov rdx, 1    ; sign = 1
    xor rcx, rcx  ; i = 0

    ; Check for negative sign
    movzx rsi, byte [rdi]
    cmp rsi, '-'
    jne .loop_start
    mov rdx, -1
    inc rcx  ; Skip '-'

.loop_start:
    movzx rsi, byte [rdi+rcx]
    cmp rsi, '\0'
    je .end

    ; Check if character is a digit
    cmp rsi, '0'
    jl .end
    cmp rsi, '9'
    jg .end

    ; Convert digit to integer and update result
    sub rsi, '0'
    imul rax, 10
    add rax, rsi
    inc rcx

    ; Check for overflow (optional)
    ; ...

    jmp .loop_start

.end:
    imul rax, rdx  ; Apply sign
    ret
