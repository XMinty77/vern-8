; limit_infinite_recursion: unbounded recursion: a subroutine that calls itself forever. D saturates
; at 4 and the stack keeps the same four return addresses. Ends at the step
; limit (CALL is not at its own target, so PC changes every step).

; expect: limit

        IMF A, 0
rec:    INC
        IMF AR, rec
        CALL
        RET
        HALT
