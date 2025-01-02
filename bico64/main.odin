package bico64
import "base:runtime"
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
  jalr      = 0b1100111, // I type
  jal       = 0b1101111, // UJ type
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
  memory: []u8,
}

fetch_decode_execute :: proc(m: ^Machine) {
  instruction := (transmute(^u32)(&m.memory[m.pc]))^
  m.pc += 4

  opcode := Opcode_Kind((instruction & 0x7F))
  #partial switch opcode {
    case .op_imm:
    
    case .
    
    case .lui:

    case .auipc:
      
    case:
    
      
  }
}

execute_i_type_int :: proc(m: ^Machine, instruction: ITypeInstruction) {
  switch instruction.funct3 {
    case .addi:
      m.x[instruction.rd].i = m.x[instruction.rs1].i + instruction.imm
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