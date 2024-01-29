extends Node

@export var walkRootNode: NodePath

@export var min_speed = 200
@export var max_speed = 300

signal finished_walking

func start_walking(target_pos):
	var walk_tween = create_tween()
	var target_node = get_node(walkRootNode)
	var duration = abs(target_pos.x - target_node.position.x) / randf_range(min_speed, max_speed)
	walk_tween.tween_property(target_node, "position", target_pos, duration)
	walk_tween.tween_callback(_finish_walking)

func _finish_walking():
	finished_walking.emit()
