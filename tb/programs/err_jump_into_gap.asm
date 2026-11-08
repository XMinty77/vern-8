; err_jump_into_gap: JMP into a hole left by .org: the word there was never loaded.

; expect: error

        IMF A, 1
        JMP 0x20
        HALT
.org 0x30
        HALT
