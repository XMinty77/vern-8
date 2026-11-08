; sweep_compare_jumps: every A from 00 to FF against B = 80 through all six compare-and-jump
; families (label form), each either taken or not depending on A; the taken path
; adds a distinct bit to a tally in short memory.

.equ va, 0
.equ t, 1
        IMF A, 0
        SST A, va
        SST A, t
loop:   SLD A, va
        IMF B, 0x80
        JEQ j1
        JMP n1
j1:     IMF A, 0x01
        CALL tally
n1:     SLD A, va
        IMF B, 0x80
        JNEQ j2
        JMP n2
j2:     IMF A, 0x02
        CALL tally
n2:     SLD A, va
        IMF B, 0x80
        JLT j3
        JMP n3
j3:     IMF A, 0x04
        CALL tally
n3:     SLD A, va
        IMF B, 0x80
        JGTE j4
        JMP n4
j4:     IMF A, 0x08
        CALL tally
n4:     SLD A, va
        IMF B, 0x80
        JGT j5
        JMP n5
j5:     IMF A, 0x10
        CALL tally
n5:     SLD A, va
        IMF B, 0x80
        JLTE j6
        JMP n6
j6:     IMF A, 0x20
        CALL tally
n6:     SLD A, va
        INC
        SST A, va
        JF done
        JMP loop
done:   HALT
tally:  SLD B, t
        ADD
        SST A, t
        RET
