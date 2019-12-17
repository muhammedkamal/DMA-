module IODevice (Ack1,GPIO1,Data,IOWrite1,clk,index);
input IOWrite1; 
input Ack1;
input wire [8:0] index;
wire CS = index[8];
integer bufferind;
output reg GPIO1;
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
assign Data = (IOWrite1)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : OData ; //if read Data
//assign GPIO1 = GP;


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
$readmemb("interrupt1.mem", interrupt);
if (interrupt[0])
begin 
assign GPIO1 = 1;
i=0;
//$monitor("%b" ,GPIO1);
//read buffermemory 
$readmemh("buffermemory1.mem", BufferReg);
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
if(IOWrite1 == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg[bufferind] <= Data ;
end
if(IOWrite1 == 0) //write
begin 
//to store in buffer
//GP <= 1;
 OData <= BufferReg[bufferind] ;
end
end
if (Ack1 ==1)
begin
if(IOWrite1 == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg[count] <= Data ;
 count <= count +1 ;

end

if (!IOWrite1) begin // read

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
$writememh("buffermemory1.mem", BufferReg);
 count = count-1;
if (count==32'h00000000)
begin
assign GPIO1 = 0;
interrupt[0]=0;
$writememb("interrupt1.mem", interrupt);
end
end

// GP <= 0;
/*count=0;
GPIO1 =0;
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
reg Ack1;
reg IOWrite1;
wire GPIO1;
reg inData ;
reg clk;
reg [8:0] index;

initial clk=1;

always #5 clk=~clk;
always @(posedge clk) 
begin
assign Ack1=0;
assign IOWrite1 =0;
assign index = 448;
$monitor("%b %d %d ",index, IOWrite1 ,Data);
end
IODevice dev(Ack1,GPIO1,Data,IOWrite1,clk,index);




endmodule 
module testbench();

wire [31:0] Data;
reg IOWrite1;
wire GPIO1;
reg inData ;

assign Data = (IOWrite1)? inData :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

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

IODevice device(GPIO1,Data,IOWrite1,clock );
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

module interrupt_test(n,GPIO1, Data ,inData , IOWrite1);
input IOWrite1; 
output reg GPIO1;
output reg [31:0] Data;

input [31:0] inData ;
input n ;
reg [31:0] BufferReg [0:30];
reg interrupt [0:1];
always 
begin 
#6
$readmemb("interrupt1.mem", interrupt);
if (interrupt[0])
begin 
assign GPIO1 = 1;
$monitor("%b" ,GPIO1);
$readmemh("memory1.mem", BufferReg);
end 
end 
endmodule 