; err_cjump_unknown: JEQ label with A unknown: the EQ inside the expansion reads it.

; expect: error

        IMF B, 0
        JEQ there
there:  HALT
