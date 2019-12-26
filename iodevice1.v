module IODevice1 (Ack1,GPIO1,databus,IOWrite1,clk,index);
input IOWrite1; 
input Ack1;
input wire [8:0] index;
wire IO1CS = index[8];
wire [7:0] IO1_addr = index[7:0];
output reg GPIO1;
//reg GP ;
inout[31:0] databus ;
reg [31:0] Odatabus;
integer i,k,startcount ;
input clk ;
//integer f;
reg interrupt1 [0:1];
wire [31:0] anything;

//buffer register to store  

reg [31:0] BufferReg1 [0:31];
reg [7:0] StatusReg;
integer count;

assign databus = (!IOWrite1)?Odatabus:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; //if read databusassign memoryReg[191]=memoryReg[191];
assign anything = (!IOWrite1)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:databus;
/*
assign databus = (IOWrite1)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : Odatabus ; //if read databus
//assign databus = (IOWrite1===1'bx) ?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:databus;
//assign databus = (IOWrite1==0) ?Odatabus:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; // databus is output//&& IOWrite1!=1'bx)
assign anything = (IOWrite1)?databus:32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz; //databus is input
//assign databus =(IOWrite1==1'bx)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:anything;
*/
//assign GPIO1 = GP;


initial 
begin 

StatusReg = 0;
count = 0;
i=0;
//f = $fopen("D:\Folder2/databusfile.txt","w");

for(k=0;k<32;k=k+1)
begin 
 BufferReg1[k]=k;
end
end 


integer file,counter;
always @(*)
begin
file = $fopen("C:\\Users\\fares\\Desktop\\year work\\DMA proj\\GUI\\IO1_status.txt");
	// $fwrite(file,"StatusReg    = %h\n",StatusReg);
	for(counter = 0; counter < 31; counter = counter + 1)
	    begin

		    $fwrite(file,"Buffer[%3d]	= %h\n",counter,BufferReg1[counter]);  
	    end

$fclose(file);$display("end");
end


always@(clk)
begin
// checking interrupt1 by gui 
//count=0;
$readmemb("C:\\Users\\fares\\Desktop\\year work\\DMA proj\\GUI\\interrupt1.txt", interrupt1);
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
$readmemh("C:\\Users\\fares\\Desktop\\year work\\DMA proj\\GUI\\buffermemory1.mem", BufferReg1);
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

always @(clk or IO1CS or IOWrite1)
begin
//assign Odatabus = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
 // since index represents net address so we must delete '-224'
if (IO1CS ==1)
begin
if(IOWrite1 == 1) //write
begin 
//@(negedge clk);
//to store in buffer
//GP <= 1;
 BufferReg1[IO1_addr] = databus ;
end
else if(IOWrite1 == 0) //write
begin 
//to store in buffer
//GP <= 1;
 Odatabus = BufferReg1[IO1_addr] ;
end
else if(IOWrite1 == 1'bx)
begin
Odatabus = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end
end

else if (Ack1 ==1)
begin
/*if(IOWrite1 == 1) //write
begin 
//to store in buffer
//GP <= 1;
 BufferReg1[count] <= databus ;
 count <= count +1 ;

end
i=0;
//read buffermemory 
$readmemh("buffermemory1.mem", BufferReg1);
//check number of words at memory */
$readmemh("C:\\Users\\fares\\Desktop\\year work\\DMA proj\\GUI\\buffermemory1.mem", BufferReg1);
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
 Odatabus = BufferReg1[i] ;
 BufferReg1[i] = 0 ;
$writememh("C:\\Users\\fares\\Desktop\\year work\\DMA proj\\GUI\\buffermemory1.mem", BufferReg1);
 count = count-1;
end
if (count==32'h00000000)
begin
assign GPIO1 = 0;
interrupt1[0]=0;
$writememb("C:\\Users\\fares\\Desktop\\year work\\DMA proj\\GUI\\interrupt1.txt", interrupt1);
end
end

// GP <= 0;
/*count=0;
GPIO1 =0;
interrupt1[0]=0;
$writememb("interrupt1.mem", interrupt1);*/
 end
/*else begin
 Odatabus <= BufferReg1[0] ;
end*/

end

end

/*else if (IOWrite1 == 1'bx)
Odatabus <= 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;*/
else
Odatabus = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
end


endmodule
//test for intruptting and count 
// module newtest1();

// wire [31:0] databus;
// reg Ack1;
// reg IOWrite1;
// wire GPIO1;
// reg clk;
// reg [8:0] index;
// reg [31:0]indata ;
// wire[31:0]databusbus;
// reg [31:0] databusmemory[0:8191];
// reg [31:0]databusin;
// integer r;
// assign databus = (IOWrite1)? indata :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
// initial clk=1;

// always #5 clk=~clk;



// initial
// begin
// $readmemb("D:\dma/databusfile.txt",databusmemory);
// end
// initial
// begin
// for(r=0;r<8191;r=r+1)
// begin 
// #10
// databusin=databusmemory[r];
// end
// end

// assign databusbus = (!IOWrite1)? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : databusin;
// /*always @(posedge clk) 
// begin
// assign Ack1=0;
// assign IOWrite1 =0;
// assign index = 448;
// $monitor("%b %d %d ",index, IOWrite1 ,databus);
// end*/
// IODevice1 dev(Ack1,GPIO1,databusbus,IOWrite1,clk,index);
// initial
// begin
// assign Ack1=0;
// assign IOWrite1 =0;
// assign index = 264;//8
// $monitor("%b %d %d ",index, IOWrite1 ,databusbus);
// #30
// assign Ack1=0;
// assign IOWrite1 =0;
// assign index = 266;//10
// $monitor("%b %d %d ",index, IOWrite1 ,databusbus);
// #30
// assign Ack1=0;
// assign IOWrite1 =0;
// assign index = 263;//7
// assign indata =5;
// $monitor("%b %d %d ",index, IOWrite1 ,databusbus);
// #30
// assign Ack1=0;
// assign IOWrite1 =1;
// assign index =263 ;//buff7
// assign indata =5;
// $monitor("%b %d %d ",index, IOWrite1 ,databusbus);
// #30
// assign Ack1=0;
// assign IOWrite1 =1'b0;
// assign index = 0;//0
// assign indata =5;
// $monitor("%b %d %d ",index, IOWrite1 ,databusbus);
// #30
// assign Ack1=0;
// assign IOWrite1 =1;
// assign index = 0;//19
// assign indata =5;
// $monitor("%b %d %d ",index, IOWrite1 ,databusbus);
// #30
// assign Ack1=1;
// assign IOWrite1 =0;
// assign index = 0;
// assign indata =5;
// $monitor("%b %d %d ",index, IOWrite1 ,databusbus);
// #49
// assign Ack1=0;
// end




// endmodule 
// module testbench();

// wire [31:0] databus;
// reg IOWrite1;
// wire GPIO1;
// reg indata ;

// assign databus = (!IOWrite1)? indata :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;

// initial 
// begin
// #6
// IOWrite1 = 1'b1;
// indata =32'b1 ;
// $monitor("%d %d %d  ",GPIO1, IOWrite1 ,databus );
// #6
// IOWrite1 = 1'b1;
// indata = 32'b0 ;
// $monitor("%d %d %d ",GPIO1, IOWrite1 ,databus);
// #6
// IOWrite1 = 1'b1;
// indata = 32'b1;
// $monitor("%d %d %d  ",GPIO1, IOWrite1 ,databus );

// #6
// IOWrite1 = 1'b1;
// indata = 32'b0;
// $monitor("%d %d %d  ",GPIO1, IOWrite1 ,databus );

// #6
// IOWrite1 = 1'b1;
// indata = 32'b1;
// $monitor("%d %d %d  ",GPIO1, IOWrite1 ,databus );



// #6
// IOWrite1 = 1'b0;
// $monitor("%d %d %d  ",GPIO1, IOWrite1 ,databus );
// #6
// IOWrite1 = 1'b1;
// indata = 32'b1;
// $monitor("%d %d %d  ",GPIO1, IOWrite1 ,databus );


// /*
// #6
// IOWrite1 = 1'b0;
// $monitor("%d %d %d  ",GPIO1, IOWrite1 ,databus );
// #6
// IOWrite1 = 1'b0;
// $monitor("%d %d %d  ",GPIO1, IOWrite1 ,databus );
// */
// end

// IODevice2 device(GPIO1,databus,IOWrite1,clock );
// clkgenertor c1(clock);


// endmodule  

// module clkgenertor(clock);
// output reg clock;
// initial 
// clock =1 ;
// always
// begin
// #3 
// clock = ~clock;
// end 
// endmodule 

// module interrupt1_test(n,GPIO1, databus ,indata , IOWrite1);
// input IOWrite1; 
// output reg GPIO1;
// output reg [31:0] databus;

// input [31:0] indata ;
// input n ;
// reg [31:0] BufferReg1 [0:30];
// reg interrupt1 [0:1];
// always 
// begin 
// #6
// $readmemb("D:\dma/interrupt1.mem", interrupt1);
// if (interrupt1[0])
// begin 
// assign GPIO1 = 1;
// $monitor("%b" ,GPIO1);
// $readmemh("D:\dma/memory1.mem", BufferReg1);
// end 
// end 
// endmodule 