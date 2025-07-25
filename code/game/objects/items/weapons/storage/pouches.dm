/obj/item/weapon/storage/pouch
	name = "pouch"
	desc = "Can hold various things."
	icon = 'icons/obj/pouches.dmi'
	icon_state = "pouch"
	item_state = "pouch"

	w_class = SIZE_TINY
	slot_flags = SLOT_FLAGS_POCKET|SLOT_FLAGS_BELT //Pouches can be worn on belt
	storage_slots = 1
	max_w_class = SIZE_TINY
	max_storage_space = base_storage_capacity(SIZE_SMALL)
	attack_verb = list("pouched")

	var/sliding_behavior = FALSE

/obj/item/weapon/storage/pouch/verb/toggle_slide()
	set name = "Toggle Slide"
	set desc = "Toggle the behavior of last item in storage \"sliding\" into your hand."
	set category = "Object"

	sliding_behavior = !sliding_behavior
	to_chat(usr, "<span class='notice'>Items will now [sliding_behavior ? "" : "not"] slide out of [src].</span>")

/obj/item/weapon/storage/pouch/attack_hand(mob/living/carbon/human/user)
	if(sliding_behavior && contents.len && loc == user)
		var/obj/item/I = contents[contents.len]
		if(istype(I))
			hide_from(usr)
			var/turf/T = get_turf(user)
			remove_from_storage(I, T)
			usr.put_in_hands(I)
			add_fingerprint(user)
	else
		..()

/obj/item/weapon/storage/pouch/small_generic
	name = "small generic pouch"
	desc = "Can hold anything in it, but only about five."
	icon_state = "small_generic"
	item_state = "small_generic"
	storage_slots = null //Uses generic capacity
	max_storage_space = SIZE_MINUSCULE * 10
	max_w_class = SIZE_TINY

/obj/item/weapon/storage/pouch/medium_generic
	name = "medium generic pouch"
	desc = "Can hold anything in it, but only about eight."
	icon_state = "medium_generic"
	item_state = "medium_generic"
	storage_slots = null //Uses generic capacity
	max_storage_space = SIZE_MINUSCULE * 14
	max_w_class = SIZE_SMALL

/obj/item/weapon/storage/pouch/large_generic
	name = "large generic pouch"
	desc = "A mini satchel. Can hold a fair bit, but it won't fit in your pocket"
	icon_state = "large_generic"
	item_state = "large_generic"
	w_class = SIZE_SMALL
	slot_flags = SLOT_FLAGS_BELT|SLOT_FLAGS_DENYPOCKET
	storage_slots = null //Uses generic capacity
	max_storage_space = SIZE_MINUSCULE * 21
	max_w_class = SIZE_SMALL

/obj/item/weapon/storage/pouch/medical_supply
	name = "medical supply pouch"
	desc = "Can hold medical equipment. But only about six pieces of it."
	icon_state = "medical_supply"
	item_state = "medical_supply"

	storage_slots = 6
	max_w_class = SIZE_SMALL

	can_hold = list(
		/obj/item/device/healthanalyzer,
		/obj/item/device/plant_analyzer,
		/obj/item/device/robotanalyzer,
		/obj/item/weapon/dnainjector,
		/obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/reagent_containers/glass/beaker,
		/obj/item/weapon/reagent_containers/glass/bottle,
		/obj/item/weapon/reagent_containers/pill,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/lighter,
		/obj/item/weapon/storage/fancy/cigarettes,
		/obj/item/weapon/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/device/flashlight/pen,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/gloves/latex,
		/obj/item/weapon/reagent_containers/hypospray,
		/obj/item/clothing/glasses/hud/health,
		/obj/item/device/sensor_device,
		/obj/item/device/mass_spectrometer,
		/obj/item/device/reagent_scanner
		)

/obj/item/weapon/storage/pouch/engineering_tools
	name = "engineering tools pouch"
	desc = "Can hold small engineering tools. But only about six pieces of them."
	icon_state = "engineering_tool"
	item_state = "engineering_tool"

	storage_slots = 6
	max_w_class = SIZE_SMALL

	can_hold = list(
		/obj/item/weapon/crowbar,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/weldingtool,
		/obj/item/weapon/wirecutters,
		/obj/item/weapon/wrench,
		/obj/item/device/multitool,
		/obj/item/device/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/device/t_scanner,
		/obj/item/device/analyzer,
		/obj/item/device/plant_analyzer,
		/obj/item/device/robotanalyzer,
		/obj/item/taperoll/engineering,
		/obj/item/device/radio/headset,
		/obj/item/weapon/minihoe,
		/obj/item/weapon/hatchet,
		/obj/item/weapon/reagent_containers/spray/extinguisher/mini,
		/obj/item/device/tagger,
		/obj/item/clothing/gloves,
		/obj/item/clothing/glasses,
		/obj/item/weapon/lighter,
		/obj/item/weapon/storage/fancy/cigarettes
		)

/obj/item/weapon/storage/pouch/engineering_supply
	name = "engineering supply pouch"
	desc = "Can hold engineering equipment. But only about twenty one pieces of it."
	icon_state = "engineering_supply"
	item_state = "engineering_supply"

	storage_slots = 21
	w_class = SIZE_SMALL
	max_w_class = SIZE_SMALL

	can_hold = list(
		/obj/item/weapon/circuitboard,
		/obj/item/stack/rods,
		/obj/item/stack/sheet,
		/obj/item/weapon/stock_parts,
		/obj/item/device/flashlight,
		/obj/item/weapon/reagent_containers/food/snacks/glowstick,
		/obj/item/stack/cable_coil,
		/obj/item/taperoll/engineering
		)

/obj/item/weapon/storage/pouch/ammo
	name = "ammo pouch"
	desc = "Can hold ammo boxes and bullets."
	// desc = "Can hold ammo magazines and bullets, not the boxes though."
	icon_state = "ammo"
	item_state = "ammo"

	storage_slots = 6
	w_class = SIZE_SMALL
	max_w_class = SIZE_SMALL

	can_hold = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/toy/ammo/gun
		)

/obj/item/weapon/storage/pouch/flare
	name = "flares pouch"
	desc = "Can hold about five flares in. In fact, anything cylindrical and small... Makes you think."
	icon_state = "flare"
	item_state = "flare"

	storage_slots = 5
	w_class = SIZE_SMALL
	max_w_class = SIZE_SMALL

	can_hold = list(
		/obj/item/device/flashlight/flare,
		/obj/item/weapon/reagent_containers/food/snacks/glowstick,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/reagent_containers/glass/beaker/vial,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector,
		/obj/item/weapon/pen,
		/obj/item/weapon/storage/pill_bottle
		)

/obj/item/weapon/storage/pouch/flare/update_icon()
	..()
	cut_overlays()
	if(contents.len)
		add_overlay(image('icons/obj/pouches.dmi', "flare_[contents.len]"))

/obj/item/weapon/storage/pouch/flare/full
	startswith = list(/obj/item/device/flashlight/flare = 5)

/obj/item/weapon/storage/pouch/flare/vial
	name = "vial pouch"
	desc = "Can hold about five vials. Rebranding!"

/obj/item/weapon/storage/pouch/pistol_holster
	name = "pistol holster"
	desc = "Can hold a handgun in."
	icon_state = "pistol_holster"
	item_state = "pistol_holster"

	storage_slots = 1
	w_class = SIZE_SMALL
	max_w_class = SIZE_SMALL

	sliding_behavior = TRUE

/obj/item/weapon/storage/pouch/pistol_holster/can_be_inserted(obj/item/I, stop_messages = FALSE)
	. = ..()
	if(. && istype(I))
		return I.can_be_holstered

/obj/item/weapon/storage/pouch/pistol_holster/update_icon()
	..()
	cut_overlays()
	if(contents.len)
		add_overlay(image('icons/obj/pouches.dmi', "pistol_layer"))

/obj/item/weapon/storage/pouch/baton_holster
	name = "baton sheath"
	desc = "Can hold a baton, or indeed most weapon shafts."
	icon_state = "baton_holster"
	item_state = "baton_holster"

	storage_slots = 1
	max_w_class = SIZE_NORMAL

	can_hold = list(
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/melee/classic_baton,
		/obj/item/weapon/melee/telebaton,
		/obj/item/weapon/wirerod,
		/obj/item/weapon/minihoe,
		/obj/item/weapon/crowbar,
		/obj/item/weapon/reagent_containers/food/snacks/candy/yumbaton
		)

	sliding_behavior = TRUE

/obj/item/weapon/storage/pouch/baton_holster/update_icon()
	..()
	cut_overlays()
	if(contents.len)
		add_overlay(image('icons/obj/pouches.dmi', "baton_layer"))

/obj/item/weapon/storage/pouch/medical_supply/syndicate
	name = "combat medical supply pouch"
	desc = "Can hold combat medical equipment. Issued to syndicate medics."
	icon_state = "medical_syndie"
	item_state = "medical_supply"

	max_storage_space = 18
	storage_slots = 9
	max_w_class = SIZE_SMALL

	startswith = list(
		/obj/item/weapon/reagent_containers/hypospray/combat/bleed,
		/obj/item/weapon/reagent_containers/hypospray/combat/bruteburn,
		/obj/item/weapon/reagent_containers/hypospray/combat/dexalin,
		/obj/item/weapon/reagent_containers/hypospray/combat/atoxin,
		/obj/item/weapon/reagent_containers/hypospray/combat/intdam,
		/obj/item/weapon/reagent_containers/hypospray/combat/pain,
		/obj/item/weapon/reagent_containers/hypospray/combat/bone,
		/obj/item/stack/medical/suture,
		/obj/item/device/healthanalyzer,
	)
