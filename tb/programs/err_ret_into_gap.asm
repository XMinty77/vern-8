; err_ret_into_gap: a RET whose return address points into a .org hole: the CALL sits at the
; end of a block, so PC + 1 was never loaded.

; expect: error

        IMF A, callee
        JMP 0x10            ; overwrites AR
.org 0x10
        TAR
        CALL                ; at 0x11: returns to 0x12, never loaded
.org 0x20
callee: RET
