extends Node2D

var CardData
var pack

func _ready():
	CardData = load("res://scripts/CardData.gd")

	create_pack()
	
func create_pack():
	pack = []
	for suit in range(4):
		for number in range(13):
			var card = CardData.new(suit, number)
			pack.append(card)

	pack.sort()
	
	dump_cards()
	
func dump_cards():
	for card in pack:
		print("Suit: %d Number: %d" % [card._suit, card._number])