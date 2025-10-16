
includelib kernel32.lib

Extern GetStdHandle: Proc
Extern WriteConsoleA: Proc
Extern ReadConsoleA: Proc

.data
    msg1 db "Enter a list of 7 numbers: ", 13, 10, 0
    msg1_end:
    len_msg1 equ msg1_end - msg1
    bytesWritten dq 0
    bytesRead dq 0
    Read_buffer db 64 dup(0)
    buffer_size dq 64
    vowels db "AEIOUaeiou"
    vowel_count db 0
    Result_val db 10 dup(0)
    Print_array db 100 dup(0)
    msg2 db "The max element value of the array is: ", 13, 10, 0
    msg2_end:
    len_msg2 equ msg2_end - msg2
    my_array db 12, 45, 10, 28, 10, 92, 100
    num_elements dq 7
    Read_nums dq 10 dup(0)


.code

PrintString MACRO strLabel, strLength
    sub rsp, 40                                 
    mov rcx, -11                 
    call GetStdHandle
    mov rcx, rax                 
    lea rdx, strLabel             
    mov r8, strLength               
    lea r9, bytesWritten         
    xor rax, rax
    call WriteConsoleA
    add rsp, 40
 endm

 ReadString MACRO strLabel, strLength
        ; Get handle
        mov rcx, -10
        call GetStdHandle
        ; Write string
        mov rcx, rax
        lea rdx, strLabel
        mov r8, strLength
        lea r9, bytesRead
        xor rax, rax
        call ReadConsoleA
ENDM

main proc
    sub rsp, 40
    PrintString msg1, len_msg1
    ReadString Read_buffer, buffer_size
    lea rsi, Read_buffer
    lea rdi, Read_nums
    call StoreNum
    ;call Find_vowel
    ;call Find_max
    call Sort_array
    PrintString msg2, len_msg2
    ;movzx rax,  vowel_count
    mov rax, rbx
    call Print_num

    add rsp, 40
    xor rax, rax
ret
main endp

Sort_array Proc
    
    next_roll:
        mov rcx, num_elements
        lea rsi, Read_nums
        xor rax, rax
        xor rbx, rbx
        xor rdx, rdx
       
       next_num:
        cmp rcx, 1
        je check_end
        lodsb
        mov rbx, rax
        lodsb
        cmp rax, rbx
        jg swap
        sub rsi, 1
        dec rcx
        jmp next_num
        swap:
            sub rsi, 1
            mov [rsi], bl
            sub rsi, 1
            mov [rsi], al
            add rsi, 1
            dec rcx
            inc rdx
            jmp next_num
        check_end:
        cmp rdx, 0 ;?
        je exit
        jmp next_roll
exit:
ret
Sort_array ENDP



StoreNum Proc
    next_char:
        mov al, [rsi]
        cmp al, 0dh
        je finish ; End of string
        cmp al, ' '
        je store_number
        ; Convert ASCII to digit
        sub al, '0'
        movzx rcx, al
                imul rbx, rbx, 10
        add rbx, rcx
        inc rsi
        jmp next_char
    store_number:
        inc num_elements ;?
        mov [rdi], rbx ; Store number
        add rdi, 1 ; Next byte
        xor rbx, rbx ; Reset accumulator
        inc rsi
        jmp next_char
    finish:
        ; Store last number (if not followed by space)
        inc num_elements ;?
        mov [rdi], rbx
    ret
StoreNum ENDP

Print_num Proc
    lea rdi, Result_val +4 ;print 4 bytes
    convert_loop:
        xor dx, dx
        mov bx, 10
        div bx
        add dl, '0'
        dec rdi
        mov [rdi], dl
        cmp ax, 0
        jne convert_loop
        PrintString Result_val, 4
    RET
Print_num ENDP

Convrt_ascii Proc
        lea r9, Read_nums
        mov rcx, num_elements
        lea rdi, Print_array
        insert_next:
        mov rax, [r9]
        lea rsi, Result_val + 1

        xor r8, r8
        convert_loop:
            xor dx, dx
            mov bx, 10
            div bx

            add dl, '0'
            dec rsi
            mov [rsi], dl
            inc r8
            cmp ax, 0
            jne convert_loop
        store_byte:
            lodsb
            stosb
            dec r8
            cmp r8, 0
            jne store_byte
            mov al, ' '
            stosb
            dec rcx
            add r9, 8
            cmp rcx, 0
            jne insert_next
            mov al, 0dh
            stosb
            mov al, 0ah
            stosb

    RET
Convrt_ascii ENDP

end