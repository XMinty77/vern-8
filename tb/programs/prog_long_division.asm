; prog_long_division: restoring binary long division (shift, compare, subtract), 8 / 8 bits, as
; a subroutine, checked against DIV for quotient and remainder. Divisors above 80
; make the doubled remainder carry, which is handled through the ADD carry.

.equ n, 0
.equ d, 1
.equ rem, 2
.equ quo, 3
.equ cnt, 4
.equ bad, 5
.equ a0, 6
        IMF A, 0
        SST A, bad
        IMF A, 200
        IMF B, 7
        CALL test
        IMF A, 0xFF
        IMF B, 0xFF
        CALL test
        IMF A, 0xFE
        IMF B, 0x81
        CALL test
        IMF A, 0x05
        IMF B, 0x09
        CALL test
        IMF A, 0x00
        IMF B, 0x01
        CALL test
        IMF A, 0xF7
        IMF B, 0x10
        CALL test
        HALT
test:   SST A, n
        SST A, a0
        SST B, d
        CALL ldiv
        SLD A, a0
        SLD B, d
        DIV                 ; A = quotient, B = remainder
        SST B, cnt          ; cnt is free now
        SLD B, quo
        JNEQ fail
        SLD A, cnt
        SLD B, rem
        JNEQ fail
        RET
fail:   IMF A, 1
        SST A, bad
        RET
ldiv:   IMF A, 0
        SST A, rem
        SST A, quo
        IMF A, 8
        SST A, cnt
dloop:  SLD A, n
        IMF B, 7
        SHR                 ; next bit of n
        SST A, 7
        SLD A, n
        SLD B, n
        ADD
        SST A, n            ; n <<= 1
        SLD A, quo
        SLD B, quo
        ADD
        SST A, quo          ; quo <<= 1
        SLD A, rem
        SLD B, rem
        ADD                 ; rem * 2, F = carry
        SLD B, 7
        OR                  ; F kept by OR
        SST A, rem
        SLD B, d
        JF dsub             ; the true remainder is above FF: certainly >= d
        JLT dnext
dsub:   SUB
        SST A, rem
        SLD A, quo
        INC
        SST A, quo
dnext:  SLD A, cnt
        IMF B, 0xFF
        ADD
        SST A, cnt
        IMF B, 0
        JNEQ dloop
        RET
