//Let's break the whole thing down step-by-step, from understanding the problem to why day3 and day7 are included, in the simplest possible way.

//Problem Breakdown
//You’re tasked with designing and verifying a memory interface that uses the valid/ready protocol. 
//This interface handles requests to read from or write to a memory array, which has the following characteristics:

//Memory is 16 locations wide, each location can hold 32 bits.

//The system should respond to requests with a delay (this makes the system behave more like a real-world system where memory access isn’t instant).

//1. Memory Interface and Valid/Ready Protocol
//The valid/ready protocol is a way for devices to communicate without needing to know the exact timing of when the other device is ready to proceed.
//req_i (valid): This signal tells the memory that a request is being made. The device is requesting data (read or write).
//req_ready_o (ready): This is the signal that tells the requester that the memory is ready to proceed with 
//the request (i.e., memory is ready to either read or write data).
//When req_i (valid) is high, it means the request is made. The memory then responds 
//with req_ready_o when it's ready to process the request. The delay is introduced before req_ready_o is asserted to make the system more realistic. 
//This system has: 16 memory locations, each 32 bits wide (total 16 x 32-bit).
//When req_i is high, a request is being made. The memory can either read or write depending on req_rnw_i.
//The response from the memory is delayed randomly to simulate real-world memory behavior.
/*3. Role of day3 and day7 Modules
Why day3? – Edge Detection
Purpose: The day3 module is used to detect the rising edge of the req_i signal.

Why is this important?

In the real world, the memory will respond to a request only once it detects a new 
request (which happens when req_i transitions from 0 to 1). So, we need to detect when req_i first turns high, indicating a new request.
Without edge detection, we'd keep reacting to the same request, which would not reflect real-world behavior.

Why day7? – Random Delay Generation
Purpose: The day7 module generates a random 4-bit value each time the request happens.

Why is this important?
Memory in real systems doesn’t respond instantly. Sometimes, there's a random delay due to various factors (bus contention, processing time, etc.).
day7 uses a Linear Feedback Shift Register (LFSR) to generate a random number (a 4-bit value). 
This random number is then used to simulate the delay before the memory can assert req_ready_o, meaning it will only respond after a random delay.

How they work together:
When a new request (req_i) comes in, the day3 module detects the rising edge (the moment req_i goes from 0 to 1).
The day7 module generates a random value (a 4-bit number) every time the rising edge of req_i is detected.
This random value is used to set a counter (count), which counts up on every clock cycle.
The memory will only respond (assert req_ready_o) when this counter hits zero, meaning there’s a random delay before the memory can say it’s ready.
This is what makes the memory system more realistic: it adds random delays to when the memory says it’s ready.

How the System Works (Step-by-Step):
Start: The request (req_i) is sent to the memory interface.
Edge Detection: The day3 module detects when req_i transitions from 0 to 1 (rising edge).
Random Delay: The day7 module generates a random number, which is used to set a counter. The memory will be ready only after this counter hits zero.

Request Handling:
Write: If the request is a write (req_rnw_i = 0), data is written into memory when the counter reaches zero.
Read: If the request is a read (req_rnw_i = 1), data is fetched from memory when the counter reaches zero.
Ready: The memory interface will only assert req_ready_o when the counter reaches zero, meaning the system is ready to process the request.

Conclusion:
In simple terms:
The day3 module is used to detect when a new request arrives, so the system knows when to start processing.
The day7 module adds a random delay before the memory responds, making it behave like a real memory system that doesn’t immediately process requests.*/


//used eda playground for simulation

module day17 (
  input       wire        clk,
  input       wire        reset,

  input       wire        req_i,        // Valid request input remains asserted until ready is seen
  input       wire        req_rnw_i,    // Read-not-write (1-read, 0-write)
  input       wire[3:0]   req_addr_i,   // 4-bit Memory address
  input       wire[31:0]  req_wdata_i,  // 32-bit write data
  output      wire        req_ready_o,   // Ready output when request accepted
  output      wire[31:0]  req_rdata_o   // Read data from memory
);

  // Memory array (16x32-bit)
  logic [15:0][31:0] mem;

  // Random delay logic
  logic [3:0] delay_count;
  logic req_rising_edge;

  // Registers for memory write and read operations
  logic mem_rd;
  logic mem_wr;

  // Generate ready signal after random delay
  assign mem_rd = req_i & req_rnw_i;   // Read condition
  assign mem_wr = req_i & ~req_rnw_i;  // Write condition

  // Instantiate day3 (edge detector)
  day3 DAY3 (
    .clk            (clk),
    .reset          (reset),
    .a_i            (req_i),
    .rising_edge_o  (req_rising_edge)
  );

  // Random delay counter
  always_ff @(posedge clk or posedge reset)
    if (reset)
      delay_count <= 4'h0;
    else if (req_rising_edge)
      delay_count <= $urandom_range(1, 10);  // Random delay value
    else if (delay_count > 0)
      delay_count <= delay_count - 1;

  // Memory operation based on delay count
  always_ff @(posedge clk)
    if (mem_wr & (delay_count == 0))
      mem[req_addr_i] <= req_wdata_i;

  // Read directly
  assign req_rdata_o = mem[req_addr_i] & {32{mem_rd}};

  // Assert ready only when delay_count is 0 (ready after delay)
  assign req_ready_o = (delay_count == 0);

endmodule

// Edge Detection Module for detecting rising and falling edges
module day3 (
  input     wire    clk,
  input     wire    reset,
  input     wire    a_i,  // Input signal to detect edges

  output    wire    rising_edge_o,  // Rising edge output
  output    wire    falling_edge_o  // Falling edge output
);

  logic a_ff;  // Delayed version of input signal

  always_ff @(posedge clk or posedge reset)
    if (reset)
      a_ff <= 1'b0;
    else
      a_ff <= a_i;

  // Rising edge when delayed signal is 0 but current is 1
  assign rising_edge_o = ~a_ff & a_i;

  // Falling edge when delayed signal is 1 but current is 0
  assign falling_edge_o = a_ff & ~a_i;

endmodule


TestBench

module day17_tb ();

  logic        clk;
  logic        reset;
  logic        req_i;
  logic        req_rnw_i;
  logic[3:0]   req_addr_i;
  logic[31:0]  req_wdata_i;
  logic        req_ready_o;
  logic[31:0]  req_rdata_o;

  // Instantiate the RTL module
  day17 DUT (
    .clk           (clk),
    .reset         (reset),
    .req_i         (req_i),
    .req_rnw_i     (req_rnw_i),
    .req_addr_i    (req_addr_i),
    .req_wdata_i   (req_wdata_i),
    .req_ready_o   (req_ready_o),
    .req_rdata_o   (req_rdata_o)
  );

  // Clock generation
  always begin
    clk = 1'b1;
    #5;
    clk = 1'b0;
    #5;
  end

  // Generate stimulus
  initial begin
    // Create VCD file for waveform dump
    $dumpfile("day17_tb.vcd");  // Specify the VCD file name
    $dumpvars(0, day17_tb);     // Dump all variables in the testbench

    reset = 1'b1;
    req_i = 1'b0;
    req_rnw_i = 1'b0;
    req_addr_i = 4'b0000;
    req_wdata_i = 32'h00000000;

    // Reset phase
    @(posedge clk);
    reset = 1'b0;

    // Test write transaction with random delay
    @(posedge clk);
    req_i = 1'b1;
    req_rnw_i = 1'b0;  // Write operation
    req_addr_i = 4'b0010;  // Address 2
    req_wdata_i = 32'hA5A5A5A5;  // Data to write
    while (~req_ready_o) begin
      @(posedge clk);
    end
    req_i = 1'b0;
    @(posedge clk);

    // Test read transaction with random delay
    @(posedge clk);
    req_i = 1'b1;
    req_rnw_i = 1'b1;  // Read operation
    req_addr_i = 4'b0010;  // Address 2 (same address as written before)
    while (~req_ready_o) begin
      @(posedge clk);
    end
    req_i = 1'b0;
    @(posedge clk);

    // Check read data
    assert(req_rdata_o == 32'hA5A5A5A5) else $fatal("Read data mismatch!");

    // Test with random writes and reads
    for (int i = 0; i < 10; i++) begin
      @(posedge clk);
      req_i = 1'b1;
      req_rnw_i = $random % 2;  // Random read or write
      req_addr_i = $random % 16;  // Random address (0-15)
      req_wdata_i = $random;  // Random data to write if write operation
      while (~req_ready_o) begin
        @(posedge clk);
      end
      req_i = 1'b0;
      @(posedge clk);
    end

    $finish;
  end

endmodule


