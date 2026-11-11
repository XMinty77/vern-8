/* ================ WU ================
 * Working unit: holds A, B and AR, and drives the memory interface
 * ====================================
 */

module wu (
  input  logic       clk_i,
  input  logic       rst_i,
  input  logic [7:0] new_a_i,
  input  logic [7:0] new_b_i,
  input  logic       write_ab_i,
  input  logic       use_a_i,
  input  logic [7:0] mask_a_i,
  input  logic [7:0] mask_b_i,
  input  logic [7:0] new_ar_i,
  input  logic       write_ar_i,
  input  logic       do_tar_i,
  input  logic       load_i,
  input  logic       store_i,
  input  logic [3:0] simple_addr_i,
  input  logic       simple_load_i,
  input  logic       simple_store_i,
  input  logic [7:0] mem_rdata_i,
  output logic [7:0] a_o,
  output logic [7:0] b_o,
  output logic [7:0] ar_o,
  output logic [7:0] mem_addr_o,
  output logic [7:0] mem_wdata_o,
  output logic       mem_write_o
);

  localparam logic [6:0] CmdNothing     = 7'b000_0000;
  localparam logic [6:0] CmdWriteAb     = 7'b100_0000;
  localparam logic [6:0] CmdWriteAr     = 7'b010_0000;
  localparam logic [6:0] CmdDoTar       = 7'b001_0000;
  localparam logic [6:0] CmdLoad        = 7'b000_1000;
  localparam logic [6:0] CmdStore       = 7'b000_0100;
  localparam logic [6:0] CmdSimpleLoad  = 7'b000_0010;
  localparam logic [6:0] CmdSimpleStore = 7'b000_0001;

  logic [7:0] a_q, b_q, ar_q;

  assign a_o  = a_q;
  assign b_o  = b_q;
  assign ar_o = ar_q;

  logic [6:0] cmd;
  assign cmd = { write_ab_i, write_ar_i, do_tar_i, load_i, store_i, simple_load_i, simple_store_i };

  function automatic logic [7:0] masked_merge (
    logic [7:0] new_value,
    logic [7:0] old_value,
    logic [7:0] merge_mask
  );
    return (new_value & merge_mask) | (old_value & ~merge_mask);
  endfunction

  // Register a store writes to memory
  logic [7:0] store_val;
  always_comb begin
    if ($isunknown(use_a_i))  store_val = 'x;
    else if (use_a_i)         store_val = a_q;
    else                      store_val = b_q;
  end

  // Memory interface
  always_comb begin
    { mem_wdata_o, mem_addr_o, mem_write_o } = '0;

    if ($isunknown(rst_i) || $isunknown(cmd))  { mem_wdata_o, mem_addr_o, mem_write_o } = 'x;
    else if (rst_i)                            { mem_wdata_o, mem_addr_o, mem_write_o } = '0;
    else begin
      case (cmd)
        CmdLoad: begin
          mem_addr_o  = ar_q;
          mem_write_o = '0;
        end
        CmdSimpleLoad: begin
          mem_addr_o  = 8'(simple_addr_i);
          mem_write_o = '0;
        end
        CmdStore: begin
          mem_addr_o  = ar_q;
          mem_wdata_o = store_val;
          mem_write_o = '1;
        end
        CmdSimpleStore: begin
          mem_addr_o  = 8'(simple_addr_i);
          mem_wdata_o = store_val;
          mem_write_o = '1;
        end
        CmdNothing,
        CmdWriteAb,
        CmdWriteAr,
        CmdDoTar: ;                         // No memory access
        default: { mem_wdata_o, mem_addr_o, mem_write_o } = '0;  // Disallowed: write must never be x
      endcase
    end
  end

  // Registers
  always_ff @(posedge clk_i) begin
    if ($isunknown(rst_i))  { a_q, b_q, ar_q } <= 'x;
    else if (rst_i)         { a_q, b_q, ar_q } <= '0;
    else begin
      case (cmd)
        CmdWriteAb: begin
          a_q <= masked_merge(new_a_i, a_q, mask_a_i);
          b_q <= masked_merge(new_b_i, b_q, mask_b_i);
        end
        CmdWriteAr:     ar_q <= masked_merge(new_ar_i, ar_q, mask_a_i);
        CmdDoTar:       ar_q <= a_q;
        CmdLoad,
        CmdSimpleLoad: begin
          if ($isunknown(use_a_i))  { a_q, b_q } <= 'x;
          else if (use_a_i)         a_q <= mem_rdata_i;
          else                      b_q <= mem_rdata_i;
        end
        CmdNothing,
        CmdStore,
        CmdSimpleStore: ;                   // No register change
        default:        { a_q, b_q, ar_q } <= 'x;
      endcase
    end
  end

endmodule
