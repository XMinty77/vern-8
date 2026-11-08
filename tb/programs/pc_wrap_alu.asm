; pc_wrap_alu: PC wraps from FF to 00 after an ordinary instruction (INC at FF). Word 00
; is a RET: at reset (D = 0) it is a NOP; after the wrap D = 1 and it returns to
; the caller. Code runs through every address F0 to FF. Then JMP to 00 and a CALL
; whose target is 00.

        RET                 ; 00: NOP at reset, a return after the wrap
        IMF A, 0x7F
        IMF AR, 0xF0
        CALL                ; push 05
        ; back here from word 00
        IMF AR, after
        CALL 0              ; CALL with target 00: its RET returns to after
after:  IMF AR, 0
        IMF B, cont
        CALL cont2          ; push cont
cont:   IMF B, 0x42
        HALT
cont2:  JMP AR              ; jump to 00, whose RET returns to cont
.org 0xF0
        INC
        INC
        INC
        INC
        INC
        INC
        INC
        INC
        INC
        INC
        INC
        INC
        INC
        INC
        INC
        INC                 ; FF: PC + 1 wraps to 00
