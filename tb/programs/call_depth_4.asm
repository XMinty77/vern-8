; call_depth_4: four nested calls (the full stack, D = 4) and all four returns.

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
        CALL f4
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE3
        HALT
f4:     INC
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE4
        HALT
