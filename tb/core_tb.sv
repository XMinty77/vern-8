/* ================ Core Testbench ================
 * Lockstep testbench of the core against the emulator
 * Runs one program per simulation:
 *   +hex=<program.hex>    loaded into PM
 *   +trace=<trace file>   the emulator's trace of the same hex, -m writes
 *   +end=HALT|ERROR|LIMIT how the trace must end (default HALT)
 * After every instruction, compares PC, A, B, AR, F, D, S0-S3, the write
 * port of M and all of M. An x in the trace is a don't care.
 * Stops at the first step that diverges.
 * ================================================
 */
module core_tb;

  import tb_prefs::*;

  // Edges the core is held in reset for, from power-up
  localparam int ResetEdges = 2;
  // Edges checked after the trace halts
  localparam int HaltEdges  = 2;

  logic clk_i = 0, rst_i = 1;

  core dut (.*);

  initial forever #5 clk_i = ~clk_i;

  int errors;
  int step;
  int fd;
  string hex_file, trace_file, exp_end, end_kind;

  // Current trace record
  string      tag;
  logic [7:0] epc, op;
  logic [7:0] pc, a, b, ar;
  logic       f;
  logic [3:0] d;
  logic [7:0] s0, s1, s2, s3;
  logic       w;
  logic [7:0] w_addr, w_data;

  // Data memory as the emulator sees it, built from the write events
  logic [7:0] shadow [0:255];

  // x bits in expected match anything; an x in actual matches only an x.
  // Same as (actual ==? expected) === 1, which Verilator can't lint here
  function automatic logic agrees (
    input logic [7:0] actual,
    input logic [7:0] expected
  );
    // Fast path for the usual case, same byte or both all x
    if (actual === expected) return 1;
    for (int i = 0; i < 8; i++)
      if (expected[i] !== 1'bx && actual[i] !== expected[i]) return 0;
    return 1;
  endfunction

  // Fails unless actual matches expected
  task automatic check (
    input string      name,
    input logic [7:0] actual,
    input logic [7:0] expected
  );
    assert (agrees(actual, expected)) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("Step %0d (PC=%h, instr=%h): expected %s=%h, got %h",
               step, epc, op, name, expected, actual);
    end
  endtask

  // Reads the fields after a record's tag
  task automatic read_record;
    int n;
    n = $fscanf(fd, " %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",
                epc, op, pc, a, b, ar, f, d, s0, s1, s2, s3, w, w_addr, w_data);
    if (n != 15)
      $fatal(1, "%s: malformed %s record after step %0d", trace_file, tag, step);
  endtask

  // Architectural state against the current record
  task automatic check_state;
    check("PC", dut.ru_pc, pc);
    check("A",  dut.wu_a,  a);
    check("B",  dut.wu_b,  b);
    check("AR", dut.wu_ar, ar);
    check("F",  {7'b0, dut.ru_f},   {7'b0, f});
    check("D",  {5'b0, dut.u_ru.d_q}, {4'b0, d});
    check("S0", dut.u_ru.s_q[0], s0);
    check("S1", dut.u_ru.s_q[1], s1);
    check("S2", dut.u_ru.s_q[2], s2);
    check("S3", dut.u_ru.s_q[3], s3);
  endtask

  // M's write port, before the edge that writes. Required even where the
  // shadow is x: a stray write there would pass check_memory
  task automatic check_write;
    check("m_write", {7'b0, dut.m_write}, {7'b0, w});
    if (w) begin
      check("m_addr",  dut.m_addr,  w_addr);
      check("m_wdata", dut.m_wdata, w_data);
    end
  endtask

  // Names the address only on a mismatch: $sformatf on every byte of every
  // step costs more than the rest of the bench
  task automatic check_memory;
    for (int i = 0; i < 256; i++)
      if (!agrees(dut.u_m.mem[i], shadow[i]))
        check($sformatf("M[%h]", 8'(i)), dut.u_m.mem[i], shadow[i]);
  endtask

  initial begin
    logic       done;
    int         n;
    logic [7:0] err_pc, err_op;
    reg [8*80-1:0] err_msg;

    errors = 0;
    step = 0;
    end_kind = "";

    if (!$value$plusargs("hex=%s", hex_file) || !$value$plusargs("trace=%s", trace_file))
      $fatal(1, "Usage: +hex=<program.hex> +trace=<trace file> [+end=HALT|ERROR|LIMIT]");
    if (!$value$plusargs("end=%s", exp_end)) exp_end = "HALT";

    // White-box load: PM's own HexFile stays ""
    $readmemh(hex_file, dut.u_pm.mem);
    fd = $fopen(trace_file, "r");
    if (fd == 0) $fatal(1, "Can't open %s", trace_file);
    for (int i = 0; i < 256; i++) shadow[i] = 'x;

    // Reset from power-up; M must never be written meanwhile
    repeat (ResetEdges) begin
      @(negedge clk_i);
      check("m_write during rst_i", {7'b0, dut.m_write}, 8'h00);
    end
    rst_i = 0;

    // State after reset
    n = $fscanf(fd, "%s", tag);
    if (n != 1 || tag != "R") $fatal(1, "%s: doesn't start with an R record", trace_file);
    read_record();
    check_state();

    // One record per instruction, one instruction per edge
    done = errors > 0;
    while (!done) begin
      n = $fscanf(fd, "%s", tag);
      if (n != 1) $fatal(1, "%s: ends without an END line", trace_file);

      if (tag == "S") begin
        read_record();
        step++;

        // Before the edge: the instruction fetched and the write it makes
        check("instr", dut.pm_rdata, op);
        check_write();

        // After the edge: the state it leaves
        @(negedge clk_i);
        check_state();
        if (w) shadow[w_addr] = w_data;
        check_memory();

        // Past the first divergence, every later step differs too
        if (errors > 0) done = 1;
      end else if (tag == "END") begin
        n = $fscanf(fd, "%s", end_kind);
        if (end_kind == "ERROR") begin
          n = $fscanf(fd, " %h %h", err_pc, err_op);
          // The message keeps its leading space and newline
          n = $fgets(err_msg, fd);
          if (err_msg[7:0] == "\n") err_msg = err_msg >> 8;
          $display("Emulator error at PC=%h (instr=%h):%0s", err_pc, err_op, err_msg);
        end
        done = 1;
      end else
        $fatal(1, "%s: unknown record tag %s after step %0d", trace_file, tag, step);
    end
    $fclose(fd);

    if (errors == 0 && end_kind != exp_end) begin
      errors++;
      $error("Trace ends in %s, expected %s", end_kind, exp_end);
    end

    // A halted core stays put: same state, no writes
    if (errors == 0 && end_kind == "HALT") begin
      w = 0;
      repeat (HaltEdges) begin
        step++;
        check_write();
        @(negedge clk_i);
        check_state();
        check_memory();
      end

      // Reset is synchronous: rst_i rising between edges changes nothing
      // before the edge, then the edge resets
      step++;
      rst_i = 1;
      #1;
      check_state();
      check("m_write during rst_i", {7'b0, dut.m_write}, 8'h00);
      @(negedge clk_i);
      // isa.md Reset: A, B, AR, F stay undefined
      { pc, s0, s1, s2, s3, d } = '0;
      { a, b, ar, f } = 'x;
      check_state();
      rst_i = 0;
    end

    if (errors == 0) begin
      $display("CORE TEST PASSED! %0s: %0d steps, END %0s", hex_file, step, end_kind);
    end else begin
      $fatal(1, "CORE TEST FAILED WITH %0d ERRORS! %0s", errors, hex_file);
    end
    $finish;
  end

endmodule
