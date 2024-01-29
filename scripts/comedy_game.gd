extends Node

@onready var joke_card_container = $Control/JokeContainer
@onready var player_crow = $PlayerCrow
@onready var audience_crow = preload("res://scenes/prefabs/audience_crow.tscn")

@export var rows = 5
@export var cols = 14
@export var vertical_gap = 90
@export var horizontal_gap = 140
@export var audience_start_pos = Vector2(640, 370)

@export var crow_count = 5

@export var jokes_to_tell = 10
var jokes_told = 0

var available_spaces = []

var audience_crows = []
var walking_crows = 0

func _ready():
	_gather_request_containers()
	_gather_joke_cards()
	_set_enable_joke_cards(false)
	_gather_inventory_slots()
	_set_enable_inventory_slots(false)
	set_up()
	
func set_up():
	# Set up the game - generate crows in the audience
	# with specific joke preferences
	available_spaces.resize(rows*cols)
	for i in range(rows*cols):
		available_spaces[i] = i
		
	for i in range(crow_count):
		var crow = generate_audience_crow()
		$Audience.add_child(crow)
		var audience_spot = get_available_audience_spot()
		set_crow_current_and_target_positions(crow, Vector2(2120 + randf() * 255, audience_spot.y) , audience_spot)
		crow.get_node("Walk").finished_walking.connect(_audience_finished_walking)
		crow.walk_to_audience()
		audience_crows.append(crow)
	walking_crows = crow_count
	
func generate_audience_crow():
	var types = Enums.JokeType.values()
	# Remove ANY
	types.remove_at(types.size()-1)
	return generate_audience_crow_with_types(types)
	
func generate_audience_crow_with_types(available_types):
	var crow_inst = audience_crow.instantiate()
	var liked_joke = randi_range(0, available_types.size()-1)
	crow_inst.set_liked_joke(available_types[liked_joke])
	available_types.remove_at(liked_joke)
	var disliked_joke = randi_range(0, available_types.size()-1)
	crow_inst.set_disliked_joke(available_types[disliked_joke])
	return crow_inst
	
func set_crow_current_and_target_positions(crow, current_pos, target_pos):
	crow.target_location = target_pos
	crow.position = current_pos
	crow.z_index = crow.position.y
	
func get_available_audience_spot():
	var desired_position_index = randi_range(0, available_spaces.size()-1)
	var desired_position = available_spaces[desired_position_index]
	available_spaces.remove_at(desired_position_index)
	
	var col = desired_position % cols
	var row = floori(desired_position / cols)
	
	var pos_x = audience_start_pos.x + col * horizontal_gap
	var pos_y = audience_start_pos.y + row * vertical_gap
	if col % 2 == 1:
		pos_y += (vertical_gap / 2)
	
	return Vector2(pos_x, pos_y)

func _audience_finished_walking():
	walking_crows = walking_crows-1
	if walking_crows <= 0:
		player_crow.walk_to_mic()
		player_crow.get_node("Walk").finished_walking.connect(_player_at_mic)

func _player_at_mic():
	$AudioStreamPlayer.play()
	_start_game()
	_new_turn()

var game_jokes = []
@export var full_joke_symbol_count = 3

var joke_containers = []

func _gather_request_containers():
	joke_containers = $Control/JokeRequestContainer.get_children()

func _start_game():
	player_crow.joke_finished.connect(_player_crow_joke_finished)
	_set_enable_joke_cards(true)

func _new_turn():
	_set_inventory_slots_for_telling()
	_handle_requests()
	_randomize_cards()

func _handle_requests():
	# if 5 full jokes exist - lose game
	if game_jokes.size() >= 5:
		if game_jokes.back().is_full:
			print("Lose game!")
	#if no jokes, generate new full joke
	if game_jokes.size() == 0:
		var full_joke = _generate_full_joke()
		game_jokes.append(full_joke)
	# if atleast one joke exists - generate new joke or gen new symbol for joke
	elif game_jokes.size() > 0:
		if game_jokes.back().is_full:
			#gen new joke
			var joke = _generate_joke()
			_gen_next_symbol(joke)
			game_jokes.append(joke)
		else:
			#gen symbol for joke
			_gen_next_symbol(game_jokes.back())
	_update_request_containers()
	
func _update_request_containers():
	for i in joke_containers.size():
		if i < game_jokes.size():
			joke_containers[i]._update_by_joke_data(game_jokes[i])
		else:
			joke_containers[i]._update_by_joke_data(null)

func _generate_full_joke():
	var joke_data = {}
	var jokes: Array
	for i in range(full_joke_symbol_count):
		jokes.append(_get_random_joke_symbol())
	joke_data.joke_sequence = jokes
	joke_data.is_full = true
	return joke_data
	
func _generate_joke():
	var joke_data={}
	joke_data.joke_sequence = []
	joke_data.is_full = false
	return joke_data

func _gen_next_symbol(joke_data):
	joke_data.joke_sequence.append(_get_random_joke_symbol())
	if joke_data.joke_sequence.size() >= full_joke_symbol_count:
		joke_data.is_full = true
	
func _get_random_joke_symbol():
	return randi_range(Enums.JokeType.BAD, Enums.JokeType.PHYSICAL)
	
func _try_full_match_pattern(request_sequence, joke):
	# if the match sizes don't equal to max, then the full match can't be completed
	if request_sequence.size() != full_joke_symbol_count or joke.size() != full_joke_symbol_count:
		return false
	for i in range(request_sequence.size()):
		# match pattern with each symbol of request
		if joke[i] != request_sequence[i] and joke[i] != Enums.JokeType.ANY:
			# atleast one didnt match, break out
			return false
	return true
	
func _try_incomplete_match_pattern(request_sequence, joke):
	# joke can only complete a request of equal or smaller size
	if request_sequence.size() > joke.size():
		return false
	for i in range(request_sequence.size()):
		if joke[i] != request_sequence[i] and joke[i] != Enums.JokeType.ANY:
			# atleast one didnt match, break out
			return false
	return true

func _try_match_single_symbol(request_sequence, symbol):
	for j in range(request_sequence.size()):
		if symbol == request_sequence[j] or symbol == Enums.JokeType.ANY:
			return {"result": true, "index": j}
	return {"result": false}

func _complete_request(request_index):
	game_jokes.remove_at(request_index)
	jokes_told += 1
	_update_request_containers()
	_crows_laugh()

func _crows_laugh():
	for crow in audience_crows:
		crow.laugh()

var cards = []

var joke_cards = []

var selected_card = -1

func _randomize_cards():
	if cards.size() == 0:
		cards.resize(3)
	for i in range(cards.size()):
		cards[i] = _get_random_joke_card()
	_update_cards()
	
func _gather_joke_cards():
	for child in joke_card_container.get_children():
		joke_cards.append(child)
		child.on_joke_selected.connect(_joke_card_selected)
		
func _set_enable_joke_cards(value):
	for card in joke_cards:
		card.visible = value
	
func _update_cards():
	for i in range(cards.size()):
		joke_cards[i].set_joke_texture(cards[i])
		#joke_cards[i].set_joke_flavor(joke_card_container.get_random_flavor_for_type(cards[i]))
	
func _get_random_joke_card():
	return randi_range(Enums.JokeType.BAD, Enums.JokeType.ANY)

@onready var card_highlight = $Control/CardHighlight

func _joke_card_selected(card):
	var new_selected_card = joke_cards.find(card)
	print("selected card "+str(new_selected_card))
	if selected_card == new_selected_card:
		_clear_selected_card()
		_set_inventory_slots_for_telling()
	else:
		selected_card = new_selected_card
		_set_inventory_slots_for_picking()
		_highlight_card(card)

func _highlight_card(card):
	card_highlight.visible = true
	card_highlight.position = card.global_position
	
func _clear_card_highlight():
	card_highlight.visible = false

func _clear_selected_card():
	if selected_card == -1:
		return
	selected_card = -1
	_clear_card_highlight()
	
var inventory_slots = []
var inventory = []

func _gather_inventory_slots():
	inventory_slots = $Control/PanelContainer/InventoryContainer.get_children()
	for slot in inventory_slots:
		slot.on_picked.connect(_pick_inventory_slot)
		slot.on_told.connect(_tell_joke)
		inventory.append([])
	
func _set_enable_inventory_slots(value):
	for slot in inventory_slots:
		slot._set_button_enabled(value)
	
func _set_inventory_slots_for_picking():
	for i in range(inventory_slots.size()):
		# allow for picking only if we have space to hold more jokes
		inventory_slots[i]._set_for_picking(inventory[i].size() < full_joke_symbol_count)

func _set_inventory_slots_for_telling():
	for i in range(inventory_slots.size()):
		# allow for telling only if we have jokes to tell
		inventory_slots[i]._set_for_telling(inventory[i].size() > 0)

func _pick_inventory_slot(joke):
	if selected_card == -1:
		return
	var selected_slot = inventory_slots.find(joke)
	print("picking slot! " + str(selected_slot))
	if selected_slot == -1:
		return
	if inventory[selected_slot].size() < full_joke_symbol_count:
		inventory[selected_slot].append(cards[selected_card])
		_update_inventory_slots()
	_clear_selected_card()
	_new_turn()
	
func _clear_inventory_slot(slot_index):
	inventory[slot_index] = []
	inventory_slots[slot_index]._set_for_telling(false)
	_update_inventory_slots()
		
func _update_inventory_slots():
	for i in range(inventory.size()):
		inventory_slots[i]._set_symbols(inventory[i])

var pending_joke

func _tell_joke(joke):
	player_crow._tell_joke()
	_disable_all_actions()
	pending_joke = joke
	
func _disable_all_actions():
	for card in joke_cards:
		card._set_btn_enabled(false)
	for slot in inventory_slots:
		slot._set_button_enabled(false)

func _enable_actions():
	for card in joke_cards:
		card._set_btn_enabled(true)
	_set_inventory_slots_for_telling()

func _player_crow_joke_finished():
	var selected_slot = inventory_slots.find(pending_joke)
	if selected_slot == -1:
		return
	var joke_pattern = inventory[selected_slot]
	# first check if any requests fully match the pattern
	# the joke pattern has to be fully completed for this
	if joke_pattern.size() >= full_joke_symbol_count:
		for i in range(game_jokes.size()):
			# we can only complete "full" requests
			if game_jokes[i].is_full:
				if _try_full_match_pattern(game_jokes[i].joke_sequence, joke_pattern):
					# we finished the pattern!
					# crows laugh!
					# next turn!
					_complete_request(i)
					_clear_inventory_slot(selected_slot)
					return
	# if we fall through here, we didn't complete any full matches
	# try non complete matches
	for i in range(game_jokes.size()):
		if game_jokes[i].is_full:
			if _try_incomplete_match_pattern(game_jokes[i].joke_sequence, joke_pattern):
				_complete_request(i)
				_clear_inventory_slot(selected_slot)
				#request complete, crows laugh a little
				_new_turn()
				return
	# if we fall through here, we didn't find any incomplete matches either
	# partly match some of the requests
	for k in range(joke_pattern.size()):
		for i in range(game_jokes.size()):
			if game_jokes[i].is_full:
				var match_result = _try_match_single_symbol(game_jokes[i].joke_sequence, joke_pattern[k])
				if match_result.result:
					game_jokes[i].joke_sequence.remove_at(match_result.index)
					if game_jokes[i].joke_sequence.size() == 0:
						_complete_request(i)
					break
	_clear_inventory_slot(selected_slot)
	_update_request_containers()
	_new_turn()
