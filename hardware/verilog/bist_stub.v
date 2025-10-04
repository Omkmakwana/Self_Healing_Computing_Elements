// bist_stub.v
// Simple placeholder Built-In Self-Test module

module bist_stub #(
    parameter BLOCK_ID = 0
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    output reg  done,
    output reg  pass
);

    reg [3:0] state;

    localparam IDLE  = 4'd0;
    localparam RUN   = 4'd1;
    localparam CHECK = 4'd2;
    localparam DONE  = 4'd3;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
            done  <= 0;
            pass  <= 0;
        end else begin
            case(state)
                IDLE: begin
                    done <= 0;
                    pass <= 0;
                    if(start) state <= RUN;
                end
                RUN: begin
                    // Placeholder for pattern generation & response capture
                    state <= CHECK;
                end
                CHECK: begin
                    // Always pass in stub
                    pass  <= 1'b1;
                    state <= DONE;
                end
                DONE: begin
                    done <= 1'b1;
                    if(!start) state <= IDLE; // ready for next cycle
                end
            endcase
        end
    end
endmodule
