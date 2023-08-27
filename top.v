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

//JUMP AND BRANCH INSTRUCTIONS
`define jump 5'b10000 //JUMP TO ADDR
`define jcarry 5'b10001 // JUMP IF CARRY
`define jnocarry 5'b10010 // JUMP IF NO CARRY
`define jsign 5'b10011 // JUMP IF SIGN
`define jnosign 5'b10100 // JUMP IF NO SIGN
`define jzero 5'b10101 // JUMP IF ZERO
`define jnozero 5'b10110 // JUMP IF NO ZERO
`define joverflow 5'b10111 // JUMP IF OVERFLOW
`define jnooverflow 5'b11000 // JUMP IF NO OVERFLOW

`define halt 5'b11001 // JUMP IF CARRY

module top(input clk,sys_rst,
            input [15:0] din,
            output reg [15:0] dout
);

    reg [31:0] inst_mem [15:0]; //program memory
    reg [15:0] data_mem [15:0]; //data memory

    reg [31:0] IR; //instruction reg
    reg [15:0] GPR [31:0]; //general purpose reg
    reg [15:0] SGPR; //special gpr
    reg [31:0] mul_res; //temp mul result
    reg sign = 0, zero = 0, overflow = 0, carry = 0; //flags
    reg [16:0] temp_sum;
    reg jump_flag = 0;
    reg stop = 0;

    wire [4:0] SRC1;
    wire [15:0] IMM_DATA;
    wire [15:0] DATA;
    wire [15:0] DATA_MEM;
    assign SRC1 = `rsrc1; 
    assign IMM_DATA = `isrc; 
    assign DATA = GPR[`rsrc1];  
    assign DATA_MEM = data_mem[`isrc];

    task decode_inst();
    begin
        jump_flag = 1'b0;
        stop = 1'b0;    
        case (`oper_type)

            `movesgpr: begin
                GPR[`rdst] = SGPR;
            end

            `mov: begin
                if(`imm_mode)
                    GPR[`rdst] = `isrc;
                else 
                    GPR[`rdst] = GPR[`rsrc1];
            end

            `add: begin
                if(`imm_mode)
                    GPR[`rdst] = GPR[`rsrc1] + `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1] + GPR[`rsrc2];
            end

            `sub: begin
                if(`imm_mode)
                    GPR[`rdst] = GPR[`rsrc1] - `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1] - GPR[`rsrc2];
            end

            `mul: begin
                if(`imm_mode)
                   mul_res = GPR[`rsrc1] * `isrc;
                else
                    mul_res = GPR[`rsrc1] * GPR[`rsrc2];
            
                GPR[`rdst] = mul_res[15:0];
                SGPR = mul_res[31:16];
            end

            `or_op: begin
                if(`imm_mode)
                    GPR[`rdst] = GPR[`rsrc1] | `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1] | GPR[`rsrc2];
            end

            `and_op: begin
                if(`imm_mode)
                    GPR[`rdst] = GPR[`rsrc1] & `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1] & GPR[`rsrc2];
            end

            `xor_op: begin
                if(`imm_mode)
                    GPR[`rdst] = GPR[`rsrc1] ^ `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1] ^ GPR[`rsrc2];
            end

            `xnor_op: begin
                if(`imm_mode)
                    GPR[`rdst] = GPR[`rsrc1] ~^ `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1] ~^ GPR[`rsrc2];
            end

            `nand_op: begin
                if(`imm_mode)
                    GPR[`rdst] = ~(GPR[`rsrc1] & `isrc);
                else
                    GPR[`rdst] = ~(GPR[`rsrc1] & GPR[`rsrc2]);
            end

            `nor_op: begin
                if(`imm_mode)
                    GPR[`rdst] = ~(GPR[`rsrc1] | `isrc);
                else
                    GPR[`rdst] = ~(GPR[`rsrc1] | GPR[`rsrc2]);
            end

            `not_op: begin
                if(`imm_mode)
                    GPR[`rdst] = ~(`isrc);
                else
                    GPR[`rdst] = ~(GPR[`rsrc1]);
            end

            `din_DM: begin
                data_mem[`isrc] = din;
            end

            `GPR_DM: begin
                data_mem[`isrc] = GPR[`rsrc1];
            end  

            `DM_dout: begin
                dout = data_mem[`isrc];
            end  

            `DM_GPR: begin
                GPR[`rdst] = data_mem[`isrc];
            end    

            `jump: begin 
                jump_flag = 1'b1;
            end  

            `jcarry: begin
                if(carry == 1'b1)
                    jump_flag = 1'b1;
                else
                    jump_flag = 1'b0;
            end

            `jsign: begin
                if(sign == 1'b1)
                    jump_flag = 1'b1;
                else
                    jump_flag = 1'b0;
            end

            `jzero: begin
                if(zero == 1'b1)
                    jump_flag = 1'b1;
                else
                    jump_flag = 1'b0;
            end

            `joverflow: begin
                if(overflow == 1'b1)
                    jump_flag = 1'b1;
                else
                    jump_flag = 1'b0;
            end

            `jnocarry: begin
                if(carry == 1'b0)
                    jump_flag = 1'b1;
                else
                    jump_flag = 1'b0;
            end

            `jnosign: begin
                if(sign == 1'b0)
                    jump_flag = 1'b1;
                else
                    jump_flag = 1'b0;
            end

            `jnozero: begin
                if(zero == 1'b0)
                    jump_flag = 1'b1;
                else
                    jump_flag = 1'b0;
            end

            `jnooverflow: begin
                if(overflow == 1'b0)
                    jump_flag = 1'b1;
                else
                    jump_flag = 1'b0;
            end

            `halt: begin
                stop = 1'b1;
            end

        endcase
    end
    endtask

    task decode_condflag();
    begin
        //SIGN BIT
        if(`oper_type == `mul)
            sign = SGPR[15];
        else
            sign = GPR[`rdst][15];

        //CARRY
        if (`oper_type == `add) begin
            if (`imm_mode) begin
                temp_sum = GPR[`rsrc1] + `isrc;
            end else begin
                temp_sum = GPR[`rsrc1] + GPR[`rsrc2];
            end
            carry = temp_sum[16];
        end else begin
            carry = 1'b0;
        end

        //ZERO FLAG
        if(`oper_type == `mul)
            zero = ~((|SGPR[15]) | (|GPR[`rdst]));
        else
            zero = ~(| GPR[`rdst]);

        //OVERFLOW FLAG
        if(`oper_type == `add) begin
            if(`imm_mode)
                overflow = ( (~GPR[`rsrc1][15] & ~IR[15] & GPR[`rdst][15] ) | (GPR[`rsrc1][15] & IR[15] & ~GPR[`rdst][15]) );
            else
                overflow = ( (~GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & GPR[`rsrc2][15] & ~GPR[`rdst][15]));
        end
        else if(`oper_type == `sub) begin
            if(`imm_mode)
                overflow = ( (~GPR[`rsrc1][15] & IR[15] & GPR[`rdst][15] ) | (GPR[`rsrc1][15] & ~IR[15] & ~GPR[`rdst][15]) );
            else
                overflow = ( (~GPR[`rsrc1][15] & GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & ~GPR[`rdst][15]));
        end 
        else
            overflow = 1'b0;   

    end
    endtask

    //READ INSTRUCTIONS(PROGRAM MEMORY)
    //PROGRAM MEMORY FILE
    initial begin
        $readmemb("instruction2.mem",inst_mem);
    end

    reg[2:0]count = 0; //delay for reading
    integer PC = 0; //program counter. Reads instruction one by one

/*     //READ ONE BY ONE
    always @(posedge clk) begin
        if(sys_rst) begin
            count <= 0;
            PC <= 0;
        end
        else begin
            if (count < 4) begin
                count <= count + 1;
            end else begin
                count <= 0;
                PC <= PC + 1;
            end
        end
    end

    //STORING DATA READ FROM FILE(PROGRAM MEMORY) INTO INSTRUCTION REGISTER
    always @(*) begin
        if(sys_rst)
            IR = 0;
        else begin
            IR = inst_mem[PC];
            decode_inst();
            decode_condflag();
        end
    end */

    //FSM
    parameter idle = 0; // CHECK RESET STATE
    parameter fetch_inst = 1; // LOAD INSTRUCTION FROM PROGRAM MEMORY
    parameter dec_exec_inst = 2; //EXECUTE INSTRUCTION + UPDATE CONDITION FLAG
    parameter next_inst = 3; //NEXT INSTRUCTION TO BE FETCHED
    parameter sense_halt = 4; //HALT
    parameter delay_next_inst = 5; //DELAY BETWEEN INSTRUCTIONS

    reg [2:0] state = idle, next_state = idle;

    always@(posedge clk)
    begin
        if(sys_rst)
            state <= idle;
        else
        state <= next_state; 
    end

    always@(*)
    begin
        case (state)

            idle: begin
                IR = 32'h0;
                PC = 0;
                next_state = fetch_inst;
            end

            fetch_inst: begin
                IR = inst_mem[PC];
                next_state = dec_exec_inst;
            end

            dec_exec_inst: begin
                decode_inst();
                decode_condflag();
                next_state = delay_next_inst;
            end

            delay_next_inst: begin
                if(count < 4)
                    next_state = delay_next_inst;
                else
                    next_state = next_inst;
            end

            next_inst: begin
                next_state = sense_halt;
                if(jump_flag == 1'b1)
                    PC = `isrc;
                else
                    PC = PC + 1;
            end

            sense_halt: begin
                if(stop == 1'b0)
                    next_state = fetch_inst;
                else if(sys_rst == 1'b1)
                    next_state = idle;
                else
                    next_state = sense_halt;
            end
            
            default: begin
                next_state = idle;
            end
        endcase
    end

    always@(posedge clk)
    begin
        case(state)
    
            idle : begin
                count <= 0;
            end
    
            fetch_inst: begin
                count <= 0;
            end
    
            dec_exec_inst : begin
                count <= 0;    
            end  
    
            delay_next_inst: begin
                count  <= count + 1;
            end
    
            next_inst : begin
                count <= 0;
            end
    
            sense_halt : begin
                count <= 0;
            end
    
            default : count <= 0;    
        endcase
    end
endmodule