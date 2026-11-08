; cjump_a: J<cond> A (EQ, TAR, JF): A is both the target and the left operand,
; for JEQ, JNEQ, JLT, JGTE, JGT, JLTE, each taken and not taken.
; F keeps the compare result afterwards; skipped words invert A.

        IMF A, c1
        IMF B, c1
        JEQ A
        INV A               ; skipped
c1:                 ; EQ taken
        IMF A, c2
        IMF B, 0
        JEQ A
c2:                 ; EQ not taken
        IMF A, c3
        IMF B, 0
        JNEQ A
        INV A               ; skipped
c3:                 ; NEQ taken
        IMF A, c4
        IMF B, c4
        JNEQ A
c4:                 ; NEQ not taken
        IMF A, c5
        IMF B, 0xFF
        JLT A
        INV A               ; skipped
c5:                 ; LT taken
        IMF A, c6
        IMF B, 0
        JLT A
c6:                 ; LT not taken
        IMF A, c7
        IMF B, 0
        JGTE A
        INV A               ; skipped
c7:                 ; GTE taken
        IMF A, c8
        IMF B, 0xFF
        JGTE A
c8:                 ; GTE not taken
        IMF A, c9
        IMF B, 0
        JGT A
        INV A               ; skipped
c9:                 ; GT taken
        IMF A, c10
        IMF B, 0xFF
        JGT A
c10:                ; GT not taken
        IMF A, c11
        IMF B, 0xFF
        JLTE A
        INV A               ; skipped
c11:                ; LTE taken
        IMF A, c12
        IMF B, 0
        JLTE A
c12:                ; LTE not taken
        HALT
