package bico64
import "base:runtime"
import "core:slice"
import "core:fmt"
import "core:c"

decode_execute :: proc(m: ^Machine, instruction: u32) {
  opcode := Opcode_Kind((instruction & 0x7F))
  #partial switch opcode {
    case .load:
      decoded_instruction := decode_i_type(instruction)
      exec_load(m, &decoded_instruction)

    case .fence:
      decoded_instruction := decode_i_type(instruction)
      exec_fence(m, &decoded_instruction)

    case .op_imm:
      decoded_instruction := decode_i_type(instruction)
      exec_op_imm(m, &decoded_instruction)

    case .auipc:
      decoded_instruction := decode_u_type(instruction)
      exec_auipc(m, &decoded_instruction)

    case .op_imm_32:
      decoded_instruction := decode_i_type(instruction)
      exec_op_imm_32(m, &decoded_instruction)

    case .store:
      // can be either S or I type; S if s{b|h|w}, I type if sd
      // decoded_instruction := decode_s_type(instruction)
      // exec_store(m, &decoded_instruction)

    case .store_FP:
      // exec_store_FP(m, &decoded_instruction)
    case .op:
      decoded_instruction := decode_r_type(instruction)
      exec_op(m, &decoded_instruction)

    case .lui:
      decoded_instruction := decode_u_type(instruction)
      exec_lui(m, &decoded_instruction)

    case .op_32:
      decoded_instruction := decode_r_type(instruction)
      exec_op_32(m, &decoded_instruction)

    case .op_FP:
      // exec_op_FP(m, &decoded_instruction)
    case .op_V:
      // exec_op_V(m, &decoded_instruction)

    case .branch:
      decoded_instruction := decode_sb_type(instruction)
      exec_branch(m, &decoded_instruction)

    case .jal:
      decoded_instruction := decode_uj_type(instruction)
      exec_jal(m, &decoded_instruction)

    case .jalr:
      decoded_instruction := decode_i_type(instruction)
      exec_jalr(m, &decoded_instruction)

    case .system:
      decoded_instruction := decode_i_type(instruction)
      exec_system(m, &decoded_instruction)
  }
}

execute_i_type_int :: proc(m: ^Machine, instruction: ITypeInstruction) {
  switch instruction.funct3 {
    

  }
}


main :: proc() {
  // store instructions at bottom part of memory
  memory: [1024]u8

  // set memory and create mmachine
  m := &Machine{
    memory = memory[:]
  }

  // program to run
  program := []u32 {
    0x00530293, // addi t0, t1, 5
    0x00540433  // add  s0, s0, t0
  }
  fmt.printf("instruction 1: %X\n", program)
  instr := transmute(^u32)(&m.memory[0])
  instr^ = 0x04500093

  // program_instructions := (^[]u8)(&program)^
  // copy_slice(m.memory, program_instructions[:]) // copy(mem[:], program[:])

  // init_machine(m, &program)
  // fmt.printf("program after: %X", program)
  print_prog_mem(m)
  // run program
  // for {
  //   // fetch instruction
  //   instruction := (transmute(^u32)(&m.memory[m.pc]))^
  //   fmt.printf("%X", instruction)
  //   // assume end of program if zero instruction
  //   if (instruction == 0) {
  //   return
  //   }

  //   m.pc += 4 // set pc to next instruction
  //   decode_execute(m, instruction)
  // }

}


print_prog_mem :: proc(m: ^Machine) {
  // print first 10 ish lines
  for i:= 0; i < 10; i += 1 {
    fmt.printf("%X\n", m.memory[i])
  }
}