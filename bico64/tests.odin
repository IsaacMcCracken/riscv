package bico64

import "core:testing"
import "core:slice"
import "core:log"

@(test)
test_op :: proc(t: ^testing.T) {
  memory: [32]u8 // small mem because its a small test

  // set memory and create mmachine
  m := &Machine{
    memory = memory[:]
  }
  
  // addi t0, t1, 5
  m.x[5].i = -1 // t0 =-1 
  m.x[6].i = 5 // t1 = 5
  instruction : u32 = 0x00530293 // addi t0, t1, 5
  decode_execute(m, instruction)
  passed := testing.expect_value(t, m.x[5].i, 5+5)
  log.infof("got %i expecting %i", m.x[5].i, 5+5)
}


@(test)
test_op_imm :: proc(t: ^testing.T) {
  memory: [32]u8 // small mem because its a small test
  // set memory and create mmachine
  m := &Machine{
    memory = memory[:]
  }

  // add  s0, s0, t0
  m.x[8].i = 6  // s0 = 6
  m.x[5].i = -5 // t0 = -5
  instruction : u32 = 0x00540433  // add  s0, s0, t0
  decode_execute(m, instruction)
  passed := testing.expect_value(t, m.x[8].i, 6-5)
  log.infof("got %i expecting %i", m.x[8].i, 6-5)
}