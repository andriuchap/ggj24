extends Control

@export var card_textures: Array[Texture2D]

@onready var pick_btn = $MarginContainer/PickBtn

#@onready var flavor_label = $MarginContainer/VBoxContainer/HBoxContainer/FlavorLabel
#@onready var symbol = $MarginContainer/VBoxContainer/HBoxContainer/CardSymbol

var panel_style_box
signal on_joke_selected(joke)

func _ready():
	$Button.pressed.connect(_button_pressed)
	panel_style_box = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", panel_style_box)

func set_joke_texture(joke):
	panel_style_box.texture = card_textures[joke]
	
func _set_btn_enabled(value):
	$Button.disabled = !value
	pick_btn.visible = value

func _button_pressed():
	on_joke_selected.emit(self)
