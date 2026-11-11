/* ================= WU Testbench =================
 * White-box testbench of the working unit
 * ================================================
 */
module wu_tb;

  import tb_prefs::*;

  localparam logic [6:0] BitNothing       = 7'b0;
  localparam int         IndexWriteAb     = 0;
  localparam logic [6:0] BitWriteAb       = 7'b1 << IndexWriteAb;
  localparam int         IndexWriteAr     = 1;
  localparam logic [6:0] BitWriteAr       = 7'b1 << IndexWriteAr;
  localparam int         IndexDoTar       = 2;
  localparam logic [6:0] BitDoTar         = 7'b1 << IndexDoTar;
  localparam int         IndexLoad        = 3;
  localparam logic [6:0] BitLoad          = 7'b1 << IndexLoad;
  localparam int         IndexStore       = 4;
  localparam logic [6:0] BitStore         = 7'b1 << IndexStore;
  localparam int         IndexSimpleLoad  = 5;
  localparam logic [6:0] BitSimpleLoad    = 7'b1 << IndexSimpleLoad;
  localparam int         IndexSimpleStore = 6;
  localparam logic [6:0] BitSimpleStore   = 7'b1 << IndexSimpleStore;

  localparam logic [7:0] DontCare = 8'hxx;

  // Inputs
  logic [1:0][7:0] masks;
  logic [6:0] ctrl;
  logic [7:0] new_a_i, new_b_i, new_ar_i;
  logic       use_a_i;
  logic [3:0] simple_addr_i;
  logic [7:0] mem_rdata_i;
  logic       clk_i = 0, rst_i = 0;

  // Outputs
  logic [7:0] a_o, b_o, ar_o;
  logic [7:0] mem_wdata_o;
  logic [7:0] mem_addr_o;
  logic       mem_write_o;

  wu dut (
    .write_ab_i     (ctrl[IndexWriteAb]),
    .write_ar_i     (ctrl[IndexWriteAr]),
    .do_tar_i       (ctrl[IndexDoTar]),
    .load_i         (ctrl[IndexLoad]),
    .store_i        (ctrl[IndexStore]),
    .simple_load_i  (ctrl[IndexSimpleLoad]),
    .simple_store_i (ctrl[IndexSimpleStore]),
    .mask_a_i       (masks[0]),
    .mask_b_i       (masks[1]),
    .*
  );

  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
  end

  int errors;

  task automatic check_comb (
    input logic [7:0]       exp_val,
    input logic [7:0]       exp_addr,
    input logic             exp_write
  );
    if (exp_val !== DontCare)
      assert (mem_wdata_o === exp_val) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("Expected mem_wdata_o=%h, got %h", exp_val, mem_wdata_o);
      end

    if (exp_addr !== DontCare)
      assert (mem_addr_o === exp_addr) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("Expected mem_addr_o=%h, got %h", exp_addr, mem_addr_o);
      end

    assert (mem_write_o === exp_write) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("Expected mem_write_o=%h, got %h", exp_write, mem_write_o);
    end
  endtask

  task automatic check_seq (
    input logic [7:0]       exp_a,
    input logic [7:0]       exp_b,
    input logic [7:0]       exp_ar
  );
    assert (a_o === exp_a) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("Expected A=%h, got %h", exp_a, a_o);
    end

    assert (b_o === exp_b) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("Expected B=%h, got %h", exp_b, b_o);
    end

    assert (ar_o === exp_ar) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("Expected AR=%h, got %h", exp_ar, ar_o);
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
    input logic [7:0]       exp_a,
    input logic [7:0]       exp_b,
    input logic [7:0]       exp_ar
  );
    @(negedge clk_i);
    rst_i = reset;
    ctrl = control;
    new_a_i = new_a; new_b_i = new_b; new_ar_i = new_ar; use_a_i = use_a;
    masks = nmasks;
    simple_addr_i = s_addr;
    mem_rdata_i = mem_val;

    #1;
    check_comb(exp_val, exp_addr, exp_write);

    @(posedge clk_i);
    #1;
    check_seq(exp_a, exp_b, exp_ar);
  endtask

  task set_state (
    input logic [7:0] set_a,
    input logic [7:0] set_b,
    input logic [7:0] set_ar
  );
    force dut.a_q = set_a;
    force dut.b_q = set_b;
    force dut.ar_q = set_ar;

    #1;

    release dut.a_q;
    release dut.b_q;
    release dut.ar_q;
  endtask

  initial begin
    masks = '0;
    ctrl = '0;
    new_a_i = '0;
    new_b_i = '0;
    new_ar_i = '0;
    use_a_i = '0;
    simple_addr_i = '0;
    mem_rdata_i = '0;

    $display("WU TEST START.");
    errors = 0;

    $display("Testing startup reset");
    step_check(
      /* .reset     */ ('1),
      /* .control   */ (BitNothing),
      /* .new_a     */ ('1),
      /* .new_b     */ ('1),
      /* .use_a     */ ('0),
      /* .new_ar    */ ('1),
      /* .nmasks    */ ('1),
      /* .s_addr    */ ('1),
      /* .mem_val   */ ('1),
      /* .exp_val   */ (DontCare),
      /* .exp_addr  */ (DontCare),
      /* .exp_write */ ('0),
      /* .exp_a     */ ('0),
      /* .exp_b     */ ('0),
      /* .exp_ar    */ ('0)
    );

    $display("Testing reset from dirty state");
    for (int a = 0; a < 256; a+=16) begin
      for (int b = 0; b < 256; b+=16) begin
        for (int ar = 0; ar < 256; ar+=16) begin
          set_state(8'(a), 8'(b), 8'(ar));
          step_check(
            /* .reset     */ ('1),
            /* .control   */ (BitNothing),
            /* .new_a     */ ('1),
            /* .new_b     */ ('1),
            /* .use_a     */ ('0),
            /* .new_ar    */ ('1),
            /* .nmasks    */ ('1),
            /* .s_addr    */ ('1),
            /* .mem_val   */ ('1),
            /* .exp_val   */ (DontCare),
            /* .exp_addr  */ (DontCare),
            /* .exp_write */ ('0),
            /* .exp_a     */ ('0),
            /* .exp_b     */ ('0),
            /* .exp_ar    */ ('0)
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
              /* .control   */ (test_ar ? BitWriteAr : BitWriteAb),
              /* .new_a     */ (test_masks ? ~dut.a_q  : 8'(a)),
              /* .new_b     */ (test_masks ? ~dut.b_q  : 8'(b)),
              /* .use_a     */ ('1),
              /* .new_ar    */ (test_masks ? ~dut.ar_q : 8'(ar)),
              /* .nmasks    */ (test_masks
                                  ? { (test_b ? b : '0), (test_a ? a : (test_ar ? ar : '0)) }
                                  : { (test_b ? 8'hFF : '0), ((test_a || test_ar) ? 8'hFF : '0) }),
              /* .s_addr    */ ('1),
              /* .mem_val   */ ('1),
              /* .exp_val   */ (DontCare),
              /* .exp_addr  */ (DontCare),
              /* .exp_write */ ('0),
              /* .exp_a     */ (test_a  ? ((m == 2) ? ~a  : a ) : s_a),
              /* .exp_b     */ (test_b  ? ((m == 2) ? ~b  : b ) : s_b),
              /* .exp_ar    */ (test_ar ? ((m == 2) ? ~ar : ar) : s_ar)
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
              /* .control   */ (test_simple ? BitSimpleStore : BitStore),
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
              /* .exp_a     */ (s_a),
              /* .exp_b     */ (s_b),
              /* .exp_ar    */ (s_ar)
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
              /* .control   */ (test_simple ? BitSimpleLoad : BitLoad),
              /* .new_a     */ (~s_a),
              /* .new_b     */ (~s_b),
              /* .use_a     */ (test_use_a),
              /* .new_ar    */ (~s_ar),
              /* .nmasks    */ ((m == 1) ? 16'hFFFF : 16'h0000),
              /* .s_addr    */ (addr),
              /* .mem_val   */ (val),
              /* .exp_val   */ (DontCare),
              /* .exp_addr  */ (test_simple ? { 4'h0, addr } : s_ar),
              /* .exp_write */ ('0),
              /* .exp_a     */ (test_use_a ? val : s_a),
              /* .exp_b     */ (test_use_a ? s_b : val),
              /* .exp_ar    */ (s_ar)
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
            /* .control   */ (BitDoTar),
            /* .new_a     */ (~s_a),
            /* .new_b     */ (~s_b),
            /* .use_a     */ (u == 1),
            /* .new_ar    */ (~s_ar),
            /* .nmasks    */ ((m == 1) ? 16'hFFFF : 16'h0000),
            /* .s_addr    */ (4'(x + 9)),
            /* .mem_val   */ (8'(x + 4)),
            /* .exp_val   */ (DontCare),
            /* .exp_addr  */ (DontCare),
            /* .exp_write */ ('0),
            /* .exp_a     */ (s_a),
            /* .exp_b     */ (s_b),
            /* .exp_ar    */ (s_a)
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
            /* .control   */ (BitNothing),
            /* .new_a     */ (~s_a),
            /* .new_b     */ (~s_b),
            /* .use_a     */ (u == 1),
            /* .new_ar    */ (~s_ar),
            /* .nmasks    */ ((m == 1) ? 16'hFFFF : 16'h0000),
            /* .s_addr    */ (4'(x + 9)),
            /* .mem_val   */ (8'(x + 4)),
            /* .exp_val   */ (DontCare),
            /* .exp_addr  */ (DontCare),
            /* .exp_write */ ('0),
            /* .exp_a     */ (s_a),
            /* .exp_b     */ (s_b),
            /* .exp_ar    */ (s_ar)
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
            /* .exp_a     */ ('x),
            /* .exp_b     */ ('x),
            /* .exp_ar    */ ('x)
          );
        end
      end
    end

    $display("Testing unknown control bits");
    for (int i = 0; i < 7; i++) begin
      for (int z = 0; z <= 1; z++) begin
        // Unknown bit on top of nothing, then on top of each single command
        for (int base = -1; base < 7; base++) begin
          logic [6:0] control;

          control = (base < 0) ? BitNothing : 7'b1 << base;
          control[i] = (z == 1) ? 1'bz : 1'bx;

          set_state(8'hAB, 8'hCD, 8'h12);
          step_check(
            /* .reset     */ ('0),
            /* .control   */ (control),
            /* .new_a     */ (8'h54),
            /* .new_b     */ (8'h32),
            /* .use_a     */ ('1),
            /* .new_ar    */ (8'hED),
            /* .nmasks    */ ('1),
            /* .s_addr    */ (4'h9),
            /* .mem_val   */ (8'h77),
            /* .exp_val   */ (DontCare),
            /* .exp_addr  */ (DontCare),
            /* .exp_write */ ('x),
            /* .exp_a     */ ('x),
            /* .exp_b     */ ('x),
            /* .exp_ar    */ ('x)
          );

          // An expected x is DontCare to check_comb, so check these here
          assert (mem_wdata_o === 'x && mem_addr_o === 'x) else begin
            errors++;
            if (errors <= ErrorsCap)
              $error("Expected mem_wdata_o=xx mem_addr_o=xx, got %h %h", mem_wdata_o, mem_addr_o);
          end
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
          /* .exp_val   */ (DontCare),
          /* .exp_addr  */ (DontCare),
          /* .exp_write */ ('0),
          /* .exp_a     */ ('0),
          /* .exp_b     */ ('0),
          /* .exp_ar    */ ('0)
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
