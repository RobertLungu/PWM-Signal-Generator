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

/*
    All registers that appear in this block should be similar to this. Please try to abide
    to sizes as specified in the architecture documentation.
*/
reg [15:0] period_reg;
reg [15:0] compare1_reg;
reg [15:0] compare2_reg;
reg en_reg;
reg count_reset_reg;
reg upnotdown_reg;
reg [7:0] prescale_reg;
reg pwm_en_reg;
reg [7:0] functions_reg;
reg [7:0] data_read_reg;

assign period      = period_reg;
assign compare1    = compare1_reg;
assign compare2    = compare2_reg;
assign en          = en_reg;
assign count_reset = count_reset_reg;
assign upnotdown   = upnotdown_reg;
assign prescale    = prescale_reg;
assign pwm_en      = pwm_en_reg;
assign functions   = functions_reg;
assign data_read   = data_read_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        period_reg      <= 16'h0000;
        compare1_reg    <= 16'h0000;
        compare2_reg    <= 16'h0000;
        en_reg          <= 1'b0;
        count_reset_reg <= 1'b0;
        upnotdown_reg   <= 1'b0;
        prescale_reg    <= 8'h00;
        pwm_en_reg      <= 1'b0;
        functions_reg   <= 8'h00;
    end else begin
        if (count_reset_reg)
            count_reset_reg <= 1'b0;

        if (write) begin
            case(addr)
                6'h00: period_reg[7:0]   <= data_write;
                6'h01: period_reg[15:8]  <= data_write;
                6'h02: en_reg             <= data_write[0];
                6'h03: compare1_reg[7:0]  <= data_write;
                6'h04: compare1_reg[15:8] <= data_write;
                6'h05: compare2_reg[7:0]  <= data_write;
                6'h06: compare2_reg[15:8] <= data_write;
                6'h07: count_reset_reg    <= 1'b1;
                6'h0A: prescale_reg       <= data_write;
                6'h0B: upnotdown_reg      <= data_write[0];
                6'h0C: pwm_en_reg         <= data_write[0];
                6'h0D: functions_reg      <= data_write;
                default: ;
            endcase
        end
    end
end

always @(*) begin
    case(addr)
        6'h00: data_read_reg = period_reg[7:0];
        6'h01: data_read_reg = period_reg[15:8];
        6'h02: data_read_reg = {7'b0, en_reg};
        6'h03: data_read_reg = compare1_reg[7:0];
        6'h04: data_read_reg = compare1_reg[15:8];
        6'h05: data_read_reg = compare2_reg[7:0];
        6'h06: data_read_reg = compare2_reg[15:8];
        6'h07: data_read_reg = {7'b0, count_reset_reg};
        6'h0A: data_read_reg = prescale_reg;
        6'h0B: data_read_reg = {7'b0, upnotdown_reg};
        6'h0C: data_read_reg = {7'b0, pwm_en_reg};
        6'h0D: data_read_reg = functions_reg;
        default: data_read_reg = 8'h00;
    endcase
end

endmodule