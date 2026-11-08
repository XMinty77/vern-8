; jf_forms: JF in every form, each taken (F = 1) and not taken (F = 0): bare JF,
; JF label, JF AR, JF A, JF B. Not taken goes to PC + 1; the label forms
; still overwrite AR. F is kept by JF in both cases.

        IMF A, 0
        IMF B, 0
        STF
        IMF AR, a1
        JF                  ; taken
        INV A
a1:     CLF
        IMF AR, 0xF0        ; never used as a target
        JF                  ; not taken, PC + 1
        STF
        JF a2               ; taken
        INV A
a2:     CLF
        JF trap             ; not taken, AR is overwritten anyway
        STF
        IMF AR, a3
        JF AR
        INV A
a3:     CLF
        JF AR               ; AR still a3: not taken
        IMF A, a4
        STF
        JF A                ; taken
        INV B
a4:     CLF
        JF A                ; not taken, AR = A
        IMF B, a5
        STF
        JF B                ; taken, A and B kept
        INV A
a5:     CLF
        JF B                ; not taken
        HALT
trap:   IMF A, 0xEE
        HALT
