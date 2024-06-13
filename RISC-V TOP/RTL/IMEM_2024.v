
/* Instruction SRAM (read only) Guillem Prenafeta
Memoria de 32b de paraula
*/

`default_nettype none
`define LOADIMEM

module IMEM 
    #(//Paranetres memoria
        parameter memfile="codi.hex",
        parameter depth = 64)     //Cap=depth*32b==4*depth bytes
    (
        input wire i_clk,

        input  wire [31:0] i_wb_adr, //SRAM de dades (R/W)
        input  wire [31:0] i_wb_dat,
        input  wire        i_wb_we ,
        input  wire        i_wb_cyc,
        output reg [31:0]  o_wb_rdt,
        output reg         o_wb_ack
    );

   wire [27:2]  addr = i_wb_adr[27:2];

   //no es pot definir amb variables
   reg [31:0]        mem [0:depth-1];
	
	`ifdef LOADIMEM
		initial begin
			$readmemh(memfile, mem);
		end
	`endif

   always @(posedge i_clk) begin //lectura
      if(i_wb_cyc) begin
          o_wb_rdt<=mem[addr];
      end else begin
          o_wb_rdt<=o_wb_rdt;
      end
   end

   always @(posedge i_clk) o_wb_ack<=i_wb_cyc & (~o_wb_ack); //ack register


   integer i;
   always @(posedge i_clk) begin //escriptura
      if(i_wb_we&&o_wb_ack) begin
          mem[addr]<=i_wb_dat;
      end else begin
          for (i=0;i<depth;i=i+1) mem[i]<=mem[i];
			 //mem<=mem;
      end
   end
   
endmodule
