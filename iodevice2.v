module IODevice2 (Ack2,GPIO2,Data,IOWrite2,clk,index);
input IOWrite2; 
input Ack2;
input wire [8:0] index;
wire CS = index[8]; 
integer bufferind;
output reg GPIO2;
//reg GP ;
inout[31:0] Data ;
reg [31:0] OData;
integer i,k,startcount ;
input clk ;
//integer f;
reg interrupt2 [0:1];
wire [31:0] anything;

//buffer register to store  

reg [31:0] BufferReg2 [0:30];
reg [7:0] StatusReg;
integer count;
//assign Data = (IOWrite2)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : OData ; //if read Data
//assign Data = (IOWrite2===1'bx) ?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:Data;
assign Data = (IOWrite2==0) ?OData:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; // Data is output//&& IOWrite2!=1'bx)
assign anything = (IOWrite2==1 )?Data:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; //Data is input
//assign Data =(IOWrite2==1'bx)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:anything;

//assign GPIO2 = GP;


initial 
begin 

StatusReg = 0;
count = 0;
i=0;
//f = $fopen("E:\Folder2/datafile.txt","w");

for(k=0;k<31;k=k+1)
begin 
 BufferReg2[k]=k;
end
end 

always@(clk)
begin

// checking interrupt2 by gui 
//count=0;
$readmemb("interrupt2.mem", interrupt2);
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
always @(clk)
begin
//assign OData = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
bufferind = index[7:0]; // since index represents net address so we must delete '-224'
if (CS ==1)
begin
if(IOWrite2 == 1) //write
begin 
//@(negedge clk);
//to store in buffer
//GP <= 1;
 BufferReg2[bufferind] = Data ;
end
else if(IOWrite2 == 0) //write
begin 
//to store in buffer
//GP <= 1;
 OData <= BufferReg2[bufferind] ;
end
else if(IOWrite2 == 1'bx)
begin
OData <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end
end

else if (Ack2 ==1)
begin
/*if(IOWrite2 == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg2[count] <= Data ;
 count <= count +1 ;

end
*/
i=0;
//read buffermemory 
$readmemh("buffermemory2.mem", BufferReg2);
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
@(posedge clk);
if(count>0)
begin
 OData = BufferReg2[i] ;
 BufferReg2[i] = 0 ;
$writememh("buffermemory2.mem", BufferReg2);
 count = count-1;
end
if (count==32'h00000000)
begin
assign GPIO2 = 0;
interrupt2[0]=0;
$writememb("interrupt2.mem", interrupt2);
end
end

// GP <= 0;
/*count=0;
GPIO2 =0;
interrupt2[0]=0;
$writememb("interrupt2.mem", interrupt2);*/
 end
else begin
 OData <= BufferReg2[0] ;
end

end

end

/*else if (IOWrite2 == 1'bx)
OData <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;*/
else
OData <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end


endmodule
//test for intruptting and count 
module newtest2();

//wire [31:0] Data;
reg Ack2;
reg IOWrite2;
wire GPIO2;
reg clk;
reg [8:0] index;
//reg [31:0]inData ;
wire[31:0]databus;
reg [31:0] datamemory[0:8191];
reg [31:0]datain;
integer r;
//assign Data = (IOWrite2)? inData :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
initial clk=1;

always #5 clk=~clk;



initial
begin
$readmemb("datafile.txt",datamemory);
end
initial
begin
for(r=0;r<8191;r=r+1)
begin 
#10
datain=datamemory[r];
end
end

assign databus = (!IOWrite2)? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : datain;
/*always @(posedge clk) 
begin
assign Ack2=0;
assign IOWrite2 =0;
assign index = 448;
$monitor("%b %d %d ",index, IOWrite2 ,Data);
end*/
IODevice2 dev(Ack2,GPIO2,databus,IOWrite2,clk,index);
initial
begin
assign Ack2=0;
assign IOWrite2 =0;
assign index = 285;//29
$monitor("%b %d %d ",index, IOWrite2 ,databus);
#30
assign Ack2=0;
assign IOWrite2 =0;
assign index = 266;//10
$monitor("%b %d %d ",index, IOWrite2 ,databus);
#30
assign Ack2=0;
assign IOWrite2 =0;
assign index = 263;//7
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite2 ,databus);
#30
assign Ack2=0;
assign IOWrite2 =1;
assign index =263 ;//buff7
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite2 ,databus);
#30
assign Ack2=0;
assign IOWrite2 =1'b0;
assign index = 0;
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite2 ,databus);
#30
assign Ack2=0;
assign IOWrite2 =1;
assign index = 275;//19
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite2 ,databus);
#30
assign Ack2=0;
assign IOWrite2 =0;
assign index = 285;
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite2 ,databus);
end




endmodule 
module testbench();

wire [31:0] Data;
reg IOWrite2;
wire GPIO2;
reg inData ;

assign Data = (!IOWrite2)? inData :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

initial 
begin
#6
IOWrite2 = 1'b1;
inData =32'b1 ;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,Data );
#6
IOWrite2 = 1'b1;
inData = 32'b0 ;
$monitor("%d %d %d ",GPIO2, IOWrite2 ,Data);
#6
IOWrite2 = 1'b1;
inData = 32'b1;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,Data );

#6
IOWrite2 = 1'b1;
inData = 32'b0;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,Data );

#6
IOWrite2 = 1'b1;
inData = 32'b1;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,Data );



#6
IOWrite2 = 1'b0;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,Data );
#6
IOWrite2 = 1'b1;
inData = 32'b1;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,Data );


/*
#6
IOWrite2 = 1'b0;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,Data );
#6
IOWrite2 = 1'b0;
$monitor("%d %d %d  ",GPIO2, IOWrite2 ,Data );
*/
end

IODevice2 device(GPIO2,Data,IOWrite2,clock );
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

module interrupt2_test(n,GPIO2, Data ,inData , IOWrite2);
input IOWrite2; 
output reg GPIO2;
output reg [31:0] Data;

input [31:0] inData ;
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
$readmemh("memory1.mem", BufferReg2);
end 
end 
endmodule 
