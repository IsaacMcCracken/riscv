package rvkot

import mu "vendor:microui"
import rl "vendor:raylib"
import "core:fmt"

buf: [512]u8
buflen := 0

all_windows :: proc(ctx: ^mu.Context) {
  mu.begin(ctx)

  sw, sh := window_get_screen_size()
  if mu.window(ctx, "Everything", {0,0,sw,sh}, {.NO_CLOSE, .EXPANDED, .NO_TITLE}) {
    if mu.layout_column(ctx) {
      if .ACTIVE in mu.header(ctx, "string") {
        mu.label(ctx, "CUM GUTTERS")
      }

      if .ACTIVE in mu.header(ctx, "Cum man") {
        mu.label(ctx, "hello my name is elder price")
      }
    }

  }
  
  mu.end(ctx)
}