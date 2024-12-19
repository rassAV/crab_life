extends CharacterBody2D

class_name Player

signal points_scored(points: int)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerMode {
	HEADCRAB,
	ZOMBIE
}

const POINTS_LABEL_SCENE = preload("res://scenes/points_label.tscn")
const HEADCRAB_COLLISION = preload("res://resources/collisionShapes/headcrab_collision_shape.tres")
const ZOMBIE_COLLISION = preload("res://resources/collisionShapes/zombie_collision_shape.tres")

@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_2d = $Area2D
@onready var attack_area_2d = $AttackArea2D
@onready var area_collision_shape = $Area2D/AreaCollisionShape
@onready var body_collision_shape = $BodyCollisionShape

@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 600.0
@export var jump_velocity = -350
@export var down_velocity = 100
@export_group("")

@export_group("Stomping enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 180
@export var stomp_y_velocity = -150
@export_group("")

@export_group("Camera sync")
@export var camera_sync: Camera2D
@export_group("")

@export var ui: UI

var player_mode = PlayerMode.HEADCRAB
var is_dead = false
var is_falling_through = false
var attack_delay = 0.5
var attack_timer = attack_delay
var damaged_delay = 0.5
var damaged_timer = damaged_delay
var zombiefy_delay = 0.7
var zombiefy_timer = zombiefy_delay
var to_zombie = false

func _ready() -> void:
	set_collision_mask_value(8, true)

func _physics_process(delta: float) -> void:	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
	
	if damaged_timer != damaged_delay:
		damaged_timer += delta
		if damaged_timer > damaged_delay:
			damaged_timer = damaged_delay
	
	if zombiefy_timer != zombiefy_delay:
		zombiefy_timer += delta
		if to_zombie:
			animated_sprite_2d.play("headcrab_to_zombie")
		else:
			animated_sprite_2d.play("zombie_to_headcrab")
		if zombiefy_timer > zombiefy_delay:
			zombiefy_timer = zombiefy_delay
			if !to_zombie:
				zombiefy()
			to_zombie = !to_zombie
	
	if !is_dead and zombiefy_timer == zombiefy_delay:
		if attack_timer == attack_delay:
			if Input.is_action_just_pressed("attack") and player_mode == PlayerMode.ZOMBIE:
				attack_timer -= delta
				animated_sprite_2d.play("zombie_attack_1")

			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = jump_velocity

			if Input.is_action_pressed("down") and is_on_floor() and not is_falling_through:
				set_collision_mask_value(8, false)
				velocity.y = down_velocity
				is_falling_through = true
				if player_mode == PlayerMode.ZOMBIE:
					velocity.x = 0
					zombiefy_timer = 0.0
					animated_sprite_2d.play("zombie_to_headcrab")
					to_zombie = false
			elif is_falling_through:
				set_collision_mask_value(8, true)
				is_falling_through = false

			var direction := Input.get_axis("left", "right")
			if direction:
				velocity.x = lerpf(velocity.x, speed * direction, run_speed_damping * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, speed * delta)

			animated_sprite_2d.trigger_animation(velocity, direction, player_mode)
		else:
			attack_timer -= delta
			animated_sprite_2d.play("zombie_attack_1")
			if attack_timer < 0.1:
				attack_timer -= delta
				animated_sprite_2d.play("zombie_attack_2")
				if attack_timer < 0:
					animated_sprite_2d.play("zombie_attack_2")
					var overlapping_areas = attack_area_2d.get_overlapping_areas()
					for area in overlapping_areas:
						if area is Enemy or area is CrashedBox:
							if is_instance_of(area, Scientist):
								spawn_points_label(area, -20, -60, 200)
							if is_instance_of(area, Snark):
								spawn_points_label(area, -20, -20, 100)
							if is_instance_of(area, Bullsquid):
								spawn_points_label(area, -20, -20, 300)
							area.die()
					attack_timer = attack_delay

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
	if area is DangerZone:
		die()
	if area is Enemy:
		handle_enemy_collision(area)
	if area is Portal:
		ui.on_finish()
		hide()
		set_physics_process(false)
		var timer = Timer.new()
		timer.wait_time = 5.0
		timer.one_shot = true
		add_child(timer)
		timer.start()
		timer.timeout.connect(self._to_menu)

func _to_menu():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func handle_enemy_collision(enemy: Enemy):
	if enemy == null && is_dead:
		return
	
	if is_instance_of(enemy, Scientist):
		enemy.die()
		if player_mode == PlayerMode.HEADCRAB:
			zombiefy()
			to_zombie = true
			zombiefy_timer = 0.0
			animated_sprite_2d.play("headcrab_to_zombie")
		spawn_points_label(enemy, -20, -60, 200)
	
	var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
	if angle_of_collision > min_stomp_degree && max_stomp_degree > angle_of_collision:
		if is_instance_of(enemy, Snark):
			enemy.die()
			on_enemy_stomped()
			spawn_points_label(enemy, -20, -20, 100)
		if is_instance_of(enemy, Bullsquid):
			enemy.stunned()
			on_enemy_stomped()
	elif damaged_timer == damaged_delay:
		damaged_timer = 0
		die()

func zombiefy():
	if player_mode == PlayerMode.ZOMBIE:
		player_mode = PlayerMode.HEADCRAB
		area_collision_shape.set_deferred("shape", HEADCRAB_COLLISION)
		body_collision_shape.set_deferred("shape", HEADCRAB_COLLISION)
	else:
		player_mode = PlayerMode.ZOMBIE
		velocity.y = 70
		velocity.x = 0
		area_collision_shape.set_deferred("shape", ZOMBIE_COLLISION)
		body_collision_shape.set_deferred("shape", ZOMBIE_COLLISION)
		#animated_sprite_2d.play("headcrab_to_zombie")

func spawn_points_label(enemy, x, y, score):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = enemy.position + Vector2(x, y)
	points_label.text = str(score)
	get_tree().root.add_child(points_label)
	points_scored.emit(score)

func on_enemy_stomped():
	if attack_timer == attack_delay:
		velocity.y = stomp_y_velocity

func die():
	if player_mode == PlayerMode.HEADCRAB:
		is_dead = true
		animated_sprite_2d.play("headcrab_death")

		area_2d.set_collision_mask_value(3, false)
		
		#set_collision_layer_value(1, false)
		#set_physics_process(false)
		
		var restart_timer = Timer.new()
		restart_timer.wait_time = 2.0
		restart_timer.one_shot = true
		add_child(restart_timer)
		restart_timer.start()
		restart_timer.timeout.connect(self._restart_scene)
	elif player_mode == PlayerMode.ZOMBIE:
		zombiefy()
	else:
		pass
		
func _restart_scene():
	get_tree().reload_current_scene()
