/* ================= RU Testbench =================
 * White-box testbench of the running unit
 * ================================================
 */
module ru_tb;

  import tb_prefs::*;

  localparam logic [4:0] BitNothing   = 5'b0;
  localparam int         IndexJmp     = 4;
  localparam logic [4:0] BitJmp       = 5'b1 << IndexJmp;
  localparam int         IndexJmpCond = 3;
  localparam logic [4:0] BitJmpCond   = 5'b1 << IndexJmpCond;
  localparam int         IndexCall    = 2;
  localparam logic [4:0] BitCall      = 5'b1 << IndexCall;
  localparam int         IndexRet     = 1;
  localparam logic [4:0] BitRet       = 5'b1 << IndexRet;
  localparam int         IndexWriteF  = 0;
  localparam logic [4:0] BitWriteF    = 5'b1 << IndexWriteF;

  // Inputs
  logic [4:0] ctrl;
  logic new_f_i = '0;
  logic clk_i = 0, rst_i = 0;

  // Outputs
  logic [7:0] pc_o, ar_i = '0;
  logic f_o;

  ru dut (
    .jmp_i      (ctrl[IndexJmp]),
    .jmp_cond_i (ctrl[IndexJmpCond]),
    .call_i     (ctrl[IndexCall]),
    .ret_i      (ctrl[IndexRet]),
    .write_f_i  (ctrl[IndexWriteF]),
    .*
  );

  initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i;
  end

  int errors;

  task automatic step (
    input logic             reset,
    input logic [4:0]       control,
    input logic [7:0]       address,
    input logic             new_f
  );
    @(negedge clk_i);
    rst_i = reset;
    ctrl = control;
    new_f_i = new_f;
    ar_i = address;

    @(posedge clk_i);
    #1;
  endtask

  task automatic check (
    input logic             exp_f,
    input logic [7:0]       exp_pc,
    input logic [3:0][7:0]  exp_s,
    input logic [2:0]       exp_d
  );
    assert (pc_o === exp_pc) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("Expected PC=%h, got %h", exp_pc, pc_o);
    end

    assert (f_o === exp_f) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("Expected F=%b, got %b", exp_f, f_o);
    end

    assert (dut.s_q === exp_s) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("Expected S=%h, got %h", exp_s, dut.s_q);
    end

    assert (dut.d_q === exp_d) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("Expected D=%0d, got %0d", exp_d, dut.d_q);
    end
  endtask

  task automatic step_check (
    input logic             reset,
    input logic [4:0]       control,
    input logic [7:0]       address,
    input logic             new_f,
    input logic             exp_f,
    input logic [7:0]       exp_pc,
    input logic [3:0][7:0]  exp_s,
    input logic [2:0]       exp_d
  );
    step(reset, control, address, new_f);
    check(exp_f, exp_pc, exp_s, exp_d);
  endtask

  task automatic empty_step();
    step (
      /* .reset   */ ('0),
      /* .control */ (BitNothing),
      /* .address */ ('0),
      /* .new_f   */ ('0)
    );
  endtask

  task set_state (
    input logic             set_f,
    input logic [7:0]       set_pc,
    input logic [3:0][7:0]  set_s,
    input logic [2:0]       set_d
  );
    force dut.f_q = set_f;
    force dut.pc_q = set_pc;
    force dut.s_q = set_s;
    force dut.d_q = set_d;

    #1;

    release dut.f_q;
    release dut.pc_q;
    release dut.d_q;
    release dut.s_q;
  endtask

  task automatic step_set_state (
    input logic             set_f,
    input logic [7:0]       set_pc,
    input logic [3:0][7:0]  set_s,
    input logic [2:0]       set_d
  );
    empty_step();
    set_state(set_f, set_pc, set_s, set_d);
  endtask

  initial begin
    $display("RU TEST START.");
    errors = 0;


    $display("Testing startup reset");
    step('1, BitNothing, '1, '1);
    check('0, '0, '0, '0);


    $display("Testing reset override");
    for (int d = 0; d <= 4; d++) begin
      for (int s = 0; s <= 1; s++) begin
        for (int f = 0; f <= 1; f++) begin
          for (int c = 0; c < 32; c++) begin
            // Positional arguments not supported by Icarus 12
            step_set_state(
              /* .set_f   */ (1'(f)),
              /* .set_pc  */ (8'hA5),
              /* .set_s   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_d   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('1),
              /* .control */ (5'(c)),
              /* .address */ (8'h5A),
              /* .new_f   */ (1'(~f)),
              /* .exp_f   */ ('0),
              /* .exp_pc  */ ('0),
              /* .exp_s   */ ('0),
              /* .exp_d   */ ('0)
            );
          end
        end
      end
    end


    $display("Testing nothing");
    for (int d = 0; d <= 4; d++) begin
      for (int s = 0; s <= 1; s++) begin
        for (int f = 0; f <= 1; f++) begin
          for (int i = 0; i < 256; i++) begin
            step_set_state(
              /* .set_f   */ (1'(f)),
              /* .set_pc  */ (8'(i)),
              /* .set_s   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_d   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BitNothing),
              /* .address */ (8'(~i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_f   */ (f_o),
              /* .exp_pc  */ (8'(i + 1)),
              /* .exp_s   */ (dut.s_q),
              /* .exp_d   */ (dut.d_q)
            );
          end
        end
      end
    end


    $display("Testing writing F");
    for (int d = 0; d <= 4; d++) begin
      for (int s = 0; s <= 1; s++) begin
        for (int f = 0; f <= 1; f++) begin
          for (int n = 0; n <= 1; n++) begin
            for (int i = 0; i < 256; i++) begin
              step_set_state(
                /* .set_f   */ (1'(f)),
                /* .set_pc  */ (8'(i)),
                /* .set_s   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
                /* .set_d   */ (3'(d))
              );

              step_check(
                /* .reset   */ ('0),
                /* .control */ (BitWriteF),
                /* .address */ (8'(~i)),
                /* .new_f   */ (1'(n)),
                /* .exp_f   */ (1'(n)),
                /* .exp_pc  */ (8'(i + 1)),
                /* .exp_s   */ (dut.s_q),
                /* .exp_d   */ (dut.d_q)
              );
            end
          end
        end
      end
    end


    $display("Testing unconditional jumping");
    for (int d = 0; d <= 4; d++) begin
      for (int s = 0; s <= 1; s++) begin
        for (int f = 0; f <= 1; f++) begin
          for (int i = 0; i < 256; i++) begin
            step_set_state(
              /* .set_f   */ (1'(f)),
              /* .set_pc  */ (8'(~i)),
              /* .set_s   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_d   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BitJmp),
              /* .address */ (8'(i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_f   */ (f_o),
              /* .exp_pc  */ (8'(i)),
              /* .exp_s   */ (dut.s_q),
              /* .exp_d   */ (dut.d_q)
            );
          end
        end
      end
    end

    $display("Testing conditional jumping");
    for (int d = 0; d <= 4; d++) begin
      for (int s = 0; s <= 1; s++) begin
        for (int f = 0; f <= 1; f++) begin
          for (int i = 0; i < 256; i++) begin
            step_set_state(
              /* .set_f   */ (1'(f)),
              /* .set_pc  */ (8'(~i)),
              /* .set_s   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_d   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BitJmp | BitJmpCond),
              /* .address */ (8'(i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_f   */ (f_o),
              /* .exp_pc  */ (1'(f) ? 8'(i) : (8'(~i + 1))),
              /* .exp_s   */ (dut.s_q),
              /* .exp_d   */ (dut.d_q)
            );
          end
        end
      end
    end


    $display("Testing calling");
    for (int d = 0; d <= 4; d++) begin
      for (int s = 0; s <= 1; s++) begin
        for (int f = 0; f <= 1; f++) begin
          for (int i = 0; i < 256; i++) begin
            step_set_state(
              /* .set_f   */ (1'(f)),
              /* .set_pc  */ (8'(~i)),
              /* .set_s   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_d   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BitCall),
              /* .address */ (8'(i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_f   */ (f_o),
              /* .exp_pc  */ (8'(i)),
              /* .exp_s   */ ({dut.s_q[2:0], 8'(~i + 1)}),      // Push semantics
              /* .exp_d   */ ((d == 4) ? 3'(d) : 3'(d + 1))   // Increase till 4
            );
          end
        end
      end
    end


    $display("Testing returning");
    for (int d = 0; d <= 4; d++) begin
      for (int s = 0; s <= 1; s++) begin
        for (int f = 0; f <= 1; f++) begin
          for (int i = 0; i < 256; i++) begin
            step_set_state(
              /* .set_f   */ (1'(f)),
              /* .set_pc  */ (8'(~i)),
              /* .set_s   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_d   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BitRet),
              /* .address */ (8'(i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_f   */ (f_o),
              /* .exp_pc  */ ((d == 0) ? 8'(~i + 1) : dut.s_q[0]),
              /* .exp_s   */ ((d == 0) ? dut.s_q : {8'h00, dut.s_q[3:1]}),  // Pop semantics
              /* .exp_d   */ ((d == 0) ? 3'(d) : 3'(d - 1))             // Decrease till zero
            );
          end
        end
      end
    end


    $display("Testing disallowed combinations");
    for (int d = 0; d <= 4; d++) begin
      for (int s = 0; s <= 1; s++) begin
        for (int f = 0; f <= 1; f++) begin
          for (int c = 0; c < 32; c++) begin
            if (
              5'(c) != BitNothing &&
              5'(c) != BitJmp &&
              5'(c) != (BitJmp | BitJmpCond) &&
              5'(c) != BitCall &&
              5'(c) != BitRet &&
              5'(c) != BitWriteF
            ) begin
              step_set_state(
                /* .set_f   */ (1'(f)),
                /* .set_pc  */ (8'hA5),
                /* .set_s   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
                /* .set_d   */ (3'(d))
              );

              step_check(
                /* .reset   */ ('0),
                /* .control */ (5'(c)),
                /* .address */ (8'h5A),
                /* .new_f   */ (1'(~f)),
                /* .exp_f   */ ('x),
                /* .exp_pc  */ ('x),
                /* .exp_s   */ ('x),
                /* .exp_d   */ ('x)
              );
            end
          end
        end
      end
    end

    if (errors == 0) begin
      $display("RU TEST PASSED!");
      $finish;
    end
    else
      $fatal(1, "RU TEST FAILED WITH %0d ERRORS!", errors);

  end

endmodule
