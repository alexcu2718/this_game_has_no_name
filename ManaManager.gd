extends Control

var max_mana := 10.0
var current_mana := 3.0

var match_time := 0.0
var mana_timer := 0.0
var mana_regen_interval := 1.0  # seconds between ticks

var base_mana_regen_rate := 1.0  # mana per tick
var mana_regen_growth := 0.01    # per second growth

@onready var mana_bar := $ManaBar

func _ready():
	mana_bar.max_value = max_mana
	mana_bar.value = round(current_mana)

func _process(delta):
	match_time += delta
	mana_timer += delta

	var current_regen_rate = base_mana_regen_rate + (match_time * mana_regen_growth)

	if mana_timer >= mana_regen_interval:
		if current_mana < max_mana:
			current_mana += current_regen_rate
			if current_mana > max_mana:
				current_mana = max_mana
			mana_bar.value = round(current_mana)
			print("Mana increased:", current_mana, " Regen rate:", current_regen_rate)
		mana_timer = 0

# ✅ Checks if enough mana
func has_enough_mana(amount):
	return current_mana >= amount

# ✅ Spends mana safely
func spend_mana(amount):
	if has_enough_mana(amount):
		current_mana -= amount
		if current_mana < 0:
			current_mana = 0
		mana_bar.value = round(current_mana)
		return true
	return false
