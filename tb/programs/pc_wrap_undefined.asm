; pc_wrap_undefined: PC wraps from FF to 00 after an undefined opcode (.byte 0xCF) at FF, and a
; JMP whose target is FF. Word 00 is a RET that returns to the caller.

        RET                 ; 00
        IMF A, 0x20
        IMF AR, 0xFF
        CALL                ; to the undefined opcode at FF
        IMF B, 0x66
        HALT
.org 0xFF
        .byte 0xCF
