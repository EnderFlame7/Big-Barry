class_name Level extends Node2D

@export var wallnground_layer : TileMapLayer
@export var obstacle_layer : TileMapLayer
@export var moving_obstacles : Node2D
@export var spawn_point : Marker2D
@export var on_screen_notifier : VisibleOnScreenNotifier2D
@export var anim_player : AnimationPlayer


func _ready() -> void:
	on_screen_notifier.screen_entered.connect(_on_screen_entered)
	on_screen_notifier.screen_exited.connect(_on_screen_exited)
	anim_player.set_current_animation("reset")
	
	
func _on_screen_entered() -> void:
	for child in get_children():
		if not child == on_screen_notifier and not child == anim_player:
			child.show()
	
	
func _on_screen_exited() -> void:
	for child in get_children():
		if not child == on_screen_notifier and not child == anim_player:
			child.hide()
