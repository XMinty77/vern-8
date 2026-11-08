; cjump_label: J<cond> label (EQ, ALO, AHI, JF),
; for JEQ, JNEQ, JLT, JGTE, JGT, JLTE, each taken and not taken.
; F keeps the compare result afterwards; skipped words invert A.

        IMF A, 0x80
        IMF B, 0x80
        JEQ c1
        INV A               ; skipped
c1:                 ; EQ taken
        IMF A, 0x80
        IMF B, 0x81
        JEQ c2
c2:                 ; EQ not taken
        IMF A, 0x00
        IMF B, 0xFF
        JNEQ c3
        INV A               ; skipped
c3:                 ; NEQ taken
        IMF A, 0x7F
        IMF B, 0x7F
        JNEQ c4
c4:                 ; NEQ not taken
        IMF A, 0x7F
        IMF B, 0x80
        JLT c5
        INV A               ; skipped
c5:                 ; LT taken
        IMF A, 0x80
        IMF B, 0x7F
        JLT c6
c6:                 ; LT not taken
        IMF A, 0x80
        IMF B, 0x80
        JGTE c7
        INV A               ; skipped
c7:                 ; GTE taken
        IMF A, 0x00
        IMF B, 0x01
        JGTE c8
c8:                 ; GTE not taken
        IMF A, 0xFF
        IMF B, 0xFE
        JGT c9
        INV A               ; skipped
c9:                 ; GT taken
        IMF A, 0x10
        IMF B, 0x10
        JGT c10
c10:                ; GT not taken
        IMF A, 0x01
        IMF B, 0x01
        JLTE c11
        INV A               ; skipped
c11:                ; LTE taken
        IMF A, 0x02
        IMF B, 0x01
        JLTE c12
c12:                ; LTE not taken
        HALT
