/* ================ CU Implementation ================
 * Simple combinational CU as per spec
 * ====================================================
 */

module cu (
  input  logic [7:0] instr,

  output logic       ru_cs,
  output logic       ru_jmp,
  output logic       ru_jmp_cond,
  output logic       ru_call,
  output logic       ru_ret,

  output logic       alu_cs,
  output logic [7:0] alu_opcode,

  output logic       wu_cs,
  output logic [7:0] wu_new_A,
  output logic [7:0] wu_new_B,
  output logic       wu_write_AB,
  output logic [7:0] wu_new_AR,
  output logic       wu_write_AR,
  output logic       wu_do_TAR,
  output logic       wu_use_A,
  output logic [7:0] wu_mask,
  output logic [7:0] wu_mask_2,
  output logic       wu_load,
  output logic       wu_store,
  output logic [3:0] wu_simple_addr,
  output logic       wu_simple_load,
  output logic       wu_simple_store
);

  // Import opcodes package
  import opcodes::*;

  // Combinational
  always_comb begin
    if (!$isunknown(instr)) begin
      { ru_cs, ru_jmp, ru_jmp_cond, ru_call, ru_ret } = '0;
      { alu_cs, alu_opcode } = '0;
      { wu_cs, wu_new_A, wu_new_B, wu_write_AB, wu_new_AR, wu_write_AR, wu_do_TAR, wu_use_A, wu_mask, wu_mask_2, wu_load, wu_store, wu_simple_addr, wu_simple_load, wu_simple_store } = '0;
      unique casez (instr)
        // WU
        ILA: begin
          wu_cs = '1;
          wu_write_AB = '1;
          wu_new_A = 8'(instr[3:0]);
          wu_mask = 8'h0F;
        end
        ILB: begin
          wu_cs = '1;
          wu_write_AB = '1;
          wu_new_B = 8'(instr[3:0]);
          wu_mask_2 = 8'h0F;
        end
        IHA: begin
          wu_cs = '1;
          wu_write_AB = '1;
          wu_new_A = { instr[3:0], 4'b0 };
          wu_mask = 8'hF0;
        end
        IHB: begin
          wu_cs = '1;
          wu_write_AB = '1;
          wu_new_B = { instr[3:0], 4'b0 };
          wu_mask_2 = 8'hF0;
        end
        ALO: begin
          wu_cs = '1;
          wu_write_AR = '1;
          wu_new_AR = 8'(instr[3:0]);
          wu_mask = 8'h0F;
        end
        AHI: begin
          wu_cs = '1;
          wu_write_AR = '1;
          wu_new_AR = { instr[3:0], 4'b0 };
          wu_mask = 8'hF0;
        end

        SLDA: begin
          wu_cs = '1;
          wu_simple_load = '1;
          wu_use_A = '1;
          wu_simple_addr = instr[3:0];
        end
        SLDB: begin
          wu_cs = '1;
          wu_simple_load = '1;
          wu_use_A = '0;
          wu_simple_addr = instr[3:0];
        end
        SSTA: begin
          wu_cs = '1;
          wu_simple_store = '1;
          wu_use_A = '1;
          wu_simple_addr = instr[3:0];
        end
        SSTB: begin
          wu_cs = '1;
          wu_simple_store = '1;
          wu_use_A = '0;
          wu_simple_addr = instr[3:0];
        end


        LDA: begin
          wu_cs = '1;
          wu_load = '1;
          wu_use_A = '1;
        end
        LDB: begin
          wu_cs = '1;
          wu_load = '1;
          wu_use_A = '0;
        end
        STA: begin
          wu_cs = '1;
          wu_store = '1;
          wu_use_A = '1;
        end
        STB: begin
          wu_cs = '1;
          wu_store = '1;
          wu_use_A = '0;
        end

        TAR: begin
          wu_cs = '1;
          wu_do_TAR = '1;
        end

        // RU
        JMP: begin
          ru_cs = '1;
          ru_jmp = '1;
        end
        JF: begin
          ru_cs = '1;
          ru_jmp = '1;
          ru_jmp_cond = '1;
        end
        CALL: begin
          ru_cs = '1;
          ru_call = '1;
        end
        RET: begin
          ru_cs = '1;
          ru_ret = '1;
        end
        
        // ALU
        INVA, INVB, ADD, SUB, MUL, DIV, SWAP, INC, AND, NAND, OR, NOR, XOR, XNOR, SHL, SHR, EQ, NEQ, LT, GTE, GT, LTE, CLF, STF: begin
          alu_cs = '1;
          alu_opcode = instr;
        end

        // Other
        default: ;
      endcase
    end else begin
      { ru_cs, ru_jmp, ru_jmp_cond, ru_call, ru_ret } = 'x;
      { alu_cs, alu_opcode } = 'x;
      { wu_cs, wu_new_A, wu_new_B, wu_write_AB, wu_new_AR, wu_write_AR, wu_do_TAR, wu_use_A, wu_mask, wu_mask_2, wu_load, wu_store, wu_simple_addr, wu_simple_load, wu_simple_store } = 'x;
    end
  end

endmodule
