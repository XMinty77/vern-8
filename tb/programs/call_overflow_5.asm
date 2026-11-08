; call_overflow_5: five nested calls: the fifth CALL at D = 4 loses the oldest return
; (main's) and D stays 4. Four RETs come back to f4..f1; the RET in f1
; then finds D = 0, is a NOP, and falls through to its HALT.

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
        CALL f5
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE4
        HALT
f5:     INC
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE5
        HALT
