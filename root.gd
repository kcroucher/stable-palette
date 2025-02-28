extends Node2D


const GRAY_REC709 = Vector3(0.2126, 0.7152, 0.0722)
const SUB_TABLE_SIZE = 64
const SUB_TABLE_WIDTH = SUB_TABLE_SIZE * SUB_TABLE_SIZE
const SUB_TABLE_HEIGHT = SUB_TABLE_SIZE

# 0 = effect off, 1 = effect on, 2 = effect + mouse light
var mode: int;

func change_mode(change: int) -> void:
	mode = posmod(mode + change, 3)

func get_neutral_rgb(x: int, y: int) -> Vector3:
	var fx = float(x)
	var fy = float(y)
	return Vector3(
		fmod(fx, SUB_TABLE_SIZE) / (SUB_TABLE_SIZE - 1),
		fy / (SUB_TABLE_SIZE - 1),
		floor(fx / SUB_TABLE_SIZE) * 1.0 / float(SUB_TABLE_SIZE - 1),
	)
	
func get_key_color(x: int, y: int, keys: Array) -> Color:
	var neutral = get_neutral_rgb(x, y)
	var neutral_gray = neutral * GRAY_REC709
	
	var min_distance = INF
	var key_pixel: Color
	for key in keys:
		var key_vec3 = Vector3(key.r, key.g, key.b)
		var key_gray = key_vec3 * GRAY_REC709
		var diff = neutral_gray - key_gray
		var diff_len = diff.length()
		
		if diff_len < min_distance:
			min_distance = diff_len
			key_pixel = key
			
	return key_pixel
	
func create_lut():
	var ramps_png = Image.new()
	ramps_png.load("res://ramps.png")
	
	var ramps = {}
	for x in range(ramps_png.get_width()):
		var key = ramps_png.get_pixel(x, 0)
		var ramp = []
		for y in range(ramps_png.get_height() - 1, 0, -1):
			ramp.append(ramps_png.get_pixel(x, y))
		ramps[key] = ramp
	var keys = ramps.keys()
	
	var lut_width = SUB_TABLE_WIDTH
	var lut_height = SUB_TABLE_HEIGHT * (ramps_png.get_height() - 1)
	var lut = Image.create_empty(lut_width, lut_height, false, Image.Format.FORMAT_RGBA8)
	for x in range(SUB_TABLE_WIDTH):
		for y in range(SUB_TABLE_HEIGHT):
			var key_pixel = get_key_color(x, y, keys)
			var ramp = ramps[key_pixel]
			for i in range(len(ramp)):
				lut.set_pixel(x, y + (i * SUB_TABLE_HEIGHT), ramp[i])
				
	lut.save_png("lut.png")
	
func _ready():
	mode = 0
	
	create_lut()
	var lut = load("res://lut.png")
	$Sprite2D.material.set_shader_parameter("lut", lut)
	
	$Sprite2D.material.set_shader_parameter("sub_table_size", SUB_TABLE_SIZE)
	$Sprite2D.material.set_shader_parameter("brightness_levels", 5)
	
func _process(delta):
	var mouse = get_viewport().get_mouse_position()
	$Sprite2D.material.set_shader_parameter("mouse", mouse)
	
	var change = 0;
	if Input.is_action_just_pressed("left"):
		change -= 1;
	if Input.is_action_just_pressed("right"):
		change += 1;
	change_mode(change)
	$Sprite2D.material.set_shader_parameter("mode", mode)
