package bico64


/*----------------------------------------------------------
instruction opcode, funct3/7 types
----------------------------------------------------------*/

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


// arithmetic operations with immediate

Op_Imm_Funct3_Kind :: enum u8 {
  addi  = 0b000,
  slli  = 0b001,
  slti  = 0b010,
  sltiu = 0b011,
  xori  = 0b100,
  sri   = 0b101,  // srai & srli have the same funct3; differing funct7
  ori   = 0b110,
  andi  = 0b111,
}

Op_Imm_Funct7_Kind :: enum u8 {
  srli = 0b0000000,
  srai = 0b0100000
}


// arithmetic operations without immediate

Op_Funct3_Kind :: enum u8 {
  add  = 0b000, // also sub
  sll  = 0b001,
  slt  = 0b010,
  sltu = 0b011,
  xor  = 0b100,
  sr  = 0b101, // srl & sra; differ by funct7
  or   = 0b110,
  and  = 0b111,
}

Op_Funct7_Kind :: enum u8 {
  add = 0b0000000,
  sub = 0b0100000,
  srl = 0b0000000,
  sra = 0b0100000
}


/*----------------------------------------------------------
decode instruction functions & decoded instruction types
----------------------------------------------------------*/


// register operation
RTypeInstruction :: bit_field u32 {
  opcode: u8 | 7,
  rd: u8 | 5,// destination register
  funct3: u8 | 3,
  rs1: u8 | 5, // source register
  rs2: u8 | 5, // target register
  funct7: u8 | 7,
}

decode_r_type :: proc(instruction: u32) -> RTypeInstruction {
  return transmute(RTypeInstruction)instruction
}


// immediate operation
ITypeInstruction :: struct {
  rs1: u8, // source register
  imm: i64, // immediate sign extended to 32 bits (for 32 bit mode)
  rd: u8, // destination register
  funct3: u8
}

decode_i_type :: proc(instruction: u32) -> ITypeInstruction {
  immediate := (u64)(instruction >> 20) & 0xFFF
  // sign extend immediate if bit 11 is set
  if (immediate & 0x800 != 0) {
      immediate |= 0xFFFFFFFFFFFFF000
  }

  return ITypeInstruction {
      rs1 = (u8) (instruction >> 15) & 0x1F,
      imm = transmute(i64) immediate,
      rd = (u8) (instruction >> 7) & 0x1F,
      funct3 = (u8) (instruction >> 12) & 0x7
  }
}

  
// combined S (store {byte|half|word}) & SB (branch instructions)
STypeInstruction :: struct {
  rs1: u8, // source register
  rs2: u8, // target register
  imm: i64, // immediate sign extended to 32 bits (for 32 bit mode)
  funct3: u8
}

decode_s_type :: proc(instruction: u32) -> STypeInstruction {
  immediate := (u64)(instruction >> 7) & 0x1F // imm[4:0]
  immediate |= (u64)((instruction >> 25) & 0x7F) << 5 // imm[11:5]
  // sign extend
  if (immediate & 0x800 != 0) {
    immediate |= 0xFFFFFFFFFFFFF000
  }

  return STypeInstruction {
    rs1 = (u8) (instruction >> 15) & 0x1F,
    rs2 = (u8) (instruction >> 20) & 0x1F,
    imm = transmute(i64) immediate,
    funct3 = (u8) (instruction >> 12) & 0x7
  }
}

decode_sb_type :: proc(instruction: u32)  -> STypeInstruction {
  immediate := (u64)((instruction >> 8) & 0x1F) << 1 // imm[4:0]
  immediate |= (u64)((instruction >> 25) & 0x3F) << 5 // imm[10:5]
  immediate |= (u64)((instruction >> 7) & 0x1) << 11 // imm[11]
  immediate |= (u64)((instruction >> 31) & 0x1) << 12 // imm[12]
  // sign extend
  if (immediate & 0x1000 != 0) {
    immediate |= 0xFFFFFFFFFFFFF000 // overlaps 12th bit but its or so who cares
  }
  
  return STypeInstruction {
    rs1 = (u8) (instruction >> 15) & 0x1F,
    rs2 = (u8) (instruction >> 20) & 0x1F,
    imm = transmute(i64) immediate,
    funct3 = (u8) (instruction >> 12) & 0x7
  }
}


// combined U (lui, auipc) & UJ (jal)
UTypeInstruction :: struct {
  rd: u8, // destination register
  imm: i64, // immediate sign extended to 32 bits (for 32 bit mode)
}

decode_u_type :: proc(instruction: u32) -> UTypeInstruction {
  immediate := (u64)(instruction & 0xFFFFF000)
  if ((immediate >> 31) != 0) {
    immediate |= 0xFFFFFFFF00000000
  }
  return UTypeInstruction {
    rd = (u8) (instruction >> 7) & 0x1F,
    imm = transmute(i64) immediate // sets bottom 11:0 bits to 0
  }
}

decode_uj_type :: proc(instruction: u32) -> UTypeInstruction {
  immediate := (u64)((instruction >> 21) & 0x3FF) << 1 // imm[10:1]
  immediate |= (u64)((instruction >> 20) & 0x1) << 11 // imm[11]
  immediate |= (u64)((instruction >> 12) & 0xFF) << 12 // imm[19:12]
  immediate |= (u64)((instruction >> 31) & 0x1) << 20 // imm[20]
  // sign extend
  if (instruction & 0x100000 != 0) {
    immediate |= 0xFFFFFFFFFFF00000
  }

  return UTypeInstruction {
    rd = (u8) (instruction >> 7) & 0x1F,
    imm = transmute(i64) immediate
  }
}


exec_load :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
exec_fence :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}

exec_op_imm :: proc(m: ^Machine, instruction: ^ITypeInstruction) {
  switch Op_Imm_Funct3_Kind(instruction.funct3) {
    case .addi:
      m.x[instruction.rd].i = m.x[instruction.rs1].i + instruction.imm
    case .slti:
      m.x[instruction.rd].i = m.x[instruction.rs1].i < instruction.imm
    case .sltiu:
      m.x[instruction.rd].u = m.x[instruction.rs1].u < transmute(u64)instruction.imm
    case .sri:
      // check for shift right cases (arithmetic vs not)
      m.x[instruction.rd].u = m.x[instruction.rs1].u >> transmute(u64)instruction.imm
    case .xori:
      m.x[instruction.rd].u = m.x[instruction.rs1].u ~ transmute(u64)instruction.imm
    case .ori:
      m.x[instruction.rd].u = m.x[instruction.rs1].u | transmute(u64)instruction.imm
    case .andi:
      m.x[instruction.rd].u = m.x[instruction.rs1].u & transmute(u64)instruction.imm
    case .slli:
      m.x[instruction.rd].u = m.x[instruction.rs1].u << transmute(u64)instruction.imm
  }
}

exec_auipc :: proc(m: ^Machine, instruction: ^UTypeInstruction) {}
exec_op_imm_32 :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
exec_store :: proc(m: ^Machine, instruction: ^STypeInstruction) {}
exec_store_FP :: proc(m: ^Machine) {}

exec_op :: proc(m: ^Machine, instruction: ^RTypeInstruction) {
  switch Op_Funct3_Kind(instruction.funct3) {
    case .add:
      m.x[instruction.rd].i = m.x[instruction.rs1].i + m.x[instruction.rs2].i
    case .slt:
      m.x[instruction.rd].i = m.x[instruction.rs1].i < m.x[instruction.rs2].i
    case .sltu:
      m.x[instruction.rd].u = m.x[instruction.rs1].u < transmute(u64)m.x[instruction.rs2]
    case .sr:
      // check for shift right cases (arithmetic vs not)
      m.x[instruction.rd].u = m.x[instruction.rs1].u >> transmute(u64)m.x[instruction.rs2]
    case .xor:
      m.x[instruction.rd].u = m.x[instruction.rs1].u ~ transmute(u64)m.x[instruction.rs2]
    case .or:
      m.x[instruction.rd].u = m.x[instruction.rs1].u | transmute(u64)m.x[instruction.rs2]
    case .and:
      m.x[instruction.rd].u = m.x[instruction.rs1].u & transmute(u64)m.x[instruction.rs2]
    case .sll:
      m.x[instruction.rd].u = m.x[instruction.rs1].u << transmute(u64)m.x[instruction.rs2]
  }
}

exec_lui :: proc(m: ^Machine, instruction: ^UTypeInstruction) {}
exec_op_32 :: proc(m: ^Machine, instruction: ^RTypeInstruction) {}
exec_op_FP :: proc(m: ^Machine) {}
exec_op_V :: proc(m: ^Machine) {}
exec_branch :: proc(m: ^Machine, instruction: ^STypeInstruction) {}
exec_jal :: proc(m: ^Machine, instruction: ^UTypeInstruction) {}
exec_jalr :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}
exec_system :: proc(m: ^Machine, instruction: ^ITypeInstruction) {}