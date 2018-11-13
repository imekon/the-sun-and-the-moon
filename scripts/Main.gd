extends Node2D

const UPPERMOST = 10

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
onready var timer = $Timer

onready var SunCard = load("res://scenes/SunCard.tscn")
onready var MoonCard = load("res://scenes/MoonCard.tscn")
onready var ShipCard = load("res://scenes/ShipCard.tscn")
onready var AlienCard = load("res://scenes/AlienCard.tscn")

onready var CometCard = load("res://scenes/CometCard.tscn")
onready var BlackHoleCard = load("res://scenes/BlackHoleCard.tscn")

onready var BackCard = load("res://scenes/BackCard.tscn")

var pack = []
var pile = []
var active = null
var previous = null

var credits = 0
var combo = 0
var multiplier = 1.0

var battle_matrix = []

var offscreen = Vector2(-200, 400)

func _ready():
	randomize()
	
	initialise_battle_matrix()
	
	var back_card = BackCard.instance()
	back_card.position = discard_pile.position
	back_card.scale = Globals.card_scaling
	add_child(back_card)
	
	back_card.connect("card_back_clicked", self, "on_discard_click")
	
	create_pack()
	deal_cards()
	display_card()
	
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
			card.z_index = row - 4
			
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
	if previous != null:
		previous.position = offscreen
		
	if active != null:
		pack.append(active)
		active.z_index = -1
		
	previous = active
		
	active = pack[0]
	pack.remove(0)
	
	active.z_index = UPPERMOST
	active.position = discard_pile.position
	active.move_to(active_pile.position)
	
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
	
	combo = 0
		
func process_match(active_suit, selected_suit):
	# Globals.selected_card.position = active.position
	Globals.selected_card.move_to(active.position)
	active.z_index = 0
	active = Globals.selected_card
	active.z_index = UPPERMOST
	Globals.clear_selected()
	var battle = process_battle(active_suit, selected_suit)
	match battle:
		-1:
			credits += active.card_credits * 0.5
		0:
			credits += active.card_credits
		1:
			credits += active.card_credits * 2
			
	combo += 1

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

func process_battle(active, selected):
	print("battle active: %d selected: %d" % [active, selected])
	var battle = battle_matrix[active][selected]
	return battle
	
func on_discard_click():
	if !pack.empty():
		display_card()

