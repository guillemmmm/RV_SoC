//FIFO memory made by Guillem Prenafeta

//ADR de DataReg sera de 0x07000000 to 0x07FFFFFF (0xFFFFFF posicions) que equival a 24b-->fins a 2MiB
//Ordre addr DataReg

//`include "clog2_function.vh"

module SPIfifo #(parameter SizeWords=8) //16 registres de 32b 0x07000000, 0x07000004...
(
input wire          clk,
input wire          rstn,

input wire          wen, //vol escriure
input wire          ren, //vol llegir
//input wire          cyc; //indica que vol llegir o escriure

input wire [16-1:0]     wdata,
output wire [16-1:0]    rdata, //data a llegir
output reg             full, //indica que esta plena
output reg             empty,  //indica que esta buida

input wire              shiftFIFO //per resetejar fifo

);

localparam  BitSizeWords    = $clog2(SizeWords); //log en base 2 de SizeWords
//integer i;

//si Rd COunter = wcounter o FULL o empty

reg [16-1:0] mem [0:SizeWords-1];

reg dataIn;

reg [BitSizeWords-1:0] wpointer; //tamany de log2SizeWords
reg [BitSizeWords-1:0] rdpointer;

assign rdata = mem[rdpointer];


assign full=(wpointer==(rdpointer)) & dataIn;
assign empty=!dataIn;

//escriptura i lectura
always @(posedge clk or negedge rstn) begin
    if(!rstn | !shiftFIFO) begin
        //for (i=0; i<SizeWords; i=i+1) mem[i] <= 16'b0; //dona igual
        wpointer<={BitSizeWords{1'b0}};
        rdpointer<={BitSizeWords{1'b0}}; //apunti al ultim registre
        dataIn<=1'b0;
    end else begin
        if(wen & !full & ren & dataIn) begin
            wpointer<=wpointer+1'b1;
            mem[wpointer]<=wdata;
            rdpointer<=rdpointer+1'b1;
            dataIn<=1'b1;
        end
        else if(wen & !full) begin
            wpointer<=wpointer+1'b1;
            mem[wpointer]<=wdata;
            dataIn<=1'b1;
        end else if(ren & dataIn) begin
            rdpointer<=rdpointer+1'b1;
            if((rdpointer+1'd1)==wpointer) dataIn<=1'b0;
            else dataIn<=1'b1;
        end
    end
end




endmodule