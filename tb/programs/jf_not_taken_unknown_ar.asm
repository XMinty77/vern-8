; jf_not_taken_unknown_ar: JF with F = 0 must not depend on AR: AR is still unknown from reset when
; JF executes, and execution continues at PC + 1 (ISA: JF with F = 0 gives
; PC = PC + 1). Then CLF; JF with AR half known, then a taken JF.

        CLF
        JF                  ; AR unknown, not taken
        JF
        ALO 0x3             ; AR = x3
        JF                  ; AR partly known, not taken
        IMF AR, done
        STF
        JF                  ; taken
        INV A
done:   HALT
