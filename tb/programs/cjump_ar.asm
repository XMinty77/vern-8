; cjump_ar: J<cond> AR (EQ, JF), AR set beforehand,
; for JEQ, JNEQ, JLT, JGTE, JGT, JLTE, each taken and not taken.
; F keeps the compare result afterwards; skipped words invert A.

        IMF A, 0x80
        IMF B, 0x80
        IMF AR, c1
        JEQ AR
        INV A               ; skipped
c1:                 ; EQ taken
        IMF A, 0x80
        IMF B, 0x81
        IMF AR, c2
        JEQ AR
c2:                 ; EQ not taken
        IMF A, 0x00
        IMF B, 0xFF
        IMF AR, c3
        JNEQ AR
        INV A               ; skipped
c3:                 ; NEQ taken
        IMF A, 0x7F
        IMF B, 0x7F
        IMF AR, c4
        JNEQ AR
c4:                 ; NEQ not taken
        IMF A, 0x7F
        IMF B, 0x80
        IMF AR, c5
        JLT AR
        INV A               ; skipped
c5:                 ; LT taken
        IMF A, 0x80
        IMF B, 0x7F
        IMF AR, c6
        JLT AR
c6:                 ; LT not taken
        IMF A, 0x80
        IMF B, 0x80
        IMF AR, c7
        JGTE AR
        INV A               ; skipped
c7:                 ; GTE taken
        IMF A, 0x00
        IMF B, 0x01
        IMF AR, c8
        JGTE AR
c8:                 ; GTE not taken
        IMF A, 0xFF
        IMF B, 0xFE
        IMF AR, c9
        JGT AR
        INV A               ; skipped
c9:                 ; GT taken
        IMF A, 0x10
        IMF B, 0x10
        IMF AR, c10
        JGT AR
c10:                ; GT not taken
        IMF A, 0x01
        IMF B, 0x01
        IMF AR, c11
        JLTE AR
        INV A               ; skipped
c11:                ; LTE taken
        IMF A, 0x02
        IMF B, 0x01
        IMF AR, c12
        JLTE AR
c12:                ; LTE not taken
        HALT
