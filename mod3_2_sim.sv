`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2024 09:49:00 AM
// Design Name: 
// Module Name: mod3_2_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mod3_2_sim();

//parameter
localparam packet_length = 8;
localparam data_width = 8;

//ports
reg clk;
reg reset_n;

reg [data_width:0]config_k;


reg [7:0]input_tdata;
reg input_tvalid;
wire input_tready;
reg input_tlast;

wire [7:0]output_tdata;
wire output_tvalid;
reg output_tready;
wire output_tlast;

mod3_2 #(.packet_length(packet_length),.data_width(data_width))
dut (.clk(clk),.reset_n(reset_n),.config_k(config_k),.input_tdata(input_tdata),.input_tvalid(input_tvalid),.input_tready(input_tready),.input_tlast(input_tlast),.output_tdata(output_tdata),.output_tvalid(output_tvalid),.output_tready(output_tready),.output_tlast(output_tlast));

// clock generation
always #5 clk = ~clk;

initial begin
clk = 0;
reset_n =0;
config_k = 8'd03;
input_tdata = 0;
input_tvalid = 0;
input_tlast = 0;
output_tready = 0;

repeat(8)@(posedge clk);
reset_n = 1;
repeat(8) begin
        repeat(7) begin
         input_tlast = 0;
         input_tvalid  = 1;
         output_tready =1;
         input_tdata = input_tdata + 1;
         @(posedge clk);
         end
 input_tvalid  = 1;
 output_tready =1;
 input_tdata = input_tdata + 1;
 input_tlast =1;
 @(posedge clk);
 end
repeat(20) @(posedge clk);

$finish;
end
endmodule
