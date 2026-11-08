; prog_max_min_sum: maximum, minimum and 16-bit sum of 12 bytes at M[20..2B] in one pass, the
; sum's high byte counting ADD carries; results to M[0..3].

.equ mx, 0
.equ mn, 1
.equ slo, 2
.equ shi, 3
.equ p, 4
        IMF A, 0x37
        ST A, 0x20
        IMF A, 0x80
        ST A, 0x21
        IMF A, 0x7F
        ST A, 0x22
        IMF A, 0x00
        ST A, 0x23
        IMF A, 0xFF
        ST A, 0x24
        IMF A, 0x12
        ST A, 0x25
        IMF A, 0xFE
        ST A, 0x26
        IMF A, 0x01
        ST A, 0x27
        IMF A, 0x80
        ST A, 0x28
        IMF A, 0x99
        ST A, 0x29
        IMF A, 0x42
        ST A, 0x2A
        IMF A, 0x7F
        ST A, 0x2B
        IMF A, 0
        SST A, mx
        SST A, slo
        SST A, shi
        IMF A, 0xFF
        SST A, mn
        IMF A, 0x20
        SST A, p
loop:   SLD A, p
        LD A, A             ; value
        SLD B, mx
        JLTE nomax
        SST A, mx
nomax:  SLD B, mn
        JGTE nomin
        SST A, mn
nomin:  SLD B, slo
        ADD
        SST A, slo
        SLD A, shi
        JF carry
        JMP next
carry:  INC
        SST A, shi
next:   SLD A, p
        INC
        SST A, p
        IMF B, 0x2C
        JNEQ loop
        HALT
