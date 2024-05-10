//`define SERV_CLEAR_RAM
module serv_rf_ram
  #(parameter width=0,
    parameter csr_regs=4,
    parameter depth=32*(32+csr_regs)/width)
   (input wire i_clk,
    input wire [$clog2(depth)-1:0] i_waddr,
    input wire [width-1:0] 	   i_wdata,
    input wire 			   i_wen,
    input wire [$clog2(depth)-1:0] i_raddr,
    input wire			   i_ren,
    output wire [width-1:0] 	   o_rdata);

   reg [width-1:0] 		   memory [0:depth-1];
   reg [width-1:0] 		   rdata ;

   always @(posedge i_clk) begin
      if (i_wen)
	memory[i_waddr] <= i_wdata;
      rdata <= i_ren ? memory[i_raddr] : {width{1'bx}};
   end

   /* Reads from reg x0 needs to return 0
    Check that the part of the read address corresponding to the register
    is zero and gate the output
    width LSB of reg index $clog2(width)
    2     4                1
    4     3                2
    8     2                3
    16    1                4
    32    0                5
    */
   reg regzero;

   always @(posedge i_clk)
     regzero <= !(|i_raddr[$clog2(depth)-1:5-$clog2(width)]);

   assign o_rdata = rdata & ~{width{regzero}};

`ifdef SERV_CLEAR_RAM
initial begin        //DEFINE SP  //IMPORTANT!!!!!! ARA TENIM 0x1000
  memory[32]=2'b00; //a15         //num== a0a1 a2a3 a4a5 a6a7 a8a9 a10a11 a12a13 a14a15
  memory[33]=2'b00; //a14a15      //volem 0001 0000 0000 0000 0000 0001   0000   0000  //ultima posicio memoria RAM
  memory[34]=2'b00; //a13
  memory[35]=2'b00; //a12
  memory[36]=2'b01; //a11 //abans 10
  memory[37]=2'b00; //a10
  memory[38]=2'b00; //a9
  memory[39]=2'b00; //a8
  memory[40]=2'b00; //a7
  memory[41]=2'b00; //a6
  memory[42]=2'b00; //a5
  memory[43]=2'b00; //a4
  memory[44]=2'b00; //a3
  memory[45]=2'b00; //a2
  memory[46]=2'b01; //a1
  memory[47]=2'b00; //a0
end

   integer i;
   initial begin
     for (i=0;i<depth;i=i+1)
       if((i<32)|(i>47)) begin
          memory[i] = {width{1'd0}};
        end
    end
`endif
endmodule
