module tb_pqc_firewall();

reg clk;
reg rst_n;
reg [7:0] data_in;
reg data_valid;
wire [5:0] led;
wire threat_detected;
wire system_ready;

// Instantiate DUT
pqc_firewall_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .data_valid(data_valid),
    .led(led),
    .threat_detected(threat_detected),
    .system_ready(system_ready)
);

// Clock generation
initial begin
    clk = 0;
    forever #18.5 clk = ~clk; // 27MHz clock
end

// Test stimulus
initial begin
    $dumpfile("pqc_firewall.vcd");
    $dumpvars(0, tb_pqc_firewall);
    
    // Initialize
    rst_n = 0;
    data_in = 8'h00;
    data_valid = 0;
    
    #100;
    rst_n = 1;
    #100;
    
    $display("Starting PQC Firewall Test...");
    
    // Test Case 1: Safe Data
    $display("Test Case 1: Sending SAFE data...");
    send_data_packet({8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'h08,
                      8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0E, 8'h0F, 8'h10,
                      8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 8'h18,
                      8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1E, 8'h1F, 8'h20});
    
    wait_for_completion();
    
    // Test Case 2: Malicious Data (contains malicious pattern)
    $display("Test Case 2: Sending MALICIOUS data...");
    send_data_packet({8'hDE, 8'hAD, 8'hBE, 8'hEF, 8'h05, 8'h06, 8'h07, 8'h08,
                      8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0E, 8'h0F, 8'h10,
                      8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 8'h18,
                      8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1E, 8'h1F, 8'h20});
    
    wait_for_completion();
    
    // Test Case 3: Another malicious pattern
    $display("Test Case 3: Sending another MALICIOUS pattern...");
    send_data_packet({8'hCA, 8'hFE, 8'hBA, 8'hBE, 8'h05, 8'h06, 8'h07, 8'h08,
                      8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0E, 8'h0F, 8'h10,
                      8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 8'h18,
                      8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1E, 8'h1F, 8'h20});
    
    wait_for_completion();
    
    #1000000; // Wait to observe LED patterns
    
    $display("Test completed!");
    $finish;
end

// Task to send data packet
task send_data_packet(input [255:0] packet);
integer i;
begin
    for (i = 0; i < 32; i = i + 1) begin
        data_in = packet[255:248];
        packet = packet << 8;
        data_valid = 1;
        #37; // One clock cycle
        data_valid = 0;
        #37;
    end
end
endtask

// Task to wait for completion
task wait_for_completion();
begin
    wait(system_ready == 1);
    #1000;
    if (threat_detected) begin
        if (dut.analyzer_inst.threat_status) begin
            $display("THREAT DETECTED - LEDs should blink simultaneously");
        end else begin
            $display("DATA SAFE - LEDs should blink sequentially");
        end
    end
end
endtask

endmodule