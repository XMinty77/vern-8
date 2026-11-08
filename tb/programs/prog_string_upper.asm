; prog_string_upper: a zero-terminated ASCII string at M[40..]: length by scanning for 0, then
; in-place upper-casing of a..z only (range checks with JLT/JGT around the letter
; boundaries @ [ ` {), and a copy reversed into M[80..].

.equ p, 0
.equ len, 1
.equ q, 2
        IMF A, 0x48
        ST A, 0x40
        IMF A, 0x65
        ST A, 0x41
        IMF A, 0x6C
        ST A, 0x42
        IMF A, 0x6C
        ST A, 0x43
        IMF A, 0x6F
        ST A, 0x44
        IMF A, 0x2C
        ST A, 0x45
        IMF A, 0x20
        ST A, 0x46
        IMF A, 0x57
        ST A, 0x47
        IMF A, 0x6F
        ST A, 0x48
        IMF A, 0x72
        ST A, 0x49
        IMF A, 0x6C
        ST A, 0x4A
        IMF A, 0x64
        ST A, 0x4B
        IMF A, 0x21
        ST A, 0x4C
        IMF A, 0x20
        ST A, 0x4D
        IMF A, 0x7A
        ST A, 0x4E
        IMF A, 0x7A
        ST A, 0x4F
        IMF A, 0x40
        ST A, 0x50
        IMF A, 0x5B
        ST A, 0x51
        IMF A, 0x60
        ST A, 0x52
        IMF A, 0x7B
        ST A, 0x53
        IMF A, 0x00
        ST A, 0x54
        IMF A, 0x40
        SST A, p
len_l:  SLD A, p
        LD A, A
        IMF B, 0
        JEQ len_e
        SLD A, p
        INC
        SST A, p
        JMP len_l
len_e:  SLD A, p
        IMF B, 0x40
        SUB
        SST A, len
        IMF A, 0x40
        SST A, p
up_l:   SLD A, p
        LD A, A
        IMF B, 0
        JEQ up_e
        IMF B, 0x61         ; 'a'
        JLT up_n
        IMF B, 0x7A         ; 'z'
        JGT up_n
        IMF B, 0xDF
        AND                 ; clear bit 5
        SWAP
        SLD A, p
        ST B, A
up_n:   SLD A, p
        INC
        SST A, p
        JMP up_l
up_e:   ; reverse copy: M[80 + len - 1 - k] = M[40 + k]
        SLD A, len
        IMF B, 0x7F
        ADD
        SST A, q
        IMF A, 0x40
        SST A, p
rv_l:   SLD A, p
        LD B, A
        IMF A, 0
        JEQ rv_e
        SLD A, q
        ST B, A
        IMF B, 0xFF
        ADD
        SST A, q
        SLD A, p
        INC
        SST A, p
        JMP rv_l
rv_e:   HALT
