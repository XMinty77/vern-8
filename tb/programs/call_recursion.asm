; call_recursion: a recursive subroutine: sum(n) = n + sum(n - 1) with n and the total in
; data memory. n = 3 stays within the stack (depth 4 at the base case); then
; n = 6 overflows it, so the outer returns are lost and the first RET at depth
; 0 falls through to the code after it. The NOP after the recursive CALL dates
; from the old one-step halt rule, when a RET returning to its own address
; counted as a halt; with five in a row it's no longer needed, but harmless.

.equ n, 0
.equ total, 1
        IMF A, 3
        SST A, n
        IMF A, 0
        SST A, total
        CALL sum            ; depth 1
        IMF A, 6            ; total = 6 here
        SST A, n
        IMF A, 0
        SST A, total
        CALL sum
        IMF B, 0xD0         ; not reached: this return is lost
        HALT
sum:    SLD A, n
        SLD B, total
        ADD
        SST A, total
        SLD A, n
        IMF B, 0
        JEQ base
        IMF B, 0xFF
        ADD                 ; n - 1
        SST A, n
        CALL sum
        NOP                 ; keeps the return address off the RET below (see header)
base:   RET
        ; RET at depth 0 falls through
        SLD A, total        ; 21
        HALT
