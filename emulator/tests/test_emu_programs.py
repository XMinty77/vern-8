"""Whole programs, assembled with the project's assembler, with results worked
out by hand from the ISA."""

from emuhelp import run_asm


def final(t):
    assert t.end == "HALT", t.lines[-1]
    return t.last


def test_arithmetic_and_flags(tmp_path):
    t = run_asm(tmp_path, """
        IMF A, 200
        IMF B, 100
        ADD             ; 300 -> 44, carry
        SST A, 0
        IMF A, 5
        IMF B, 7
        SUB             ; 5 - 7 -> 254, borrow
        SST A, 1
        IMF A, 20
        IMF B, 13
        MUL             ; 260 -> 4, discarded bits non-zero
        SST A, 2
        IMF A, 15
        IMF B, 17
        MUL             ; 255 fits, F = 0
        SST A, 3
        IMF A, 0xFF
        INC             ; wraps to 0, carry
        HALT
    """)
    w = [(r.op, r.write, r.state["a"], r.state["f"]) for r in t.steps
         if r.op in ("82", "83", "84", "87")]
    assert w == [("82", None, "2c", "1"), ("83", None, "fe", "1"),
                 ("84", None, "04", "1"), ("84", None, "ff", "0"),
                 ("87", None, "00", "1")]
    writes = [r.write for r in t.steps if r.write]
    assert writes == [("00", "2c"), ("01", "fe"), ("02", "04"), ("03", "ff")]


def test_no_carry_cases_clear_f(tmp_path):
    t = run_asm(tmp_path, """
        STF
        IMF A, 100
        IMF B, 155
        ADD             ; exactly 255: no carry
        SST A, 0
        STF
        IMF B, 255
        SUB             ; 255 - 255 = 0: no borrow
        SST A, 1
        STF
        INC             ; 0 -> 1
        HALT
    """)
    ops = [(r.op, r.state["a"], r.state["f"]) for r in t.steps
           if r.op in ("82", "83", "87")]
    assert ops == [("82", "ff", "0"), ("83", "00", "0"), ("87", "01", "0")]


def test_div(tmp_path):
    t = run_asm(tmp_path, """
        IMF A, 200
        IMF B, 7
        STF
        DIV             ; 28 rem 4, F cleared
        SST A, 0
        SST B, 1
        IMF A, 9
        IMF B, 0
        CLF
        DIV             ; by zero: A, B kept, F set
        HALT
    """)
    divs = [r.state for r in t.steps if r.op == "85"]
    assert [(s["a"], s["b"], s["f"]) for s in divs] == [("1c", "04", "0"),
                                                        ("09", "00", "1")]


def test_logic_and_shifts(tmp_path):
    src = """
        IMF A, 0b11001010
        IMF B, 0b10100110
        {op}
        HALT
    """
    want = {"AND": "82", "NAND": "7d", "OR": "ee", "NOR": "11", "XOR": "6c",
            "XNOR": "93", "INV A": "35", "SWAP": "a6"}
    for op, a in want.items():
        s = final(run_asm(tmp_path, src.format(op=op)))
        assert s["a"] == a, op
        assert s["f"] == "x", f"{op} must not write F"
    s = final(run_asm(tmp_path, src.format(op="INV B")))
    assert (s["a"], s["b"]) == ("ca", "59")
    s = final(run_asm(tmp_path, src.format(op="SWAP")))
    assert (s["a"], s["b"]) == ("a6", "ca")

    shifts = [("SHL", 0, "b5"), ("SHL", 3, "a8"), ("SHL", 7, "80"),
              ("SHL", 8, "00"), ("SHL", 200, "00"), ("SHR", 0, "b5"),
              ("SHR", 3, "16"), ("SHR", 7, "01"), ("SHR", 8, "00"),
              ("SHR", 255, "00")]
    for op, b, a in shifts:
        s = final(run_asm(tmp_path, f"IMF A, 0xB5\nIMF B, {b}\n{op}\nHALT\n"))
        assert s["a"] == a, (op, b)
        assert s["f"] == "x"


def test_flag_ops(tmp_path):
    def flags(a, b):
        t = run_asm(tmp_path, f"""
            IMF A, {a}
            IMF B, {b}
            EQ
            NEQ
            LT
            GTE
            GT
            LTE
            CLF
            STF
            HALT
        """)
        return "".join(r.state["f"] for r in t.steps[4:12])

    #                 EQ NEQ LT GTE GT LTE CLF STF
    assert flags(5, 5) == "10010101"
    assert flags(4, 5) == "01100101"
    assert flags(6, 5) == "01011001"
    assert flags(0, 255) == "01100101"


def test_nibble_immediates_keep_the_other_nibble(tmp_path):
    t = run_asm(tmp_path, """
        ILA 0x3         ; A = x3
        IHB 0xC         ; B = cx
        ALO 0x9         ; AR = x9
        IHA 0x7         ; A = 73
        ILB 0x1         ; B = c1
        AHI 0x2         ; AR = 29
        ILA 0xE         ; A = 7e
        IHA 0x0         ; A = 0e
        ALO 0x0         ; AR = 20
        AHI 0xF         ; AR = f0
        HALT
    """)
    got = [(r.state["a"], r.state["b"], r.state["ar"]) for r in t.steps[:10]]
    assert got == [("x3", "xx", "xx"), ("x3", "cx", "xx"), ("x3", "cx", "x9"),
                   ("73", "cx", "x9"), ("73", "c1", "x9"), ("73", "c1", "29"),
                   ("7e", "c1", "29"), ("0e", "c1", "29"), ("0e", "c1", "20"),
                   ("0e", "c1", "f0")]


def test_memory(tmp_path):
    t = run_asm(tmp_path, """
        IMF A, 0x11
        IMF B, 0x22
        SST A, 15       ; M[0f] = 11
        SST B, 0        ; M[00] = 22
        IMF AR, 0xFF
        ST A            ; M[ff] = 11
        IMF A, 0x80
        TAR
        ST B            ; M[80] = 22
        SLD A, 0        ; A = 22
        SLD B, 15       ; B = 11
        IMF AR, 0xFF
        LD B            ; B = 11
        IMF AR, 0x80
        LD A            ; A = 22
        IMF A, 0x33
        SST A, 0        ; overwrite M[00] = 33
        SLD B, 0
        HALT
    """, mode="full")
    writes = []
    for prev, rec in zip(t.records, t.records[1:]):
        changed = [(i, rec.mem[i]) for i in range(256) if rec.mem[i] != prev.mem[i]]
        writes += changed
    assert writes == [(0x0F, "11"), (0x00, "22"), (0xFF, "11"), (0x80, "22"),
                      (0x00, "33")]
    s = t.last
    assert (s["a"], s["b"]) == ("33", "33")
    loads = [(r.op, r.state["a"], r.state["b"]) for r in t.steps
             if r.op in ("60", "7f", "dd", "dc")]
    assert loads == [("60", "22", "22"), ("7f", "22", "11"), ("dd", "22", "11"),
                     ("dc", "22", "11")]
    mem = t.records[-1].mem
    assert mem[0x00] == "33" and mem[0x0F] == "11" and mem[0x80] == "22"
    assert mem[0xFF] == "11"
    assert mem.count("xx") == 252


def test_write_mode_reports_each_write(tmp_path):
    t = run_asm(tmp_path, """
        IMF A, 0xAB
        IMF AR, 0x42
        ST A
        SST A, 7
        HALT
    """)
    assert [r.write for r in t.records] == [None] * 5 + [("42", "ab"), ("07", "ab")] + [None] * 7


def test_jumps(tmp_path):
    t = run_asm(tmp_path, """
        JMP over
        .byte 0xC0      ; never executed
over:   IMF A, 1
        TAR
        CLF
        JF AR           ; not taken
        STF
        JF yes          ; taken
        .byte 0xC1
yes:    IMF B, 0x5A
        HALT
    """)
    pcs = [r.epc for r in t.steps]
    assert "03" not in pcs  # the .byte after JMP over (ALO, AHI, JMP, byte)
    jf = [(r.epc, r.state["pc"]) for r in t.steps if r.op == "99"]
    assert jf[0] == ("08", "09")       # F = 0: PC + 1
    assert jf[1][1] == "0e"            # taken to yes
    assert final(t)["b"] == "5a"


def test_call_and_ret(tmp_path):
    t = run_asm(tmp_path, """
        IMF A, 0
        CALL f1         ; return to 05
        HALT
f1:     INC
        CALL f2
        RET
f2:     INC
        RET
    """)
    rec = [(r.op, r.state["pc"], r.state["d"], r.state["s0"], r.state["s1"])
           for r in t.steps if r.op in ("9a", "9b")]
    # f1 at 08: INC 08, ALO 09, AHI 0a, CALL 0b -> f2 at 0d
    assert rec == [("9a", "08", "1", "05", "00"),
                   ("9a", "0d", "2", "0c", "05"),
                   ("9b", "0c", "1", "05", "00"),
                   ("9b", "05", "0", "00", "00")]
    assert final(t)["a"] == "02"


def test_call_stack_overflow_and_empty_ret(tmp_path):
    # Five nested calls: the first return address is lost, D stays at 4.
    t = run_asm(tmp_path, """
        RET             ; empty stack: NOP
        CALL c1         ; pushes 04
        HALT
c1:     CALL c2         ; pushes 0a
        HALT
c2:     CALL c3         ; pushes 10
        HALT
c3:     CALL c4         ; pushes 16
        HALT
c4:     CALL c5         ; pushes 1c
        HALT
c5:     RET
    """, "-n", "200")
    calls = [(r.state["d"], r.state["s0"], r.state["s1"], r.state["s2"],
              r.state["s3"]) for r in t.steps if r.op == "9a"]
    assert calls == [("1", "04", "00", "00", "00"),
                     ("2", "0a", "04", "00", "00"),
                     ("3", "10", "0a", "04", "00"),
                     ("4", "16", "10", "0a", "04"),
                     ("4", "1c", "16", "10", "0a")]
    first = t.steps[0]
    assert (first.op, first.state["pc"], first.state["d"]) == ("9b", "01", "0")
    rets = [(r.state["pc"], r.state["d"], r.state["s0"], r.state["s3"])
            for r in t.steps if r.op == "9b"][1:]
    # c5's RET goes back into c4 (1c), whose HALT stops the run.
    assert rets == [("1c", "3", "16", "00")]
    assert final(t)["pc"] == "1e"


def test_ret_unwinds_to_empty_then_nops(tmp_path):
    t = run_asm(tmp_path, """
        CALL f          ; 00-02, pushes 03
        RET             ; 03: stack empty again, so NOP
        HALT
f:      CALL g          ; 07-09, pushes 0a
        RET             ; 0a
g:      RET             ; 0b
    """)
    rets = [(r.epc, r.state["pc"], r.state["d"]) for r in t.steps
            if r.op == "9b"]
    assert rets == [("0b", "0a", "1"), ("0a", "03", "0"), ("03", "04", "0")]


def test_pc_wraps(tmp_path):
    t = run_asm(tmp_path, """
        JMP top         ; 00-02
        STF             ; 03, never reached
.org 0xFD
top:    IMF A, 9        ; fd, fe
        INC             ; ff, then 00
    """, "-n", "9")
    assert t.end == "LIMIT"
    assert [r.epc for r in t.steps] == ["00", "01", "02", "fd", "fe", "ff",
                                        "00", "01", "02"]
    assert t.steps[5].state["pc"] == "00"


def test_call_at_ff_pushes_00(tmp_path):
    t = run_asm(tmp_path, """
        JMP top         ; 00-02
fn:     HALT            ; 03-05
.org 0xFD
top:    IMF AR, fn      ; fd, fe
        CALL            ; ff
    """)
    call = [r for r in t.steps if r.op == "9a"][0]
    assert call.epc == "ff"
    assert (call.state["pc"], call.state["d"], call.state["s0"]) == ("03", "1", "00")
    assert final(t)["pc"] == "05"
