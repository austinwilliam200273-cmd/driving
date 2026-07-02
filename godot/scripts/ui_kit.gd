# UiKit: shared helpers for styled UI — rounded buttons with hover/pressed
# states, translucent panels, sky-gradient backgrounds and a soft vignette.
# All static so every screen shares one consistent look.
class_name UiKit

const INK := Color(0.10, 0.13, 0.18)
const INK_SOFT := Color(0.30, 0.38, 0.48)
const PRIMARY := Color(0.93, 0.42, 0.10)
const PRIMARY_DARK := Color(0.70, 0.28, 0.04)
const SLATE := Color(0.32, 0.40, 0.50)
const SLATE_DARK := Color(0.22, 0.28, 0.36)
const PANEL_BG := Color(1, 1, 1, 0.88)
const PANEL_DARK := Color(0.08, 0.11, 0.17, 0.72)

static func box(bg: Color, radius: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(int(radius))
	return sb

static func button(parent: Node, text: String, pos: Vector2, size: Vector2, fsize: int, primary := true) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.custom_minimum_size = size
	b.add_theme_font_size_override("font_size", fsize)
	var base := PRIMARY if primary else SLATE
	var shade := PRIMARY_DARK if primary else SLATE_DARK
	var nb := box(base, 16)
	nb.border_width_bottom = 6
	nb.border_color = shade
	b.add_theme_stylebox_override("normal", nb)
	var hb: StyleBoxFlat = nb.duplicate()
	hb.bg_color = base.lightened(0.10)
	b.add_theme_stylebox_override("hover", hb)
	var pb: StyleBoxFlat = nb.duplicate()
	pb.bg_color = base.darkened(0.10)
	pb.border_width_bottom = 2
	b.add_theme_stylebox_override("pressed", pb)
	var db: StyleBoxFlat = nb.duplicate()
	db.bg_color = Color(base.r, base.g, base.b, 0.35)
	db.border_color = Color(shade.r, shade.g, shade.b, 0.35)
	b.add_theme_stylebox_override("disabled", db)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.55))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 0.85))
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.28))
	b.add_theme_constant_override("outline_size", 4)
	parent.add_child(b)
	return b

static func panel(parent: Node, pos: Vector2, size: Vector2, bg: Color = PANEL_BG, radius := 18.0) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	p.add_theme_stylebox_override("panel", box(bg, radius))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(p)
	return p

static func label(parent: Node, text: String, pos: Vector2, fsize: int, color: Color, center_w := 0.0) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", color)
	if center_w > 0.0:
		l.size = Vector2(center_w, fsize + 12)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

static func title(parent: Node, text: String, pos: Vector2, fsize: int, color: Color, center_w := 0.0) -> Label:
	var l := label(parent, text, pos, fsize, color, center_w)
	l.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.75))
	l.add_theme_constant_override("outline_size", int(fsize / 9.0))
	return l

# A small keyboard key drawing (for the controls onboarding overlay).
static func keycap(parent: Node, text: String, pos: Vector2, size := 58.0) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = Vector2(size, size)
	var sb := box(Color(0.97, 0.97, 0.99), 10)
	sb.border_width_bottom = 6
	sb.set_border_width(SIDE_LEFT, 2)
	sb.set_border_width(SIDE_RIGHT, 2)
	sb.set_border_width(SIDE_TOP, 2)
	sb.border_color = Color(0.55, 0.60, 0.68)
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := Label.new()
	l.text = text
	l.size = Vector2(size, size - 8)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", int(size * 0.5))
	l.add_theme_color_override("font_color", INK)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	parent.add_child(p)
	return p

# Soft radial vignette over the whole screen (subtle depth / polish).
static func vignette(parent: Node, strength := 0.20) -> TextureRect:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	grad.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, strength)])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.0, 0.0)
	tex.width = 512
	tex.height = 288
	var tr := TextureRect.new()
	tr.texture = tex
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.size = Vector2(Consts.GAME_W, Consts.GAME_H)
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(tr)
	return tr

# Vertical sky gradient used behind the menu screens.
static func sky_background(parent: Node) -> TextureRect:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	grad.colors = PackedColorArray([Consts.SKY, Consts.SKY_LOW])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	tex.width = 64
	tex.height = 256
	var tr := TextureRect.new()
	tr.texture = tex
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.size = Vector2(Consts.GAME_W, Consts.GAME_H)
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(tr)
	return tr
