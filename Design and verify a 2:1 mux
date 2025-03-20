// A simple mux

module day1 (
  input   wire [7:0]    a_i,
  input   wire [7:0]    b_i,
  input   wire          sel_i,
  output  wire [7:0]    y_o
);

 
  assign y_o = sel_i ? b_i : a_i;

endmodule

//Testbench

// A simple TB for mux

module day1_tb;
    
    logic [7:0] a_i, b_i;
    logic sel_i;
    logic [7:0] y_o;
    
    // Instantiate the DUT
    day1 dut (
        .a_i(a_i),
        .b_i(b_i),
        .sel_i(sel_i),
        .y_o(y_o)
    );

initial begin
        // Monitor the signals
        $monitor("Time=%0t | a_i=%h b_i=%h sel_i=%b y_o=%h", $time, a_i, b_i, sel_i, y_o);
        
        // Test Case 1: sel_i = 0, expect y_o = a_i
        a_i = 8'hA5; b_i = 8'h5A; sel_i = 0;
        #10;
        assert (y_o == a_i) else $error("Test Case 1 Failed");
        
        // Test Case 2: sel_i = 1, expect y_o = b_i
        sel_i = 1;
        #10;
        assert (y_o == b_i) else $error("Test Case 2 Failed");
        
        // Test Case 3: Change inputs while sel_i = 0
        a_i = 8'hFF; b_i = 8'h00; sel_i = 0;
        #10;
        assert (y_o == a_i) else $error("Test Case 3 Failed");
        
        // Test Case 4: Change inputs while sel_i = 1
        sel_i = 1;
        #10;
        assert (y_o == b_i) else $error("Test Case 4 Failed");
        
        $display("All test cases passed.");
        $finish;
    end


endmodule


