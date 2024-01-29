extends Node2D

var liked_joke: Enums.JokeType
var disliked_joke: Enums.JokeType

var laugh_level = 0

const MAX_LAUGH_LEVEL = 3
const MIN_LAUGH_LEVEL = -3

var target_location = Vector2.ZERO 

func set_liked_joke(joke_type):
	liked_joke = joke_type

func set_disliked_joke(joke_type):
	disliked_joke = joke_type

func evaluate_joke(joke_type):
	var joke_funniness = is_joke_funny(joke_type)
	if joke_funniness > 0:
		update_laugh_level(2)
		$Crow.laugh()
	elif joke_funniness < 0:
		update_laugh_level(-2)
		$Crow.angry()
	else:
		update_laugh_level(1)
		$Crow.chuckle()

func update_laugh_level(amount):
	laugh_level = clamp(laugh_level + amount, MIN_LAUGH_LEVEL, MAX_LAUGH_LEVEL)

func is_joke_funny(joke_type):
	if joke_type == liked_joke || joke_type == Enums.JokeType.ANY:
		return 1
	elif joke_type == disliked_joke:
		return -1
	else:
		return 0
		
func laugh():
	$Crow.laugh()

func walk_to_audience():
	$Walk.start_walking(target_location)
	$Walk.finished_walking.connect(_finished_walking)
	$Crow.walk()

func _finished_walking():
	$Crow.idle()
