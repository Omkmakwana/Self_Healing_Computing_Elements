// guardian_module.v
// Skeleton of a Guardian Module for SRA
// Monitors metrics, performs feature extraction & anomaly scoring (placeholder), raises alert

module guardian_module #(
    parameter BLOCK_ID = 0,
    parameter FEATURE_WIDTH = 16,
    parameter SCORE_WIDTH = 16
) (
    input  wire              clk,
    input  wire              rst_n,

    // Telemetry inputs (simplified)
    input  wire [11:0]       temp_code,
    input  wire [11:0]       volt_code,
    input  wire [15:0]       timing_margin,

    // Control
    input  wire              enable,

    // Output alert
    output reg               alert_valid,
    output reg  [15:0]       anomaly_score,
    output reg  [15:0]       block_id
);

    // Simple placeholder feature extraction (delta on temp & volt)
    reg [11:0] temp_prev, volt_prev;
    wire [12:0] temp_delta = {1'b0,temp_code} - {1'b0,temp_prev};
    wire [12:0] volt_delta = {1'b0,volt_code} - {1'b0,volt_prev};

    // Naive anomaly scoring placeholder
    // TODO: replace with quantized TinyML inference block
    wire [15:0] score_raw = (temp_delta[12] ? -temp_delta[11:0] : temp_delta[11:0]) +
                            (volt_delta[12] ? -volt_delta[11:0] : volt_delta[11:0]) +
                            (timing_margin[15:8]);

    // Thresholds (static for now)
    localparam [15:0] THRESHOLD = 16'd80;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            temp_prev     <= 0;
            volt_prev     <= 0;
            anomaly_score <= 0;
            alert_valid   <= 0;
            block_id      <= BLOCK_ID;
        end else if (enable) begin
            temp_prev     <= temp_code;
            volt_prev     <= volt_code;
            anomaly_score <= score_raw;
            if (score_raw > THRESHOLD) begin
                alert_valid <= 1'b1;
            end else begin
                alert_valid <= 1'b0;
            end
        end else begin
            alert_valid <= 1'b0;
        end
    end

endmodule
