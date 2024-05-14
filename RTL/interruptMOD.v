
// MODUL interrupcions SLAVE PARAMETRITZABLE TANT DE MIDA COM DE MODE DE FUNCIONAMENT
// fet per GUILLEM PRENAFETA (UB 2024)

// MODUL interrupcions el qual detecta els flancs de pujada de la interrupcio, i quan salta la interrupcio es neteja 
    //la font automaticament


module interrupt
    (  
        //Control/Data signals (2CPU)

        input wire rstn,
        input wire clk,

        input wire int1, //ex SSI
        input wire int2, //ex GPIO
        input wire int3, //ex Timer
        input wire int4, //ex Other HW units
        input wire int5, //ex Other HW units
        input wire int6, //ex Other HW units
        input wire int7, //ex Other HW units
        input wire int8, //ex Other HW units

        input wire ins_ack, // per saber quan resetejar int

        //SPI interface (2ext)

        output reg int, //module to generate int for the CPU

        input wire          i_wb_cyc, //register read
        input wire          addr,
        output wire [8-1:0]  o_wb_rdt,
        output reg         o_wb_ack,
        input wire [8-1:0] i_wb_data,
        input wire        i_wb_we
        );


    reg [8-1:0] registers[1:0]; //status & IE

    // [15:0] registers status [0]:
/*
 *
 *      [n]   Int 'n' status    (R/W)    (0)
 */

    // [15:0] registers IE [1]:
/*
 *
 *      [n]   Int 'n' IE        (R/W)    (0)
 */

    wire posedgeInt;

    assign o_wb_rdt = addr ? registers[1] : registers[0];

    //detetctor posedge per generar interrupcio
    always@(posedge clk or negedge rstn) begin
        if(~rstn)           int<=1'b0;
        else if(int) begin
            if(ins_ack)     int<=1'b0; //reset of int
            else            int<=int;
        end else begin
            if(posedgeInt)  int<=1'b1;
            else            int<=int;
        end
    end

    //per si de cas fem detetcor de posedges
    reg [8-1:0]     pos;
    wire [8-1:0]    interrupts = {int8, int7, int6, int5, int4, int3, int2, int1};
    wire [8-1:0]    posDetect = ((~pos)&interrupts);

    always@(posedge clk)    pos<=registers[1] & interrupts;

    assign posedgeInt = |posDetect;

    always@(posedge clk or negedge rstn) begin
        if(~rstn) begin
            registers[1]<=8'd0;
            registers[0]<=8'd0; 
        end else begin
            if(i_wb_we&o_wb_ack) begin
                if(addr)    registers[1]<=i_wb_data;
                else        registers[0]<=i_wb_data | posDetect;
            end else begin
                registers[1]<=registers[1];
                registers[0]<=registers[0] | posDetect;
            end
        end
    end

    always@(posedge clk) o_wb_ack<=i_wb_cyc&(~o_wb_ack);

endmodule




