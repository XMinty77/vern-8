/* ================ WU Implementation ================
 * WU implementation as per spec
 * Holds A, B, AR and handles memory L/S.
 * ===================================================
 */

module wu (
  input  logic [7:0] new_A,
  input  logic [7:0] new_B,
  input  logic       write_AB,
  input  logic       use_A,
  input  logic [7:0] mask,
  input  logic [7:0] mask_2,
  input  logic [7:0] new_AR,
  input  logic       write_AR,
  input  logic       do_TAR,
  input  logic       load,
  input  logic       store,
  input  logic [3:0] simple_addr,
  input  logic       simple_load,
  input  logic       simple_store,
  input  logic [7:0] mem_val_in,
  input  logic       clk,
  input  logic       rst,
  output logic [7:0] A,
  output logic [7:0] B,
  output logic [7:0] AR,
  output logic [7:0] mem_addr,
  output logic [7:0] mem_val_out,
  output logic       mem_write
);

  // TODO: Refactor into a nicer shape
  logic only_write_AB;
  logic only_write_AR;
  logic only_do_TAR;
  logic only_load;
  logic only_store;
  logic only_simple_load;
  logic only_simple_store;

  assign only_write_AB     = write_AB & !write_AR & !do_TAR & !load & !store & !simple_load & !simple_store;
  assign only_write_AR     = !write_AB & write_AR & !do_TAR & !load & !store & !simple_load & !simple_store;
  assign only_do_TAR       = !write_AB & !write_AR & do_TAR & !load & !store & !simple_load & !simple_store;
  assign only_load         = !write_AB & !write_AR & !do_TAR & load & !store & !simple_load & !simple_store;
  assign only_store        = !write_AB & !write_AR & !do_TAR & !load & store & !simple_load & !simple_store;
  assign only_simple_load  = !write_AB & !write_AR & !do_TAR & !load & !store & simple_load & !simple_store;
  assign only_simple_store = !write_AB & !write_AR & !do_TAR & !load & !store & !simple_load & simple_store;

  // Internal state
  logic [7:0] _A;
  logic [7:0] _B;
  logic [7:0] _AR;

  // Expose always
  assign A = _A;
  assign B = _B;
  assign AR = _AR;

  // Combinational outputs
  always_comb begin
    mem_val_out = '0;
    mem_addr = '0;
    mem_write ='0;

    if (~rst) begin
      if (only_load) begin
        mem_addr = _AR;
        mem_write = '0;
      end else if (only_simple_load) begin
        mem_addr = 8'(simple_addr);
        mem_write = '0;
      end else if (only_store) begin
        mem_addr = _AR;
        mem_write = '1;
      end else if (only_simple_store) begin
        mem_addr = 8'(simple_addr);
        mem_write = '1;
      end
      
      if (only_store | only_simple_store) begin
        if (use_A) mem_val_out = _A;
        else       mem_val_out = _B;
      end
    end
  end

  // Pos edge sequential logic
  always_ff @(posedge clk) begin
    if (rst) begin
      // Reset overrides everything
      _A <= '0;
      _B <= '0;
      _AR <= '0;
    end else begin
      if (only_write_AB) begin
        _A <=  (new_A & mask) | (_A & ~mask);
        _B <=  (new_B & mask_2) | (_B & ~mask_2);
      end else if (only_write_AR) begin
        _AR <= (new_AR & mask) | (_AR & ~mask);
      end else if (only_do_TAR) begin
        _AR <= _A;
      end else if (only_load | only_simple_load) begin
        if (use_A) _A <= mem_val_in;
        else       _B <= mem_val_in;
      end else if (only_store | only_simple_store) begin
          // Handled by combinational output
      end else if (!write_AB & !write_AR & !do_TAR & !load & !store & !simple_load & !simple_store) begin
        // Do nothing??
      end else begin
        _A <= 'x;
        _B <= 'x;
        _AR <= 'x;
      end
    end
  end

endmodule
