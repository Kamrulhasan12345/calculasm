section .data
	num dd -12345
	buf times 16 db 0

section .text
	global _start
_start:
	mov rdi, [num]
	mov rsi, buf
	call itoa
	
	mov rax, buf
	call _print

	mov rax, 60
	mov rdi, 0
	syscall
	
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
  mov rdi, rax
  jmp _itoa_div
_itoa_zero:
  inc rbx
  mov byte [rsi + rbx], 0

  ret
