  section .data
    num db "-12345", 10, 0
    

  section .text
    global _start
_start:
    mov rdi, num
    call atoi
    
    mov rax, rdi
    call _print

    mov rax, 60
    mov rdi, 0
    syscall

_print:
        push rax
        mov rbx, 0
	call _printLoop

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

atoi:
	mov rax, 0
	cmp byte [rdi], 45
	je _atoi_neg
	mov rbx, 0
	mov r8, 1
	jmp _atoi_loop
_atoi_neg:
	mov r8, -1
	mov rbx, 1
_atoi_loop:
	mov sil, byte [rdi + rbx]
	cmp sil, 48
	jl _atoi_zero
	sub rsi, 48
	mov rdx, 0
	mov r9, 10
	mul r9
	add rax, rsi
	inc rbx
	jmp _atoi_loop
_atoi_zero:
	mul r8
	
	ret
	
