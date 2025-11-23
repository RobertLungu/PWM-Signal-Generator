module counter (
    // peripheral clock signals
    input clk,
    input rst_n,
    // register facing signals
    output[15:0] count_val,
    input[15:0] period,
    input en,
    input count_reset,
    input upnotdown,
    input[7:0] prescale
);
reg [15:0] counter_reg;
reg [7:0] prescale_cnt;

// Assign output from internal reg
assign count_val = counter_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter_reg <= 16'h0000;
        prescale_cnt <= 8'h00;
    end else begin
        if (count_reset) begin
            counter_reg <= 16'h0000;
            prescale_cnt <= 8'h00;
        end else if (en) begin
            // Prescaler logic
            if (prescale_cnt >= prescale) begin
                prescale_cnt <= 8'h00;
                // Counter direction
                if (upnotdown)
                    counter_reg <= (counter_reg >= period) ? 16'h0000 : counter_reg + 1;
                else
                    counter_reg <= (counter_reg == 16'h0000) ? period : counter_reg - 1;
            end else begin
                prescale_cnt <= prescale_cnt + 1;
            end
        end
    end
end
endmodule
