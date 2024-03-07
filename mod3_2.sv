`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 10:25:52 AM
// Design Name: 
// Module Name: mod3_2_update
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


module mod3_2_update #(
parameter packet_length = 8,
parameter data_width = 8,
parameter config_k = 3
)
(
input clk,
input reset_n,


input [7:0]input_tdata,
input input_tvalid,
output input_tready,
input input_tlast,

output [7:0]output_tdata,
output output_tvalid,
input output_tready,
output output_tlast
    );
   
    
     // function to find log 
   
   function integer log2 (input integer depth);
		begin
			for(log2=0; depth>0; log2=log2+1)
				depth = depth >> 1;
		end
	endfunction


    localparam ADDR_width = log2(packet_length) - 1;   // i have used loacal param instead of wire becuase addr_width should be constant throughout 
    localparam j_width = log2(config_k) + 1; 

reg [7:0]r_input_tdata;
reg r_input_tlast;

reg [7:0]r_output_tdata;
reg r_output_tvalid;
reg r_output_tlast;
reg r_output_tready;

reg [ADDR_width-1:0]count;
reg [ADDR_width-1:0]r_count;
reg [7:0]mem[config_k+1:0]; 

wire [ADDR_width-1:0]stop;

assign stop = packet_length  - config_k;

  integer i;
  reg [j_width:0]j =0;
    // mem initiliazation to 0;
    initial begin
    // Initialize mem to all zeros
    for (i = 0; i <= (config_k+1); i = i + 1) begin
        mem[i] = 8'h00; // 8'h00 represents an 8-bit value of all zeros
    end
    end


always@(posedge clk)                // counter 
begin
if(!reset_n) count <= 0;
else 
count <= count + 1;
end

always@(posedge clk)                // registering the counter 
begin
if(!reset_n) r_count <= 0;
else 
r_count <= count;
end

always@(posedge clk)              // for addition
begin
if(!reset_n)
begin
r_input_tdata <= 0;
r_input_tlast <=0;
end
else begin
                  if(input_tvalid && input_tready && (count<stop)) begin
                  r_input_tdata <= input_tdata + mem[count];
                  r_input_tlast <= 0;
                  end
                  else  begin
                  r_input_tdata <= input_tdata;
                  r_input_tlast <= input_tlast;
                  end                  
end
end

always@(posedge clk)                     // adding data into memory
begin
if(input_tvalid && input_tready && (r_count>=stop)) begin
mem[j] <=  r_input_tdata;
end
else mem[j] <= mem[j];
end

always@(posedge clk)                            // controlling the pointer of j
begin
if(input_tvalid && input_tready && (r_count>=stop) && (j < config_k-1)) begin
j <= j +1;
end
else j <= 0;
end

always@(posedge clk)                           // registering the output ready
begin
if(!reset_n) r_output_tready <= 0;
else r_output_tready <= output_tready;
end

always@(posedge clk)                                      // data out 
begin
if(!reset_n)begin 
 r_output_tdata <= 0;
 r_output_tvalid <= 0;
 r_output_tlast <=0;
 end
else begin 
               if (r_output_tready) begin
               r_output_tdata <= r_input_tdata;
               r_output_tvalid <= 1;
               r_output_tlast <= r_input_tlast;
               end
               else begin 
               r_output_tdata <= r_output_tdata;
               r_output_tvalid <= 0;
               r_output_tlast <= r_output_tlast;               
               end
end
end


assign  output_tdata = r_output_tdata;
assign  output_tlast = r_output_tlast;
assign   output_tvalid = r_output_tvalid;
assign   input_tready = output_tready;

endmodule
