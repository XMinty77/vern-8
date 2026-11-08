; limit_counter_loop: a loop that never ends: an 8-bit counter in data memory incremented
; forever (it wraps), with a compare-and-jump that is always taken. Ends at
; the step limit.

; expect: limit

        IMF A, 0
        SST A, 0
loop:   SLD A, 0
        INC
        SST A, 0
        IMF B, 0xFF
        JLTE loop           ; A <= FF always
        HALT
