/* BOOT fet per GUILLEM PRENAFETA

Per un codi de uns 180 paraules (32b) tarda uns 2**16 polsos de rellotge que a 10MHZ son 6.5ms
També depen SPI etc, nomes es un calcul, per tant 1kiParaules \simeq 36.4 ms
*/

`default_nettype none

module BOOT
    (
        input wire clk,
        input wire rst,
        input wire bootEN, //flanc de rellotge que indica que el prog esta a 1 quan es fa posedge del rstNegat

        output reg bootRST,

        //connexio amb IMEM

        input wire i_IMEM_ack,
        output reg o_IMEM_cyc,
        output reg o_IMEM_we, //sempre sera 1 (ja que volem escriure sempre quan posem el cyc
        output reg [32-1:0] RxWord,
        output wire [32-1:0] o_IMEM_adr, //o adreça de memoria
        input wire [32-1:0] i_IMEM_dat,

        //conexio amb SPI

        input wire i_wb_ack,
        input wire [8-1:0] i_data2R,
        output reg o_wb_cyc,
        output reg o_wb_we,
        output reg [8-1:0] o_data2W,
        output reg addr,
        input wire int //per avisar a la maquina d'estats que ha arribat la dada

    );

    parameter IDLE      =3'h0;  
    parameter START     =3'h1;
    parameter waitSPI   =3'h2;
    parameter SPIRd     =3'h3;
    parameter SPIWr     =3'h4;
    parameter IMEMWr    =3'h5;
    parameter IMEMRd    =3'h6;

    parameter modeLECTURA   =32'h1;
    parameter modeESCRIPTURA=32'h2;



    //Hi haura un protocol per anar escribint la IMEM paraula per paraula (4Byte) (es fara en serie ja que no cal programar rapidament)
    //maquina d'estats la cual va llegint dades per SPI i les escriu a la IMEM g

    reg [3-1:0] estat; //tenim 8 estats
    reg [3-1:0] nestat;
    reg [8-1:0] IMEM_datR[0:4-1];
    reg [32-1:0] WordCounter;

    //canvi estat sincron
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            estat <= 3'd0;
        end else begin
            estat <= nestat;
        end
    end

    reg init; //si es 0 indica que encara no s'ha configurat el mode
    reg mode; //si es 0 indica mode lectura si 1 escriptura de la memoria IMEM
    reg [1:0] wordC; //per enviar les 4W 0,1,2,3

    //calcula nstate
    always@(*) begin
        case (estat)
            IDLE: begin
                if(bootEN)  nestat<=START;
                else        nestat<=estat; //bucle
            end
            START: begin
                //if(i_wb_ack) begin //si rebem ack de que s'ha escrit al SPI
                    nestat<=waitSPI;
                //end else begin
                  //  nestat<=estat;
                //end
            end
            waitSPI: begin
                if(int) begin
                    nestat<=SPIRd;
                end else begin
                    nestat<=estat;
                end
            end
            SPIRd: begin
                if(i_wb_ack) begin
                    if(&wordC) begin
                        if(mode) begin //mode w
                            nestat<=IMEMWr;
                        end else begin //mode r
                            nestat<=IMEMRd;
                        end
                    end else begin
                        nestat<=SPIWr;
                    end
                    /*if(|wordC) begin //SI es dif de 0,, quan sigui 0 vol dir que venim de rebre 4W
                        nestat<=SPIWr;
                    end else begin
                        if(mode) begin //mode w
                            nestat<=IMEMWr;
                        end else begin //mode r
                            nestat<=IMEMRd;
                        end
                    end */       
                end else begin
                    nestat<=estat;
                end
            end
            IMEMWr: begin
                if(i_IMEM_ack) begin
                    nestat<=SPIWr;
                end else begin
                    nestat<=estat;
                end
            end
            IMEMRd: begin
                if(i_IMEM_ack) begin
                    nestat<=SPIWr;
                end else begin
                    nestat<=estat;
                end
            end
            SPIWr: begin
                if(i_wb_ack) begin
                    if(&wordC) begin //si wordC=3
                        if(&RxWord) begin
                            nestat<=IDLE; //entrem en bucle infinit
                        end else begin
                            nestat<=waitSPI;
                        end
                    end else begin
                        nestat<=waitSPI; //no cal
                    end
                end else begin
                    nestat<=estat;
                end
            end
            default: begin
                nestat<=IDLE;
            end
        endcase  
    end

    //sortides sincrones
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            bootRST<=1'b0;
            o_IMEM_cyc<=1'b0;
            o_IMEM_we<=1'b0; 
            //RxWord<=32'd0; //dona igual
            WordCounter<=32'hFFFFFFFC;
            o_wb_cyc<=1'b0;
            o_wb_we<=1'b0;
            addr<=1'b0;
            init<=1'b0;
            mode<=1'b0;
            IMEM_datR[3]<=8'd0;
            IMEM_datR[2]<=8'd0;
            IMEM_datR[1]<=8'd0;
            IMEM_datR[0]<=8'd0;
        end else begin
            case (estat)
                IDLE: begin
                    bootRST<=1'b0;
                    o_IMEM_cyc<=1'b0;
                    o_IMEM_we<=1'b0; 
                    o_wb_cyc<=1'b0; //nomes hi hauria problema si despres no canvies d'estat, pero sempre canvia
                    o_wb_we<=1'b0;
                    RxWord<=32'd0;
                end
                START: begin
                    bootRST<=1'b1;
                    o_IMEM_cyc<=1'b0;
                    o_IMEM_we<=1'b0; 
                    o_wb_cyc<=1'b0; //nomes hi hauria problema si despres no canvies d'estat, pero sempre canvia
                    o_wb_we<=1'b0;
                    //RxWord<=32'd0;
                    wordC<=2'd3;
                end
                waitSPI: begin
                    bootRST<=1'b1;
                    o_IMEM_cyc<=1'b0;
                    o_IMEM_we<=1'b0;
                    o_wb_cyc<=1'b0;
                    o_wb_we<=1'b0;
                    addr<=1'b0; //no farem mes conf al SPI
                end
                SPIRd: begin //durada de 2 cicles de rellotge
                    bootRST<=1'b1;
                    o_IMEM_cyc<=1'b0;
                    o_IMEM_we<=1'b0;
                    o_wb_cyc<=~i_wb_ack;
                    o_wb_we<=1'b0;

                    if(i_wb_ack) begin //un cop rebem
                        //wordC<=wordC+1'b1;
                        if(~init) begin
                            wordC<=2'd3;
                            if(i_data2R==modeLECTURA) begin
                                mode<=1'b0; //mode lectura
                                init<=1'b1;
                            end else if(i_data2R==modeESCRIPTURA) begin
                                mode<=1'b1; //mode escriptura
                                init<=1'b1;
                            end else begin
                                init<=1'b0; //sino res
                            end
                        end else begin
                            //wordC<=wordC-1'b1;
                            RxWord<={i_data2R, RxWord[32-1:8]};
                            if(~mode) begin //si estem fent lectura de la memoria
                                //WordCounter<={i_data2R, RxWord[32-1:8]}; //seguent direccio de memmoria que llegirem
                                //WordCounter<=RxWord; //encara no s'ha llegit la direccio que voldem llegir de IMEM
                            end else begin
                                //RxWord<={i_data2R, RxWord[32-1:8]}; //first LSB
                                WordCounter<=WordCounter+1'b1; //sumem de 1 en 1 
                            end
                        end
                    end else begin
                        wordC<=wordC+o_wb_cyc;
                    end
                end
                IMEMWr: begin
                    bootRST<=1'b1;
                    if(&RxWord) begin //si es word final
                        o_IMEM_cyc<=1'b0;
                    end else begin
                        o_IMEM_cyc<=~i_IMEM_ack;
                    end
                    o_IMEM_we<=1'b1; 
                    o_wb_cyc<=1'b0; //nomes hi hauria problema si despres no canvies d'estat, pero sempre canvia
                    o_wb_we<=1'b0; //escribim SPI
                    //RxWord i WordCounter ja s'han actualitzat
                end
                IMEMRd: begin
                    bootRST<=1'b1;
                    o_IMEM_cyc<=~i_IMEM_ack;
                    o_IMEM_we<=1'b0; 
                    o_wb_cyc<=1'b0; //nomes hi hauria problema si despres no canvies d'estat, pero sempre canvia
                    o_wb_we<=1'b0; //escribim SPI
                    if(i_IMEM_ack) begin
                        IMEM_datR[3]<=i_IMEM_dat[32-1:24]; //llegim dada IMEM i la posem per escriure al SPI
                        IMEM_datR[2]<=i_IMEM_dat[24-1:16];
                        IMEM_datR[1]<=i_IMEM_dat[16-1: 8];
                        IMEM_datR[0]<=i_IMEM_dat[ 8-1: 0];
                    end
                    //RxWord i WordCounter ja s'han actualitzat
                end
                SPIWr: begin
                    bootRST<=1'b1;
                    o_IMEM_cyc<=1'b0;
                    o_IMEM_we<=1'b0;
                    o_wb_cyc<=~i_wb_ack;
                    o_wb_we<=1'b1; //escribim spi
                end
            endcase
        end
    end

    wire [1:0] ind;
    assign ind=wordC+1'b1;
    assign o_data2W =  mode ? WordCounter[9:2] : (IMEM_datR[ind]) ; //first LSB on wordC va de 0->1->2->3 word

    assign o_IMEM_adr = mode ? (WordCounter) : (RxWord);



   
endmodule
