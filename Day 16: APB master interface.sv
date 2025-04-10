
module day16 (
  input       wire        clk,
  input       wire        reset,

  input       wire[1:0]   cmd_i,          // Command input

  output      wire        psel_o,         // APB select
  output      wire        penable_o,      // APB enable
  output      wire[31:0]  paddr_o,        // APB address
  output      wire        pwrite_o,       // APB write control
  output      wire[31:0]  pwdata_o,       // APB write data
  input       wire        pready_i,       // APB ready signal
  input       wire[31:0]  prdata_i        // APB read data
);

  // Define APB transfer states
  typedef enum logic[1:0] {
    ST_IDLE   = 2'b00,
    ST_SETUP  = 2'b01,
    ST_ACCESS = 2'b10
  } apb_state_t;

  apb_state_t state_q, nxt_state;

  logic [31:0] rdata_q; // To store previously read data

  // Sequential logic: state register
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      state_q <= ST_IDLE;
    else
      state_q <= nxt_state;
  end

  // Combinational logic: next state logic
  always_comb begin
    nxt_state = state_q;
    case (state_q)
      ST_IDLE   : if (|cmd_i) nxt_state = ST_SETUP; else nxt_state = ST_IDLE;
      ST_SETUP  : nxt_state = ST_ACCESS;
      ST_ACCESS : begin
        if (pready_i) nxt_state = ST_IDLE;
      end
      default   : nxt_state = state_q;
    endcase
  end

  // Output logic
  assign psel_o    = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
  assign penable_o = (state_q == ST_ACCESS);
  assign pwrite_o  = (cmd_i == 2'b10); // Write only for cmd = 2'b10
  assign paddr_o   = 32'hDEAD_CAFE;
  assign pwdata_o  = rdata_q + 32'h1;

  // Capture read data when read transaction completes
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      rdata_q <= 32'h0;
    else if (penable_o && pready_i && cmd_i == 2'b01)
      rdata_q <= prdata_i;
  end

endmodule

TestBench

module day16_tb ();

  logic        clk;
  logic        reset;
  logic [1:0]  cmd_i;
  logic        psel_o;
  logic        penable_o;
  logic [31:0] paddr_o;
  logic        pwrite_o;
  logic [31:0] pwdata_o;
  logic        pready_i;
  logic [31:0] prdata_i;

  // Instantiate the DUT
  day16 uut (
    .clk(clk),
    .reset(reset),
    .cmd_i(cmd_i),
    .psel_o(psel_o),
    .penable_o(penable_o),
    .paddr_o(paddr_o),
    .pwrite_o(pwrite_o),
    .pwdata_o(pwdata_o),
    .pready_i(pready_i),
    .prdata_i(prdata_i)
  );

  // Clock generation: 10ns period
  always begin
    clk = 0; #5;
    clk = 1; #5;
  end

  // Simulate slave response: pready_i is delayed randomly
  initial begin
    forever begin
      pready_i = 0;
      repeat ($urandom_range(1, 4)) @(posedge clk);
      pready_i = 1;
      @(posedge clk);
    end
  end

  // Stimulus logic
  initial begin
    $display("Starting APB Master Testbench...");
    $dumpfile("day16.vcd");
    $dumpvars(0, day16_tb);

    reset = 1;
    cmd_i = 2'b00;
    prdata_i = 32'h0000_0000;
    @(posedge clk); reset = 0;
    @(posedge clk);

    // Perform 5 read + write command cycles
    for (int i = 0; i < 5; i++) begin
      // Issue Read command
      cmd_i = 2'b01;
      prdata_i = $urandom_range(10, 50); // simulate random data
      @(posedge clk);
      // Wait until APB transaction completes
      wait (pready_i && penable_o);
      @(posedge clk);

      // Issue Write command (use previously read data + 1)
      cmd_i = 2'b10;
      @(posedge clk);
      wait (pready_i && penable_o);
      @(posedge clk);

      // Return to idle
      cmd_i = 2'b00;
      @(posedge clk);
    end

    $display("Simulation done.");
    $finish;
  end

endmodule

