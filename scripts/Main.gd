extends Node2D

onready var pile1 = $Card1
onready var pile2 = $Card2
onready var pile3 = $Card3
onready var pile4 = $Card4
onready var pile5 = $Card5
onready var pile6 = $Card6

onready var active_pile = $ActivePile
onready var discard_pile = $DiscardPile

onready var selection = $Selection

onready var creditsLabel = $CreditsLabel
onready var comboLabel = $ComboLabel
onready var multiplierLabel = $MultiplierLabel
onready var messageLabel = $MessageLabel
onready var messageTween = $MessageTween
onready var timer = $Timer

onready var SunCard = load("res://scenes/SunCard.tscn")
onready var MoonCard = load("res://scenes/MoonCard.tscn")
onready var ShipCard = load("res://scenes/ShipCard.tscn")
onready var AlienCard = load("res://scenes/AlienCard.tscn")

onready var CometCard = load("res://scenes/CometCard.tscn")
onready var BlackHoleCard = load("res://scenes/BlackHoleCard.tscn")

onready var BackCard = load("res://scenes/BackCard.tscn")

onready var Indicator = load("res://scenes/Indicator.tscn")

onready var dealing_cards = $SFX/DealingCards

onready var next_button = $NextButton

var pack = []
var pile = []
var card_discard_pile = []

var active = null

var credits = 0
var combo = 0
var multiplier = 1.0
var stage = 1

var indicators = []

var music_db = -6
var sfx_db = -6
var music_mute = false
var sfx_mute = false
var music_index
var sfx_index
var pile_count

var next_button_block = false

var battle_matrix = Battle.new()

const offscreen = Vector2(-200, 400)

func _ready():
	randomize()
	
	next_button.visible = false
	next_button_block = false
	
	music_index = AudioServer.get_bus_index("Music")
	sfx_index = AudioServer.get_bus_index("SFX")
	
	battle_matrix.initialise_battle_matrix()
	
	var back_card = BackCard.instance()
	back_card.position = discard_pile.position
	back_card.scale = Globals.card_scaling
	add_child(back_card)
	
	back_card.connect("card_back_clicked", self, "on_discard_click")
	
	# display_indicators()
	create_pack()
	deal_cards()
	display_card()
	
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("blow_up"):
		blow_up_cards()
		
	creditsLabel.text = "Credits: " + str(credits)
	comboLabel.text = "Combo: " + str(combo)
	multiplierLabel.text = "Multiplier: " + str(multiplier)
	
	if Globals.selected_card != null:
		selection.position = Globals.selected_card.position
	else:
		selection.position = active.position
		
	process_audio()
	
	if pile_count == 0:
		next_button.visible = true
		
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.is_pressed():
		process_selection()
	
func display_indicators():
	for i in range(6):
		var indicator = Indicator.instance()
		add_child(indicator)
		
		var pos
		
		match i:
			0:
				pos = pile1.position
			1:
				pos = pile2.position
			2:
				pos = pile3.position
			3:
				pos = pile4.position
			4:
				pos = pile5.position
			5:
				pos = pile6.position
				
		pos.y = 480
		
		indicator.position = pos
		indicators.append(indicator)
	
func create_pack():
	pack = []
	for suit in range(4):
		for number in range(13):
			var card = create_card(suit, number + 1, offscreen)
			pack.append(card)

	pack.shuffle()
	
func deal_cards():
	next_button_block = true
	dealing_cards.play()
	
	var pos1 = pile1.position
	var pos2 = pile2.position
	var pos3 = pile3.position
	var pos4 = pile4.position
	var pos5 = pile5.position
	var pos6 = pile6.position
	
	timer.wait_time = 0.1
	timer.start()
	
	for row in range(4):
		for column in range(6):
			var pos = Vector2()
			
			match column:
				0:
					pos = pos1
				1:
					pos = pos2
				2:
					pos = pos3
				3:
					pos = pos4
				4:
					pos = pos5
				5:
					pos = pos6
				
			pos.y += row * 70
			
			var card = pack[0]
			pack.remove(0)
			pile.append(card)
			
			card.move_to(pos)
			card.row = row
			card.column = column
			card.z_index = row + 4
			
			if row == 0:
				card.card_credits += 20
				
			yield(timer, "timeout")
			
	timer.stop()
	
	next_button_block = false
	next_button.visible = false
	
	# number of cards on display
	# pile_count = 4 * 6
	pile_count = pile.size()
	
func blow_up_cards():
	# blow up all the cards on the pile first
	timer.wait_time = 0.1
	timer.start()
	
	var card
	while !pile.empty():
		card = pile.pop_back()
		card.blow_up(offscreen)
		pack.append(card)

		yield(timer, "timeout")

	timer.stop()
	
	# wait a second or so...
	timer.wait_time = 1.5
	timer.start()
	yield(timer, "timeout")
	timer.stop()
	
	# shuffle the pack
	pack.shuffle()
	
	# redeal the cards
	deal_cards()
	
func set_redeal_piles():
	print("comet card activated")
			
func create_card(suit, number, pos):
	var card : Sprite
	
	match suit:
		Globals.SUITS.SUN:
			card = SunCard.instance()
		Globals.SUITS.MOON:
			card = MoonCard.instance()
		Globals.SUITS.SHIP:
			card = ShipCard.instance()
		Globals.SUITS.ALIEN:
			card = AlienCard.instance()
		Globals.SUITS.SPECIAL:
			card = process_special_card()
			
	if card == null:
		return null
	
	card.scale = Globals.card_scaling
	card.position = pos
	add_child(card)
	card.card_suit = suit
	card.card_number = number
	card.row = -1
	card.column = -1
	card.card_type = Globals.SPECIALS.STANDARD
	var credits = 0
	
	if suit != Globals.SUITS.SPECIAL:
		if rand_range(1, 100) > 70:
			credits = 10
			
	card.set_details(number, credits)
	return card
	
func process_special_card():
	var card = null
	
	match stage:
		2:
			card = CometCard.instance()
			card.card_type = Globals.SPECIALS.COMET
		3:
			card = BlackHoleCard.instance()
			card.card_type = Globals.SPECIALS.BLACKHOLE
			
	card.card_special = true
	return card
				
func display_card():	
	if active != null:
		pack.append(active)
		active.z_index = -1
		
	active = pack[0]
	pack.remove(0)
	
	active.z_index = 1
	active.position = discard_pile.position
	active.move_to(active_pile.position)
	active.row = -1
	active.column = -1
	
	match active.card_special:
		Globals.SPECIALS.STANDARD:
			pass
		Globals.SPECIALS.COMET:
			set_redeal_piles()
		Globals.SPECIALS.BLACKHOLE:
			blow_up_cards()
	
	card_discard_pile.push_front(active)
	yield(active, "finished_moving")
	arrange_discard_pile()
	
func arrange_discard_pile():
	var size = card_discard_pile.size()
	for i in range(size):
		var card = card_discard_pile[i]
		card.z_index = -i - 1
		if i < 5:
			var pos = active_pile.position
			pos.x += i * 30
			card.position = pos
		else:
			card.position = offscreen
	
	while card_discard_pile.size() > 5:
		card_discard_pile.pop_back()
	
func process_selection():
	if active == null:
		reset_selection()
		return
		
	var selected = Globals.selected_card
	
	selected = choose_visible_card(selected)
		
	if selected == null:
		reset_selection()
		return
		
	if active.card_number - selected.card_number == 1:
		process_match(active.card_suit, selected.card_suit)
		return
		
	if selected.card_number - active.card_number == 1:
		process_match(active.card_suit, selected.card_suit)
		return
		
	if selected.card_number == 1 and active.card_number == 13:
		process_match(active.card_suit, selected.card_suit)
		return
		
	if selected.card_number == 13 and active.card_number == 1:
		process_match(active.card_suit, selected.card_suit)
		return
		
	reset_selection()
	
func choose_visible_card(selected):
	if selected == null:
		return null
		
	if selected.row == -1:
		return selected
		
	for card in pile:
		if card.column == selected.column:
			if card.row > selected.row:
				selected = card
				
	return selected
		
func reset_selection():
	Globals.clear_selected()
	
	if combo >= 5:
		var ratio = combo / 5.0
		multiplier += ratio - 0.9
	
	combo = 0
		
func process_match(active_suit, selected_suit):
	Globals.selected_card.move_to(active.position)
	active.z_index = 1
	active = Globals.selected_card
	Globals.clear_selected()
	
	if selected_suit == Globals.SUITS.SPECIAL:
		return
		
	var battle = battle_matrix.process_battle(active_suit, selected_suit)
	if active.card_credits > 0:
		var first = Globals.suit_names[battle.first]
		var second = Globals.suit_names[battle.second]
		match battle.credits:
			-1:
				credits += active.card_credits * 0.5 * multiplier
				process_message("%s vs %s: battle lost, less credits won" % [ first, second])
			0:
				credits += active.card_credits * multiplier
				process_message("Same suit, battle drawn")
			1:
				credits += active.card_credits * 2 * multiplier
				process_message("%s vs %s: battle won, more credits won!" % [ first, second])
			
	combo += 1
	
	pile_count -= 1
	
	active.row = -1
	active.column = -1
	
	card_discard_pile.push_front(active)
	yield(active, "finished_moving")
	arrange_discard_pile()
	
func process_message(message):
	messageLabel.text = message
	messageTween.interpolate_method(self, "on_message_tween", 0, 1, 3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	messageTween.start()
	
func on_message_tween(value):
	messageLabel.modulate = Color(1, 1, 1, 1 - value)
	
func on_discard_click():
	if !pack.empty():
		display_card()

func process_audio():
	if Globals.music_mute != music_mute:
		music_mute = Globals.music_mute
		AudioServer.set_bus_mute(music_index, music_mute)
		
	if Globals.sfx_mute != sfx_mute:
		sfx_mute = Globals.sfx_mute
		AudioServer.set_bus_mute(sfx_index, sfx_mute)
	
	if Globals.music_db != music_db:
		music_db = Globals.music_db
		AudioServer.set_bus_volume_db(music_index, music_db)
		
	if Globals.sfx_db != sfx_db:
		sfx_db = Globals.sfx_db
		AudioServer.set_bus_volume_db(sfx_index, sfx_db)

func on_next_pressed():
	if next_button_block:
		return
	
	stage += 1
	var card = create_card(Globals.SUITS.SPECIAL, -1, offscreen)
	pack.append(card)
			
	deal_cards()

