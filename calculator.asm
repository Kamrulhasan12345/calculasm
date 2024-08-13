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
	mov rax, [num3]

_toAscii:
	div 10
	add rdx, 48
	

_printRDX:
	mov 
	

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

	mov dword [num3], rax
	
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
	call _division
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

	mov rax, prompt2
	call _print
	
	mov rbx, num2
	call _getNum

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
