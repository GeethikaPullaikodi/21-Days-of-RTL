

Test Bench

`timescale 1ns/1ps

module day18_tb;

  // APB signals
  logic clk;
  logic reset;
  logic psel_i;
  logic penable_i;
  logic [9:0] paddr_i;
  logic pwrite_i;
  logic [31:0] pwdata_i;
  logic [31:0] prdata_o;
  logic pready_o;

  // Read value holder (declared outside initial block)
  logic [31:0] read_val;

  // Instantiate DUT
  day18 dut (
    .clk(clk),
    .reset(reset),
    .psel_i(psel_i),
    .penable_i(penable_i),
    .paddr_i(paddr_i),
    .pwrite_i(pwrite_i),
    .pwdata_i(pwdata_i),
    .prdata_o(prdata_o),
    .pready_o(pready_o)
  );

  // Clock generation
  always #5 clk = ~clk;

  // APB write task
  task apb_write(input [9:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      psel_i   = 1'b1;
      penable_i = 1'b0;
      pwrite_i  = 1'b1;
      paddr_i   = addr;
      pwdata_i  = data;

      @(posedge clk);
      penable_i = 1'b1;

      // Wait until ready
      while (!pready_o)
        @(posedge clk);

      psel_i = 0;
      penable_i = 0;
      pwrite_i = 0;
    end
  endtask

  // APB read task
  task apb_read(input [9:0] addr, output [31:0] data);
    begin
      @(posedge clk);
      psel_i    = 1'b1;
      penable_i = 1'b0;
      pwrite_i  = 1'b0;
      paddr_i   = addr;

      @(posedge clk);
      penable_i = 1'b1;

      while (!pready_o)
        @(posedge clk);

      data = prdata_o;

      psel_i = 0;
      penable_i = 0;
    end
  endtask

  // Test sequence
  initial begin
    $dumpfile("day18_tb.vcd");
    $dumpvars(0, day18_tb);

    // Initialize
    clk = 0;
    reset = 1;
    psel_i = 0;
    penable_i = 0;
    paddr_i = 0;
    pwrite_i = 0;
    pwdata_i = 0;

    @(posedge clk);
    reset = 0;

    // Write to address 4 with value 0x12345678
    apb_write(10'd4, 32'h12345678);

    // Read from address 4 and check value
    apb_read(10'd4, read_val);
    assert(read_val == 32'h12345678)
      else $fatal("Read failed! Expected 0x12345678, got %h", read_val);

    // Multiple reads/writes
    for (int i = 0; i < 5; i++) begin
      apb_write(i, i * 32'h10);
    end

    for (int i = 0; i < 5; i++) begin
      apb_read(i, read_val);
      assert(read_val == i * 32'h10)
        else $fatal("Read failed at addr %0d! Got %h", i, read_val);
    end

    $display("All APB read/write tests passed!");
    $finish;
  end

endmodule
