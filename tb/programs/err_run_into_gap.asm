; err_run_into_gap: execution falls through the end of the code into unloaded instruction
; memory (no HALT), after a few valid steps.

; expect: error

        IMF A, 1
        INC
        INC
