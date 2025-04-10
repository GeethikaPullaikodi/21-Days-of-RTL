// Parameterized FIFO Module
module day19 #(
  parameter DEPTH   = 4,   // Depth of the FIFO (number of entries)
  parameter DATA_W  = 8    // Data width (size of each element in bits)
)(
  input         wire              clk,            // Clock signal
  input         wire              reset,          // Reset signal
  input         wire              push_i,         // Push signal to insert data
  input         wire[DATA_W-1:0]  push_data_i,    // Data to be pushed into FIFO
  input         wire              pop_i,          // Pop signal to remove data
  output        wire[DATA_W-1:0]  pop_data_o,     // Data popped from FIFO
  output        wire              full_o,         // Full flag, FIFO is full
  output        wire              empty_o         // Empty flag, FIFO is empty
);

  // Pointer width based on depth (how many bits are required to address the FIFO)
  parameter PTR_W = $clog2(DEPTH);

  // Internal pointers for reading and writing
  logic [PTR_W-1:0] rd_ptr_q, wr_ptr_q;   // Read and Write pointers
  logic [DATA_W-1:0] fifo_mem[0:DEPTH-1]; // FIFO memory array

  // FIFO output data (popped data)
  assign pop_data_o = fifo_mem[rd_ptr_q];

  // Full and Empty flags
  assign full_o = (wr_ptr_q == rd_ptr_q - 1);
  assign empty_o = (wr_ptr_q == rd_ptr_q);

  // Flops for read and write pointers
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      rd_ptr_q <= 0;
      wr_ptr_q <= 0;
    end else begin
      if (push_i && !full_o)
        wr_ptr_q <= wr_ptr_q + 1;  // Increment write pointer
      if (pop_i && !empty_o)
        rd_ptr_q <= rd_ptr_q + 1;  // Increment read pointer
    end
  end

  // Write data into FIFO when push_i is active
  always_ff @(posedge clk) begin
    if (push_i && !full_o)
      fifo_mem[wr_ptr_q] <= push_data_i;
  end

endmodule

TestBench

module day19_tb();

  // Parameters for the FIFO
  parameter DATA_W = 8;  // Data width (8 bits)
  parameter DEPTH  = 4;  // FIFO depth (4 entries)

  // Testbench signals
  logic clk, reset;
  logic push_i, pop_i;
  logic [DATA_W-1:0] push_data_i;
  wire [DATA_W-1:0] pop_data_o;
  wire full_o, empty_o;

  // Instantiate the FIFO (day19) with parameters
  day19 #(.DEPTH(DEPTH), .DATA_W(DATA_W)) dut (
    .clk(clk),
    .reset(reset),
    .push_i(push_i),
    .push_data_i(push_data_i),
    .pop_i(pop_i),
    .pop_data_o(pop_data_o),
    .full_o(full_o),
    .empty_o(empty_o)
  );

  // Clock generation
  always begin
    clk = 0; #5; clk = 1; #5;  // 10 time units for each clock cycle
  end

  // Stimulus for testing
  initial begin
    reset = 1; push_i = 0; pop_i = 0; push_data_i = 0;
    #10 reset = 0; // Release reset after 10 time units

    // Push 4 elements into the FIFO
    repeat (4) begin
      @(posedge clk);
      push_i = 1; // Assert push signal
      push_data_i = $random; // Assign random data
    end
    push_i = 0; // Deassert push signal

    // Test FIFO full condition
    @(posedge clk);
    if (full_o) $display("FIFO is full");

    // Pop 4 elements from the FIFO
    repeat (4) begin
      @(posedge clk);
      pop_i = 1; // Assert pop signal
      $display("Popped: %0h", pop_data_o); // Display popped data
    end
    pop_i = 0; // Deassert pop signal

    // Test FIFO empty condition
    @(posedge clk);
    if (empty_o) $display("FIFO is empty");

    $finish;
  end

endmodule
