extends CharacterBody2D

@export var speed: float = 150.0

# Target
var current_target = null

# Stores all interactable objects currently near the player.
# We use a list because more than one resource can be in range at once.
var nearby_objects = []

# Basic resource counters.
var wood_count = 0
var ore_count = 0

# Cooldown control
var can_interact = true
var interact_cooldown = 0.25 #1/4 second

# Handles top-down movement.
func _physics_process(delta):
	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	input_vector = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()
	update_action_prompt()
	update_target_highlight()

# Handles interaction input.
func handle_interact():
	if not can_interact:
		return

	can_interact = false

	var target = get_closest_nearby_object()

	if target != null:
		target.interact(self)
	else:
		print("Nothing to interact with")

	await get_tree().create_timer(interact_cooldown).timeout
	can_interact = true

# Handle cooldown
func start_interact_cooldown():
	can_interact = false
	await get_tree().create_timer(interact_cooldown).timeout
	can_interact = true

# When E is pressed, the player interacts with only the closest nearby object.
func _input(event):
	if event.is_action_pressed("interact")  and can_interact:
		handle_interact()
		var target = get_closest_nearby_object()

		if target != null:
			target.interact(self)
		else:
			print("Nothing to interact with")

# Adds an interactable object to the nearby list when the player enters its area.
func add_nearby_object(node):
	if node not in nearby_objects:
		nearby_objects.append(node)
		print("Near object: ", node.name)

# Removes an interactable object from the nearby list when the player leaves its area.
func remove_nearby_object(node):
	if node in nearby_objects:
		nearby_objects.erase(node)
		print("Left object: ", node.name)

# Returns the closest valid nearby object.
# This prevents the "last entered wins" bug when multiple resources are close together.
func get_closest_nearby_object():
	if nearby_objects.is_empty():
		return null

	var closest = null
	var closest_distance = INF

	for node in nearby_objects:
		if not is_instance_valid(node):
			continue

		var distance = global_position.distance_to(node.global_position)

		if distance < closest_distance:
			closest_distance = distance
			closest = node

	return closest

# Update action prompt based on current target
func update_action_prompt():
	var label = get_tree().current_scene.get_node("UI/ActionLabel")
	var target = get_closest_nearby_object()
	if target != null:
		label.text = "["+target.interaction_type.capitalize()+"]"
	else:
		label.text= ""


# Updates the on-screen resource counters
func update_resource_ui():
	var wood_label = get_tree().current_scene.get_node("UI/WoodLabel")
	var ore_label = get_tree().current_scene.get_node("UI/OreLabel")

	wood_label.text = "Wood: " + str(wood_count)
	ore_label.text = "Ore: " + str(ore_count)
	
# Handles which object should be highlighted
func update_target_highlight():
	var new_target = get_closest_nearby_object()
	
	# If nothing changed do nothing
	if new_target == current_target:
		return
		
	# Remove highlight from old target
	if current_target != null and is_instance_valid(current_target):
		current_target.unhighlight()
		
	# Set new target
	current_target = new_target
	
	# Highlight new target
	if current_target != null:
		current_target.highlight()

# Shows a short feedback message on screen, then clears it
func show_feedback(message):
	var label = get_tree().current_scene.get_node("UI/FeedbackLabel")
	label.text = message

	await get_tree().create_timer(1.0).timeout

	# Only clear it if nothing else replaced it during the timer
	if label.text == message:
		label.text = ""
