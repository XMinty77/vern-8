; call_depth_3: three nested calls and returns.

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
        CALL f3
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE2
        HALT
f3:     INC
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE3
        HALT
