module tagme3();
//main signals
wire [31:0] Data_bus;
wire [8:0] adress_bus; //not sure about length

//in out devices signals
wire Ack1;
wire Ack2;
wire GPIO1;
wire GPIO2;
wire IOWrite1;
wire IOWrite2;
wire [9:0] index; // signal have the adressbus and cs will be generated from module will be here 

// memory signals
wire memWrite;
wire [7:0] firstempty;


// Processor & dma signals (grant,IOWrite1,IOWrite2,memwrite,instruction,clock,databus,IOIP1,IOIP2)
wire grant;
reg [25:0] instruction;




// mo7awla 8albn fashla ll tgme3 

memory main_memory(memWrite , Data_bus , adress_bus , clk,firstempty);

IODevice2 io2(Ack2,GPIO2,Data_bus,IOWrite2,clk,index);

IODevice io1(Ack1,GPIO1,Data_bus,IOWrite1,clk,index);

end module
