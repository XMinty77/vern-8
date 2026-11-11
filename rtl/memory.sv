/* ================ Memory ================
 * 256 x 8 memory, used for M and PM
 * Combinational read, synchronous write
 * ========================================
 */

module memory #(
  parameter string HexFile = ""
) (
  input  logic       clk_i,
  input  logic [7:0] addr_i,
  input  logic [7:0] wdata_i,
  input  logic       write_i,
  output logic [7:0] rdata_o
);

  logic [7:0] mem [0:255];

  initial if (HexFile != "") $readmemh(HexFile, mem);

  assign rdata_o = mem[addr_i];

  always_ff @(posedge clk_i) begin
    if ($isunknown(write_i) || (write_i && $isunknown(addr_i))) begin
      if ($isunknown(addr_i)) begin
        for (int i = 0; i < 256; i++) begin : fill_with_x
          mem[i] <= 'x;
        end
      end else mem[addr_i] <= 'x;
    end else if (write_i) mem[addr_i] <= wdata_i;
  end

endmodule
