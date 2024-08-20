section .data
	prompt db "Enter an operation (from +, -, *, /, %): ", 0
	prompt1 db "Enter number 1: ", 0
	prompt2 db "Enter number 2: ", 0
	answer db "The result of the calculation is: ", 0
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
; I'll add a printReverse function also, in order to print the reverse of a string
; serious bug for _itoa_pos and _atoi_neg, move their position to avoid running them by mistake
; was able to successfully test itoa and atoi functions somehow
; looks like there are some problems regarding _doOprs, I'll be sure to check them out later
; so, problems are with itoa and maybe doOprs, it's because itoa can't handle digits with 0, and for some reason after the ret call in _printLoop, it goes to _doOprs and does the job again

section .text
	global _start
_start:
	call _initOpr
	call _initNums
	call _doOprs

	mov dword [num3], eax

	call _printAnswer

	mov rax, 60
	mov rdx, 0
	syscall

_printAnswer:
	mov rdi, [num3]
	mov rsi, buffer
	mov rdx, 10
	call itoa
	
	mov rax, answer
	call _print

	mov rax, buffer
	call _print

	ret

_doOprs:
	mov rax, 0
	mov eax, [num1]
	mov ecx, [num2]

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

	;mov dword [num3], eax
	
	ret

_add:
	add eax, ecx

	ret

_sub:
	sub eax, ecx

	ret	

_mul:
	mov rdx, 0
	mov eax, [num1]
	mov ecx, [num2]
	mul ecx

	ret
	
_div:
	mov rdx, 0
	mov eax, [num1]
	mov ecx, [num2]
	div ecx
	
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
	mov rdx, 2
	syscall

	ret

_initNums:
	mov rax, prompt1
	call _print
	
	mov rbx, buffer
	call _getNum
	mov rdi, rbx
	call atoi
	mov dword [num1], eax

	mov rax, prompt2
	call _print
	
	mov rbx, buffer
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
	mov byte [rsi], '-' ;store the first byte as negative
	mov rbx, 1
	jmp _itoa_div
_itoa_pos:
	mov rbx, 0
_itoa_div:
	mov rdx, 0
	mov rax, rdi
	mov ecx, 10
	div ecx
	cmp rdx, 0 ;made a tragic mistake here
	je _itoa_zero
	add rdx, '0'
	mov [rsi + rbx], rdx
	inc rbx
	mov rdi, rax
	jmp _itoa_div
_itoa_zero:
	inc rbx
	mov byte [rsi + rbx], 0

	ret

atoi:
        mov rax, 0
	mov rcx, 0
        cmp byte [rdi], 45
        je _atoi_neg
        mov rbx, 0
        mov r8, 1
        jmp _atoi_loop
_atoi_neg:
        mov r8, -1
        mov rbx, 1
_atoi_loop:
        mov cl, byte [rdi + rbx]
        cmp cl, 48
        jl _atoi_zero
        sub cl, 48
        mov rdx, 0
        mov r9, 10
        mul r9
        add rax, rcx
        inc rbx
        jmp _atoi_loop
_atoi_zero:
        mul r8

        ret
