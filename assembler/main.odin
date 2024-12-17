package riscv_assembler

import "core:fmt"

IType_Instruction :: bit_field u32 {
  opcode: u8 | 7,
  rd: u8 | 5,
  func3: u8 | 3,
  rs: u8 | 5,
  imm: u16 | 12,
}

RType_Instruction :: bit_field u32 {
  opcode: u8 | 7,
  rd: u8 | 5,
  func3: u8 | 3,
  rs1: u8 | 5,
  rs2: u8 | 5,
  func7: u8 | 7,
}

Opcode :: enum u8 {
  Invalid = 0,
}

opcode_map: map[string]u8 = {
  "add" = 0b0110011,
  "sub" = 0b0110011,
  "xor" = 0b0110011,
  "or" = 0b0110011,
  "and" = 0b0110011,
  "sll" = 0b0110011,
}

funct3_map: map[string]u8 = {
  "add" = 0x0,
  "sub" = 0x0,
  "xor" = 0x4,
  "or" =  0x6,
  "and" = 0x7,
}

funct7_map: map[string]u8 = {
  "add" = 0x00,
  "sub" = 0x20,
  "xor" = 0x00,
  "or" =  0x00,
  "and" = 0x00,
}

test := transmute([]byte)string("add x3, x4, x5")

main :: proc() {
  rtype := RType_Instruction{}
  
}