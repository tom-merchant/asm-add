; Tom Merchant 2019

;Target architecture: AMD64 Linux

SECTION .DATA
  maxlen: dq 21
  argerror: db "Invalid arguments", 10
  largerror: equ $-argerror
  newline: db 10

SECTION .bss
  ;num1: resq 1
  numstr: resb 22
  numstrlen: resq 1

SECTION .TEXT
global _start
_start:
  mov rdi, [rsp+16]
  call atoi
  ;mov [num1], rax
  push rax

  mov rdi, [rsp+32]
  call atoi
 
  ;mov rbx, [num1]
  pop rbx

  add rax, rbx

  mov rdi, rax
  mov rsi, numstr
  mov rdx, numstrlen
  call itoa

  mov rax, 1
  mov rdi, 1
  mov rsi, numstr
  mov rdx, numstrlen
  syscall

  mov rax, 1
  mov rdi, 1
  mov rsi, newline
  mov rdx, 1
  syscall
  
  mov rax, 60
  mov rdi, 0
  syscall

itoa:
  push rbp
  mov rbp, rsp
  
  push rbx

  xor rcx, rcx
  
  mov rbx, 10  
  mov rax, rdi

  cmp rdi, 0
  jge $+5
  neg rax
  
  mov r11, rdx

  pushdigits:
  test rax, rax
  jz enddiv
  xor rdx, rdx
  cqo
  idiv rbx
  add rdx, '0'
  push rdx
  inc rcx
  jmp pushdigits
  
  enddiv:

  cmp rdi, 0
  jge $+8
  mov al, '-'
  push rax
  inc rcx

  mov [r11], rcx

  digitstoaddr:
  test rcx, rcx
  jz enditoa
  pop rbx
  mov [rsi], bl
  dec rcx
  inc rsi
  jmp digitstoaddr
  enditoa:

  pop rbx
  mov rsp, rbp
  pop rbp
  ret

atoi:
  push rbp
  mov rbp, rsp

  xor rax, rax
  xor r11, r11
  stackloop:
  mov al, [rdi]
  test al, al
  jz strlenend
  push rax
  inc rdi
  inc r11
  jmp stackloop
  strlenend:
  mov rax, 1
  xor rsi, rsi
  mov rcx, 10
  cmp r11, [maxlen]
  jg printargerror

  conversionloop:
  test r11, r11
  je positivedone
  pop rdx
  cmp dl, '-'
  je negativedone
  sub dl, '0'
  push rax
  mul rdx
  add rsi, rax
  pop rax
  mul rcx
  dec r11
  jmp conversionloop
 
  negativedone:
  neg rsi
  positivedone:
  mov rax, rsi

  mov rsp, rbp
  pop rbp
  ret

printargerror:
  push rbp
  mov rbp, rsp
  
  mov rsi, argerror
  mov rax, 1
  mov rdx, largerror
  mov rdi, 1
  syscall
  
  mov rax, 60
  mov rdi, -1
  syscall
