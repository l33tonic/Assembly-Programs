section .bss
    buffer: resb 14
    numbers: resb 5
    results: resw 8

section .text
global _start


_start:
    readdata:
        lea rsi, [rel buffer]
        mov eax, 0
        mov edi, 0
        mov edx, 14
        syscall
        mov ecx, 0
        readloop:
            tenscheck:
                mov al, [rsi+rcx]
                cmp al, '0'
                jb throwerr
                cmp al, '9'
                ja throwerr
                add ecx, 1

            onescheck:
                mov al, [rsi+rcx]
                cmp al, '0'
                jb throwerr
                cmp al, '9'
                ja throwerr
                add ecx, 1

            commacheck:
                cmp ecx, 14
                je convert
                mov al, [rsi+rcx]
                cmp al, ','
                jne throwerr
                add ecx, 1
                jmp tenscheck

        throwerr:
            mov edi, 1
            jmp exit

    convert:
        lea rdi, [rel numbers]
        mov ecx, 0
        mov ebx, 0
        mov r8d, 0

        convertloop:
            firstdigit:
                mov al, [rsi+rcx]
                sub al, '0'
                add al, al
                mov ah, al
                add al, al
                add al, al
                add al, ah
                add ecx, 1
                jmp seconddigit

            seconddigit:
                mov bl, [rsi+rcx]
                sub bl, '0'
                add al, bl
                add ecx, 2
                mov byte [rdi+r8], al
                add r8d, 1
                cmp ecx, 13
                jb firstdigit

    sort:
        mov eax, 0
        mov ebx, 0
        mov r8d, 0
        mov r9d, 4
        sortloop:
            mov al, [rdi+r8]
            mov bl, [rdi+r8+1]
            cmp al, bl
            jb skipswap
            mov byte [rdi+r8], bl
            mov byte [rdi+r8+1], al
            skipswap:
                add r8d, 1
                cmp r8d, r9d
                jb sortloop
            sub r9d, 1
            mov r8d, 0
            jnz sortloop

    lea rsi, [rel results]
    sum:
        mov ecx, 0
        mov eax, 0
        sumloop:
            movzx bx, byte [rdi+rcx]
            add ax, bx
            add ecx, 1
            cmp ecx, 5
            jb sumloop
        mov word [rsi], ax

    min:
        movzx bx, byte [rdi]
        mov word [rsi+2], bx

    max:
        movzx bx, byte [rdi+4]
        mov word [rsi+4], bx

    average:
        mov edx, 0
        mov ecx, 5
        div ecx
        mov word [rsi+6], ax

    remainder:
        mov word [rsi+8], dx

    range:
        mov al, [rdi]
        mov bl, [rdi+4]
        sub bl, al
        mov word [rsi+10], bx

    sumbytes:
        movzx ax, byte [rsi]
        movzx bx, byte [rsi+1]
        mov word [rsi+12], ax
        mov word [rsi+14], bx

    output:
        mov r8d, 0
        outputloop:
            cmp r8d, 5
            jb outputnumber

            lea rdi, [rel results]
            mov r9d, r8d
            sub r9d, 5
            add r9d, r9d
            movzx eax, word [rdi+r9]
            jmp outputconvert

        outputnumber:
            lea rdi, [rel numbers]
            movzx eax, byte [rdi+r8]

        outputconvert:
            lea rsi, [rel buffer]
            mov r9d, 13
            mov byte [rsi+r9], 10
            cmp r8d, 4
            jb outputcomma
            cmp r8d, 12
            je outputsetup
            sub r9d, 1
            mov byte [rsi+r9], 10
            jmp outputsetup

        outputcomma:
            mov byte [rsi+r9], ','

        outputsetup:
            mov ebx, 10

            outputdigit:
                mov edx, 0
                div ebx
                sub r9d, 1
                add dl, '0'
                mov byte [rsi+r9], dl
                cmp eax, 0
                jne outputdigit

            mov edx, 14
            sub edx, r9d
            add rsi, r9
            mov eax, 1
            mov edi, 1
            syscall
            add r8d, 1
            cmp r8d, 13
            jb outputloop

        mov edi, 0

    exit:
        mov eax, 60
        syscall

