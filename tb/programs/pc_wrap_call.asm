; pc_wrap_call: a CALL at address FF pushes PC + 1 = 00 (wrapped). The callee RETs to 00,
; where a RET returns to the original caller.

        RET                 ; 00: NOP at reset, then a return
        IMF A, 0x11
        IMF AR, 0xFC
        CALL                ; push 05, D = 1
        IMF B, 0x33
        HALT
callee: INC
        RET                 ; to 00
.org 0xFC
        IMF AR, callee      ; FC, FD
        INC                 ; FE
        CALL                ; FF: push 00, D = 2
