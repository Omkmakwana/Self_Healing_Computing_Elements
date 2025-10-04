// reconfig_region_interface.v
// Abstract interface wrapper to standardize signals crossing static <-> reconfig partitions.
// In a real design, this may be implemented via partition pins or bus macros.

module reconfig_region_interface #(
    parameter DATA_W = 32
) (
    input  wire              clk,
    input  wire              rst_n,

    // Upstream (static) side
    input  wire [DATA_W-1:0] in_data,
    input  wire              in_valid,
    output wire              in_ready,

    // Downstream (static) side
    output wire [DATA_W-1:0] out_data,
    output wire              out_valid,
    input  wire              out_ready,

    // To Reconfigurable Partition (RP)
    output wire [DATA_W-1:0] rp_in_data,
    output wire              rp_in_valid,
    input  wire              rp_in_ready,

    input  wire [DATA_W-1:0] rp_out_data,
    input  wire              rp_out_valid,
    output wire              rp_out_ready
);

    // Simple pass-through for skeleton
    assign rp_in_data  = in_data;
    assign rp_in_valid = in_valid;
    assign in_ready    = rp_in_ready;

    assign out_data    = rp_out_data;
    assign out_valid   = rp_out_valid;
    assign rp_out_ready= out_ready;

endmodule
