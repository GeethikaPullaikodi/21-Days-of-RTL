module day21 #(
  parameter WIDTH = 12
)(
  input  wire [WIDTH-1:0] vec_i,
  output wire [WIDTH-1:0] second_bit_o
);

  logic [WIDTH-1:0] first_bit;
  logic [WIDTH-1:0] masked_vec;

  // Find the first bit set
  day14 #(.NUM_PORTS(WIDTH)) find_first (
    .req_i (vec_i),
    .gnt_o (first_bit)
  );

  // Mask the first bit
  assign masked_vec = vec_i & ~first_bit;

  // Find the second set bit
  day14 #(.NUM_PORTS(WIDTH)) find_second (
    .req_i (masked_vec),
    .gnt_o (second_bit_o)
  );

endmodule

// Priority encoder module to find first set bit (1-hot)
module day14 #(
  parameter NUM_PORTS = 4
)(
  input  wire [NUM_PORTS-1:0] req_i,
  output wire [NUM_PORTS-1:0] gnt_o
);
  assign gnt_o[0] = req_i[0];

  genvar i;
  generate
    for (i = 1; i < NUM_PORTS; i = i + 1) begin
      assign gnt_o[i] = req_i[i] & ~(|req_i[i-1:0]);
    end
  endgenerate
endmodule

TestBench:

module day21_tb;

  parameter WIDTH = 12;

  logic [WIDTH-1:0] vec_i;
  logic [WIDTH-1:0] second_bit_o;

  day21 #(WIDTH) dut (
    .vec_i(vec_i),
    .second_bit_o(second_bit_o)
  );

  function automatic [WIDTH-1:0] ref_second_bit(input [WIDTH-1:0] vec);
    int count = 0;
    ref_second_bit = '0;
    for (int i = 0; i < WIDTH; i++) begin
      if (vec[i]) begin
        count++;
        if (count == 2) begin
          ref_second_bit[i] = 1'b1;
        end
      end
    end
  endfunction

  initial begin
    $display("Time\tvec_i\t\tSecond_Bit_O\tExpected\tPASS?");
    for (int i = 0; i < 20; i++) begin
      vec_i = $urandom_range(0, (1 << WIDTH) - 1);
      #1;
      $display("%0t\t%b\t%b\t%b\t%s",
        $time,
        vec_i,
        second_bit_o,
        ref_second_bit(vec_i),
        (second_bit_o === ref_second_bit(vec_i)) ? "YES" : "NO"
      );
      #4;
    end

    // Edge cases
    vec_i = '0; #1;
    $display("Edge - All 0s: %b => %b", vec_i, second_bit_o);

    vec_i = 12'b0000_0000_0001; #1;
    $display("Edge - Only 1 bit: %b => %b", vec_i, second_bit_o);

    vec_i = 12'b0000_0000_0011; #1;
    $display("Edge - Two bits: %b => %b", vec_i, second_bit_o);

    $finish;
  end

endmodule
