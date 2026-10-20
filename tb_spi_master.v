`timescale 1ns/1ps

module tb_spi_master;

    reg        clk = 1'b0;
    reg        rst_n = 1'b0;
    reg        start = 1'b0;
    reg [7:0]  tx_data = 8'h3C;
    reg        miso = 1'b0;

    wire       sclk;
    wire       mosi;
    wire       ss_n;
    wire [7:0] rx_data;
    wire       busy;
    wire       done;

    localparam [7:0] SLAVE_RESPONSE = 8'hA5;
    integer rx_bit_index = 0;

    spi_master #(.CLK_DIV(4)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .tx_data(tx_data),
        .miso(miso),
        .sclk(sclk),
        .mosi(mosi),
        .ss_n(ss_n),
        .rx_data(rx_data),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    // Simple Mode-0 slave model:
    // place the first response bit on MISO when selected, then update
    // MISO on each falling SCLK edge so it is stable before the next rise.
    always @(negedge ss_n) begin
        rx_bit_index = 0;
        miso = SLAVE_RESPONSE[7];
    end

    always @(negedge sclk) begin
        if (!ss_n) begin
            if (rx_bit_index < 7) begin
                rx_bit_index = rx_bit_index + 1;
                miso = SLAVE_RESPONSE[7-rx_bit_index];
            end
        end
    end

    initial begin
        $dumpfile("spi_master.vcd");
        $dumpvars(0, tb_spi_master);

        repeat (3) @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;

        wait (done == 1'b1);
        #25;

        if (rx_data !== SLAVE_RESPONSE) begin
            $display("FAIL: expected RX=0x%02h, got RX=0x%02h",
                     SLAVE_RESPONSE, rx_data);
            $fatal(1);
        end

        $display("PASS: SPI transfer completed. TX=0x%02h RX=0x%02h",
                 tx_data, rx_data);
        $finish;
    end

    initial begin
        #10000;
        $display("FAIL: simulation timeout");
        $fatal(1);
    end

endmodule
