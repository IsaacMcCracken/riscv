package riscv_assembler


import "core:os"
import "core:strings"
import "core:unicode/utf8"
import "core:text/scanner"
import "core:unicode"
import "core:fmt"
import "core:math"

smap := map[string]Token_Kind{
  // i-type instructions
  "addi" = .Addi,
  "jalr" = .Jalr,
  // r-type instructions
  "add" = .Add,

  // named registers
  "zero" = .Zero,
  "ra" = .RA,
  "sp" = .SP,
  "gp" = .GP,
  "tp" = .TP,
  "t0" = .T0,
  "t1" = .T1,
  "t2" = .T2,
  "fp" = .FP, "s0" = .FP,
  "s1" = .S1,
  "a0" = .A0,
  "a1" = .A1,
  "a2" = .A2,
  "a3" = .A3,
  "a4" = .A4,
  "a5" = .A5,
  "a6" = .A6,
  "a7" = .A7,
  "s2" = .S2,
  "s3" = .S3,
  "s4" = .S4,
  "s5" = .S5,
  "s6" = .S6,
  "s7" = .S7,
  "s8" = .S8,
  "s9" = .S9,
  "s10" = .S10,
  "s11" = .S11,
  "t3" = .T3,
  "t4" = .T4,
  "t5" = .T5,
  "t6" = .T6,
  // numbered registers
  "x0" = .Zero,
  "x1" = .RA,
  "x2" = .SP,
  "x3" = .GP,
  "x4" = .TP,
  "x5" = .T0,
  "x6" = .T1,
  "x7" = .T2,
  "x8" = .FP,
  "x9" = .S1,
  "x10" = .A0,
  "x11" = .A1,
  "x12" = .A2,
  "x13" = .A3,
  "x14" = .A4,
  "x15" = .A5,
  "x16" = .A6,
  "x17" = .A7,
  "x18" = .S2,
  "x19" = .S3,
  "x20" = .S4,
  "x21" = .S5,
  "x22" = .S6,
  "x23" = .S7,
  "x24" = .S8,
  "x25" = .S9,
  "x26" = .S10,
  "x27" = .S11,
  "x28" = .T3,
  "x29" = .T4,
  "x30" = .T5,
  "x31" = .T6,

}

itype_funct3 := #partial [Token_Kind]u8 {
  .Addi = 0x0,
  .Jalr = 0x0
}

rtype_funct3 := #partial [Token_Kind]u8 {
  .Add = 0x0,
}

rtype_funct7 := #partial [Token_Kind]u8 {
  .Add = 0x00
}

Token_Kind :: enum u16 {
  Invalid,
  Number,
  Newline,
  Comma,
  Colon,
  Identifier,
  Zero,
  RA,
  SP,
  GP,
  TP,
  T0,
  T1,
  T2,
  FP,
  S1,
  A0,
  A1,
  A2,
  A3,
  A4,
  A5,
  A6,
  A7,
  S2,
  S3,
  S4,
  S5,
  S6,
  S7,
  S8,
  S9,
  S10,
  S11,
  T3,
  T4,
  T5,
  T6,

  Addi,
  Jalr,
  Add,
}

IType :: bit_field u32 {
  opcode: u8 | 7,
  rd: u8 | 5,
  funct3: u8 | 3,
  rs1: u8 | 5,
  imm: u16 | 12,
}

RType :: bit_field u32 {
  opcode: u8 | 7,
  rd: u8 | 5,
  funct3: u8 | 3,
  rs1: u8 | 5,
  rs2: u8 | 5,
  funct7: u8 | 7,
}

Token :: struct {
  kind: Token_Kind,
  start, end: u32
}



Assembler :: struct {
  text: []byte, //
  tokens: [dynamic]Token,
  lines: [dynamic]u32, // contains the end of the line
  instructions: [dynamic]u32, // to do add compressed instructions
  data: [dynamic]u8,
  errors: [dynamic]string
}




append_token :: proc(a: ^Assembler, start, end: u32, kind: Token_Kind) {
  append(&a.tokens, Token{start = start, end = end, kind = kind})
}

// todo find better name

get_string_token :: proc(s: string) -> Token_Kind {
  kind, ok := smap[s]
  if ok do return kind
  return .Identifier
}

assembler_init :: proc(a: ^Assembler, text: []byte, allocator:=context.allocator) -> (asmbler: ^Assembler) {
  a.text = text
  a.instructions = make([dynamic]u32, 0, 128)
  a.data = make([dynamic]u8)
  a.tokens = make([dynamic]Token, 0, 128)
  a.lines = make([dynamic]u32, 0, 128)

  return a
}

get_pos :: proc(a: ^Assembler, index: u32) -> (line, col: u32) {
  start: u32 = 0
  for end, line in a.lines {
    if index >= start && index < end {
      return u32(line), index - start
    }

    start = end
  }

  return 0, 0
}

find_lines :: proc(a: ^Assembler) {
  assert(a.tokens != nil)
  assert(a.lines != nil)

  for tok in a.tokens {
    if tok.kind == .Newline {
      append(&a.lines, tok.start)
    }
  }
}

scan :: proc(a: ^Assembler) {
  assert(a.text != nil)
  assert(a.tokens != nil)

  curr, prev: u32
  parsing: for curr < u32(len(a.text)) {
    prev = curr
    
    switch a.text[curr] {
      case ' ', '\t':
        curr += 1
        continue parsing
      case 'a'..='z', 'A'..='Z':
        for unicode.is_alpha(rune(a.text[curr])) || unicode.is_digit(rune(a.text[curr])) {
          curr += 1
        }
        append_token(a, prev, curr, get_string_token(string(a.text[prev:curr])))
      case '\n':
        curr += 1
        append_token(a, prev, curr, .Newline)
      case ':':
        curr += 1
        append_token(a, prev, curr, .Colon)
      case ',':
        curr += 1
        append_token(a, prev, curr, .Comma)
      case '0'..='9':
        // todo add hex, octal, binary
        for unicode.is_digit(rune(a.text[curr])) {
          curr += 1
        }
        append_token(a, prev, curr, .Number)
      case 0:
        break parsing

    }
    
  }
}

parse :: proc(a: ^Assembler) {
  assert(a.lines != nil)
  assert(a.instructions != nil)
  assert(a.tokens != nil)
  assert(a.errors != nil)

  for i: u32 = 0; i < u32(len(a.tokens)); i += 1 {
    tok := a.tokens[i]
    #partial switch tok.kind {
      case .Addi:
        produce_itype(a, &i, 0b0010011)
      case .Jalr:
        produce_itype(a, &i, 0b1100111)
      case .Add:
        produce_rtype(a, &i)
      case:
    }

    // assert(tokens[i].kind == .Newline)
  } 
}





is_register_token :: proc(kind: Token_Kind) -> bool {
  return u32(kind) >= u32(Token_Kind.Zero) && u32(kind) <= u32(Token_Kind.T6)
}

token_expect :: proc(tokens: ^[dynamic]Token, place: u32, expect: Token_Kind) -> bool {
  return tokens[place].kind == expect
}

advance_to_newline :: proc(tokens: ^[dynamic]Token, curr: ^u32, errors: ^[dynamic]string) {
  for curr^ < u32(len(tokens)) && tokens[curr^].kind != .Newline {
    curr^ += 1
  }

  if tokens[curr^].kind != .Newline {
    append(errors, "Expected newline")
    return 
  }

  // curr += 1
}

produce_rtype :: proc(a: ^Assembler, curr: ^u32){
  tok := a.tokens[curr^]
  funct3 := rtype_funct3[tok.kind]
  funct7 := rtype_funct7[tok.kind]


  regs: [3]u8
  for &reg, i in regs {
    curr^ += 1
    tok = a.tokens[curr^]
  
    if !is_register_token(tok.kind) {
      // Todo better error system
      append(&a.errors, "Expected a register token here:")
      advance_to_newline(&a.tokens, curr, &a.errors)
      return  
    } else {
      reg = u8(tok.kind) - u8(Token_Kind.Zero) 
      assert(reg < 32)
    }
  
    curr^ += 1
    tok = a.tokens[curr^]
  
    if i != 2 && !token_expect(&a.tokens, curr^, .Comma) {
      append(&a.errors, "Expected a comma at: ")
      advance_to_newline(&a.tokens, curr, &a.errors)
      return 
    }
  }

  instruction := RType {
    opcode = 0b0110011,
    rd = regs[0],
    funct3 = funct3,
    rs1 = regs[1],
    rs2 = regs[2],
    funct7 = funct7,
  }


  append(&a.instructions, transmute(u32)instruction)
}

produce_itype :: proc(a: ^Assembler, curr: ^u32, opcode: u8) {
  tok := a.tokens[curr^]
  funct3 := itype_funct3[tok.kind]

  regs: [2]u8
  for &reg, i in regs {
    curr^ += 1
    tok = a.tokens[curr^]
  
    if !is_register_token(tok.kind) {
      
      line, col := get_pos(a, tok.start)
      msg := fmt.tprintf("Error (%d, %d): expected comma.", line, col)
      append(&a.errors, "Expected a register token here:")
      advance_to_newline(&a.tokens, curr, &a.errors)
      return  
    } else {
      reg = u8(tok.kind) - u8(Token_Kind.Zero) 
      fmt.println(reg)
      assert(reg < 32)
    }
  
    curr^ += 1
    tok = a.tokens[curr^]
  
    if !token_expect(&a.tokens, curr^, .Comma) {
      line, col := get_pos(a, tok.start)
      msg := fmt.tprintf("Error (%d, %d): expected comma.", line, col)
      append(&a.errors, msg)
      advance_to_newline(&a.tokens, curr, &a.errors)
      return 
    }
  }

  curr^ += 1
  tok = a.tokens[curr^]

  if !token_expect(&a.tokens, curr^, .Number) {
    append(&a.errors, "Expected a number literal here")
    advance_to_newline(&a.tokens, curr, &a.errors)
    return
  }
  imm: u16 = 69 //todo make this actually work

  instruction := IType {
    opcode = opcode,
    rd = regs[0],
    funct3 = funct3,
    rs1 = regs[1], 
    imm = imm,
  }
  
  append(&a.instructions, transmute(u32)instruction)
} 
