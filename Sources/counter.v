// counter.v: Num?r?tor de 16 bi?i cu Prescaler
// Contorul principal se incrementeaza/decrementeaza la 2^PRESCALE cicli de ceas.
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

    // Contorul intern al prescaler-ului (8 biti latime)
    reg [7:0] prescale_cnt;
    
    // Registru pentru valoarea contorului principal
    reg [15:0] counter_val_reg; 
    assign count_val = counter_val_reg;
    
    // Semnal de tick: activ cand contorul principal trebuie sa se schimbe.
    wire counter_tick;
    
    // Valoarea la care prescale_cnt se reseteaza (2^PRESCALE - 1)
    reg [7:0] prescale_limit;
    
    // Logica de calcul a limitei prescaler (combinationala)
    // PRESCALE=0 -> limit=0; PRESCALE=1 -> limit=1; PRESCALE=2 -> limit=3, etc.
    always @(*) begin
        case (prescale)
            8'd0: prescale_limit = 8'd0; 
            8'd1: prescale_limit = 8'd1; 
            8'd2: prescale_limit = 8'd3; 
            8'd3: prescale_limit = 8'd7; 
            8'd4: prescale_limit = 8'd15;
            8'd5: prescale_limit = 8'd31;
            8'd6: prescale_limit = 8'd63;
            8'd7: prescale_limit = 8'd127;
            default: prescale_limit = 8'hFF; // Pentru prescale >= 8 (max 255)
        endcase
    end
    
    // Logica Prescaler (secventiala)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescale_cnt <= 8'h00;
        end else if (en) begin
            if (prescale_cnt == prescale_limit)
                prescale_cnt <= 8'h00; // Reset
            else
                prescale_cnt <= prescale_cnt + 8'h01; // Increment
        end else begin
            prescale_cnt <= 8'h00; // Oprim/resetam cand e dezactivat
        end
    end
    
    // Tick-ul apare in ciclul in care prescale_cnt a atins limita
    assign counter_tick = en && (prescale_cnt == prescale_limit);

    // Logica Contor Principal (16-bit, secventiala)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter_val_reg <= 16'h0000;
        end else if (count_reset) begin
            // COUNTER_RESET reseteaza starea num?r?torului la 0
            counter_val_reg <= 16'h0000; 
        end else if (en && counter_tick) begin // Contorul se schimba doar la tick
            if (upnotdown) begin // UP (Incrementare)
                if (counter_val_reg == period) begin
                    counter_val_reg <= 16'h0000; // Overflow: revine la 0
                end else begin
                    counter_val_reg <= counter_val_reg + 16'h0001;
                end
            end else begin // DOWN (Decrementare)
                if (counter_val_reg == 16'h0000) begin
                    counter_val_reg <= period; // Underflow: revine la PERIOD
                end else begin
                    counter_val_reg <= counter_val_reg - 16'h0001;
                end
            end
        end
    end

endmodule