/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = 2.9
	density = TRUE
	anchored = TRUE
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = NOREACT
	allowed_checks = ALLOWED_CHECK_NONE
	var/max_n_of_items = 1500
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/icon_panel = "smartfridge-panel"
	var/list/item_quants = list()
	var/ispowered = 1 //starts powered
	var/isbroken = 0
	var/seconds_electrified = 0;
	var/shoot_inventory = 0
	var/locked = 0
	var/content_overlay = "smartfridge-food"
	var/datum/wires/smartfridge/wires = null

/obj/machinery/smartfridge/atom_init()
	. = ..()
	wires = new(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/smartfridge(null, type)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()
	create_fridge_states()

/obj/machinery/smartfridge/update_icon()
	create_fridge_states()

/obj/machinery/smartfridge/proc/create_fridge_states()
	cut_overlays()
	if(stat & BROKEN)
		icon_state = "smartfridge-broken"
		add_overlay(image(icon, "smartfridge-glass-broken"))
		return
	add_overlay(image(icon, content_overlay))
	add_overlay(image(icon, "smartfridge-glass"))

/obj/machinery/smartfridge/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/smartfridge/construction()
	for(var/datum/A in contents)
		qdel(A)

/obj/machinery/smartfridge/deconstruction()
	for(var/atom/movable/A in contents)
		A.loc = loc

/obj/machinery/smartfridge/RefreshParts()
	..()

	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = 1500 * B.rating

/obj/machinery/smartfridge/proc/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/grown) || istype(O,/obj/item/seeds))
		return 1
	return 0

/obj/machinery/smartfridge/seeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	content_overlay = "smartfridge-petri"

/obj/machinery/smartfridge/seeds/accept_check(obj/item/O)
	if(istype(O,/obj/item/seeds))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry
	name = "smart chemical storage"
	desc = "A refrigerated storage unit for medicine storage."
	content_overlay = "smartfridge-chem"

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/storage/pill_bottle))
		return TRUE
	if(!istype(O,/obj/item/weapon/reagent_containers))
		return FALSE
	if(istype(O,/obj/item/weapon/reagent_containers/pill)) // empty pill prank ok
		return TRUE
	if(!O.reagents || !O.reagents.reagent_list.len) // other empty containers not accepted
		return FALSE
	if(istype(O,/obj/item/weapon/reagent_containers/syringe) || istype(O,/obj/item/weapon/reagent_containers/glass/bottle) || istype(O,/obj/item/weapon/reagent_containers/glass/beaker) || istype(O,/obj/item/weapon/reagent_containers/spray))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/secure/extract
	name = "Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts."
	req_access = list(access_xenobiology)
	content_overlay = "smartfridge-slime"

/obj/machinery/smartfridge/secure/extract/accept_check(obj/item/O)
	if(istype(O,/obj/item/slime_extract))
		return 1
	return 0

/obj/machinery/smartfridge/secure/medbay
	name = "Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	req_one_access = list(access_medical, access_chemistry)
	content_overlay = "smartfridge-chem"

/obj/machinery/smartfridge/secure/medbay/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/glass))
		return 1
	if(istype(O,/obj/item/weapon/storage/pill_bottle))
		return 1
	if(istype(O,/obj/item/weapon/reagent_containers/pill))
		return 1
	return 0

/obj/machinery/smartfridge/secure/virology
	name = "Refrigerated Virus Storage"
	desc = "A refrigerated storage unit for storing viral material."
	req_access = list(access_virology)
	content_overlay = "smartfridge-viro"

/obj/machinery/smartfridge/secure/virology/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/glass/beaker/vial))
		return 1
	if(istype(O,/obj/item/weapon/virusdish))
		return 1
	return 0

/obj/machinery/smartfridge/chemistry/virology
	name = "Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."
	content_overlay = "smartfridge-viro"


/obj/machinery/smartfridge/drinks
	name = "Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."
	content_overlay = "smartfridge-drink"

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/food/drinks) || istype(O,/obj/item/weapon/reagent_containers/food/condiment))
		return 1

/obj/machinery/smartfridge/secure/bluespace
	name = "Bluespace Storage"
	desc = "Очень вместительное хранилище вещей с гравировкой BB-tech"
	icon_state = "bluespace"
	icon_on = "bluespace"
	icon_off = "bluespace-off"

/obj/machinery/smartfridge/secure/bluespace/accept_check(obj/item/O)
	if(istype(O, /obj/item/weapon/storage/bag) || istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))
		return FALSE
	if(isitem(O))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/secure/bluespace/atom_init()
	. = ..()
	wires = new(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/smartfridge/secure/bluespace(null, type)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/smartfridge/secure/bluespace/create_fridge_states()
	return

/obj/machinery/smartfridge/secure/bluespace/update_icon()
	if(stat & BROKEN)
		icon_state = "bluespace-broken"

/obj/machinery/smartfridge/process()
	if(!src.ispowered)
		return
	if(src.seconds_electrified > 0)
		src.seconds_electrified--
	if(src.shoot_inventory && prob(2))
		throw_item()

/obj/machinery/smartfridge/power_change()
	if( powered() )
		src.ispowered = 1
		stat &= ~NOPOWER
		if(!isbroken)
			icon_state = icon_on
	else
		spawn(rand(0, 15))
		src.ispowered = 0
		stat |= NOPOWER
		if(!isbroken)
			icon_state = icon_off
	update_power_use()

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, icon_off, icon_on, O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	default_deconstruction_crowbar(O)

	if(is_wire_tool(O) && panel_open && wires.interact(user))
		return

	if(!src.ispowered)
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return

	if(accept_check(O))
		if(contents.len >= max_n_of_items)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return
		else
			user.remove_from_mob(O)
			O.loc = src
			if(item_quants[O.name])
				item_quants[O.name]++
			else
				item_quants[O.name] = 1
			user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].</span>", \
								 "<span class='notice'>You add \the [O] to \the [src].</span>")

			nanomanager.update_uis(src)

	else if(istype(O, /obj/item/weapon/storage)) // fastload from userstorage
		if(istype(O, /obj/item/weapon/storage/lockbox))
			var/obj/item/weapon/storage/lockbox/L = O
			if(L.locked)
				to_chat(user, "<span class='notice'>\The [L] is locked.</span>")
				return
		var/obj/item/weapon/storage/S = O
		var/item_loaded = 0
		for(var/obj/I in S.contents)
			if(accept_check(I))
				if(contents.len >= max_n_of_items)
					to_chat(user, "<span class='notice'>\The [src] is full.</span>")
					return
				else
					S.remove_from_storage(I,src)
					if(item_quants[I.name])
						item_quants[I.name]++
					else
						item_quants[I.name] = 1
					item_loaded++

		if(item_loaded)
			user.visible_message( \
				"<span class='notice'>[user] loads \the [src] with \the [S].</span>", \
				"<span class='notice'>You load \the [src] with \the [S].</span>")
			if(S.contents.len > 0)
				to_chat(user, "<span class='notice'>Some items are refused.</span>")

		nanomanager.update_uis(src)
		return
	else
		to_chat(user, "<span class='notice'>\The [src] smartly refuses [O].</span>")
		return

/obj/machinery/smartfridge/secure/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = 1
	locked = -1
	to_chat(user, "You short out the product lock on [src].")
	return TRUE

/obj/machinery/smartfridge/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()
	return 0

/obj/machinery/smartfridge/attack_hand(mob/user)
	if(!issilicon(user) && !isobserver(user) && seconds_electrified)
		if(shock(user, 100))
			return

	return ..()

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/smartfridge/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmartFridge", name)
		ui.open()

/obj/machinery/smartfridge/tgui_data(mob/user)
	var/list/data = list(
	"contents" = null,
	"locked" = locked,
	"secure" = istype(src,/obj/machinery/smartfridge/secure)
	)

	var/list/items[0]
	for (var/i=1 to length(item_quants))
		var/K = item_quants[i]
		var/count = item_quants[K]
		if (count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(K)), "vend" = i, "quantity" = count)))

	if (items.len > 0)
		data["contents"] = items
	return data

/obj/machinery/smartfridge/tgui_act(action, params)
	. = ..()
	if(.)
		return

	if (action == "vend")
		var/index = text2num(params["index"])
		var/amount = text2num(params["amount"])
		var/K = item_quants[index]
		var/count = item_quants[K]

		// Sanity check, there are probably ways to press the button when it shouldn't be possible.
		if(count > 0)
			item_quants[K] = max(count - amount, 0)

			var/i = amount
			for(var/obj/O in contents)
				if (O.name == K)
					O.loc = loc
					i--
					if (i <= 0)
						return TRUE

		return TRUE

/obj/machinery/smartfridge/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for (var/O in item_quants)
		if(item_quants[O] <= 0) //Try to use a record that actually has something to dump.
			continue

		item_quants[O]--
		for(var/obj/T in contents)
			if(T.name == O)
				T.loc = src.loc
				throw_item = T
				break
		break
	if(!throw_item)
		return 0
	throw_item.throw_at(target,16,3,src)
	visible_message("<span class='warning'><b>[src] launches [throw_item.name] at [target.name]!</b></span>")
	return 1

/obj/machinery/smartfridge/proc/shock(mob/user, prb)
	if(!ispowered) return 0
	if(!prob(prb)) return 0

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()

	return electrocute_mob(user, get_area(src), src, 0.7)

/************************
*   Secure SmartFridges
*************************/

/obj/machinery/smartfridge/secure/tgui_act(action, params)
	if(!allowed(usr) && !emagged && locked != -1 && action == "vend")
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return FALSE
	return ..()
