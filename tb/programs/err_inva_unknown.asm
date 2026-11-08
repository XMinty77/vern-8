; err_inva_unknown: INVA on an unknown A, after B, AR and F were made known.

; expect: error

        IMF B, 0xFF
        IMF AR, 0x10
        CLF
        INVA
        HALT
