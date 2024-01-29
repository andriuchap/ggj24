extends Node

const main_menu_scene = preload("res://scenes/main_menu.tscn")
const game_scene = preload("res://scenes/game_scene.tscn")

var main_menu
var game

func _ready():
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	main_menu.get_node("PlayGame").pressed.connect(_start_game)
	main_menu.get_node("ExitGame").pressed.connect(_quit_game)

func _start_game():
	main_menu.queue_free()
	game = game_scene.instantiate()
	add_child(game)
	
func _quit_game():
	get_tree().quit()
