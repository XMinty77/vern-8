/* ================= CU Testbench =================
 * Black box testbench of the control unit
 * ================================================
 */
module cu_tb;

  import opcodes::*;
  import tb_prefs::*;

  localparam logic [13:0] BitNothing         = 14'b0;
  localparam int          IndexRuCs          = 0;
  localparam logic [13:0] BitRuCs            = 14'b1 << IndexRuCs;
  localparam int          IndexRuJmp         = 1;
  localparam logic [13:0] BitRuJmp           = 14'b1 << IndexRuJmp;
  localparam int          IndexRuJmpCond     = 2;
  localparam logic [13:0] BitRuJmpCond       = 14'b1 << IndexRuJmpCond;
  localparam int          IndexRuCall        = 3;
  localparam logic [13:0] BitRuCall          = 14'b1 << IndexRuCall;
  localparam int          IndexRuRet         = 4;
  localparam logic [13:0] BitRuRet           = 14'b1 << IndexRuRet;
  localparam int          IndexAluCs         = 5;
  localparam logic [13:0] BitAluCs           = 14'b1 << IndexAluCs;
  localparam int          IndexWuCs          = 6;
  localparam logic [13:0] BitWuCs            = 14'b1 << IndexWuCs;
  localparam int          IndexWuWriteAb     = 7;
  localparam logic [13:0] BitWuWriteAb       = 14'b1 << IndexWuWriteAb;
  localparam int          IndexWuWriteAr     = 8;
  localparam logic [13:0] BitWuWriteAr       = 14'b1 << IndexWuWriteAr;
  localparam int          IndexWuDoTar       = 9;
  localparam logic [13:0] BitWuDoTar         = 14'b1 << IndexWuDoTar;
  localparam int          IndexWuLoad        = 10;
  localparam logic [13:0] BitWuLoad          = 14'b1 << IndexWuLoad;
  localparam int          IndexWuStore       = 11;
  localparam logic [13:0] BitWuStore         = 14'b1 << IndexWuStore;
  localparam int          IndexWuSimpleLoad  = 12;
  localparam logic [13:0] BitWuSimpleLoad    = 14'b1 << IndexWuSimpleLoad;
  localparam int          IndexWuSimpleStore = 13;
  localparam logic [13:0] BitWuSimpleStore   = 14'b1 << IndexWuSimpleStore;

  localparam logic [7:0] DontCare  = 8'hxx;
  localparam logic [3:0] DontCare4 = 4'hx;
  localparam logic       DontCare1 = 1'bx;

  // Inputs
  logic [7:0] instr_i;

  // Outputs
  logic [13:0] ctrl;
  logic [7:0]  alu_op_o;
  logic [7:0]  wu_new_a_o, wu_new_b_o, wu_new_ar_o;
  logic        wu_use_a_o;
  logic [7:0]  wu_mask_a_o, wu_mask_b_o;
  logic [3:0]  wu_simple_addr_o;

  cu dut (
    .ru_cs_o           (ctrl[IndexRuCs]),
    .ru_jmp_o          (ctrl[IndexRuJmp]),
    .ru_jmp_cond_o     (ctrl[IndexRuJmpCond]),
    .ru_call_o         (ctrl[IndexRuCall]),
    .ru_ret_o          (ctrl[IndexRuRet]),
    .alu_cs_o          (ctrl[IndexAluCs]),
    .wu_cs_o           (ctrl[IndexWuCs]),
    .wu_write_ab_o     (ctrl[IndexWuWriteAb]),
    .wu_write_ar_o     (ctrl[IndexWuWriteAr]),
    .wu_do_tar_o       (ctrl[IndexWuDoTar]),
    .wu_load_o         (ctrl[IndexWuLoad]),
    .wu_store_o        (ctrl[IndexWuStore]),
    .wu_simple_load_o  (ctrl[IndexWuSimpleLoad]),
    .wu_simple_store_o (ctrl[IndexWuSimpleStore]),
    .*
  );

  int errors;

  task automatic check (
    input logic [7:0]  instruction,
    input logic [13:0] exp_ctrl,
    input logic [7:0]  exp_op,
    input logic [7:0]  exp_new_a,
    input logic [7:0]  exp_new_b,
    input logic [7:0]  exp_new_ar,
    input logic        exp_use_a,
    input logic [7:0]  exp_mask_a,
    input logic [7:0]  exp_mask_b,
    input logic [3:0]  exp_s_addr
  );
    instr_i = instruction;

    #1;
    assert (ctrl === exp_ctrl) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("instr=%b: Expected ctrl=%b, got %b", instr_i, exp_ctrl, ctrl);
    end

    if (exp_op !== DontCare)
      assert (alu_op_o === exp_op) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("instr=%b: Expected alu_op_o=%h, got %h", instr_i, exp_op, alu_op_o);
      end

    // Only the bits under the mask reach the register
    if (exp_new_a !== DontCare)
      assert ((wu_new_a_o & exp_mask_a) === (exp_new_a & exp_mask_a)) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("instr=%b: Expected wu_new_a_o=%h, got %h", instr_i, exp_new_a, wu_new_a_o);
      end

    if (exp_new_b !== DontCare)
      assert ((wu_new_b_o & exp_mask_b) === (exp_new_b & exp_mask_b)) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("instr=%b: Expected wu_new_b_o=%h, got %h", instr_i, exp_new_b, wu_new_b_o);
      end

    if (exp_new_ar !== DontCare)
      assert ((wu_new_ar_o & exp_mask_a) === (exp_new_ar & exp_mask_a)) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("instr=%b: Expected wu_new_ar_o=%h, got %h", instr_i, exp_new_ar, wu_new_ar_o);
      end

    if (exp_use_a !== DontCare1)
      assert (wu_use_a_o === exp_use_a) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("instr=%b: Expected wu_use_a_o=%b, got %b", instr_i, exp_use_a, wu_use_a_o);
      end

    if (exp_mask_a !== DontCare)
      assert (wu_mask_a_o === exp_mask_a) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("instr=%b: Expected wu_mask_a_o=%h, got %h", instr_i, exp_mask_a, wu_mask_a_o);
      end

    if (exp_mask_b !== DontCare)
      assert (wu_mask_b_o === exp_mask_b) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("instr=%b: Expected wu_mask_b_o=%h, got %h", instr_i, exp_mask_b, wu_mask_b_o);
      end

    if (exp_s_addr !== DontCare4)
      assert (wu_simple_addr_o === exp_s_addr) else begin
        errors++;
        if (errors <= ErrorsCap)
          $error("instr=%b: Expected wu_simple_addr_o=%h, got %h", instr_i, exp_s_addr, wu_simple_addr_o);
      end
  endtask

  task automatic check_unknown ();
    #1;
    assert ({ ctrl, alu_op_o, wu_new_a_o, wu_new_b_o, wu_new_ar_o, wu_use_a_o, wu_mask_a_o, wu_mask_b_o, wu_simple_addr_o } === 'x) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("instr=%b: Expected every output x, got ctrl=%b alu_op_o=%h wu_new_a_o=%h wu_new_b_o=%h wu_new_ar_o=%h wu_use_a_o=%b wu_mask_a_o=%h wu_mask_b_o=%h wu_simple_addr_o=%h",
               instr_i, ctrl, alu_op_o, wu_new_a_o, wu_new_b_o, wu_new_ar_o, wu_use_a_o, wu_mask_a_o, wu_mask_b_o, wu_simple_addr_o);
    end
  endtask

  initial begin
    $display("CU TEST START.");
    errors = 0;

    $display("Testing immediates");
    for (int imm = 0; imm < 16; imm++) begin
      check(
        /* .instruction */ ({ Ila[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuWriteAb),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ ({ 4'hx, 4'(imm) }),
        /* .exp_new_b   */ (DontCare),
        /* .exp_new_ar  */ (DontCare),
        /* .exp_use_a   */ (DontCare1),
        /* .exp_mask_a  */ (8'h0F),
        /* .exp_mask_b  */ (8'h00),
        /* .exp_s_addr  */ (DontCare4)
      );
      check(
        /* .instruction */ ({ Ilb[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuWriteAb),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ (DontCare),
        /* .exp_new_b   */ ({ 4'hx, 4'(imm) }),
        /* .exp_new_ar  */ (DontCare),
        /* .exp_use_a   */ (DontCare1),
        /* .exp_mask_a  */ (8'h00),
        /* .exp_mask_b  */ (8'h0F),
        /* .exp_s_addr  */ (DontCare4)
      );
      check(
        /* .instruction */ ({ Iha[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuWriteAb),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ ({ 4'(imm), 4'hx }),
        /* .exp_new_b   */ (DontCare),
        /* .exp_new_ar  */ (DontCare),
        /* .exp_use_a   */ (DontCare1),
        /* .exp_mask_a  */ (8'hF0),
        /* .exp_mask_b  */ (8'h00),
        /* .exp_s_addr  */ (DontCare4)
      );
      check(
        /* .instruction */ ({ Ihb[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuWriteAb),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ (DontCare),
        /* .exp_new_b   */ ({ 4'(imm), 4'hx }),
        /* .exp_new_ar  */ (DontCare),
        /* .exp_use_a   */ (DontCare1),
        /* .exp_mask_a  */ (8'h00),
        /* .exp_mask_b  */ (8'hF0),
        /* .exp_s_addr  */ (DontCare4)
      );
      check(
        /* .instruction */ ({ Alo[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuWriteAr),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ (DontCare),
        /* .exp_new_b   */ (DontCare),
        /* .exp_new_ar  */ ({ 4'hx, 4'(imm) }),
        /* .exp_use_a   */ (DontCare1),
        /* .exp_mask_a  */ (8'h0F),
        /* .exp_mask_b  */ (DontCare),
        /* .exp_s_addr  */ (DontCare4)
      );
      check(
        /* .instruction */ ({ Ahi[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuWriteAr),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ (DontCare),
        /* .exp_new_b   */ (DontCare),
        /* .exp_new_ar  */ ({ 4'(imm), 4'hx }),
        /* .exp_use_a   */ (DontCare1),
        /* .exp_mask_a  */ (8'hF0),
        /* .exp_mask_b  */ (DontCare),
        /* .exp_s_addr  */ (DontCare4)
      );
    end

    $display("Testing simple loads and stores");
    for (int imm = 0; imm < 16; imm++) begin
      check(
        /* .instruction */ ({ Slda[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuSimpleLoad),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ (DontCare),
        /* .exp_new_b   */ (DontCare),
        /* .exp_new_ar  */ (DontCare),
        /* .exp_use_a   */ ('1),
        /* .exp_mask_a  */ (DontCare),
        /* .exp_mask_b  */ (DontCare),
        /* .exp_s_addr  */ (4'(imm))
      );
      check(
        /* .instruction */ ({ Sldb[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuSimpleLoad),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ (DontCare),
        /* .exp_new_b   */ (DontCare),
        /* .exp_new_ar  */ (DontCare),
        /* .exp_use_a   */ ('0),
        /* .exp_mask_a  */ (DontCare),
        /* .exp_mask_b  */ (DontCare),
        /* .exp_s_addr  */ (4'(imm))
      );
      check(
        /* .instruction */ ({ Ssta[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuSimpleStore),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ (DontCare),
        /* .exp_new_b   */ (DontCare),
        /* .exp_new_ar  */ (DontCare),
        /* .exp_use_a   */ ('1),
        /* .exp_mask_a  */ (DontCare),
        /* .exp_mask_b  */ (DontCare),
        /* .exp_s_addr  */ (4'(imm))
      );
      check(
        /* .instruction */ ({ Sstb[7:4], 4'(imm) }),
        /* .exp_ctrl    */ (BitWuCs | BitWuSimpleStore),
        /* .exp_op      */ (DontCare),
        /* .exp_new_a   */ (DontCare),
        /* .exp_new_b   */ (DontCare),
        /* .exp_new_ar  */ (DontCare),
        /* .exp_use_a   */ ('0),
        /* .exp_mask_a  */ (DontCare),
        /* .exp_mask_b  */ (DontCare),
        /* .exp_s_addr  */ (4'(imm))
      );
    end

    $display("Testing loads and stores");
    check(
      /* .instruction */ (Lda),
      /* .exp_ctrl    */ (BitWuCs | BitWuLoad),
      /* .exp_op      */ (DontCare),
      /* .exp_new_a   */ (DontCare),
      /* .exp_new_b   */ (DontCare),
      /* .exp_new_ar  */ (DontCare),
      /* .exp_use_a   */ ('1),
      /* .exp_mask_a  */ (DontCare),
      /* .exp_mask_b  */ (DontCare),
      /* .exp_s_addr  */ (DontCare4)
    );
    check(
      /* .instruction */ (Ldb),
      /* .exp_ctrl    */ (BitWuCs | BitWuLoad),
      /* .exp_op      */ (DontCare),
      /* .exp_new_a   */ (DontCare),
      /* .exp_new_b   */ (DontCare),
      /* .exp_new_ar  */ (DontCare),
      /* .exp_use_a   */ ('0),
      /* .exp_mask_a  */ (DontCare),
      /* .exp_mask_b  */ (DontCare),
      /* .exp_s_addr  */ (DontCare4)
    );
    check(
      /* .instruction */ (Sta),
      /* .exp_ctrl    */ (BitWuCs | BitWuStore),
      /* .exp_op      */ (DontCare),
      /* .exp_new_a   */ (DontCare),
      /* .exp_new_b   */ (DontCare),
      /* .exp_new_ar  */ (DontCare),
      /* .exp_use_a   */ ('1),
      /* .exp_mask_a  */ (DontCare),
      /* .exp_mask_b  */ (DontCare),
      /* .exp_s_addr  */ (DontCare4)
    );
    check(
      /* .instruction */ (Stb),
      /* .exp_ctrl    */ (BitWuCs | BitWuStore),
      /* .exp_op      */ (DontCare),
      /* .exp_new_a   */ (DontCare),
      /* .exp_new_b   */ (DontCare),
      /* .exp_new_ar  */ (DontCare),
      /* .exp_use_a   */ ('0),
      /* .exp_mask_a  */ (DontCare),
      /* .exp_mask_b  */ (DontCare),
      /* .exp_s_addr  */ (DontCare4)
    );

    $display("Testing TAR");
    check(
      /* .instruction */ (Tar),
      /* .exp_ctrl    */ (BitWuCs | BitWuDoTar),
      /* .exp_op      */ (DontCare),
      /* .exp_new_a   */ (DontCare),
      /* .exp_new_b   */ (DontCare),
      /* .exp_new_ar  */ (DontCare),
      /* .exp_use_a   */ (DontCare1),
      /* .exp_mask_a  */ (DontCare),
      /* .exp_mask_b  */ (DontCare),
      /* .exp_s_addr  */ (DontCare4)
    );

    $display("Testing ALU instructions");
    for (int op = int'(Inva); op <= int'(Stf); op++) begin
      check(
        /* .instruction */ (8'(op)),
        /* .exp_ctrl    */ (BitAluCs),
        /* .exp_op      */ (8'(op)),
        /* .exp_new_a   */ (DontCare),
        /* .exp_new_b   */ (DontCare),
        /* .exp_new_ar  */ (DontCare),
        /* .exp_use_a   */ (DontCare1),
        /* .exp_mask_a  */ (DontCare),
        /* .exp_mask_b  */ (DontCare),
        /* .exp_s_addr  */ (DontCare4)
      );
    end

    $display("Testing RU instructions");
    check(
      /* .instruction */ (Jmp),
      /* .exp_ctrl    */ (BitRuCs | BitRuJmp),
      /* .exp_op      */ (DontCare),
      /* .exp_new_a   */ (DontCare),
      /* .exp_new_b   */ (DontCare),
      /* .exp_new_ar  */ (DontCare),
      /* .exp_use_a   */ (DontCare1),
      /* .exp_mask_a  */ (DontCare),
      /* .exp_mask_b  */ (DontCare),
      /* .exp_s_addr  */ (DontCare4)
    );
    check(
      /* .instruction */ (Jf),
      /* .exp_ctrl    */ (BitRuCs | BitRuJmp | BitRuJmpCond),
      /* .exp_op      */ (DontCare),
      /* .exp_new_a   */ (DontCare),
      /* .exp_new_b   */ (DontCare),
      /* .exp_new_ar  */ (DontCare),
      /* .exp_use_a   */ (DontCare1),
      /* .exp_mask_a  */ (DontCare),
      /* .exp_mask_b  */ (DontCare),
      /* .exp_s_addr  */ (DontCare4)
    );
    check(
      /* .instruction */ (Call),
      /* .exp_ctrl    */ (BitRuCs | BitRuCall),
      /* .exp_op      */ (DontCare),
      /* .exp_new_a   */ (DontCare),
      /* .exp_new_b   */ (DontCare),
      /* .exp_new_ar  */ (DontCare),
      /* .exp_use_a   */ (DontCare1),
      /* .exp_mask_a  */ (DontCare),
      /* .exp_mask_b  */ (DontCare),
      /* .exp_s_addr  */ (DontCare4)
    );
    check(
      /* .instruction */ (Ret),
      /* .exp_ctrl    */ (BitRuCs | BitRuRet),
      /* .exp_op      */ (DontCare),
      /* .exp_new_a   */ (DontCare),
      /* .exp_new_b   */ (DontCare),
      /* .exp_new_ar  */ (DontCare),
      /* .exp_use_a   */ (DontCare1),
      /* .exp_mask_a  */ (DontCare),
      /* .exp_mask_b  */ (DontCare),
      /* .exp_s_addr  */ (DontCare4)
    );

    $display("Testing undefined opcodes");
    for (int op = 0; op < 256; op++) begin
      // The free codes listed in docs/isa.md
      if ((op >= 8'h9C && op <= 8'h9F) || (op >= 8'hA0 && op <= 8'hCF) ||
          (op >= 8'hD0 && op <= 8'hD7) || (op >= 8'hD9 && op <= 8'hDB)) begin
        check(
          /* .instruction */ (8'(op)),
          /* .exp_ctrl    */ (BitNothing),
          /* .exp_op      */ (DontCare),
          /* .exp_new_a   */ (DontCare),
          /* .exp_new_b   */ (DontCare),
          /* .exp_new_ar  */ (DontCare),
          /* .exp_use_a   */ (DontCare1),
          /* .exp_mask_a  */ (DontCare),
          /* .exp_mask_b  */ (DontCare),
          /* .exp_s_addr  */ (DontCare4)
        );
      end
    end

    $display("Testing unknown instructions");
    instr_i = 8'hxx;
    check_unknown();

    instr_i = 8'hzz;
    check_unknown();

    for (int op = 0; op < 256; op++) begin
      for (int i = 0; i < 8; i++) begin
        instr_i = 8'(op);
        instr_i[i] = 1'bx;
        check_unknown();

        instr_i[i] = 1'bz;
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
