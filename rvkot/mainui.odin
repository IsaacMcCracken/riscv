package rvkot

import mu "vendor:microui"
import rl "vendor:raylib"
import "core:fmt"

buf: [512]u8
buflen := 0




all_windows :: proc(ctx: ^mu.Context) {
  mu.begin(ctx)

  sw, sh := window_get_screen_size()

  if mu.window(ctx, "Everything", {0,0,sw,sh}, mu.Options{}) {
    mu.set_clip(ctx, {0, 0, sw, sh})
    @static cursor: int
    @static buf: [4096]u8


    mu.layout_row(ctx, {-100, -1})
    textbox := mu.textbox(ctx, buf[:], &cursor, mu.Options{.AUTO_SIZE})
    if .SUBMIT in textbox {
      fmt.println("Fart Squad!", string(buf[:cursor]))
    }

    if .SUBMIT in mu.button(ctx, "Submit") {
      fmt.println("FART:", string(buf[:cursor]))
    }

  }
  
  mu.end(ctx)
}