package riscv_assembler

import "core:strings"
import "base:runtime"


Token_Kind :: enum u32 {
  Invalid,
  Newline,
  Comment,
  Number,
  Character,
  String,
  Comma,
  Reg, 
  // Instructions
  Addi,
}

Token :: struct {
  start, end: u32,
  kind: Token_Kind
}

Error :: struct {
  msg: string
}

Tokenizer :: struct {
  text: []u8,
  curr, prev: u32,
  tokens: [dynamic]Token,
  errors: [dynamic]Error,
}

tokenize :: proc(t: ^Tokenizer) {
  for i := 0; t.curr < u32(len(t.text)); {
    t.prev = t.curr


    switch t.text[t.curr] {
      case 'A'..='Z', 'a'..='z':
        
      case '0'..='9':

      case '.':
      
      case '"':
      case '#':
        for t.text[t.curr] != '\n' {
          t.curr += 1
        }
        append(&t.tokens, Token{t.prev, t.curr, .Comment})
        t.curr += 1

      case '\'':
        t.curr += 1
        if t.text[t.curr] == '\\' do t.curr += 1
        t.curr += 1
        if t.text[t.curr] != '\'' {
          append(&t.errors, Error{msg="Oh No: character literal not formated correctly"})
        }
      case '\n':
        t.curr += 1
        append(&t.tokens, Token{t.prev, t.curr, .Newline})

      case ',':
        t.curr += 1
        append(&t.tokens, Token{t.prev, t.curr, .Newline})

    }
  }
}