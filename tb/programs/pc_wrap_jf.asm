; pc_wrap_jf: PC wraps from FF to 00 after a JF that is not taken at FF, and a taken JF
; at FF whose target is 00. Word 00 is a RET that returns to the caller.

        RET                 ; 00
        IMF A, 0
        CLF
        IMF AR, 0xFF
        CALL                ; JF at FF with F = 0: not taken, wraps to 00
        STF
        IMF AR, 0xFD
        CALL                ; sets AR = 00 then JF at FF taken to 00
        IMF B, 0x24
        HALT
.org 0xFD
        ALO 0
        AHI 0
        JF                  ; FF
