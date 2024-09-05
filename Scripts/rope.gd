class_name Rope extends Node2D

@onready var neck_segment : RigidBody2D = %NeckSegment
@onready var end_segment : RigidBody2D = %RopeEnd

func _physics_process(delta: float) -> void:
	pass
	#if Input.is_action_pressed("anchor"):
		#end_segment.look_at(get_global_mouse_position())


func _get_neck_rotation() -> float:
	return neck_segment.global_rotation
