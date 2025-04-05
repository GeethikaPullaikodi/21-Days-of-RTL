module day11 (
  input  logic       clk,
  input  logic       reset,

  output logic       empty_o,
  input  logic [3:0] parallel_i,
  
  output logic       serial_o,
  output logic       valid_o
);

  // Shift register for parallel-to-serial conversion
  logic [3:0] shift_ff, nxt_shift;
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      shift_ff <= 4'h0;   // Reset shift register
    else
      shift_ff <= nxt_shift; // Update shift register
  end

  // Load new parallel data when empty, otherwise shift right
  assign nxt_shift = empty_o ? parallel_i : {1'b0, shift_ff[3:1]};

  // Serial output from LSB
  assign serial_o = shift_ff[0];

  // Counter to manage empty and valid signals
  logic [2:0] count_ff, nxt_count;

  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      count_ff <= 3'h0;   // Reset counter
    else
      count_ff <= nxt_count;  // Update counter
  end

  // Count cycles to track serial output
  assign nxt_count = (count_ff == 3'h4) ? 3'h0 : count_ff + 3'h1;

  // Output valid when count > 0
  assign valid_o = |count_ff;

  // Output empty when counter is 0
  assign empty_o = (count_ff == 3'h0);

endmodule


TestBench

module day11_tb;

  logic       clk;
  logic       reset;
  logic       empty_o;
  logic [3:0] parallel_i;
  logic       serial_o;
  logic       valid_o;

  // Instantiate DUT
  day11 dut (
    .clk(clk),
    .reset(reset),
    .empty_o(empty_o),
    .parallel_i(parallel_i),
    .serial_o(serial_o),
    .valid_o(valid_o)
  );

  // Clock Generation (10 ns period)
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    $display("Starting Simulation...");
    
    // Initialize signals
    clk = 0;
    reset = 1;
    parallel_i = 4'h0;
    #10;

    reset = 0;
    #10;

    // Apply random test cases
    for (int i = 0; i < 10; i++) begin
      parallel_i = $urandom_range(0, 15); // Random 4-bit input
      @(posedge clk);
      $display("Input: %b, Serial Output: %b, Valid: %b, Empty: %b", 
                parallel_i, serial_o, valid_o, empty_o);
    end
    
    $finish;
  end

endmodule
