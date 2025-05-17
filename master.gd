extends Node2D

#generator values
@export var dif_level: int
@export var stat_block = []
@export var hp: int
@export var mp: int
@export var def: int
@export var lvl := 5
@export var type = ["Beast", "Construct", "Demon", "Elemental", "Humanoid", "Monster", 'Plant', "Undead"]
@export var champ_value: int
@export var damage_types = ["Physical", "Air", "Bolt", "Dark", "Earth", "Fire", "Ice", "Light", "Poison"]
@export var vulnerabilities = []
@export var resistances = []
@export var immunities = []
@export var absorption = []
@export var generated = false

#enemy1 values
@export var e1hp: int
@export var e1mp: int
@export var e1vulnerabilities = []
@export var e1resistances = []
@export var e1immunities = []
@export var e1absorption = []

#enemy2 values
@export var e2hp: int
@export var e2mp: int
@export var e2vulnerabilities = []
@export var e2resistances = []
@export var e2immunities = []
@export var e2absorption = []

func _ready() -> void:
	populate_level_picker()

func _on_button_pressed() -> void:
	if $Generator/LevelPicker.get_selected_id() == -1:
		print("ERROR: Please select a level.")
		$Generator/Button/Label.text = "Please select a level."
	if $Generator/Rank.get_selected_id() == -1:
		print("ERROR: Please select a rank.")
#		$Generator/Button/Label.text = "Please select a rank."
	else:
		generated = true
		lvl = $Generator/LevelPicker.get_selected_id()
		difficulty_assign()
		update_stats()
		update_values()
		update_dmg_types()
	
func difficulty_assign():
	dif_level = randi_range(1,3)
	var dif_label = ""
	if dif_level == 1:
		dif_label = "Easy"
	elif dif_level == 2:
		dif_label = "Average"
	elif dif_level == 3:
		dif_label = "Hard"
	$Generator/"Stats/Difficulty Level".text = "Difficulty Level: " + str(dif_label)

func update_stats():
	if dif_level != null:
		stat_block.clear()
		if dif_level == 1:
			stat_block.append_array([6,6,8,8])
		elif dif_level == 2:
			stat_block.append_array([6,6,8,10])
		elif dif_level == 3:
			stat_block.append_array([6,8,10,10])
		stat_block.shuffle()
		$Generator/Stats/DEX.text = "DEX: d" + str(stat_block[0])
		$Generator/Stats/INS.text = "INS: d" + str(stat_block[1])
		$Generator/Stats/MIG.text = "MIG: d" + str(stat_block[2])
		$Generator/Stats/WLP.text = "WLP: d" + str(stat_block[3])

func update_values():
	hp = lvl + (stat_block[0] * 5)
	mp = lvl + (stat_block[1] * 5)
	def = stat_block[0]
	if dif_level == 2:
		pass
	elif dif_level == 1:
		lvl -= randi_range(2, 4)
		hp *= .8
		def += randi_range(0,2)
	elif dif_level ==3:
		hp *= 1.25
		def += randi_range(1,4)
	hp *= champ_value * (1.0 + randf_range(-.1,.1))
	$Generator/Stats/Level.text = "Level: " + str(lvl)
	$Generator/Stats/Type.text = "Type: " + type.pick_random()
	$Generator/Stats/HP.text = "HP: " + str(hp)
	$Generator/Stats/MP.text = "MP: " + str(mp)
	$Generator/Stats/DEF.text = "DEF: " + str(def)

func populate_level_picker():
	var LevelPicker = $Generator/LevelPicker
	for options in range(5,61):
		LevelPicker.add_item(str(options), options)
	for components in range(3,10):
		$Generator/Rank2.add_item(str(components), components)

func _on_rank_item_selected(index: int) -> void:
	if index == 2:
		$Generator/Rank2.show()
		champ_value = 3
	elif index == 1:
		champ_value = 2
		$Generator/Rank2.hide()
	elif index == 0:
		champ_value = 1
		$Generator/Rank2.hide()

func _on_rank_2_item_selected(index: int) -> void:
	champ_value = $Generator/Rank2.get_selected_id()
	print(champ_value)

func update_dmg_types():
	vulnerabilities.clear()
	resistances.clear()
	immunities.clear()
	absorption.clear()
	
	var weakness_roll: int
	var resist_roll: int
	
	if dif_level == 1:
		weakness_roll = randi_range(0,4)
		resist_roll = randi_range(0,1)
	if dif_level == 2:
		weakness_roll = randi_range(0,2)
		resist_roll = randi_range(0,2)
	if dif_level ==3:
		weakness_roll = randi_range(0,1)
		resist_roll = randi_range (0,4)
	print(weakness_roll)
	for i in resist_roll:
		var roll = damage_types.pick_random()
		if resistances.has(roll):
			resistances.erase(roll)
			immunities.append(roll)
		else: resistances.append(roll)
	for i in weakness_roll:
		var roll = damage_types.pick_random()
		if not vulnerabilities.has(roll):
			vulnerabilities.append(damage_types.pick_random())
		else:
			pass
	for i in resistances:
		if vulnerabilities.has(i):
			vulnerabilities.erase(i)
			resistances.erase(i)
			absorption.append(i)
		if immunities.has(i):
			vulnerabilities.erase(i)
			immunities.erase(i)
			absorption.append(i)
			
	$Generator/Affinities/Vulnerabilities.text = "Vunerabilities:\n" + "\n".join(vulnerabilities)
	$Generator/Affinities/Resistances.text = "Resistances:\n" + "\n".join(resistances)
	$Generator/Affinities/Immunity.text = "Immunity:\n" + "\n".join(immunities)
	$Generator/Affinities/Absorb.text = "Absorption:\n" + "\n".join(absorption)

func _on_check_button_toggled(toggled_on: bool) -> void:
	if $Generator/Affinities.visible == false:
		$Generator/Affinities.show()
	elif $Generator/Affinities.visible == true:
		$Generator/Affinities.hide()


func _on_copy_enemy_1_pressed() -> void:
	var source_stats = $Generator/Stats.get_children()
	var source_affinities = $Generator/Affinities.get_children()
	var target_stats = $"HBoxContainer/Enemy 1/Stats".get_children()
	var target_affinities = $"HBoxContainer/Enemy 1/Affinities".get_children()
	
	if generated == false:
		pass
	else:
	
		if 	$"HBoxContainer/Enemy 1".visible == false:
			$"HBoxContainer/Enemy 1".show()
			
		for values in source_stats.size():
			if source_stats[values] is Label and target_stats[values] is Label:
				target_stats[values].text = source_stats[values].text
				
		for values in source_affinities.size():
			if source_affinities[values] is Label and target_affinities[values] is Label:
				target_affinities[values].text = source_affinities[values].text
				
		e1hp = hp
		e1mp = mp
		e1vulnerabilities = vulnerabilities
		e1resistances = resistances
		e1immunities = immunities
		e1absorption = absorption
		
		$"HBoxContainer/Enemy 1/HP".max_value = e1hp
		$"HBoxContainer/Enemy 1/HP".value = e1hp
		$"HBoxContainer/Enemy 1/MP".max_value = e1mp
		$"HBoxContainer/Enemy 1/MP".value = e1mp


func _on_copy_enemy_2_pressed() -> void:
	var source_stats = $Generator/Stats.get_children()
	var source_affinities = $Generator/Affinities.get_children()
	var target_stats = $"HBoxContainer/Enemy 2/Stats".get_children()
	var target_affinities = $"HBoxContainer/Enemy 2/Affinities".get_children()
	
	if generated == false:
		pass
	else:
		if 	$"HBoxContainer/Enemy 2".visible == false:
			$"HBoxContainer/Enemy 2".show()
			
		for values in source_stats.size():
			if source_stats[values] is Label and target_stats[values] is Label:
				target_stats[values].text = source_stats[values].text
		for values in source_affinities.size():
			if source_affinities[values] is Label and target_affinities[values] is Label:
				target_affinities[values].text = source_affinities[values].text
				
		e2hp = hp
		e2mp = mp
		e2vulnerabilities = vulnerabilities
		e2resistances = resistances
		e2immunities = immunities
		e2absorption = absorption
		
		$"HBoxContainer/Enemy 2/HP".max_value = e2hp
		$"HBoxContainer/Enemy 2/HP".value = e2hp
		$"HBoxContainer/Enemy 2/MP".max_value = e2mp
		$"HBoxContainer/Enemy 2/MP".value = e2mp

func _on_e_1_dmg_pressed() -> void:
	var dmg = int($"HBoxContainer/Enemy 1/e1dmgField".text)
	if $"HBoxContainer/Enemy 1/e1dmgField".text.is_valid_int():
		$"HBoxContainer/Enemy 1/HP".value -= dmg
		print($"HBoxContainer/Enemy 1/HP".value)
		print(dmg)
	elif not $"HBoxContainer/Enemy 1/e1dmgField".text is int:
		print("ERROR ON VALUE")

func _on_e_2_dmg_button_pressed() -> void:
	var dmg = int($"HBoxContainer/Enemy 2/e2dmgField".text)
	if $"HBoxContainer/Enemy 2/e2dmgField".text.is_valid_int():
		$"HBoxContainer/Enemy 2/HP".value -= dmg
		print($"HBoxContainer/Enemy 2/HP".value)
		print(dmg)
	elif not $"HBoxContainer/Enemy 2/e2dmgField".text is int:
		print("ERROR ON VALUE")

func _on_powered_by_fabula_ultima_logo_pressed() -> void:
	OS.shell_open("https://need.games/fabula-ultima/")

func _on_e_1_clear_pressed() -> void:
	$"HBoxContainer/Enemy 1".hide()

func _on_e_2_clear_pressed() -> void:
	$"HBoxContainer/Enemy 2".hide()
