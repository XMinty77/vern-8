/* ================ ALU Testbench ================
 * Baseline:   Exhaustive on ALU Opcodes
 * Exhaustive: Exhaustive on on-ALU OpCodes
 * ===============================================
 */
module alu_tb;

  import opcodes::*;
  import tb_prefs::*;

  logic [7:0] a_i, b_i, new_a_o, new_b_o, op_i;
  logic f_i, new_f_o;

  alu dut (
    .a_i     (a_i),
    .b_i     (b_i),
    .f_i     (f_i),
    .new_a_o (new_a_o),
    .new_b_o (new_b_o),
    .new_f_o (new_f_o),
    .op_i    (op_i)
  );

  int errors;
  bit exhaustive;

  // Apply one set of inputs, wait for the ALU to settle, then check all three outputs
  // against the expected values. Counts every mismatch in errors and prints the first ErrorsCap.
  // a and b stay int, so expected values are calculated with comfortable headroom
  task automatic check(input logic [7:0] opcode, input int a, b, input logic f);
    logic [7:0] exp_a, exp_b;
    logic exp_f;

    op_i = opcode;
    a_i = 8'(a);
    b_i = 8'(b);
    f_i = f;

    #1;
    exp_a = a_i;
    exp_b = b_i;
    exp_f = f_i;

    case (op_i)
      Inva: exp_a = ~a_i;
      Invb: exp_b = ~b_i;
      Add: begin
        exp_a = 8'(a + b);
        exp_f = ((a + b) > 255);
      end
      Sub: begin
        exp_a = 8'(a - b);
        exp_f = ((a - b) < 0);
      end
      Mul: begin
        exp_a = 8'(a * b);
        exp_f = ((a * b) > 255);
      end
      Div: begin
        if (b !== 0) begin
          exp_a = 8'(a / b);
          exp_b = 8'(a % b);
        end

        exp_f = (b === 0);

        assert (b == 0 || a == b * int'(new_a_o) + int'(new_b_o) && new_b_o < b_i) else begin
          errors++;
          $error("op=%h A=%h B=%h F=%b: division fails check with new_a_o=%h, new_b_o=%h", op_i, a_i, b_i, f_i, new_a_o, new_b_o);
        end
      end
      Swap: begin
        exp_a = 8'(b);
        exp_b = 8'(a_i);
      end
      Inc: begin
        exp_a = 8'(a + 1);
        exp_f = ((a + 1) > 255);
      end
      And: exp_a = 8'(a & b);
      Nand: exp_a = 8'(~(a & b));
      Or: exp_a = 8'(a | b);
      Nor: exp_a = 8'(~(a | b));
      Xor: exp_a = 8'(a ^ b);
      Xnor: exp_a = 8'(~(a ^ b));
      Shl: exp_a = 8'(a << b);
      Shr: exp_a = 8'(a >> b);
      Eq: exp_f = (a === b);
      Neq: exp_f = (a !== b);
      Lt: exp_f = (a < b);
      Gte: exp_f = (a >= b);
      Gt: exp_f = (a > b);
      Lte: exp_f = (a <= b);
      Clf: exp_f = 0;
      Stf: exp_f = 1;
      default: begin
        exp_a = 'x;
        exp_b = 'x;
        exp_f = 'x;
      end
    endcase

    assert (new_a_o === exp_a) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("op=%b A=%h B=%h F=%b: new_a_o got %h, expected %h", op_i, a_i, b_i, f_i, new_a_o, exp_a);
    end
    assert (new_b_o === exp_b) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("op=%b A=%h B=%h F=%b: new_b_o got %h, expected %h", op_i, a_i, b_i, f_i, new_b_o, exp_b);
    end
    assert (new_f_o === exp_f) else begin
      errors++;
      if (errors <= ErrorsCap)
        $error("op=%b A=%h B=%h F=%b: new_f_o got %h, expected %h", op_i, a_i, b_i, f_i, new_f_o, exp_f);
    end
  endtask

  initial begin
    exhaustive = $test$plusargs("exhaustive");
    errors = 0;

    if (exhaustive)
      $display("ALU EXHAUSTIVE TEST START.");
    else
      $display("ALU TEST START.");

    for (int opcode = 0; opcode < 256; opcode++) begin
      if (exhaustive || opcode >= Inva && opcode <= Stf)
        for (int a = 0; a < 256; a++) begin
          for (int b = 0; b < 256; b++) begin
            for (int f = 0; f <= 1; f++) begin
              assert (a >= 0 && b >= 0 && a < 256 && b < 256 && (f == 0 || f == 1)) else begin
                errors++;
                $error("a=%h b=%h f=%b: value out of range", a_i, b_i, f_i);
              end

              check(8'(opcode), a, b, 1'(f));
            end
          end
        end
      else begin
        check(8'(opcode), 0, 0, 0);
        check(8'(opcode), 0, 0, 1);
      end
    end

    if (errors == 0) begin
      if (exhaustive)
        $display("ALU EXHAUSTIVE TEST PASSED!");
      else
        $display("ALU TEST PASSED!");
      $finish;
    end
    else
      $fatal(1, "ALU TEST FAILED WITH %0d ERRORS!", errors);

  end

endmodule
