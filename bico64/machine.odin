package bico64

Register :: enum u8 {
  zero,
  ra,
  sp,
  gp,
  tp,
  t0,
  t1,
  t2,
  s0,
  s1,
  a0,
  a1,
  a2,
  a3,
  a4,
  a5,
  a6,
  a7,
  s2,
  s3,
  s4,
  s5,
  s6,
  s7,
  s8,
  s9,
  s10,
  s11,
  t3,
  t4,
  t5,
  t6,
}

Opcode_Kind :: enum u8 {
  load      = 0b0000011, // I type; l{b|h|w|d} or l{b|h|w}u
  fence     = 0b0001111, // I type; fence or fence.i
  op_imm    = 0b0010011, // I type; arithmetic or logical immediate
  auipc     = 0b0010111, // U type
  op_imm_32 = 0b0011011, // I type; addiw, slliw, srliw, sraiw
  store     = 0b0100011, // S/I type; S type if s{b|h|w}, I type if sd
  store_FP  = 0b0100111,
  op        = 0b0110011, // R type; arithmetic or logical no immediate
  lui       = 0b0110111, // U type
  op_32     = 0b0111011, // R type; addw, sllw, srlw, sraw
  op_FP     = 0b1010011,
  op_V      = 0b1010111,
  branch    = 0b1100011, // SB type, beq, bne, blt, bge, bltu, bgeu
  jal       = 0b1101111, // UJ type
  jalr      = 0b1100111, // I type
  system    = 0b1110011, // I type; cssr & environment calls
}

Op_Imm_Funct3_Kind :: enum u8 {
  addi  = 0b000,
  stli  = 0b010,
  stliu = 0b011,
  xori  = 0b100,
  ori   = 0b110,
  andi  = 0b111,
  slli  = 0b001,
}

Op_Funct3_Kind :: enum u8 {
  add  = 0b000, // also sub
  sll  = 0b001,
  slt  = 0b010,
  sltu = 0b011,
  xor  = 0b100,
  srl  = 0b101,
  or   = 0b110,
  and  = 0b111,

}


IntegerReg :: struct #raw_union {
  u: u64,
  i: i64
}

FloatReg :: struct #raw_union {
  s: f32,
  d: f64
}

Machine :: struct {
  x: [32]IntegerReg,
  f: [32]FloatReg,
  pc: u64,
  memory: []u8, // 1 megabyte
}

init_machine :: proc(m: ^Machine, program: ^[]u32) {
  assert(size_of(m.memory) <= size_of(program))

  program_instructions := (^[]u8)(program)^
  copy_slice(m.memory, program_instructions) // copy(mem[:], program[:])
  
  m.pc = 0 // start at first instruction
}