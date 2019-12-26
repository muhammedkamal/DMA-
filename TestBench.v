module processor_tb();     
wire[31:0]databus;
wire [7:0]address;

// Common signals

//reg IOIP1,IOIP2;
wire[7:0] firstempty;
wire [7:0] next_source,next_destination,src,dest;
reg [25:0]instruction,fake_instruction;
wire [25:0] DMA_instruction;
integer f,i ;
clkgenerator c1(clock);

//test signals

wire IOWrite1,IOWrite2,memwrite,IOAck1,IOAck2,GPIO2,GPIO1;
reg [31:0] datamemory[0:8191];
reg [25:0] instructionmemory[0:8191];
reg [31:0]datain;
integer r,p,oldp;
reg [5:0] updated_count,offset;
wire [8:0] memCS,IO1CS,IO2CS;

//Processor signals

wire P_IOWrite1,P_IOWrite2,P_memwrite,P_IOAck1,P_IOAck2,grant;
wire [7:0]P_address;

//DMA signals

wire D_IOWrite1,D_IOWrite2,D_memwrite,D_IOAck1,D_IOAck2,busybus;
wire [7:0]D_address;
/*always @ (fake_instruction)
i=1;*/
initial
begin
$readmemb("E:\Folder2/datafile.txt",datamemory);
$readmemb("E:\FOLDER/instructionfile.txt",instructionmemory);
f = 1;
i=1;
end
always @(fake_instruction)
begin
offset=0;
//i=1;
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
begin
if (p<8191 )//updated_count
//if ((p<8191))
begin

//offset =0;
//fake_instruction=instructionmemory[p];
if ((instructionmemory[p][25:24]==2'b00 || instructionmemory[p][25:24]==2'b01) && instructionmemory[p][23:22] != 2'b00 && instructionmemory[p][23:22] != 2'b11 && instructionmemory[p][5:0]>=1 && ( instructionmemory[p+i][25:24]==2'b10 || instructionmemory[p+i][25:24]==2'b11 ))
begin
fake_instruction=instructionmemory[p];
#2
instruction=instructionmemory[p];
/*if (instructionmemory[p+i][25:24]==2'b10 || instructionmemory[p+i][25:24]==2'b11)
begin*/
oldp = p;
#8
instruction=instructionmemory[oldp+i];
i = i +1;
//end
end
/*
while ( instructionmemory[p+1+i][25:24]==2'b10 || instructionmemory[p+1+i][25:24]==2'b11 )
begin
#10
instruction=instructionmemory[p+1+i];
i = i +1;
end
*/
else if (updated_count==0 )
begin
offset=0;
oldp = p;
i=0;
fake_instruction = instructionmemory[oldp];
#10

instruction=instructionmemory[oldp];
//#10
//fake_instruction = instruction;
oldp=oldp+1;
if (instruction[25:24]==2'b00 || instruction[25:24]==2'b01)
updated_count =instruction [5:0];
end
end


//p = p + 1;
end
//end
//always@( posedge clock)//fake_instruction or
//begin
//offset =0;

always @(negedge clock )
begin
if (f)
begin
if ((instruction[25:24] == 2'b00 ||instruction[25:24] == 2'b01) )//&& instruction[23:22] != 2'b00 && instruction[23:22] != 2'b11
//#1
updated_count =instruction [5:0];
end

if (updated_count>=1) // put &&busybus==0
begin
p=p;
end
else // if  (updated_count==0) 
begin
p=p+i+1;
end
/*if (updated_count!=0&&)
begin
DMA_instruction = instruction;
//instruction =  instructionmemory[p+1];
p = p + 1;
end
else //if (updated_count==0)
p = p + 1;
end*/
//i=1;
end

/*always @(negedge clock)
begin
#1
if(instructionmemory[p][25:24]!=2'b10 || instructionmemory[p][25:24]!=2'b11);
#4
instruction = instructionmemory[p-1];
end*/
always@(negedge clock )
begin
if (i==0)
i=1;
else if (i==1 && instruction [25:22]==4'b0100 && updated_count == 6'b000000)
begin
i=0;
#1
i=1;
end
end

always@(negedge clock )//or negedge clock
begin
if(updated_count !=0)
begin

updated_count = updated_count - 1;
f = 0;
end
else if (updated_count == 0)
f = 1;
end


always@( negedge clock)//posedge clock or //fake_instruction or
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
 
//assign databus = ((instruction [25:24]!=2'b01)&&(instruction [25:24] !=2'b10)&&(instruction [25:24] !=2'b11))? 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz : datain;
assign databus = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
/*initial 
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



end*/ 
mux m1(IOWrite1,P_IOWrite1,D_IOWrite1,busybus);
mux m2(IOWrite2,P_IOWrite2,D_IOWrite2,busybus);
mux m3(memwrite,P_memwrite,D_memwrite,busybus);
mux m4(IOAck1,P_IOAck1,D_IOAck1,busybus);
mux m5(IOAck2,P_IOAck2,D_IOAck2,busybus);
addressmux m6(address,P_address,D_address,busybus);
processor p1(updated_count,DMA_instruction,firstempty,P_address,grant,busybus,P_IOWrite1,P_IOWrite2,P_memwrite,P_IOAck1,P_IOAck2,instruction,clock,databus,GPIO1,GPIO2,next_source,next_destination);
DMA D1(firstempty,D_address,grant,D_IOWrite1,D_IOWrite2,D_memwrite,D_IOAck1,D_IOAck2,DMA_instruction,clock,GPIO1,GPIO2,busybus,next_source,next_destination); //,databus
IODevice2 dev2(IOAck2,GPIO2,databus,IOWrite2,clock,IO2CS);
IODevice1 dev1(IOAck1,GPIO1,databus,IOWrite1,clock,IO1CS);
memory mem1(memwrite,databus,memCS,clock,firstempty);//memfull,
endmodule

