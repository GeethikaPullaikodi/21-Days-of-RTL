module day12(
  
  input     wire        clk,     // Clock
  input     wire        reset,   // Reset
  input     wire        x_i,     // Serial input

  output    wire        det_o    // Output high when sequence detected
);

  // Shift register to store incoming bits
  logic [11:0] shift_ff;
  logic [11:0] nxt_shift;

  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      shift_ff <= 12'h0;  // Reset the shift register
    else
      shift_ff <= nxt_shift;  // Shift and store new value
  end

  // Shift operation: Left shift and insert new bit at LSB
  assign nxt_shift = {shift_ff[10:0], x_i};

  // Detect when the stored bits match the target sequence
  assign det_o = (shift_ff == 12'b1110_1101_1011);

endmodule

TestBench

module day12_tb;

  // Declare signals
  logic clk;
  logic reset;
  logic x_i;
  logic det_o;

  // Instantiate the sequence detector
 day12 DUT (
    .clk(clk),
    .reset(reset),
    .x_i(x_i),
    .det_o(det_o)
  );

  // Clock generation (10ns period -> 5ns high, 5ns low)
  always begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
  end

  // Sequence to be detected: 1110_1101_1011
  logic [11:0] seq = 12'b1110_1101_1011;

  // Test process
  initial begin
    reset = 1;  // Apply reset
    x_i = 0;  
    @(posedge clk);
    reset = 0;  // Release reset
    @(posedge clk);

    // Send the exact sequence bit by bit
    for (int i = 0; i < 12; i++) begin
      x_i = seq[i];
      @(posedge clk);
    end

    // Random bits to check for false positives
    for (int i = 0; i < 10; i++) begin
      x_i = $random % 2;
      @(posedge clk);
    end

    $finish;  // End simulation
  end

endmodule
