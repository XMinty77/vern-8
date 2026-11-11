/* ================ RU ================
 * Running unit: holds PC, F, the call stack S and the call depth D
 * ====================================
 */

module ru (
  input  logic       clk_i,
  input  logic       rst_i,
  input  logic       jmp_i,
  input  logic       jmp_cond_i,
  input  logic       call_i,
  input  logic       ret_i,
  input  logic       new_f_i,
  input  logic       write_f_i,
  input  logic [7:0] ar_i,
  output logic [7:0] pc_o,
  output logic       f_o
);

  localparam int                         StackDepth      = 4;
  localparam int                         StackDepthWidth = $clog2(StackDepth + 1);  // +1 for d_q = 0
  localparam logic [StackDepthWidth-1:0] StackMax        = StackDepthWidth'(StackDepth);

  logic [7:0]                 pc_q;
  logic                       f_q;
  logic [StackDepth-1:0][7:0] s_q;
  logic [StackDepthWidth-1:0] d_q;

  assign pc_o = pc_q;
  assign f_o  = f_q;

  always_ff @(posedge clk_i) begin
    if ($isunknown(rst_i))  { pc_q, f_q, s_q, d_q } <= 'x;
    else if (rst_i)         { pc_q, f_q, s_q, d_q } <= '0;
    else if (jmp_i && !call_i && !ret_i && !write_f_i) begin
      if ($isunknown(jmp_cond_i) || (jmp_cond_i && $isunknown(f_q)))  pc_q <= 'x;
      else if (!jmp_cond_i || f_q)                                    pc_q <= ar_i;
      else                                                            pc_q <= pc_q + 8'd1;
    end else if (!jmp_i && !jmp_cond_i && call_i && !ret_i && !write_f_i) begin
      s_q  <= { s_q[StackDepth-2:0], pc_q + 8'd1 };
      pc_q <= ar_i;
      if ($isunknown(d_q))        d_q <= 'x;
      else if (d_q != StackMax)   d_q <= d_q + 1'b1;
    end else if (!jmp_i && !jmp_cond_i && !call_i && ret_i && !write_f_i) begin
      if ($isunknown(d_q)) begin
        { pc_q, s_q, d_q } <= 'x;
      end else if (d_q != '0) begin
        { s_q, pc_q } <= { 8'h00, s_q };
        d_q           <= d_q - 1'b1;
      end else begin
        pc_q <= pc_q + 8'd1;      // RET at depth 0: no-op
      end
    end else if (!jmp_i && !jmp_cond_i && !call_i && !ret_i && write_f_i) begin
      f_q  <= new_f_i;
      pc_q <= pc_q + 8'd1;
    end else if (!jmp_i && !jmp_cond_i && !call_i && !ret_i && !write_f_i) begin
      pc_q <= pc_q + 8'd1;        // Nothing selected: step once
    end else begin
      { pc_q, f_q, s_q, d_q } <= 'x;
    end
  end

endmodule
