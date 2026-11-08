; prog_fibonacci: Fibonacci numbers into M[20..]: each term is M[p-2] + M[p-1], with
; pointer arithmetic in A (ADD 0xFE as minus 2), until ADD carries (fib(14) = 377).

.equ p, 0
        IMF A, 0
        ST A, 0x20
        IMF A, 1
        ST A, 0x21
        IMF A, 0x22
        SST A, p
loop:   SLD A, p
        IMF B, 0xFE
        ADD                 ; A = p - 2
        LD B, A             ; B = M[p-2]
        INC
        LD A, A             ; A = M[p-1]
        ADD                 ; F = carry out
        JF done
        SWAP
        SLD A, p
        ST B, A
        INC
        SST A, p
        JMP loop
done:   HALT
