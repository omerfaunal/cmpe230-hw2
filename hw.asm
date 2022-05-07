	jmp read_char
	base_b db 10h
	base_w dw 10h
	was_last_token_number db 0h
	curr_num dw 0h
	divisor dw 0h
	output_num db 4h dup 0h
	counter db 4h
read_char:	
	; Read the values and compare them with their ASCII values.
	; After comparing jump to the relavent segments.
	mov ah, 1h
	int 21h
	cmp al, 2bh ; Value is +
	je addition
	cmp al, 2ah ; Value is *
	je multiplication
	cmp al, 2fh ; Value is /
	je division
	cmp al, 5eh ; Value is ˆ
	je bitwise_xor
	cmp al, 26h ; Value is &
	je bitwise_and
	cmp al, 7ch ; Value is |
	je bitwise_or
	cmp al, 20h ; Value is Space
	je space
	cmp al, 0dh
	je print_result
	cmp al, 3ah 
	jb normalize_09 ; If value is below 3A ASCII which is threshold for numbers up to 9 jump to normalize_09
	ja normalize_AF ; Else jump to normalize_AF
normalize_09:
	; Subtract 30 from AL value and convert ASCII value of number to decimal integer value.
	sub al, 30h
	jmp new_digit
normalize_AF:
	; Subtract 37 from AL value and convert ASCII value of number to decimal integer value.
	; Converts HEX number A,B,C,D,E,F to their decimal values.
	sub al, 37h
	jmp new_digit
new_digit:
	mov was_last_token_number, 1h
	mov ah, 0h
	mov bx, ax
	mov ax, curr_num
	mul base_w
	add ax, bx
	mov curr_num, ax
	jmp read_char
space:
	cmp was_last_token_number, 0h
	je read_char
	push curr_num
	mov curr_num, 0h
	mov was_last_token_number, 0h
	jmp read_char
addition:
	; Take the values ​​in ax and dx. 
	; Add them, push the result to the stack and jump back to the character reading.
	pop ax
	pop dx
	add ax, dx
	push ax
	jmp read_char
multiplication:
	; Take the values ​​in ax and dx. 
	; Multiply them, push the result to the stack and jump back to the character reading.
	pop ax
	pop dx
	mul dx
	push ax
	jmp read_char
division:
	; Take the values ​​in ax and divisor. 
	; Update the value in dx to 0000.
	; Apply division, push the result to the stack and jump back to the character reading.
	pop divisor
	pop ax
	mov dx, 0h
	div divisor
	push ax
	jmp read_char
bitwise_xor:
	; Take the values ​​in ax and dx, apply the xor operator and jump back to the character reading.
	pop ax
	pop dx
	xor ax, dx
	push ax
	jmp read_char
bitwise_and:
	; Take the values ​​in ax and dx, apply the and operator and jump back to the character reading.
	pop ax
	pop dx
	and ax, dx
	jmp read_char
bitwise_or:
	; Take the values ​​in ax and dx, apply the or operator and jump back to the character reading.
	pop ax
	pop dx
	or ax, dx
	jmp read_char
print_result:
	mov ah, 2h
	mov dl, 0ah
	int 21h
	mov bx, offset output_num+3
	pop ax
divide_by_base:
	mov dx, 0h
	div base_w
	mov b[bx], dl
	dec bx
	dec counter
	cmp counter, 0h
	jne divide_by_base
	mov ah, 2h
	inc bx
convert_to_char:
	mov dl, b[bx]
	add dl, 30h
	cmp dl, 3ah
	jb print_char
	add dl, 7h
print_char:
	int 21h
	inc bx
	inc counter
	cmp counter, 4h
	jb convert_to_char
	mov ax, 4c00h
	int 21h
