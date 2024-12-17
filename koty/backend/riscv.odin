package compiler_backend

Opcode_Kind :: enum u8 {
  Load      = 0b0000011,
  Load_FP   = 0b0000111,
  Op_Imm    = 0b0010011,
  Auipc     = 0b0010111,
  Op_Imm_32 = 0b0011011,
  Store     = 0b0100011, 
  Store_FP  = 0b0100111,
  Op        = 0b0110011,
  Lui       = 0b0110111,
  Op_32     = 0b0111011,
  Op_FP     = 0b1010011,
  Op_V      = 0b1010111,
  Branch    = 0b1100011,
  Jalr      = 0b1100111,
  Jal       = 0b1101111,
  System    = 0b1110011,
}

RiscV_RType :: bit_field u32 {
  opcode: u8 | 7,
  
}