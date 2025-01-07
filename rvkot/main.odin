package rvkot

import mu "vendor:microui"
import "core:fmt"
import rl "vendor:raylib"
import "core:unicode/utf8"
// import "../bico64"

// State :: struct {

// }

atlas_texture: rl.Texture

main :: proc() {
	rl.SetWindowState({.WINDOW_RESIZABLE})
  window_init(1200, 900, "Risc V Kot Simulator")
  defer window_close() 


  ctx, _ := new(mu.Context, context.allocator)
  mu.init(ctx, window_set_clipboard, window_get_clipboard)

  pixels := make([][4]u8, mu.DEFAULT_ATLAS_WIDTH*mu.DEFAULT_ATLAS_HEIGHT)
	for alpha, i in mu.default_atlas_alpha {
		pixels[i] = {0xff, 0xff, 0xff, alpha}
	}
  
	image := rl.Image{
		data = raw_data(pixels),
		width   = mu.DEFAULT_ATLAS_WIDTH,
		height  = mu.DEFAULT_ATLAS_HEIGHT,
		mipmaps = 1,
		format  = .UNCOMPRESSED_R8G8B8A8,
	}
	atlas_texture = rl.LoadTextureFromImage(image)
  delete(pixels)
	defer rl.UnloadTexture(atlas_texture)
		
  ctx.text_width = mu.default_atlas_text_width
  ctx.text_height = mu.default_atlas_text_height

  rl.SetTargetFPS(60)
  mainloop: for window_running() {
    /* Input Update */

		{ // text input
			text_input: [512]byte = ---
			text_input_offset := 0
			for text_input_offset < len(text_input) {
				ch := rl.GetCharPressed()
				if ch == 0 {
					break
				}
				b, w := utf8.encode_rune(ch)
				copy(text_input[text_input_offset:], b[:w])
				text_input_offset += w
			}
			mu.input_text(ctx, string(text_input[:text_input_offset]))
		}
    mx, my := window_get_mouse_position()
    sx, sy := window_get_mouse_scroll()
    mu.input_mouse_move(ctx, mx, my)
    mu.input_scroll(ctx, sx, sy)
		

    microui_mouse_button_input(ctx, mx, my)
		microui_key_input(ctx)
    /* GUI Update /(*o*)\ */
		all_windows(ctx)

    /* Drawing */
    render(ctx)
    
    free_all(context.temp_allocator)
  }
}


microui_mouse_button_input :: proc(ctx: ^mu.Context, x, y: i32)  {
  @static buttons_to_key := [?]struct{
    rl_button: rl.MouseButton,
    mu_button: mu.Mouse,
  }{
    {.LEFT, .LEFT},
    {.RIGHT, .RIGHT},
    {.MIDDLE, .MIDDLE},
  }

  for b in buttons_to_key {
    if rl.IsMouseButtonPressed(b.rl_button) {
      mu.input_mouse_down(ctx, x, y, b.mu_button)
    } else {
      mu.input_mouse_up(ctx, x, y, b.mu_button)
    }
  }
}

microui_key_input :: proc(ctx: ^mu.Context) {
	@static keys :=[?]struct{rl_key: rl.KeyboardKey, mu_key: mu.Key} {
		{.LEFT_SHIFT, .SHIFT},
		{.LEFT_CONTROL, .SHIFT},
		{.LEFT_ALT, .ALT},
		{.BACKSPACE, .BACKSPACE},
		{.DELETE, .DELETE },
		{.ENTER, .RETURN },
		{.LEFT, .LEFT },
		{.RIGHT, .RIGHT },
		{.HOME, .HOME },
		{.END, .END },
		{.A, .A },
		{.X, .X },
		{.C, .C },
		{.V, .V },
	}

	for key in keys {
		if rl.IsKeyDown(key.rl_key) {
			mu.input_key_down(ctx, key.mu_key)
		} else {
			mu.input_key_up(ctx, key.mu_key)
		}
	}
}


render :: proc(ctx: ^mu.Context) {
	render_texture :: proc(rect: mu.Rect, pos: [2]i32, color: mu.Color) {
		source := rl.Rectangle{
			f32(rect.x),
			f32(rect.y),
			f32(rect.w),
			f32(rect.h),
		}
		position := rl.Vector2{f32(pos.x), f32(pos.y)}
		
		rl.DrawTextureRec(atlas_texture, source, position, transmute(rl.Color)color)
	}
	
	rl.ClearBackground(rl.DARKGRAY)
	
	rl.BeginDrawing()
	defer rl.EndDrawing()
	
	rl.BeginScissorMode(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight())
	defer rl.EndScissorMode()
	
	command_backing: ^mu.Command
	for variant in mu.next_command_iterator(ctx, &command_backing) {
		switch cmd in variant {
		case ^mu.Command_Text:
			pos := [2]i32{cmd.pos.x, cmd.pos.y}
			for ch in cmd.str do if ch&0xc0 != 0x80 {
				r := min(int(ch), 127)
				rect := mu.default_atlas[mu.DEFAULT_ATLAS_FONT + r]
				render_texture(rect, pos, cmd.color)
				pos.x += rect.w
			}
		case ^mu.Command_Rect:
			rl.DrawRectangle(cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h, transmute(rl.Color)cmd.color)
		case ^mu.Command_Icon:
			rect := mu.default_atlas[cmd.id]
			x := cmd.rect.x + (cmd.rect.w - rect.w)/2
			y := cmd.rect.y + (cmd.rect.h - rect.h)/2
			render_texture(rect, {x, y}, cmd.color)
		case ^mu.Command_Clip:
			rl.EndScissorMode()
			rl.BeginScissorMode(cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h)
		case ^mu.Command_Jump: 
			unreachable()
		}
	}
}

