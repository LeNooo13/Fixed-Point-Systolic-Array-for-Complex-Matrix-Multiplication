`timescale 1ns/1ps
`define WL_IP 12
`define FWL_IP 10

module systolic_tb;

    // Clock and Reset
    reg clk;
    reg rst;

    // Parameters
    parameter N = 4;
    real error_threshold = 0.01;
    integer error_count = 0;

    // Input and output signals
    reg signed [`WL_IP-1:0] A_real [0:N-1][0:N-1];
    reg signed [`WL_IP-1:0] A_imag [0:N-1][0:N-1];
    reg signed [`WL_IP-1:0] B_real [0:N-1][0:N-1];
    reg signed [`WL_IP-1:0] B_imag [0:N-1][0:N-1];

    wire signed [27:0] C_real [0:N-1][0:N-1];  // acc_r
    wire signed [27:0] C_imag [0:N-1][0:N-1];  // acc_i

    // Float reference
    real A_r_f[0:N-1][0:N-1], A_i_f[0:N-1][0:N-1];
    real B_r_f[0:N-1][0:N-1], B_i_f[0:N-1][0:N-1];
    real C_ref_r[0:N-1][0:N-1], C_ref_i[0:N-1][0:N-1];

    integer i, j, k;
    real out_r, out_i,ref_r,ref_i;

    // Clock generation
    always #5 clk = ~clk;

    // Dump fsdb file
    initial begin
        $fsdbDumpfile("systolic_rtb.fsdb");
        $fsdbDumpvars(0, systolic_tb);
    end

    // rtl
    systolic dut (
        .clk(clk),
        .rst(rst),
        .A_real_in_11(A_real[0][0]), .A_imag_in_11(A_imag[0][0]),
        .A_real_in_12(A_real[0][1]), .A_imag_in_12(A_imag[0][1]),
        .A_real_in_13(A_real[0][2]), .A_imag_in_13(A_imag[0][2]),
        .A_real_in_14(A_real[0][3]), .A_imag_in_14(A_imag[0][3]),
        .A_real_in_21(A_real[1][0]), .A_imag_in_21(A_imag[1][0]),
        .A_real_in_22(A_real[1][1]), .A_imag_in_22(A_imag[1][1]),
        .A_real_in_23(A_real[1][2]), .A_imag_in_23(A_imag[1][2]),
        .A_real_in_24(A_real[1][3]), .A_imag_in_24(A_imag[1][3]),
        .A_real_in_31(A_real[2][0]), .A_imag_in_31(A_imag[2][0]),
        .A_real_in_32(A_real[2][1]), .A_imag_in_32(A_imag[2][1]),
        .A_real_in_33(A_real[2][2]), .A_imag_in_33(A_imag[2][2]),
        .A_real_in_34(A_real[2][3]), .A_imag_in_34(A_imag[2][3]),
        .A_real_in_41(A_real[3][0]), .A_imag_in_41(A_imag[3][0]),
        .A_real_in_42(A_real[3][1]), .A_imag_in_42(A_imag[3][1]),
        .A_real_in_43(A_real[3][2]), .A_imag_in_43(A_imag[3][2]),
        .A_real_in_44(A_real[3][3]), .A_imag_in_44(A_imag[3][3]),
        .B_real_in_11(B_real[0][0]), .B_imag_in_11(B_imag[0][0]),
        .B_real_in_12(B_real[0][1]), .B_imag_in_12(B_imag[0][1]),
        .B_real_in_13(B_real[0][2]), .B_imag_in_13(B_imag[0][2]),
        .B_real_in_14(B_real[0][3]), .B_imag_in_14(B_imag[0][3]),
        .B_real_in_21(B_real[1][0]), .B_imag_in_21(B_imag[1][0]),
        .B_real_in_22(B_real[1][1]), .B_imag_in_22(B_imag[1][1]),
        .B_real_in_23(B_real[1][2]), .B_imag_in_23(B_imag[1][2]),
        .B_real_in_24(B_real[1][3]), .B_imag_in_24(B_imag[1][3]),
        .B_real_in_31(B_real[2][0]), .B_imag_in_31(B_imag[2][0]),
        .B_real_in_32(B_real[2][1]), .B_imag_in_32(B_imag[2][1]),
        .B_real_in_33(B_real[2][2]), .B_imag_in_33(B_imag[2][2]),
        .B_real_in_34(B_real[2][3]), .B_imag_in_34(B_imag[2][3]),
        .B_real_in_41(B_real[3][0]), .B_imag_in_41(B_imag[3][0]),
        .B_real_in_42(B_real[3][1]), .B_imag_in_42(B_imag[3][1]),
        .B_real_in_43(B_real[3][2]), .B_imag_in_43(B_imag[3][2]),
        .B_real_in_44(B_real[3][3]), .B_imag_in_44(B_imag[3][3]),
        .C_real_out_11(C_real[0][0]), .C_imag_out_11(C_imag[0][0]),
        .C_real_out_12(C_real[0][1]), .C_imag_out_12(C_imag[0][1]),
        .C_real_out_13(C_real[0][2]), .C_imag_out_13(C_imag[0][2]),
        .C_real_out_14(C_real[0][3]), .C_imag_out_14(C_imag[0][3]),
        .C_real_out_21(C_real[1][0]), .C_imag_out_21(C_imag[1][0]),
        .C_real_out_22(C_real[1][1]), .C_imag_out_22(C_imag[1][1]),
        .C_real_out_23(C_real[1][2]), .C_imag_out_23(C_imag[1][2]),
        .C_real_out_24(C_real[1][3]), .C_imag_out_24(C_imag[1][3]),
        .C_real_out_31(C_real[2][0]), .C_imag_out_31(C_imag[2][0]),
        .C_real_out_32(C_real[2][1]), .C_imag_out_32(C_imag[2][1]),
        .C_real_out_33(C_real[2][2]), .C_imag_out_33(C_imag[2][2]),
        .C_real_out_34(C_real[2][3]), .C_imag_out_34(C_imag[2][3]),
        .C_real_out_41(C_real[3][0]), .C_imag_out_41(C_imag[3][0]),
        .C_real_out_42(C_real[3][1]), .C_imag_out_42(C_imag[3][1]),
        .C_real_out_43(C_real[3][2]), .C_imag_out_43(C_imag[3][2]),
        .C_real_out_44(C_real[3][3]), .C_imag_out_44(C_imag[3][3])
    );

    // Fixed-point conversion
    function [`WL_IP-1:0] float_to_fixed;
        input real val;
        begin
            float_to_fixed = val * (1 << `FWL_IP);
        end
    endfunction

    function real fixed_to_float;
        input [`WL_IP-1:0] val;
        begin
            fixed_to_float = $itor(val) / (1 << `FWL_IP);
        end
    endfunction

    function real abs;
        input real x;
        begin
            abs = (x < 0) ? -x : x;
        end
    endfunction

    // Initialization
    initial begin
        clk = 1;
        rst = 1;

        // Fraction
        for (i = 0; i < N; i = i + 1)
            for (j = 0; j < N; j = j + 1) begin
                A_r_f[i][j] = 0.1 + i*0.1 + j*0.05;
                A_i_f[i][j] = 0.2 + j*0.5;
                B_r_f[i][j] = 1.0 - i*0.01 - j*0.05;
                B_i_f[i][j] = 1.0 + i*0.05;
                //A_r_f[i][j] = 1;
                //A_i_f[i][j] = 1;
                //B_r_f[i][j] = 1;
                //B_i_f[i][j] = 1;

                A_real[i][j] = float_to_fixed(A_r_f[i][j]);
                A_imag[i][j] = float_to_fixed(A_i_f[i][j]);
                B_real[i][j] = float_to_fixed(B_r_f[i][j]);
                B_imag[i][j] = float_to_fixed(B_i_f[i][j]);

                //A_real[i][j] = A_r_f[i][j];
                //A_imag[i][j] = A_i_f[i][j];
                //B_real[i][j] = B_r_f[i][j];
                //B_imag[i][j] = B_i_f[i][j];
            end

        // system reset
        #5  rst = 0;                            
        #10 rst = 1;

        // Wait
        #1000;

        // golden reference
        for (i = 0; i < N; i = i + 1)
            for (j = 0; j < N; j = j + 1) begin
                C_ref_r[i][j] = 0;
                C_ref_i[i][j] = 0;
                for (k = 0; k < N; k = k + 1) begin
                    C_ref_r[i][j] = C_ref_r[i][j] + A_r_f[i][k]*B_r_f[k][j] - A_i_f[i][k]*B_i_f[k][j];
                    C_ref_i[i][j] = C_ref_i[i][j] + A_r_f[i][k]*B_i_f[k][j] + A_i_f[i][k]*B_r_f[k][j];
                end
            end

        /*Compare Results
        $display("=== Matrix A (real + j imag) ===");
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                $display("A[%0d][%0d] = %f + j%f", i, j, A_r_f[i][j], A_i_f[i][j]);
            end
        end

        $display("=== Matrix B (real + j imag) ===");
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                $display("B[%0d][%0d] = %f + j%f", i, j, B_r_f[i][j], B_i_f[i][j]);
            end
        end

        $display("=== Output Comparison ===");
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                out_r = fixed_to_float(C_real[i][j]);
                out_i = fixed_to_float(C_imag[i][j]);
                ref_r = C_ref_r[i][j] /( 1 << `FWL_IP);
                ref_i = C_ref_i[i][j] /( 1 << `FWL_IP);
                
                //out_r = (C_real[i][j]);
                //out_i = (C_imag[i][j]);

                $display("C[%0d][%0d] = %f + j%f, Expected = %f + j%f", 
                    i, j, out_r, out_i, ref_r, ref_i);

                if ((abs(out_r - C_ref_r[i][j]) > error_threshold) || 
                    (abs(out_i - C_ref_i[i][j]) > error_threshold)) begin
                    error_count = error_count + 1;
                end
            end
        end*/

        $display("Total Errors = %0d", error_count);
        $finish;
    end

endmodule
