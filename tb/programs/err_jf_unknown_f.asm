; err_jf_unknown_f: JF with F unknown (AR known): F is read even though the target is fine.

; expect: error

        IMF AR, there
        JF
there:  HALT
