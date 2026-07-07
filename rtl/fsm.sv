module fsm (
    input  logic clk,
    input  logic rst_n,
    input  logic byte_valid,

    output logic reg_en,
    output logic count_en,
    output logic done
);

    typedef enum logic [1:0] {
        IDLE,
        STORE,
        COUNT,
        DONE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;

        reg_en   = 0;
        count_en = 0;
        done     = 0;

        case (state)

            IDLE: begin
                if (byte_valid)
                    next_state = STORE;
            end

            STORE: begin
                reg_en = 1;
                next_state = COUNT;
            end

            COUNT: begin
                count_en = 1;
                next_state = DONE;
            end

            DONE: begin
                done = 1;
                next_state = IDLE;
            end

        endcase
    end

endmodule
