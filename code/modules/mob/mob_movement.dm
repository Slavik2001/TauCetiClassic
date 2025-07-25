/mob/CanPass(atom/movable/mover, turf/target, height=0)
	var/retVal = SEND_SIGNAL(src, COMSIG_ATOM_CANPASS, mover, target, height)
	if(retVal & COMPONENT_CANTPASS)
		return FALSE
	else if(retVal & COMPONENT_CANPASS)
		return TRUE

	if(!mover)
		return TRUE

	if(istype(mover, /obj/item/projectile) || mover.throwing)
		return (!density || lying)
	if(mover.checkpass(PASSMOB) || checkpass(PASSMOB))
		return 1
	if(buckled == mover)
		return 1
	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((other_mobs && moving_mob.other_mobs))
			return 1
		if (mover == buckled_mob)
			return 1
	return (!mover.density || !density || lying)

/mob/proc/setMoveCooldown(timeout)
	if(client)
		client.move_delay = max(world.time + timeout, client.move_delay)

/client/North()
	..()

/client/South()
	..()

/client/West()
	..()

/client/East()
	..()

/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)	return
			mob.control_object.set_dir(direct)
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	return

/client/Move(n, direct, forced = FALSE)
	if(!mob)
		return // Moved here to avoid nullrefs below

	if(!forced)
		if(moving || mob.throwing)
			return

		if(world.time < move_delay) //do not move anything ahead of this check please
			return
		else
			next_move_dir_add = 0
			next_move_dir_sub = 0

	if(mob.control_object)	Move_object(direct)

	if(isobserver(mob) || isovermind(mob))
		return mob.Move(n,direct)

	if(!n || !direct)
		return
	if(!forced && mob.stat != CONSCIOUS)
		return

/*	// handle possible spirit movement
	if(istype(mob,/mob/spirit))
		var/mob/spirit/currentSpirit = mob
		return currentSpirit.Spirit_Move(direct) */

	// handle possible AI movement

	if(mob.remote_control)					//we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		var/mob/living/silicon/ai/A = mob
		if(!A.uses_legs)
			return AIMove(n,direct,mob)

	if(mob.notransform)
		return//This is sota the goto stop mobs from moving var

	if(isliving(mob))
		var/mob/living/L = mob
		if(L.incorporeal_move)//Move though walls
			Process_Incorpmove(direct)
			return
	Process_Grab()

	if(!forced && !mob.canmove)
		return

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return 0

	if(isturf(mob.loc))

		if(mob.restrained())//Why being pulled while cuffed prevents you from moving
			var/mob/M = mob.pulledby
			if(M)
				if(!M.incapacitated() && M.canmove && mob.Adjacent(M))
					to_chat(src, "<span class='notice'>You're incapacitated! You can't move!</span>")
					return 0
				else
					M.stop_pulling()

		//Calculating delays
		var/add_delay = 0

		mob.last_move_intent = world.time + 10

		add_delay += mob.m_intent_delay()

		var/list/grabs = mob.GetGrabs()
		if(grabs.len)
			var/grab_delay
			for(var/obj/item/weapon/grab/G in grabs)
				grab_delay += max(0, (G.state - 1) * 4 + (grabs.len - 1) * 4) // so if we have 2 grabs or 1 in high level we will be sloow
				grab_delay += G.affecting.stat == CONSCIOUS ? ( G.affecting.a_intent == INTENT_HELP ? 0 : 0.5 ) : 1
			add_delay += grab_delay

		add_delay += mob.movement_delay()

		move_delay = world.time + add_delay //set move delay

		//Relaymoves
		if(istype(mob.pulledby, /obj/structure/stool/bed/chair/wheelchair))
			return mob.pulledby.relaymove(mob, direct)

		if(mob.buckled) // Wheelchair driving!
			if(isspaceturf(mob.loc))
				return // No wheelchair driving in space

			return mob.buckled.relaymove(mob, direct)

		//We are now going to move
		moving = TRUE

		if(SEND_SIGNAL(mob, COMSIG_CLIENTMOB_MOVE, n, direct) & COMPONENT_CLIENTMOB_BLOCK_MOVE)
			// Someone please investigate why we can't do moving = TRUE *after* this check. ~Luduk
			moving = FALSE
			return

		SEND_SIGNAL(mob, COMSIG_CLIENTMOB_MOVING, n, direct)

		//Something with pulling things
		if(grabs.len)
			var/list/L = mob.ret_grab()
			if(istype(L, /list))
				if(L.len == 2)
					L -= mob
					var/mob/M = L[1]
					if(M)
						if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
							var/turf/T = mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(mob, M)
								if (!((diag - 1) & diag))
									diag = null
								if ((get_dist(mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
				else
					for(var/mob/M in L)
						M.other_mobs = 1
						if(mob != M)
							M.animate_movement = 3
					for(var/mob/M in L)
						spawn( 0 )
							step(M, direct)
							return
						spawn( 1 )
							M.other_mobs = null
							M.animate_movement = 2
							return

		else
			if(mob.confused && !mob.crawling)
				direct = mob.confuse_input(direct)
				n = get_step(get_turf(mob), direct)
			. = mob.SelfMove(n, direct)

		for(var/obj/item/weapon/grab/G in grabs)
			if(G.state == GRAB_NECK)
				mob.set_dir(reverse_dir[direct])
			G.adjust_position()

		for(var/obj/item/weapon/grab/G in mob.grabbed_by)
			G.adjust_position()

		if((direct & (direct - 1)) && mob.loc == n)
			move_delay += add_delay * 0.4 // in general moving diagonally will be 1.4 (sqrt(2)) times slower

		moving = FALSE

		if(mob && .)
			mob.throwing = FALSE

		SEND_SIGNAL(mob, COMSIG_CLIENTMOB_POSTMOVE, n, direct)

/mob/proc/random_move()
	if(isturf(loc) && !isspaceturf(loc) || (canmove && !incapacitated()))
		step(src, pick(cardinal))

/mob/proc/SelfMove(turf/n, direct)
	if(camera_move(direct))
		return FALSE
	return Move(n, direct)

/mob/proc/camera_move(Dir = 0)
	if(stat || restrained())
		return FALSE
	if(!machine || !istype(machine, /obj/machinery/computer/security))
		return FALSE
	if(!Adjacent(machine) || !machine.can_interact_with(src))
		return FALSE
	var/obj/machinery/computer/security/console = machine

	if(QDELETED(console.active_camera))
		console.active_camera = null // if qdeling, set it null
		return FALSE

	var/turf/T = get_turf(console.active_camera)
	var/list/cameras = list()

	for(var/cam_tag in console.camera_cache)
		var/obj/C = console.camera_cache[cam_tag]
		if(C == console.active_camera)
			continue
		if(C.z != T.z)
			continue
		var/dx = C.x - T.x
		var/dy = C.y - T.y
		var/is_in_bounds = FALSE
		switch(Dir)
			if(NORTH)
				is_in_bounds = dy >= abs(dx)
			if(SOUTH)
				is_in_bounds = dy <= -abs(dx)
			if(EAST)
				is_in_bounds = dx >= abs(dy)
			if(WEST)
				is_in_bounds = dx <= -abs(dy)
		if(is_in_bounds)
			cameras += C
	var/minDist = INFINITY
	var/minCam = console.active_camera
	for(var/obj/machinery/camera/C as anything in cameras)
		var/dist = get_dist(T, C)
		if(dist < minDist)
			minCam = C
			minDist = dist
	console.jump_on_click(src, minCam)
	return TRUE

///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	if(!isliving(mob))
		return
	var/mob/living/L = mob
	switch(L.incorporeal_move)
		if(1)
			L.loc = get_step(L, direct)
			L.set_dir(direct)
		if(2)
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				L.loc = locate(locx,locy,mobloc.z)
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, L.loc))
						spawn(0)
							anim(T,L,'icons/mob/mob.dmi',,"shadow",,L.dir)
						limit--
						if(limit<=0)	break
			else
				spawn(0)
					anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,L.dir)
				L.loc = get_step(L, direct)
			L.set_dir(direct)
	return 1


///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/Process_Spacemove(movement_dir = 0)

	if(..())
		return 1

	var/atom/movable/dense_object_backup
	for(var/atom/A in orange(1, get_turf(src)))
		if(isarea(A))
			continue

		else if(isturf(A))
			var/turf/turf = A
			if(isspaceturf(turf))
				continue

			if(!turf.density && !mob_negates_gravity())
				continue

			return 1

		else
			var/atom/movable/AM = A
			if(AM == buckled || AM.type == /obj/effect/portal/tsci_wormhole) //hardcoded type check, since idk if we need such feature for something else at all.
				continue
			if(AM.density)
				if(AM.anchored)
					return 1
				if(pulling == AM)
					continue
				dense_object_backup = AM

	if(movement_dir && dense_object_backup)
		if(dense_object_backup.newtonian_move(turn(movement_dir, 180))) //You're pushing off something movable, so it moves
			to_chat(src, "<span class='info'>You push off of [dense_object_backup] to propel yourself.</span>")

		return 1
	return 0

/mob/proc/mob_has_gravity(turf/T)
	return has_gravity(src, T)

/mob/proc/mob_negates_gravity()
	return 0


/mob/proc/slip(weaken_duration, obj/slipped_on, lube)
	SEND_SIGNAL(src, COMSIG_MOB_SLIP, weaken_duration, slipped_on, lube)
	return TRUE

/mob/living/carbon/slip(weaken_duration, obj/slipped_on, lube)
	if(!loc.handle_slip(src, weaken_duration, slipped_on, lube))
		return FALSE

	return ..()

/mob/living/carbon/human/slip(weaken_duration, obj/slipped_on, lube)
	if(species.flags[NO_SLIP])
		return FALSE
	if(!(lube & GALOSHES_DONT_HELP))
		if((shoes && (shoes.flags & NOSLIP)) || (wear_suit && (wear_suit.flags & NOSLIP) || (get_species() == SKRELL && !shoes)))
			return FALSE
	return ..()


/mob/proc/update_gravity()
	return

/mob/proc/Move_Pulled(atom/A)
	if (!canmove || restrained() || !pulling)
		return

	if(SEND_SIGNAL(src, COMSIG_LIVING_MOVE_PULLED, A) & COMPONENT_PREVENT_MOVE_PULLED)
		return

	if (pulling.anchored)
		return
	if (!pulling.Adjacent(src))
		return
	if (A == loc && pulling.density)
		return
	if (!Process_Spacemove(get_dir(pulling.loc, A)))
		return
	if (ismob(pulling))
		var/mob/M = pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()
		step(pulling, get_dir(pulling.loc, A))
		if(M && t)
			M.start_pulling(t)
	else
		step(pulling, get_dir(pulling.loc, A))
	return


//bodypart selection verbs - Cyberboss
//8: repeated presses toggles through head - eyes - mouth
//9: eyes 8: head 7: mouth
//4: r-arm 5: chest 6: l-arm
//1: r-leg 2: groin 3: l-leg

///Validate the client's mob has a valid zone selected
/client/proc/check_has_body_select()
	return mob && mob.zone_sel && istype(mob.zone_sel, /atom/movable/screen/zone_sel)

/**
 * Hidden verb to set the target zone of a mob to the head
 *
 * (bound to 8) - repeated presses toggles through head - eyes - mouth
 */

///Hidden verb to target the head, bound to 8
/client/verb/body_toggle_head()
	set name = "body-toggle-head"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.get_targetzone())
		if(BP_HEAD)
			next_in_line = O_EYES
		if(O_EYES)
			next_in_line = O_MOUTH
		else
			next_in_line = BP_HEAD

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(next_in_line, mob)

///Hidden verb to target the eyes, bound to 7
/client/verb/body_eyes()
	set name = "body-eyes"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(O_EYES, mob)

///Hidden verb to target the mouth, bound to 9
/client/verb/body_mouth()
	set name = "body-mouth"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(O_MOUTH, mob)

///Hidden verb to target the right arm, bound to 4
/client/verb/body_r_arm()
	set name = "body-r-arm"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_R_ARM, mob)

///Hidden verb to target the chest, bound to 5
/client/verb/body_chest()
	set name = "body-chest"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_CHEST, mob)

///Hidden verb to target the left arm, bound to 6
/client/verb/body_l_arm()
	set name = "body-l-arm"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_L_ARM, mob)

///Hidden verb to target the right leg, bound to 1
/client/verb/body_r_leg()
	set name = "body-r-leg"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_R_LEG, mob)

///Hidden verb to target the groin, bound to 2
/client/verb/body_groin()
	set name = "body-groin"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_GROIN, mob)

///Hidden verb to target the left leg, bound to 3
/client/verb/body_l_leg()
	set name = "body-l-leg"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_L_LEG, mob)

// https://github.com/TauCetiStation/TauCetiClassic/issues/12899
// at this moment we need it only for clients, so it will not be called for clientless mobs
/mob/proc/update_z(new_z)
	last_z = new_z
	SEND_SIGNAL(src, COMSIG_MOB_Z_CHANGED, new_z)
