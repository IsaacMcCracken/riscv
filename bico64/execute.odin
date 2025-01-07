package bico64

exec_load :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
exec_fence :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
exec_op_imm :: proc(m: ^Machine, instruction: ^ITypeInstruction) {
  switch instruction.funct3 {
    // case .addi:
    //   m.x[instruction.rd].i = m.x[instruction.rs1].i + instruction.imm
    // case .slti:
    //   m.x[rd].i = m.x[rs1].i < imm
    // case .stliu:
    //   m.x[rd].u = m.x[rs1].u < u64(imm0)
    // case .xori:
    //   m.x[rd].i = m.x[rs1].i ~ imm
    // case .ori:
    //   m.x[rd].i = m.x[rs1].i | imm
    // case .andi:
    //   m.x[rd].i = m.x[rs1].i & imm
    // case .slli:
    //   m.x[rd].i = m.x[rs1].i << imm
  }
}
exec_auipc :: proc(m: ^Machine, instruction: ^UTypeInstruction) {}
exec_op_imm_32 :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
exec_store :: proc(m: ^Machine, instruction: ^STypeInstruction) {}
exec_store_FP :: proc(m: ^Machine) {}
exec_op :: proc(m: ^Machine, instruction: ^RTypeInstruction) {}
exec_lui :: proc(m: ^Machine, instruction: ^UTypeInstruction) {}
exec_op_32 :: proc(m: ^Machine, instruction: ^RTypeInstruction) {}
exec_op_FP :: proc(m: ^Machine) {}
exec_op_V :: proc(m: ^Machine) {}
exec_branch :: proc(m: ^Machine, instruction: ^STypeInstruction) {}
exec_jal :: proc(m: ^Machine, instruction: ^UTypeInstruction) {}
exec_jalr :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
exec_system :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}