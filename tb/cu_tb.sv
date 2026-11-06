/* ================= CU Testbench =================
 * Black box testbench of the control unit
 * ================================================
 */
module cu_tb;

  import opcodes::*;
  import tb_prefs::*;

  localparam logic [13:0] BIT_NOTHING            = 14'b0;
  localparam int          INDEX_RU_CS            = 0;
  localparam logic [13:0] BIT_RU_CS              = 14'b1 << INDEX_RU_CS;
  localparam int          INDEX_RU_JMP           = 1;
  localparam logic [13:0] BIT_RU_JMP             = 14'b1 << INDEX_RU_JMP;
  localparam int          INDEX_RU_JMP_COND      = 2;
  localparam logic [13:0] BIT_RU_JMP_COND        = 14'b1 << INDEX_RU_JMP_COND;
  localparam int          INDEX_RU_CALL          = 3;
  localparam logic [13:0] BIT_RU_CALL            = 14'b1 << INDEX_RU_CALL;
  localparam int          INDEX_RU_RET           = 4;
  localparam logic [13:0] BIT_RU_RET             = 14'b1 << INDEX_RU_RET;
  localparam int          INDEX_ALU_CS           = 5;
  localparam logic [13:0] BIT_ALU_CS             = 14'b1 << INDEX_ALU_CS;
  localparam int          INDEX_WU_CS            = 6;
  localparam logic [13:0] BIT_WU_CS              = 14'b1 << INDEX_WU_CS;
  localparam int          INDEX_WU_WRITE_AB      = 7;
  localparam logic [13:0] BIT_WU_WRITE_AB        = 14'b1 << INDEX_WU_WRITE_AB;
  localparam int          INDEX_WU_WRITE_AR      = 8;
  localparam logic [13:0] BIT_WU_WRITE_AR        = 14'b1 << INDEX_WU_WRITE_AR;
  localparam int          INDEX_WU_DO_TAR        = 9;
  localparam logic [13:0] BIT_WU_DO_TAR          = 14'b1 << INDEX_WU_DO_TAR;
  localparam int          INDEX_WU_LOAD          = 10;
  localparam logic [13:0] BIT_WU_LOAD            = 14'b1 << INDEX_WU_LOAD;
  localparam int          INDEX_WU_STORE         = 11;
  localparam logic [13:0] BIT_WU_STORE           = 14'b1 << INDEX_WU_STORE;
  localparam int          INDEX_WU_SIMPLE_LOAD   = 12;
  localparam logic [13:0] BIT_WU_SIMPLE_LOAD     = 14'b1 << INDEX_WU_SIMPLE_LOAD;
  localparam int          INDEX_WU_SIMPLE_STORE  = 13;
  localparam logic [13:0] BIT_WU_SIMPLE_STORE    = 14'b1 << INDEX_WU_SIMPLE_STORE;

  localparam logic [7:0] DONT_CARE   = 8'hxx;
  localparam logic [3:0] DONT_CARE_4 = 4'hx;
  localparam logic       DONT_CARE_1 = 1'bx;

  // Inputs
  logic [7:0] instr;

  // Outputs
  logic [13:0] ctrl;
  logic [7:0]  alu_opcode;
  logic [7:0]  wu_new_A, wu_new_B, wu_new_AR;
  logic        wu_use_A;
  logic [7:0]  wu_mask, wu_mask_2;
  logic [3:0]  wu_simple_addr;

  cu dut (
    .ru_cs           (ctrl[INDEX_RU_CS]),
    .ru_jmp          (ctrl[INDEX_RU_JMP]),
    .ru_jmp_cond     (ctrl[INDEX_RU_JMP_COND]),
    .ru_call         (ctrl[INDEX_RU_CALL]),
    .ru_ret          (ctrl[INDEX_RU_RET]),
    .alu_cs          (ctrl[INDEX_ALU_CS]),
    .wu_cs           (ctrl[INDEX_WU_CS]),
    .wu_write_AB     (ctrl[INDEX_WU_WRITE_AB]),
    .wu_write_AR     (ctrl[INDEX_WU_WRITE_AR]),
    .wu_do_TAR       (ctrl[INDEX_WU_DO_TAR]),
    .wu_load         (ctrl[INDEX_WU_LOAD]),
    .wu_store        (ctrl[INDEX_WU_STORE]),
    .wu_simple_load  (ctrl[INDEX_WU_SIMPLE_LOAD]),
    .wu_simple_store (ctrl[INDEX_WU_SIMPLE_STORE]),
    .*
  );

  int errors;

  task automatic check (
    input logic [7:0]  instruction,
    input logic [13:0] exp_ctrl,
    input logic [7:0]  exp_opcode,
    input logic [7:0]  exp_new_A,
    input logic [7:0]  exp_new_B,
    input logic [7:0]  exp_new_AR,
    input logic        exp_use_A,
    input logic [7:0]  exp_mask,
    input logic [7:0]  exp_mask_2,
    input logic [3:0]  exp_s_addr
  );
    instr = instruction;

    #1;
    assert (ctrl === exp_ctrl) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("instr=%b: Expected ctrl=%b, got %b", instr, exp_ctrl, ctrl);
    end

    if (exp_opcode !== DONT_CARE)
      assert (alu_opcode === exp_opcode) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("instr=%b: Expected alu_opcode=%h, got %h", instr, exp_opcode, alu_opcode);
      end

    // Only the bits under the mask reach the register
    if (exp_new_A !== DONT_CARE)
      assert ((wu_new_A & exp_mask) === (exp_new_A & exp_mask)) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("instr=%b: Expected wu_new_A=%h, got %h", instr, exp_new_A, wu_new_A);
      end

    if (exp_new_B !== DONT_CARE)
      assert ((wu_new_B & exp_mask_2) === (exp_new_B & exp_mask_2)) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("instr=%b: Expected wu_new_B=%h, got %h", instr, exp_new_B, wu_new_B);
      end

    if (exp_new_AR !== DONT_CARE)
      assert ((wu_new_AR & exp_mask) === (exp_new_AR & exp_mask)) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("instr=%b: Expected wu_new_AR=%h, got %h", instr, exp_new_AR, wu_new_AR);
      end

    if (exp_use_A !== DONT_CARE_1)
      assert (wu_use_A === exp_use_A) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("instr=%b: Expected wu_use_A=%b, got %b", instr, exp_use_A, wu_use_A);
      end

    if (exp_mask !== DONT_CARE)
      assert (wu_mask === exp_mask) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("instr=%b: Expected wu_mask=%h, got %h", instr, exp_mask, wu_mask);
      end

    if (exp_mask_2 !== DONT_CARE)
      assert (wu_mask_2 === exp_mask_2) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("instr=%b: Expected wu_mask_2=%h, got %h", instr, exp_mask_2, wu_mask_2);
      end

    if (exp_s_addr !== DONT_CARE_4)
      assert (wu_simple_addr === exp_s_addr) else begin
        errors++;
        if (errors <= ERRORS_CAP)
          $error("instr=%b: Expected wu_simple_addr=%h, got %h", instr, exp_s_addr, wu_simple_addr);
      end
  endtask

  task automatic check_unknown ();
    #1;
    assert ({ ctrl, alu_opcode, wu_new_A, wu_new_B, wu_new_AR, wu_use_A, wu_mask, wu_mask_2, wu_simple_addr } === 'x) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("instr=%b: Expected every output x, got ctrl=%b alu_opcode=%h wu_new_A=%h wu_new_B=%h wu_new_AR=%h wu_use_A=%b wu_mask=%h wu_mask_2=%h wu_simple_addr=%h",
               instr, ctrl, alu_opcode, wu_new_A, wu_new_B, wu_new_AR, wu_use_A, wu_mask, wu_mask_2, wu_simple_addr);
    end
  endtask

  initial begin
    $display("CU TEST START.");
    errors = 0;

    $display("Testing immediates");
    for (int imm = 0; imm < 16; imm++) begin
      check(
        /* .instruction */ ({ ILA[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_WRITE_AB),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ ({ 4'hx, 4'(imm) }),
        /* .exp_new_B   */ (DONT_CARE),
        /* .exp_new_AR  */ (DONT_CARE),
        /* .exp_use_A   */ (DONT_CARE_1),
        /* .exp_mask    */ (8'h0F),
        /* .exp_mask_2  */ (8'h00),
        /* .exp_s_addr  */ (DONT_CARE_4)
      );
      check(
        /* .instruction */ ({ ILB[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_WRITE_AB),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ (DONT_CARE),
        /* .exp_new_B   */ ({ 4'hx, 4'(imm) }),
        /* .exp_new_AR  */ (DONT_CARE),
        /* .exp_use_A   */ (DONT_CARE_1),
        /* .exp_mask    */ (8'h00),
        /* .exp_mask_2  */ (8'h0F),
        /* .exp_s_addr  */ (DONT_CARE_4)
      );
      check(
        /* .instruction */ ({ IHA[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_WRITE_AB),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ ({ 4'(imm), 4'hx }),
        /* .exp_new_B   */ (DONT_CARE),
        /* .exp_new_AR  */ (DONT_CARE),
        /* .exp_use_A   */ (DONT_CARE_1),
        /* .exp_mask    */ (8'hF0),
        /* .exp_mask_2  */ (8'h00),
        /* .exp_s_addr  */ (DONT_CARE_4)
      );
      check(
        /* .instruction */ ({ IHB[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_WRITE_AB),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ (DONT_CARE),
        /* .exp_new_B   */ ({ 4'(imm), 4'hx }),
        /* .exp_new_AR  */ (DONT_CARE),
        /* .exp_use_A   */ (DONT_CARE_1),
        /* .exp_mask    */ (8'h00),
        /* .exp_mask_2  */ (8'hF0),
        /* .exp_s_addr  */ (DONT_CARE_4)
      );
      check(
        /* .instruction */ ({ ALO[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_WRITE_AR),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ (DONT_CARE),
        /* .exp_new_B   */ (DONT_CARE),
        /* .exp_new_AR  */ ({ 4'hx, 4'(imm) }),
        /* .exp_use_A   */ (DONT_CARE_1),
        /* .exp_mask    */ (8'h0F),
        /* .exp_mask_2  */ (DONT_CARE),
        /* .exp_s_addr  */ (DONT_CARE_4)
      );
      check(
        /* .instruction */ ({ AHI[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_WRITE_AR),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ (DONT_CARE),
        /* .exp_new_B   */ (DONT_CARE),
        /* .exp_new_AR  */ ({ 4'(imm), 4'hx }),
        /* .exp_use_A   */ (DONT_CARE_1),
        /* .exp_mask    */ (8'hF0),
        /* .exp_mask_2  */ (DONT_CARE),
        /* .exp_s_addr  */ (DONT_CARE_4)
      );
    end

    $display("Testing simple loads and stores");
    for (int imm = 0; imm < 16; imm++) begin
      check(
        /* .instruction */ ({ SLDA[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_SIMPLE_LOAD),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ (DONT_CARE),
        /* .exp_new_B   */ (DONT_CARE),
        /* .exp_new_AR  */ (DONT_CARE),
        /* .exp_use_A   */ ('1),
        /* .exp_mask    */ (DONT_CARE),
        /* .exp_mask_2  */ (DONT_CARE),
        /* .exp_s_addr  */ (4'(imm))
      );
      check(
        /* .instruction */ ({ SLDB[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_SIMPLE_LOAD),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ (DONT_CARE),
        /* .exp_new_B   */ (DONT_CARE),
        /* .exp_new_AR  */ (DONT_CARE),
        /* .exp_use_A   */ ('0),
        /* .exp_mask    */ (DONT_CARE),
        /* .exp_mask_2  */ (DONT_CARE),
        /* .exp_s_addr  */ (4'(imm))
      );
      check(
        /* .instruction */ ({ SSTA[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_SIMPLE_STORE),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ (DONT_CARE),
        /* .exp_new_B   */ (DONT_CARE),
        /* .exp_new_AR  */ (DONT_CARE),
        /* .exp_use_A   */ ('1),
        /* .exp_mask    */ (DONT_CARE),
        /* .exp_mask_2  */ (DONT_CARE),
        /* .exp_s_addr  */ (4'(imm))
      );
      check(
        /* .instruction */ ({ SSTB[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_SIMPLE_STORE),
        /* .exp_opcode  */ (DONT_CARE),
        /* .exp_new_A   */ (DONT_CARE),
        /* .exp_new_B   */ (DONT_CARE),
        /* .exp_new_AR  */ (DONT_CARE),
        /* .exp_use_A   */ ('0),
        /* .exp_mask    */ (DONT_CARE),
        /* .exp_mask_2  */ (DONT_CARE),
        /* .exp_s_addr  */ (4'(imm))
      );
    end

    $display("Testing loads and stores");
    check(
      /* .instruction */ (LDA),
      /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_LOAD),
      /* .exp_opcode  */ (DONT_CARE),
      /* .exp_new_A   */ (DONT_CARE),
      /* .exp_new_B   */ (DONT_CARE),
      /* .exp_new_AR  */ (DONT_CARE),
      /* .exp_use_A   */ ('1),
      /* .exp_mask    */ (DONT_CARE),
      /* .exp_mask_2  */ (DONT_CARE),
      /* .exp_s_addr  */ (DONT_CARE_4)
    );
    check(
      /* .instruction */ (LDB),
      /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_LOAD),
      /* .exp_opcode  */ (DONT_CARE),
      /* .exp_new_A   */ (DONT_CARE),
      /* .exp_new_B   */ (DONT_CARE),
      /* .exp_new_AR  */ (DONT_CARE),
      /* .exp_use_A   */ ('0),
      /* .exp_mask    */ (DONT_CARE),
      /* .exp_mask_2  */ (DONT_CARE),
      /* .exp_s_addr  */ (DONT_CARE_4)
    );
    check(
      /* .instruction */ (STA),
      /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_STORE),
      /* .exp_opcode  */ (DONT_CARE),
      /* .exp_new_A   */ (DONT_CARE),
      /* .exp_new_B   */ (DONT_CARE),
      /* .exp_new_AR  */ (DONT_CARE),
      /* .exp_use_A   */ ('1),
      /* .exp_mask    */ (DONT_CARE),
      /* .exp_mask_2  */ (DONT_CARE),
      /* .exp_s_addr  */ (DONT_CARE_4)
    );
    check(
      /* .instruction */ (STB),
      /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_STORE),
      /* .exp_opcode  */ (DONT_CARE),
      /* .exp_new_A   */ (DONT_CARE),
      /* .exp_new_B   */ (DONT_CARE),
      /* .exp_new_AR  */ (DONT_CARE),
      /* .exp_use_A   */ ('0),
      /* .exp_mask    */ (DONT_CARE),
      /* .exp_mask_2  */ (DONT_CARE),
      /* .exp_s_addr  */ (DONT_CARE_4)
    );

    $display("Testing TAR");
    check(
      /* .instruction */ (TAR),
      /* .exp_ctrl    */ (BIT_WU_CS | BIT_WU_DO_TAR),
      /* .exp_opcode  */ (DONT_CARE),
      /* .exp_new_A   */ (DONT_CARE),
      /* .exp_new_B   */ (DONT_CARE),
      /* .exp_new_AR  */ (DONT_CARE),
      /* .exp_use_A   */ (DONT_CARE_1),
      /* .exp_mask    */ (DONT_CARE),
      /* .exp_mask_2  */ (DONT_CARE),
      /* .exp_s_addr  */ (DONT_CARE_4)
    );

    $display("Testing ALU instructions");
    for (int op = int'(INVA); op <= int'(STF); op++) begin
      check(
        /* .instruction */ (8'(op)),
        /* .exp_ctrl    */ (BIT_ALU_CS),
        /* .exp_opcode  */ (8'(op)),
        /* .exp_new_A   */ (DONT_CARE),
        /* .exp_new_B   */ (DONT_CARE),
        /* .exp_new_AR  */ (DONT_CARE),
        /* .exp_use_A   */ (DONT_CARE_1),
        /* .exp_mask    */ (DONT_CARE),
        /* .exp_mask_2  */ (DONT_CARE),
        /* .exp_s_addr  */ (DONT_CARE_4)
      );
    end

    $display("Testing RU instructions");
    check(
      /* .instruction */ (JMP),
      /* .exp_ctrl    */ (BIT_RU_CS | BIT_RU_JMP),
      /* .exp_opcode  */ (DONT_CARE),
      /* .exp_new_A   */ (DONT_CARE),
      /* .exp_new_B   */ (DONT_CARE),
      /* .exp_new_AR  */ (DONT_CARE),
      /* .exp_use_A   */ (DONT_CARE_1),
      /* .exp_mask    */ (DONT_CARE),
      /* .exp_mask_2  */ (DONT_CARE),
      /* .exp_s_addr  */ (DONT_CARE_4)
    );
    check(
      /* .instruction */ (JF),
      /* .exp_ctrl    */ (BIT_RU_CS | BIT_RU_JMP | BIT_RU_JMP_COND),
      /* .exp_opcode  */ (DONT_CARE),
      /* .exp_new_A   */ (DONT_CARE),
      /* .exp_new_B   */ (DONT_CARE),
      /* .exp_new_AR  */ (DONT_CARE),
      /* .exp_use_A   */ (DONT_CARE_1),
      /* .exp_mask    */ (DONT_CARE),
      /* .exp_mask_2  */ (DONT_CARE),
      /* .exp_s_addr  */ (DONT_CARE_4)
    );
    check(
      /* .instruction */ (CALL),
      /* .exp_ctrl    */ (BIT_RU_CS | BIT_RU_CALL),
      /* .exp_opcode  */ (DONT_CARE),
      /* .exp_new_A   */ (DONT_CARE),
      /* .exp_new_B   */ (DONT_CARE),
      /* .exp_new_AR  */ (DONT_CARE),
      /* .exp_use_A   */ (DONT_CARE_1),
      /* .exp_mask    */ (DONT_CARE),
      /* .exp_mask_2  */ (DONT_CARE),
      /* .exp_s_addr  */ (DONT_CARE_4)
    );
    check(
      /* .instruction */ (RET),
      /* .exp_ctrl    */ (BIT_RU_CS | BIT_RU_RET),
      /* .exp_opcode  */ (DONT_CARE),
      /* .exp_new_A   */ (DONT_CARE),
      /* .exp_new_B   */ (DONT_CARE),
      /* .exp_new_AR  */ (DONT_CARE),
      /* .exp_use_A   */ (DONT_CARE_1),
      /* .exp_mask    */ (DONT_CARE),
      /* .exp_mask_2  */ (DONT_CARE),
      /* .exp_s_addr  */ (DONT_CARE_4)
    );

    $display("Testing undefined opcodes");
    for (int op = 0; op < 256; op++) begin
      // The free codes listed in docs/isa.md
      if ((op >= 8'h9C && op <= 8'h9F) || (op >= 8'hA0 && op <= 8'hCF) ||
          (op >= 8'hD0 && op <= 8'hD7) || (op >= 8'hD9 && op <= 8'hDB)) begin
        check(
          /* .instruction */ (8'(op)),
          /* .exp_ctrl    */ (BIT_NOTHING),
          /* .exp_opcode  */ (DONT_CARE),
          /* .exp_new_A   */ (DONT_CARE),
          /* .exp_new_B   */ (DONT_CARE),
          /* .exp_new_AR  */ (DONT_CARE),
          /* .exp_use_A   */ (DONT_CARE_1),
          /* .exp_mask    */ (DONT_CARE),
          /* .exp_mask_2  */ (DONT_CARE),
          /* .exp_s_addr  */ (DONT_CARE_4)
        );
      end
    end

    $display("Testing unknown instructions");
    instr = 8'hxx;
    check_unknown();

    instr = 8'hzz;
    check_unknown();

    for (int op = 0; op < 256; op++) begin
      for (int i = 0; i < 8; i++) begin
        instr = 8'(op);
        instr[i] = 1'bx;
        check_unknown();

        instr[i] = 1'bz;
        check_unknown();
      end
    end

    if (errors == 0) begin
      $display("CU TEST PASSED!");
      $finish;
    end
    else
      $fatal(1, "CU TEST FAILED WITH %0d ERRORS!", errors);

  end

endmodule
