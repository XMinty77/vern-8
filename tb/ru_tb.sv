/* ================= RU Testbench =================
 * White-box testbench of the running unit
 * ================================================
 */
module ru_tb;

  import tb_prefs::*;

  localparam logic [4:0] BIT_NOTHING    = 5'b0;
  localparam int         INDEX_JMP      = 4;
  localparam logic [4:0] BIT_JMP        = 5'b1 << INDEX_JMP;
  localparam int         INDEX_JMP_COND = 3;
  localparam logic [4:0] BIT_JMP_COND   = 5'b1 << INDEX_JMP_COND;
  localparam int         INDEX_CALL     = 2;
  localparam logic [4:0] BIT_CALL       = 5'b1 << INDEX_CALL;
  localparam int         INDEX_RET      = 1;
  localparam logic [4:0] BIT_RET        = 5'b1 << INDEX_RET;
  localparam int         INDEX_WRITE_F  = 0;
  localparam logic [4:0] BIT_WRITE_F    = 5'b1 << INDEX_WRITE_F;

  // Inputs
  logic [4:0] ctrl;
  logic new_F = '0;
  logic clk = 0, rst = 0;

  // Outputs
  logic [7:0] PC, AR = '0;
  logic F;

  ru dut (
    .jmp      (ctrl[INDEX_JMP]),
    .jmp_cond (ctrl[INDEX_JMP_COND]),
    .call     (ctrl[INDEX_CALL]),
    .ret      (ctrl[INDEX_RET]),
    .write_F  (ctrl[INDEX_WRITE_F]),
    .*
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  int errors;

  task automatic step (
    input logic             reset,
    input logic [4:0]       control,
    input logic [7:0]       address,
    input logic             new_f
  );
    @(negedge clk);
    rst = reset;
    ctrl = control;
    new_F = new_f;
    AR = address;

    @(posedge clk);
    #1;
  endtask

  task automatic check (
    input logic             exp_F,
    input logic [7:0]       exp_PC,
    input logic [3:0][7:0]  exp_S,
    input logic [2:0]       exp_D
  );
    assert (PC === exp_PC) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("Expected PC=%h, got %h", exp_PC, PC);
    end

    assert (F === exp_F) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("Expected F=%b, got %b", exp_F, F);
    end

    assert (dut.S === exp_S) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("Expected S=%h, got %h", exp_S, dut.S);
    end

    assert (dut.D === exp_D) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("Expected D=%0d, got %0d", exp_D, dut.D);
    end
  endtask

  task automatic step_check (
    input logic             reset,
    input logic [4:0]       control,
    input logic [7:0]       address,
    input logic             new_f,
    input logic             exp_F,
    input logic [7:0]       exp_PC,
    input logic [3:0][7:0]  exp_S,
    input logic [2:0]       exp_D
  );
    step(reset, control, address, new_f);
    check(exp_F, exp_PC, exp_S, exp_D);
  endtask

  task automatic empty_step();
    step (
      /* .reset   */ ('0),
      /* .control */ (BIT_NOTHING),
      /* .address */ ('0),
      /* .new_f   */ ('0)
    );
  endtask

  task set_state (
    input logic             set_F,
    input logic [7:0]       set_PC,
    input logic [3:0][7:0]  set_S,
    input logic [2:0]       set_D
  );
    force dut._F = set_F;
    force dut._PC = set_PC;
    force dut.S = set_S;
    force dut.D = set_D;

    #1;

    release dut._F;
    release dut._PC;
    release dut.D;
    release dut.S;
  endtask

  task automatic step_set_state (
    input logic             set_F,
    input logic [7:0]       set_PC,
    input logic [3:0][7:0]  set_S,
    input logic [2:0]       set_D
  );
    empty_step();
    set_state(set_F, set_PC, set_S, set_D);
  endtask

  initial begin
    $display("RU TEST START.");
    errors = 0;


    $display("Testing startup reset");
    step('1, BIT_NOTHING, '1, '1);
    check('0, '0, '0, '0);


    $display("Testing reset override");
    for (int d = 0; d <= 4; d++) begin
      for (int s = 0; s <= 1; s++) begin
        for (int f = 0; f <= 1; f++) begin
          for (int c = 0; c < 32; c++) begin
            // Positional arguments not supported by Icarus 12
            step_set_state(
              /* .set_F   */ (1'(f)),
              /* .set_PC  */ (8'hA5),
              /* .set_S   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_D   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('1),
              /* .control */ (5'(c)),
              /* .address */ (8'h5A),
              /* .new_f   */ (1'(~f)),
              /* .exp_F   */ ('0),
              /* .exp_PC  */ ('0),
              /* .exp_S   */ ('0),
              /* .exp_D   */ ('0)
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
              /* .set_F   */ (1'(f)),
              /* .set_PC  */ (8'(i)),
              /* .set_S   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_D   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BIT_NOTHING),
              /* .address */ (8'(~i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_F   */ (F),
              /* .exp_PC  */ (8'(i + 1)),
              /* .exp_S   */ (dut.S),
              /* .exp_D   */ (dut.D)
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
                /* .set_F   */ (1'(f)),
                /* .set_PC  */ (8'(i)),
                /* .set_S   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
                /* .set_D   */ (3'(d))
              );

              step_check(
                /* .reset   */ ('0),
                /* .control */ (BIT_WRITE_F),
                /* .address */ (8'(~i)),
                /* .new_f   */ (1'(n)),
                /* .exp_F   */ (1'(n)),
                /* .exp_PC  */ (8'(i + 1)),
                /* .exp_S   */ (dut.S),
                /* .exp_D   */ (dut.D)
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
              /* .set_F   */ (1'(f)),
              /* .set_PC  */ (8'(~i)),
              /* .set_S   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_D   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BIT_JMP),
              /* .address */ (8'(i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_F   */ (F),
              /* .exp_PC  */ (8'(i)),
              /* .exp_S   */ (dut.S),
              /* .exp_D   */ (dut.D)
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
              /* .set_F   */ (1'(f)),
              /* .set_PC  */ (8'(~i)),
              /* .set_S   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_D   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BIT_JMP | BIT_JMP_COND),
              /* .address */ (8'(i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_F   */ (F),
              /* .exp_PC  */ (1'(f) ? 8'(i) : (8'(~i + 1))),
              /* .exp_S   */ (dut.S),
              /* .exp_D   */ (dut.D)
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
              /* .set_F   */ (1'(f)),
              /* .set_PC  */ (8'(~i)),
              /* .set_S   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_D   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BIT_CALL),
              /* .address */ (8'(i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_F   */ (F),
              /* .exp_PC  */ (8'(i)),
              /* .exp_S   */ ({dut.S[2:0], 8'(~i + 1)}),      // Push semantics
              /* .exp_D   */ ((d == 4) ? 3'(d) : 3'(d + 1))   // Increase till 4
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
              /* .set_F   */ (1'(f)),
              /* .set_PC  */ (8'(~i)),
              /* .set_S   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
              /* .set_D   */ (3'(d))
            );

            step_check(
              /* .reset   */ ('0),
              /* .control */ (BIT_RET),
              /* .address */ (8'(i)),
              /* .new_f   */ (1'(~f)),
              /* .exp_F   */ (F),
              /* .exp_PC  */ ((d == 0) ? 8'(~i + 1) : dut.S[0]),
              /* .exp_S   */ ((d == 0) ? dut.S : {8'h00, dut.S[3:1]}),  // Pop semantics
              /* .exp_D   */ ((d == 0) ? 3'(d) : 3'(d - 1))             // Decrease till zero
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
              5'(c) != BIT_NOTHING &&
              5'(c) != BIT_JMP &&
              5'(c) != (BIT_JMP | BIT_JMP_COND) &&
              5'(c) != BIT_CALL &&
              5'(c) != BIT_RET &&
              5'(c) != BIT_WRITE_F
            ) begin
              step_set_state(
                /* .set_F   */ (1'(f)),
                /* .set_PC  */ (8'hA5),
                /* .set_S   */ (1'(s) ? 32'h44_33_22_11 : 32'hBB_CC_DD_EE),
                /* .set_D   */ (3'(d))
              );

              step_check(
                /* .reset   */ ('0),
                /* .control */ (5'(c)),
                /* .address */ (8'h5A),
                /* .new_f   */ (1'(~f)),
                /* .exp_F   */ ('x),
                /* .exp_PC  */ ('x),
                /* .exp_S   */ ('x),
                /* .exp_D   */ ('x)
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
