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
    if (write) mem[addr] <= in;
  end

endmodule
