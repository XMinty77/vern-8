; call_overflow_8: eight nested calls: D saturates at 4 for the last four CALLs, S3 is
; dropped each time. Four RETs return to f7..f4, the fifth (in f4) is a
; NOP at D = 0 and falls through to f4's HALT.

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
        CALL f6
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE5
        HALT
f6:     INC
        CALL f7
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE6
        HALT
f7:     INC
        CALL f8
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE7
        HALT
f8:     INC
        INV B
        RET
        ; only when this RET found the stack empty (D = 0)
        IMF B, 0xE8
        HALT
