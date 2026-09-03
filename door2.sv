module digital_door_lock (
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] digit,
    input  logic       enter,

    output logic       unlock,
    output logic       alarm,
    output logic       locked
);

    // Password = 1, 2, 3, 4
    parameter logic [3:0] P1 = 4'd1;
    parameter logic [3:0] P2 = 4'd2;
    parameter logic [3:0] P3 = 4'd3;
    parameter logic [3:0] P4 = 4'd4;

    // FSM states
    typedef enum logic [1:0] {
        LOCKED_STATE,
        CHECK_STATE,
        UNLOCK_STATE,
        ALARM_STATE
    } state_t;

    state_t state;

    // Counters
    logic [1:0] digit_count;
    logic [1:0] wrong_attempts;
    logic [2:0] unlock_counter;

    // Stores four entered password digits
    logic [3:0] entered_password [0:3];


    // Sequential logic
    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            state          <= LOCKED_STATE;
            digit_count    <= 2'd0;
            wrong_attempts <= 2'd0;
            unlock_counter <= 3'd0;

            unlock <= 1'b0;
            alarm  <= 1'b0;
            locked <= 1'b1;

            entered_password[0] <= 4'd0;
            entered_password[1] <= 4'd0;
            entered_password[2] <= 4'd0;
            entered_password[3] <= 4'd0;
        end

        else begin

            case (state)

                // =========================
                // LOCKED STATE
                // =========================
                LOCKED_STATE: begin

                    unlock <= 1'b0;
                    alarm  <= 1'b0;
                    locked <= 1'b1;

                    if (enter) begin

                        entered_password[digit_count] <= digit;

                        if (digit_count == 2'd3) begin
                            digit_count <= 2'd0;
                            state <= CHECK_STATE;
                        end

                        else begin
                            digit_count <= digit_count + 1'b1;
                        end

                    end
                end


                // =========================
                // CHECK PASSWORD
                // =========================
                CHECK_STATE: begin

                    if ((entered_password[0] == P1) &&
                        (entered_password[1] == P2) &&
                        (entered_password[2] == P3) &&
                        (entered_password[3] == P4)) begin

                        // Correct password
                        unlock_counter <= 3'd0;
                        wrong_attempts <= 2'd0;
                        state <= UNLOCK_STATE;

                    end

                    else begin

                        // Wrong password
                        if (wrong_attempts == 2'd2) begin
                            state <= ALARM_STATE;
                        end

                        else begin
                            wrong_attempts <= wrong_attempts + 1'b1;
                            state <= LOCKED_STATE;
                        end

                    end
                end


                // =========================
                // UNLOCK STATE
                // =========================
                UNLOCK_STATE: begin

                    locked <= 1'b0;
                    unlock <= 1'b1;
                    alarm  <= 1'b0;

                    if (unlock_counter == 3'd4) begin

                        unlock_counter <= 3'd0;
                        unlock <= 1'b0;
                        locked <= 1'b1;
                        state <= LOCKED_STATE;

                    end

                    else begin
                        unlock_counter <= unlock_counter + 1'b1;
                    end

                end


                // =========================
                // ALARM STATE
                // =========================
                ALARM_STATE: begin

                    locked <= 1'b1;
                    unlock <= 1'b0;
                    alarm  <= 1'b1;

                end


                // =========================
                // DEFAULT
                // =========================
                default: begin
                    state <= LOCKED_STATE;
                    locked <= 1'b1;
                    unlock <= 1'b0;
                    alarm <= 1'b0;
                end

            endcase
        end
    end

endmodule