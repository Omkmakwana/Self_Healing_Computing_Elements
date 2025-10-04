// tb_guardian_module.v
// Minimal simulation testbench skeleton for guardian_module

`timescale 1ns/1ps

module tb_guardian_module;
    reg clk = 0;
    reg rst_n = 0;
    reg enable = 0;
    reg [11:0] temp_code = 12'd30;
    reg [11:0] volt_code = 12'd2048; // mid-scale placeholder
    reg [15:0] timing_margin = 16'd200;

    wire alert_valid;
    wire [15:0] anomaly_score;
    wire [15:0] block_id;

    guardian_module #(.BLOCK_ID(5)) dut (
        .clk(clk), .rst_n(rst_n), .temp_code(temp_code), .volt_code(volt_code),
        .timing_margin(timing_margin), .enable(enable), .alert_valid(alert_valid),
        .anomaly_score(anomaly_score), .block_id(block_id)
    );

    always #5 clk = ~clk; // 100MHz

    initial begin
        $display("[TB] Starting guardian module test");
        #20 rst_n = 1; enable = 1;
        // Stable period
        repeat(20) begin
            #10;
        end
        // Inject temp spike
        temp_code = 12'd150; // large jump
        #50;
        // Restore normal
        temp_code = 12'd32;
        #100;
        $display("[TB] Final anomaly_score=%0d alert_valid=%0d", anomaly_score, alert_valid);
        $finish;
    end
endmodule
