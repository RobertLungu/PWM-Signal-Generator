module pwm_gen (
    // peripheral clock signals
    input clk,
    input rst_n,
    // PWM signal register configuration
    input pwm_en,
    input[15:0] period,
    input[7:0] functions, // [0]: Left(0)/Right(1), [1]: Aligned(0)/Non-aligned(1)
    input[15:0] compare1,
    input[15:0] compare2,
    input[15:0] count_val,
    // top facing signals
    output pwm_out
);

    reg pwm_out_reg;
    assign pwm_out = pwm_out_reg;

    wire compare1_match = (count_val == compare1);
    wire compare2_match = (count_val == compare2);
    wire period_match = (count_val == period);
    wire zero_match = (count_val == 16'h0000);
    
    wire is_aligned = (functions[1] == 1'b0);
    wire is_left_aligned = (functions[1] == 1'b0) && (functions[0] == 1'b0); // Bit 0: Left(0) / Right(1)
    wire is_right_aligned = (functions[1] == 1'b0) && (functions[0] == 1'b1);
    wire is_non_aligned = (functions[1] == 1'b1);

    // PWM Output Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_out_reg <= 1'b0;
        end else if (!pwm_en) begin
            pwm_out_reg <= pwm_out_reg; 
        end else begin
            
            if (is_aligned) begin
                // Mode Aligned
                
                if (compare1_match) begin
                    pwm_out_reg <= ~pwm_out_reg;
                end 
                else if (period_match || zero_match) begin
                    if (is_left_aligned) begin 
                        // Left Aligned Starts HIGH (1)
                        pwm_out_reg <= 1'b1; 
                    end else if (is_right_aligned) begin 
                        // Right Aligned: Starts LOW (0)
                        pwm_out_reg <= 1'b0; 
                    end
                end
            end 
            else if (is_non_aligned) begin
                // Mode Non-Aligned - Starts 0, goes 1 at C1, returns 0 at C2
                
                if (compare1_match) begin
                    pwm_out_reg <= 1'b1; 
                end else if (compare2_match) begin
                    pwm_out_reg <= 1'b0; 
                end else if (zero_match) begin
                    pwm_out_reg <= 1'b0;
                end
            end
        end
    end

endmodule