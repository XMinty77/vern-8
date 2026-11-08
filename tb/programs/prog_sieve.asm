; prog_sieve: sieve of Eratosthenes for numbers below 128 (flags at M[80+n]), multiples
; stepped with ADD from p * p (MUL); the primes are then collected to M[20..].

.equ p, 0
.equ m, 1
.equ outp, 2
        IMF A, 0x80
        IMF B, 0
clear:  TAR
        ST B, AR
        INC
        JF cleared          ; 0xFF -> 0x00
        JMP clear
cleared: IMF A, 2
        SST A, p
p_loop: SLD A, p
        IMF B, 0x80
        ADD
        LD A, A             ; flag of p
        IMF B, 0
        JNEQ p_next
        SLD A, p
        SLD B, p
        MUL                 ; p * p
        SST A, m
m_loop: SLD A, m
        IMF B, 0x80
        JGTE p_next
        ADD                 ; 0x80 + m
        IMF B, 1
        ST B, A
        SLD A, m
        SLD B, p
        ADD
        SST A, m
        JMP m_loop
p_next: SLD A, p
        INC
        SST A, p
        IMF B, 12           ; 11 * 11 = 121 < 128 < 13 * 13
        JNEQ p_loop
        ; collect
        IMF A, 0x20
        SST A, outp
        IMF A, 2
        SST A, p
c_loop: SLD A, p
        IMF B, 0x80
        ADD
        LD A, A
        IMF B, 0
        JNEQ c_next
        SLD A, outp
        SLD B, p
        ST B, A
        INC
        SST A, outp
c_next: SLD A, p
        INC
        SST A, p
        IMF B, 0x80
        JNEQ c_loop
        HALT
