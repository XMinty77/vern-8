/* ================ Memory Implementation ================
 * 256 x 8 memory, used for M and PM.
 * Combinational read, sequential write.
 * =======================================================
 */

module memory #(
  parameter string HEX_FILE = ""
) (
  input  logic [7:0] addr,
  input  logic [7:0] in,
  input  logic       write,
  input  logic       clk,
  output logic [7:0] out
);

  logic [7:0] mem [0:255];

  initial if (HEX_FILE != "") $readmemh(HEX_FILE, mem);

  assign out = mem[addr];

  always_ff @(posedge clk) begin
    if ($isunknown(write) || write && $isunknown(addr)) begin
      if ($isunknown(addr)) begin
        for (int i = 0; i < 256; i++) begin : fill_with_x
          mem[i] <= 'x;
        end
      end else mem[addr] <= 'x;
    end else if (write) mem[addr] <= in;
  end

endmodule
