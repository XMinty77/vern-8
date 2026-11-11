/* ================ CU ================
 * Control unit: decodes the instruction byte into unit commands
 * ====================================
 */

module cu (
  input  logic [7:0] instr_i,

  output logic       ru_cs_o,
  output logic       ru_jmp_o,
  output logic       ru_jmp_cond_o,
  output logic       ru_call_o,
  output logic       ru_ret_o,

  output logic       alu_cs_o,
  output logic [7:0] alu_op_o,

  output logic       wu_cs_o,
  output logic [7:0] wu_new_a_o,
  output logic [7:0] wu_new_b_o,
  output logic       wu_write_ab_o,
  output logic [7:0] wu_new_ar_o,
  output logic       wu_write_ar_o,
  output logic       wu_do_tar_o,
  output logic       wu_use_a_o,
  output logic [7:0] wu_mask_a_o,
  output logic [7:0] wu_mask_b_o,
  output logic       wu_load_o,
  output logic       wu_store_o,
  output logic [3:0] wu_simple_addr_o,
  output logic       wu_simple_load_o,
  output logic       wu_simple_store_o
);

  import opcodes::*;

  always_comb begin
    if ($isunknown(instr_i)) begin
      { ru_cs_o, ru_jmp_o, ru_jmp_cond_o, ru_call_o, ru_ret_o } = 'x;
      { alu_cs_o, alu_op_o } = 'x;
      { wu_cs_o, wu_new_a_o, wu_new_b_o, wu_write_ab_o, wu_new_ar_o, wu_write_ar_o, wu_do_tar_o, wu_use_a_o,
        wu_mask_a_o, wu_mask_b_o, wu_load_o, wu_store_o,
        wu_simple_addr_o, wu_simple_load_o, wu_simple_store_o } = 'x;
    end else begin
      { ru_cs_o, ru_jmp_o, ru_jmp_cond_o, ru_call_o, ru_ret_o } = '0;
      { alu_cs_o, alu_op_o } = '0;
      { wu_cs_o, wu_new_a_o, wu_new_b_o, wu_write_ab_o, wu_new_ar_o, wu_write_ar_o, wu_do_tar_o, wu_use_a_o,
        wu_mask_a_o, wu_mask_b_o, wu_load_o, wu_store_o,
        wu_simple_addr_o, wu_simple_load_o, wu_simple_store_o } = '0;

      unique casez (instr_i)
        // WU
        Ila: begin
          wu_cs_o = '1;
          wu_write_ab_o = '1;
          wu_new_a_o = 8'(instr_i[3:0]);
          wu_mask_a_o = 8'h0F;
        end
        Ilb: begin
          wu_cs_o = '1;
          wu_write_ab_o = '1;
          wu_new_b_o = 8'(instr_i[3:0]);
          wu_mask_b_o = 8'h0F;
        end
        Iha: begin
          wu_cs_o = '1;
          wu_write_ab_o = '1;
          wu_new_a_o = { instr_i[3:0], 4'b0 };
          wu_mask_a_o = 8'hF0;
        end
        Ihb: begin
          wu_cs_o = '1;
          wu_write_ab_o = '1;
          wu_new_b_o = { instr_i[3:0], 4'b0 };
          wu_mask_b_o = 8'hF0;
        end
        Alo: begin
          wu_cs_o = '1;
          wu_write_ar_o = '1;
          wu_new_ar_o = 8'(instr_i[3:0]);
          wu_mask_a_o = 8'h0F;
        end
        Ahi: begin
          wu_cs_o = '1;
          wu_write_ar_o = '1;
          wu_new_ar_o = { instr_i[3:0], 4'b0 };
          wu_mask_a_o = 8'hF0;
        end

        Slda: begin
          wu_cs_o = '1;
          wu_simple_load_o = '1;
          wu_use_a_o = '1;
          wu_simple_addr_o = instr_i[3:0];
        end
        Sldb: begin
          wu_cs_o = '1;
          wu_simple_load_o = '1;
          wu_use_a_o = '0;
          wu_simple_addr_o = instr_i[3:0];
        end
        Ssta: begin
          wu_cs_o = '1;
          wu_simple_store_o = '1;
          wu_use_a_o = '1;
          wu_simple_addr_o = instr_i[3:0];
        end
        Sstb: begin
          wu_cs_o = '1;
          wu_simple_store_o = '1;
          wu_use_a_o = '0;
          wu_simple_addr_o = instr_i[3:0];
        end

        Lda: begin
          wu_cs_o = '1;
          wu_load_o = '1;
          wu_use_a_o = '1;
        end
        Ldb: begin
          wu_cs_o = '1;
          wu_load_o = '1;
          wu_use_a_o = '0;
        end
        Sta: begin
          wu_cs_o = '1;
          wu_store_o = '1;
          wu_use_a_o = '1;
        end
        Stb: begin
          wu_cs_o = '1;
          wu_store_o = '1;
          wu_use_a_o = '0;
        end

        Tar: begin
          wu_cs_o = '1;
          wu_do_tar_o = '1;
        end

        // RU
        Jmp: begin
          ru_cs_o = '1;
          ru_jmp_o = '1;
        end
        Jf: begin
          ru_cs_o = '1;
          ru_jmp_o = '1;
          ru_jmp_cond_o = '1;
        end
        Call: begin
          ru_cs_o = '1;
          ru_call_o = '1;
        end
        Ret: begin
          ru_cs_o = '1;
          ru_ret_o = '1;
        end

        // ALU
        Inva, Invb, Add, Sub, Mul, Div, Swap, Inc,
        And, Nand, Or, Nor, Xor, Xnor, Shl, Shr,
        Eq, Neq, Lt, Gte, Gt, Lte, Clf, Stf: begin
          alu_cs_o = '1;
          alu_op_o = instr_i;
        end

        default: ;                // Undefined instruction: no unit selected
      endcase
    end
  end

endmodule
