; sweep_ops_high_b: all 16 ALU ops and the 6 compares for every A from 00 to FF, with
; B = ~(A XOR (A << 4)): B high nibble driven by A low nibble, covering large
; divisors, MUL overflow, and B = ~A pairs.

.equ va, 0
.equ vb, 1
        IMF A, 0
        SST A, va
        IMF A, 0xFF
        SST A, vb
        CLF
loop:
        SLD A, va
        SLD B, vb
        INVA
        SLD A, va
        SLD B, vb
        INVB
        SLD A, va
        SLD B, vb
        ADD
        SLD A, va
        SLD B, vb
        SUB
        SLD A, va
        SLD B, vb
        MUL
        SLD A, va
        SLD B, vb
        DIV
        SLD A, va
        SLD B, vb
        SWAP
        SLD A, va
        SLD B, vb
        INC
        SLD A, va
        SLD B, vb
        AND
        SLD A, va
        SLD B, vb
        NAND
        SLD A, va
        SLD B, vb
        OR
        SLD A, va
        SLD B, vb
        NOR
        SLD A, va
        SLD B, vb
        XOR
        SLD A, va
        SLD B, vb
        XNOR
        SLD A, va
        SLD B, vb
        SHL
        SLD A, va
        SLD B, vb
        SHR
        SLD A, va
        SLD B, vb
        EQ
        SLD A, va
        SLD B, vb
        NEQ
        SLD A, va
        SLD B, vb
        LT
        SLD A, va
        SLD B, vb
        GTE
        SLD A, va
        SLD B, vb
        GT
        SLD A, va
        SLD B, vb
        LTE
        SLD A, va
        INC
        SST A, 2
        IMF B, 4
        SHL
        SLD B, 2
        XOR
        INV A
        SST A, vb
        SLD A, va
        INC
        SST A, va
        JF done             ; after a = FF
        JMP loop
done:   HALT
