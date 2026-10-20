`timescale 1ns/1ps

// Educational SPI Master: 8-bit transfers, SPI Mode 0 (CPOL=0, CPHA=0).
// This is a newly written example, not recovered source from the training report.
module spi_master #(
    parameter integer CLK_DIV = 4
) (
    input  wire       clk,
    input  wire       rst_n,   // Active-low synchronous reset
    input  wire       start,
    input  wire [7:0] tx_data,
    input  wire       miso,
    output reg        sclk,
    output reg        mosi,
    output reg        ss_n,
    output reg  [7:0] rx_data,
    output reg        busy,
    output reg        done
);

    reg [7:0] tx_shift;
    reg [7:0] rx_shift;
    reg [3:0] bit_count;
    integer   clk_count;

    always @(posedge clk) begin
        if (!rst_n) begin
            sclk      <= 1'b0;
            mosi      <= 1'b0;
            ss_n      <= 1'b1;
            rx_data   <= 8'h00;
            tx_shift  <= 8'h00;
            rx_shift  <= 8'h00;
            bit_count <= 4'd0;
            clk_count <= 0;
            busy      <= 1'b0;
            done      <= 1'b0;
        end else begin
            // done is a one-clock-cycle pulse.
            done <= 1'b0;

            if (!busy) begin
                sclk      <= 1'b0;
                clk_count <= 0;

                if (start) begin
                    tx_shift  <= tx_data;
                    rx_shift  <= 8'h00;
                    bit_count <= 4'd0;
                    mosi      <= tx_data[7];
                    ss_n      <= 1'b0;
                    busy      <= 1'b1;
                end else begin
                    ss_n <= 1'b1;
                end
            end else begin
                if (clk_count == CLK_DIV - 1) begin
                    clk_count <= 0;

                    if (sclk == 1'b0) begin
                        // Rising SCLK edge: Mode 0 samples MISO.
                        sclk      <= 1'b1;
                        rx_shift  <= {rx_shift[6:0], miso};
                        bit_count <= bit_count + 1'b1;
                    end else begin
                        // Falling SCLK edge: prepare the next MOSI bit.
                        sclk <= 1'b0;

                        if (bit_count == 4'd8) begin
                            ss_n    <= 1'b1;
                            busy    <= 1'b0;
                            done    <= 1'b1;
                            rx_data <= rx_shift;
                        end else begin
                            mosi     <= tx_shift[6];
                            tx_shift <= {tx_shift[6:0], 1'b0};
                        end
                    end
                end else begin
                    clk_count <= clk_count + 1;
                end
            end
        end
    end

endmodule
