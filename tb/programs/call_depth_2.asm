; call_depth_2: two nested calls and returns: S0/S1 shift down on CALL and up on RET,
; 0 shifts into S3.

        CLF
        IMF A, 0
        IMF B, 0x10
        CALL f1
        IMF B, 0xD0         ; reached only if the return from f1 survived
        HALT
f1:     INC
        CALL f2
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE1
        HALT
f2:     INC
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE2
        HALT
