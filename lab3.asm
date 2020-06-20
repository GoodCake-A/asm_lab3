.model small
.code
.stack 128   
.data
 num_of_str equ 5
 num_of_col equ 6
 max_length equ 200
 string_i db max_length+3 dup(?)
 matrix dw 30 dup(?)
 greeting_str db "Enter a matrix 5x6 to sort it's strings:",10,13,'$'
 sorted_str db 10,13,"Sorted matrix:",10,13,'$' 
 too_big_str db 10,13,"ERROR: one of numbers is too big",'$'
start:
jmp j_over  far
selection_sort macro dw_string size 
    local cycle1
    local cycle2
    local greater_replacing
    local equal_or_lower 
    push ax
    push di 
    push cx
    push bp
    mov di,dw_string;di on the str begining
    mov cx,size
    cycle1: ;bp- max 
        mov bp,di;max on the first elem
        push cx
        push di
        cycle2:
            mov ax,ds:[bp]
            cmp ax,ds:[di]
            jg greater_replacing
            jmp equal_or_lower
            greater_replacing:
                mov bp,di
            equal_or_lower:
                inc di
                inc di
        loop cycle2 
        pop di
        pop cx
        mov ax,ds[di]
        mov bx,ds:[bp]
        mov ds:[di],bx
        mov ds:[bp],ax
        inc di
        inc di
    loop cycle1
    pop bp
    pop cx
    pop di
    pop ax
endm

incorrect_num macro 
    push ax
    push dx
    lea dx,too_big_str
    mov ah,9
    int 21h
    pop dx
    pop ax
    jmp terminate
endm

print_c macro ascii
    push ax
    push dx
    mov dl,ascii
    mov ah,02h
    int 21h
    pop dx
    pop ax    
endm
    

dw_input proc near   ;;beginning in di    ;;ret. dw in ax
    push cx   
    push bx
    push dx  
    mov bx,10
    xor ax,ax
    xor dx,dx
    mov dl,ds:[di]
    cmp dl,'-'
    je minus
    
    mov cx,6  
    cycle_plus:
        mov dl,ds:[di]
        cmp dl,' '
        je input_end_plus
        cmp dl,'$'
        je input_end_plus
        cmp dl,13
        je input_end_plus   
        sub dl,48
        push dx
        imul bx;;
        cmp dx,0 
        jne error
        pop dx
        add ax,dx
        inc di
    loop cycle_plus
    jmp error
    input_end_plus:
    cmp ax,32767
    ja error    
    jmp input_end
    minus:
    mov cx,6
    cycle_minus:
        inc di
        mov dl,ds:[di]
        cmp dl,' '
        je input_end_minus
        cmp dl,'$'
        je input_end_minus
        cmp dl,13
        je input_end_minus   
        sub dl,48
        push dx
        imul bx;;
        cmp dx,0FFFFh 
        jne error0
        jmp over2
        error0:
        cmp dx,0
        jne error
        over2:
        pop dx
        sub ax,dx
    loop cycle_minus
    jmp error
    input_end_minus:
    neg ax
    cmp ax,0
    jl error
    neg ax
    jmp over
    error:
    incorrect_num
    mov ax,0
    over:    
    input_end:
    pop dx
    pop bx
    pop cx
    ret     
dw_input endp

dw_output proc near ;dw in dx
    pusha
    xor di,di
    mov bx,10000
    cmp dx,0
    jl minus_case
    jmp over_0
    minus_case:
        print_c '-'
        neg dx
    over_0:
    mov cx,5
    first_0:
        push cx
        mov ax,dx
        xor dx,dx
        div bx
        mov cx,di
        add ax,cx
        cmp ax,0
        jne !0_case
        jmp over_1
        !0_case:
            sub ax,cx
            inc di
            add ax,'0'
            print_c al
        over_1:
        push ax
        push dx
        xor dx,dx
        mov ax,bx
        mov cx,10
        div cx
        mov bx,ax
        pop dx
        pop ax    
        pop cx
    loop first_0
    cmp di,0
    je zero_num
    jmp over_2
    zero_num:
    print_c '0'
    over_2:
    popa
    ret
dw_output endp    
 
matrix_string_input proc near ;beginning in di;amount of numb. in cx
    pusha
    numb_cycle:     ; mem. beg. in bx
        call dw_input
        push di
        mov di,bx
        mov ds:[di],ax
        pop di
        inc di
        inc bx
        inc bx    
    loop numb_cycle
    popa
    ret
matrix_string_input endp   

matrix_string_output proc near   ;amount of numb. in cx
    pusha
    mov di,bx                    ; mem. beg. in bx
    numb_cycle2:
        mov dx,ds:[di]
        call dw_output
        print_c ' '
        inc di
        inc di    
    loop numb_cycle2
    print_c 10
    print_c 13
    popa
    ret
matrix_string_output endp

j_over:
    mov ax,@data
    mov ds,ax
    lea dx,greeting_str
    mov ah,09h
    int 21h
    lea bx,matrix
    lea dx,string_i
    mov cx,num_of_str
    input_cycle:
        push cx
        push bx
        mov di,dx ;di to the begining of the string
        mov [di],max_length ;max_length in the first byte
        mov ah,0Ah  ;input
        int 21h
        inc di
        inc di
        mov cx,num_of_col 
        call matrix_string_input
        print_c 10
        print_c 13
        selection_sort bx num_of_col
        pop bx
        add bx,num_of_col
        add bx,num_of_col
        pop cx
    loop input_cycle
    print_c 10
    print_c 13
    lea dx,sorted_str
    mov ah,09h
    int 21h
    lea bx,matrix
    lea dx,string_i
    mov cx,num_of_str
    output_cycle:
        push cx
        mov cx,num_of_col
        call matrix_string_output
        add bx,num_of_col
        add bx,num_of_col
        pop cx
    loop output_cycle
    terminate:
end start far

