`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2024 10:21:53 AM
// Design Name: 
// Module Name: mod3_1
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


module mod3_1(
input clk,
input reset_n,
    input  signed [22:0]a,    // 23 bit
    input  signed [22:0]b,    // 23 bit
    input signed [16:0]c,    // 17 bit
output signed [39:0]y
    );
    
    reg signed [22:0] a1;  // registering inputs and outputs
    reg signed [22:0] b1;
    reg signed [16:0] c1;
    reg signed [23:0] sum;
    reg signed [39:0]result;
    always@(posedge clk)
    begin
             if(!reset_n)
             begin
             a1<=0;
             b1<=0;
             c1<=0;
             sum <= 0;
             result <=0;
             end
             else begin
             a1<=a;
             b1<=b;
             c1<=c;
             sum <= a1+b1;
            result <= sum * c1;
             end
    end
  assign y = result;
endmodule
