module mux(signalout,signal1,signal2,sel);
output reg signalout; 
input wire signal1,signal2,sel;
always @(signal1 or signal2 or sel)
begin
if (sel==0)
signalout = signal1;
else if (sel==1)
signalout = signal2;
else
signalout = 1'bx;
end
endmodule 
module addressmux(signalout,signal1,signal2,sel);
output reg [7:0]signalout; 
input wire [7:0]signal1,signal2;
input wire sel;
always @(signal1 or signal2 or sel)
begin
if (sel==0)
signalout = signal1;
else if (sel==1)
signalout = signal2;
else
signalout = 1'bx;
end
endmodule 
module clkgenerator(clock);                                  
output reg clock;   
initial 
clock = 1;
always 
begin
#5
clock = ~ clock;

end
endmodule
/* this module is made by me to check communication between bus , processor and I/O .. neglect it 
module device(IOIP,IOwrite);
output IOIP;
input IOwrite;
reg [31:0] buffers [0:31];
integer k;
initial
begin
for ( k =0;k<32;k=k+1)
buffers[k]<=k;
end
endmodule
*/




module DMA(firstempty,D_address,grant,D_IOWrite1,D_IOWrite2,D_memwrite,D_IOAck1,D_IOAck2,instruction,clock,IOIP1,IOIP2,busybus,next_source,next_destination); //,databus
input [25:0] instruction ;

wire[1:0] op,type; 
wire [5:0] count;
output reg [7:0]D_address;
input clock,IOIP1,IOIP2,grant; 
wire clk,gnt;
//inout [31:0] databus;
wire[31:0] data; 
output reg D_IOWrite1,D_IOWrite2,D_memwrite,D_IOAck1,D_IOAck2,busybus; 
input [7:0] next_source,next_destination,firstempty;
reg [7:0] source,destination,IPaddress;

assign op = instruction [25:24];
//assign gnt = grant;
assign clk = clock;
assign type = instruction [23:22];
assign count = instruction [5:0];




always @(grant or posedge clk)
begin 
if (grant == 1)
busybus=1;
else
busybus=0; 
end

assign databus = ((instruction [25:24] !=2'b01)&&(instruction [25:24] !=2'b10)&&(instruction [25:24]!=2'b11))? 100000: 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;  //bigdata is in output mode 
assign data = ((instruction [25:24]!=2'b01)&&(instruction [25:24] !=2'b10)&&(instruction [25:24] !=2'b11))? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:databus; //bigdata is in input mode


always@( posedge clk)
begin
source = next_source;
destination = next_destination;
IPaddress = firstempty;
end


initial
$monitor("instruction is %b,source is %b,destination is %b,D_address is %b,busybus is %b,clk is %b",instruction,source,destination,D_address,busybus,clk);


always @ (grant or posedge clk)  
begin
if (grant==1)
begin
if (op == 2'b01 && type ==2'b01 ) // put && busybus==0
begin
if (destination <= 223 && destination >= 192) // from memory to I/O1
begin
D_IOWrite1 = 1;
D_IOWrite2= 1'b0;
D_memwrite = 0;
busybus=1;
D_IOAck1 =0;
D_IOAck2 =0;
D_address = source;
#5
D_address = destination;
#4
D_address = 8'bx; 
end
else if (destination <= 255 && destination >= 224) // from memory to I/O2
begin
D_IOWrite1 = 1'b0;
D_IOWrite2 = 1;
D_memwrite = 0;
busybus=1;
D_IOAck1 =0;
D_IOAck2 =0;
D_address = source;
#5
D_address = destination;
#4
D_address = 8'bx; 
end
end

else if (op == 2'b00 && type ==2'b01 ) // put && busybus==0
begin
if (source <= 223 && source >= 192) // from I/O1 to memory 
begin
D_IOWrite1 = 0;
D_IOWrite2 = 1'b0;
D_memwrite = 1;       
busybus=1;
D_IOAck1 =0;
D_IOAck2=0;
D_address = source;
#5
D_address = destination;
#4
D_address = 8'bx; 
end
else if (source <= 255 && source >= 224) // from I/O2 to memory 
begin
D_IOWrite1 = 1'b0;
D_IOWrite2 = 0;
D_memwrite = 1;
busybus=1;
D_IOAck1 =0;
D_IOAck2 =0;
D_address = source;
#5
D_address = destination;
#4
D_address = 8'bx; 
end
end


else if (( (op == 2'b01 && type == 2'b10)) ) // from memory to memory  // put && (busybus == 0) //(op == 2'b00 && type == 2'b10) ||
begin    
D_IOWrite1 = 1'b0;
D_IOWrite2 = 1'b0;
D_memwrite = 0;   // read from any place in memory at posedge
busybus=1;
D_IOAck1 =0;
D_IOAck2 =0;
D_address = source;
#5
D_address = destination;
D_IOWrite1 = 1'b0;
D_IOWrite2 = 1'b0;
D_memwrite = 1;  // write in any place in memory at negedge of same cycle 
busybus=1; 
D_IOAck1 =0;
D_IOAck2 =0;
#4
D_address = 8'bx; 
end

else 
begin
if ((IOIP1==1) &&(IOIP2==1) )  //I/O1 will have higher priority than I/O2 .. it's just a design choice  // put && (busybus!=1)
begin
D_IOWrite1 = 0;
D_IOWrite2 = 1'b0;
busybus=1;
D_IOAck1 =1;
D_IOAck2 =0;
D_memwrite = 1'b0;
D_address=8'bx;
#5
D_memwrite = 1;
D_address=IPaddress;
#4
D_address = 8'bx; 
end


else if ((IOIP1==1) &&(IOIP2!=1) )  // put && (busybus!=1)
begin
D_IOWrite1 = 0;
D_IOWrite2 = 1'b0;
busybus=1;
D_IOAck1 =1;
D_IOAck2 =0;
D_memwrite = 1'b0;
D_address=8'bx;
#5
D_memwrite = 1;
D_address=IPaddress;
#4
D_address = 8'bx; 
end

else if ((IOIP1!=1) &&(IOIP2==1) )  // put && (busybus!=1)
begin
D_IOWrite1 = 1'b0;
D_IOWrite2 = 0;
busybus=1;
D_IOAck1 =0;
D_IOAck2 =1;
D_memwrite = 1'b0;
D_address=8'bx;
#5
D_memwrite = 1;
D_address=IPaddress;
#4
D_address = 8'bx; 
end

else
begin
D_IOWrite1 = 1'b0;
D_IOWrite2 = 1'b0;
D_memwrite = 1'b0;
busybus=0;
D_IOAck1 =0;
D_IOAck2 =0;
D_address=IPaddress;
#5
D_address = 8'bx; 
end

end
end
end

endmodule


