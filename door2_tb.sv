`timescale 1ns/1ps

module door_tb;

    // Inputs to DUT
    logic       clk;
    logic       reset;
    logic [3:0] digit;
    logic       enter;

    // Outputs from DUT
    logic       unlock;
    logic       alarm;
    logic       locked;


    // =====================================
    // DUT INSTANTIATION
    // =====================================

    digital_door_lock DUT (
        .clk    (clk),
        .reset  (reset),
        .digit  (digit),
        .enter  (enter),
        .unlock (unlock),
        .alarm  (alarm),
        .locked (locked)
    );


    // =====================================
    // CLOCK GENERATION
    // =====================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    // =====================================
    // TASK TO ENTER ONE DIGIT
    // =====================================

    task automatic enter_digit(input logic [3:0] d);

        begin

            @(negedge clk);

            digit = d;
            enter = 1'b1;

            @(negedge clk);

            enter = 1'b0;

        end

    endtask


    // =====================================
    // TEST SEQUENCE
    // =====================================

    initial begin

        // Initial values
        reset = 1'b1;
        digit = 4'd0;
        enter = 1'b0;


        // =================================
        // RESET
        // =================================

        #20;

        reset = 1'b0;

        $display("--------------------------------");
        $display("RESET COMPLETED");
        $display("--------------------------------");


        // =================================
        // TEST 1: CORRECT PASSWORD
        // PASSWORD = 1234
        // =================================

        $display("TEST 1: Entering correct password 1234");

        enter_digit(4'd1);
        enter_digit(4'd2);
        enter_digit(4'd3);
        enter_digit(4'd4);

        // Wait for CHECK → UNLOCK
        #20;

        if (unlock == 1'b1)
            $display("PASS: Door UNLOCKED");
        else
            $display("FAIL: Door did not unlock");


        // Wait for door to lock again
        #60;


        // =================================
        // TEST 2: FIRST WRONG PASSWORD
        // =================================

        $display("TEST 2: First wrong password 1111");

        enter_digit(4'd1);
        enter_digit(4'd1);
        enter_digit(4'd1);
        enter_digit(4'd1);

        #20;

        if (locked == 1'b1)
            $display("PASS: Door remains LOCKED");
        else
            $display("FAIL: Door unlocked incorrectly");


        // =================================
        // TEST 3: SECOND WRONG PASSWORD
        // =================================

        $display("TEST 3: Second wrong password 5555");

        enter_digit(4'd5);
        enter_digit(4'd5);
        enter_digit(4'd5);
        enter_digit(4'd5);

        #20;


        // =================================
        // TEST 4: THIRD WRONG PASSWORD
        // =================================

        $display("TEST 4: Third wrong password 9999");

        enter_digit(4'd9);
        enter_digit(4'd9);
        enter_digit(4'd9);
        enter_digit(4'd9);

        #20;

        if (alarm == 1'b1)
            $display("PASS: ALARM ACTIVATED");
        else
            $display("FAIL: Alarm did not activate");


        // =================================
        // TEST 5: RESET AFTER ALARM
        // =================================

        $display("TEST 5: Resetting system");

        reset = 1'b1;

        #10;

        reset = 1'b0;

        #10;

        if ((locked == 1'b1) && 
            (alarm == 1'b0) && 
            (unlock == 1'b0))

            $display("PASS: System reset successfully");

        else
            $display("FAIL: Reset failed");


        // =================================
        // END SIMULATION
        // =================================

        #20;

        $display("--------------------------------");
        $display("SIMULATION COMPLETED");
        $display("--------------------------------");

        $finish;

    end

endmodule