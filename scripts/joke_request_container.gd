extends Node

@export var symbol_tex: Array[Texture2D]

func _update_by_joke_data(joke_data):
	if joke_data == null:
		self.visible = false
		return
	self.visible = true
	var symbols = $MarginContainer/HBoxContainer.get_children()
	for i in range(symbols.size()):
		if i < joke_data.joke_sequence.size():
			symbols[i].visible = true
			symbols[i].texture = symbol_tex[joke_data.joke_sequence[i]]
		else:
			symbols[i].visible = false
