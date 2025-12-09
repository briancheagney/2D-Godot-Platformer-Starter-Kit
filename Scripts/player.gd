extends CharacterBody2D
# --------- VARIABLES ---------- #
@export_category("Player Properties")
@export var move_speed : float = 400
@export var jump_force : float = 600
@export var gravity : float = 30
@export var max_jump_count : int = 2
var jump_count : int = 2
@export_category("Toggle Functions")
@export var double_jump : = false
var is_grounded : bool = false
var is_attacking : bool = false  # NEW: Track if player is attacking
@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var animation_player = $AnimationPlayer

# --------- BUILT-IN FUNCTIONS ---------- #
func _process(_delta):
	# Calling functions
	movement()
	player_animations()
	flip_player()
	handle_attack()  # NEW: Check for attack input

# --------- CUSTOM FUNCTIONS ---------- #
# NEW: Handle attack input
func handle_attack():
	if Input.is_action_just_pressed("Attack") and !is_attacking:
		perform_attack()

# NEW: Perform attack animation
func perform_attack():
	is_attacking = true
	player_sprite.play("Attack")  # Make sure you have an "Attack" animation in your AnimatedSprite2D
	# If you want to use AnimationPlayer instead, use: animation_player.play("attack")
	
	# Wait for animation to finish
	await player_sprite.animation_finished
	is_attacking = false

# <-- Player Movement Code -->
func movement():
	# Gravity
	if !is_on_floor():
		velocity.y += gravity
	elif is_on_floor():
		jump_count = max_jump_count
	
	handle_jumping()
	
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	velocity = Vector2(inputAxis * move_speed, velocity.y)
	move_and_slide()

# Handles jumping functionality
func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1

# Player jump
func jump():
	jump_tween()
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force

# Handle Player Animations
func player_animations():
	# Don't change animation if attacking
	if is_attacking:
		return
		
	particle_trails.emitting = false
	
	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.play("GirkWalk", 0.5)
		else:
			player_sprite.play("Idle")
	else:
		player_sprite.play("Jump")

# Flip player sprite based on X velocity
func flip_player():
	if velocity.x < 0: 
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

# Tween Animations
func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = spawn_point.global_position
	await get_tree().create_timer(0.3).timeout
	AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

# --------- SIGNALS ---------- #
func _on_collision_body_entered(_body):
	if _body.is_in_group("Traps"):
		AudioManager.death_sfx.play()
		death_particles.emitting = true
		death_tween()
