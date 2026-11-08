; prog_parity: even parity of 16 bytes by XOR folding (x ^= x >> 4; x ^= x >> 2;
; x ^= x >> 1; & 1), and a parity byte over the whole block with XNOR/NOR
; variants checked against the plain XOR result.

.equ p, 0
.equ acc, 1
.equ bad, 2
        IMF A, 0x00
        ST A, 0x70
        IMF A, 0x01
        ST A, 0x71
        IMF A, 0x03
        ST A, 0x72
        IMF A, 0x07
        ST A, 0x73
        IMF A, 0x80
        ST A, 0x74
        IMF A, 0xFF
        ST A, 0x75
        IMF A, 0xFE
        ST A, 0x76
        IMF A, 0x55
        ST A, 0x77
        IMF A, 0xAA
        ST A, 0x78
        IMF A, 0x96
        ST A, 0x79
        IMF A, 0x69
        ST A, 0x7A
        IMF A, 0x0F
        ST A, 0x7B
        IMF A, 0xF0
        ST A, 0x7C
        IMF A, 0x11
        ST A, 0x7D
        IMF A, 0x7F
        ST A, 0x7E
        IMF A, 0x81
        ST A, 0x7F
        IMF A, 0x70
        SST A, p
        IMF A, 0
        SST A, acc
        SST A, bad
loop:   SLD A, p
        LD A, A
        SST A, 3
        SLD B, acc
        XOR
        SST A, acc          ; running XOR of the block
        SLD A, 3
        IMF B, 4
        SHR
        SLD B, 3
        XOR
        SST A, 3
        IMF B, 2
        SHR
        SLD B, 3
        XOR
        SST A, 3
        IMF B, 1
        SHR
        SLD B, 3
        XOR
        IMF B, 1
        AND                 ; parity bit
        SWAP
        SLD A, p
        IMF AR, 0x10        ; parity to M[p + 10]: shift the pointer
        SWAP
        SST A, 4
        SWAP
        IMF B, 0x10
        ADD
        SLD B, 4
        ST B, A
        SLD A, p
        INC
        SST A, p
        IMF B, 0x80
        JNEQ loop
        ; ~(a ^ b) == ~a ^ b, and NOR(x, x) == ~x
        SLD A, acc
        IMF B, 0x5C
        XNOR
        SST A, 5
        SLD A, acc
        INV A
        IMF B, 0x5C
        XOR
        SLD B, 5
        JEQ ok1
        SST A, bad
ok1:    SLD A, acc
        SLD B, acc
        NOR
        SLD B, acc
        INV B
        JEQ ok2
        SST A, bad
ok2:    HALT
