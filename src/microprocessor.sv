module final_exam_pre(
    input wire clk,
    input wire reset,
    input wire [3:0] i_pins,

    // -- Program Data - ROM --
    output reg [7:0] pm_data,
    // -- Program Sequencer
    output reg [7:0] pc,
    output reg [7:0] pm_address,
    output reg [7:0] from_PS,
    // -- Instruction Decoder --
    output reg [7:0] ir,
    output reg [8:0] reg_enables,
    output reg [7:0] from_ID,
    output reg NOPC8, NOPCF, NOPD8, NOPDF,
    // -- Computational Unit --
    output reg [7:0] from_CU,
    output reg [3:0] o_reg,
    output reg [3:0] x0,
    output reg [3:0] x1,
    output reg [3:0] y0,
    output reg [3:0] y1,
    output reg [3:0] r,
    output reg [3:0] i,
    output reg zero_flag,
    output reg [3:0] m
);

    // **** Wires & Registers ****
    // -- Instruction Decoder --
    wire jump, conditional_jump;
    wire [3:0] LS_nibble_ir;
    wire i_mux_select, y_reg_select, x_reg_select;
    wire [3:0] source_select;
    // -- Computational Unit --
    wire [3:0] data_bus;
    // -- Data Memory - RAM --
    wire [3:0] dm;
    // -- Reset --
    reg sync_reset;

    

    // **** Synchronous Reset ****
    always @(posedge clk)
        sync_reset <= reset;

    // **** Program Sequencer ****
    program_sequencer prog_sequencer (
        // Timing
        .clk(clk),
        .sync_reset(sync_reset),

        // Data
        .pm_addr(pm_address),
        .jmp(jump),
        .jmp_nz(conditional_jump),
        .jmp_addr(LS_nibble_ir),
        .dont_jmp(zero_flag),

        // Debug
        .pc(pc),
        .from_PS(from_PS)
    );

    // **** Program Memory - ROM ****
    program_memory prog_mem (
        // Timing
        .clock(~clk),

        //Data
        .address(pm_address),
        .q(pm_data)
    );

    // **** Instruction Decoder ****
    instruction_decoder instr_decoder (
        // Timing
        .clk(clk),
        .sync_reset(sync_reset),

        // Control
        .next_instr(pm_data),

        // Output
        .jmp(jump),
        .jmp_nz(conditional_jump),
        .ir_nibble(LS_nibble_ir),
        .i_sel(i_mux_select),
        .y_sel(y_reg_select),
        .x_sel(x_reg_select),
        .source_sel(source_select),
        .reg_en(reg_enables),

        // Debug
        .ir(ir),
        .from_ID(from_ID),
        .NOPC8(NOPC8),
        .NOPCF(NOPCF),
        .NOPD8(NOPD8),
        .NOPDF(NOPDF)
    );

    // **** Computational Unit ****
    computational_unit comp_unit (
        // Timing
        .clk(clk),
        .sync_reset(sync_reset),

        // Control
        .i_pins(i_pins),
        .nibble_ir(LS_nibble_ir),
        .i_sel(i_mux_select),
        .y_sel(y_reg_select),
        .x_sel(x_reg_select),
        .source_sel(source_select),
        .reg_en(reg_enables),
        .dm(dm),

        // Output
        .r_eq_0(zero_flag),
        .i(i),
        .data_bus(data_bus),
        .o_reg(o_reg),
        .x0(x0),
        .x1(x1),
        .y0(y0),
        .y1(y1),
        .r(r),
        .m(m),

        // Debug
        .from_CU(from_CU)
    );

    // **** Data Memory - RAM ****
    data_memory data_mem (
        // Timing
        .clock(~clk),

        // Control
        .address(i),
        .data(data_bus),
        .wren(reg_enables[7]),

        // Output
        .q(dm)
    );
        
    
endmodule