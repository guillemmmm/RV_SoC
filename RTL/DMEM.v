
/* Data SRAM (read/write) Guillem Prenafeta
*/

`default_nettype none

module DMEM 
    #(//Paranetres memoria
        parameter depth = 64)     //Cap=depth*32b==4*depth bytes
    (
        input wire i_clk,

        input  wire [31:0] i_wb_adr, //SRAM de dades (R/W)
        input  wire [31:0] i_wb_dat,
        input  wire [3:0]  i_wb_sel,
        input  wire        i_wb_we ,
        input  wire        i_wb_cyc,
        output reg [31:0]  o_wb_rdt,
        output reg         o_wb_ack
    );

   wire [27:2]  addr = i_wb_adr[27:2];

   //no es pot definir amb variables
   reg [31:0]        mem [0:depth-1];


   wire [31:0] mem_ac;
   assign mem_ac = mem[addr];



   wire [7:0] ByteSelect [0:3];
   assign ByteSelect[3] = i_wb_sel[3] ? i_wb_dat[31:24] : mem_ac[31:24];
   assign ByteSelect[2] = i_wb_sel[2] ? i_wb_dat[23:16] : mem_ac[23:16];
   assign ByteSelect[1] = i_wb_sel[1] ? i_wb_dat[15:8] : mem_ac[15:8];
   assign ByteSelect[0] = i_wb_sel[0] ? i_wb_dat[7:0] : mem_ac[7:0];

   always @(posedge i_clk) begin //lectura
      if(i_wb_cyc) begin
          o_wb_rdt<=mem_ac;
      end else begin
          o_wb_rdt<=o_wb_rdt;
      end
   end

   always @(posedge i_clk) begin //ack
      o_wb_ack<=i_wb_cyc & (~o_wb_ack);
   end

   always @(posedge i_clk) begin //escriptura
      if(i_wb_we&&o_wb_ack) begin
          //mirem el SEL
          mem[addr]<={ByteSelect[3],ByteSelect[2],ByteSelect[1],ByteSelect[0]};


      end else begin
          mem[addr]<=mem_ac;
      end
   end

    //  integer i;
   /*initial begin

     for (i=0; i<depth; i=i+1) begin //primer omplim amb zeros
       mem[i]=0;
     end
     o_wb_rdt=0;

    end*/

endmodule
