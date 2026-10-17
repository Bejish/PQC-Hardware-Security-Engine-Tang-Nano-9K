module led_controller(
    input wire clk,
    input wire led_clk,
    input wire rst_n,
    input wire threat_status,
    input wire system_active,
    output reg [5:0] led_out
);

reg [2:0] seq_counter;
reg [5:0] safe_pattern;
reg [5:0] threat_pattern;

always @(posedge led_clk or negedge rst_n) begin
    if (!rst_n) begin
        seq_counter <= 3'd0;
        safe_pattern <= 6'b000001;
    end else if (system_active) begin
        if (!threat_status) begin
            // Sequential blinking for SAFE data
            seq_counter <= seq_counter + 1'b1;
            case (seq_counter)
                3'd0: safe_pattern <= 6'b000001;
                3'd1: safe_pattern <= 6'b000010;
                3'd2: safe_pattern <= 6'b000100;
                3'd3: safe_pattern <= 6'b001000;
                3'd4: safe_pattern <= 6'b010000;
                3'd5: safe_pattern <= 6'b100000;
                3'd6: safe_pattern <= 6'b000000;
                3'd7: safe_pattern <= 6'b000000;
            endcase
        end else begin
            // Simultaneous blinking for MALICIOUS data
            safe_pattern <= (seq_counter[0]) ? 6'b111111 : 6'b000000;
            seq_counter <= seq_counter + 1'b1;
        end
    end else begin
        safe_pattern <= 6'b000000;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        led_out <= 6'b000000;
    end else begin
        led_out <= safe_pattern;
    end
end

endmodule
