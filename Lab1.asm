
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
    call Find_max
    PrintString msg2, len_msg2
    ;movzx rax,  vowel_count
    mov rax, rbx
    call Print_num

    add rsp, 40
    xor rax, rax
ret
main endp

Find_max Proc
    mov rcx, num_elements
    lea rsi, Read_nums ; mov the address of the array into rsi
    xor rax, rax ;?
    xor rbx, rbx ;?
    lodsb ;? mov al, [rsi] = 12
    mov rbx, rax ;?  rbx = 12
    check_max:
        cmp rcx, 1
        je exit
        lodsb ;?
        cmp rbx, rax
        jl new_max
        dec rcx
        jmp check_max
    new_max:
        mov rbx, rax
        dec rcx
        jmp check_max
    exit:
    ret
Find_max ENDP

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
end