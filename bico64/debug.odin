package bico64
import "core:fmt"

print_prog_mem :: proc(m: ^Machine) {
  // print first four words of memory
  for j := 0; j < 4; j += 1{
    for i:= 0; i < 4; i += 1 {
      fmt.printf("%X ", m.memory[i])
    }
    fmt.print("  ")
  }
  fmt.println()
}

print_regs :: proc(m: ^Machine) {
  for i := 0; i < len(m.x); i+=1 {
    fmt.printf("%X ", m.x[i].u)
  }
  fmt.println()
}