; err_jmp_partial_ar: JMP with AR half known (only ALO written).

; expect: error

        ALO 0x4
        JMP
        HALT
