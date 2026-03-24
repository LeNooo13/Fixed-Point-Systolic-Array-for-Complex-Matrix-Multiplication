`timescale 1ns / 1ps
`define WL_IP 15
`define FWL_IP 13
`define WL_OP 14
`define FWL_OP 11

// WL & FWL in every stage
`define WL_1 15
`define FWL_1 12  
`define WL_2 15
`define FWL_2 12
`define WL_3 15
`define FWL_3 12
`define WL_4 15
`define FWL_4 12
`define WL_5 16
`define FWL_5 13
`define WL_6 16
`define FWL_6 13
`define WL_7 16
`define FWL_7 13
    
// Systolic Array Module
module systolic (
    input wire clk,
    input wire rst,
    // A matrix I/P (Re)
    input wire signed [`WL_IP-1:0] A_real_in_11, A_real_in_21, A_real_in_31, A_real_in_41,
    input wire signed [`WL_IP-1:0] A_real_in_12, A_real_in_22, A_real_in_32, A_real_in_42,
    input wire signed [`WL_IP-1:0] A_real_in_13, A_real_in_23, A_real_in_33, A_real_in_43,
    input wire signed [`WL_IP-1:0] A_real_in_14, A_real_in_24, A_real_in_34, A_real_in_44,
    // A matrix I/P (Im)
    input wire signed [`WL_IP-1:0] A_imag_in_11, A_imag_in_21, A_imag_in_31, A_imag_in_41,
    input wire signed [`WL_IP-1:0] A_imag_in_12, A_imag_in_22, A_imag_in_32, A_imag_in_42,
    input wire signed [`WL_IP-1:0] A_imag_in_13, A_imag_in_23, A_imag_in_33, A_imag_in_43,
    input wire signed [`WL_IP-1:0] A_imag_in_14, A_imag_in_24, A_imag_in_34, A_imag_in_44,
    // B matrix I/P (Re)
    input wire signed [`WL_IP-1:0] B_real_in_11, B_real_in_12, B_real_in_13, B_real_in_14,
    input wire signed [`WL_IP-1:0] B_real_in_21, B_real_in_22, B_real_in_23, B_real_in_24,
    input wire signed [`WL_IP-1:0] B_real_in_31, B_real_in_32, B_real_in_33, B_real_in_34,
    input wire signed [`WL_IP-1:0] B_real_in_41, B_real_in_42, B_real_in_43, B_real_in_44,
    // B matrix I/P (Im)
    input wire signed [`WL_IP-1:0] B_imag_in_11, B_imag_in_12, B_imag_in_13, B_imag_in_14,
    input wire signed [`WL_IP-1:0] B_imag_in_21, B_imag_in_22, B_imag_in_23, B_imag_in_24,
    input wire signed [`WL_IP-1:0] B_imag_in_31, B_imag_in_32, B_imag_in_33, B_imag_in_34,
    input wire signed [`WL_IP-1:0] B_imag_in_41, B_imag_in_42, B_imag_in_43, B_imag_in_44,

    // C matrix O/P (Re)
    output wire signed [`WL_OP-1:0] C_real_out_11, C_real_out_12, C_real_out_13, C_real_out_14,
    output wire signed [`WL_OP-1:0] C_real_out_21, C_real_out_22, C_real_out_23, C_real_out_24,
    output wire signed [`WL_OP-1:0] C_real_out_31, C_real_out_32, C_real_out_33, C_real_out_34,
    output wire signed [`WL_OP-1:0] C_real_out_41, C_real_out_42, C_real_out_43, C_real_out_44,
    // C matrix O/P (Im)
    output wire signed [`WL_OP-1:0] C_imag_out_11, C_imag_out_12, C_imag_out_13, C_imag_out_14,
    output wire signed [`WL_OP-1:0] C_imag_out_21, C_imag_out_22, C_imag_out_23, C_imag_out_24,
    output wire signed [`WL_OP-1:0] C_imag_out_31, C_imag_out_32, C_imag_out_33, C_imag_out_34,
    output wire signed [`WL_OP-1:0] C_imag_out_41, C_imag_out_42, C_imag_out_43, C_imag_out_44
);

    // Stage 1: PU(1,1)
    wire signed [`WL_1-1:0] acc_r_11, acc_i_11;

    // Stage 2: PU(1,2), PU(2,1)
    wire signed [`WL_2-1:0] acc_r_12, acc_i_12;
    wire signed [`WL_2-1:0] acc_r_21, acc_i_21;

    // Stage 3: PU(1,3), PU(2,2), PU(3,1)
    wire signed [`WL_3-1:0] acc_r_13, acc_i_13;
    wire signed [`WL_3-1:0] acc_r_22, acc_i_22;
    wire signed [`WL_3-1:0] acc_r_31, acc_i_31;

    // Stage 4: PU(1,4), PU(2,3), PU(3,2), PU(4,1)
    wire signed [`WL_4-1:0] acc_r_14, acc_i_14;
    wire signed [`WL_4-1:0] acc_r_23, acc_i_23;
    wire signed [`WL_4-1:0] acc_r_32, acc_i_32;
    wire signed [`WL_4-1:0] acc_r_41, acc_i_41;
    
    // Stage 5: PU(2,4), PU(3,3), PU(4,2)
    wire signed [`WL_5-1:0] acc_r_24, acc_i_24;
    wire signed [`WL_5-1:0] acc_r_33, acc_i_33;
    wire signed [`WL_5-1:0] acc_r_42, acc_i_42;
    
    // Stage 6: PU(3,4), PU(4,3)
    wire signed [`WL_6-1:0] acc_r_34, acc_i_34;
    wire signed [`WL_6-1:0] acc_r_43, acc_i_43;
    
    // Stage 7: PU(4,4)
    wire signed [`WL_7-1:0] acc_r_44, acc_i_44;
    
    // wire out for connact with PE and reg
    wire signed [`WL_IP-1:0] ar_11, ai_11, br_11, bi_11;
    wire signed [`WL_IP-1:0] ar_21, ai_21, br_21, bi_21;
    wire signed [`WL_IP-1:0] ar_31, ai_31, br_31, bi_31;
    wire signed [`WL_IP-1:0] ar_41, ai_41, br_41, bi_41;

    wire signed [`WL_IP-1:0] ar_12, ai_12, br_12, bi_12;
    wire signed [`WL_IP-1:0] ar_22, ai_22, br_22, bi_22;
    wire signed [`WL_IP-1:0] ar_32, ai_32, br_32, bi_32;
    wire signed [`WL_IP-1:0] ar_42, ai_42, br_42, bi_42;

    wire signed [`WL_IP-1:0] ar_13, ai_13, br_13, bi_13;
    wire signed [`WL_IP-1:0] ar_23, ai_23, br_23, bi_23;
    wire signed [`WL_IP-1:0] ar_33, ai_33, br_33, bi_33;
    wire signed [`WL_IP-1:0] ar_43, ai_43, br_43, bi_43;

    wire signed [`WL_IP-1:0] ar_14, ai_14, br_14, bi_14;
    wire signed [`WL_IP-1:0] ar_24, ai_24, br_24, bi_24;
    wire signed [`WL_IP-1:0] ar_34, ai_34, br_34, bi_34;
    wire signed [`WL_IP-1:0] ar_44, ai_44, br_44, bi_44;

    // reg for bypass
    reg signed [`WL_IP-1:0] ar_11_reg, ai_11_reg, br_11_reg, bi_11_reg;
    reg signed [`WL_IP-1:0] ar_21_reg, ai_21_reg, br_21_reg, bi_21_reg;
    reg signed [`WL_IP-1:0] ar_31_reg, ai_31_reg, br_31_reg, bi_31_reg;
    reg signed [`WL_IP-1:0] ar_41_reg, ai_41_reg, br_41_reg, bi_41_reg;
    reg signed [`WL_IP-1:0] ar_12_reg, ai_12_reg, br_12_reg, bi_12_reg;
    reg signed [`WL_IP-1:0] ar_22_reg, ai_22_reg, br_22_reg, bi_22_reg;
    reg signed [`WL_IP-1:0] ar_32_reg, ai_32_reg, br_32_reg, bi_32_reg;
    reg signed [`WL_IP-1:0] ar_42_reg, ai_42_reg, br_42_reg, bi_42_reg;
    reg signed [`WL_IP-1:0] ar_13_reg, ai_13_reg, br_13_reg, bi_13_reg;
    reg signed [`WL_IP-1:0] ar_23_reg, ai_23_reg, br_23_reg, bi_23_reg;
    reg signed [`WL_IP-1:0] ar_33_reg, ai_33_reg, br_33_reg, bi_33_reg;
    reg signed [`WL_IP-1:0] ar_43_reg, ai_43_reg, br_43_reg, bi_43_reg;
    reg signed [`WL_IP-1:0] ar_14_reg, ai_14_reg, br_14_reg, bi_14_reg;
    reg signed [`WL_IP-1:0] ar_24_reg, ai_24_reg, br_24_reg, bi_24_reg;
    reg signed [`WL_IP-1:0] ar_34_reg, ai_34_reg, br_34_reg, bi_34_reg;
    reg signed [`WL_IP-1:0] ar_44_reg, ai_44_reg, br_44_reg, bi_44_reg;

    reg [3:0] cycle_cnt;
    reg cnt_enab;

    // data flow control
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cycle_cnt <= 0;
            cnt_enab <= 0;

            // Stage 1
            ar_11_reg <= 0;
            ai_11_reg <= 0;
            br_11_reg <= 0;
            bi_11_reg <= 0;
            
            // Stage 2
            ar_12_reg <= 0;
            ai_12_reg <= 0;
            br_21_reg <= 0;
            bi_21_reg <= 0;
            ar_21_reg <= 0;
            ai_21_reg <= 0;
            br_12_reg <= 0;
            bi_12_reg <= 0;

            // Stage 3
            ar_13_reg <= 0;
            ai_13_reg <= 0;
            br_31_reg <= 0;
            bi_31_reg <= 0;
            ar_22_reg <= 0;
            ai_22_reg <= 0;
            br_22_reg <= 0;
            bi_22_reg <= 0;
            ar_31_reg <= 0;
            ai_31_reg <= 0;
            br_13_reg <= 0;
            bi_13_reg <= 0;

            // Stage 4
            ar_14_reg <= 0;
            ai_14_reg <= 0;
            br_41_reg <= 0;
            bi_41_reg <= 0;
            ar_23_reg <= 0;
            ai_23_reg <= 0;
            br_32_reg <= 0;
            bi_32_reg <= 0;
            ar_32_reg <= 0;
            ai_32_reg <= 0;
            br_23_reg <= 0;
            bi_23_reg <= 0;
            ar_41_reg <= 0;
            ai_41_reg <= 0;
            br_14_reg <= 0;
            bi_14_reg <= 0;

            // Stage 5
            ar_24_reg <= 0;
            ai_24_reg <= 0;
            br_42_reg <= 0;
            bi_42_reg <= 0;

            // Stage 6
            ar_34_reg <= 0;
            ai_34_reg <= 0;
            br_43_reg <= 0;
            bi_43_reg <= 0;
            ar_43_reg <= 0; 
            ai_43_reg <= 0;
            br_34_reg <= 0;
            bi_34_reg <= 0;

            // Stage 7
            ar_44_reg <= 0;
            ai_44_reg <= 0;
            br_44_reg <= 0;
            bi_44_reg <= 0;

        end else begin

            if (cycle_cnt == 0) begin
                cnt_enab <= 1;
            end

            if (cnt_enab) begin
                cycle_cnt <= cycle_cnt + 1;

                case (cycle_cnt)
                    1:begin
                        ar_11_reg <= A_real_in_11;
                        ai_11_reg <= A_imag_in_11;
                        br_11_reg <= B_real_in_11;
                        bi_11_reg <= B_imag_in_11;

                        ar_21_reg <= 0;
                        ai_21_reg <= 0;
 
                        br_12_reg <= 0;
                        bi_12_reg <= 0;

                        ar_31_reg <= 0;
                        ai_31_reg <= 0;

                        br_13_reg <= 0;
                        bi_13_reg <= 0;  

                        ar_41_reg <= 0;
                        ai_41_reg <= 0;

                        br_14_reg <= 0;
                        bi_14_reg <= 0;
                    end
                    2:begin
                        ar_11_reg <= A_real_in_12;
                        ai_11_reg <= A_imag_in_12;
                        br_11_reg <= B_real_in_21;
                        bi_11_reg <= B_imag_in_21;

                        ar_21_reg <= A_real_in_21;
                        ai_21_reg <= A_imag_in_21;
 
                        br_12_reg <= B_real_in_12;
                        bi_12_reg <= B_imag_in_12;

                        ar_31_reg <= 0;
                        ai_31_reg <= 0;

                        br_13_reg <= 0;
                        bi_13_reg <= 0;  

                        ar_41_reg <= 0;
                        ai_41_reg <= 0;

                        br_14_reg <= 0;
                        bi_14_reg <= 0;
                    end
                    3:begin
                        ar_11_reg <= A_real_in_13;
                        ai_11_reg <= A_imag_in_13;
                        br_11_reg <= B_real_in_31;
                        bi_11_reg <= B_imag_in_31;

                        ar_21_reg <= A_real_in_22;
                        ai_21_reg <= A_imag_in_22;
 
                        br_12_reg <= B_real_in_22;
                        bi_12_reg <= B_imag_in_22;

                        ar_31_reg <= A_real_in_31;
                        ai_31_reg <= A_imag_in_31;

                        br_13_reg <= B_real_in_13;
                        bi_13_reg <= B_imag_in_13;

                        ar_41_reg <= 0;
                        ai_41_reg <= 0;

                        br_14_reg <= 0;
                        bi_14_reg <= 0;
                    end
                    4:begin
                        ar_11_reg <= A_real_in_14;
                        ai_11_reg <= A_imag_in_14;
                        br_11_reg <= B_real_in_41;
                        bi_11_reg <= B_imag_in_41;

                        ar_21_reg <= A_real_in_23;
                        ai_21_reg <= A_imag_in_23;
 
                        br_12_reg <= B_real_in_32;
                        bi_12_reg <= B_imag_in_32;

                        ar_31_reg <= A_real_in_32;
                        ai_31_reg <= A_imag_in_32;

                        br_13_reg <= B_real_in_23;
                        bi_13_reg <= B_imag_in_23;  

                        ar_41_reg <= A_real_in_41;
                        ai_41_reg <= A_imag_in_41;

                        br_14_reg <= B_real_in_14;
                        bi_14_reg <= B_imag_in_14; 
                    end
                    5: begin 
                        ar_11_reg <= 0;
                        ai_11_reg <= 0;
                        br_11_reg <= 0;
                        bi_11_reg <= 0;

                        ar_21_reg <= A_real_in_24;
                        ai_21_reg <= A_imag_in_24;
 
                        br_12_reg <= B_real_in_42;
                        bi_12_reg <= B_imag_in_42;

                        ar_31_reg <= A_real_in_33;
                        ai_31_reg <= A_imag_in_33;

                        br_13_reg <= B_real_in_33;
                        bi_13_reg <= B_imag_in_33;  

                        ar_41_reg <= A_real_in_42;
                        ai_41_reg <= A_imag_in_42;

                        br_14_reg <= B_real_in_24;
                        bi_14_reg <= B_imag_in_24; 
                    end
                    6:begin
                        ar_11_reg <= 0;
                        ai_11_reg <= 0;
                        br_11_reg <= 0;
                        bi_11_reg <= 0;

                        ar_21_reg <= 0;
                        ai_21_reg <= 0;
 
                        br_12_reg <= 0;
                        bi_12_reg <= 0;

                        ar_31_reg <= A_real_in_34;
                        ai_31_reg <= A_imag_in_34;

                        br_13_reg <= B_real_in_43;
                        bi_13_reg <= B_imag_in_43;  

                        ar_41_reg <= A_real_in_43;
                        ai_41_reg <= A_imag_in_43;

                        br_14_reg <= B_real_in_34;
                        bi_14_reg <= B_imag_in_34;
                    end
                    7:begin
                        cnt_enab <= 0;
                        ar_11_reg <= 0;
                        ai_11_reg <= 0;
                        br_11_reg <= 0;
                        bi_11_reg <= 0;

                        ar_21_reg <= 0;
                        ai_21_reg <= 0;
 
                        br_12_reg <= 0;
                        bi_12_reg <= 0;

                        ar_31_reg <= 0;
                        ai_31_reg <= 0;

                        br_13_reg <= 0;
                        bi_13_reg <= 0;  

                        ar_41_reg <= A_real_in_44;
                        ai_41_reg <= A_imag_in_44;

                        br_14_reg <= B_real_in_44;
                        bi_14_reg <= B_imag_in_44;
                    end
                    default: begin
                        ar_11_reg <= 0;
                        ai_11_reg <= 0;
                        br_11_reg <= 0;
                        bi_11_reg <= 0;

                        ar_21_reg <= 0;
                        ai_21_reg <= 0;
 
                        br_12_reg <= 0;
                        bi_12_reg <= 0;

                        ar_31_reg <= 0;
                        ai_31_reg <= 0;

                        br_13_reg <= 0;
                        bi_13_reg <= 0;  

                        ar_41_reg <= 0;
                        ai_41_reg <= 0;

                        br_14_reg <= 0;
                        bi_14_reg <= 0;
                    end
                endcase
            end

        end
    end

    // reg gives in while wire gets out
    PE #(
        .WL_IN(`WL_IP), .FWL_IN(`FWL_IP),
        .WL_OUT(`WL_1), .FWL_OUT(`FWL_1),
        .STAGE_DELAY(0)
    ) pe_11 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_11_reg),
        .ai_in(ai_11_reg),
        .br_in(br_11_reg),
        .bi_in(bi_11_reg),
        .ar_out(ar_11),
        .ai_out(ai_11),
        .br_out(br_11),
        .bi_out(bi_11),
        .acc_r(acc_r_11),
        .acc_i(acc_i_11)
    );

    always @(*) begin
        ar_12_reg = ar_11;
        ai_12_reg  = ai_11;
        br_21_reg  = br_11;
        bi_21_reg  = bi_11;
    end

    // Stage 2: PU(1,2), PU(2,1)
    // PU(1,2)
    PE #(
        .WL_IN(`WL_1), .FWL_IN(`FWL_1),
        .WL_OUT(`WL_2), .FWL_OUT(`FWL_2),
        .STAGE_DELAY(1)
    ) pe_12 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_12_reg),
        .ai_in(ai_12_reg),
        .br_in(br_12_reg),
        .bi_in(bi_12_reg),
        .ar_out(ar_12),
        .ai_out(ai_12),
        .br_out(br_12),
        .bi_out(bi_12),
        .acc_r(acc_r_12),
        .acc_i(acc_i_12)
    );

    always @(*) begin
        ar_13_reg = ar_12;
        ai_13_reg = ai_12;
        br_22_reg = br_12;
        bi_22_reg = bi_12;
    end

    // PU(2,1)
    PE #(
        .WL_IN(`WL_1), .FWL_IN(`FWL_1),
        .WL_OUT(`WL_2), .FWL_OUT(`FWL_2),
        .STAGE_DELAY(1)
    ) pe_21 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_21_reg),
        .ai_in(ai_21_reg),
        .br_in(br_21_reg),
        .bi_in(bi_21_reg),
        .ar_out(ar_21),
        .ai_out(ai_21),
        .br_out(br_21),
        .bi_out(bi_21),
        .acc_r(acc_r_21),
        .acc_i(acc_i_21)
    );
    always @(*) begin
        ar_22_reg = ar_21;
        ai_22_reg = ai_21;
        br_31_reg = br_21;
        bi_31_reg = bi_21;
    end
    // Stage 3: PU(1,3), PU(2,2), PU(3,1)
    // PU(1,3)
    PE #(
        .WL_IN(`WL_2), .FWL_IN(`FWL_2),
        .WL_OUT(`WL_3), .FWL_OUT(`FWL_3),
        .STAGE_DELAY(2) 
    ) pe_13 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_13_reg),
        .ai_in(ai_13_reg),
        .br_in(br_13_reg),
        .bi_in(bi_13_reg),
        .ar_out(ar_13),
        .ai_out(ai_13),
        .br_out(br_13),
        .bi_out(bi_13),
        .acc_r(acc_r_13),
        .acc_i(acc_i_13)
    );
    always @(*) begin
        ar_14_reg = ar_13;
        ai_14_reg = ai_13;
        br_23_reg = br_13;
        bi_23_reg = bi_13;
    end
    
    // PU(2,2)
    PE #(
        .WL_IN(`WL_2), .FWL_IN(`FWL_2),
        .WL_OUT(`WL_3), .FWL_OUT(`FWL_3),
        .STAGE_DELAY(2)
    ) pe_22 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_22_reg),
        .ai_in(ai_22_reg),
        .br_in(br_22_reg),
        .bi_in(bi_22_reg),
        .ar_out(ar_22),
        .ai_out(ai_22),
        .br_out(br_22),
        .bi_out(bi_22),
        .acc_r(acc_r_22),
        .acc_i(acc_i_22)
    );
    always @(*) begin
        ar_23_reg = ar_22;
        ai_23_reg = ai_22;
        br_32_reg = br_22;
        bi_32_reg = bi_22;
    end
    
    PE #(
        .WL_IN(`WL_2), .FWL_IN(`FWL_2),
        .WL_OUT(`WL_3), .FWL_OUT(`FWL_3),
        .STAGE_DELAY(2)
    ) pe_31 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_31_reg),
        .ai_in(ai_31_reg),
        .br_in(br_31_reg),
        .bi_in(bi_31_reg),
        .ar_out(ar_31),
        .ai_out(ai_31),
        .br_out(br_31),
        .bi_out(bi_31),
        .acc_r(acc_r_31),
        .acc_i(acc_i_31)
    );
    always @(*) begin
        ar_32_reg = ar_31;
        ai_32_reg = ai_31;
        br_41_reg = br_31;
        bi_41_reg = bi_31;
    end

    // Stage 4: PU(1,4), PU(2,3), PU(3,2), PU(4,1)
    // PU(1,4)
    PE #(
        .WL_IN(`WL_3), .FWL_IN(`FWL_3),
        .WL_OUT(`WL_4), .FWL_OUT(`FWL_4),
        .STAGE_DELAY(3)
    ) pe_14 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_14_reg),
        .ai_in(ai_14_reg),
        .br_in(br_14_reg),
        .bi_in(bi_14_reg),
        .ar_out(),
        .ai_out(),
        .br_out(br_14),
        .bi_out(bi_14),
        .acc_r(acc_r_14),
        .acc_i(acc_i_14)
    );
    always @(*) begin
        br_24_reg = br_14;
        bi_24_reg = bi_14;
    end
    
    // PU(2,3)
    PE #(
        .WL_IN(`WL_3), .FWL_IN(`FWL_3),
        .WL_OUT(`WL_4), .FWL_OUT(`FWL_4),
        .STAGE_DELAY(3)
    ) pe_23 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_23_reg),
        .ai_in(ai_23_reg),
        .br_in(br_23_reg),
        .bi_in(bi_23_reg),
        .ar_out(ar_23),
        .ai_out(ai_23),
        .br_out(br_23),
        .bi_out(bi_23),
        .acc_r(acc_r_23),
        .acc_i(acc_i_23)
    );
    always @(*) begin
        ar_24_reg = ar_23;
        ai_24_reg = ai_23;
        br_33_reg = br_23;
        bi_33_reg = bi_23;
    end
    
    // PU(3,2)
    PE #(
        .WL_IN(`WL_3), .FWL_IN(`FWL_3),
        .WL_OUT(`WL_4), .FWL_OUT(`FWL_4),
        .STAGE_DELAY(3)
    ) pe_32 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_32_reg),
        .ai_in(ai_32_reg),
        .br_in(br_32_reg),
        .bi_in(bi_32_reg),
        .ar_out(ar_32),
        .ai_out(ai_32),
        .br_out(br_32),
        .bi_out(bi_32),
        .acc_r(acc_r_32),
        .acc_i(acc_i_32)
    );
    always @(*) begin
        ar_33_reg = ar_32;
        ai_33_reg = ai_32;
        br_42_reg = br_32;
        bi_42_reg = bi_32;
    end
    
    // PU(4,1)
    PE #(
        .WL_IN(`WL_3), .FWL_IN(`FWL_3),
        .WL_OUT(`WL_4), .FWL_OUT(`FWL_4),
        .STAGE_DELAY(3)
    ) pe_41 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_41_reg),
        .ai_in(ai_41_reg),
        .br_in(br_41_reg),
        .bi_in(bi_41_reg),
        .ar_out(ar_41),
        .ai_out(ai_41),
        .br_out(),
        .bi_out(),
        .acc_r(acc_r_41),
        .acc_i(acc_i_41)
    );
    always @(*) begin
        ar_42_reg = ar_41;
        ai_42_reg = ai_41;
    end

    // Stage 5: PU(2,4), PU(3,3), PU(4,2)
    // PU(2,4)
    PE #(
        .WL_IN(`WL_4), .FWL_IN(`FWL_4),
        .WL_OUT(`WL_5), .FWL_OUT(`FWL_5),
        .STAGE_DELAY(4)
    ) pe_24 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_24_reg),
        .ai_in(ai_24_reg),
        .br_in(br_24_reg),
        .bi_in(bi_24_reg),
        .ar_out(),
        .ai_out(),
        .br_out(br_24),
        .bi_out(bi_24),
        .acc_r(acc_r_24),
        .acc_i(acc_i_24)
    );
    always @(*) begin
        br_34_reg = br_24;
        bi_34_reg = bi_24;
    end

    // PU(3,3)
    PE #(
        .WL_IN(`WL_4), .FWL_IN(`FWL_4),
        .WL_OUT(`WL_5), .FWL_OUT(`FWL_5),
        .STAGE_DELAY(4)
    ) pe_33 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_33_reg),
        .ai_in(ai_33_reg),
        .br_in(br_33_reg),
        .bi_in(bi_33_reg),
        .ar_out(ar_33),
        .ai_out(ai_33),
        .br_out(br_33),
        .bi_out(bi_33),
        .acc_r(acc_r_33),
        .acc_i(acc_i_33)
    );
    always @(*) begin
        ar_34_reg = ar_33;
        ai_34_reg = ai_33;
        br_43_reg = br_33;
        bi_43_reg = bi_33;
    end

    // PU(4,2)
    PE #(
        .WL_IN(`WL_4), .FWL_IN(`FWL_4),
        .WL_OUT(`WL_5), .FWL_OUT(`FWL_5),
        .STAGE_DELAY(4)
    ) pe_42 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_42_reg),
        .ai_in(ai_42_reg),
        .br_in(br_42_reg),
        .bi_in(bi_42_reg),
        .ar_out(ar_42),
        .ai_out(ai_42),
        .br_out(),
        .bi_out(),
        .acc_r(acc_r_42),
        .acc_i(acc_i_42)
    );
    always @(*) begin
        ar_43_reg = ar_42;
        ai_43_reg = ai_42;
    end

    // Stage 6: PU(3,4), PU(4,3)
    // PU(3,4)
    PE #(
        .WL_IN(`WL_5), .FWL_IN(`FWL_5),
        .WL_OUT(`WL_6), .FWL_OUT(`FWL_6),
        .STAGE_DELAY(5)
    ) pe_34 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_34_reg),
        .ai_in(ai_34_reg),
        .br_in(br_34_reg),
        .bi_in(bi_34_reg),
        .ar_out(),
        .ai_out(),
        .br_out(br_34),
        .bi_out(bi_34),
        .acc_r(acc_r_34),
        .acc_i(acc_i_34)
    );
     always @(*) begin
        br_44_reg = br_34;
        bi_44_reg = bi_34;
    end

    // PU(4,3)
    PE #(
        .WL_IN(`WL_5), .FWL_IN(`FWL_5),
        .WL_OUT(`WL_6), .FWL_OUT(`FWL_6),
        .STAGE_DELAY(5)
    ) pe_43 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_43_reg),
        .ai_in(ai_43_reg),
        .br_in(br_43_reg),
        .bi_in(bi_43_reg),
        .ar_out(ar_43),
        .ai_out(ai_43),
        .br_out(),
        .bi_out(),
        .acc_r(acc_r_43),
        .acc_i(acc_i_43)
    );
     always @(*) begin
        ar_44_reg = ar_43;
        ai_44_reg = ai_43;
    end

    // Stage 7: PU(4,4)
    PE #(
        .WL_IN(`WL_6), .FWL_IN(`FWL_6),
        .WL_OUT(`WL_7), .FWL_OUT(`FWL_7),
        .STAGE_DELAY(6)
    ) pe_44 (
        .clk(clk),
        .rst(rst),
        .ar_in(ar_44_reg),
        .ai_in(ai_44_reg),
        .br_in(br_44_reg),
        .bi_in(bi_44_reg),
        .ar_out(),
        .ai_out(),
        .br_out(),
        .bi_out(),
        .acc_r(acc_r_44),
        .acc_i(acc_i_44)
    );

    // O/P
    assign C_real_out_11 = acc_r_11;
    assign C_imag_out_11 = acc_i_11;
    assign C_real_out_12 = acc_r_12;
    assign C_imag_out_12 = acc_i_12;
    assign C_real_out_13 = acc_r_13;
    assign C_imag_out_13 = acc_i_13;
    assign C_real_out_14 = acc_r_14;
    assign C_imag_out_14 = acc_i_14;

    assign C_real_out_21 = acc_r_21;
    assign C_imag_out_21 = acc_i_21;
    assign C_real_out_22 = acc_r_22;
    assign C_imag_out_22 = acc_i_22;
    assign C_real_out_23 = acc_r_23;
    assign C_imag_out_23 = acc_i_23;
    assign C_real_out_24 = acc_r_24;
    assign C_imag_out_24 = acc_i_24;

    assign C_real_out_31 = acc_r_31;
    assign C_imag_out_31 = acc_i_31;
    assign C_real_out_32 = acc_r_32;
    assign C_imag_out_32 = acc_i_32;
    assign C_real_out_33 = acc_r_33;
    assign C_imag_out_33 = acc_i_33;
    assign C_real_out_34 = acc_r_34;
    assign C_imag_out_34 = acc_i_34;

    assign C_real_out_41 = acc_r_41;
    assign C_imag_out_41 = acc_i_41;
    assign C_real_out_42 = acc_r_42;
    assign C_imag_out_42 = acc_i_42;
    assign C_real_out_43 = acc_r_43;
    assign C_imag_out_43 = acc_i_43;
    assign C_real_out_44 = acc_r_44;
    assign C_imag_out_44 = acc_i_44;

endmodule