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
    localparam SETUP_PHASE = 1'b0;
    localparam DATA_PHASE  = 1'b1;

    reg state = SETUP_PHASE;          
    reg next_state;    
    
    reg setup_write = 1'b0;    // Bit 7: 1=Write, 0=Read.
    reg setup_high_low = 1'b0; // Bit 6: 1=MSB (High), 0=LSB (Low).
    reg [5:0] setup_addr = 6'h00; // Biti 5:0: Adresa de baza
    
    reg read_reg;
    reg write_reg;
    reg [5:0] addr_reg;
    reg [7:0] data_write_reg;

    assign data_out = data_read;
    assign read = read_reg;
    assign write = write_reg;
    assign addr = addr_reg;
    assign data_write = data_write_reg;

    // FSM State Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= SETUP_PHASE;
            setup_addr     <= 6'h00;
            setup_high_low <= 1'b0;
            setup_write    <= 1'b0;
        end else begin
            state <= next_state;
        end
    end
    
    // FSM Next State Logic & Output Control
    always @(*) begin
        next_state = state;
        // Default initializations
        read_reg = 1'b0;
        write_reg = 1'b0;
        addr_reg = 6'h00;
        data_write_reg = 8'h00;
        
        case (state)
            SETUP_PHASE: begin
                addr_reg = setup_addr + setup_high_low;
                if (byte_sync) begin
                    setup_write    = data_in[7];
                    setup_high_low = data_in[6];
                    setup_addr     = data_in[5:0];
                    addr_reg = data_in[5:0] + data_in[6]; 
                    if (setup_write) next_state = DATA_PHASE;// Write (Bit 7 = 1)
                    else begin // Read (Bit 7 = 0)
                        read_reg = 1'b1;
                        next_state = SETUP_PHASE;
                    end
                end
            end
            DATA_PHASE: begin
                addr_reg = setup_addr + setup_high_low;
                if (byte_sync) begin
                    data_write_reg = data_in;
                    write_reg = 1'b1;
                    next_state = SETUP_PHASE; 
                end
            end
        endcase
    end
endmodule