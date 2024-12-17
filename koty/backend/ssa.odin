package compiler_backend

import "core:fmt"
import lin "core:math/linalg"

Instruction_OpCode :: enum u32 {
  Int_Arg, // an integer argument
  // communitive operations
  AddR, // integer add register-register 
  //
  EqualR, // set integer register to another register // rd = rs1
}

RType_Hash :: struct {
  op: Instruction_OpCode,
  rs1, rs2: u32,
}

Instruction_RType :: struct {
  using hash: RType_Hash,
  lifetime: u32 // last instruction where it was used
}

Block :: struct {
  instructions: [dynamic]Instruction_RType,
  imap: map[RType_Hash]u32,
}

block_append_rtype :: proc(b: ^Block, instruction: Instruction_RType) {
  id := u32(len(b.instructions))
  // assert that the instructions are legal
  if instruction.op != .Int_Arg {
    assert(instruction.rs1 < id)
    assert(instruction.rs2 < id)
    // set the last updated position of the instructions  
    b.instructions[instruction.rs1].lifetime = id
    b.instructions[instruction.rs2].lifetime = id
  }

  // set the hash id of the instruction
  b.imap[instruction.hash] = id
  instr := instruction
  instr.lifetime = id
  n, _ := append(&b.instructions, instr)
}

block_greedy_coloring :: proc(b: ^Block, allocator := context.allocator) -> []u16 {
  context.allocator = allocator

  colors := make([]u16, len(b.instructions))

  n: u16 = 0

  for instr, i in b.instructions {
    if instr.op == .Int_Arg {
      colors[i] = n
      n += 1
    } else {
      for 
    }

  }
  
  return colors
} 

main :: proc() {
  b := &Block{
    instructions = make([dynamic]Instruction_RType),
    imap = make(map[RType_Hash]u32)
  }

  block_append_rtype(b, Instruction_RType{op = .Int_Arg}) // 0
  block_append_rtype(b, Instruction_RType{op = .Int_Arg}) // 1
  block_append_rtype(b, Instruction_RType{op = .Int_Arg}) // 2
  block_append_rtype(b, Instruction_RType{op = .AddR, rs1 = 0, rs2 = 1}) // 3
  block_append_rtype(b, Instruction_RType{op = .AddR, rs1 = 1, rs2 = 2}) // 4
  block_append_rtype(b, Instruction_RType{op = .AddR, rs1 = 3, rs2 = 4}) // 5

  /*
    expected asm output:
    add a0, a0, a1
    add a1, a1, a2
    add a0, a0, a1
  */

  for instr, i in b.instructions {
    if instr.op == .Int_Arg {
      fmt.printfln("%%%d: Int Arg [%d-%d]", i, i, instr.lifetime)
    } else {
      fmt.printfln("%%%d = %v %%%d, %%%d [%d-%d]", i, instr.op, instr.rs1, instr.rs2, i, instr.lifetime)
    }
  }

}