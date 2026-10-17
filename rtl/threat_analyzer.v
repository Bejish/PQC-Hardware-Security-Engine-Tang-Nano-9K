module threat_analyzer(
    input wire clk,
    input wire rst_n,
    input wire kyber_result,
    input wire pattern_result,
    input wire verification_complete,
    output reg threat_status,
    output reg analysis_ready
);

reg [1:0] analysis_state;
reg [15:0] delay_counter;

localparam WAIT_VERIFICATION = 2'd0;
localparam ANALYZE = 2'd1;
localparam DELAY_OUTPUT = 2'd2;
localparam OUTPUT_READY = 2'd3;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        threat_status <= 1'b0;
        analysis_ready <= 1'b0;
        analysis_state <= WAIT_VERIFICATION;
        delay_counter <= 16'd0;
    end else begin
        case (analysis_state)
            WAIT_VERIFICATION: begin
                analysis_ready <= 1'b0;
                if (verification_complete) begin
                    analysis_state <= ANALYZE;
                end
            end
            
            ANALYZE: begin
                // Threat detected if pattern found OR kyber verification failed
                threat_status <= pattern_result || (!kyber_result);
                delay_counter <= 16'd0;
                analysis_state <= DELAY_OUTPUT;
            end
            
            DELAY_OUTPUT: begin
                // Add delay for judges to observe the difference
                delay_counter <= delay_counter + 1'b1;
                if (delay_counter == 16'd27000) begin // ~1ms delay at 27MHz
                    analysis_state <= OUTPUT_READY;
                end
            end
            
            OUTPUT_READY: begin
                analysis_ready <= 1'b1;
                analysis_state <= WAIT_VERIFICATION;
            end
        endcase
    end
end

endmodule
