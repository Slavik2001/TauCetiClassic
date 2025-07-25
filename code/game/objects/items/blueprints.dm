/obj/item/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacked", "bapped", "hit")
	var/max_area_size = 300
	var/greedy = 0

	var/const/AREA_ERRNONE = 0
	var/const/AREA_STATION = 1
	var/const/AREA_SPACE =   2
	var/const/AREA_SPECIAL = 3

	var/const/BORDER_ERROR = 0
	var/const/BORDER_NONE = 1
	var/const/BORDER_BETWEEN =   2
	var/const/BORDER_2NDTILE = 3
	var/const/BORDER_SPACE = 4

	var/const/ROOM_ERR_LOLWAT = 0
	var/const/ROOM_ERR_SPACE = -1
	var/const/ROOM_ERR_TOOLARGE = -2

/obj/item/blueprints/attack_self(mob/M)
	if (!ishuman(M))
		to_chat(M, "This stack of blue paper means nothing to you.")//monkeys cannot into projecting
		return
	interact()
	return

/obj/item/blueprints/Topic(href, href_list)
	..()
	if ((usr.incapacitated() || usr.get_active_hand() != src))
		return
	if (!href_list["action"])
		return
	switch(href_list["action"])
		if ("create_area")
			if (get_area_by_type()!=AREA_SPACE)
				interact()
				return
			create_area()
		if ("edit_area")
			if (get_area_by_type()!=AREA_STATION)
				interact()
				return
			edit_area()

/obj/item/blueprints/interact()
	var/area/A = get_blueprint_area()
	var/text = "<small>Property of Nanotrasen. For heads of staff only. Store in high-secure storage.</small><hr>"
	switch (get_area_by_type())
		if (AREA_SPACE)
			text += {"
<p>According the blueprints, you are now in <b>outer space</b>.  Hold your breath.</p>
<p><a href='byond://?src=\ref[src];action=create_area'>Mark this place as new area</a></p>
"}
		if (AREA_STATION)
			text += {"
<p>According the blueprints, you are now in <b>\"[A.name]\"</b>.</p>
<p>You may <a href='byond://?src=\ref[src];action=edit_area'>
move an amendment</a> to the drawing.</p>
"}
		if (AREA_SPECIAL)
			text += {"
<p>This place isn't noted on the blueprint.</p>
"}
		else
			return

	var/datum/browser/popup = new(usr, "blueprints", "[station_name()] blueprints")
	popup.set_content(text)
	popup.open()

/obj/item/blueprints/proc/get_blueprint_area()
	var/turf/T = get_turf_loc(usr)
	var/area/A = T.loc
	return A

/obj/item/blueprints/proc/get_area_by_type(area/A = get_blueprint_area())
	if (istype(A, /area/space))
		return AREA_SPACE
	if (istype(A, /area/awaymission/junkyard))
		return AREA_SPACE // allow junkyard building
	var/list/SPECIALS = list(
		/area/shuttle,
		/area/centcom,
		/area/asteroid,
		/area/centcom/tdome,
		/area/shuttle/syndicate,
		/area/custom/wizard_station
		// /area/space_structures/derelict //commented out, all hail derelict-rebuilders!
	)
	for (var/type in SPECIALS)
		if ( istype(A,type) )
			return AREA_SPECIAL
	return AREA_STATION

/obj/item/blueprints/proc/create_area()
	//world << "DEBUG: create_area"
	var/res = detect_room(get_turf_loc(usr))
	if(!istype(res,/list))
		switch(res)
			if(ROOM_ERR_SPACE)
				to_chat(usr, "<span class='warning'>The new area must be completely airtight!</span>")
				return
			if(ROOM_ERR_TOOLARGE)
				to_chat(usr, "<span class='warning'>The new area too large!</span>")
				return
			else
				to_chat(usr, "<span class='warning'>Error! Please notify administration!</span>")
				return
	var/list/turf/turfs = res
	var/str = sanitize_safe(input(usr,"New area name:","Blueprint Editing", ""), MAX_LNAME_LEN)
	if(!str || !length(str)) //cancel
		return
	if(length(str) > 50)
		to_chat(usr, "<span class='warning'>Name too long.</span>")
		return
	var/area/A = new
	A.name = str
	A.tag="[A.type]_[md5(str)]" // without this dynamic light system ruin everithing
	//world << "DEBUG: create_area: <br>A.name=[A.name]<br>A.tag=[A.tag]"
	A.power_equip = 0
	A.power_light = 0
	A.power_environ = 0
	A.always_unpowered = 0
	A.valid_territory = 0
	move_turfs_to_area(turfs, A)
	A.always_unpowered = 0
	A.update_areasize()

	spawn(5)
		//world << "DEBUG: create_area(5): <br>A.name=[A.name]<br>A.tag=[A.tag]"
		interact()
	return


/obj/item/blueprints/proc/move_turfs_to_area(list/turf/turfs, area/A)
	for(var/i in 1 to turfs.len)
		var/turf/thing = turfs[i]
		var/area/old_area = thing.loc
		A.contents += thing
		thing.change_area(old_area, A)


/obj/item/blueprints/proc/edit_area()
	var/area/A = get_blueprint_area()
	//world << "DEBUG: edit_area"
	var/prevname = "[A.name]"
	var/str = sanitize_safe(input(usr,"New area name:","Blueprint Editing", input_default(prevname)), MAX_LNAME_LEN)
	if(!str || !length(str) || str==prevname) //cancel
		return
	if(length(str) > 50)
		to_chat(usr, "<span class='warning'>Text too long.</span>")
		return
	set_area_machinery_title(A,str,prevname)
	A.name = str
	A.update_areasize()
	to_chat(usr, "<span class='notice'>You set the area '[prevname]' title to '[str]'.</span>")
	interact()
	return



/obj/item/blueprints/proc/set_area_machinery_title(area/A,title,oldtitle)
	if (!oldtitle) // or replacetext goes to infinite loop
		return

	for(var/obj/machinery/alarm/M in src)
		M.name = replacetext(M.name,oldtitle,title)
	for(var/obj/machinery/power/apc/M in src)
		M.name = replacetext(M.name,oldtitle,title)
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/M in src)
		M.name = replacetext(M.name,oldtitle,title)
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/M in src)
		M.name = replacetext(M.name,oldtitle,title)
	for(var/obj/machinery/door/M in src)
		M.name = replacetext(M.name,oldtitle,title)
	//TODO: much much more. Unnamed airlocks, cameras, etc.

/obj/item/blueprints/proc/check_tile_is_border(turf/T2,dir)
	if (isenvironmentturf(T2))
		return BORDER_SPACE //omg hull breach we all going to die here
	if (istype(T2, /turf/simulated/shuttle))
		return BORDER_SPACE
	if (get_area_by_type(T2.loc)!=AREA_SPACE)
		return BORDER_BETWEEN
	if (iswallturf(T2))
		return BORDER_2NDTILE
	if (!istype(T2, /turf/simulated) || (dir in list(NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST))) // why we need to check dir
		return BORDER_BETWEEN

	for (var/obj/structure/window/fulltile/W in T2)
		return BORDER_2NDTILE
	for (var/obj/structure/window/thin/W in T2)
		if(turn(dir,180) == W.dir)
			return BORDER_2NDTILE
	for(var/obj/machinery/door/window/D in T2)
		if(turn(dir,180) == D.dir)
			return BORDER_BETWEEN
	if (locate(/obj/machinery/door) in T2)
		return BORDER_2NDTILE
	if (locate(/obj/structure/falsewall) in T2)
		return BORDER_2NDTILE
	if (locate(/obj/structure/mineral_door) in T2)
		return BORDER_2NDTILE
	if (locate(/obj/structure/inflatable/door) in T2)
		return BORDER_2NDTILE

	return BORDER_NONE

/obj/item/blueprints/proc/detect_room(turf/first)
	var/list/turf/found = new
	var/list/turf/pending = list(first)
	while(pending.len)
		if (found.len+pending.len > max_area_size)
			return ROOM_ERR_TOOLARGE
		var/turf/T = pending[1] //why byond havent list::pop()?
		pending -= T
		for (var/dir in alldirs)
			if(!greedy) // we want to add windows to area or not
				var/skip = 0
				for (var/obj/structure/window/thin/W in T)
					if(dir == W.dir)
						skip = 1; break
				if (skip) continue
				for(var/obj/machinery/door/window/D in T)
					if(dir == D.dir)
						skip = 1; break
				if (skip) continue

			var/turf/NT = get_step(T,dir)
			if (!isturf(NT) || (NT in found) || (NT in pending))
				continue

			switch(check_tile_is_border(NT,dir))
				if(BORDER_NONE)
					pending+=NT
				if(BORDER_BETWEEN)
					EMPTY_BLOCK_GUARD
					//do nothing, may be later i'll add 'rejected' list as optimization
				if(BORDER_2NDTILE)
					found+=NT //tile included to new area, but we dont seek more
				if(BORDER_SPACE)
					return ROOM_ERR_SPACE
		found+=T
	return found
