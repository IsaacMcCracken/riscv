package rvkot

import rl "vendor:raylib"
import "core:strings"



window_init :: proc(width, height: u32, title: string) {
  rl.InitWindow(i32(width), i32(height), strings.unsafe_string_to_cstring(title))
}

window_close :: proc() {
  rl.CloseWindow()
}

window_running :: proc() -> bool {
  return !rl.WindowShouldClose()
}

begin_drawing :: proc() {
  rl.BeginDrawing()
}

end_drawing :: proc() {
  rl.EndDrawing()
}



window_set_clipboard :: proc(user_data: rawptr, text: string) -> (ok: bool) {
  cstr, err := strings.clone_to_cstring(text, context.temp_allocator)
  if err == .None {
    rl.SetClipboardText(cstr)
    return true
  }

  return false
}


window_get_mouse_position :: proc() -> (x, y: i32) {
  return i32(rl.GetMouseX()), i32(rl.GetMouseX())
}

window_get_mouse_scroll :: proc() -> (x, y: i32) {
  v := rl.GetMouseWheelMoveV()
  return i32(v.x * -30), i32(v.y * -30)
}

window_get_clipboard :: proc(user_data: rawptr) -> (text: string, ok: bool) {
  return string(rl.GetClipboardText()), true
}

window_get_screen_size :: proc() -> (w, h: i32) {
  return rl.GetScreenWidth(), rl.GetScreenHeight()
}

window_get_position :: proc() -> (x, y: i32) {
  pos := rl.GetWindowPosition()
  return i32(pos.x), i32(pos.y)
}