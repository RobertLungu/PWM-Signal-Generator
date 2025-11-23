module instr_dcd (
    // peripheral clock signals
    input clk,
    input rst_n,
    // towards SPI slave interface signals
    input byte_sync,
    input[7:0] data_in,
    output[7:0] data_out,
    // register access signals
    output read,
    output write,
    output[5:0] addr,
    input[7:0] data_read,
    output[7:0] data_write
);

reg phase;                 
reg [7:0] data_write_reg;  
reg [7:0] data_out_reg;    
reg write_flag;
reg read_flag;
reg [5:0] addr_reg;

// Assign outputs from internal regs (stupid workaround i know)
assign write = write_flag;
assign read  = read_flag;
assign addr  = addr_reg;
assign data_write = data_write_reg;
assign data_out   = data_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        phase <= 0;
        data_write_reg <= 8'h00;
        data_out_reg   <= 8'h00;
        write_flag <= 1'b0;
        read_flag  <= 1'b0;
        addr_reg   <= 6'h00;
    end else if (byte_sync) begin
        if (phase == 0) begin
            // Setup phase
            write_flag <= data_in[7];
            read_flag  <= ~data_in[7];
            addr_reg   <= data_in[5:0];
            phase <= 1'b1;
        end else begin
            // Data phase
            if (write_flag)
                data_write_reg <= data_in;
            if (read_flag)
                data_out_reg <= data_read;
            phase <= 1'b0;
        end
    end
end

endmodule