package bico64

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
  imm: i32, // immediate sign extended to 32 bits (for 32 bit mode)
  rd: u8, // destination register
  funct3: u8
}

decode_i_type :: proc(instruction: u32) -> ITypeInstruction {
  immediate := (instruction >> 20) * 0xFFF
  // sign extend immediate if bit 11 is set
  if (immediate & 0x800 != 0) {
      immediate |= 0xFFFFF000
  }

  return ITypeInstruction {
      rs1 = (u8) (instruction >> 15) & 0x1F,
      imm = transmute(i32) immediate,
      rd = (u8) (instruction >> 7) & 0x1F,
      funct3 = (u8) (instruction >> 12) & 0x7
  }
}

  
// combined S (store {byte|half|word}) & SB (branch instructions)
STypeInstruction :: struct {
  rs1: u8, // source register
  rs2: u8, // target register
  imm: i32, // immediate sign extended to 32 bits (for 32 bit mode)
  funct3: u8
}

decode_s_type :: proc(instruction: u32) -> STypeInstruction {
  immediate := (instruction >> 7) & 0x1F // imm[4:0]
  immediate |= ((instruction >> 25) & 0x7F) << 5 // imm[11:5]
  // sign extend
  if (immediate & 0x800 != 0) {
    immediate |= 0xFFFFF000
  }

  return STypeInstruction {
    rs1 = (u8) (instruction >> 15) & 0x1F,
    rs2 = (u8) (instruction >> 20) & 0x1F,
    imm = transmute(i32) immediate,
    funct3 = (u8) (instruction >> 12) & 0x7
  }
}

decode_sb_type :: proc(instruction: u32)  -> STypeInstruction {
  immediate := ((instruction >> 8) & 0x1F) << 1 // imm[4:0]
  immediate |= ((instruction >> 25) & 0x3F) << 5 // imm[10:5]
  immediate |= ((instruction >> 7) & 0x1) << 11 // imm[11]
  immediate |= ((instruction >> 31) & 0x1) << 12 // imm[12]
  // sign extend
  if (immediate & 0x1000 != 0) {
    immediate |= 0xFFFFF000 // overlaps 12th bit but its or so who cares
  }
  
  return STypeInstruction {
    rs1 = (u8) (instruction >> 15) & 0x1F,
    rs2 = (u8) (instruction >> 20) & 0x1F,
    imm = transmute(i32) immediate,
    funct3 = (u8) (instruction >> 12) & 0x7
  }
}


// combined U (lui, auipc) & UJ (jal)
UTypeInstruction :: struct {
  rd: u8, // destination register
  imm: i32, // immediate sign extended to 32 bits (for 32 bit mode)
}

decode_u_type :: proc(instruction: u32) -> UTypeInstruction {
  return UTypeInstruction {
    rd = (u8) (instruction >> 7) & 0x1F,
    imm = (i32) (instruction & 0xFFFFF000) // sets bottom 11:0 bits to 0
  }
}

decode_uj_type :: proc(instruction: u32) -> UTypeInstruction {
  immediate := ((instruction >> 21) & 0x3FF) << 1 // imm[10:1]
  immediate |= ((instruction >> 20) & 0x1) << 11 // imm[11]
  immediate |= ((instruction >> 12) & 0xFF) << 12 // imm[19:12]
  immediate |= ((instruction >> 31) & 0x1) << 20 // imm[20]
  // sign extend
  if (instruction & 0x100000 != 0) {
    immediate |= 0xFFF00000
  }

  return UTypeInstruction {
    rd = (u8) (instruction >> 7) & 0x1F,
    imm = transmute(i32) immediate
  }
}