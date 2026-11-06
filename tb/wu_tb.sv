/* ================= WU Testbench =================
 * White-box testbench of the working unit
 * ================================================
 */
module wu_tb;

  import tb_prefs::*;

  localparam logic [6:0] BIT_NOTHING          = 7'b0;
  localparam int         INDEX_WRITE_AB       = 0;
  localparam logic [6:0] BIT_WRITE_AB         = 7'b1 << INDEX_WRITE_AB;
  localparam int         INDEX_WRITE_AR       = 1;
  localparam logic [6:0] BIT_WRITE_AR         = 7'b1 << INDEX_WRITE_AR;
  localparam int         INDEX_DO_TAR         = 2;
  localparam logic [6:0] BIT_DO_TAR           = 7'b1 << INDEX_DO_TAR;
  localparam int         INDEX_LOAD           = 3;
  localparam logic [6:0] BIT_LOAD             = 7'b1 << INDEX_LOAD;
  localparam int         INDEX_STORE          = 4;
  localparam logic [6:0] BIT_STORE            = 7'b1 << INDEX_STORE;
  localparam int         INDEX_SIMPLE_LOAD    = 5;
  localparam logic [6:0] BIT_SIMPLE_LOAD      = 7'b1 << INDEX_SIMPLE_LOAD;
  localparam int         INDEX_SIMPLE_STORE   = 6;
  localparam logic [6:0] BIT_SIMPLE_STORE     = 7'b1 << INDEX_SIMPLE_STORE;

  localparam logic [7:0] DONT_CARE = 8'hxx;

  // Inputs
  logic [1:0][7:0] masks;
  logic [6:0] ctrl;
  logic [7:0] new_A, new_B, new_AR;
  logic       use_A;
  logic [3:0] simple_addr;
  logic [7:0] mem_val_in;
  logic       clk = 0, rst = 0;

  // Outputs
  logic [7:0] A, B, AR;
  logic [7:0] mem_val_out;
  logic [7:0] mem_addr;
  logic       mem_write;

  wu dut (
    .write_AB       (ctrl[INDEX_WRITE_AB]),
    .write_AR       (ctrl[INDEX_WRITE_AR]),
    .do_TAR         (ctrl[INDEX_DO_TAR]),
    .load           (ctrl[INDEX_LOAD]),
    .store          (ctrl[INDEX_STORE]),
    .simple_load    (ctrl[INDEX_SIMPLE_LOAD]),
    .simple_store   (ctrl[INDEX_SIMPLE_STORE]),
    .mask           (masks[0]),
    .mask_2         (masks[1]),
    .*
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  int errors;

  task automatic check_comb (
    input logic [7:0]       exp_val,
    input logic [7:0]       exp_addr,
    input logic             exp_write
  );
    if (exp_val !== DONT_CARE)
      assert (mem_val_out === exp_val) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("Expected mem_val_out=%h, got %h", exp_val, mem_val_out);
      end

    if (exp_addr !== DONT_CARE)
      assert (mem_addr === exp_addr) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("Expected mem_addr=%h, got %h", exp_addr, mem_addr);
      end

    assert (mem_write === exp_write) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("Expected mem_write=%h, got %h", exp_write, mem_write);
    end
  endtask

  task automatic check_seq (
    input logic [7:0]       exp_A,
    input logic [7:0]       exp_B,
    input logic [7:0]       exp_AR
  );
    assert (A === exp_A) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("Expected A=%h, got %h", exp_A, A);
    end

    assert (B === exp_B) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("Expected B=%h, got %h", exp_B, B);
    end

    assert (AR === exp_AR) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("Expected AR=%h, got %h", exp_AR, AR);
    end
  endtask

  task automatic step_check (
    input logic             reset,
    input logic [6:0]       control,
    input logic [7:0]       new_a,
    input logic [7:0]       new_b,
    input logic             use_a,
    input logic [7:0]       new_ar,
    input logic [1:0][7:0]  nmasks,
    input logic [3:0]       s_addr,
    input logic [7:0]       mem_val,
    input logic [7:0]       exp_val,
    input logic [7:0]       exp_addr,
    input logic             exp_write,
    input logic [7:0]       exp_A,
    input logic [7:0]       exp_B,
    input logic [7:0]       exp_AR
  );
    @(negedge clk);
    rst = reset;
    ctrl = control;
    new_A = new_a; new_B = new_b; new_AR = new_ar; use_A = use_a;
    masks = nmasks;
    simple_addr = s_addr;
    mem_val_in = mem_val;

    #1;
    check_comb(exp_val, exp_addr, exp_write);

    @(posedge clk);
    #1;
    check_seq(exp_A, exp_B, exp_AR);
  endtask

  task set_state (
    input logic [7:0] set_A,
    input logic [7:0] set_B,
    input logic [7:0] set_AR
  );
    force dut._A = set_A;
    force dut._B = set_B;
    force dut._AR = set_AR;

    #1;

    release dut._A;
    release dut._B;
    release dut._AR;
  endtask

  initial begin
    masks = '0;
    ctrl = '0;
    new_A = '0;
    new_B = '0;
    new_AR = '0;
    use_A = '0;
    simple_addr = '0;
    mem_val_in = '0;

    $display("WU TEST START.");
    errors = 0;

    $display("Testing startup reset");
    step_check(
      /* .reset     */ ('1),
      /* .control   */ (BIT_NOTHING),
      /* .new_a     */ ('1),
      /* .new_b     */ ('1),
      /* .use_a     */ ('0),
      /* .new_ar    */ ('1),
      /* .nmasks    */ ('1),
      /* .s_addr    */ ('1),
      /* .mem_val   */ ('1),
      /* .exp_val   */ (DONT_CARE),
      /* .exp_addr  */ (DONT_CARE),
      /* .exp_write */ ('0),
      /* .exp_A     */ ('0),
      /* .exp_B     */ ('0),
      /* .exp_AR    */ ('0)
    );

    $display("Testing reset from dirty state");
    for (int a = 0; a < 256; a+=16) begin
      for (int b = 0; b < 256; b+=16) begin
        for (int ar = 0; ar < 256; ar+=16) begin
          set_state(8'(a), 8'(b), 8'(ar));
          step_check(
            /* .reset     */ ('1),
            /* .control   */ (BIT_NOTHING),
            /* .new_a     */ ('1),
            /* .new_b     */ ('1),
            /* .use_a     */ ('0),
            /* .new_ar    */ ('1),
            /* .nmasks    */ ('1),
            /* .s_addr    */ ('1),
            /* .mem_val   */ ('1),
            /* .exp_val   */ (DONT_CARE),
            /* .exp_addr  */ (DONT_CARE),
            /* .exp_write */ ('0),
            /* .exp_A     */ ('0),
            /* .exp_B     */ ('0),
            /* .exp_AR    */ ('0)
          );
        end
      end
    end

    $display("Testing writes");
    for (int m = 0; m <= 2; m++) begin
      logic test_masks;
      test_masks = (m >= 1);

      if (test_masks) $display("Testing writes - masks"); else $display("Testing writes - values");
      
      for (int s = 0; s < 4; s++) begin
        for (int x = 0; x < 256; x++) begin
          for (int y = 0; y < ((s == 0) ? 256 : 1); y++) begin
            logic test_a, test_b, test_ar;
            logic [7:0] a, b, ar, s_a, s_b, s_ar;

            test_a  = (s == 0 | s === 1);
            test_b  = (s == 0 | s === 2);
            test_ar = (s == 3);

            a = test_a ? 8'(x) : 8'd0;
            b = test_b ? ((s == 0) ? 8'(y) : 8'(x)) : 8'd0;
            ar = 8'(x);
            
            if (m == 0) { s_a, s_b, s_ar } = { 8'(~x + 2), 8'(~x + 4), 8'(~x + 8) };
            if (m == 1) { s_a, s_b, s_ar } = '0;
            if (m == 2) { s_a, s_b, s_ar } = '1;
            set_state(s_a, s_b, s_ar);

            step_check(
              /* .reset     */ ('0),
              /* .control   */ (test_ar ? BIT_WRITE_AR : BIT_WRITE_AB),
              /* .new_a     */ (test_masks ? ~dut._A  : 8'(a)),
              /* .new_b     */ (test_masks ? ~dut._B  : 8'(b)),
              /* .use_a     */ ('1),
              /* .new_ar    */ (test_masks ? ~dut._AR : 8'(ar)),
              /* .nmasks    */ (test_masks
                                  ? { (test_b ? b : '0), (test_a ? a : (test_ar ? ar : '0)) }
                                  : { (test_b ? 8'hFF : '0), ((test_a || test_ar) ? 8'hFF : '0) }),
              /* .s_addr    */ ('1),
              /* .mem_val   */ ('1),
              /* .exp_val   */ (DONT_CARE),
              /* .exp_addr  */ (DONT_CARE),
              /* .exp_write */ ('0),
              /* .exp_A     */ (test_a  ? ((m == 2) ? ~a  : a ) : s_a),
              /* .exp_B     */ (test_b  ? ((m == 2) ? ~b  : b ) : s_b),
              /* .exp_AR    */ (test_ar ? ((m == 2) ? ~ar : ar) : s_ar)
            );
          end
        end
      end
    end

    $display("Testing stores");
    for (int s = 0; s < 2; s++) begin
      for (int u = 0; u <= 1; u++) begin
        for (int m = 0; m <= 1; m++) begin
          for (int x = 0; x < 256; x++) begin
            logic test_simple, test_use_a;
            logic [7:0] s_a, s_b, s_ar, val;
            logic [3:0] addr;

            test_simple = (s == 1);
            test_use_a  = (u == 1);

            s_a  = 8'(x);
            s_b  = 8'(~x + 2);
            s_ar = 8'(x + 2);
            addr = 4'(x + 9);

            val = test_use_a ? s_a : s_b;

            set_state(s_a, s_b, s_ar);
            step_check(
              /* .reset     */ ('0),
              /* .control   */ (test_simple ? BIT_SIMPLE_STORE : BIT_STORE),
              /* .new_a     */ (~s_a),
              /* .new_b     */ (~s_b),
              /* .use_a     */ (test_use_a),
              /* .new_ar    */ (~s_ar),
              /* .nmasks    */ ((m == 1) ? 16'hFFFF : 16'h0000),
              /* .s_addr    */ (addr),
              /* .mem_val   */ (~val),
              /* .exp_val   */ (val),
              /* .exp_addr  */ (test_simple ? { 4'h0, addr } : s_ar),
              /* .exp_write */ ('1),
              /* .exp_A     */ (s_a),
              /* .exp_B     */ (s_b),
              /* .exp_AR    */ (s_ar)
            );
          end
        end
      end
    end

    $display("Testing loads");
    for (int s = 0; s < 2; s++) begin
      for (int u = 0; u <= 1; u++) begin
        for (int m = 0; m <= 1; m++) begin
          for (int x = 0; x < 256; x++) begin
            logic test_simple, test_use_a;
            logic [7:0] s_a, s_b, s_ar, val;
            logic [3:0] addr;

            test_simple = (s == 1);
            test_use_a  = (u == 1);

            s_a  = 8'(x);
            s_b  = 8'(~x + 2);
            s_ar = 8'(x + 2);
            addr = 4'(x + 9);

            val = 8'(x + 4);

            set_state(s_a, s_b, s_ar);
            step_check(
              /* .reset     */ ('0),
              /* .control   */ (test_simple ? BIT_SIMPLE_LOAD : BIT_LOAD),
              /* .new_a     */ (~s_a),
              /* .new_b     */ (~s_b),
              /* .use_a     */ (test_use_a),
              /* .new_ar    */ (~s_ar),
              /* .nmasks    */ ((m == 1) ? 16'hFFFF : 16'h0000),
              /* .s_addr    */ (addr),
              /* .mem_val   */ (val),
              /* .exp_val   */ (DONT_CARE),
              /* .exp_addr  */ (test_simple ? { 4'h0, addr } : s_ar),
              /* .exp_write */ ('0),
              /* .exp_A     */ (test_use_a ? val : s_a),
              /* .exp_B     */ (test_use_a ? s_b : val),
              /* .exp_AR    */ (s_ar)
            );
          end
        end
      end
    end

    $display("Testing TAR");
    for (int u = 0; u <= 1; u++) begin
      for (int m = 0; m <= 1; m++) begin
        for (int x = 0; x < 256; x++) begin
          logic [7:0] s_a, s_b, s_ar;

          s_a  = 8'(x);
          s_b  = 8'(~x + 2);
          s_ar = 8'(x + 2);

          set_state(s_a, s_b, s_ar);
          step_check(
            /* .reset     */ ('0),
            /* .control   */ (BIT_DO_TAR),
            /* .new_a     */ (~s_a),
            /* .new_b     */ (~s_b),
            /* .use_a     */ (u == 1),
            /* .new_ar    */ (~s_ar),
            /* .nmasks    */ ((m == 1) ? 16'hFFFF : 16'h0000),
            /* .s_addr    */ (4'(x + 9)),
            /* .mem_val   */ (8'(x + 4)),
            /* .exp_val   */ (DONT_CARE),
            /* .exp_addr  */ (DONT_CARE),
            /* .exp_write */ ('0),
            /* .exp_A     */ (s_a),
            /* .exp_B     */ (s_b),
            /* .exp_AR    */ (s_a)
          );
        end
      end
    end

    $display("Testing nothing selected");
    for (int u = 0; u <= 1; u++) begin
      for (int m = 0; m <= 1; m++) begin
        for (int x = 0; x < 256; x++) begin
          logic [7:0] s_a, s_b, s_ar;

          s_a  = 8'(x);
          s_b  = 8'(~x + 2);
          s_ar = 8'(x + 2);

          set_state(s_a, s_b, s_ar);
          step_check(
            /* .reset     */ ('0),
            /* .control   */ (BIT_NOTHING),
            /* .new_a     */ (~s_a),
            /* .new_b     */ (~s_b),
            /* .use_a     */ (u == 1),
            /* .new_ar    */ (~s_ar),
            /* .nmasks    */ ((m == 1) ? 16'hFFFF : 16'h0000),
            /* .s_addr    */ (4'(x + 9)),
            /* .mem_val   */ (8'(x + 4)),
            /* .exp_val   */ (DONT_CARE),
            /* .exp_addr  */ (DONT_CARE),
            /* .exp_write */ ('0),
            /* .exp_A     */ (s_a),
            /* .exp_B     */ (s_b),
            /* .exp_AR    */ (s_ar)
          );
        end
      end
    end

    $display("Testing disallowed combinations");
    for (int c = 0; c < 128; c++) begin
      for (int u = 0; u <= 1; u++) begin
        // Two or more control bits set
        if ((c & (c - 1)) != 0) begin
          set_state(8'hAB, 8'hCD, 8'h12);
          step_check(
            /* .reset     */ ('0),
            /* .control   */ (7'(c)),
            /* .new_a     */ (8'h54),
            /* .new_b     */ (8'h32),
            /* .use_a     */ (u == 1),
            /* .new_ar    */ (8'hED),
            /* .nmasks    */ ('1),
            /* .s_addr    */ (4'h9),
            /* .mem_val   */ (8'h77),
            /* .exp_val   */ ('0),
            /* .exp_addr  */ ('0),
            /* .exp_write */ ('0),
            /* .exp_A     */ ('x),
            /* .exp_B     */ ('x),
            /* .exp_AR    */ ('x)
          );
        end
      end
    end

    $display("Testing reset override");
    for (int c = 0; c < 128; c++) begin
      for (int u = 0; u <= 1; u++) begin
        set_state(8'hAB, 8'hCD, 8'h12);
        step_check(
          /* .reset     */ ('1),
          /* .control   */ (7'(c)),
          /* .new_a     */ (8'h54),
          /* .new_b     */ (8'h32),
          /* .use_a     */ (u == 1),
          /* .new_ar    */ (8'hED),
          /* .nmasks    */ ('1),
          /* .s_addr    */ (4'h9),
          /* .mem_val   */ (8'h77),
          /* .exp_val   */ (DONT_CARE),
          /* .exp_addr  */ (DONT_CARE),
          /* .exp_write */ ('0),
          /* .exp_A     */ ('0),
          /* .exp_B     */ ('0),
          /* .exp_AR    */ ('0)
        );
      end
    end

    if (errors == 0) begin
      $display("WU TEST PASSED!");
      $finish;
    end
    else
      $fatal(1, "WU TEST FAILED WITH %0d ERRORS!", errors);

  end

endmodule
