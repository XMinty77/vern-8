/* ================ ALU Testbench ================
 * Baseline:   Exhaustive on ALU Opcodes
 * Exhaustive: Exhaustive on on-ALU OpCodes
 * ===============================================
 */
module alu_tb;

  import opcodes::*;
  import tb_prefs::*;

  logic [7:0] A, B, nA, nB, op;
  logic F, nF;

  alu dut (
    .cur_A (A),
    .cur_B (B),
    .cur_F (F),
    .new_A (nA),
    .new_B (nB),
    .new_F (nF),
    .opcode (op)
  );

  int errors;
  bit exhaustive;

  // Apply one set of inputs, wait for the ALU to settle, then check all three outputs
  // against the expected values. Counts every mismatch in errors and prints the first ERRORS_CAP.
  // a and b stay int, so expected values are calculated with comfortable headroom
  task automatic check(input logic [7:0] opcode, input int a, b, input logic f);
    logic [7:0] exp_A, exp_B;
    logic exp_F;

    op = opcode;
    A = 8'(a);
    B = 8'(b);
    F = f;

    #1;
    exp_A = A;
    exp_B = B;
    exp_F = F;

    case (op)
      INVA: exp_A = ~A;
      INVB: exp_B = ~B;
      ADD: begin
        exp_A = 8'(a + b);
        exp_F = ((a + b) > 255);
      end
      SUB: begin
        exp_A = 8'(a - b);
        exp_F = ((a - b) < 0);
      end
      MUL: begin
        exp_A = 8'(a * b);
        exp_F = ((a * b) > 255);
      end
      DIV: begin
        if (b !== 0) begin
          exp_A = 8'(a / b);
          exp_B = 8'(a % b);
        end

        exp_F = (b === 0);

        assert (b == 0 || a == b * int'(nA) + int'(nB) && nB < B) else begin
          errors++;
          $error("op=%h A=%h B=%h F=%b: division fails check with new_A=%h, new_B=%h", op, A, B, F, nA, nB);
        end
      end
      SWAP: begin
        exp_A = 8'(b);
        exp_B = 8'(A);
      end
      INC: begin
        exp_A = 8'(a + 1);
        exp_F = ((a + 1) > 255);
      end
      AND: exp_A = 8'(a & b);
      NAND: exp_A = 8'(~(a & b));
      OR: exp_A = 8'(a | b);
      NOR: exp_A = 8'(~(a | b));
      XOR: exp_A = 8'(a ^ b);
      XNOR: exp_A = 8'(~(a ^ b));
      SHL: exp_A = 8'(a << b);
      SHR: exp_A = 8'(a >> b);
      EQ: exp_F = (a === b);
      NEQ: exp_F = (a !== b);
      LT: exp_F = (a < b);
      GTE: exp_F = (a >= b);
      GT: exp_F = (a > b);
      LTE: exp_F = (a <= b);
      CLF: exp_F = 0;
      STF: exp_F = 1;
      default: begin
        exp_A = 'x;
        exp_B = 'x;
        exp_F = 'x;
      end
    endcase

    assert (nA === exp_A) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("op=%b A=%h B=%h F=%b: new_A got %h, expected %h", op, A, B, F, nA, exp_A);
    end
    assert (nB === exp_B) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("op=%b A=%h B=%h F=%b: new_B got %h, expected %h", op, A, B, F, nB, exp_B);
    end
    assert (nF === exp_F) else begin
      errors++;
      if (errors <= ERRORS_CAP)
        $error("op=%b A=%h B=%h F=%b: new_F got %h, expected %h", op, A, B, F, nF, exp_F);
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
      if (exhaustive || opcode >= INVA && opcode <= STF)
        for (int a = 0; a < 256; a++) begin
          for (int b = 0; b < 256; b++) begin
            for (int f = 0; f <= 1; f++) begin
              assert (a >= 0 && b >= 0 && a < 256 && b < 256 && (f == 0 || f == 1)) else begin
                errors++;
                $error("a=%h b=%h f=%b: value out of range", A, B, F);
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
