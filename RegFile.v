module RegisterFile(ReadData1, ReadData2, Readreg1,Readreg2, Writereg,next_source,destination,RegWrite,op,type,clk,data); 

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
input [7:0] next_source,destination;
output [31:0] ReadData1, ReadData2;
reg [31:0] Register [0:15];
integer i;

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
always @(posedge clk or op)
begin
if (op==2'b10) // add 
WriteData = ReadData1 + ReadData2;  
else if (op==2'b11) // sub
WriteData = ReadData1 - ReadData2; 
 else if ((op==2'b01&&type==2'b00) || (op==2'b01&&type==2'b11) ) // lw from memory , lw from IO device 
#1
WriteData =fake_WriteData; 


else
WriteData = 32'bz;
end  
/*
always @(negedge clk)
begin
 if ((op==2'b01&&type==2'b00) || (op==2'b01&&type==2'b11) ) // lw from memory , lw from IO device 
begin
WriteData =fake_WriteData; 
Register[destination] = WriteData ;
end
else
WriteData = WriteData;

end 
*/

always @(posedge clk) 
begin

if ((op==2'b00&&type==2'b00) || (op==2'b00&&type==2'b11)) // sw to memory , sw to IO device
begin
fake_read =Register[next_source];
#10
fake_read = 32'bz;
end 
else
fake_read = 32'bz;
end
always @(posedge clk or op or type)
begin


if(RegWrite ==1)
begin
if (op==2'b10 || op == 2'b11)
 Register[Writereg] = WriteData; 
else if ((op==2'b01&&type==2'b00) || (op==2'b01&&type==2'b11) ) // lw from memory , lw from IO device 
#2
Register[destination] = WriteData  ; // try data


end


 
end 
/*
initial
$monitor("next_source is %d,op is %b,type is %b,destination is %d,clk is %b",next_source,op,type,destination,clk);
*/

/*
initial
begin
#10 // because it takes 6 time units to reach first posedge  
// $monitor("op is %d,rreg1 is %d, rreg2 is %d,wreg is %d,regw is %d,RD1 is %d,RD2 is %d,WD is %d ,clk is %b",op,Readreg1,Readreg2,Writereg,RegWrite,ReadData1,ReadData2,WriteData,clk);
$monitor("fakeread is %d,data is %d,clk is %b",fake_read,data,clk); 
end
*/
endmodule


