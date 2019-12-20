module memory(WR , Data , addr , clk ,memfull);
input [7:0] addr ;
input WR;
inout [31:0] Data ;
reg [31:0] OData;
input clk;
//reg [7:0]memoryReg[191];
reg [31:0] memoryReg [0:191];
integer k;
reg [7:0]i;
output reg memfull;
//reg [7:0]Raddr ;

assign Data = (WR)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : OData ; //if read Dataassign memoryReg[191]=memoryReg[191];
initial 
begin
memoryReg[191] =0;
k=0;
for(k=0;k<191;k=k+1)
begin 
 memoryReg[k]=0;
end

end
 
integer file, i;
always @(WR)
 begin
	#50 // delay between writing to the memory and then writing to the file
 file = $fopen("C:\\Users\\Toka\\Desktop\\dma-gui-master\\Memory.txt","w");

for(i=0;i<192;i=i+4)
	begin
		$fwrite(file,"%04d   : ", i);
  $fwrite(file,"%h %h %h %h",memoryReg[i],memoryReg[i+1],memoryReg[i+2],memoryReg[i+3]);
		$fwrite(file,"\n");		
	end
	$fclose(file);

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
always @(clk)
begin
i=192;
for (i=192;i>0;i=i-1)
begin
//@(clk);
if(memoryReg[i]==32'h0000_0000)
begin
memoryReg[191]=i;
$monitor("%d" ,memoryReg[191]);
end
/*else if (memoryReg[i]!=32'h0000_0000)
begin
i=i+1;
end*/
end
if(memoryReg[191]==32'd190)
begin 
memfull <=1;
end 
else 
begin
memfull<=0;
end
  if(WR && addr!=191)
  begin
   memoryReg[addr] <= Data;
  end

  else if(!WR)
  begin
  OData <= memoryReg[addr];
  end
$writememb("memory.mem", memoryReg);
end

endmodule 

module testmemory();
reg WR ;
wire [31:0] Data;
reg [31:0]inData;
reg [7:0]addr ;
//wire [7:0] memoryReg[191];
assign Data = (WR)? inData :32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
reg clock;

initial
begin
clock=0;
end 

always 
begin
#5 clock= ~clock; 
end

initial 
begin
 
#6
WR = 1'b1;
inData =32'd8 ;
addr = 7'd0;

$monitor($time,,,"%d %d %d %d ",WR, Data ,inData , addr, clock );

#6
WR = 1'b1;
inData =32'd9 ;
addr = 7'd1;

//$monitor("%h %h %h %h ",WR, Data ,inData , addr );
#6
WR = 1'b1;
inData =32'd12 ;
addr = 7'd2;
//$monitor("%h %h %h %h ",WR, Data ,inData , addr );
#6
WR = 1'b0;

addr = 7'b1;
//$monitor("%h %h %h %h ",WR, Data ,inData , addr );

end

memory mem(WR , Data , addr , clock,memfull);
//clkgenertor c1(clock);


endmodule 
