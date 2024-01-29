extends Control

var symbols = []
var is_picking = false

@export var symbol_tex: Array[Texture2D]
@export var action_tex: Array[Texture2D]

@onready var action_btn = $MarginContainer2/ActionButton

signal on_picked(inventory_item)
signal on_told(inventory_item)

func _ready():
	symbols = $MarginContainer/HBoxContainer.get_children()
	for sym in symbols:
		sym.visible = false
	action_btn.visible = false
	$Button.pressed.connect(_btn_pressed)
	
func _set_symbols(joke_symbols):
	for sym in symbols:
		sym.visible = false
	for i in range(joke_symbols.size()):
		symbols[i].visible = true
		symbols[i].texture = symbol_tex[joke_symbols[i]]
	
func _set_button_enabled(value):
	$Button.disabled = !value

func _set_for_picking(value):
	is_picking = value
	$Button.disabled = !value
	action_btn.visible = value
	if value:
		action_btn.texture = action_tex[0]

func _set_for_telling(value):
	is_picking = false
	$Button.disabled = !value
	action_btn.visible = value
	if value:
		action_btn.texture = action_tex[1]

func _pick_item():
	on_picked.emit(self)

func _tell_joke():
	on_told.emit(self)

func _btn_pressed():
	if is_picking:
		_pick_item()
	else:
		_tell_joke()
