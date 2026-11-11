/* ================ ALU ================
 * Combinational ALU: computes new A, B and F from the current ones
 * =====================================
 */

module alu (
  input  logic [7:0] op_i,      // Full instruction byte, non-ALU opcodes give x outputs
  input  logic [7:0] a_i,
  input  logic [7:0] b_i,
  input  logic       f_i,
  output logic [7:0] new_a_o,
  output logic [7:0] new_b_o,
  output logic       new_f_o
);

  import opcodes::*;

  always_comb begin
    logic [15:0] product;       // Full product, the high byte sets F (overflow)
    product = 'x;

    { new_a_o, new_b_o, new_f_o } = { a_i, b_i, f_i };

    case (op_i)
      // Arithmetic
      Add:  { new_f_o, new_a_o } = a_i + b_i;
      Sub:  { new_f_o, new_a_o } = a_i - b_i;
      Mul: begin
        product = a_i * b_i;
        new_a_o = product[7:0];
        new_f_o = |product[15:8];
      end
      Div: begin
        // TODO: Consider a divider that computes quotient and remainder
        //       together, since separate / and % may synthesize to two dividers
        if ($isunknown(b_i))  { new_f_o, new_a_o, new_b_o } = 'x;
        else if (b_i == '0)   new_f_o = 1'b1;
        else begin
          new_f_o = 1'b0;
          new_a_o = a_i / b_i;
          new_b_o = a_i % b_i;
        end
      end
      Inc:  { new_f_o, new_a_o } = a_i + 9'b1;

      // Bitwise
      Inva: new_a_o = ~a_i;
      Invb: new_b_o = ~b_i;
      And:  new_a_o = a_i & b_i;
      Nand: new_a_o = ~(a_i & b_i);
      Or:   new_a_o = a_i | b_i;
      Nor:  new_a_o = ~(a_i | b_i);
      Xor:  new_a_o = a_i ^ b_i;
      Xnor: new_a_o = ~(a_i ^ b_i);
      Shl:  new_a_o = a_i << b_i;
      Shr:  new_a_o = a_i >> b_i;

      // Conditions
      Eq:   new_f_o = a_i == b_i;
      Neq:  new_f_o = a_i != b_i;
      Lt:   new_f_o = a_i <  b_i;
      Gt:   new_f_o = a_i >  b_i;
      Lte:  new_f_o = a_i <= b_i;
      Gte:  new_f_o = a_i >= b_i;
      Clf:  new_f_o = 1'b0;
      Stf:  new_f_o = 1'b1;

      // Misc
      Swap: { new_a_o, new_b_o } = { b_i, a_i };

      default: { new_a_o, new_b_o, new_f_o } = 'x;
    endcase
  end

endmodule
