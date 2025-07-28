extends Control

enum CardType { DAMAGE, HEAL, SHIELD, BUFF }

var deck := [
	{"name": "Fireball", "mana_cost": 3, "type": CardType.DAMAGE},
	{"name": "Fireball", "mana_cost": 3, "type": CardType.DAMAGE},
	{"name": "Ice Shard", "mana_cost": 2, "type": CardType.DAMAGE},
	{"name": "Ice Shard", "mana_cost": 2, "type": CardType.DAMAGE},
	{"name": "Heal", "mana_cost": 2, "type": CardType.HEAL},
	{"name": "Heal", "mana_cost": 2, "type": CardType.HEAL},
	{"name": "Shield", "mana_cost": 1, "type": CardType.SHIELD},
	{"name": "Shield", "mana_cost": 1, "type": CardType.SHIELD},
	{"name": "Battle Cry", "mana_cost": 2, "type": CardType.BUFF},
	{"name": "Battle Cry", "mana_cost": 2, "type": CardType.BUFF},
]

var graveyard := []
var hand := [null, null, null, null]  # Fixed 4 slots
var max_hand_size := 4
var reshuffle_mana_cost := 5

@onready var card_display_container := get_node("CardDisplayContainer")
@onready var main_control := get_node("/root/Control")
@onready var reshuffle_button := get_node("../ReshuffleButton")
@onready var deck_count_label := get_node("../DeckCountLabel")
@onready var graveyard_count_label := get_node("../GraveyardCountLabel")

func _ready():
	reshuffle_button.pressed.connect(reshuffle_graveyard)
	shuffle_deck()
	fill_hand()
	update_card_display()
	update_counts()

func shuffle_deck():
	deck.shuffle()

func fill_hand():
	for i in range(max_hand_size):
		if hand[i] == null and deck.size() > 0:
			hand[i] = deck.pop_back()
	update_counts()

func update_card_display():
	for child in card_display_container.get_children():
		child.queue_free()

	for i in range(hand.size()):
		var card = hand[i]
		var button = Button.new()
		if card != null:
			button.text = "%d: %s (Cost: %d)" % [i + 1, card["name"], card["mana_cost"]]
			var card_index = i
			button.pressed.connect(func():
				on_card_clicked(card_index)
			)
		else:
			button.text = "%d: (Empty)" % [i + 1]
			button.disabled = true
		card_display_container.add_child(button)

func on_card_clicked(card_index):
	var card = hand[card_index]
	if card == null:
		return  # Nothing to play

	if main_control.spend_mana(card["mana_cost"]):
		print("✅ Played card:", card["name"])
		graveyard.append(card)
		# Replace slot with new card (if deck has any), else leave null
		if deck.size() > 0:
			hand[card_index] = deck.pop_back()
		else:
			hand[card_index] = null
		update_card_display()
		update_counts()
	else:
		print("❌ Not enough mana to play:", card["name"])

func reshuffle_graveyard():
	if graveyard.size() == 0:
		print("⚠ Graveyard is already empty!")
		return

	if main_control.spend_mana(reshuffle_mana_cost):
		deck += graveyard
		graveyard.clear()
		shuffle_deck()
		print("♻ Graveyard reshuffled into deck!")
		fill_hand()
		update_card_display()
		update_counts()
	else:
		print("❌ Not enough mana to reshuffle graveyard.")

func update_counts():
	deck_count_label.text = "Deck: %d" % deck.size()
	graveyard_count_label.text = "Graveyard: %d" % graveyard.size()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				try_play_card(0)
			KEY_2:
				try_play_card(1)
			KEY_3:
				try_play_card(2)
			KEY_4:
				try_play_card(3)
			KEY_R:
				reshuffle_graveyard()

func try_play_card(index):
	if index >= 0 and index < hand.size():
		on_card_clicked(index)
