// Counter with a self-reloading mechanism
module day10 (
  input     wire          clk,
  input     wire          reset,
  input     wire          load_i,
  input     wire[3:0]     load_val_i,
  output    wire[3:0]     count_o
);

  logic[3:0] load_ff;

  // Store the load value whenever load_i is seen
  always_ff @(posedge clk or posedge reset)
    if (reset)
      load_ff <= 4'h0;
    else if (load_i)
      load_ff <= load_val_i;

  // Counter logic
  logic[3:0] count_ff;
  logic[3:0] nxt_count;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      count_ff <= 4'h0;
    else
      count_ff <= nxt_count;

  // Next counter value logic
  assign nxt_count = load_i ? load_val_i :
                              (count_ff == 4'hF) ? load_ff : // Reload on overflow
                              count_ff + 4'h1;

  assign count_o = count_ff;

endmodule




TestBench

module self_reloading_counter_tb ();

  logic          clk;
  logic          reset;
  logic          load_i;
  logic[3:0]     load_val_i;
  logic[3:0]     count_o;

  // Instantiate DUT (Device Under Test)
  self_reloading_counter DUT (.*);

  // Clock generation
  always begin
    clk = 1'b1;
    #5;
    clk = 1'b0;
    #5;
  end

  int cycles;
  initial begin
    $monitor("Time=%0t | Reset=%b | Load=%b | Load_Val=%h | Count=%h",
              $time, reset, load_i, load_val_i, count_o);

    // Initialize signals
    reset <= 1'b1;
    load_i <= 1'b0;
    load_val_i <= 4'h0;
    @(posedge clk);
    
    // Release reset
    reset <= 1'b0;

    // Load values and test reloading behavior
    for (int i = 0; i < 3; i = i + 1) begin
      load_i <= 1;
      load_val_i <= 3 * i; // Load 0, 3, and 6
      cycles = 4'hF - load_val_i; // Wait until counter rolls over
      @(posedge clk);
      load_i <= 0;
      
      while (cycles) begin
        cycles = cycles - 1;
        @(posedge clk);
      end
    end
    
    $finish();
  end

endmodule
