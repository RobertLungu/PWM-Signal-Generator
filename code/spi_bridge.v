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

reg [2:0] bit_cnt;
reg [7:0] shift_in;
reg [7:0] shift_out;
reg sclk_d;

reg miso_reg;
reg byte_sync_reg;
reg [7:0] data_in_reg;

assign miso = miso_reg;
assign byte_sync = byte_sync_reg;
assign data_in = data_in_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bit_cnt      <= 3'b0;
        shift_in     <= 8'h00;
        shift_out    <= 8'h00;
        miso_reg     <= 1'b0;
        byte_sync_reg<= 1'b0;
        data_in_reg  <= 8'h00;
        sclk_d       <= 1'b0;
    end else begin
        sclk_d <= sclk;

        if (cs_n) begin
            bit_cnt       <= 3'b0;
            shift_in      <= 8'h00;
            shift_out     <= data_out;
            byte_sync_reg <= 1'b0;
            miso_reg      <= data_out[7];
        end else begin
            byte_sync_reg <= 1'b0;

            if (sclk & ~sclk_d) begin
                shift_in <= {shift_in[6:0], mosi};
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt == 3'd7) begin
                    data_in_reg <= {shift_in[6:0], mosi};
                    byte_sync_reg <= 1'b1;
                    shift_out <= data_out;
                end
            end

            if (~sclk & sclk_d) begin
                miso_reg <= shift_out[7];
                shift_out <= {shift_out[6:0], 1'b0};
            end
        end
    end
end

endmodule