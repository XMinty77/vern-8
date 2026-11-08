; prog_mul16: 8 x 8 -> 16-bit multiply by shift and add, as a subroutine with arguments
; and results in short memory: 16-bit add with carry (JF on the ADD carry), 16-bit
; shift with SHR 7 and OR. Each product is checked against MUL for the low byte.

.equ rlo, 0
.equ rhi, 1
.equ mlo, 2
.equ mhi, 3
.equ q, 4
.equ cnt, 5
.equ a0, 6
.equ b0, 7
.equ bad, 8
        IMF A, 0
        SST A, bad
        IMF A, 0xFF
        IMF B, 0xFF
        CALL test           ; FE01
        IMF A, 0x10
        IMF B, 0x10
        CALL test           ; 0100
        IMF A, 0x0D
        IMF B, 0x0B
        CALL test           ; 008F
        IMF A, 0x00
        IMF B, 0xC7
        CALL test
        IMF A, 0x80
        IMF B, 0x02
        CALL test
        IMF A, 0xA5
        IMF B, 0x5A
        CALL test
        HALT
test:   SST A, a0
        SST B, b0
        SST A, mlo
        SST B, q
        CALL mul16          ; depth 2
        SLD A, a0
        SLD B, b0
        MUL
        SLD B, rlo
        JEQ ok
        SST A, bad
ok:     RET
mul16:  IMF A, 0
        SST A, rlo
        SST A, rhi
        SST A, mhi
        IMF A, 8
        SST A, cnt
mloop:  SLD A, q
        IMF B, 1
        AND
        IMF B, 0
        JEQ mskip
        SLD A, rlo
        SLD B, mlo
        ADD
        SST A, rlo
        SLD A, rhi
        JF mcarry
        JMP mnc
mcarry: INC
mnc:    SLD B, mhi
        ADD
        SST A, rhi
mskip:  SLD A, mhi
        SLD B, mhi
        ADD                 ; mhi * 2
        SST A, mhi
        SLD A, mlo
        IMF B, 7
        SHR                 ; top bit of mlo
        SLD B, mhi
        OR
        SST A, mhi
        SLD A, mlo
        SLD B, mlo
        ADD
        SST A, mlo
        SLD A, q
        IMF B, 1
        SHR
        SST A, q
        SLD A, cnt
        IMF B, 0xFF
        ADD
        SST A, cnt
        IMF B, 0
        JNEQ mloop
        RET
