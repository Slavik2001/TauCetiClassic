/mob/living/carbon/monkey
	name = "monkey"
	voice_name = "monkey"
	speak_emote = list("chimpers")
	icon_state = "monkey1"
	icon = 'icons/mob/monkey.dmi'
	gender = NEUTER
	pass_flags = PASSTABLE
	ventcrawler = 1
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE
	var/warning_high_pressure = WARNING_HIGH_PRESSURE
	var/warning_low_pressure = WARNING_LOW_PRESSURE
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE
	var/blood_datum = /datum/dirt_cover/red_blood
	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/greaterform = HUMAN                  // Used when humanizing a monkey.
	icon_state = "monkey1"
	//var/uni_append = "12C4E2"                // Small appearance modifier for different species.
	var/list/uni_append = list(0x12C,0x4E2)    // Same as above for DNA2.
	var/update_muts = 1                        // Monkey gene must be set at start.
	var/race = HUMAN // Used for restrictions checking.
	holder_type = /obj/item/weapon/holder/monkey
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/monkey = 5)
	pull_size_ratio = 1.5
	w_class = SIZE_BIG

	moveset_type = /datum/combat_moveset/human

/mob/living/carbon/monkey/proc/handle_monkey_pressure(datum/gas_mixture/environment)
	var/pressure = environment.return_pressure()
	//Returns how much pressure actually affects the mob.
	var/adjusted_pressure = calculate_affecting_pressure(pressure)
	//Account for massive pressure differences
	var/warning_LOW_pressure = WARNING_LOW_PRESSURE
	var/hazard_LOW_pressure = HAZARD_LOW_PRESSURE
	var/warning_HIGH_pressure = WARNING_HIGH_PRESSURE
	var/hazard_HIGH_pressure = HAZARD_HIGH_PRESSURE

	var/datum/species/monk_specie = global.all_species[race]
	if(monk_specie)
		warning_LOW_pressure = monk_specie.warning_low_pressure
		hazard_LOW_pressure = monk_specie.hazard_low_pressure
		warning_HIGH_pressure = monk_specie.warning_high_pressure
		hazard_HIGH_pressure = monk_specie.hazard_high_pressure

	var/highpress_damage = MAX_HIGH_PRESSURE_DAMAGE
	var/lowpress_damage = LOW_PRESSURE_DAMAGE

	if(adjusted_pressure > warning_HIGH_pressure)
		if(adjusted_pressure < hazard_HIGH_pressure)
			pressure_alert = 1
			return
		if(RESIST_HEAT in mutations)
			highpress_damage /= 3
		adjustBruteLoss(min(((adjusted_pressure / hazard_HIGH_pressure) - 1) * PRESSURE_DAMAGE_COEFFICIENT, highpress_damage))
		pressure_alert = 2
	else if(adjusted_pressure < warning_LOW_pressure)
		if(adjusted_pressure >= hazard_LOW_pressure)
			pressure_alert = -1
			return
		if(COLD_RESISTANCE in mutations)
			lowpress_damage /= 3
		adjustBruteLoss(lowpress_damage)
		pressure_alert = -2

/mob/living/carbon/monkey/proc/handle_monkey_temperature(datum/gas_mixture/environment)
	var/temperature = environment.temperature
	var/affecting_temp = (temperature - bodytemperature) * environment.return_relative_density()

	if(!on_fire)
		adjust_bodytemperature(affecting_temp, use_insulation = TRUE, use_steps = TRUE)

	var/heat_lvl_1 = BODYTEMP_HEAT_DAMAGE_LIMIT
	var/cold_lvl_1 = BODYTEMP_COLD_DAMAGE_LIMIT
	var/datum/species/monk_specie = global.all_species[race]
	if(monk_specie)
		heat_lvl_1 = monk_specie.heat_level_1
		cold_lvl_1 = monk_specie.cold_level_1

	if(bodytemperature > heat_lvl_1)
		if(RESIST_HEAT in mutations)
			temp_alert = 1
			return
		temp_alert = 2
		adjustFireLoss(HEAT_DAMAGE_LEVEL_2)
	else if(bodytemperature < cold_lvl_1)
		if(COLD_RESISTANCE in mutations)
			temp_alert = -1
			return
		temp_alert = -2
		adjustFireLoss(COLD_DAMAGE_LEVEL_2)

/mob/living/carbon/monkey/handle_environment(datum/gas_mixture/environment)
	if(stat != DEAD) // lets put this shit somewhere here
		stabilize_body_temperature()

	if(!environment || HAS_TRAIT(src, ELEMENT_TRAIT_GODMODE))
		return
	handle_monkey_pressure(environment)
	handle_monkey_temperature(environment)

/mob/living/carbon/monkey/tajara
	name = "farwa"
	voice_name = "farwa"
	speak_emote = list("mews")
	icon_state = "tajkey1"
	uni_append = list(0x0A0,0xE00) // 0A0E00
	race = TAJARAN
	holder_type = /obj/item/weapon/holder/monkey/farwa

/mob/living/carbon/monkey/skrell
	name = "neaera"
	voice_name = "neaera"
	speak_emote = list("squicks")
	icon_state = "skrellkey1"
	uni_append = list(0x01C,0xC92) // 01CC92
	race = SKRELL
	holder_type = /obj/item/weapon/holder/monkey/neaera
	blood_datum = /datum/dirt_cover/purple_blood

/mob/living/carbon/monkey/unathi
	name = "stok"
	voice_name = "stok"
	speak_emote = list("hisses")
	icon_state = "stokkey1"
	uni_append = list(0x044,0xC5D) // 044C5D
	race = UNATHI
	holder_type = /obj/item/weapon/holder/monkey/stok

/mob/living/carbon/monkey/pluvian
	name = "Pluv-key"
	voice_name = "Pluv-key"
	cases = list("Плувеныш", "Плувеныша", "Плувешыну", "Плувеныша", "Плувенышом", "Плувеныше")
	speak_emote = list("chimpers")
	icon_state = "pluvian"
	race = PLUVIAN
	holder_type = /obj/item/weapon/holder/monkey/pluvia

/mob/living/carbon/monkey/atom_init()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	if(name == initial(name)) //To stop Pun-Pun becoming generic.
		name = "[name] ([rand(1, 1000)])"
		real_name = name

	if (!(dna))
		if(gender == NEUTER)
			gender = pick(MALE, FEMALE)
		dna = new /datum/dna( null )
		dna.real_name = real_name
		dna.ResetSE()
		dna.ResetUI()
		//dna.uni_identity = "00600200A00E0110148FC01300B009"
		//dna.SetUI(list(0x006,0x002,0x00A,0x00E,0x011,0x014,0x8FC,0x013,0x00B,0x009))
		//dna.struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B0FD6"
		//dna.SetSE(list(0x433,0x591,0x567,0x561,0x31E,0x137,0x633,0x34D,0x1C3,0x690,0x120,0x321,0x64D,0x4FE,0x4CD,0x615,0x44B,0x6C0,0x3F2,0x51B,0x6C6,0x0A4,0x282,0x1D2,0x6BA,0x3B0,0xFD6))
		dna.unique_enzymes = md5(name)

		// We're a monkey
		dna.SetSEState(MONKEYBLOCK,   1)
		dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)
		// Fix gender
		dna.SetUIState(DNA_UI_GENDER, gender != MALE, 1)

		// Set the blocks to uni_append, if needed.
		if(uni_append.len>0)
			for(var/b=1;b<=uni_append.len;b++)
				dna.SetUIValue(DNA_UI_LENGTH-(uni_append.len-b),uni_append[b], 1)
		dna.UpdateUI()

		update_muts=1

	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_BAREFOOT, 0.5, -1)

	. = ..()

	monkey_list += src
	update_icons()

/mob/living/carbon/monkey/Destroy()
	monkey_list -= src
	return ..()

/mob/living/carbon/monkey/unathi/atom_init()
	. = ..()
	greaterform = UNATHI
	add_language(LANGUAGE_SINTAUNATHI)

/mob/living/carbon/monkey/skrell/atom_init()
	. = ..()
	greaterform = SKRELL
	add_language(LANGUAGE_SKRELLIAN)

/mob/living/carbon/monkey/tajara/atom_init()
	. = ..()
	greaterform = TAJARAN
	add_language(LANGUAGE_SIIKTAJR)

/mob/living/carbon/monkey/pluvian/atom_init()
	. = ..()
	greaterform = PLUVIAN

/mob/living/carbon/monkey/movement_delay()
	var/tally = speed

	if(reagents && reagents.has_reagent("hyperzine") || reagents.has_reagent("nuka_cola"))
		return -1

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45)
		tally += (health_deficiency / 25)

	tally += count_pull_debuff()

	if (bodytemperature < BODYTEMP_NORMAL - 30)
		tally += 1.75 * (BODYTEMP_NORMAL - 30 - bodytemperature) / 10
	return tally + config.monkey_delay

/mob/living/carbon/monkey/count_pull_debuff()
	return pulling ? ..() + 1 : 0

/mob/living/carbon/monkey/helpReaction(mob/living/attacker, show_message = TRUE)
	help_shake_act(attacker)
	get_scooped(attacker)

/mob/living/carbon/monkey/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")
		if(istype(src, /mob/living/carbon/monkey/diona))
			stat(null, "Nutriment: [nutrition]/[NUTRITION_LEVEL_NORMAL]")
	if(mind)
		for(var/role in mind.antag_roles)
			var/datum/role/R = mind.antag_roles[role]
			stat(R.StatPanel())

/mob/living/carbon/monkey/verb/removeinternal()
	set name = "Remove Internals"
	set category = "IC"
	internal = null
	return

/mob/living/carbon/monkey/emp_act(severity)
	if(wear_id) wear_id.emplode(severity)
	..()

/mob/living/carbon/monkey/ex_act(severity)
	if(!blinded)
		flash_eyes()

	switch(severity)
		if(EXPLODE_DEVASTATE)
			if (stat != DEAD)
				adjustBruteLoss(200)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(EXPLODE_HEAVY)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(EXPLODE_LIGHT)
			if (stat != DEAD)
				adjustBruteLoss(30)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
			if (prob(50))
				Paralyse(10)

/mob/living/carbon/monkey/blob_act()
	if (stat != DEAD)
		adjustFireLoss(60)
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	if (prob(50))
		Paralyse(10)
	if (stat == DEAD && client)
		gib()
		return
	if (stat == DEAD && !client)
		new /obj/effect/gibspawner/generic(get_turf(loc), src)
		qdel(src)
		return


/mob/living/carbon/monkey/IsAdvancedToolUser()//Unless its monkey mode monkeys cant use advanced tools
	return 0

/mob/living/carbon/monkey/say(message, datum/language/speaking = null, verb="says", alt_name="", italics=0, message_range = world.view, list/used_radios = list())
	if(stat != CONSCIOUS)
		return

	if(!message)
		return

	if(message[1] == "*")
		return emote(copytext(message, 2))

	if(speak_emote.len)
		verb = pick(speak_emote)

	message = capitalize(trim_left(message))

	..(message, speaking, verb, alt_name, italics, message_range, used_radios)

/mob/living/carbon/monkey/is_usable_head(targetzone = null)
	return TRUE

/mob/living/carbon/monkey/is_usable_arm(targetzone = null)
	return TRUE

/mob/living/carbon/monkey/is_usable_leg(targetzone = null)
	return TRUE

/mob/living/carbon/monkey/get_species()
	return race

/mob/living/carbon/monkey/is_facehuggable()
	return stat != DEAD && !(locate(/obj/item/alien_embryo) in contents)
