sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
   
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
     

    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
   
     
    sys_exit     equ     60
   
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3
;---------------------------------------------------------
GetStrlen:
   push    rbx
   push    rcx
   push    rax  

   xor     rcx, rcx
   not     rcx
   xor     rax, rax
   cld
         repne   scasb
   not     rcx
   lea     rdx, [rcx -1]  ; length in rdx

   pop     rax
   pop     rcx
   pop     rbx
   ret
;-----------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret
;-----------------------
putc:

   push   rcx
   push   rdx
   push   rsi
   push   rdi
   push   r11

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
printString:
    push    rax
    push    rcx
    push    rsi
    push    rdx
    push    rdi

    mov     rdi, rsi
    call    GetStrlen
    mov     rax, sys_write  
    mov     rdi, stdout
    syscall
   
    pop     rdi
    pop     rdx
    pop     rsi
    pop     rcx
    pop     rax
    ret
;-------------------------------------------
getString:
    push rax
    push rsp
    push rdi
    push rsi
    push rdx
   
    mov rax, 0      
    mov rdi, 0      
    mov rsi, input  
    mov rdx, 101    ; maximum number of bytes to read
    syscall       
   
   
    pop rdx
    pop rsi
    pop rdi
    pop rsp
    pop rax
    ret
;-------------------------------------------

section .data
    prompt db 'asfsa', 0
    no db 'NO', 0
    yes db 'YES', 0
    newline db 10 ; define newline character as byte 10
    char db 'A'
section .bss
    input resb 101
    temp resb 100

section .text
    global _start

_start:
    ; get input
    call getString
    ;allocate the begginig of input
    mov r8, input
    ;allocate the end of input
    mov rdi, input
    call GetStrlen
    mov r9, input
    add r9, rdx
    dec r9

   
    while:
        cmp r8, r9
        jge endWhile
        mov r10b, byte [r8]
        mov r11b, byte [r9]
        checkSpace1:
        cmp r10b, ' '
        jne checkspace2
        inc r8
        jmp while
        checkspace2:
        cmp r11b, ' '
        jne checkNewLine
        dec r9
        jmp while
        checkNewLine:
        cmp r11b, 10
        jne continue
        dec r9
        jmp while
        continue:
        inc r8
        dec r9
        cmp r10b, r11b
        je while
        jmp printNo
       

    endWhile:
    mov rsi, yes
    call printString
    ;print newline character
    mov eax, 4 
    mov ebx, 1
    mov ecx, newline ;address of newline character
    mov edx, 1 ;#bytes to write
    int 0x80 
    jmp Exit
   
printNo:
    mov rsi, no
    call printString
    ; print newline character
    mov eax, 4 
    mov ebx, 1 
    mov ecx, newline ;address of newline character
    mov edx, 1 ;#bytes to write
    int 0x80  
    jmp Exit
   
Exit:
    ; Exit program
    mov rax, 1
    xor rbx, rbx
    int 0x80