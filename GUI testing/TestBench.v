module processor_tb();     
wire[31:0]databus;
wire [7:0]address;

// Common signals

reg IOIP1,IOIP2;
reg [7:0] firstempty;
wire [7:0] next_source,next_destination,src,dest;
reg [25:0]instruction,fake_instruction;
clkgenerator c1(clock);

//test signals

wire IOWrite1,IOWrite2,memwrite,IOAck1,IOAck2;
reg [31:0] datamemory[0:8191];
reg [25:0] instructionmemory[0:8191];
reg [31:0]datain;
integer r,p;
reg [5:0] updated_count,offset;
wire [8:0] memCS,IO1CS,IO2CS;

//Processor signals

wire P_IOWrite1,P_IOWrite2,P_memwrite,P_IOAck1,P_IOAck2,grant;
wire [7:0]P_address;

//DMA signals

wire D_IOWrite1,D_IOWrite2,D_memwrite,D_IOAck1,D_IOAck2,busybus;
wire [7:0]D_address;

initial
begin     

$readmemb("C:/Users/Toka/Desktop/dma-gui-master/binary.txt",instructionmemory);
end
initial
begin
for(r=0;r<8191;r=r+1)
begin 
#10
datain=datamemory[r];
end
end

initial
begin
p = 0;
updated_count=0;
offset=0;
end

always @(posedge clock)
if ((p<8191) && updated_count == 0)
begin
offset =0;
fake_instruction=instructionmemory[p];
#10
instruction=instructionmemory[p];
p = p + 1;
if (instruction[25:24]==2'b00 || instruction[25:24]==2'b01)
updated_count =instruction [5:0];
end

always@(negedge clock)
begin
if(updated_count !=0)
updated_count = updated_count - 1;
end


always@(posedge clock)
begin
if (fake_instruction [5:0] == 0)
offset = 1;
else if (fake_instruction [5:0] >=1)
begin
offset =offset+1;
end
else
offset = 0;
end

assign src = fake_instruction [21:14];
assign dest = fake_instruction [13:6];
assign next_source= src+offset-1;
assign next_destination= dest+offset-1;


assign IO1CS[7:0] = address-192 ;
assign IO1CS[8] = (address <= 223 && address >= 192)?1:0; 
assign IO2CS[7:0] = address-224 ;
assign IO2CS[8] = (address <= 255 && address >= 224)?1:0; 
assign memCS[7:0] = address;
assign memCS[8] = (address <= 191 && address >= 0)?1:0;  

/*
initial
$monitor("instruction is %b,address is %d,memCS is %b,IO1CS is %b,IO2CS is %b,clock is %b",instruction,address,memCS,IO1CS,IO2CS,clock); 
*/
 
assign databus = ((instruction [25:24]!=2'b01)&&(instruction [25:24] !=2'b10)&&(instruction [25:24] !=2'b11))? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : datain;

initial 
begin 

#30
IOIP1 = 1;
IOIP2 = 0;
firstempty = 00001111;

#20
IOIP1 = 0;
IOIP2 = 1;
firstempty = 00001010;


#30
IOIP1 = 1;
IOIP2 = 1;
firstempty = 00001101;

#20
IOIP1 = 0;
IOIP2 = 1;
firstempty = 00010101;

#20
IOIP1 = 1;
IOIP2 = 0;
firstempty = 00010111;

#30
IOIP1 = 1;
IOIP2 = 1;
firstempty = 00010011;
#40
IOIP1 = 1;
IOIP2 = 1;
firstempty = 00101100;

/*
#6
instruction = 26'b00_00_01100110_00001110_000000;
#6
instruction = 26'b00_01_11011101_10100101_000000;
#6
instruction = 26'b00_10_11001100_00110011_000000;
#6
instruction = 26'b00_11_10101010_11001000_000000;  
#6
instruction = 26'b01_00_11100011_00011000_000000;
#6
instruction = 26'b01_01_11110000_11110101_000000;
#6
instruction = 26'b01_10_00110110_10001010_000000;
#6
instruction = 26'b01_11_11111010_11000011_000000;

#6
instruction = 26'b10_00_11011011_00100100_000000;
#6
instruction = 26'b10_01_10100101_11111111_000000; 
#6
instruction = 26'b10_01_11000110_11001100_000000;   
#6
instruction = 26'b10_11_01101101_01111100_000000;
#6
instruction = 26'b11_00_01111110_00000100_000000;
#6
instruction = 26'b11_01_01111101_01101111_000000;
#6
instruction = 26'b11_10_11111110_01111111_000000;
#6
instruction = 26'b11_11_10101111_00111111_000000;

*/  

end
mux m1(IOWrite1,P_IOWrite1,D_IOWrite1,busybus);
mux m2(IOWrite2,P_IOWrite2,D_IOWrite2,busybus);
mux m3(memwrite,P_memwrite,D_memwrite,busybus);
mux m4(IOAck1,P_IOAck1,D_IOAck1,busybus);
mux m5(IOAck2,P_IOAck2,D_IOAck2,busybus);
addressmux m6(address,P_address,D_address,busybus);
processor p1(firstempty,P_address,grant,busybus,P_IOWrite1,P_IOWrite2,P_memwrite,P_IOAck1,P_IOAck2,instruction,clock,databus,IOIP1,IOIP2,next_source,next_destination);
DMA D1(firstempty,D_address,grant,D_IOWrite1,D_IOWrite2,D_memwrite,D_IOAck1,D_IOAck2,instruction,clock,IOIP1,IOIP2,busybus,next_source,next_destination); //,databus
endmodule

