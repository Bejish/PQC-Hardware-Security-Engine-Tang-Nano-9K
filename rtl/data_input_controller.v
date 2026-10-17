module data_input_controller(
    input wire clk,
    input wire rst_n,
    input wire start_test,
    input wire [1:0] test_mode, // 00: safe, 01: malicious1, 10: malicious2
    output reg [7:0] data_out,
    output reg data_valid_out,
    output reg test_complete
);

// Test data storage
reg [7:0] safe_data [0:31];
reg [7:0] malicious_data1 [0:31];
reg [7:0] malicious_data2 [0:31];

// Initialize test data
initial begin
    // Safe data pattern
    safe_data[0] = 8'h01; safe_data[1] = 8'h02; safe_data[2] = 8'h03; safe_data[3] = 8'h04;
    safe_data[4] = 8'h05; safe_data[5] = 8'h06; safe_data[6] = 8'h07; safe_data[7] = 8'h08;
    safe_data[8] = 8'h09; safe_data[9] = 8'h0A; safe_data[10] = 8'h0B; safe_data[11] = 8'h0C;
    safe_data[12] = 8'h0D; safe_data[13] = 8'h0E; safe_data[14] = 8'h0F; safe_data[15] = 8'h10;
    safe_data[16] = 8'h11; safe_data[17] = 8'h12; safe_data[18] = 8'h13; safe_data[19] = 8'h14;
    safe_data[20] = 8'h15; safe_data[21] = 8'h16; safe_data[22] = 8'h17; safe_data[23] = 8'h18;
    safe_data[24] = 8'h19; safe_data[25] = 8'h1A; safe_data[26] = 8'h1B; safe_data[27] = 8'h1C;
    safe_data[28] = 8'h1D; safe_data[29] = 8'h1E; safe_data[30] = 8'h1F; safe_data[31] = 8'h20;
    
    // Malicious data pattern 1 (DEADBEEF)
    malicious_data1[0] = 8'hDE; malicious_data1[1] = 8'hAD; malicious_data1[2] = 8'hBE; malicious_data1[3] = 8'hEF;
    malicious_data1[4] = 8'h05; malicious_data1[5] = 8'h06; malicious_data1[6] = 8'h07; malicious_data1[7] = 8'h08;
    malicious_data1[8] = 8'h09; malicious_data1[9] = 8'h0A; malicious_data1[10] = 8'h0B; malicious_data1[11] = 8'h0C;
    malicious_data1[12] = 8'h0D; malicious_data1[13] = 8'h0E; malicious_data1[14] = 8'h0F; malicious_data1[15] = 8'h10;
    malicious_data1[16] = 8'h11; malicious_data1[17] = 8'h12; malicious_data1[18] = 8'h13; malicious_data1[19] = 8'h14;
    malicious_data1[20] = 8'h15; malicious_data1[21] = 8'h16; malicious_data1[22] = 8'h17; malicious_data1[23] = 8'h18;
    malicious_data1[24] = 8'h19; malicious_data1[25] = 8'h1A; malicious_data1[26] = 8'h1B; malicious_data1[27] = 8'h1C;
    malicious_data1[28] = 8'h1D; malicious_data1[29] = 8'h1E; malicious_data1[30] = 8'h1F; malicious_data1[31] = 8'h20;
    
    // Malicious data pattern 2 (CAFEBABE)
    malicious_data2[0] = 8'hCA; malicious_data2[1] = 8'hFE; malicious_data2[2] = 8'hBA; malicious_data2[3] = 8'hBE;
    malicious_data2[4] = 8'h05; malicious_data2[5] = 8'h06; malicious_data2[6] = 8'h07; malicious_data2[7] = 8'h08;
    malicious_data2[8] = 8'h09; malicious_data2[9] = 8'h0A; malicious_data2[10] = 8'h0B; malicious_data2[11] = 8'h0C;
    malicious_data2[12] = 8'h0D; malicious_data2[13] = 8'h0E; malicious_data2[14] = 8'h0F; malicious_data2[15] = 8'h10;
    malicious_data2[16] = 8'h11; malicious_data2[17] = 8'h12; malicious_data2[18] = 8'h13; malicious_data2[19] = 8'h14;
    malicious_data2[20] = 8'h15; malicious_data2[21] = 8'h16; malicious_data2[22] = 8'h17; malicious_data2[23] = 8'h18;
    malicious_data2[24] = 8'h19; malicious_data2[25] = 8'h1A; malicious_data2[26] = 8'h1B; malicious_data2[27] = 8'h1C;
    malicious_data2[28] = 8'h1D; malicious_data2[29] = 8'h1E; malicious_data2[30] = 8'h1F; malicious_data2[31] = 8'h20;
end

reg [5:0] byte_counter;
reg [2:0] state;
reg [15:0] delay_counter;

localparam IDLE = 3'd0;
localparam SEND_DATA = 3'd1;
localparam WAIT_CYCLE = 3'd2;
localparam COMPLETE = 3'd3;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_out <= 8'h00;
        data_valid_out <= 1'b0;
        test_complete <= 1'b0;
        byte_counter <= 6'd0;
        state <= IDLE;
        delay_counter <= 16'd0;
    end else begin
        case (state)
            IDLE: begin
                test_complete <= 1'b0;
                data_valid_out <= 1'b0;
                if (start_test) begin
                    byte_counter <= 6'd0;
                    state <= SEND_DATA;
                end
            end
            
            SEND_DATA: begin
                case (test_mode)
                    2'b00: data_out <= safe_data[byte_counter];
                    2'b01: data_out <= malicious_data1[byte_counter];
                    2'b10: data_out <= malicious_data2[byte_counter];
                    default: data_out <= safe_data[byte_counter];
                endcase
                
                data_valid_out <= 1'b1;
                state <= WAIT_CYCLE;
                delay_counter <= 16'd0;
            end
            
            WAIT_CYCLE: begin
                data_valid_out <= 1'b0;
                delay_counter <= delay_counter + 1'b1;
                if (delay_counter == 16'd100) begin // Small delay between bytes
                    if (byte_counter == 6'd31) begin
                        state <= COMPLETE;
                    end else begin
                        byte_counter <= byte_counter + 1'b1;
                        state <= SEND_DATA;
                    end
                end
            end
            
            COMPLETE: begin
                test_complete <= 1'b1;
                state <= IDLE;
            end
        endcase
    end
end

endmodule