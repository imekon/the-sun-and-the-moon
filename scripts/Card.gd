extends Sprite

onready var top_label = $TopLabel
onready var bottom_label = $BottomLabel

var card_data = null
var location = Globals.UNKNOWN

func set_details(number):
	match number:
		1:
			top_label.text = "A"
			bottom_label.text = "A"
		2, 3, 4, 5, 6, 7, 8, 9, 10:
			top_label.text = str(number)
			bottom_label.text = str(number)
		11:
			top_label.text = "J"
			bottom_label.text = "J"
		12:
			top_label.text = "Q"
			bottom_label.text = "Q"
		13:
			top_label.text = "K"
			bottom_label.text = "K"

func on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			print("Left Mouse Click suit: %d number %d" % [card_data._suit, card_data._number])
