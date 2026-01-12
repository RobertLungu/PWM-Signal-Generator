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
// Internal signals, newly initialized
    reg [7:0] prescale_cnt = 8'h00;
    reg [15:0] counter_val_reg = 16'h0000; 
    assign count_val = counter_val_reg;
    wire counter_tick;
    reg [7:0] prescale_limit;

//Common prescale limit logic
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
            default: prescale_limit = 8'hFF;
        endcase
    end
    
 // Prescaler logic (8-bit, sequential)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) prescale_cnt <= 8'h00;
        else if (en) begin
            if (prescale_cnt == prescale_limit) prescale_cnt <= 8'h00;// Reset
            else prescale_cnt <= prescale_cnt + 8'h01;  // Increment
        end else prescale_cnt <= 8'h00;
    end
    
    assign counter_tick = en && (prescale_cnt == prescale_limit);

 // Main Counter Logic (16-bit, sequential)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) counter_val_reg <= 16'h0000;
        else if (count_reset) counter_val_reg <= 16'h0000;
        else if (en && counter_tick) begin 
            if (upnotdown) begin  // UP (Increment)
                if (counter_val_reg == period) counter_val_reg <= 16'h0000;
                else counter_val_reg <= counter_val_reg + 16'h0001;
            end else begin // DOWN (Decrement)
                if (counter_val_reg == 16'h0000) counter_val_reg <= period; // Underflow
                else counter_val_reg <= counter_val_reg - 16'h0001;
            end
        end
    end
endmodule