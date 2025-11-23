// pwm_gen.v: Generator de semnal PWM
// Implementeaza modurile Aliniat (Stanga/Dreapta) si Nealiniat
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

    // Registru pentru semnalul PWM de iesire
    reg pwm_out_reg;
    assign pwm_out = pwm_out_reg;

    // Detectii de potrivire
    wire compare1_match = (count_val == compare1);
    wire compare2_match = (count_val == compare2);
    wire period_match = (count_val == period);
    wire zero_match = (count_val == 16'h0000);
    
    // Decodificare functii
    wire is_aligned = (functions[1] == 1'b0);
    wire is_left_aligned = (functions[1] == 1'b0) && (functions[0] == 1'b0); // Bitul 0: Stanga(0) / Dreapta(1)
    wire is_right_aligned = (functions[1] == 1'b0) && (functions[0] == 1'b1);
    wire is_non_aligned = (functions[1] == 1'b1);

    // Logica de generare a semnalului PWM (secventiala)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_out_reg <= 1'b0;
        end else if (!pwm_en) begin
            // Cand PWM_EN este dezactivat, linia ramane in starea curenta (blocata).
            pwm_out_reg <= pwm_out_reg; 
        end else begin
            // PWM_EN este activat
            
            if (is_aligned) begin
                // Mod Aliniat (Aligned)
                
                // Schimbarea starii la match COMPARE1
                if (compare1_match) begin
                    pwm_out_reg <= ~pwm_out_reg;
                end 
                // Resetarea starii (la inceputul perioadei - Over/Under-flow)
                else if (period_match || zero_match) begin
                    if (is_left_aligned) begin 
                        // Left Aligned: Incepe pe HIGH (1)
                        pwm_out_reg <= 1'b1; 
                    end else if (is_right_aligned) begin 
                        // Right Aligned: Incepe pe LOW (0)
                        pwm_out_reg <= 1'b0; 
                    end
                end
            end 
            else if (is_non_aligned) begin
                // Mod Nealiniat (Non-Aligned) - Incepe 0, devine 1 la C1, revine 0 la C2
                
                if (compare1_match) begin
                    pwm_out_reg <= 1'b1; // Devine HIGH la COMPARE1
                end else if (compare2_match) begin
                    pwm_out_reg <= 1'b0; // Devine LOW la COMPARE2
                end else if (zero_match) begin
                    pwm_out_reg <= 1'b0; // Asigura ca incepe de la 0
                end
            end
        end
    end

endmodule