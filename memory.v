module memory(WR , Data , addr , clk,firstempty);
input [7:0] addr ;
input WR;
inout [31:0] Data ;
reg [31:0] OData;
input clk;
output reg [7:0]firstempty;
reg [31:0] memoryReg [0:191];
integer k;
integer i;
//reg [7:0]Raddr ;

assign Data = (WR)?32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : OData ; //if read Data

initial 
begin
firstempty <=0;
k=0;
for(k=0;k<191;k=k+1)
begin 
 memoryReg[k]=0;
end

end

always@(clk) 
i=0;
for(i=0;i<192;i=i+1)
begin
 if(!memoryReg[i])
begin
	firstempty = i;
$monitor("%d" ,i);
end
begin

  if(WR)
  begin
   memoryReg[addr] <= Data;
  end

  else if(!WR)
  begin
  OData <= memoryReg[addr];
  end
 
end

endmodule 

module testmemory();
reg WR ;
wire [31:0] Data;
reg [31:0]inData;
reg [7:0]addr ;
wire [7:0] firstempty;
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
addr = 7'd1;

$monitor($time,,,"%d %d %d %d ",WR, Data ,inData , addr, clock );

#6
WR = 1'b1;
inData =32'd9 ;
addr = 7'd2;

//$monitor("%h %h %h %h ",WR, Data ,inData , addr );
#6
WR = 1'b1;
inData =32'd12 ;
addr = 7'd3;
//$monitor("%h %h %h %h ",WR, Data ,inData , addr );
#6
WR = 1'b0;

addr = 7'b1;
//$monitor("%h %h %h %h ",WR, Data ,inData , addr );

end

memory mem(WR , Data , addr , clock,firstempty);
//clkgenertor c1(clock);


endmodule 
