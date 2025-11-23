// spi_bridge.v: Modulul de comunicatie SPI (Slave)
// Protocol: MSB first, CPOL=0, CPHA=0. Datele sunt citite pe frontul crescator al SCLK.
// Presupunere: clk si sclk sunt sincrone.
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

    // Contor pentru a urmari transferul de 8 biti
    reg [2:0] bit_counter;
    // Registru de schimb (shift register) pentru datele de intrare (MOSI)
    reg [7:0] shift_in_reg;
    // Registru de schimb (shift register) pentru datele de iesire (MISO)
    reg [7:0] shift_out_reg;

    // Detectie front crescator pe SCLK
    reg sclk_d;
    wire sclk_rise = sclk & (~sclk_d);

    // MISO (Master In Slave Out) este bitul de iesire in timp real
    // Tristate (Z) cand CS_n este dezactivat (High)
    assign miso = cs_n ? 1'bZ : shift_out_reg[7]; 
    
    // Data_in (rezultat final) si byte_sync (sincronizare)
    reg [7:0] data_in_reg;
    reg byte_sync_reg;
    
    assign byte_sync = byte_sync_reg;
    assign data_in = data_in_reg;

    // Logica secventiala pe ceasul perifericului (clk)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_counter <= 3'b000;
            byte_sync_reg <= 1'b0;
            sclk_d <= 1'b0;
            data_in_reg <= 8'h00;
        end else begin
            // Capturare SCLK intarziat pentru detectie front
            sclk_d <= sclk;
            byte_sync_reg <= 1'b0; // Resetam semnalul de sincronizare in fiecare ciclu
            
            // Resetare contor si preincarcare MISO cand CS_n este dezactivat
            if (cs_n) begin
                bit_counter <= 3'b000;
                shift_out_reg <= data_out; // Incarcam datele de iesire, pregatind MISO
            end else begin
                // CS_n este activ (Low)
                
                if (sclk_rise) begin // Citim si scriem pe frontul crescator al SCLK
                    
                    // 1. Citim bitul de intrare (MOSI) si il mutam in shift register
                    shift_in_reg <= {shift_in_reg[6:0], mosi};
                    
                    // 2. Transmitem bitul de iesire (MISO) si mutam la stanga (MSB iese primul)
                    shift_out_reg <= {shift_out_reg[6:0], 1'b0};
                    
                    // 3. Incrementam contorul de biti
                    bit_counter <= bit_counter + 3'b001;

                    // 4. Daca s-au transferat 8 biti (bit_counter == 7)
                    if (bit_counter == 3'd7) begin
                        // Capturam byte-ul final in data_in_reg
                        data_in_reg <= {shift_in_reg[6:0], mosi}; 
                        byte_sync_reg <= 1'b1; // Semnalam un byte complet
                        bit_counter <= 3'b000; // Resetam contorul
                        // Reincarcam imediat shift_out_reg pentru urmatorul byte
                        shift_out_reg <= data_out; 
                    end
                end
            end
        end
    end

endmodule