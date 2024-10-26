extends CharacterBody2D

class_name Player

signal points_scored(points: int)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerMode {
	DEFAULT
}

const POINTS_LABEL_SCENE = preload("res://scenes/points_label.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_2d = $Area2D
@onready var area_collision_shape = $Area2D/AreaCollisionShape
@onready var body_collision_shape = $BodyCollisionShape

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 600.0
@export var jump_velocity = -350
@export_group("")

@export_group("Stomping enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 180
@export var stomp_y_velocity = -150
@export_group("")

@export_group("Camera sync")
@export var camera_sync: Camera2D
@export_group("")

var player_mode = PlayerMode.DEFAULT
var is_dead = false

func _physics_process(delta: float) -> void:	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = lerpf(velocity.x, speed * direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)

	animated_sprite_2d.trigger_animation(velocity, direction, player_mode)

	move_and_slide()

func _process(delta) -> void: 
	if global_position.x > camera_sync.global_position.x + 6:
		camera_sync.global_position.x = global_position.x - 6
	if global_position.x < camera_sync.global_position.x - 6:
		camera_sync.global_position.x = global_position.x + 6
	if global_position.y > camera_sync.global_position.y + 6:
		camera_sync.global_position.y = global_position.y - 6
	if global_position.y < camera_sync.global_position.y - 6:
		camera_sync.global_position.y = global_position.y + 6

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Enemy:
		handle_enemy_collision(area)

func handle_enemy_collision(enemy: Enemy):
	if enemy == null && is_dead:
		return
		
	var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
		
	if angle_of_collision > min_stomp_degree && max_stomp_degree > angle_of_collision:
		if is_instance_of(enemy, Snark):
			enemy.die()
			on_enemy_stomped()
			spawn_points_label(enemy)
		if is_instance_of(enemy, Bullsquid):
			enemy.stunned()
			on_enemy_stomped()
	else:
		die()

func spawn_points_label(enemy):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = enemy.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)

func on_enemy_stomped():
	velocity.y = stomp_y_velocity

func die():
	if player_mode == PlayerMode.DEFAULT:
		is_dead = true
		animated_sprite_2d.play("default_death")

		area_2d.set_collision_mask_value(3, false)
		set_collision_layer_value(1, false)

		set_physics_process(false)
	else:
		pass
