
/* Data SRAM (read/write) Guillem Prenafeta
*/

`default_nettype none

module GPIO_MOD 
    #(//Paranetres memoria
        parameter depth = 64)     //Cap=depth*32b==4*depth bytes
    (
        input wire clk,
        input wire rst,

        inout wire [7:0] GPIO_out,  //8 bits de GPIOs

        input  wire [2-1:0]     addr, 
        input  wire [8-1:0]     i_wb_dat,

        input  wire             i_wb_we,
        input  wire             i_wb_cyc,
        output wire [8-1:0]      o_wb_rdt,
        output reg              o_wb_ack,

        output wire             int
        
    );



    reg [8-1:0] getGPIO, setGPIO, dirGPIO, isGPIO; 
    wire [8-1:0] intStatus;

    //dirGPIO
	 generate
		genvar i;
		 for(i=0;i<8;i=i+1) 
			begin : gen1
			  assign GPIO_out[i] = dirGPIO[i] ? setGPIO[i] : 1'bZ; //si dir==1 output
		 end
	endgenerate
   // assign GPIO_out = dirGPIO ? setGPIO : 1'bZ; //si dir==1 output

    assign intStatus = (~dirGPIO)&(setGPIO)&(getGPIO&(~GPIO_out)); //negedge gpio if defined as input and IE(setGPIO to 1)

    //getGPIO
    always@(posedge clk) begin
        getGPIO <= GPIO_out;
    end

   always @(posedge clk or posedge rst) begin
       if (rst) begin
           // reset
           dirGPIO<=8'd0; //definim com input tots
           setGPIO<=8'd0; //interrupcions apagades
           isGPIO<=8'd0;
       end
       else if (i_wb_we&&o_wb_ack) begin
           case(addr)
                2'b01: setGPIO<=i_wb_dat;
                2'b10: dirGPIO<=i_wb_dat;
                2'b11: isGPIO<=i_wb_dat | intStatus;
                default;
            endcase
       end else begin
           dirGPIO<=dirGPIO;
           setGPIO<=setGPIO;
           isGPIO<=isGPIO | intStatus;
       end
   end

   //ara int
   assign int = |(intStatus); //per saber de quin GPIO ve interrupt s'ha de mirar registre GPIO IS


    always @(posedge clk) begin //per gestionar ack
      o_wb_ack<=i_wb_cyc&(~o_wb_ack);
    end

    assign o_wb_rdt = (|addr) ? ( (&addr) ? isGPIO : ( addr[0] ? setGPIO : dirGPIO ) ) : getGPIO;

endmodule
