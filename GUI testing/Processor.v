
module processor(firstempty,P_address,grant,busybus,P_IOWrite1,P_IOWrite2,P_memwrite,P_IOAck1,P_IOAck2,instruction,clock,databus,IOIP1,IOIP2,next_source,next_destination);
input [25:0] instruction ;
wire [3:0] Readreg1,Readreg2,Writereg;
wire [31:0] ReadData1, ReadData2; 
wire[1:0] op,type; 
wire [5:0] count;
wire RegWrite; 
input clock,IOIP1,IOIP2,busybus; 
wire clk;
inout [31:0] databus;
wire[31:0] data; 
output reg grant,P_IOWrite1,P_IOWrite2,P_memwrite,P_IOAck1,P_IOAck2;
input [7:0] next_source,next_destination,firstempty;
wire [7:0] fake_source,fake_destination;
output reg [7:0]P_address;
reg [7:0] source,destination,IPaddress;
 

assign Readreg1 = instruction[23:20];
assign Readreg2 = instruction[19:16];
assign Writereg = instruction[15:12]; 
assign op = instruction [25:24];
assign RegWrite = (op == 1 || op == 2 || op == 3)? 1 : 0;
assign clk = clock;
assign type = instruction [23:22];
assign count = instruction [5:0];
assign fake_source = next_source;
assign fake_destination = next_destination;


assign databus = ((instruction [25:24] !=2'b01)&&(instruction [25:24] !=2'b10)&&(instruction [25:24]!=2'b11))? data : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;  //bigdata is in output mode 
assign data = ((instruction [25:24]!=2'b01)&&(instruction [25:24] !=2'b10)&&(instruction [25:24] !=2'b11))? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:databus; //bigdata is in input mode

RegisterFile RF1(ReadData1, ReadData2, Readreg1,Readreg2, Writereg,fake_source,fake_destination,RegWrite,op,type,clk,data); 

always@(posedge clk)
begin
source = next_source;
destination = next_destination;
IPaddress = firstempty;
end

/*
always@(posedge clk)
begin
if ((op==2'b00 || op==2'b01) && count >0 )
grant = 1;
else 
grant = 0;
end

*/
//initial
//$monitor("instruction is %b,source is %b,destination is %b,address is %b,busybus is %b,clk is %b",instruction,source,destination,address,busybus,clk);

always @ (posedge clk) // generating I/Owrite1 , I/Owrite2 , memwrite for all instructions 
/*for processor, instructions will have higher priority than interrupts , because it will assign interrupts to DMA in case of conflicts
if there is an instruction(lw,sw) at posedge and there is interrupt(s),the device should wait becuase it can't take Bus now
if there is an instruction(add,sub) at posedge and there is interrupt(s),the processor gives grant to DMA while it executes instruction
if there is no instruction at posedge and there is interrupt(s) , the processor will execute interrupt 
*/
begin
if (op == 2'b00 && type ==2'b11 ) // put && busybus==0
begin
if (destination <= 223 && destination >= 192) // from Regfile to I/O1
begin  
P_IOWrite1 = 1;
P_IOWrite2 = 1'bx;
P_memwrite = 1'bx;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = 8'bx;
#5
P_address = destination; 
end
else if (destination <= 255 && destination >= 224) // from Regfile to I/O2
begin
P_IOWrite1 = 1'bx;
P_IOWrite2 = 1;
P_memwrite = 1'bx;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = 8'bx;
#5
P_address = destination;
end
end

else if (op == 2'b01 && type ==2'b01 && count==0) // put && busybus==0
begin
if (destination <= 223 && destination >= 192 ) // single word from memory to I/O1
begin
P_IOWrite1 = 1;
P_IOWrite2= 1'bx;
P_memwrite = 0;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = source;
#5
P_address = destination;
end
else if (destination <= 255 && destination >= 224) //single word from memory to I/O2
begin
P_IOWrite1 = 1'bx;
P_IOWrite2 = 1;
P_memwrite = 0;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = source;
#5
P_address = destination;
end
end

else if (op == 2'b01 && type ==2'b01 && count!=0) // multiple words from memory to I/O
grant = 1;

else if (op == 2'b00 && type ==2'b01 && count==0 ) // put && busybus==0
begin
if (source <= 223 && source >= 192) //single word from I/O1 to memory 
begin
P_IOWrite1 = 0;
P_IOWrite2 = 1'bx;
P_memwrite = 1;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = source;
#5
P_address = destination;
end
else if (source <= 255 && source >= 224) // single word from I/O2 to memory 
begin
P_IOWrite1 = 1'bx;
P_IOWrite2 = 0;
P_memwrite = 1;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = source;
#5
P_address = destination;
end
end

else if (op == 2'b00 && type ==2'b01 && count!=0 ) // multiple words from I/O to memory 
grant = 1;

else if (op == 2'b01 && type ==2'b11 ) // put && busybus==0 
begin
if (source <= 223 && source >= 192) // from I/O1 to Regfile
begin
P_IOWrite1 = 0;
P_IOWrite2 = 1'bx;
P_memwrite = 1'bx;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = source;

end
else if (source <= 255 && source >= 224) // from I/O2 to Regfile
begin
P_IOWrite1 = 1'bx;
P_IOWrite2 = 0;
P_memwrite = 1'bx;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = source;

end
end

else if (op == 2'b00 && type == 2'b00 ) // from Regfile to memory  // put && busybus==0
begin
P_IOWrite1 = 1'bx;
P_IOWrite2 = 1'bx;
P_memwrite = 1;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
#5
P_address = destination;
end

else if (op == 2'b01 && type == 2'b00 ) // from memory to Regfile   // put && busybus==0
begin
P_IOWrite1 = 1'bx;
P_IOWrite2 = 1'bx;
P_memwrite = 0;
grant = 0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = source;

end

else if (( (op == 2'b01 && type == 2'b10)) && count==0 )// single word from memory to memory  // put && (busybus == 0) //op == 2'b00 && type == 2'b10) ||
begin    
P_IOWrite1 = 1'bx;
P_IOWrite2 = 1'bx;
P_memwrite = 0;   // read from any place in memory at posedge
grant = 0; 
P_IOAck1 =0;
P_IOAck2 =0;
P_address = source;
#5
P_address = destination;
P_IOWrite1 = 1'bx;
P_IOWrite2 = 1'bx;
P_memwrite = 1;  // write in any place in memory at negedge of same cycle 
grant = 0; 
P_IOAck1 =0;
P_IOAck2 =0;
end

else if (( (op == 2'b01 && type == 2'b10)) && count!=0 )// multiple words from memory to memory //(op == 2'b00 && type == 2'b10) ||
grant=1;

else if ((op==2'b10) || (op==2'b11))
begin
P_IOWrite1 = 1'bx;
P_IOWrite2 = 1'bx;
P_memwrite = 1'bx;
grant = 1;
P_IOAck1 =0;
P_IOAck2 =0;
P_address = 8'bx;
end

else 
begin
if ((IOIP1==1) &&(IOIP2==1) )  //I/O1 will have higher priority than I/O2 .. it's just a design choice  // put && (busybus!=1)
begin
P_IOWrite1 = 0;
P_IOWrite2= 1'bx;
grant=0;
P_IOAck1 =1;
P_IOAck2 =0;
P_memwrite = 1'bx;
P_address=8'bx;
#5
P_memwrite = 1;
P_address=IPaddress;
end


else if ((IOIP1==1) &&(IOIP2!=1) )  // put && (busybus!=1)
begin
P_IOWrite1 = 0;
P_IOWrite2 = 1'bx;
grant=0;
P_IOAck1 =1;
P_IOAck2 =0;
P_memwrite = 1'bx;
P_address=8'bx;
#5
P_memwrite = 1;
P_address=IPaddress;
end

else if ((IOIP1!=1) &&(IOIP2==1) )  // put && (busybus!=1)
begin
P_IOWrite1 = 1'bx;
P_IOWrite2 = 0;
grant=0;
P_IOAck1 =0;
P_IOAck2 =1;
P_memwrite = 1'bx;
P_address=8'bx;
#5
P_memwrite = 1;
P_address=IPaddress;
end

else
begin
P_IOWrite1 = 1'bx;
P_IOWrite2 = 1'bx;
P_memwrite = 1'bx;
grant=0;
P_IOAck1 =0;
P_IOAck2 =0;
P_address=8'bx;
end

end
end

//always @(grant)

/*
initial
$monitor("instruction is %b,source is %d,destination is %d,address is %d,clk is %b",instruction,source,destination,address,clk);
*/

/*
initial
begin
#6 // because it takes 6 time units to reach first posedge 
$monitor("op is %d,type is %d, source is %d,destination is %d,I/OW1 is %d,I/OW2 is %d,memwrite is %d,clk is %b",op,type,source,destination,IOWrite1,IOWrite2,memwrite,clk);
end
*/
endmodule