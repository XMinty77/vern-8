/* ================ RU Implementation ================
 * RU implementation as per spec
 * Holds PC, F, call stack S, call depth D
 * Reset pulls all internal states to zero
 * ===================================================
 */

module ru (
  input  logic       jmp,
  input  logic       jmp_cond,
  input  logic       call,
  input  logic       ret,
  input  logic       new_F,
  input  logic       write_F,
  input  logic [7:0] AR,
  input  logic       clk,
  input  logic       rst,
  output logic [7:0] PC,
  output logic       F
);

  // Internal state
  logic [7:0] _PC;
  logic _F;
  logic [3:0][7:0] S;
  logic [2:0] D;

  // Expose always
  assign PC = _PC;
  assign F = _F;

  // Pos edge sequential logic
  always_ff @(posedge clk) begin
    if ($isunknown(rst))
      { _PC, _F, S, D } <= 'x;
    else begin
      if (rst) begin
        // Reset overrides everything
        _F <= '0;
        _PC <= '0;
        S[0] <= '0;
        S[1] <= '0;
        S[2] <= '0;
        S[3] <= '0;
        D <= '0;
      end else begin
        // No reset signal
        if (jmp && !call && !ret && !write_F) begin
          if ($isunknown(jmp_cond) || jmp_cond && $isunknown(_F)) _PC <= 'x;
          else begin
            if (!jmp_cond || jmp_cond && F) _PC <= AR;  // Non-conditional or conditional with true condition
            else _PC <= _PC + 1;                        // Failed condition
          end
        end else if (!jmp && !jmp_cond && call && !ret && !write_F) begin
          // Push down the stack
          S[3] <= S[2];
          S[2] <= S[1];
          S[1] <= S[0];
          S[0] <= _PC + 1;
          _PC <= AR;

          // Increase depth if applicable
          if ($isunknown(D)) { D } <= 'x;
          else if (D != 3'd4) D <= D + 1;
        end else if (!jmp && !jmp_cond && !call && ret && !write_F) begin
          if ($isunknown(D)) { _PC, S, D } <= 'x;
          else begin
            // Return only if applicable
            if (D != 3'd0) begin
              // Pop from the stack
              _PC <= S[0];
              S[0] <= S[1];
              S[1] <= S[2];
              S[2] <= S[3];
              S[3] <= 0;

              // Decrease depth
              D <= D - 1;
            end else _PC <= _PC + 1;
          end
        end else if (!jmp && !jmp_cond && !call && !ret && write_F) begin
          // Write new F and step PC
          _F <= new_F;
          _PC <= _PC + 1;
        end else if (!jmp && !jmp_cond && !call && !ret && !write_F) begin
          // Nothing to do, just step PC
          _PC <= _PC + 1;
        end else begin
          // Unsupported combination of signals
          _PC <= 'x;
          _F <= 'x;
          D <= 'x;
          S[0] <= 'x;
          S[1] <= 'x;
          S[2] <= 'x;
          S[3] <= 'x;
        end
      end
    end
  end

endmodule
