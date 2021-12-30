module instruction_decoder(
    input wire [7:0] next_instr,

    input wire sync_reset,
    input wire clk,
    
    output reg jmp,
    output reg jmp_nz,
    output reg [3:0] ir_nibble,
    output reg i_sel,
    output reg y_sel,
    output reg x_sel,
    output reg [3:0] source_sel,
    output reg [8:0] reg_en,
    output reg [7:0] ir,
    output reg [7:0] from_ID,
    output reg NOPC8, NOPCF, NOPD8, NOPDF
);
    // ******** NOPC8 ********
    always@(*)
        // RESET
        if (ir == 8'hC8)
            NOPC8 = 1'b1;
        // Jump
        else
            NOPC8 = 1'b0;

    // ******** NOPCF ********
    always@(*)
        // RESET
        if (ir == 8'hCF)
            NOPCF = 1'b1;
        // Jump
        else
            NOPCF = 1'b0;

    // ******** NOPD8 ********
    always@(*)
        // RESET
        if (ir == 8'hD8)
            NOPD8 = 1'b1;
        // Jump
        else
            NOPD8 = 1'b0;

    // ******** NOPDF ********
    always@(*)
        // RESET
        if (ir == 8'hDF)
            NOPDF = 1'b1;
        // Jump
        else
            NOPDF = 1'b0;

    // ******** From ID ********
    always@(*)
        from_ID <= reg_en[7:0];

    // ******** Instruction Register ********
    always @(posedge clk)
        ir <= next_instr;
    
    // ******** Send ir_nibble ********
    always@(*)
        ir_nibble <= ir[3:0];

    // ******** Decoding Jump or Conditional Jump ********
    // --- Jump ---
    always@(*)
        // RESET
        if (sync_reset)
            jmp <= 1'b0;
        // Jump
        else if (ir[7:4] == 4'b1110)
            jmp <= 1'b1;
        // No Jump
        else
            jmp <= 1'b0;

    // --- Conditional Jump ---
    always@(*)
        // RESET
        if (sync_reset)
            jmp_nz <= 1'b0;
        // Jump
        else if (ir[7:4] == 4'b1111)
            jmp_nz <= 1'b1;
        // No Jump
        else
            jmp_nz <= 1'b0;

    // ******** Decoding x,y,i Selects ********
    // --- x Select ---
    always@(*)
        // RESET
        if (sync_reset)
            x_sel <= 1'b0;
        // Send x select
        else
            x_sel <= ir[4];

    // --- y Select ---
    always@(*)
        // RESET
        if (sync_reset)
            y_sel <= 1'b0;
        // Send y select
        else
            y_sel <= ir[3];

    // --- i select ---
    always@(*)
        // RESET
        if (sync_reset)
            i_sel <= 1'b0;

        // --- Move Instruction ---
        else if ((ir[7:6] == 2'b10) &&  (ir[5:3] == 3'b110))
            i_sel <= 1'b0;

        // --- Load Instruction ---
        else if ((ir[7] == 1'b0) && (ir[6:4] == 3'b110))
            i_sel <= 1'b0;

        // i is not destination or source, dm is not source
        else
            i_sel <= 1'b1;

    // ******** Decoding Source Select ********
    always@(*)
        // RESET
        if (sync_reset)
            source_sel <= 4'd10;

        // --- Load Instruction ---
        else if (ir[7:6] == 2'b10)
            // i_pins
            if ((ir[5:3] == ir[2:0]))
                if ((ir[5:3] != 3'b100))
                    source_sel <= 4'd9;
                else
                    source_sel <= 4'd4;
            
            // x0,x1,y0,y1,r,m,i,dm
            else
                source_sel <= ir[2:0];

        // --- Move Instruction ---
        else if (ir[7] == 1'b0)
            source_sel <= 4'd8;
        
        // Otherwise
        else
            source_sel <= 4'd10;
        

    // ******** Decoding Register Enables ********
    // --- reg_en[0] - x0 ---
    always@(*)
        // RESET
        if (sync_reset)
            reg_en[0] <= 1'b1;
        else
            // Load
            if ((ir[7] == 1'b0) && (ir[6:4] == 3'd0))
                reg_en[0] <= 1'b1;
            
            // Move
            else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd0))
                reg_en[0] <= 1'b1;

            // Otherwise
            else
                reg_en[0] <= 1'b0;

    // --- reg_en[1] - x1 ---
    always@(*)
        // RESET
        if (sync_reset)
            reg_en[1] <= 1'b1;
        else

            // Load
            if ((ir[7] == 1'b0) && (ir[6:4] == 3'd1))
                reg_en[1] <= 1'b1;
            
            // Move
            else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd1))
                reg_en[1] <= 1'b1;

            // Otherwise
            else
                reg_en[1] <= 1'b0;

    // --- reg_en[2] - y0 ---
    always@(*)
        // RESET
        if (sync_reset)
            reg_en[2] <= 1'b1;
        else

            // Load
            if ((ir[7] == 1'b0) && (ir[6:4] == 3'd2))
                reg_en[2] <= 1'b1;
            
            // Load
            else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd2))
                reg_en[2] <= 1'b1;

            // Otherwise
            else
                reg_en[2] <= 1'b0;

    // --- reg_en[3] - y1 ---
    always@(*)
        // RESET
        if (sync_reset)
            reg_en[3] <= 1'b1;
        else

            // Load
            if ((ir[7] == 1'b0) && (ir[6:4] == 3'd3))
                reg_en[3] <= 1'b1;
            
            // Load
            else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd3))
                reg_en[3] <= 1'b1;

            // Otherwise
            else
                reg_en[3] <= 1'b0;

    // --- reg_en[4] - ALU ---
    always@(*)
        // RESET
        if (sync_reset)
            reg_en[4] <= 1'b1;
        else

            // ALU
            if (ir[7:5] == 3'b110)
                reg_en[4] <= 1'b1;
            else
                reg_en[4] <= 1'b0;

    // --- reg_en[5] - m ---
    always@(*)
        // RESET
        if (sync_reset)
            reg_en[5] <= 1'b1;
        else

            // Load
            if ((ir[7] == 1'b0) && (ir[6:4] == 3'd5))
                reg_en[5] <= 1'b1;
            
            // Move
            else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd5))
                reg_en[5] <= 1'b1;

            // Otherwise
            else
                reg_en[5] <= 1'b0;

    // --- reg_en[6] - i ---
    always@(*)
        // RESET
        if (sync_reset)
            reg_en[6] <= 1'b1;
        else

            // Load
            if ((ir[7] == 1'b0) && (ir[6:4] == 3'd7))
                reg_en[6] <= 1'b1; // Load DM
            else if ((ir[7] == 1'b0) && (ir[6:4] == 3'd6))
                reg_en[6] <= 1'b1; // Load i
            
            // Move
            else if ((ir[7:6] == 2'b10) && (ir[2:0] == 3'b111))
                reg_en[6] <= 1'b1; // Move to DM
            else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'b111))
                reg_en[6] <= 1'b1; // Move from DM
            else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'b110))
                reg_en[6] <= 1'b1; // Move to i
            
            // Otherwise
            else
                reg_en[6] <= 1'b0;

    // --- reg_en[7] - dm ---
    always@(*)
        // RESET
        if (sync_reset)
            reg_en[7] <= 1'b1;
        else

            // Move
            if ((ir[7] == 1'b0) && (ir[6:4] == 3'd7))
                reg_en[7] <= 1'b1;

            // Load
            else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd7))
                reg_en[7] <= 1'b1;

            // Otherwise
            else
                reg_en[7] <= 1'b0;

    // --- reg_en[8] - o_reg ---
    always@(*)
        // RESET
        if (sync_reset)
            reg_en[8] <= 1'b1;
        else

            // Move
            if ((ir[7] == 1'b0) && (ir[6:4] == 3'd4))
                reg_en[8] <= 1'b1;

            // Load
            else if ((ir[7:6] == 2'b10) && (ir[5:3] == 3'd4))
                reg_en[8] <= 1'b1;

            // Otherwise
            else
                reg_en[8] <= 1'b0;
        

endmodule