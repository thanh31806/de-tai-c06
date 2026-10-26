`timescale 1ns/1ps

module tb;
    logic clk, rst_n, ena;
    logic [7:0] ui_in, uio_in;
    wire [7:0] uo_out, uio_out, uio_oe;

    tt_um_24101322_c06 dut (.*);

    always #5 clk = ~clk;

    task apply_cycle(input [7:0] sample, input [7:0] thresh);
        begin
            ui_in = sample;
            uio_in = thresh;
            @(posedge clk);
            #1;
        end
    endtask

    task reset_dut;
        begin
            rst_n = 0;
            repeat(2) @(posedge clk);
            rst_n = 1;
            #1;
        end
    endtask

    initial begin
        clk = 0; rst_n = 1; ena = 1; ui_in = 0; uio_in = 0;

        // CA 1: Sự kiện tại chu kỳ 1, 255, 256
        reset_dut();
        apply_cycle(8'd101, 8'd100);
        for (int i=2; i<=254; i++) apply_cycle(8'd100, 8'd100);
        apply_cycle(8'd101, 8'd100);
        apply_cycle(8'd101, 8'd100);
        if (uo_out !== 8'd3) $display("FAIL: CA 1, ky vong 3, nhan duoc %0d", uo_out);
        else $display("PASS: CA 1 (Ket qua = 3)");

        // CA 2: Tất cả đều vượt ngưỡng (Tràn số)
        reset_dut();
        for (int i=1; i<=256; i++) apply_cycle(8'd101, 8'd100);
        if (uo_out !== 8'd0 || uio_out[1] !== 1'b1) 
            $display("FAIL: CA 2, ky vong 256, nhan duoc uo_out=%0d, uio_out[1]=%0d", uo_out, uio_out[1]);
        else $display("PASS: CA 2 (Ket qua = 256)");

        // CA 3: Bằng ngưỡng (Biên)
        reset_dut();
        for (int i=1; i<=256; i++) apply_cycle(8'd100, 8'd100);
        if (uo_out !== 8'd0) $display("FAIL: CA 3, ky vong 0, nhan duoc %0d", uo_out);
        else $display("PASS: CA 3 (Ket qua = 0)");

        // CA 4: Cửa sổ mới bắt đầu ngay
        reset_dut();
        for (int i=1; i<=256; i++) apply_cycle(8'd101, 8'd100);
        apply_cycle(8'd101, 8'd100);
        if (uo_out !== 8'd1) $display("FAIL: CA 4, ky vong 1, nhan duoc %0d", uo_out);
        else $display("PASS: CA 4 (Ket qua = 1)");

        $display("Testbench finished.");
        $finish(0);
    end
endmodule
