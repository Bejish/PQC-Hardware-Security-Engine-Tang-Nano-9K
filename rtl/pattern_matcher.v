module pattern_matcher(
    input wire clk,
    input wire rst_n,
    input wire [31:0] data_in,
    input wire data_valid,
    output reg pattern_detected
);

// Malicious pattern signatures (simplified examples)
reg [31:0] malicious_patterns [0:7];
reg [3:0] pattern_index;
reg [2:0] match_state;

// Initialize malicious patterns
initial begin
    malicious_patterns[0] = 32'hDEADBEEF; // Buffer overflow signature
    malicious_patterns[1] = 32'hCAFEBABE; // Code injection signature
    malicious_patterns[2] = 32'hFEEDFACE; // SQL injection signature
    malicious_patterns[3] = 32'hBADC0DE0; // Malware signature
    malicious_patterns[4] = 32'hC0DEBEEF; // Custom threat signature
    malicious_patterns[5] = 32'h12345678; // Suspicious pattern
    malicious_patterns[6] = 32'hABCDEF00; // Network attack signature
    malicious_patterns[7] = 32'h87654321; // Data exfiltration signature
end

localparam IDLE_MATCH = 3'd0;
localparam PATTERN_CHECK = 3'd1;
localparam MATCH_FOUND = 3'd2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pattern_detected <= 1'b0;
        pattern_index <= 4'd0;
        match_state <= IDLE_MATCH;
    end else begin
        case (match_state)
            IDLE_MATCH: begin
                if (data_valid) begin
                    match_state <= PATTERN_CHECK;
                    pattern_index <= 4'd0;
                    pattern_detected <= 1'b0;
                end
            end
            
            PATTERN_CHECK: begin
                if (data_in == malicious_patterns[pattern_index]) begin
                    pattern_detected <= 1'b1;
                    match_state <= MATCH_FOUND;
                end else if (pattern_index == 4'd7) begin
                    match_state <= IDLE_MATCH;
                end else begin
                    pattern_index <= pattern_index + 1'b1;
                end
            end
            
            MATCH_FOUND: begin
                match_state <= IDLE_MATCH;
            end
        endcase
    end
end

endmodule
