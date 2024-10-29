`timescale 1ns / 1ps

module graycount(
    input wire clk,
    input wire [15:0] phases,
    output wire [4:0] sampled_binary
    );

    logic [4:0] gray;
    logic [4:0] binary;

    assign sampled_binary = binary;

    always_ff @(posedge clk) begin
        gray[0] <= phases[1] ^ phases[3] ^ phases[5] ^
                   phases[7] ^ phases[9] ^ phases[11] ^
                   phases[13] ^ phases[15];
        gray[1] <= phases[2] ^ phases[6] ^ phases[10] ^ phases[14];
        gray[2] <= phases[4] ^ phases[12];
        gray[3] <= phases[8];
        gray[4] <= phases[0];
    end

    integer i;
    always_comb begin
        binary[4] = gray[4];
        for(i = 3; i >= 0;i--) begin
            binary[i] = gray[i] ^ binary[i+1];
        end
    end

endmodule
