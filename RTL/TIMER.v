
/* Timer Guillem Prenafeta
*/

`default_nettype none

module TIMER
    #(//Paranetres memoria
        parameter depth = 64)     //Cap=depth*32b==4*depth bytes
    (
        input wire clk,
        input wire rst,
        
        input wire addr, 


        output wire int
        
    );


   reg [32-1:0] counter;
   reg [32-1:0] timerReg; //
   reg Trst;
   wire en;

   assign int=Trst;

   always @(posedge clk or posedge rst) begin
       if (rst|Trst) begin
           // reset
           counter<=32'b0;
       end
       else if (en) begin
           counter<=counter+1'b1;
       end else begin
           counter<=32'b0;
       end
   end

   always @(counter) begin
       if(int) begin
           Trst<=1'b1;
       end else begin
           Trst<=1'b0;
       end
   end



   assign int = counter==timerReg[0];


endmodule
