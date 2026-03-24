`timescale 1ns / 1ps
`define COMPUTE_CYCLES 4
`define WL_IP 15
`define FWL_IP 13

module PE #(
    parameter WL_IN = 12,
    parameter FWL_IN = 10,
    parameter WL_OUT = 14,
    parameter FWL_OUT = 11,
    parameter STAGE_DELAY = 0 // systolic stage delay
)(
    input wire clk,
    input wire rst,

    input wire signed [WL_IN-1:0] ar_in,
    input wire signed [WL_IN-1:0] ai_in,
    input wire signed [WL_IN-1:0] br_in,
    input wire signed [WL_IN-1:0] bi_in,

    output reg signed [WL_IN-1:0] ar_out,
    output reg signed [WL_IN-1:0] ai_out,
    output reg signed [WL_IN-1:0] br_out,
    output reg signed [WL_IN-1:0] bi_out,

    output reg signed [WL_OUT+WL_OUT-1:0] acc_r,
    output reg signed [WL_OUT+WL_OUT-1:0] acc_i
);
    /*wire signed [WL_IN+WL_IN-1:0] ar_shift, ai_shift, br_shift, bi_shift;
    assign ar_shift = (`FWL_IP > FWL_IN)? 
                    ar_in * (1 << (`FWL_IP - FWL_IN)): 
                    ar_in * (1 << (FWL_IN - `FWL_IP));
    assign ai_shift = (`FWL_IP > FWL_IN)? 
                    ai_in * (1 << (`FWL_IP - FWL_IN)): 
                    ai_in * (1 << (FWL_IN - `FWL_IP));
    assign br_shift = (`FWL_IP > FWL_IN)? 
                    br_in * (1 << (`FWL_IP - FWL_IN)): 
                    br_in * (1 << (FWL_IN - `FWL_IP));
    assign bi_shift = (`FWL_IP > FWL_IN)? 
                    bi_in * (1 << (`FWL_IP - FWL_IN)): 
                    bi_in * (1 << (FWL_IN - `FWL_IP));
    */

    // Multi
    wire signed [WL_IN+WL_IN-1:0] arxbr, arxbi, aixbr, aixbi;
    /*assign arxbr = ar_shift * br_shift;
    assign arxbi = ar_shift * bi_shift;
    assign aixbr = ai_shift * br_shift;
    assign aixbi = ai_shift * bi_shift;
    */
    assign arxbr = ar_in * br_in;
    assign arxbi = ar_in * bi_in;
    assign aixbr = ai_in * br_in;
    assign aixbi = ai_in * bi_in;

    wire [3:0] IP_diff;
    assign IP_diff = (`FWL_IP > FWL_IN)? (`FWL_IP - FWL_IN) : (FWL_IN - `FWL_IP);

    // Shift Re & Im
    wire signed [WL_OUT+WL_OUT-1:0] re_mult, im_mult;
    assign re_mult = (arxbr - aixbi) >>> (IP_diff + FWL_IN + FWL_IN - FWL_OUT);
    assign im_mult = (arxbi + aixbr) >>> (IP_diff + FWL_IN + FWL_IN - FWL_OUT); 
    //assign re_mult = (arxbr - aixbi);
    //assign im_mult = (arxbi + aixbr); 

    // Internal counters
    wire [3:0] delay_counter;
    reg [3:0] compute_counter;
    reg [3:0] cycle_count;
    //reg compute_done;
    wire start_compute;
    wire input_zero;
    wire stage_complete;

    assign input_zero = (ar_in == 0) && (ai_in == 0) && (br_in == 0) && (bi_in == 0);
    assign start_compute = (!input_zero)? 1: 0;
    assign stage_complete = (cycle_count == 4)? 1 : 0 ;  // 每4個cycle完成一個stage

    // delay_counter
    assign delay_counter = (stage_complete)? 0 : STAGE_DELAY; 


    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset state
            ar_out <= 0;
            ai_out <= 0;
            br_out <= 0;
            bi_out <= 0;
            acc_r <= 0;
            acc_i <= 0;
            cycle_count <= 0;
            //compute_done <= 0;
            compute_counter <= 0;
        end else begin
            // Always propagate inputs to outputs
            ar_out <= ar_in;
            ai_out <= ai_in;
            br_out <= br_in;
            bi_out <= bi_in;

            // Delay control for systolic wave
            if (delay_counter == STAGE_DELAY) begin
                if (start_compute) begin
                    if (cycle_count == 0) begin
                        acc_r <= re_mult;
                        acc_i <= im_mult;
                        compute_counter <= 1;
                        cycle_count <= 1;
                    end else begin
                        acc_r <= acc_r + re_mult;
                        acc_i <= acc_i + im_mult;
                        compute_counter <= compute_counter + 1;
                        cycle_count <= cycle_count + 1;
                    end

                end else begin
                    // 保持最終結果
                    acc_r <= acc_r;
                    acc_i <= acc_i;
                    compute_counter <= 0;
                    cycle_count <= 0;
                end
            end   
        end
    end

endmodule
