; prog_lfsr: 8-bit Galois LFSR (right shift, taps B8) run for its full period of 255 steps
; from seed 01, marking each state in data memory (M[state] = 1, all cleared
; first); a repeated state before 255 steps would branch to a different HALT.

.equ cnt, 0
        IMF A, 0x10
        IMF B, 0
clr:    TAR
        ST B, AR
        INC
        JF cleared
        JMP clr
cleared: IMF A, 0x01
        SST A, 1            ; state
        IMF A, 0
        SST A, cnt
step:   SLD A, 1
        IMF B, 1
        AND                 ; lsb
        SST A, 2
        SLD A, 1
        IMF B, 1
        SHR
        SST A, 1
        SLD A, 2
        IMF B, 0
        JEQ nox
        SLD A, 1
        IMF B, 0xB8
        XOR
        SST A, 1
nox:    SLD A, 1
        IMF B, 0x10
        JLT count           ; states below 10 overlap short memory: not marked
        LD B, A
        IMF A, 0
        JNEQ repeat
        IMF B, 1
        SLD A, 1
        ST B, A
count:  SLD A, cnt
        INC
        SST A, cnt
        SLD B, 1
        IMF A, 1
        JNEQ step           ; until the state is back to 01
        SLD A, cnt          ; 0xFF
        HALT
repeat: IMF A, 0xEE
        HALT
