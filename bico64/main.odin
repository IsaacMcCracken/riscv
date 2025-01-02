package bico64



import rl "vendor:raylib"
import "core:slice"
import "core:fmt"
import "core:c"


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
  Load      = 0b00000,
  Load_FP   = 0b00001,
  Op_Imm    = 0b00100,
  Auipc     = 0b00101,
  Op_Imm_32 = 0b00110,
  Store     = 0b01000, 
  Store_FP  = 0b01001,
  Op        = 0b01100,
  Lui       = 0b01101,
  Op_32     = 0b01110,
  Op_FP     = 0b10100,
  Op_V      = 0b10101,
  Branch    = 0b11000,
  Jalr      = 0b11001,
  Jal       = 0b11011,
  System    = 0b11100,
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
  memory: []u8,
}

imm_12_bit_conversion :: proc(imm: u32) -> i64 {
  // if there is a signed we have to do some more stuff
  if ((imm & (1 << 11)) > 0) {
    // TODO: this
    return 0
  }

  return i64(imm)
}

op_imm_execute :: proc(m: ^Machine, instruction: u32) {
  funct3 := Op_Imm_Funct3_Kind((instruction & 0b111000000000000) >> 11)
  rd := u8((0b111110000000 & instruction) >> 7)
  rs1 := u8((0b11111000000000000000 & instruction) >> 15)
  imm0 := instruction >> 20
  imm := imm_12_bit_conversion(imm0)
  switch funct3 {
    case .addi:
      m.x[rd].i = m.x[rs1].i + imm
    case .stli:
      m.x[rd].i = m.x[rs1].i < imm
    case .stliu:
      m.x[rd].u = m.x[rs1].u < u64(imm0)
    case .xori:
      m.x[rd].i = m.x[rs1].i ~ imm
    case .ori:
      m.x[rd].i = m.x[rs1].i | imm
    case .andi:
      m.x[rd].i = m.x[rs1].i & imm
    case .slli:
      shamt := (instruction >> 20) & 0b11111 
      funct5 := instruction >> 26
      

  }
}

fetch_decode_execute :: proc(m: ^Machine) {
  instruction := (transmute(^u32)(&m.memory[m.pc]))^
  m.pc += 4
  opcode := Opcode_Kind((instruction & 0b1111111) >> 2)
  #partial switch opcode {
    case .Op_Imm:
      op_imm_execute(m, instruction)
    case .Lui:
      rd := u8((0b111110000000 & instruction) >> 7)
      m.x[rd].u = u64(instruction & 0b11111111111111111111000000000000)
    case .Auipc:
      rd := u8((0b111110000000 & instruction) >> 7)
      m.x[rd].u = m.pc + u64(instruction & 0b11111111111111111111000000000000)
    case:
    
      
  }
}

main :: proc() {
  memory: [1024]u8

  m := &Machine{
    memory = memory[:]
  }

  instr := transmute(^u32)(&memory[0])
  instr^ = 0x04500093



  fetch_decode_execute(m)

  fmt.print("x1 =", m.x[1].i)
}