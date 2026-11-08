; cjump_b: J<cond> B (EQ, SWAP, TAR, SWAP, JF): B is both the target and the right operand,
; for JEQ, JNEQ, JLT, JGTE, JGT, JLTE, each taken and not taken.
; F keeps the compare result afterwards; skipped words invert A.

        IMF B, c1
        IMF A, c1
        JEQ B
        INV A               ; skipped
c1:                 ; EQ taken
        IMF B, c2
        IMF A, 0
        JEQ B
c2:                 ; EQ not taken
        IMF B, c3
        IMF A, 0
        JNEQ B
        INV A               ; skipped
c3:                 ; NEQ taken
        IMF B, c4
        IMF A, c4
        JNEQ B
c4:                 ; NEQ not taken
        IMF B, c5
        IMF A, 0
        JLT B
        INV A               ; skipped
c5:                 ; LT taken
        IMF B, c6
        IMF A, 0xFF
        JLT B
c6:                 ; LT not taken
        IMF B, c7
        IMF A, 0xFF
        JGTE B
        INV A               ; skipped
c7:                 ; GTE taken
        IMF B, c8
        IMF A, 0
        JGTE B
c8:                 ; GTE not taken
        IMF B, c9
        IMF A, 0xFF
        JGT B
        INV A               ; skipped
c9:                 ; GT taken
        IMF B, c10
        IMF A, 0
        JGT B
c10:                ; GT not taken
        IMF B, c11
        IMF A, 0
        JLTE B
        INV A               ; skipped
c11:                ; LTE taken
        IMF B, c12
        IMF A, 0xFF
        JLTE B
c12:                ; LTE not taken
        HALT
