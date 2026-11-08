; call_forms: CALL in every form: bare CALL (AR as set), CALL label, CALL AR, CALL A,
; CALL B (A and B kept). Each pushes PC + 1 of the CALL word itself (the last
; word of the expansion) and the subroutine RETs to it; D goes 0 -> 1 -> 0.

        IMF A, 0
        IMF B, 0
        IMF AR, s1
        CALL                ; bare
        CALL s2             ; ALO, AHI, CALL
        IMF AR, s3
        CALL AR
        IMF A, s4
        CALL A              ; TAR, CALL
        IMF B, s5
        IMF A, 0x12
        CALL B              ; SWAP, TAR, SWAP, CALL
        HALT
s1:     INC
        RET
s2:     INV B
        RET
s3:     IMF A, 0x33
        RET
s4:     INC
        RET
s5:     INC                 ; A = 13, B = s5 kept
        RET
