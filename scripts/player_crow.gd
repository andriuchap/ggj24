extends Node2D

@export var mic_loc = Vector2.ZERO

signal joke_finished

func _ready():
	$Walk.finished_walking.connect(_finished_walking)
	$JokeCaw.finished.connect(_joke_finished)

func walk_to_mic():
	$Crow.walk()
	$Walk.start_walking(mic_loc)

func _finished_walking():
	$Crow.idle()

func _tell_joke():
	$JokeCaw.play()
	$ChatBubble.visible = true

func _joke_finished():
	$ChatBubble.visible = false
	joke_finished.emit()
