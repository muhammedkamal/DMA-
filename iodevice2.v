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
reg interrupt [0:1];

//buffer register to store  

reg [31:0] BufferReg [0:30];
reg [7:0] StatusReg;
integer count;
assign Data = (IOWrite2)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : OData ; //if read Data
//assign GPIO2 = GP;


initial 
begin 

StatusReg = 0;
count = 0;
i=0;
//f = $fopen("E:\Folder2/datafile.txt","w");

for(k=0;k<31;k=k+1)
begin 
 BufferReg[k]=0;
end
end 

always@(clk)
begin
// checking interrupt by gui 
count=0;
$readmemb("interrupt2.mem", interrupt);
if (interrupt[0])
begin 
assign GPIO2 = 1;
i=0;
//$monitor("%b" ,GPIO2);
//read buffermemory 
$readmemh("buffermemory2.mem", BufferReg);
//check number of words at memory 
for(i=0;i<31;i=i+1)
begin
 if(BufferReg[i])
begin
	count = count+1;
end
/*
else if (!BufferReg[i])
begin
	count =count;
end*/
end
end 

bufferind = index[7:0]-192;
if (CS ==1)
begin
if(IOWrite2 == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg[bufferind] <= Data ;
end
if(IOWrite2 == 0) //write
begin 
//to store in buffer
//GP <= 1;
 OData <= BufferReg[bufferind] ;
end
end
if (Ack2 ==1)
begin
if(IOWrite2 == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg[count] <= Data ;
 count <= count +1 ;

end

if (!IOWrite2) begin // read

 if(count>0)
 begin
i=0;
startcount=count+1;
// $fwrite(f,"%b\n",BufferReg[count-1]);
for(i=0;i<startcount;i=i+1)
begin
@(posedge clk);

 OData = BufferReg[i] ;
 BufferReg[i] = 0 ;
$writememh("buffermemory2.mem", BufferReg);
 count = count-1;
if (count==32'h00000000)
begin
assign GPIO2 = 0;
interrupt[0]=0;
$writememb("interrupt2.mem", interrupt);
end
end

// GP <= 0;
/*count=0;
GPIO2 =0;
interrupt[0]=0;
$writememb("interrupt.mem", interrupt);*/
 end
else begin
 OData <= BufferReg[0] ;
end

end

end
end

endmodule
//test for intruptting and count 
module newtest2();

wire [31:0] Data;
reg Ack2;
reg IOWrite2;
wire GPIO2;
reg clk;
reg [8:0] index;
reg [31:0]inData ;

assign Data = (IOWrite2)? inData :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
initial clk=1;

always #5 clk=~clk;
/*always @(posedge clk) 
begin
assign Ack2=0;
assign IOWrite2 =0;
assign index = 448;
$monitor("%b %d %d ",index, IOWrite2 ,Data);
end*/
IODevice2 dev(Ack2,GPIO2,Data,IOWrite2,clk,index);
initial
begin
assign Ack2=0;
assign IOWrite2 =0;
assign index = 448;
$monitor("%b %d %d ",index, IOWrite2 ,Data);
#8
assign Ack2=1;
assign IOWrite2 =0;
assign index = 192;
$monitor("%b %d %d ",index, IOWrite2 ,Data);
#8
assign Ack2=1;
assign IOWrite2 =1;
assign index = 192;
assign inData =5;
$monitor("%b %d %d ",index, IOWrite2 ,Data);
end




endmodule 
module testbench();

wire [31:0] Data;
reg IOWrite2;
wire GPIO2;
reg inData ;

assign Data = (IOWrite2)? inData :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

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

module interrupt_test(n,GPIO2, Data ,inData , IOWrite2);
input IOWrite2; 
output reg GPIO2;
output reg [31:0] Data;

input [31:0] inData ;
input n ;
reg [31:0] BufferReg [0:30];
reg interrupt [0:1];
always 
begin 
#6
$readmemb("interrupt2.mem", interrupt);
if (interrupt[0])
begin 
assign GPIO2 = 1;
$monitor("%b" ,GPIO2);
$readmemh("memory1.mem", BufferReg);
end 
end 
endmodule 
