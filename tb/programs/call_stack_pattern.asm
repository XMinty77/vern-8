; call_stack_pattern: depth going up and down: 1, 2, 1, 2, 3, 2, 3, 4, 3, 4, then a call at depth 4
; that overflows (main's return is lost). Unwinding reaches D = 0 in lv_a, whose RET
; is then a NOP and falls into lv_b; the fall-through repeats level by level with
; fresh calls until lv_d's RET at depth 0 falls through to the HALT.

        IMF A, 0
        CALL lv_a           ; depth 1
        IMF B, 0xD0         ; not reached: this return is lost
        HALT
lv_a:   CALL leaf           ; 2, back to 1
        CALL lv_b           ; 2
        RET
lv_b:   CALL leaf           ; 3, back to 2
        CALL lv_c           ; 3
        RET
lv_c:   CALL leaf           ; 4, back to 3
        CALL lv_d           ; 4
        RET
lv_d:   CALL leaf           ; 5: D stays 4, oldest return dropped
        RET
        IMF B, 0x42
        HALT
leaf:   INC
        RET
