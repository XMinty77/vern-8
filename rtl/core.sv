/* ================ Core ================
 * Top level: instantiates the units and routes signals between them
 * ======================================
 */

module core (
  input logic clk_i,
  input logic rst_i
);

  // ---------------- Units ----------------

  logic [7:0] wu_new_a, wu_new_b, wu_new_ar, wu_mem_rdata, wu_mask_a, wu_mask_b;
  logic       wu_write_ab, wu_use_a, wu_write_ar, wu_do_tar;
  logic       wu_load, wu_store, wu_simple_load, wu_simple_store;
  logic [3:0] wu_simple_addr;
  logic [7:0] wu_a, wu_b, wu_ar, wu_mem_wdata, wu_mem_addr;
  logic       wu_mem_write;
  wu u_wu (
    .clk_i          (clk_i),
    .rst_i          (rst_i),
    .new_a_i        (wu_new_a),
    .new_b_i        (wu_new_b),
    .write_ab_i     (wu_write_ab),
    .use_a_i        (wu_use_a),
    .mask_a_i       (wu_mask_a),
    .mask_b_i       (wu_mask_b),
    .new_ar_i       (wu_new_ar),
    .write_ar_i     (wu_write_ar),
    .do_tar_i       (wu_do_tar),
    .load_i         (wu_load),
    .store_i        (wu_store),
    .simple_addr_i  (wu_simple_addr),
    .simple_load_i  (wu_simple_load),
    .simple_store_i (wu_simple_store),
    .mem_rdata_i    (wu_mem_rdata),
    .a_o            (wu_a),
    .b_o            (wu_b),
    .ar_o           (wu_ar),
    .mem_addr_o     (wu_mem_addr),
    .mem_wdata_o    (wu_mem_wdata),
    .mem_write_o    (wu_mem_write)
  );

  logic       ru_jmp, ru_jmp_cond, ru_call, ru_ret, ru_write_f;
  logic       ru_new_f, ru_f;
  logic [7:0] ru_ar, ru_pc;
  ru u_ru (
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .jmp_i      (ru_jmp),
    .jmp_cond_i (ru_jmp_cond),
    .call_i     (ru_call),
    .ret_i      (ru_ret),
    .new_f_i    (ru_new_f),
    .write_f_i  (ru_write_f),
    .ar_i       (ru_ar),
    .pc_o       (ru_pc),
    .f_o        (ru_f)
  );

  logic [7:0] alu_a, alu_b, alu_new_a, alu_new_b;
  logic       alu_f, alu_new_f;
  logic [7:0] alu_op;
  alu u_alu (
    .a_i     (alu_a),
    .b_i     (alu_b),
    .f_i     (alu_f),
    .new_a_o (alu_new_a),
    .new_b_o (alu_new_b),
    .new_f_o (alu_new_f),
    .op_i    (alu_op)
  );

  logic [7:0] m_addr, m_wdata, pm_addr, pm_wdata;
  logic       m_write, pm_write;
  logic [7:0] m_rdata, pm_rdata;
  memory u_m (
    .clk_i   (clk_i),
    .addr_i  (m_addr),
    .wdata_i (m_wdata),
    .write_i (m_write),
    .rdata_o (m_rdata)
  );
  memory #(
    .HexFile ("")               // Empty: the program is loaded by the bench
  ) u_pm (
    .clk_i   (clk_i),
    .addr_i  (pm_addr),
    .wdata_i (pm_wdata),
    .write_i (pm_write),
    .rdata_o (pm_rdata)
  );

  logic [7:0] cu_instr;
  logic       ru_cs, alu_cs, wu_cs;
  logic       cu_ru_jmp, cu_ru_jmp_cond, cu_ru_call, cu_ru_ret;
  logic [7:0] cu_alu_op;
  logic [7:0] cu_wu_new_a, cu_wu_new_b, cu_wu_new_ar, cu_wu_mask_a, cu_wu_mask_b;
  logic       cu_wu_write_ab, cu_wu_write_ar, cu_wu_do_tar, cu_wu_use_a;
  logic       cu_wu_load, cu_wu_store, cu_wu_simple_load, cu_wu_simple_store;
  logic [3:0] cu_wu_simple_addr;
  cu u_cu (
    .instr_i           (cu_instr),

    .ru_cs_o           (ru_cs),
    .ru_jmp_o          (cu_ru_jmp),
    .ru_jmp_cond_o     (cu_ru_jmp_cond),
    .ru_call_o         (cu_ru_call),
    .ru_ret_o          (cu_ru_ret),

    .alu_cs_o          (alu_cs),
    .alu_op_o          (cu_alu_op),

    .wu_cs_o           (wu_cs),
    .wu_new_a_o        (cu_wu_new_a),
    .wu_new_b_o        (cu_wu_new_b),
    .wu_write_ab_o     (cu_wu_write_ab),
    .wu_new_ar_o       (cu_wu_new_ar),
    .wu_write_ar_o     (cu_wu_write_ar),
    .wu_do_tar_o       (cu_wu_do_tar),
    .wu_use_a_o        (cu_wu_use_a),
    .wu_mask_a_o       (cu_wu_mask_a),
    .wu_mask_b_o       (cu_wu_mask_b),
    .wu_load_o         (cu_wu_load),
    .wu_store_o        (cu_wu_store),
    .wu_simple_addr_o  (cu_wu_simple_addr),
    .wu_simple_load_o  (cu_wu_simple_load),
    .wu_simple_store_o (cu_wu_simple_store)
  );

  // ---------------- Routing ----------------

  // Fixed connections
  assign ru_ar                  = wu_ar;
  assign pm_addr                = ru_pc;
  assign cu_instr               = pm_rdata;
  assign { pm_write, pm_wdata } = '0;

  // An x or z on any unit select makes every routed input x
  logic cs_known;
  assign cs_known = !$isunknown(ru_cs) && !$isunknown(wu_cs) && !$isunknown(alu_cs);

  // One block per destination unit. A single block would read signals that
  // depend on its own outputs (through the units), so it would keep
  // re-triggering itself and the simulation would hang.

  // RU inputs
  always_comb begin
    if (cs_known) begin
      { ru_jmp, ru_jmp_cond, ru_call, ru_ret } = '0;
      { ru_new_f, ru_write_f } = '0;

      if (ru_cs) begin
        ru_jmp      = cu_ru_jmp;
        ru_jmp_cond = cu_ru_jmp_cond;
        ru_call     = cu_ru_call;
        ru_ret      = cu_ru_ret;
      end

      if (alu_cs) begin
        ru_write_f = '1;
        ru_new_f   = alu_new_f;
      end
    end else begin
      { ru_jmp, ru_jmp_cond, ru_call, ru_ret } = 'x;
      { ru_new_f, ru_write_f } = 'x;
    end
  end

  // WU inputs, except the memory value
  always_comb begin
    if (cs_known) begin
      { wu_new_a, wu_new_b, wu_write_ab, wu_use_a } = '0;
      { wu_mask_a, wu_mask_b } = '0;
      { wu_new_ar, wu_write_ar, wu_do_tar } = '0;
      { wu_load, wu_store } = '0;
      { wu_simple_addr, wu_simple_load, wu_simple_store } = '0;

      if (wu_cs) begin
        wu_new_a        = cu_wu_new_a;
        wu_new_b        = cu_wu_new_b;
        wu_write_ab     = cu_wu_write_ab;
        wu_use_a        = cu_wu_use_a;
        wu_mask_a       = cu_wu_mask_a;
        wu_mask_b       = cu_wu_mask_b;
        wu_new_ar       = cu_wu_new_ar;
        wu_write_ar     = cu_wu_write_ar;
        wu_do_tar       = cu_wu_do_tar;
        wu_load         = cu_wu_load;
        wu_store        = cu_wu_store;
        wu_simple_addr  = cu_wu_simple_addr;
        wu_simple_load  = cu_wu_simple_load;
        wu_simple_store = cu_wu_simple_store;
      end

      if (alu_cs) begin
        wu_write_ab = '1;
        { wu_mask_a, wu_mask_b } = '1;
        { wu_new_a, wu_new_b } = { alu_new_a, alu_new_b };
      end
    end else begin
      { wu_new_a, wu_new_b, wu_write_ab, wu_use_a } = 'x;
      { wu_mask_a, wu_mask_b } = 'x;
      { wu_new_ar, wu_write_ar, wu_do_tar } = 'x;
      { wu_load, wu_store } = 'x;
      { wu_simple_addr, wu_simple_load, wu_simple_store } = 'x;
    end
  end

  // WU memory value
  always_comb begin
    if (cs_known) begin
      wu_mem_rdata = '0;

      if (wu_cs) wu_mem_rdata = m_rdata;
    end else begin
      wu_mem_rdata = 'x;
    end
  end

  // M inputs
  always_comb begin
    if (cs_known) begin
      { m_addr, m_wdata, m_write } = '0;

      if (wu_cs) begin
        m_wdata = wu_mem_wdata;
        m_addr  = wu_mem_addr;
        m_write = wu_mem_write;
      end
    end else begin
      { m_addr, m_wdata, m_write } = 'x;
    end
  end

  // ALU inputs
  always_comb begin
    if (cs_known) begin
      { alu_a, alu_b, alu_f, alu_op } = '0;

      if (alu_cs) begin
        { alu_a, alu_b, alu_f } = { wu_a, wu_b, ru_f };
        alu_op = cu_alu_op;
      end
    end else begin
      { alu_a, alu_b, alu_f, alu_op } = 'x;
    end
  end

endmodule
