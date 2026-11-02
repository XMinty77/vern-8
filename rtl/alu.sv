/* ================ ALU Implementation ================
 * Simple combinational ALU as per spec
 * Relies on SV for hardware arithmetic operations
 * TODO: Consider doing a div alg that computes quotient and remainder
    together, since separate / and % may synthesize to two dividers
 * ====================================================
 */

module alu (
  input  logic [7:0] opcode,    // The full instruction byte, non-ALU opcodes give x outputs
  input  logic [7:0] cur_A,     // The current value of A
  input  logic [7:0] cur_B,     // The current value of B
  input  logic       cur_F,     // The current flag value
  output logic [7:0] new_A,     // The computed new value of A
  output logic [7:0] new_B,     // The computed new value of B
  output logic       new_F      // The computed new flag
);
  // Import opcodes package
  import opcodes::*;

  // Combinational
  always_comb begin
    // Used for holding multiplication result for OF detection
    logic [15:0] mul_tmp;

    // Garbage by default
    mul_tmp = 'x;

    // Passthrough current values by default
    new_A = cur_A;
    new_B = cur_B;
    new_F = cur_F;

    // Switch by opcode
    case (opcode)
      // Arithmetic
      ADD:
        { new_F, new_A } = cur_A + cur_B;
      SUB:
        { new_F, new_A } = cur_A - cur_B;
      MUL: begin
        mul_tmp = cur_A * cur_B;
        new_A = mul_tmp[7:0];
        new_F = |mul_tmp[15:8];
      end
      DIV: begin
        new_F = ( cur_B == '0 );
        if (~new_F) begin
          new_A = cur_A / cur_B;
          new_B = cur_A % cur_B;
        end
      end

      INC:
        { new_F, new_A } = cur_A + 1'b1;

      // Bitwise
      INVA:
        new_A = ~cur_A;
      INVB:
        new_B = ~cur_B;

      AND:
        new_A = cur_A & cur_B;
      NAND:
        new_A = ~(cur_A & cur_B);
      OR:
        new_A = cur_A | cur_B;
      NOR:
        new_A = ~(cur_A | cur_B);
      XOR:
        new_A = cur_A ^ cur_B;
      XNOR:
        new_A = ~(cur_A ^ cur_B);

      SHL:
        new_A = cur_A << cur_B;
      SHR:
        new_A = cur_A >> cur_B;

      // Conditions
      EQ:
        new_F = cur_A == cur_B;
      NEQ:
        new_F = ~(cur_A == cur_B);
      LT:
        new_F = cur_A < cur_B;
      GT:
        new_F = cur_A > cur_B;
      LTE:
        new_F = cur_A <= cur_B;
      GTE:
        new_F = cur_A >= cur_B;

      CLF:
        new_F = 0;
      STF:
        new_F = 1;

      // Misc
      SWAP:
        { new_A, new_B } = { cur_B, cur_A };

      default:
        { new_A, new_B, new_F } = 'x;
    endcase
  end

endmodule
