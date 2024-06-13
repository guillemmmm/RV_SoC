
/* Timer Guillem Prenafeta
*/

`default_nettype none

module TIMER_MOD
    #(//Paranetres memoria
        parameter depth = 64)     //Cap=depth*32b==4*depth bytes
    (
        input wire clk,
        input wire rst,

        input  wire [32-1:0]     i_wb_dat,

        input wire addr,

        input  wire             i_wb_we,
        input  wire             i_wb_cyc,
        output wire [32-1:0]      o_wb_rdt,
        output reg              o_wb_ack,

        output reg int
        
    );


   reg [32-1:0] counter;
   reg [32-1:0] timerReg; //
   reg en;

   always@(posedge clk) o_wb_ack<=i_wb_cyc&(~o_wb_ack);

   always @(posedge clk or posedge rst) begin
       if (rst) begin
           // reset
            timerReg<=32'hFFFFFFFF;
       end
       else if (i_wb_we&&o_wb_ack&&addr) begin
           timerReg <= i_wb_dat;
       end else begin
           timerReg <= timerReg;
       end
   end

   always @(posedge clk or posedge rst) begin
       if (rst) begin
           // reset
           counter<=32'b0;
           en<=1'b0;
           int<=1'b0;
       end else if(i_wb_we&&o_wb_ack&&(~addr)) begin
           counter<={i_wb_dat[32-1:1], 1'b0};
           en<=i_wb_dat[0];
           int<=1'b0;
       end else begin
            en<=en;
            if(en) begin
               if(counter==timerReg) begin
                   counter<=32'd0;
                   int<=1'b1;
               end else begin
                   counter<=counter+1'b1;
                   int<=1'b0;
               end
            end else begin
                int<=1'b0;
                counter<=32'd0;
            end
       end
   end

   assign o_wb_rdt = addr ? timerReg : {counter[31:1], en};


endmodule
