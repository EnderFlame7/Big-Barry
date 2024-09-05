class_name Player extends RigidBody2D

@export_group("Player Scale")
@export var MAX_SCALE : Vector2
@export var BASE_SCALE : Vector2
var current_scale : Vector2 = BASE_SCALE

@export_group("Inflation Properties")
@export var MAX_INFLATION : float
@export var inflation_rate : float
@export var inflation_decay_rate : float
@export var inflation_mult : float
@export var gravity : float
var inflation : float

@export_group("Deflate Properties")
@export var MAX_DEFLATION : float
@export var deflate_rate : float
@export var deflate_cost : float
@export var deflate_decay_rate : float # paired with delta to slow down
@export var deflation_mult : float
var deflation : Vector2 = Vector2.ZERO

@export_group("Sneeze Properties")
@export var sneeze_cost : float
@export var sneeze_strength : float

@export_group("Rope Properties")
@export var initial_rope_pos : Vector2

@onready var hurtbox_shape : CollisionShape2D = %HurtboxShape
@onready var sprite : AnimatedSprite2D = %AnimatedSprite
@onready var rope : Rope = %Rope

@onready var sfx_node : Node2D = %SFXs
@onready var inflate_sfx : AudioStreamPlayer = %"Inflate SFX"
@onready var deflate_sfx : AudioStreamPlayer = %"Deflate SFX"
@onready var sneeze_sfx : AudioStreamPlayer = %"Sneeze SFX"
@onready var pop_sfx : AudioStreamPlayer = %"Pop SFX"

var input_dir : Vector2 = Vector2.ZERO

var dead : bool = false

signal respawn_player

func _ready() -> void:
	Global.player = self
	respawn_player.connect(Global.main._on_respawn_player)
	rope.position = initial_rope_pos
	current_scale = BASE_SCALE + (MAX_SCALE * (inflation / MAX_INFLATION))
	for child in get_children():
		if not child == rope or not child == sfx_node: child.global_scale = current_scale
	

func _process(delta: float) -> void:
	if not dead: adjust_sprite(delta)
	if Global.main.game_started and not dead:
		if not inflate(delta):
			deflate(delta)
	
	if dead:
		inflate_sfx.stop()
		deflate_sfx.stop()
		sneeze_sfx.stop()

func _physics_process(delta: float) -> void:
	adjust_rope(delta)
	if not dead:
		set_linear_velocity((Vector2.UP * inflation * inflation_mult) + (gravity * Vector2.DOWN) + (deflation * deflation_mult))
	else:
		set_linear_velocity(gravity * Vector2.DOWN)
	if not Global.main.transitioning and not Global.main.game_started:
		global_position.y = lerp(global_position.y, -abs((Global.main.LEVEL_COUNT + 1) * (Global.main.LEVEL_HEIGHT * Global.TILE_SIZE)) * 1.0, 0.1 * delta)
		inflate_sfx.stop()
		deflate_sfx.stop()
		sneeze_sfx.stop()
		pop_sfx.stop()
		

func inflate(delta : float) -> bool:
	if Input.is_action_pressed("inflate"):
		if not inflate_sfx.playing:
			inflate_sfx.set_pitch_scale(inflate_sfx.get_stream().get_length() / (MAX_INFLATION / inflation_rate))
			inflate_sfx.play(inflate_sfx.get_stream().get_length() * (inflation / MAX_INFLATION))
		sprite.set_animation("inflate")
		inflation += inflation_rate * (delta / 1.0)
		inflation = clamp(inflation, 0, MAX_INFLATION)
		return true
	else:
		if inflate_sfx.playing:
			inflate_sfx.stop()
		if not Input.is_action_pressed("deflate"): sprite.set_animation("hold")
		inflation -= inflation_decay_rate * (delta / 1.0)
		inflation = clamp(inflation, 0, MAX_INFLATION)
		return false
	return false


func deflate(delta : float) -> void:
	if not Input.is_action_pressed("inflate") and inflation > 0.0 and (Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("deflate")):
		sprite.set_animation("deflate")
		if not deflate_sfx.playing: deflate_sfx.play()
		input_dir = Vector2.ZERO
		inflation -= deflate_cost * (delta / 1.0)
		if Input.is_action_pressed("up"):
			input_dir += Vector2.UP
		if Input.is_action_pressed("down"):
			input_dir += Vector2.DOWN
		if Input.is_action_pressed("left"):
			input_dir += Vector2.LEFT
		if Input.is_action_pressed("right"):
			input_dir += Vector2.RIGHT
		if Input.is_action_pressed("deflate"):
			input_dir += global_position.direction_to(get_global_mouse_position()).normalized()
			
		if deflation.x < MAX_DEFLATION and deflation.x > -MAX_DEFLATION:
			deflation.x += deflate_rate * (delta / 1.0) * input_dir.x
		else:
			deflation.x = lerp(deflation.x, 0.0, deflate_decay_rate * delta)
			
		if deflation.y < MAX_DEFLATION and deflation.y > -MAX_DEFLATION:
			deflation.y += deflate_rate * (delta / 1.0) * input_dir.y
		else:
			deflation.y = lerp(deflation.y, 0.0, deflate_decay_rate * delta)
	else:
		deflate_sfx.stop()
		deflation = lerp(deflation, Vector2.ZERO, deflate_decay_rate * delta)


func sneeze(input : String) -> void:
	if inflation >= sneeze_cost and Global.main.game_started and not dead:
		sneeze_sfx.set_pitch_scale(1 + randf_range(-0.25, 0.25))
		sneeze_sfx.play()
		inflation -= sneeze_cost
		if input == "up":
			deflation.y += sneeze_strength * Vector2.UP.y
		elif input == "down":
			deflation.y += sneeze_strength * Vector2.DOWN.y
		elif input == "left":
			deflation.x += sneeze_strength * Vector2.LEFT.x
		elif input == "right":
			deflation.x += sneeze_strength * Vector2.RIGHT.x
		elif input == "deflate":
			deflation += sneeze_strength * global_position.direction_to(get_global_mouse_position()).normalized()


func adjust_sprite(delta : float) -> void:
	sprite.rotation = lerp(sprite.rotation, clamp(rope._get_neck_rotation(), deg_to_rad(-35.0), deg_to_rad(35.0)), 10 * delta)
	current_scale = BASE_SCALE + (MAX_SCALE * (inflation / MAX_INFLATION))
	for child in get_children():
		if not child == rope: child.global_scale = lerp(child.global_scale, clamp(current_scale, BASE_SCALE, MAX_SCALE), 15 * delta)
	sprite.set_frame_and_progress(ceil((sprite.get_sprite_frames().get_frame_count(sprite.get_animation()) - 0.01) * (inflation / MAX_INFLATION)), 0.0)


func adjust_rope(delta : float) -> void:
	rope.position = Vector2(initial_rope_pos.x, initial_rope_pos.y * current_scale.y)


func _on_body_entered_hurtbox(body: Node2D) -> void:
	if body.is_in_group("fatal"):
		dead = true
		hurtbox_shape.set_deferred("disabled", true)
		pop_sfx.play()
		var anim_name : String = "pop_" + str(ceil((sprite.get_sprite_frames().get_frame_count(sprite.get_animation()) - 0.01) * (inflation / MAX_INFLATION)))
		sprite.set_animation(anim_name)
		sprite.play()
		await sprite.animation_finished
		sprite.hide()
		sprite.queue_free()
		await get_tree().create_timer(2.0).timeout
		respawn_player.emit()
