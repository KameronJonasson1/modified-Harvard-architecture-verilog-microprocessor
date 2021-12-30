module program_sequencer(
    input wire clk,
    input wire sync_reset,
    input wire [3:0] jmp_addr,
    input wire jmp,
    input wire jmp_nz,
    input wire dont_jmp,
    output reg [7:0] pm_addr,
    output reg [7:0] pc,
    output reg [7:0] from_PS
);

// ******** From PS ********
always@(*)
    from_PS <= pc;

always @(posedge clk)
    pc <= pm_addr;

// ******** Combinational Next Adress Logic ********
always @(*) begin
    // Reset
    if (sync_reset == 1'b1)
        pm_addr <= 8'b00000000;
    // Non-Conditional jump
    else if (jmp == 1'b1)
        pm_addr <= {jmp_addr,4'b0000};
    // Conditional jump
    else if ((jmp_nz == 1'b1) && (dont_jmp == 1'b0))
        pm_addr <= {jmp_addr,4'b0000};
    // Move to next instruction
    else
        pm_addr <= pc + 8'd1;
end

    
endmodule