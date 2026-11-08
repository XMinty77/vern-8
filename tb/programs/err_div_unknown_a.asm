; err_div_unknown_a: DIV by zero with A unknown: even the B = 0 case reads A.

; expect: error

        IMF B, 0
        DIV
        HALT
