module spi_bridge (
    // peripheral clock signals
    input clk,
    input rst_n,
    // SPI master facing signals
    input sclk,
    input cs_n,
    input mosi,
    output miso,
    // internal facing
    output byte_sync,
    output[7:0] data_in,
    input[7:0] data_out
);
    // Initializare fortata la declarare
    reg [2:0] bit_counter = 3'b000;
    reg [7:0] shift_in_reg = 8'h00;
    reg [7:0] shift_out_reg = 8'h00;

    reg sclk_d = 1'b0;
    wire sclk_rise = sclk & (~sclk_d);

    // MISO (Master In Slave Out) is the real-time output bit
    // Tristate (Z) when CS_n is inactive (High)
    assign miso = cs_n ? 1'bZ : shift_out_reg[7]; 
    
    reg [7:0] data_in_reg = 8'h00;
    reg byte_sync_reg = 1'b0;
    
    assign byte_sync = byte_sync_reg;
    assign data_in = data_in_reg;

    // Sequential logic on the peripheral clock (clk)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_counter <= 3'b000;
            byte_sync_reg <= 1'b0;
            sclk_d <= 1'b0;
            data_in_reg <= 8'h00;
            shift_in_reg <= 8'h00;
            shift_out_reg <= 8'h00;
        end else begin
            sclk_d <= sclk;
            byte_sync_reg <= 1'b0;  // Reset the synchronization signal every cycle
            
            if (cs_n) begin
                bit_counter <= 3'b000;
                shift_out_reg <= data_out;
            end else begin                
                if (sclk_rise) begin  // Read and write on the rising edge of SCLK
                    shift_in_reg <= {shift_in_reg[6:0], mosi};
                    shift_out_reg <= {shift_out_reg[6:0], 1'b0};
                    bit_counter <= bit_counter + 3'b001;
                    if (bit_counter == 3'd7) begin
                        data_in_reg <= {shift_in_reg[6:0], mosi};
                        byte_sync_reg <= 1'b1; 
                        bit_counter <= 3'b000; 
                        shift_out_reg <= data_out; 
                    end
                end
            end
        end
    end
endmodule