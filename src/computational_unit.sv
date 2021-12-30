module computational_unit(
    input wire clk,
    input wire sync_reset,

    input wire [3:0] dm,
    input wire [3:0] nibble_ir,
    input wire i_sel,
    input wire y_sel,
    input wire x_sel,
    input wire [3:0] source_sel,
    input wire [8:0] reg_en,
    input wire [3:0] i_pins,

    output reg [3:0] x0,
    output reg [3:0] x1,
    output reg [3:0] y0,
    output reg [3:0] y1,
    output reg [3:0] r,
    output reg [3:0] m,
    output reg [3:0] data_bus,
    output reg [3:0] i,
    output reg [3:0] o_reg,
    output reg r_eq_0,
    output reg [7:0] from_CU
);

    // ********** from_CU **********
    always@(*)
        from_CU <= {x1,x0};
    
    reg [3:0] x;
    
    reg [3:0] y;

    reg [3:0] pm_data;

    // ********** Data Bus **********
    always @(*)
        if (source_sel == 4'd0)
            data_bus <= x0;
        else if (source_sel == 4'd1)
            data_bus <= x1;
        else if (source_sel == 4'd2)
            data_bus <= y0;
        else if (source_sel == 4'd3)
            data_bus <= y1;
        else if (source_sel == 4'd4)
            data_bus <= r;
        else if (source_sel == 4'd5)
            data_bus <= m;
        else if (source_sel == 4'd6)
            data_bus <= i;
        else if (source_sel == 4'd7)
            data_bus <= dm;
        else if (source_sel == 4'd8)
            data_bus <= pm_data;
        else if (source_sel == 4'd9)
            data_bus <= i_pins;
        else
            data_bus <= 4'd0;
        
    // ********** x,y,m,o_reg Registers **********
    // --- x0 Reg ---
    always @(posedge clk)
        if (reg_en[0])
            x0 <= data_bus;
        else
            x0 <= x0;
    // --- x1 Reg ---
    always @(posedge clk)
        if (reg_en[1])
            x1 <= data_bus;
        else
            x1 <= x1;
    // --- y0 Reg ---
    always @(posedge clk)
        if (reg_en[2])
            y0 <= data_bus;
        else
            y0 <= y0;
    // --- y1 Reg ---
    always @(posedge clk)
        if (reg_en[3])
            y1 <= data_bus;
        else
            y1 <= y1;
    // --- m Reg ---
    always @(posedge clk)
        if (reg_en[5])
            m <= data_bus;
        else
            m <= m;
    // --- o_reg Reg ---
    always @(posedge clk)
        if (reg_en[8])
            o_reg <= data_bus;
        else
            o_reg <= o_reg;

    // ********** i Register **********
    always @(posedge clk)
        if (reg_en[6])
            if (i_sel)
                i <= i + m;
            else
                i <= data_bus;
        else
            i <= i;
    
    // ********** X Mux **********
    always @(*)
        if (x_sel)
            x <= x1;
        else
            x <= x0;
    // ********** Y Mux **********
    always @(*)
        if (y_sel)
            y <= y1;
        else
            y <= y0;
    
    // ********** pm_data **********
    always @(*)
        pm_data <= nibble_ir;
    

    // *************************
    // ********** ALU **********
    // *************************

    // ********** Inputs **********
    reg ir_3;
    reg [2:0] alu_function;
    reg [3:0] alu_out;

    // --- ir_3 ---
    always @(*)
        ir_3 <= nibble_ir[3];
    // --- alu_function ---
    always @(*)
        alu_function <= nibble_ir[2:0];
    
    // ********** Outputs **********
    reg [7:0] xy_mult;
    // --- multiplication ---
    always @(*)
        xy_mult <= x*y;

    // --- alu_out ---
    always @(*)
        if (sync_reset)
            alu_out <= 4'H0;
        // ***** C8 (x = x0) & D8 (x = x1) *****
        else if ((alu_function == 3'b000) && (ir_3 == 1'b1))
            alu_out <= 4'H1; // NO OP
        else if ((alu_function == 3'b000) && (ir_3 == 1'b0))
            alu_out <= -x;
        else if (alu_function == 3'b001)
            alu_out <=x-y;
        else if (alu_function == 3'b010)
            alu_out <= x + y;
        else if (alu_function == 3'b011)
            alu_out <= xy_mult[7:4];
        else if (alu_function == 3'b100)
            alu_out <= xy_mult[3:0];
        else if (alu_function == 3'b101)
            alu_out <= x^y;
        else if (alu_function == 3'b110)
            alu_out <= x&y;
        // ***** CF (x = x0) & DF (x = x1) *****
        else if ((alu_function == 3'b111) && (ir_3 == 1'b1))
            alu_out <= 4'H1; // NO OP
        else if ((alu_function == 3'b111) && (ir_3 == 1'b0))
            alu_out <= ~x;
        else
            alu_out <= 4'H1; // SHOULD NEVER GET HERE
    
    // --- r register ---
    always @(posedge clk)
        if (reg_en[4])
            // ***** C8 (x = x0) & D8 (x = x1) *****
            if ((alu_function == 3'b000) && (ir_3 == 1'b1))
                r <= r; // NO OP
            else if ((alu_function == 3'b000) && (ir_3 == 1'b0))
                r <= alu_out;
            // ***** CF (x = x0) & DF (x = x1) *****
            else if ((alu_function == 3'b111) && (ir_3 == 1'b1))
                r <= r; // NO OP
            else if ((alu_function == 3'b111) && (ir_3 == 1'b0))
                r <= alu_out;
            else
                r <= alu_out;
        else
            r <= r;

    // --- r_eq_0 ---
    always @(posedge clk)
        if (reg_en[4])
            // ***** C8 (x = x0) & D8 (x = x1) *****
            if ((alu_function == 3'b000) && (ir_3 == 1'b1))
                r_eq_0 <= r_eq_0;
            else if ((alu_function == 3'b000) && (ir_3 == 1'b0))
                if (x == 4'H0)
                    r_eq_0 <= 1'b1;
                else
                    r_eq_0 <= 1'b0;
            // ***** CF (x = x0) & DF (x = x1) *****
            else if ((alu_function == 3'b111) && (ir_3 == 1'b1))
                r_eq_0 <= r_eq_0;
            else if ((alu_function == 3'b111) && (ir_3 == 1'b0))
                if (x == 4'HF)
                    r_eq_0 <= 1'b1;
                else
                    r_eq_0 <= 1'b0;
            else
                if (alu_out == 4'H0)
                    r_eq_0 <= 1'b1;
                else
                    r_eq_0 <= 1'b0;
        else
            r_eq_0 <= r_eq_0;
    


endmodule