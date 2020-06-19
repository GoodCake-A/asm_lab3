.model small
.code
.stack 128   
.data
 max_length equ 200
 string_i db max_length+3 dup(?)
 sorted_str dw "6514632168484689",'$'
 matrix dw 30 dup(?)
 too_big_str db " the number is too big",'$'
start:
jmp j_through  far
buble_sort macro dw_string size 
    local cycle1
    local cycle2
    local greater_replacing
    local equal_or_lower 
    push ax
    push di 
    push cx
    lea di,sorted_str;di on the str begining
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
    mov cx,7
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
        jmp through2
        error0:
        cmp dx,0
        jne error
        through2:
        pop dx
        sub ax,dx
    loop cycle_minus
    jmp error
    input_end_minus:
    neg ax
    cmp ax,0
    jl error
    jmp through
    error:
    incorrect_num
    mov ax,0
    through:    
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
    jmp through_0
    minus_case:
        print_c '-'
        neg dx
    through_0:
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
        jmp through_1
        !0_case:
            sub ax,cx
            inc di
            add ax,'0'
            print_c al
        through_1:
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
    loop numb_cycle
    popa
    ret
matrix_string_input endp   

j_through:
    mov ax,@data
    mov ds,ax
    lea dx,string_i
    mov di,dx ;di to the begining of the string
    mov [di],max_length ;max_length in the first byte
    mov ah,0Ah  ;input
    int 21h
    inc di
    inc di
    call dw_input
    print_c ' '
    mov dx,ax
    call dw_output
    add ax,1616
    ;lea dx,sorted_str
    ;mov ah,9
    ;int 21h
    terminate:
end start

