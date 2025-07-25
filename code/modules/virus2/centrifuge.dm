/obj/machinery/computer/centrifuge
	name = "Isolation Centrifuge"
	desc = "Used to separate things with different weight. Spin 'em round, round, right round."
	icon = 'icons/obj/virology.dmi'
	icon_state = "centrifuge"
	var/curing
	var/isolating

	var/obj/item/weapon/reagent_containers/glass/beaker/vial/sample = null
	var/datum/disease2/disease/virus2 = null
	required_skills = list(/datum/skill/chemistry = SKILL_LEVEL_TRAINED, /datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/medical = SKILL_LEVEL_PRO)

/obj/machinery/computer/centrifuge/attackby(obj/item/weapon/O, mob/user)
	if(isscrewing(O))
		return ..()

	else if(istype(O,/obj/item/weapon/reagent_containers/glass/beaker/vial))
		if(sample)
			to_chat(user, "\The [src] is already loaded.")
			return
		if(!do_skill_checks(user))
			return
		sample = O
		user.drop_from_inventory(O, src)

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		SStgui.update_uis(src)
		return

	attack_hand(user)

/obj/machinery/computer/centrifuge/update_icon()
	..()
	if(! (stat & (BROKEN|NOPOWER)) && (isolating || curing))
		icon_state = "centrifuge_moving"

/obj/machinery/computer/centrifuge/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/computer/centrifuge/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IsolationCentrifuge", name)
		ui.open()

/obj/machinery/computer/centrifuge/tgui_data(mob/user)
	var/list/data = list()
	data["antibodies"] = null
	data["pathogens"] = null
	data["is_antibody_sample"] = null

	if (curing)
		data["busy"] = "Isolating antibodies..."
	else if (isolating)
		data["busy"] = "Isolating pathogens..."
	else
		data["sample_inserted"] = !!sample

		if (sample)
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in sample.reagents.reagent_list
			if (B)
				data["antibodies"] = B.data["antibodies"] ? antigens2string(B.data["antibodies"]) : null

				var/list/pathogens[0]
				var/list/virus = B.data["virus2"]
				for (var/ID in virus)
					var/datum/disease2/disease/V = virus[ID]
					pathogens.Add(list(list("name" = V.name(), "spread_type" = V.spreadtype, "reference" = "\ref[V]")))

				if (pathogens.len > 0)
					data["pathogens"] = pathogens

			else
				var/datum/reagent/antibodies/A = locate(/datum/reagent/antibodies) in sample.reagents.reagent_list
				data["antibodies"] = A && A.data["antibodies"] ? antigens2string(A.data["antibodies"]) : null
				data["is_antibody_sample"] = TRUE
	return data

/obj/machinery/computer/centrifuge/tgui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	if(isnull(user))
		return

	switch(action)
		if("print")
			print(user)
			return TRUE
		if("isolate")
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in sample.reagents.reagent_list
			if (B)
				var/datum/disease2/disease/virus = locate(params["index"])
				virus2 = virus.getcopy()
				isolating = 40
				update_icon()
			return TRUE
		if ("antibody")
			var/delay = 20
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in sample.reagents.reagent_list
			if (!B)
				state("\The [src] buzzes, \"No antibody carrier detected.\"", "blue")
				return TRUE

			var/has_toxins = locate(/datum/reagent/toxin) in sample.reagents.reagent_list
			var/has_radium = sample.reagents.has_reagent("radium")
			if (has_toxins || has_radium)
				state("\The [src] beeps, \"Pathogen purging speed above nominal.\"", "blue")
				if (has_toxins)
					delay = delay / 2
				if (has_radium)
					delay = delay / 2

			curing = round(delay)
			playsound(src, 'sound/machines/juicer.ogg', VOL_EFFECTS_MASTER)
			update_icon()
			return TRUE
		if("sample")
			if(sample)
				sample.forceMove(loc)
				sample = null
			return TRUE

	return FALSE

/obj/machinery/computer/centrifuge/process()
	..()
	if (stat & (NOPOWER|BROKEN)) return

	if (curing)
		curing -= 1
		if (curing == 0)
			cure()

	if (isolating)
		isolating -= 1
		if(isolating == 0)
			isolate()

/obj/machinery/computer/centrifuge/proc/cure()
	if (!sample) return
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in sample.reagents.reagent_list
	if (!B) return

	var/list/data = list("antibodies" = B.data["antibodies"])
	var/amt= sample.reagents.get_reagent_amount("blood")
	sample.reagents.remove_reagent("blood", amt)
	sample.reagents.add_reagent("antibodies", amt, data)

	SStgui.update_uis(src)
	update_icon()
	ping("\The [src] pings, \"Antibody isolated.\"")

/obj/machinery/computer/centrifuge/proc/isolate()
	if (!sample) return
	var/obj/item/weapon/virusdish/dish = new/obj/item/weapon/virusdish(loc)
	dish.virus2 = virus2
	virus2 = null

	SStgui.update_uis(src)
	update_icon()
	ping("\The [src] pings, \"Pathogen isolated.\"")

/obj/machinery/computer/centrifuge/proc/print(mob/user)
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(loc)
	P.name = "paper - Pathology Report"
	P.info = {"
		[virology_letterhead("Pathology Report")]
		<large><u>Sample:</u></large> [sample.name]<br>
"}

	if (user)
		P.info += "<u>Generated By:</u> [user.name]<br>"

	P.info += "<hr>"

	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in sample.reagents.reagent_list
	if (B)
		P.info += "<u>Antibodies:</u> "
		P.info += B.data["antibodies"] ? antigens2string(B.data["antibodies"]) : "None"
		P.info += "<br>"

		var/list/virus = B.data["virus2"]
		P.info += "<u>Pathogens:</u> <br>"
		if (virus && virus.len > 0)
			for (var/ID in virus)
				var/datum/disease2/disease/V = virus[ID]
				P.info += "[V.name()]<br>"
		else
			P.info += "None<br>"

	else
		var/datum/reagent/antibodies/A = locate(/datum/reagent/antibodies) in sample.reagents.reagent_list
		if (A)
			P.info += "The following antibodies have been isolated from the blood sample: "
			P.info += A.data["antibodies"] ? antigens2string(A.data["antibodies"]) : "None"
			P.info += "<br>"

	P.info += {"
	<hr>
	<u>Additional Notes:</u> <field>
"}

	P.update_icon()
	state("The nearby computer prints out a pathology report.")
