; call_depth_1: one CALL and RET: D 0 -> 1 -> 0, S0 = return address, then 0.

        CLF
        IMF A, 0
        IMF B, 0x10
        CALL f1
        IMF B, 0xD0         ; reached only if the return from f1 survived
        HALT
f1:     INC
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE1
        HALT
