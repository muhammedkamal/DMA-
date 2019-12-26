module IODevice2 (Ack2,GPIO2,databus,IOWrite2,clk,index);
input IOWrite2; 
input Ack2;
input wire [8:0] index;
wire IO2CS = index[8]; 
wire [7:0] IO2_addr = index[7:0];
output reg GPIO2;
//reg GP ;
inout[31:0] databus ;
reg [31:0] Odatabus;
integer i,k,startcount ;
input clk ;
//integer f;
reg interrupt2 [0:1];
wire [31:0] anything;
//D:\dma/
//buffer register to store  

reg [31:0] BufferReg2 [0:31]; 
reg [7:0] StatusReg;
integer count;

assign databus = (!IOWrite2)?Odatabus:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; //if read databusassign memoryReg[191]=memoryReg[191];
assign anything = (!IOWrite2)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:databus;

/*
//assign databus = (IOWrite2)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : Odatabus ; //if read databus
//assign databus = (IOWrite2===1'bx) ?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:databus;
assign databus = (IOWrite2==0) ?Odatabus:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; // databus is output//&& IOWrite2!=1'bx)
assign anything = (IOWrite2==1 )?databus:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; //databus is input
//assign databus =(IOWrite2==1'bx)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:anything;
*/
//assign GPIO2 = GP;


initial 
begin 

StatusReg = 0;
count = 0;
i=0;
//f = $fopen("D:\Folder2/databusfile.txt","w");

for(k=0;k<32;k=k+1)
begin 
 BufferReg2[k]=k;
end
end 

always@(clk)
begin

// checking interrupt2 by gui 
//count=0;
$readmemb("D:\dma/interrupt2.mem", interrupt2);
if (interrupt2[0]==0)
begin
assign GPIO2 =0;

end
else if (interrupt2[0]==1)
begin 
assign GPIO2 = 1;
for(k=0;k<31;k=k+1)
begin 
 BufferReg2[k]=0;

end
$readmemh("D:\dma/buffermemory2.mem", BufferReg2);
//$writememh("D:\dma/buffermemory2.mem", BufferReg2);
//count=0;
//$monitor("%b" ,GPIO2);
//read buffermemory 
/*$readmemh("D:\dma/buffermemory2.mem", BufferReg2);
//check number of words at memory 
for(i=0;i<32;i=i+1)
begin
 if(BufferReg2[i])
begin
	count = count+1;
end
/*
else if (!BufferReg2[i])
begin
	count =count;
end
end*/
end 
end
always @(Ack2 or clk or IO2CS or IOWrite2)
begin
//assign Odatabus = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
 // since index represents net address so we must delete '-224'
if (IO2CS ==1)
begin
if(IOWrite2 == 1) //write
begin 
//@(negedge clk);
//to store in buffer
//GP <= 1;
 BufferReg2[IO2_addr] = databus ;
end
else if(IOWrite2 == 0) //write
begin 
//to store in buffer
//GP <= 1;
 Odatabus <= BufferReg2[IO2_addr] ;
end

else if(IOWrite2 == 1'bx)
begin
Odatabus <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end
end
else if (Ack2 ==0)
Odatabus = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
else if (Ack2 ==1)
begin
/*if(IOWrite2 == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg2[count] <= databus ;
 count <= count +1 ;

end
*/
i=0;
//read buffermemory 
$readmemh("D:\dma/buffermemory2.mem", BufferReg2);
//check number of words at memory 
for(i=0;i<32;i=i+1)
begin
 if(BufferReg2[i])
begin
	count = count+1;
end
end
if (!IOWrite2) begin // read

 if(count>0)
 begin
i=0;
startcount=count+1;
// $fwrite(f,"%b\n",BufferReg2[count-1]);
for(i=0;i<startcount;i=i+1)
begin
@(negedge clk);
 if (Ack2 ==0)
Odatabus = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
else if(count>0)
begin
 Odatabus = BufferReg2[i] ;
 BufferReg2[i] = 0 ;
$writememh("D:\dma/buffermemory2.mem", BufferReg2);
 count = count-1;
end
else if (count==32'h00000000)
begin
assign GPIO2 = 0;
interrupt2[0]=0;
$writememb("D:\dma/interrupt2.mem", interrupt2);
end
end

// GP <= 0;
/*count=0;
GPIO2 =0;
interrupt2[0]=0;
$writememb("D:\dma/interrupt2.mem", interrupt2);*/
 end
else begin
 Odatabus <= BufferReg2[0] ;
end

end

end

/*else if (IOWrite2 == 1'bx)
Odatabus <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;*/
else
Odatabus <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end


endmodule
//test for intruptting and count 
module newtest2();

//wire [31:0] databus;
reg Ack2;
reg IOWrite2;
wire GPIO2;
reg clk;
reg [8:0] index;
//reg [31:0]indata ;
wire[31:0]databusbus;
reg [31:0] databusmemory[0:8191];
reg [31:0]databusin;
integer r;
//assign databus = (IOWrite2)? indata :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
initial clk=1;

always #5 clk=~clk;



initial
begin
$readmemb("D:\dma/databusfile.txt",databusmemory);
end
initial
begin
for(r=0;r<8191;r=r+1)
begin 
#10
databusin=databusmemory[r];
end
end

assign databusbus = (!IOWrite2)? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : databusin;
/*always @(posedge clk) 
begin
assign Ack2=0;
assign IOWrite2 =0;
assign index = 448;
$monitor("%b %d %d ",index, IOWrite2 ,databus);
end*/
IODevice2 dev(Ack2,GPIO2,databusbus,IOWrite2,clk,index);
initial
begin
assign Ack2=0;
assign IOWrite2 =0;
assign index = 285;//29
$monitor("%b %d %d ",index, IOWrite2 ,databusbus);
#30
assign Ack2=0;
assign IOWrite2 =0;
assign index = 266;//10
$monitor("%b %d %d ",index, IOWrite2 ,databusbus);
#30
assign Ack2=0;
assign IOWrite2 =0;
assign index = 263;//7
//assign indata =5;
$monitor("%b %d %d ",index, IOWrite2 ,databusbus);
#30
assign Ack2=0;
assign IOWrite2 =1;
assign index =263 ;//buff7
//assign indata =5;
$monitor("%b %d %d ",index, IOWrite2 ,databusbus);
#30
assign Ack2=0;
assign IOWrite2 =1'b0;
assign index = 0;
//assign indata =5;
$monitor("%b %d %d ",index, IOWrite2 ,databusbus);
#30
assign Ack2=0;
assign IOWrite2 =1;
assign index = 275;//19
//assign indata =5;
$monitor("%b %d %d ",index, IOWrite2 ,databusbus);
#30
assign Ack2=0;
assign IOWrite2 =0;
assign index = 285;
//assign indata =5;
$monitor("%b %d %d ",index, IOWrite2 ,databusbus);
end




endmodule 
module testbench();

wire [31:0] databus;
reg IOWrite2;
wire GPIO2;
reg indata ;

assign databus = (!IOWrite2)? indata :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

initial 
begin
#6
IOWrite2 = 1'b1;
indata =32'b1 ;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,databus );
#6
IOWrite2 = 1'b1;
indata = 32'b0 ;
$monitor("%d %d %d ",GPIO2, IOWrite2 ,databus);
#6
IOWrite2 = 1'b1;
indata = 32'b1;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,databus );

#6
IOWrite2 = 1'b1;
indata = 32'b0;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,databus );

#6
IOWrite2 = 1'b1;
indata = 32'b1;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,databus );



#6
IOWrite2 = 1'b0;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,databus );
#6
IOWrite2 = 1'b1;
indata = 32'b1;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,databus );


/*
#6
IOWrite2 = 1'b0;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,databus );
#6
IOWrite2 = 1'b0;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,databus );
*/
end

//IODevice2 device(GPIO2,databus,IOWrite2,clock );
clkgenertor c1(clock);


endmodule  

module clkgenertor(clock);
output reg clock;
initial 
clock =1 ;
always
begin
#3 
clock = ~clock;
end 
endmodule 

module interrupt2_test(n,GPIO2, databus ,indata , IOWrite2);
input IOWrite2; 
output reg GPIO2;
output reg [31:0] databus;

input [31:0] indata ;
input n ;
reg [31:0] BufferReg2 [0:30];
reg interrupt2 [0:1];
always 
begin 
#6
$readmemb("D:\dma/interrupt2.mem", interrupt2);
if (interrupt2[0])
begin 
assign GPIO2 = 1;
$monitor("%b" ,GPIO2);
$readmemh("D:\dma/memory1.mem", BufferReg2);
end 
end 
endmodule 
