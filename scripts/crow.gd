@tool
extends Node2D

@export var flip_h = false:
	set(flip):
		flip_h = flip
		$Sprite2D.flip_h = flip
		$Sprite2D2.flip_h = flip
		$CrowShadow.position.x = -$CrowShadow.position.x
		
@export var flip_v = false:
	set(flip):
		flip_v = flip
		$Sprite2D2.flip_v = flip
		$Sprite2D.flip_v = flip

func _ready():
	$Sprite2D.flip_h = flip_h
	$Sprite2D.flip_v = flip_v
	
	$AnimationPlayer.animation_finished.connect(_anim_finished)
	$AnimationPlayer.animation_changed.connect(_anim_changed)
	idle()

func laugh():
	$AnimationPlayer.play("laugh", 0.2)
	if randf() > 0.5:
		$Sprite2D2.play("laugh1")
	else:
		$Sprite2D2.play("laugh2")

func angry():
	$AnimationPlayer.play("angry", 0.2)
	
func chuckle():
	$AnimationPlayer.play("chuckle", 0.2)

func idle():
	print("idle")
	$AnimationPlayer.play("idle", 0.2)
	$AnimationPlayer.seek(randf() * 2)
	$Sprite2D2.play("idle")
	var frame_count = $Sprite2D2.sprite_frames.get_frame_count("idle")
	$Sprite2D2.set_frame_and_progress(randi_range(0, frame_count-1), 0)
	
func walk():
	$AnimationPlayer.play("walk")
	$AnimationPlayer.seek(randf())

func _anim_finished(anim):
	print("anim_finished " + anim)
	if anim != "idle":
		idle()
		
func _anim_changed(old, new):
	print("anim changed " + str(old) + " " + str(new))
