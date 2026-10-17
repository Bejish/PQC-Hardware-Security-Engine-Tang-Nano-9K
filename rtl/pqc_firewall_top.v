module pqc_firewall_top(
    input wire clk,           // 27MHz system clock
    input wire rst_n,         // Active low reset
    input wire [7:0] data_in, // Input data stream
    input wire data_valid,    // Data valid signal
    input wire test_enable,   // Enable hardware testing
    input wire [1:0] test_mode, // Test mode selection
    output wire [5:0] led,    // Tang Nano 9K built-in LEDs
    output wire threat_detected,
    output wire system_ready
);

// Internal signals
wire kyber_valid;
wire pattern_match;
wire threat_status;
wire [31:0] processed_data;
wire verification_complete;

// Hardware test signals
wire [7:0] test_data;
wire test_data_valid;
wire test_complete;

// Clock divider for LED effects
reg [25:0] led_counter;
reg [2:0] led_seq_counter;
reg led_clk;

// Data source selection
wire [7:0] selected_data;
wire selected_data_valid;

assign selected_data = test_enable ? test_data : data_in;
assign selected_data_valid = test_enable ? test_data_valid : data_valid;

// Generate slower clock for LED effects
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        led_counter <= 26'd0;
        led_clk <= 1'b0;
    end else begin
        if (led_counter == 26'd13500000) begin // ~0.5 second at 27MHz
            led_counter <= 26'd0;
            led_clk <= ~led_clk;
        end else begin
            led_counter <= led_counter + 1'b1;
        end
    end
end

// Hardware test data generator
data_input_controller test_controller (
    .clk(clk),
    .rst_n(rst_n),
    .start_test(test_enable),
    .test_mode(test_mode),
    .data_out(test_data),
    .data_valid_out(test_data_valid),
    .test_complete(test_complete)
);

// Instantiate Kyber-512 verification module
kyber_512_verifier kyber_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(selected_data),
    .data_valid(selected_data_valid),
    .verification_result(kyber_valid),
    .processed_data(processed_data),
    .verification_complete(verification_complete)
);

// Instantiate pattern matching module
pattern_matcher pattern_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(processed_data),
    .data_valid(verification_complete),
    .pattern_detected(pattern_match)
);

// Instantiate threat analyzer
threat_analyzer analyzer_inst (
    .clk(clk),
    .rst_n(rst_n),
    .kyber_result(kyber_valid),
    .pattern_result(pattern_match),
    .verification_complete(verification_complete),
    .threat_status(threat_status),
    .analysis_ready(threat_detected)
);

// LED controller for visual indication
led_controller led_ctrl_inst (
    .clk(clk),
    .led_clk(led_clk),
    .rst_n(rst_n),
    .threat_status(threat_status),
    .system_active(threat_detected),
    .led_out(led)
);

assign system_ready = verification_complete;

endmodule
