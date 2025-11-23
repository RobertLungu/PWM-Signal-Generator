module pwm_gen (
    // peripheral clock signals
    input clk,
    input rst_n,
    // PWM signal register configuration
    input pwm_en,
    input[15:0] period,
    input[7:0] functions,
    input[15:0] compare1,
    input[15:0] compare2,
    input[15:0] count_val,
    // top facing signals
    output pwm_out
);

reg pwm_out_reg;
assign pwm_out = pwm_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pwm_out_reg <= 1'b0;
    else if (!pwm_en)
        pwm_out_reg <= 1'b0;
    else begin
        if (functions[1]) begin
            // unaligned mode
            if (count_val < compare1)
                pwm_out_reg <= 1'b0;
            else if (count_val >= compare1 && count_val < compare2)
                pwm_out_reg <= 1'b1;
            else
                pwm_out_reg <= 1'b0;
        end else begin
            // aligned mode
            if (functions[0] == 0) begin
                // left-aligned
                if (count_val < compare1)
                    pwm_out_reg <= 1'b1;
                else
                    pwm_out_reg <= 1'b0;
            end else begin
                // right-aligned
                if (count_val < compare1)
                    pwm_out_reg <= 1'b0;
                else
                    pwm_out_reg <= 1'b1;
            end
        end
    end
end

endmodule
