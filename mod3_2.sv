`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2024 10:26:51 AM
// Design Name: 
// Module Name: mod3_2
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


module mod3_2 # (
parameter packet_length = 8,
parameter data_width = 8
)
(
input clk,
input reset_n,

input [data_width:0]config_k,


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

   

    reg [ADDR_width-1:0] ptr = 0; // position where manipulation should start 
     reg [ADDR_width-1:0] r_ptr = 0;
    reg [data_width -1:0]mem[packet_length-1:0];  // memory block to store
    reg [data_width -1:0]mem_1[packet_length-1:0];  // memory block to store the added information for next bytes
    reg [data_width -1:0]mem_2[packet_length-1:0];  // memory block to store the final result 
    reg [ADDR_width-1:0] ptr_1 = 0; // pointer for the mem1 memory block
    reg [7:0]r_output_data;   
    reg r_output_valid;
    reg r_output_last;          // registers for all the outputs;
    wire [ADDR_width-1 : 0]stop;
    reg r_input_tlast;
    reg count = 1;
    
    assign  stop = packet_length - config_k;    
    assign output_tdata = r_output_data;
    assign output_tvalid = r_output_valid;
    assign output_tlast = r_output_last; 
    assign input_tready = (reset_n) ? 1: 0;


     integer i;
    // mem initiliazation to 0;
    initial begin
    // Initialize mem to all zeros
    for (i = 0; i < (packet_length); i = i + 1) begin
        mem[i] = 8'h00; // 8'h00 represents an 8-bit value of all zeros
        mem_1[i] = 8'h00;
        mem_2[i] = 8'h00;
    end
    end
    
    always@(posedge clk)             // 1st stage of pipelining  //  no delay but ptr value its taking before clock edge
    begin 
    if(!reset_n) mem[ptr] = 0;
    else begin
              if (input_tvalid)
              begin
               mem[ptr] <= input_tdata;
    
               end
             else mem[ptr] <= mem[ptr]; 
          end
    end
    
    
    
    always@(posedge clk)    // always block for pointer addition for every clock cycle  // there is no delay same clock cycle
    begin
       if(!reset_n) ptr <= 0;
       else if(input_tvalid)ptr <= ptr +1;
    end
    
     always@(posedge clk)           // for make my timing fix i am using reg ptr to make with mem 1 and mem 2
    begin 
    if(!reset_n) begin 
    r_input_tlast <= 0;
    r_ptr <= 0;
    end
    else begin
    r_input_tlast <= input_tlast;
    r_ptr <= ptr;
    end
    end   
   
    always@(posedge clk)    //second stage // here we are storing the data which should be manipulated in mem1
    begin
           if(r_ptr >= stop)
           begin
           mem_1[ptr_1] <= mem[r_ptr];        // there is one clock cycle delay to update mem_1 so we have taken ptr-1
 
           ptr_1 <= ptr_1 + 1;                // there is one clock cycle delay to update ptr_1
           
           end
             else begin
             mem_1[ptr_1] <= mem_1[ptr_1];
             ptr_1 <= 0;
             end
    end
    

always@(posedge clk)                               // memory 3  operation
begin
            if (count) begin
            mem_2[r_ptr] <= mem [r_ptr];
            count <= 0; 
            end
            else begin
             mem_2[r_ptr] <= mem[r_ptr] + mem_1[r_ptr];
            end
      end
 
 
    always@(posedge clk)    // to get the outputs into registers
    begin
     if (!reset_n) 
    begin
    r_output_data <= 0;
    r_output_valid <= 0;
    r_output_last <= 0;
    end
    else begin
         if(input_tvalid && output_tready) begin
         r_output_data <= mem_2[r_ptr];
         r_output_valid <= 1;
         r_output_last <= r_input_tlast;
         end
         else begin
         r_output_data <= r_output_data;
         r_output_valid <= 0;
         r_output_last <= r_output_last;
         end
    end

    end
endmodule
