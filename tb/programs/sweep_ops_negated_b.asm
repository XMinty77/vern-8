; sweep_ops_negated_b: all 16 ALU ops and the 6 compares for every A from 00 to FF, with
; B = (0 - A) & FF: ADD gives 0 with carry for every A except 0, SUB borrows from
; A = 01 to 80, compares cross over at 80.

.equ va, 0
.equ vb, 1
        IMF A, 0
        SST A, va
        IMF A, 0x00
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
        INC                 ; next a
        SWAP
        IMF A, 0
        SUB                 ; 0 - next a
        SST A, vb
        SLD A, va
        INC
        SST A, va
        JF done             ; after a = FF
        JMP loop
done:   HALT
