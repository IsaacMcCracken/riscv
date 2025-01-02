package riscv_assembler

import "core:fmt"
import "core:unicode"
import "base:runtime"
import "core:os"
import "core:flags/example"

assemble :: proc(a: ^Assembler) {
  scan(a)
  find_lines(a)
  parse(a)
}

main ::  proc() {
  
  
  test : []byte = transmute([]byte)string("addi a0, a0, 69\nadd sp, gp, t0\n")

  a := assembler_init(&{}, test)
  assemble(a)
  

  for instr in a.instructions {
    fmt.printfln("0x%08x", instr)
  }
  



}