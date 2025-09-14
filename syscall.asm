.option pic
.option norvc
.section .text
.global _syscall
_syscall:
    ecall
    ret

