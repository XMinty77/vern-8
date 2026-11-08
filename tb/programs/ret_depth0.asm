; ret_depth0: RET at depth 0 is a NOP (PC + 1, stack and D unchanged): right after reset
; with every register unknown, repeated, after a call has returned, and after
; an overflowed stack has been fully unwound.

        RET
        RET
        RET
        IMF A, 1
        CALL r1
        RET                 ; D = 0 again
        RET
        CALL o1             ; five deep: this return is lost
        IMF B, 0xD0
        HALT
r1:     RET
o1:     CALL o2
        RET                 ; D = 0 by now: NOP
        RET
        RET
        IMF B, 0x99
        HALT
o2:     CALL o3
        RET
o3:     CALL o4
        RET
o4:     CALL o5
        RET
o5:     RET
