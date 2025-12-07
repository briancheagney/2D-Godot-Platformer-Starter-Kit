extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -350.0

var gravity = 900

var attack_type: String
var current_attack: bool

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if !current_attack:
		if Input.is_action_just_pressed("Attack"):
			current_attack = true
			if Input.is_action_just_pressed("Attack"):
				attack_type = "Attack"
				handle_attack_animation(attack_type)
			
	move_and_slide()
	handle_movement_animation(direction)
	
func handle_movement_animation(direction):
	if is_on_floor() and !current_attack:
		if !velocity:
			animated_sprite.play("Idle")
		if velocity:
			animated_sprite.play("Walk")
			toggle_flip_sprite(direction)
	elif is_on_floor() and !current_attack:
		animated_sprite.play("Jump")
			
func toggle_flip_sprite(direction):
	if direction == 1:
		animated_sprite.flip_h = false
	if direction == -1:
		animated_sprite.flip_h = true

func handle_attack_animation(attack_type):
	if current_attack:
		var animation = str(attack_type)
		animated_sprite.play(animation)
		
		


func _on_animated_sprite_2d_animation_finished() -> void:
	current_attack = false
