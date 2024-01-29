extends Control

@export var exit_game_normal = preload("res://assets/sprites/main_menu/Exit.png")
@export var exit_game_hover = preload("res://assets/sprites/main_menu/Exit Hover.png")
@export var play_game_normal = preload("res://assets/sprites/main_menu/Play.png")
@export var play_game_hover = preload("res://assets/sprites/main_menu/Play Hover.png")

func _ready():
	$PlayGame.mouse_entered.connect(_play_mouse_entered)
	$PlayGame.mouse_exited.connect(_play_mouse_exited)
	
	$ExitGame.mouse_entered.connect(_exit_mouse_entered)
	$ExitGame.mouse_exited.connect(_exit_mouse_exited)
	
func _play_mouse_entered():
	$Play.texture = play_game_hover
	
func _play_mouse_exited():
	$Play.texture = play_game_normal

func _exit_mouse_entered():
	$Exit.texture = exit_game_hover
	
func _exit_mouse_exited():
	$Exit.texture = exit_game_normal
