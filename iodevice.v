module IODevice (Ack,GPIO,Data,IOWrite,clk,index);
input IOWrite; 
input Ack;
input wire [8:0] index;
wire CS = index[8];
integer bufferind;
output reg GPIO;
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
assign Data = (IOWrite)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : OData ; //if read Data
//assign GPIO = GP;


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
$readmemb("interrupt.mem", interrupt);
if (interrupt[0])
begin 
assign GPIO = 1;
i=0;
//$monitor("%b" ,GPIO);
//read buffermemory 
$readmemh("buffermemory.mem", BufferReg);
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
if(IOWrite == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg[bufferind] <= Data ;
end
if(IOWrite == 0) //write
begin 
//to store in buffer
//GP <= 1;
 OData <= BufferReg[bufferind] ;
end
end
if (Ack ==1)
begin
if(IOWrite == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg[count] <= Data ;
 count <= count +1 ;

end

if (!IOWrite) begin // read

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
$writememh("buffermemory.mem", BufferReg);
 count = count-1;
if (count==32'h00000000)
begin
assign GPIO = 0;
interrupt[0]=0;
$writememb("interrupt.mem", interrupt);
end
end

// GP <= 0;
/*count=0;
GPIO =0;
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
module newtest();

wire [31:0] Data;
reg Ack;
reg IOWrite;
wire GPIO;
reg inData ;
reg clk;
reg [8:0] index;

initial clk=1;

always #5 clk=~clk;
always @(posedge clk) 
begin
assign Ack=0;
assign IOWrite =0;
assign index = 448;
$monitor("%b %d %d ",index, IOWrite ,Data);
end
IODevice dev(Ack,GPIO,Data,IOWrite,clk,index);




endmodule 
module testbench();

wire [31:0] Data;
reg IOWrite;
wire GPIO;
reg inData ;

assign Data = (IOWrite)? inData :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

initial 
begin
#6
IOWrite = 1'b1;
inData =32'b1 ;
$monitor("%d %d %d  ",GPIO, IOWrite ,Data );
#6
IOWrite = 1'b1;
inData = 32'b0 ;
$monitor("%d %d %d ",GPIO, IOWrite ,Data);
#6
IOWrite = 1'b1;
inData = 32'b1;
$monitor("%d %d %d  ",GPIO, IOWrite ,Data );

#6
IOWrite = 1'b1;
inData = 32'b0;
$monitor("%d %d %d  ",GPIO, IOWrite ,Data );

#6
IOWrite = 1'b1;
inData = 32'b1;
$monitor("%d %d %d  ",GPIO, IOWrite ,Data );



#6
IOWrite = 1'b0;
$monitor("%d %d %d  ",GPIO, IOWrite ,Data );
#6
IOWrite = 1'b1;
inData = 32'b1;
$monitor("%d %d %d  ",GPIO, IOWrite ,Data );


/*
#6
IOWrite = 1'b0;
$monitor("%d %d %d  ",GPIO, IOWrite ,Data );
#6
IOWrite = 1'b0;
$monitor("%d %d %d  ",GPIO, IOWrite ,Data );
*/
end

IODevice device(GPIO,Data,IOWrite,clock );
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

module interrupt_test(n,GPIO, Data ,inData , IOWrite);
input IOWrite; 
output reg GPIO;
output reg [31:0] Data;

input [31:0] inData ;
input n ;
reg [31:0] BufferReg [0:30];
reg interrupt [0:1];
always 
begin 
#6
$readmemb("interrupt.mem", interrupt);
if (interrupt[0])
begin 
assign GPIO = 1;
$monitor("%b" ,GPIO);
$readmemh("memory.mem", BufferReg);
end 
end 
endmodule 