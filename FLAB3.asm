section .data
    prompt_status   db "Enter Enrollment Status: ", 0
    prompt_id       db "Enter Student #: ", 0
    prompt_name     db "Enter Name: ", 0
    prompt_phone    db "Enter Phone: ", 0
    prompt_zip      db "Enter Zip Code: ", 0
    prompt_college  db "Enter College: ", 0
    prompt_program  db "Enter Program: ", 0
    prompt_year     db "Enter Year Level: ", 0
    prompt_term     db "Enter Term: ", 0
    prompt_sy       db "Enter School Year (SY): ", 0
    prompt_address  db "Enter Address: ", 0
    
    prompt_tuition  db "Enter Tuition Fee Amount: ", 0
    prompt_misc     db "Enter Miscellaneous Fee Amount: ", 0
    prompt_lab      db "Enter Lab Fees Amount: ", 0
    
    hdr_info        db 10, "===================================================", 10, \
                           "               REGISTRATION SUMMARY                ", 10, \
                           "===================================================", 10, 0
    lbl_status      db "Enrollment Status: ", 0
    lbl_id          db "Student #        : ", 0
    lbl_name        db "Name             : ", 0
    lbl_phone       db "Phone            : ", 0
    lbl_zip         db "Zip Code         : ", 0
    lbl_college     db "College          : ", 0
    lbl_program     db "Program          : ", 0
    lbl_year        db "Year Level       : ", 0
    lbl_term        db "Term             : ", 0
    lbl_sy          db "School Year (SY) : ", 0
    lbl_address     db "Address          : ", 0
    lbl_section     db "Class Section    : TN24", 10, 0
    
    hdr_courses     db 10, "Enrolled Courses:", 10, \
                           "  - CCS0021   INFORMATION MANAGEMENT (LEC)", 10, \
                           "  - CCS0021L  INFORMATION MANAGEMENT (LAB)", 10, \
                           "  - CS0001    DISCRETE STRUCTURES 1", 10, \
                           "  - CS0003    COMPUTER SYSTEMS & ARCHITECTURE", 10, \
                           "  - CS0003L   COMPUTER SYSTEMS & ARCHITECTURE (LAB)", 10, \
                           "  - CS0070    OBJECT ORIENTED PROGRAMMING", 10, \
                           "  - CS0070L   OBJECT ORIENTED PROGRAMMING-LAB", 10, \
                           "  - GED0021   SPECIALIZED ENGLISH PROGRAM 2", 10, \
                           "  - GED0070   LINEAR ALGEBRA", 10, \
                           "  - GED0081   COLLEGE PHYSICS 1 LECTURE", 10, \
                           "  - GED0081L  COLLEGE PHYSICS 1 LABORATORY", 10, \
                           "TOTAL UNITS: 21", 10, 0

    hdr_billing     db 10, "===================================================", 10, \
                           "               FINANCIAL ASSESSMENT                ", 10, \
                           "===================================================", 10, 0
    lbl_total       db "TOTAL ASSESSMENT VALUE: Php ", 0
    newline         db 10, 0

section .bss
    buffer_status   resb 32
    buffer_id       resb 32
    buffer_name     resb 64
    buffer_phone    resb 32
    buffer_zip      resb 16
    buffer_college  resb 64
    buffer_program  resb 32
    buffer_year     resb 16
    buffer_term     resb 32
    buffer_sy       resb 32
    buffer_address  resb 128
    
    buffer_money    resb 32
    running_total   resd 1
    string_out      resb 32

section .text
    global _start

%macro OUTPUT_TEXT 1
    mov ecx, %1
    xor edx, edx
%%count_bytes:
    cmp byte [ecx + edx], 0
    je %%write_syscall
    inc edx
    jmp %%count_bytes
%%write_syscall:
    mov eax, 4          
    mov ebx, 1          
    int 0x80
%endmacro

%macro INPUT_TEXT 2
    mov eax, 3          
    mov ebx, 0          
    mov ecx, %1
    mov edx, %2
    int 0x80
    
    xor ecx, ecx
%%clean_newline:
    cmp ecx, eax
    jge %%exit_macro
    mov edx, %1
    cmp byte [edx + ecx], 10
    jne %%inc_pointer
    mov byte [edx + ecx], 0
%%inc_pointer:
    inc ecx
    jmp %%clean_newline
%%exit_macro:
%endmacro

%macro DISPATCH_PROMPT 3
    OUTPUT_TEXT %1
    INPUT_TEXT %2, %3
%endmacro

_start:
    DISPATCH_PROMPT prompt_status, buffer_status, 32
    DISPATCH_PROMPT prompt_id, buffer_id, 32
    DISPATCH_PROMPT prompt_name, buffer_name, 64
    DISPATCH_PROMPT prompt_phone, buffer_phone, 32
    DISPATCH_PROMPT prompt_zip, buffer_zip, 16
    DISPATCH_PROMPT prompt_college, buffer_college, 64
    DISPATCH_PROMPT prompt_program, buffer_program, 32
    DISPATCH_PROMPT prompt_year, buffer_year, 16
    DISPATCH_PROMPT prompt_term, buffer_term, 32
    DISPATCH_PROMPT prompt_sy, buffer_sy, 32
    DISPATCH_PROMPT prompt_address, buffer_address, 128

    OUTPUT_TEXT hdr_info
    OUTPUT_TEXT lbl_status
    OUTPUT_TEXT buffer_status
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_id
    OUTPUT_TEXT buffer_id
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_name
    OUTPUT_TEXT buffer_name
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_phone
    OUTPUT_TEXT buffer_phone
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_zip
    OUTPUT_TEXT buffer_zip
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_college
    OUTPUT_TEXT buffer_college
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_program
    OUTPUT_TEXT buffer_program
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_year
    OUTPUT_TEXT buffer_year
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_term
    OUTPUT_TEXT buffer_term
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_sy
    OUTPUT_TEXT buffer_sy
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_address
    OUTPUT_TEXT buffer_address
    OUTPUT_TEXT newline
    
    OUTPUT_TEXT lbl_section
    OUTPUT_TEXT hdr_courses
    OUTPUT_TEXT newline

    OUTPUT_TEXT hdr_billing
    mov dword [running_total], 0

    DISPATCH_PROMPT prompt_tuition, buffer_money, 32
    call procedure_ascii_to_int
    add [running_total], eax

    DISPATCH_PROMPT prompt_misc, buffer_money, 32
    call procedure_ascii_to_int
    add [running_total], eax

    DISPATCH_PROMPT prompt_lab, buffer_money, 32
    call procedure_ascii_to_int
    add [running_total], eax

    OUTPUT_TEXT newline
    OUTPUT_TEXT lbl_total
    
    mov eax, [running_total]
    call procedure_int_to_ascii
    OUTPUT_TEXT string_out
    OUTPUT_TEXT newline
    OUTPUT_TEXT newline

    mov eax, 1          
    mov ebx, 0
    int 0x80

procedure_ascii_to_int:
    xor eax, eax
    xor ecx, ecx
    mov esi, buffer_money
.read_character:
    movzx edx, byte [esi + ecx]
    cmp dl, 0
    je .execution_finished
    cmp dl, 10
    je .execution_finished
    
    cmp dl, '0'
    jl .skip_character
    cmp dl, '9'
    jg .skip_character
    
    sub dl, '0'
    imul eax, 10
    add eax, edx
.skip_character:
    inc ecx
    jmp .read_character
.execution_finished:
    ret

procedure_int_to_ascii:
    mov ebx, 10
    mov edi, string_out + 31
    mov byte [edi], 0
.division_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .division_loop
    
    mov esi, edi
    mov edi, string_out
.string_alignment_copy:
    lodsb
    stosb
    test al, al
    jnz .string_alignment_copy
    ret
