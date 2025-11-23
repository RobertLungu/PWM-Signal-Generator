module regs (
    // peripheral clock signals
    input clk,
    input rst_n,
    // decoder facing signals
    input read,
    input write,
    input[5:0] addr,
    output[7:0] data_read,
    input[7:0] data_write,
    // counter programming signals
    input[15:0] counter_val,
    output[15:0] period,
    output en,
    output count_reset,
    output upnotdown,
    output[7:0] prescale,
    // PWM signal programming values
    output pwm_en,
    output[7:0] functions,
    output[15:0] compare1,
    output[15:0] compare2
);

    reg [15:0] period_reg;
    reg counter_en_reg; 
    reg [15:0] compare1_reg;
    reg [15:0] compare2_reg;
    reg [7:0] prescale_reg; 
    reg upnotdown_reg;      
    reg pwm_en_reg;         
    reg [1:0] functions_reg; 
    
    assign period = period_reg;
    assign en = counter_en_reg;
    assign compare1 = compare1_reg;
    assign compare2 = compare2_reg;
    assign prescale = prescale_reg;
    assign upnotdown = upnotdown_reg;
    assign pwm_en = pwm_en_reg;
    assign functions = {6'h00, functions_reg}; // FUNCTIONS is 2 bits wide but output is 8 bits

    reg [1:0] counter_reset_cnt; // Counter(00 -> 01 -> 10 -> 11 -> 00)
    
    // COUNTER_RESET output is active in cycles 1 and 2 (out of 4 states)
    assign count_reset = (counter_reset_cnt == 2'b01) || (counter_reset_cnt == 2'b10); 

    // COUNTER_RESET logic (sequential)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_reset_cnt <= 2'b00;
        end else if (write && (addr == 6'h07)) begin // Write to COUNTER_RESET (0x07)
            counter_reset_cnt <= 2'b01; // Start counting (active in next cycle)
        end else if (counter_reset_cnt != 2'b00) begin
            counter_reset_cnt <= counter_reset_cnt + 2'b01;
        end
    end
    
    // Write logic for all registers (sequential)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            period_reg <= 16'h0000;
            counter_en_reg <= 1'b0;
            compare1_reg <= 16'h0000;
            compare2_reg <= 16'h0000;
            prescale_reg <= 8'h00;
            upnotdown_reg <= 1'b1; // Default UP
            pwm_en_reg <= 1'b0;
            functions_reg <= 2'b00;
        end else if (write) begin
            case (addr)
                6'h00: period_reg[7:0] <= data_write;       // PERIOD LSB
                6'h01: period_reg[15:8] <= data_write;      // PERIOD MSB
                6'h02: counter_en_reg <= data_write[0];     // COUNTER_EN (1 bit)
                6'h03: compare1_reg[7:0] <= data_write;     // COMPARE1 LSB
                6'h04: compare1_reg[15:8] <= data_write;    // COMPARE1 MSB
                6'h05: compare2_reg[7:0] <= data_write;     // COMPARE2 LSB
                6'h06: compare2_reg[15:8] <= data_write;    // COMPARE2 MSB
                // 0x07: COUNTER_RESET (W only)
                // 0x08, 0x09: COUNTER_VAL (R only)
                6'h0A: prescale_reg <= data_write;          // PRESCALE (8 bit)
                6'h0B: upnotdown_reg <= data_write[0];      // UPNOTDOWN (1 bit)
                6'h0C: pwm_en_reg <= data_write[0];         // PWM_EN (1 bit)
                6'h0D: functions_reg <= data_write[1:0];    // FUNCTIONS (2 bits)
                default: ; 
            endcase
        end
    end

    reg [7:0] data_read_reg;
    assign data_read = data_read_reg;

    always @(*) begin
        data_read_reg = 8'h00; // Default value (returns 0 for invalid/unimplemented addresses)
        
        if (read) begin
            case (addr)
                6'h00: data_read_reg = period_reg[7:0];
                6'h01: data_read_reg = period_reg[15:8];
                6'h02: data_read_reg = {7'h00, counter_en_reg};
                6'h03: data_read_reg = compare1_reg[7:0];
                6'h04: data_read_reg = compare1_reg[15:8];
                6'h05: data_read_reg = compare2_reg[7:0];
                6'h06: data_read_reg = compare2_reg[15:8];
                6'h07: data_read_reg = 8'h00; // COUNTER_RESET (W only)
                6'h08: data_read_reg = counter_val[7:0]; // COUNTER_VAL LSB (R only)
                6'h09: data_read_reg = counter_val[15:8]; // COUNTER_VAL MSB (R only)
                6'h0A: data_read_reg = prescale_reg;
                6'h0B: data_read_reg = {7'h00, upnotdown_reg};
                6'h0C: data_read_reg = {7'h00, pwm_en_reg};
                6'h0D: data_read_reg = {6'h00, functions_reg};
                default: data_read_reg = 8'h00; // Unimplemented address
            endcase
        end
    end

endmodule