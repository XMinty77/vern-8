; jfe: JFE x, y: to x when F = 1, to y when F = 0, never falling through;
; forward and backward targets, x = y, and F kept.

        IMF A, 0
        STF
        JFE f1, trap        ; F = 1: to f1
        INV A
trap:   IMF A, 0xEE
        HALT
f1:     CLF
        JFE trap, f2        ; F = 0: to f2
        INV A
f3:     STF
        JFE f4, f4          ; same target both ways
        INV A
f2:     JFE trap, f3        ; F = 0: backward to f3
f4:     CLF
        JFE f4b, f4b
f4b:    STF
        JFE f5, f5
f5:     IMF B, 0x55
        HALT
