/* ================ Core Implementation ================
 * The top level module of the CPU
 * =====================================================
 */

module core (
  input logic clk,
  input logic rst
);

  // Import opcodes package
  import opcodes::*;

  // Instances
  
  logic [7:0] wu_in_A, wu_in_B, wu_in_AR, wu_in_mem, wu_mask, wu_mask_2;
  logic       wu_write_AB, wu_use_A, wu_write_AR, wu_do_TAR, wu_load, wu_store, wu_simple_load, wu_simple_store;
  logic [3:0] wu_simple_addr;
  logic [7:0] wu_out_A, wu_out_B, wu_out_AR, wu_out_mem, wu_mem_addr;
  logic       wu_mem_write;
   wu wu (
    .new_A        (wu_in_A),
    .new_B        (wu_in_B),
    .write_AB     (wu_write_AB),
    .use_A        (wu_use_A),
    .mask         (wu_mask),
    .mask_2       (wu_mask_2),
    .new_AR       (wu_in_AR),
    .write_AR     (wu_write_AR),
    .do_TAR       (wu_do_TAR),
    .load         (wu_load),
    .store        (wu_store),
    .simple_addr  (wu_simple_addr),
    .simple_load  (wu_simple_load),
    .simple_store (wu_simple_store),
    .mem_val_in   (wu_in_mem),
    .A            (wu_out_A),
    .B            (wu_out_B),
    .AR           (wu_out_AR),
    .mem_addr     (wu_mem_addr),
    .mem_val_out  (wu_out_mem),
    .mem_write    (wu_mem_write),
    .clk          (clk),
    .rst          (rst)
  );
  
  logic       ru_jmp, ru_jmp_cond, ru_call, ru_ret, ru_write_F;
  logic       ru_in_F, ru_out_F;
  logic [7:0] ru_in_AR, ru_out_PC;
  ru ru (
    .jmp      (ru_jmp),
    .jmp_cond (ru_jmp_cond),
    .call     (ru_call),
    .ret      (ru_ret),
    .new_F    (ru_in_F),
    .write_F  (ru_write_F),
    .AR       (ru_in_AR),
    .PC       (ru_out_PC),
    .F        (ru_out_F),
    .clk      (clk),
    .rst      (rst)
  );

  logic [7:0] alu_in_A, alu_in_B, alu_out_A, alu_out_B;
  logic       alu_in_F, alu_out_F;
  logic [7:0] alu_opcode;
  alu alu (
    .cur_A  (alu_in_A),
    .cur_B  (alu_in_B),
    .cur_F  (alu_in_F),
    .new_A  (alu_out_A),
    .new_B  (alu_out_B),
    .new_F  (alu_out_F),
    .opcode (alu_opcode)
  );

  logic [7:0] M_addr, M_in, PM_addr, PM_in;
  logic       M_write, PM_write;
  logic [7:0] M_out, PM_out;
  memory M (
    .addr  (M_addr),
    .in    (M_in),
    .write (M_write),
    .out   (M_out),
    .clk   (clk)
  );
  memory #(
    // Program goes here v
    .HEX_FILE("")
  ) PM (
    .addr  (PM_addr),
    .in    (PM_in),
    .write (PM_write),
    .out   (PM_out),
    .clk   (clk)
  );

  logic [7:0] cu_in_instr;
  logic       ru_cs, alu_cs, wu_cs;
  logic       cu_ru_jmp, cu_ru_jmp_cond, cu_ru_call, cu_ru_ret;
  logic [7:0] cu_alu_opcode;
  logic [7:0] cu_wu_new_A, cu_wu_new_B, cu_wu_new_AR, cu_wu_mask, cu_wu_mask_2;
  logic       cu_wu_write_AB, cu_wu_write_AR, cu_wu_do_TAR, cu_wu_use_A;
  logic       cu_wu_load, cu_wu_store, cu_wu_simple_load, cu_wu_simple_store;
  logic [3:0] cu_wu_simple_addr;
  cu cu (
    .instr           (cu_in_instr),

    .ru_cs           (ru_cs),
    .ru_jmp          (cu_ru_jmp),
    .ru_jmp_cond     (cu_ru_jmp_cond),
    .ru_call         (cu_ru_call),
    .ru_ret          (cu_ru_ret),

    .alu_cs          (alu_cs),
    .alu_opcode      (cu_alu_opcode),

    .wu_cs           (wu_cs),
    .wu_new_A        (cu_wu_new_A),
    .wu_new_B        (cu_wu_new_B),
    .wu_write_AB     (cu_wu_write_AB),
    .wu_new_AR       (cu_wu_new_AR),
    .wu_write_AR     (cu_wu_write_AR),
    .wu_do_TAR       (cu_wu_do_TAR),
    .wu_use_A        (cu_wu_use_A),
    .wu_mask         (cu_wu_mask),
    .wu_mask_2       (cu_wu_mask_2),
    .wu_load         (cu_wu_load),
    .wu_store        (cu_wu_store),
    .wu_simple_addr  (cu_wu_simple_addr),
    .wu_simple_load  (cu_wu_simple_load),
    .wu_simple_store (cu_wu_simple_store)
  );

  // Core logic

  // Always connected
  assign ru_in_AR = wu_out_AR;
  assign PM_addr = ru_out_PC;
  assign cu_in_instr = PM_out;
  assign { PM_write, PM_in } = '0;

  // It's muxing time!

  // Blocks are split based on independent destinations
  // Merging the blocks would result in indefinite simulation hangs

  // RU inputs
  always_comb begin
    if (!$isunknown(ru_cs) && !$isunknown(wu_cs) && !$isunknown(alu_cs)) begin
      { ru_jmp, ru_jmp_cond, ru_call, ru_ret }              = '0;
      { ru_in_F, ru_write_F }                               = '0;

      if (ru_cs) begin
        // Connections
        ru_jmp      = cu_ru_jmp;
        ru_jmp_cond = cu_ru_jmp_cond;
        ru_call     = cu_ru_call;
        ru_ret      = cu_ru_ret;
      end

      if (alu_cs) begin
        // Spec logic
        ru_write_F = '1;
        ru_in_F = alu_out_F;
      end
    end else begin
      { ru_jmp, ru_jmp_cond, ru_call, ru_ret }              = 'x;
      { ru_in_F, ru_write_F }                               = 'x;
    end
  end

  // WU inputs, except the memory value
  always_comb begin
    if (!$isunknown(ru_cs) && !$isunknown(wu_cs) && !$isunknown(alu_cs)) begin
      { wu_in_A, wu_in_B, wu_write_AB, wu_use_A }           = '0;
      { wu_mask, wu_mask_2 }                                = '0;
      { wu_in_AR, wu_write_AR, wu_do_TAR }                  = '0;
      { wu_load, wu_store }                                 = '0;
      { wu_simple_addr, wu_simple_load, wu_simple_store }   = '0;

      if (wu_cs) begin
        // Connections
        wu_in_A         = cu_wu_new_A;
        wu_in_B         = cu_wu_new_B;
        wu_write_AB     = cu_wu_write_AB;
        wu_use_A        = cu_wu_use_A;
        wu_mask         = cu_wu_mask;
        wu_mask_2       = cu_wu_mask_2;
        wu_in_AR        = cu_wu_new_AR;
        wu_write_AR     = cu_wu_write_AR;
        wu_do_TAR       = cu_wu_do_TAR;
        wu_load         = cu_wu_load;
        wu_store        = cu_wu_store;
        wu_simple_addr  = cu_wu_simple_addr;
        wu_simple_load  = cu_wu_simple_load;
        wu_simple_store = cu_wu_simple_store;
      end

      if (alu_cs) begin
        // Spec logic
        wu_write_AB = '1;
        { wu_mask, wu_mask_2 } = '1;
        { wu_in_A, wu_in_B } = { alu_out_A, alu_out_B };
      end
    end else begin
      { wu_in_A, wu_in_B, wu_write_AB, wu_use_A }           = 'x;
      { wu_mask, wu_mask_2 }                                = 'x;
      { wu_in_AR, wu_write_AR, wu_do_TAR }                  = 'x;
      { wu_load, wu_store }                                 = 'x;
      { wu_simple_addr, wu_simple_load, wu_simple_store }   = 'x;
    end
  end

  // WU memory value
  always_comb begin
    if (!$isunknown(ru_cs) && !$isunknown(wu_cs) && !$isunknown(alu_cs)) begin
      wu_in_mem = '0;

      if (wu_cs) begin
        // Spec logic
        wu_in_mem = M_out;
      end
    end else begin
      wu_in_mem = 'x;
    end
  end

  // M inputs
  always_comb begin
    if (!$isunknown(ru_cs) && !$isunknown(wu_cs) && !$isunknown(alu_cs)) begin
      { M_addr, M_in, M_write }                             = '0;

      if (wu_cs) begin
        // Spec logic
        M_in = wu_out_mem;
        M_addr = wu_mem_addr;
        M_write = wu_mem_write;
      end
    end else begin
      { M_addr, M_in, M_write }                             = 'x;
    end
  end

  // ALU inputs
  always_comb begin
    if (!$isunknown(ru_cs) && !$isunknown(wu_cs) && !$isunknown(alu_cs)) begin
      { alu_in_A, alu_in_B, alu_in_F, alu_opcode }          = '0;

      if (alu_cs) begin
        // Spec logic
        { alu_in_A, alu_in_B, alu_in_F } = { wu_out_A, wu_out_B, ru_out_F };

        // Connection...!
        alu_opcode = cu_alu_opcode;
      end
    end else begin
      { alu_in_A, alu_in_B, alu_in_F, alu_opcode }          = 'x;
    end
  end

endmodule
