/obj/effect/proc_holder/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating arachnids which will grow into deadly beasts."
	helptext = "The spiders are thoughtless creatures, and may attack their creators when fully grown."
	button_icon_state = "spread_infestation"
	chemical_cost = 30
	genomecost = 2
	req_dna = 1

//Makes some spiderlings. Good for setting traps and causing general trouble.
/obj/effect/proc_holder/changeling/spiders/sting_action(mob/user)
	var/turf = get_turf(user)
	for(var/I in 1 to 2)
		var/obj/structure/spider/spiderling/Sp = new(turf)
		Sp.amount_grown = 1

	feedback_add_details("changeling_powers","SI")
	return TRUE
