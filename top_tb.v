`timescale 1ns/1ps

//IR FIELDS
`define oper_type IR[31:27]
`define rdst IR[26:22]
`define rsrc1 IR[21:17]
`define imm_mode IR[16]
`define rsrc2 IR[15:11]
`define isrc IR[15:0]

//ARITHMETIC OPERATIONS
`define movesgpr 5'b0
`define mov 5'b1
`define add 5'b10
`define sub 5'b11
`define mul 5'b100

//LOGICAL OPERATIONS
`define or_op 5'b101
`define and_op 5'b110
`define xor_op 5'b111
`define xnor_op 5'b1000
`define nand_op 5'b1001
`define nor_op 5'b1010
`define not_op 5'b1011

//LOAD AND STORE INSTRUCTIONS
`define GPR_DM 5'b1100 //REG to DATA MEM
`define din_DM 5'b1101 //INPUT to DATA MEM
`define DM_dout 5'b1110 //DATA MEM to OUTPUT
`define DM_GPR 5'b1111 //DATA MEM to REG

module tb();

    integer i = 0;
    reg clk = 0,sys_rst = 0;
    reg [15:0] din = 0;
    wire [15:0] dout;

    top dut(.clk(clk),
            .sys_rst(sys_rst),
            .din(din),
            .dout(dout)
    );

    always #5 clk = ~clk;

    //INITIALISING VALUE OF ALL REGISTERS TO ZERO
    initial begin
        for(i=0; i<32; i = i+1)
        begin
            dut.GPR[i] = 0;
        end
    end

    //INITIALISING VALUE OF DATA MEMORY TO FOUR
    initial begin
        for(i=0; i<16; i = i+1)
        begin
            dut.data_mem[i] = 4;
        end
    end

    initial begin
        sys_rst = 1'b1;
        repeat(5) @(posedge clk);
        sys_rst = 1'b0;
        din = 16'd30;
        #2500;
        $stop;
    end

    //----------------------------------------------------------------------------------------------------
    //**************************** TEST READING MEMORY FILES ****************************
    /* reg clk = 0;
    reg [31:0] mem [15:0]; //data memory
    initial begin
        $readmemh("data.mem",mem);
    end

    reg [31:0] IR;
    always #5 clk = ~clk;
    integer count = 0, delay = 0;

    always @(posedge clk) begin
        if(delay < 4)
            delay <= delay + 1;
        else begin
            count <= count + 1;
            delay <= 0;
        end
    end

    always@(*) begin
        IR = mem[count];
    end */

    //----------------------------------------------------------------------------------------------------
    //**************************** TEST INDIVIDUAL OPERATIONS **************************************

    /* initial begin
        //ADD IMMEDIATE
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 2;
        dut.`rsrc1 = 3;
        dut.`rdst = 0;
        dut.`isrc = 4;
        #10;
        $display($time,"OP: ADI RSRC1: %0d RSRC2: %0d RDST: %0d",dut.GPR[dut.`rsrc1], dut.`isrc, dut.GPR[dut.`rdst]);
        //ADD REGISTER
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 2;
        dut.`rsrc1 = 4;
        dut.`rsrc2 = 5;
        dut.`rdst = 0;
        #10;
        $display($time,"OP: ADD RSRC1: %0d RSRC2: %0d RDST: %0d",dut.GPR[dut.`rsrc1], dut.GPR[dut.`rsrc2], dut.GPR[dut.`rdst]);
        //IMMEDIATE MOVE
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 1;
        dut.`rdst = 4;
        dut.`isrc = 55;
        #10;
        $display($time,"OP: MOVI RDST: %0d imm_data: %0d",dut.GPR[dut.`rdst],dut.`isrc);
        //MOV REGISTER
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 1;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        #10;
        $display($time,"OP: MOV RDST: %0d RSRC1: %0d",dut.GPR[dut.`rdst],dut.GPR[dut.`rsrc1]);
        //MULTIPLICATION
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 4;
        dut.`rsrc1 = 0;
        dut.`rsrc2 = 1;
        dut.`rdst = 2;
        #5;
        dut.GPR[3] = dut.SGPR;
        #10;
        $display($time,"OP: MUL RSRC1: %0d RSRC2: %0d RDST: %0d, GPR[3]: %0d SGPR: %0d, ANS: %0d",dut.GPR[dut.`rsrc1], dut.GPR[dut.`rsrc2],dut.GPR[dut.`rdst], dut.GPR[3],dut.SGPR,dut.mul_res);
        //LOGICAL
        //AND IMMEDIATE
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 6;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`isrc = 56;
        #10;
        $display("OP: ANDI RDST: %8b RSRC1: %8b imm_data: %8b",dut.GPR[4],dut.GPR[7],dut.`isrc);
        //AND REGISTER
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 6;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`rsrc2 = 8;
        #10;
        $display("OP: AND RDST: %8b RSRC1: %8b RSRC2: %8b",dut.GPR[4],dut.GPR[7],dut.GPR[8]);
        //OR IMMEDIATE
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 5;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`isrc = 56;
        #10;
        $display("OP: ORI RDST: %8b RSRC1: %8b imm_data: %8b",dut.GPR[4],dut.GPR[7],dut.`isrc);
        //OR REGISTER
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 5;
        dut.`rdst = 0;
        dut.`rsrc1 = 4;
        dut.`rsrc2 = 16;
        #10;
        $display("OP: OR RDST: %8b RSRC1: %8b RSRC2: %8b",dut.GPR[0],dut.GPR[4],dut.GPR[16]);
        //XOR IMMEDIATE
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 7;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`isrc = 56;
        #10;
        $display("OP: XORI RDST: %8b RSRC1: %8b imm_data: %8b",dut.GPR[4],dut.GPR[7],dut.`isrc);
        //XOR REGISTER
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 7;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`rsrc2 = 8;
        #10;
        $display("OP: XOR RDST: %8b RSRC1: %8b RSRC2: %8b",dut.GPR[4],dut.GPR[7],dut.GPR[8]);
        //XNOR IMMEDIATE
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 8;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`isrc = 56;
        #10;
        $display("OP: XNORI RDST: %8b RSRC1: %8b imm_data: %8b",dut.GPR[4],dut.GPR[7],dut.`isrc);
        //XNOR REGISTER
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 8;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`rsrc2 = 8;
        #10;
        $display("OP: XNOR RDST: %8b RSRC1: %8b RSRC2: %8b",dut.GPR[4],dut.GPR[7],dut.GPR[8]);
        //NAND IMMEDIATE
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 9;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`isrc = 56;
        #10;
        $display("OP: NANDI RDST: %8b RSRC1: %8b imm_data: %8b",dut.GPR[4],dut.GPR[7],dut.`isrc);
        //NAND REGISTER
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 9;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`rsrc2 = 8;
        #10;
        $display("OP: NAND RDST: %8b RSRC1: %8b RSRC2: %8b",dut.GPR[4],dut.GPR[7],dut.GPR[8]);
        //NOR IMMEDIATE
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 10;
        dut.`rdst = 4;
        dut.`rsrc1 = 7;
        dut.`isrc = 56;
        #10;
        $display("OP: NORI RDST: %8b RSRC1: %8b imm_data: %8b",dut.GPR[4],dut.GPR[7],dut.`isrc);
        //NOR REGISTER
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 10;
        dut.`rdst = 0;
        dut.`rsrc1 = 4;
        dut.`rsrc2 = 16;
        #10;
        $display("OP: NOR RDST: %8b RSRC1: %8b RSRC2: %8b",dut.GPR[0],dut.GPR[4],dut.GPR[16]);
        //NOT IMMEDIATE
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = 11;
        dut.`rdst = 4;
        dut.`isrc = 56;
        #10;
        $display("OP: NOTI RDST: %8b imm_data: %8b",dut.GPR[4],dut.`isrc);
        //NOT REGISTER
        $display("-------------------------------------");
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = 11;
        dut.`rdst = 0;
        dut.`rsrc1 = 6;
        #10;
        $display("OP: NOT RDST: %8b RSRC1: %8b",dut.GPR[0],dut.GPR[6]);
        //ZERO FLAG
        $display("-------------------------------------");
        dut.IR = 0;
        dut.GPR[0] = 0;
        dut.GPR[1] = 0;
        dut.`imm_mode = 0;
        dut.`rsrc1 = 0;
        dut.`rsrc2 = 0;
        dut.`oper_type = 2; //add
        dut.`rdst = 2;
        #10;
        $display("OP: ZERO RSRC1: %0d RSRC2: %0d RDST: %0d",dut.GPR[0],dut.GPR[1],dut.GPR[2]);
        //SIGN GLAG
        $display("-------------------------------------");
        dut.IR = 0;
        dut.GPR[0] = 16'h8000; 
        dut.GPR[1] = 0; 
        dut.`imm_mode = 0;
        dut.`rsrc1 = 0;
        dut.`rsrc2 = 1;
        dut.`oper_type = 2;
        dut.`rdst = 2;
        #10;
        $display("OP: SIGN RSRC1: %0d  RSRC2: %0d RDST: %0d",dut.GPR[0], dut.GPR[1], dut.GPR[2]);
        //CARRY AND OVERFLOW
        dut.IR = 0;
        dut.GPR[0] = 16'h8000; 
        dut.GPR[1] = 16'h8002; 
        dut.`imm_mode = 0;
        dut.`rsrc1 = 0;
        dut.`rsrc2 = 1;
        dut.`oper_type = 2;
        dut.`rdst = 2;    
        #10;        
        $display("OP: CARRY & OVERFLOW RSRC: %0d  RSRC: %0d RDST: %0d",dut.GPR[0], dut.GPR[1], dut.GPR[2] );
        $display("-----------------------------------------------------------------");
        
        #20;
        $finish;
    end */
    
endmodule