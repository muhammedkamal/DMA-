module memory(memWR,databus,index,clk,firstempty);// remember memfull 
input wire [8:0]index ;
input memWR;
wire MemCS=index[8];
wire [7:0]addr =index[7:0];
inout [31:0] databus;
reg [31:0] Odatabus;
input clk;
reg [31:0] memoryReg [0:191];
integer k;
reg [7:0]i;
//output reg memfull;
output reg [7:0] firstempty; 
wire [31:0] anything;



assign databus = (!memWR)?Odatabus:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; //if read databusassign memoryReg[191]=memoryReg[191];
assign anything = (!memWR)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:databus; 
//assign databus = (!memWR)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:databus;


initial 
begin
memoryReg[191] =0;
k=0;
for(k=0;k<100;k=k+1)
begin 
 memoryReg[k]=k+1;
end
for(k=100;k<191;k=k+1) 
begin 
 memoryReg[k]=0;
end

end
/*always @(clk)
begin 
if(memoryReg[191]==32'd190)
begin 
memfull =1;
end  
else 
begin
memfull=0;
end
end*/
always @(clk or MemCS or memWR)
begin
i=190;
for (i=190;i>0;i=i-1)
begin
if(memoryReg[i]==32'h0000_0000)
begin
memoryReg[191]=i;
firstempty = i;
end
/*else if (memoryReg[i]!=32'h0000_0000)
begin
i=i+1;
end*/
end

if (MemCS)
begin
  if(memWR && addr!=191) 
  begin
   memoryReg[addr]  = databus; 
  end

  else if(!memWR)
  begin
  Odatabus = memoryReg[addr];
  end
$writememb("D:\dma/memory.mem", memoryReg); 
end

else
Odatabus = 32'hzzzzzzzz;

end

endmodule 

module testmemory();
reg memWR ;
reg MemCS;
wire [31:0] databus;
reg [31:0]indata;
reg [8:0]index ;
wire [7:0] firstempty ;
//wire [7:0] memoryReg[191];
assign databus = (!memWR)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:indata;
reg clk;
//wire [8:0] fake_index = 285;//29
//wire fake_MemCS =fake_index[8];

initial
begin
clk=0;
end 
always 
begin
#5 clk= ~clk; 
end

initial
begin
 memWR =0;
 index = 285;//29
indata =32'd9;
MemCS = index[8];
$monitor(" index is %b,memWR is %d,databus is %d, MemCS is %b",index, memWR ,databus,MemCS);
#30
 memWR =0;
 index = 266;//10
indata =32'd26 ;
MemCS = index[8];
$monitor(" index is %b,memWR is %d,databus is %d, MemCS is %b",index, memWR ,databus,MemCS);
#30
 memWR =0;
 index = 263;//7
indata =32'd99 ;
MemCS = index[8];
$monitor(" index is %b,memWR is %d,databus is %d, MemCS is %b",index, memWR ,databus,MemCS);
#30
 memWR =1;
 index =263 ;//buff7
indata =32'd149 ;
MemCS = index[8];
$monitor(" index is %b,memWR is %d,databus is %d, MemCS is %b",index, memWR ,databus,MemCS);
#30
 memWR =1'b0;
index = 0;
indata =32'd9 ;
MemCS = index[8];
$monitor(" index is %b,memWR is %d,databus is %d, MemCS is %b",index, memWR ,databus,MemCS);
#30
 memWR =1;
 index = 275;//19
indata =32'd48 ;
//assign inData =5;
MemCS = index[8];
$monitor(" index is %b,memWR is %d,databus is %d, MemCS is %b",index, memWR ,databus,MemCS);
#30
 memWR =0;
index = 285;
indata =32'd86 ;
//assign inData =5;
MemCS = index[8];
$monitor(" index is %b,memWR is %d,databus is %d, MemCS is %b",index, memWR ,databus,MemCS);
end


memory mem(memWR,databus,index,clk,firstempty);
//clkgenertor c1(clock); 


endmodule 
