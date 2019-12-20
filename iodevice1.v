module IODevice1 (Ack1,GPIO1,Data,IOWrite1,clk,index);
input IOWrite1; 
input Ack1;
input wire [8:0] index;
wire CS_1 ;
assign CS_1= index[8]; 
integer bufferind_1;
output reg GPIO1;
//reg GP ;
inout[31:0] Data ;
reg [31:0] OData;
integer i,k,startcount ;
input clk ;
//integer f;
reg interrupt1 [0:1];
wire [31:0] anything;

//buffer register to store  

reg [31:0] BufferReg1 [0:30];
reg [7:0] StatusReg;
integer count;
assign Data = (IOWrite1)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : OData ; //if read Data
//assign Data = (IOWrite1===1'bx) ?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:Data;
//assign Data = (IOWrite1==0) ?OData:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; // Data is output//&& IOWrite1!=1'bx)
assign anything = (IOWrite1)?Data:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; //Data is input
//assign Data =(IOWrite1==1'bx)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:anything;

//assign GPIO1 = GP;


initial 
begin 

StatusReg = 0;
count = 0;
i=0;
//f = $fopen("E:\Folder2/datafile.txt","w");

for(k=0;k<31;k=k+1)
begin 
 BufferReg1[k]=k;
end
end 

always@(clk)
begin


// checking interrupt1 by gui 
//count=0;
$readmemb("interrupt1.mem", interrupt1);
if (interrupt1[0]==0)
begin
assign GPIO1 =0;

end
else if (interrupt1[0]==1)
begin 
assign GPIO1 = 1;
for(k=0;k<31;k=k+1)
begin 
 BufferReg1[k]=0;

end
$readmemh("buffermemory1.mem", BufferReg1);
//i=0;
//read buffermemory 
//$readmemh("buffermemory1.mem", BufferReg1);
//check number of words at memory 
/*for(i=0;i<32;i=i+1)
begin
 if(BufferReg1[i])
begin
	count = count+1;
end
end*/
//$writememh("D:\dma/buffermemory1.mem", BufferReg1);
//count=0;
//$monitor("%b" ,GPIO1);
//read buffermemory 
/*$readmemh("D:\dma/buffermemory1.mem", BufferReg1);
//check number of words at memory 
for(i=0;i<32;i=i+1)
begin
 if(BufferReg1[i])
begin
	count = count+1;
end
/*
else if (!BufferReg1[i])
begin
	count =count;
end
end*/
end 
end
always @(clk)
begin
//assign OData = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
bufferind_1 = index[7:0]; // since index represents net address so we must delete '-224'
if (CS_1 ==1)
begin
if(IOWrite1 == 1) //write
begin 
//@(negedge clk);
//to store in buffer
//GP <= 1;
 BufferReg1[bufferind_1] = Data ;
end
else if(IOWrite1 == 0) //write
begin 
//to store in buffer
//GP <= 1;
 OData = BufferReg1[bufferind_1] ;
end
else if(IOWrite1 == 1'bx)
begin
OData = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end
end

else if (Ack1 ==1)
begin
/*if(IOWrite1 == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg1[count] <= Data ;
 count <= count +1 ;

end
i=0;
//read buffermemory 
//$readmemh("buffermemory1.mem", BufferReg1);
//check number of words at memory */
for(i=0;i<32;i=i+1)
begin
 if(BufferReg1[i])
begin
	count = count+1;
end
end
if (!IOWrite1) begin // read

 if(count>0)
 begin
i=0;
startcount=count+1;
// $fwrite(f,"%b\n",BufferReg1[count-1]);
for(i=0;i<startcount;i=i+1)
begin
@(negedge clk);
if(count>0)
begin
 OData = BufferReg1[i] ;
 BufferReg1[i] = 0 ;
$writememh("buffermemory1.mem", BufferReg1);
 count = count-1;
end
if (count==32'h00000000)
begin
assign GPIO1 = 0;
interrupt1[0]=0;
$writememb("interrupt1.mem", interrupt1);
end
end

// GP <= 0;
/*count=0;
GPIO1 =0;
interrupt1[0]=0;
$writememb("interrupt1.mem", interrupt1);*/
 end
/*else begin
 OData <= BufferReg1[0] ;
end*/

end

end

/*else if (IOWrite1 == 1'bx)
OData <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;*/
else
OData = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end


endmodule
//test for intruptting and count 
module newtest1();

//wire [31:0] Data;
reg Ack1;
reg IOWrite1;
wire GPIO1;
reg clk;
reg [8:0] index;
//reg [31:0]inData ;
wire[31:0]databus;
reg [31:0] datamemory[0:8191];
reg [31:0]datain;
integer r;
//assign Data = (IOWrite1)? inData :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
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

assign databus = (!IOWrite1)? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : datain;
/*always @(posedge clk) 
begin
assign Ack1=0;
assign IOWrite1 =0;
assign index = 448;
$monitor("%b %d %d ",index, IOWrite1 ,Data);
end*/
IODevice1 dev(Ack1,GPIO1,databus,IOWrite1,clk,index);
initial
begin
assign Ack1=0;
assign IOWrite1 =0;
assign index = 264;//8
$monitor("%b %d %d ",index, IOWrite1 ,databus);
#30
assign Ack1=0;
assign IOWrite1 =0;
assign index = 266;//10
$monitor("%b %d %d ",index, IOWrite1 ,databus);
#30
assign Ack1=0;
assign IOWrite1 =0;
assign index = 263;//7
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite1 ,databus);
#30
assign Ack1=0;
assign IOWrite1 =1;
assign index =263 ;//buff7
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite1 ,databus);
#30
assign Ack1=0;
assign IOWrite1 =1'b0;
assign index = 0;//0
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite1 ,databus);
#30
assign Ack1=0;
assign IOWrite1 =1;
assign index = 0;//19
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite1 ,databus);
#30
assign Ack1=1;
assign IOWrite1 =0;
assign index = 0;
//assign inData =5;
$monitor("%b %d %d ",index, IOWrite1 ,databus);
#49
assign Ack1=0;
end




endmodule 
module testbench();

wire [31:0] Data;
reg IOWrite1;
wire GPIO1;
reg inData ;

assign Data = (!IOWrite1)? inData :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

initial 
begin
#6
IOWrite1 = 1'b1;
inData =32'b1 ;
$monitor("%d %d %d  ",GPIO1, IOWrite1 ,Data );
#6
IOWrite1 = 1'b1;
inData = 32'b0 ;
$monitor("%d %d %d ",GPIO1, IOWrite1 ,Data);
#6
IOWrite1 = 1'b1;
inData = 32'b1;
$monitor("%d %d %d  ",GPIO1, IOWrite1 ,Data );

#6
IOWrite1 = 1'b1;
inData = 32'b0;
$monitor("%d %d %d  ",GPIO1, IOWrite1 ,Data );

#6
IOWrite1 = 1'b1;
inData = 32'b1;
$monitor("%d %d %d  ",GPIO1, IOWrite1 ,Data );



#6
IOWrite1 = 1'b0;
$monitor("%d %d %d  ",GPIO1, IOWrite1 ,Data );
#6
IOWrite1 = 1'b1;
inData = 32'b1;
$monitor("%d %d %d  ",GPIO1, IOWrite1 ,Data );


/*
#6
IOWrite1 = 1'b0;
$monitor("%d %d %d  ",GPIO1, IOWrite1 ,Data );
#6
IOWrite1 = 1'b0;
$monitor("%d %d %d  ",GPIO1, IOWrite1 ,Data );
*/
end

IODevice2 device(GPIO1,Data,IOWrite1,clock );
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

module interrupt1_test(n,GPIO1, Data ,inData , IOWrite1);
input IOWrite1; 
output reg GPIO1;
output reg [31:0] Data;

input [31:0] inData ;
input n ;
reg [31:0] BufferReg1 [0:30];
reg interrupt1 [0:1];
always 
begin 
#6
$readmemb("D:\dma/interrupt1.mem", interrupt1);
if (interrupt1[0])
begin 
assign GPIO1 = 1;
$monitor("%b" ,GPIO1);
$readmemh("memory1.mem", BufferReg1);
end 
end 
endmodule 