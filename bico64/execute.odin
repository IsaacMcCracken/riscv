package bico64

exec_load :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
exec_fence :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
exec_op_imm :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
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