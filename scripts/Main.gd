extends Node2D

onready var pile1 = $Card1
onready var pile2 = $Card2
onready var pile3 = $Card3
onready var pile4 = $Card4

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

var pack = []
var pile = []
var card_discard_pile = []

var active = null

var credits = 0
var combo = 0
var multiplier = 1.0

var battle_matrix = []

var indicators = []

var offscreen = Vector2(-200, 400)

func _ready():
	randomize()
	
	initialise_battle_matrix()
	
	var back_card = BackCard.instance()
	back_card.position = discard_pile.position
	back_card.scale = Globals.card_scaling
	add_child(back_card)
	
	back_card.connect("card_back_clicked", self, "on_discard_click")
	
	# display_indicators()
	create_pack()
	deal_cards()
	display_card()
	
func display_indicators():
	for i in range(4):
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
				
		pos.y = 480
		
		indicator.position = pos
		indicators.append(indicator)
	
func _process(delta):
	if Input.is_action_pressed("restart"):
		get_tree().reload_current_scene()
		
	creditsLabel.text = "Credits: " + str(credits)
	comboLabel.text = "Combo: " + str(combo)
	multiplierLabel.text = "Multiplier: " + str(multiplier)
	
	if Globals.selected_card != null:
		selection.position = Globals.selected_card.position
	else:
		selection.position = active.position
		
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.is_pressed():
		process_selection()
	
func create_pack():
	pack = []
	for suit in range(4):
		for number in range(13):
			var card = create_card(suit, number + 1, offscreen)
			pack.append(card)

	pack.shuffle()
	
func deal_cards():
	var pos1 = pile1.position
	var pos2 = pile2.position
	var pos3 = pile3.position
	var pos4 = pile4.position
	
	timer.start()
	
	for row in range(4):
		for column in range(4):
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
			
func create_card(suit, number, pos):
	var card : Sprite
	
	match suit:
		Globals.SUN:
			card = SunCard.instance()
		Globals.MOON:
			card = MoonCard.instance()
		Globals.SHIP:
			card = ShipCard.instance()
		Globals.ALIEN:
			card = AlienCard.instance()
	
	card.scale = Globals.card_scaling
	card.position = pos
	add_child(card)
	card.card_suit = suit
	card.card_number = number
	card.row = -1
	var credits = 0
	if rand_range(1, 100) > 70:
		credits = 10
	card.set_details(number, credits)
	return card
				
func display_card():
	print("--- display card ---")
	
	# arrange_discard_pile()
	
	if active != null:
		pack.append(active)
		active.z_index = -1
		
		print("active: " + str(active.card_suit) + " " + str(active.card_number))

	active = pack[0]
	pack.remove(0)
	
	print("latest: " + str(active.card_suit) + " " + str(active.card_number))

	# active.z_index = UPPERMOST
	active.position = discard_pile.position
	active.move_to(active_pile.position)
	
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
	print("process selection")
	
	if active == null:
		reset_selection()
		return
		
	var selected = Globals.selected_card
		
	if selected == null:
		reset_selection()
		return
		
	print("active: %d selected: %d" % [active.card_number, selected.card_number])
		
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
		
func reset_selection():
	print("reset selection")
	Globals.clear_selected()
	
	if combo > 5:
		var ratio = combo / 5.0
		multiplier += ratio - 1.0
	
	combo = 0
		
func process_match(active_suit, selected_suit):
	Globals.selected_card.move_to(active.position)
	active.z_index = 1
	active = Globals.selected_card
	Globals.clear_selected()
	var battle = process_battle(active_suit, selected_suit)
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
	
	card_discard_pile.push_front(active)
	yield(active, "finished_moving")
	arrange_discard_pile()
	
func process_message(message):
	messageLabel.text = message
	messageTween.interpolate_method(self, "on_message_tween", 0, 1, 3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	messageTween.start()
	
func on_message_tween(value):
	messageLabel.modulate = Color(1, 1, 1, 1 - value)

# Scissors cuts paper => SHIP beats MOON
# Paper covers rock => MOON beats SUN
# Rock crushes lizard => SUN beats ALIEN
# Scissors decapitates lizard => SHIP beats ALIEN
# Lizard eats paper => ALIEN beats MOON
# Rock crushes scissors => SUN beats SHIP
#
# SUN  -> MOON  -> SHIP     -> ALIEN
# ROCK -> PAPER -> SCISSORS -> LIZARD
func initialise_battle_matrix():
	var sun =   [  0, -1,  1,  1 ]
	var moon =  [  1,  0, -1, -1 ]
	var ship =  [ -1,  1,  0,  1 ]
	var alien = [ -1,  1, -1,  0 ]
	
	battle_matrix.append(sun)
	battle_matrix.append(moon)
	battle_matrix.append(ship)
	battle_matrix.append(alien)

func process_battle(active_suit, selected_suit):
	print("battle active: %d selected: %d" % [active_suit, selected_suit])
	var battle = battle_matrix[active_suit][selected_suit]
	var result = { 
		credits = battle, 
		first = active_suit, 
		second = selected_suit 
		}
	return result
	
func get_pile_card(pile_index):
	match pile_index:
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
		
	return null
	
func on_discard_click():
	if !pack.empty():
		display_card()

