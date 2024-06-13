
/* SPADs MOD (functional blog only for testbench) Guillem Prenafeta
*/

`default_nettype none

module SPADsMOD 
    #(//Paranetres memoria
        parameter depth = 128)     //Cap=depth*32b==4*depth bytes
    (
        input wire clk,
        input wire rst,

        input  wire [31:0] i_wb_adr, //SRAM de dades (R/W)
        input  wire        i_wb_cyc,
        output reg [16-1:0]  o_wb_rdt,
        output reg         o_wb_ack,

        output reg o_wb_irq
    );

   wire wr_mem;

   //no es pot definir amb variables
   reg [31:0]        mem [0:depth-1];


   always @(posedge clk) begin //lectura memoria
      if(i_wb_cyc) begin
          o_wb_rdt<=mem[i_wb_adr[27:2]];
      end else begin
          o_wb_rdt<=o_wb_rdt;
      end
   end

   always @(posedge clk) begin //ack lectura
      o_wb_ack<=i_wb_cyc & (~o_wb_ack);
   end

   integer i;
   always @(posedge clk or posedge rst) begin
     if (rst) begin
       // reset
       for (i=0;i<depth;i=i+1) mem[i]<=16'd0;
       o_wb_irq<=1'b0;
     end
     else begin 
        for (i=0;i<depth;i=i+1) mem[i]<=mem[i];
        o_wb_irq<=o_wb_irq;
     end
   end



endmodule
