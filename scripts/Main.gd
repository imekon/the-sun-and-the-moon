# Scissors cuts paper. Paper covers rock. Rock crushes lizard. Scissors decapitates lizard. Lizard eats paper. Rock crushes scissors.

extends Node2D

onready var pile1 = $Card1
onready var pile2 = $Card2
onready var pile3 = $Card3
onready var pile4 = $Card4

onready var active_pile = $ActivePile
onready var discard_pile = $DiscardPile

onready var selection = $Selection

onready var SunCard = load("res://scenes/SunCard.tscn")
onready var MoonCard = load("res://scenes/MoonCard.tscn")
onready var ShipCard = load("res://scenes/ShipCard.tscn")
onready var AlienCard = load("res://scenes/AlienCard.tscn")

onready var CometCard = load("res://scenes/CometCard.tscn")
onready var BlackHoleCard = load("res://scenes/BlackHoleCard.tscn")

onready var BackCard = load("res://scenes/BackCard.tscn")

onready var CardData = load("res://scripts/CardData.gd")

var pack
var active = null

func _ready():
	randomize()
	
	var back_card = BackCard.instance()
	back_card.position = discard_pile.position
	back_card.scale = Globals.card_scaling
	add_child(back_card)
	
	back_card.connect("card_back_clicked", self, "on_discard_click")
	
	create_pack()
	deal_cards()
	display_card()
	
func _process(delta):
	if Globals.selected_card != null:
		selection.position = Globals.selected_card.position
		
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.is_pressed():
		process_selection()
	
func create_pack():
	pack = []
	for suit in range(4):
		for number in range(13):
			var card = CardData.new(suit, number + 1)
			pack.append(card)

	pack.shuffle()
	
func deal_cards():
	var pos1 = pile1.position
	var pos2 = pile2.position
	var pos3 = pile3.position
	var pos4 = pile4.position
	
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
			
			var card_data = pack[0]
			pack.remove(0)
			
			create_card(card_data, pos, row)
			
func create_card(card_data, pos, row):
	var card : Sprite
	
	match card_data._suit:
		0:
			card = SunCard.instance()
		1:
			card = MoonCard.instance()
		2:
			card = ShipCard.instance()
		3:
			card = AlienCard.instance()
	
	card.scale = Globals.card_scaling
	card.position = pos
	add_child(card)
	card.row = row
	card.card_data = card_data
	card.location = Globals.PILE
	card.set_details(card_data._number)
	return card
				
func display_card():
	var card_data = pack[0]
	pack.remove(0)
	
	active = create_card(card_data, active_pile.position, -1)
	
func process_selection():
	if active == null:
		return
		
	if Globals.selected_card == null:
		return
		
	if active.card_data._number - Globals.selected_card.card_data._number == 1:
		process_match()
		
	if Globals.selected_card.card_data._number - active.card_data._number == 1:
		process_match()
		
func process_match():
	print("matched!")
	
func on_discard_click():
	print("discard clicked")
	
