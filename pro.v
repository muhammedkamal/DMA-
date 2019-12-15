          
module clkgenerator(clock);                 
output reg clock;  
initial
clock = 1;
always 
begin
#3
clock = ~ clock;

end
endmodule
/* this module is made by me to check communication between bus , processor and I/O .. neglect it 
module device(IOIP,IOwrite);
output IOIP;
input IOwrite;
reg [31:0] buffers [0:31];
integer k;
initial
begin
for ( k =0;k<32;k=k+1)
buffers[k]<=k;
end
endmodule
*/

module RegisterFile (ReadData1, ReadData2, Readreg1, Readreg2, Writereg,source,destination, RegWrite,op,type,clk,data);

/*
the interface of the RegisterFile which has the following:
 1- Three 5 bits inputs which are the adressess of the wanted registers
 2- Two 1 bit input of RegWrite if we want to write data and the input clock
 3- One input of 32 bits which is the data we will write if RegWrite input is true 
 4- Two outputs of 32 bits which represent the data read from the two Registers with the address of ReadReg1 & ReadReg2
 5- Thirty Two Registers with 32 bits each to assign the read data from the registers with the adressess of ReadReg1 & ReadReg2*/ 



input RegWrite,clk;
input [1:0] op,type;
integer WriteData; // modified from reg [31:0] to integer for -ve numbers 
input [3:0]Readreg1,Readreg2,Writereg; 
input [7:0] source,destination;
output [31:0] ReadData1, ReadData2;
reg [31:0] Register [0:15];

inout [31:0] data; 
wire[31:0] fake_WriteData;
reg [31:0] fake_read;
assign data = ((op !=2'b01)&&(op !=2'b10)&&(op !=2'b11))? fake_read : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;  //data is in output mode 
assign fake_WriteData = ((op !=2'b01)&&(op !=2'b10)&&(op !=2'b11))? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : data; //data is in input mode



assign ReadData1 = Register[Readreg1];  
assign ReadData2 = Register[Readreg2];
 

integer k;
initial
begin
for ( k =0;k<16;k=k+1) 
Register[k]=k; 
end 
always @(negedge clk)
begin
if (op==2'b10) // add 
WriteData = ReadData1 + ReadData2;  
else if (op==2'b11) // sub
WriteData = ReadData1 - ReadData2;  
 
else if ((op==2'b01&&type==2'b00) || (op==2'b01&&type==2'b11) ) // lw from memory , lw from IO device 
WriteData =fake_WriteData; 

else
WriteData = 32'bx;
end  
always @(posedge clk)
begin
if ((op==2'b00&&type==2'b00) || (op==2'b00&&type==2'b11)) // sw to memory , sw to IO device
begin
fake_read =Register[source]; 
end 
end
always @(negedge clk)
begin
if(RegWrite ==1)
begin
if (op==2'b10 || op == 2'b11)
 Register[Writereg] = WriteData; 
else if ((op==2'b01&&type==2'b00) || (op==2'b01&&type==2'b11) ) // lw from memory , lw from IO device 
 Register[destination] = WriteData; 
end

 
end

initial
begin
#6 // because it takes 6 time units to reach first posedge 
// $monitor("op is %d,rreg1 is %d, rreg2 is %d,wreg is %d,regw is %d,RD1 is %d,RD2 is %d,WD is %d ,clk is %b",op,Readreg1,Readreg2,Writereg,RegWrite,ReadData1,ReadData2,WriteData,clk);
$monitor("fakeread is %d,data is %d,clk is %b",fake_read,data,clk); 
end

endmodule

module processor(grant,IOWrite1,IOWrite2,memwrite,instruction,clock,databus,IOIP1,IOIP2); // I/O1 interrupt , I/O2 interrupt 
input [25:0] instruction ;
wire [3:0] Readreg1,Readreg2,Writereg;
wire [31:0] ReadData1, ReadData2; 
wire[1:0] op,type; 
wire [7:0] source,destination;
wire [5:0] count;
wire RegWrite; 
input clock,IOIP1,IOIP2; 
wire clk;
inout [31:0] databus;
wire[31:0] data; 
output reg grant,IOWrite1,IOWrite2,memwrite; 

assign Readreg1 = instruction[23:20];
assign Readreg2 = instruction[19:16];
assign Writereg = instruction[15:12];
assign op = instruction [25:24];
assign RegWrite = (op == 1 || op == 2 || op == 3)? 1 : 0;
assign clk = clock;
assign type = instruction [23:22];
assign source = instruction [21:14];
assign destination = instruction [13:6];
assign count = instruction [5:0];


assign databus = ((instruction [25:24] !=2'b01)&&(instruction [25:24] !=2'b10)&&(instruction [25:24]!=2'b11))? data : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;  //bigdata is in output mode 
assign data = ((instruction [25:24]!=2'b01)&&(instruction [25:24] !=2'b10)&&(instruction [25:24] !=2'b11))? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:databus; //bigdata is in input mode

RegisterFile RF1(ReadData1, ReadData2, Readreg1, Readreg2, Writereg,source,destination, RegWrite,op,type,clk,data);

initial
begin
if (op != 2'b10 && op != 2'b11) //modified by me , if it's add or sub we won't give grant to DMA
grant = 1;
else
grant = 0;
end

always @ (posedge clk) // generating I/Owrite1 , I/Owrite2 , memwrite for all instructions 
begin
if (op == 2'b00 && type ==2'b11)
begin
if (destination <= 223 && destination >= 192) // from Regfile to I/O1
begin
IOWrite1 = 1;
IOWrite2 = 1'bx;
memwrite = 1'bx;
end
else if (destination <= 255 && destination >= 224) // from Regfile to I/O2
begin
IOWrite1 = 1'bx;
IOWrite2 = 1;
memwrite = 1'bx;
end
end

else if (op == 2'b01 && type ==2'b01)
begin
if (destination <= 223 && destination >= 192) // from memory to I/O1
begin
IOWrite1 = 1;
IOWrite2 = 1'bx;
memwrite = 0;
end
else if (destination <= 255 && destination >= 224) // from memory to I/O2
begin
IOWrite1 = 1'bx;
IOWrite2 = 1;
memwrite = 0;
end
end

else if (op == 2'b00 && type ==2'b01)
begin
if (source <= 223 && source >= 192) // from I/O1 to memory 
begin
IOWrite1 = 0;
IOWrite2 = 1'bx;
memwrite = 1;
end
else if (source <= 255 && source >= 224) // from I/O2 to memory 
begin
IOWrite1 = 1'bx;
IOWrite2 = 0;
memwrite = 1;
end
end

else if (op == 2'b01 && type ==2'b11)
begin
if (source <= 223 && source >= 192) // from I/O1 to Regfile
begin
IOWrite1 = 0;
IOWrite2 = 1'bx;
memwrite = 1'bx;
end
else if (source <= 255 && source >= 224) // from I/O2 to Regfile
begin
IOWrite1 = 1'bx;
IOWrite2 = 0;
memwrite = 1'bx;
end
end

else if (op == 2'b00 && type == 2'b00) // from Regfile to memory
begin
IOWrite1 = 1'bx;
IOWrite2 = 1'bx;
memwrite = 1;
end

else if (op == 2'b01 && type == 2'b00) // from memory to Regfile 
begin
IOWrite1 = 1'bx;
IOWrite2 = 1'bx;
memwrite = 0;
end

else if ((op == 2'b00 && type == 2'b10) || (op == 2'b01 && type == 2'b10) ) // from memory to memory
begin    
IOWrite1 = 1'bx;
IOWrite2 = 1'bx;
memwrite = 0; // read from any place in memory at posedge
#3
IOWrite1 = 1'bx;
IOWrite2 = 1'bx;
memwrite = 1; // write in  any place in memory at negedge of same cycle 
end

else 
begin
IOWrite1 = 1'bx;
IOWrite2 = 1'bx;
memwrite = 1'bx;
end

end
/*
initial
begin
#6 // because it takes 6 time units to reach first posedge 
$monitor("op is %d,type is %d, source is %d,destination is %d,I/OW1 is %d,I/OW2 is %d,memwrite is %d,clk is %b",op,type,source,destination,IOWrite1,IOWrite2,memwrite,clk);
end
*/
endmodule


module processor_tb(); 
wire[31:0]databus;

reg [25:0]instruction;
clkgenerator c1(clock);
wire grant,IOWrite1,IOWrite2,memwrite,IOIP1,IOIP2;
reg [31:0] datamemory[0:8191];
reg [25:0] instructionmemory[0:8191];
reg [31:0]datain;
integer r,p;
initial
begin
$readmemb("E:\Folder2/datafile.txt",datamemory);
$readmemb("E:\FOLDER/instructionfile.txt",instructionmemory);
end
initial
begin
for(r=0;r<8191;r=r+1)
begin 
#6
datain=datamemory[r]; 
end
end

initial
begin
for(p=0;p<8191;p=p+1)
begin
#6
instruction=instructionmemory[p]; 
end

end

processor p1(grant,IOWrite1,IOWrite2,memwrite,instruction,clock,databus,IOIP1,IOIP2);
assign databus = ((instruction [25:24]!=2'b01)&&(instruction [25:24] !=2'b10)&&(instruction [25:24] !=2'b11))? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : datain;
initial 
begin
 

/*
#6
instruction = 26'b00_00_01100110_00001110_000000;
#6
instruction = 26'b00_01_11011101_10100101_000000;
#6
instruction = 26'b00_10_11001100_00110011_000000;
#6
instruction = 26'b00_11_10101010_11001000_000000;
#6
instruction = 26'b01_00_11100011_00011000_000000;
#6
instruction = 26'b01_01_11110000_11110101_000000;
#6
instruction = 26'b01_10_00110110_10001010_000000;
#6
instruction = 26'b01_11_11111010_11000011_000000;

#6
instruction = 26'b10_00_11011011_00100100_000000;
#6
instruction = 26'b10_01_10100101_11111111_000000; 
#6
instruction = 26'b10_01_11000110_11001100_000000;   
#6
instruction = 26'b10_11_01101101_01111100_000000;
#6
instruction = 26'b11_00_01111110_00000100_000000;
#6
instruction = 26'b11_01_01111101_01101111_000000;
#6
instruction = 26'b11_10_11111110_01111111_000000;
#6
instruction = 26'b11_11_10101111_00111111_000000;

*/

end
endmodule
