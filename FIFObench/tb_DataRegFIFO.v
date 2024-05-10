
`timescale 1 ns / 1 ns

module tb_DataRegFIFO;
	reg clk;
	reg reset=1;
	reg addr_valid=0;
	reg data_valid=0;
	wire ready;
	wire [16-1:0] rdata;
	wire full;
	wire empty;
	reg [16-1:0] wdata=16'b0;
	reg [16-1:0] varOut;
	reg shiftFIFO;

	integer i;

	localparam ser_half_period = 217;
	
	// clock parameters
	parameter HALF_CLOCK_PERIOD_50M 	= 10;
	parameter HALF_CLOCK_PERIOD_32M		= 15625;
	parameter HALF_CLOCK_PERIOD_10M 	= 50000;
	parameter HALF_CLOCK_PERIOD_1M 		= 500000;
	parameter HALF_CLOCK_PERIOD_100K 	= 5000000;
	parameter HALF_CLOCK_PERIOD_4608 	= 108506944;

	// clock generation
	always begin
		clk = 1;
    	#HALF_CLOCK_PERIOD_50M;
    	clk = 0;
    	#HALF_CLOCK_PERIOD_50M;
	end


	SPIfifo DUT (
		.clk    	  (clk      	 ),
		.rstn  		(reset),

		.ren 	(addr_valid),
		.wen 	(data_valid),
		.rdata  		(rdata),
		.full    (full),
		.empty 		(empty),
		.shiftFIFO  (shiftFIFO),
		.wdata   (wdata)
		);

	task putWord; 
		input [16-1:0] var;
		begin
			wdata=var;
			#5;
			data_valid=1;
			@(posedge clk);
			#5;
			data_valid=0;
			@(posedge clk); //minim 1 clk entre escriptures
			#5;

		end
	endtask

	task readWord;
		output [15:0] data_out;
		begin
		$display("Ara abem a llegir, %d",$time);
		addr_valid=1;
		@(posedge clk);
		data_out=rdata;
		addr_valid=0;
		#5;
		end
	endtask

	initial begin
		#20;
		shiftFIFO=1'b0;
		reset=0;
		#50;
		reset=1;
		#50;
		//L'hem definit amb un tamany de 16 paraules de 32 bits
		//Primer li fiquem 6 paraules i després les llegirem
		putWord(16'hFFFF);
		putWord(16'h00FF);
		putWord(16'h1111);
		putWord(16'hB232);
		//#30
		readWord(varOut);
		$display("%h",varOut);
		@(posedge clk);
		#1;
		readWord(varOut);
		$display("%h",varOut);
		putWord(16'hFFFF);
		putWord(16'hF00FF);
		putWord(16'h1111);
		putWord(16'hB232);
		putWord(16'hCFFF);
		putWord(16'hE0FF);
		$display("Ara saltará el full, %d",$time);
		putWord(16'hAAAA); //salta senyal full
		putWord(16'hBBBB);

		for(i=0;i<12;i=i+1) begin
			readWord(varOut); //buidem fifo
		end

		#50;

		for(i=0;i<12;i=i+1) begin
			putWord(16'd23); //buidem fifo
		end

		#50;

		//fem flush
		@(posedge clk);
		shiftFIFO=1'b1;
		@(posedge clk);
		shiftFIFO=1'b0;

		#500
		$stop;








	end


	

endmodule

