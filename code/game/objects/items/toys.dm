/* Toys!
 * ContainsL
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy swords
 *		Crayons
 *		Snap pops
 *		Water flower
 *		Plushies
 *		Arm Blade
 */


/obj/item/toy
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0

/*
 * Balloons
 */

/obj/item/toy/balloon/arrest
	name = "arreyst balloon"
	desc = "A half inflated balloon about a boyband named Arreyst that was popular about ten years ago, famous for making fun of red jumpsuits as unfashionable."
	icon = 'icons/obj/balloons.dmi'
	icon_state = "arrestballoon"
	item_state = "arrestballoon"
	lefthand_file = 'icons/mob/inhands/balloons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/balloons_righthand.dmi'

/obj/item/toy/balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	item_state = "balloon-empty"

/obj/item/toy/balloon/atom_init()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = src
	. = ..()

/obj/item/toy/balloon/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/toy/balloon/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if (istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(src,target) <= 1)
		target.reagents.trans_to(src, 10)
		to_chat(user, "<span class='notice'>You fill the balloon with the contents of [target].</span>")
		src.desc = "A translucent balloon with some form of liquid sloshing around in it."
		update_icon()
	return

/obj/item/toy/balloon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(I.reagents)
			if(I.reagents.total_volume < 1)
				to_chat(user, "The [I] is empty.")
			else if(I.reagents.total_volume >= 1)
				if(I.reagents.has_reagent("pacid", 1))
					to_chat(user, "The acid chews through the balloon!")
					I.reagents.reaction(user)
					qdel(src)
				else
					src.desc = "A translucent balloon with some form of liquid sloshing around in it."
					to_chat(user, "<span class='notice'>You fill the balloon with the contents of [I].</span>")
					I.reagents.trans_to(src, 10)
				update_icon()
			return

	return ..()

/obj/item/toy/balloon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	if(src.reagents.total_volume >= 1)
		visible_message("<span class='warning'>The [src] bursts!</span>","You hear a pop and a splash.")
		reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			reagents.reaction(A)
		src.icon_state = "burst"
		spawn(5)
			if(src)
				qdel(src)
	return

/obj/item/toy/balloon/update_icon()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "balloon"
	else
		icon_state = "waterballoon-e"
		item_state = "balloon-empty"

/obj/item/toy/syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = SIZE_NORMAL

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "Gravitational Singularity"
	desc = "A gravitational singularity."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s11"
	plane = SINGULARITY_PLANE
	layer = SINGULARITY_LAYER

	var/on = FALSE

	var/stage_of_effect = 1 //1 - clown card, 2 - emag
	var/atom/movable/singularity_effect/fake_singulo_effect
	var/atom/movable/singularity_swirl/fake_singulo_swirl
	var/atom/movable/singularity_lens/fake_singulo_lens

/obj/item/toy/spinningtoy/atom_init()

	add_filter("singa_ring", 1, bloom_filter(rgb(100,0,0), 2, 2, 255))

	animate(src, transform = turn(matrix(), -120), time = 5, loop = -1, flags = ANIMATION_PARALLEL)
	animate(transform = turn(matrix(), -240), time = 7, loop = -1)
	animate(transform = turn(matrix(), 0), time = 5, loop = -1)

	animate(get_filter("singa_ring"), size = 1, offset = 1, time = 5, loop = -1, easing = CIRCULAR_EASING, flags = ANIMATION_PARALLEL)
	animate(size = 2, offset = 2, time = 10, loop = -1, easing = CIRCULAR_EASING)

	. = ..()

/obj/item/toy/spinningtoy/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback)
	return

/obj/item/toy/spinningtoy/attack_hand(mob/user)
	turn_off()
	return ..()

/obj/item/toy/spinningtoy/verb/toggle()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle"

	try_toggle(usr)

/obj/item/toy/spinningtoy/AltClick(mob/user)
	try_toggle(user)

/obj/item/toy/spinningtoy/proc/try_toggle(mob/user)
	if(!user)
		return
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!isturf(loc)) // we dont want to allow user toggling it while it is in someone's inventory
		return
	if(!iscarbon(user) || isbrain(user))
		return

	if(on)
		turn_off()
		return
	else
		add_fingerprint(user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.job == "Clown" || stage_of_effect == 2)
				to_chat(user, "<span class = 'notice'>You concentrate your power into a one big bad joke and make the [src] much stronger.</span>")
				on = TRUE

	update_icon()

/obj/item/toy/spinningtoy/emag_act()
	if(stage_of_effect == 2)
		return FALSE
	to_chat(usr, "<span class = 'notice'>You upgrade the [src] in the faith of Lord Sindicatulo.</span>")
	stage_of_effect = 2
	update_icon()
	return TRUE

/obj/item/toy/spinningtoy/apply_outline(color)
	return

/obj/item/toy/spinningtoy/update_icon()

	if(!on)
		icon = 'icons/obj/singularity.dmi'
		icon_state = "singularity_s11"
		pixel_x = 0
		pixel_y = 0
		return

	if(!fake_singulo_lens)
		fake_singulo_lens = new(src)
		vis_contents += fake_singulo_lens

	if(!fake_singulo_swirl)
		fake_singulo_swirl = new(src)
		vis_contents += fake_singulo_swirl

	if(!fake_singulo_effect)
		fake_singulo_effect = new(src)
		vis_contents += fake_singulo_effect

	switch(stage_of_effect)
		if(1)
			icon = 'icons/effects/96x96.dmi'
			icon_state = "singularity_s3"
			pixel_x = -32
			pixel_y = -32
			fake_singulo_swirl.plane = SINGULARITY_EFFECT_PLANE_1
			fake_singulo_effect.plane = SINGULARITY_EFFECT_PLANE_2
			animate(fake_singulo_lens, transform = matrix().Scale(0.75), time = 25)
			fake_singulo_lens.pixel_x = -96
			fake_singulo_lens.pixel_y = -96
			animate(fake_singulo_swirl, transform = matrix().Scale(0.5), time = 25)
			fake_singulo_swirl.pixel_x = -96
			fake_singulo_swirl.pixel_y = -96
			animate(fake_singulo_effect, transform = matrix().Scale(0.19), time = 25)
			fake_singulo_effect.pixel_x = -96
			fake_singulo_effect.pixel_y = -96
		if(2)
			icon = 'icons/effects/160x160.dmi'
			icon_state = "singularity_s5"
			pixel_x = -64
			pixel_y = -64
			fake_singulo_swirl.plane = SINGULARITY_EFFECT_PLANE_2
			fake_singulo_effect.plane = SINGULARITY_EFFECT_PLANE_2
			animate(fake_singulo_lens, transform = matrix().Scale(1.25), time = 25)
			fake_singulo_lens.pixel_x = -64
			fake_singulo_lens.pixel_y = -64
			animate(fake_singulo_swirl, transform = matrix().Scale(0.75), time = 25)
			fake_singulo_swirl.pixel_x = -64
			fake_singulo_swirl.pixel_y = -64
			animate(fake_singulo_effect, transform = matrix().Scale(0.3), time = 25)
			fake_singulo_effect.pixel_x = -64
			fake_singulo_effect.pixel_y = -64

/obj/item/toy/spinningtoy/proc/turn_off()
	on = FALSE

	vis_contents -= fake_singulo_swirl
	QDEL_NULL(fake_singulo_swirl)
	vis_contents -= fake_singulo_effect
	QDEL_NULL(fake_singulo_effect)
	vis_contents -= fake_singulo_lens
	QDEL_NULL(fake_singulo_lens)

	update_icon()

/obj/item/toy/spinningtoy/Destroy()
	turn_off()
	return ..()

/*
 * Toy gun: Why isnt this an /obj/item/weapon/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_state = "revolver"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	can_be_holstered = TRUE
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_SMALL
	m_amt = 3250
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
	var/bullets = 7.0

/obj/item/toy/gun/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "<span class='notice'>There are [bullets] caps\s left.</span>")

/obj/item/toy/gun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/ammo/gun))
		var/obj/item/toy/ammo/gun/G = I
		if (src.bullets >= 7)
			to_chat(user, "<span class='notice'>It's already fully loaded!</span>")
			return 1
		if (G.amount_left <= 0)
			to_chat(user, "<span class='warning'>There is no more caps!</span>")
			return 1
		if (G.amount_left < (7 - src.bullets))
			src.bullets += G.amount_left
			to_chat(user, "<span class='warning'>You reload [G.amount_left] caps\s!</span>")
			G.amount_left = 0
		else
			to_chat(user, "<span class='warning'>You reload [7 - bullets] caps\s!</span>")
			G.amount_left -= 7 - bullets
			bullets = 7
		G.update_icon()
		return TRUE

	return ..()

/obj/item/toy/gun/afterattack(atom/target, mob/user, proximity, params)
	if (proximity)
		return
	add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("<span class='warning'>*click* *click*</span>", SHOWMSG_AUDIO)
		playsound(user, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
		return
	playsound(user, 'sound/weapons/guns/Gunshot.ogg', VOL_EFFECTS_MASTER)
	src.bullets--

	visible_message("<span class='warning'><B>[user] fires a cap gun at [target]!</B></span>", "<span class='warning'>You hear a gunshot</span>")

/obj/item/toy/gun/peacemaker
	name = "Colt SAA"
	desc = "A legend of Wild West."
	icon_state = "peacemaker"

/obj/item/toy/ammo/gun
	name = "ammo-caps"
	desc = "There are 7 caps left! Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo/magazines.dmi'
	icon_state = "357-7"
	flags = CONDUCT
	w_class = SIZE_MINUSCULE
	m_amt = 500
	var/amount_left = 7.0

/obj/item/toy/ammo/gun/update_icon()
	src.icon_state = text("357-[]", src.amount_left)
	src.desc = text("There are [] caps\s left! Make sure to recycle the box in an autolathe when it gets empty.", src.amount_left)
	return

/*
 * Toy crossbow
 */

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "Оружие, любимое многими гиперактивными детьми. Возрастной рейтинг 8+."
	icon = 'icons/obj/gun.dmi'
	icon_state = "crossbow"
	item_state = "crossbow"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	can_be_holstered = TRUE
	w_class = SIZE_TINY
	attack_verb = list("attacked", "struck", "hit")
	var/bullets = 5

/obj/item/toy/crossbow/examine(mob/user)
	..()
	if (bullets && (src in view(2, user)))
		to_chat(user, "<span class='notice'>It is loaded with [bullets] foam darts!</span>")

/obj/item/toy/crossbow/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/ammo/crossbow))
		if(bullets <= 4)
			qdel(I)
			bullets++
			to_chat(user, "<span class='notice'>You load the foam dart into the crossbow.</span>")
		else
			to_chat(usr, "<span class='warning'>It's already fully loaded.</span>")
	else
		return ..()

/obj/item/toy/crossbow/afterattack(atom/target, mob/user, proximity, params)
	if(!isturf(target.loc) || target == user) return
	if(proximity) return

	if (locate (/obj/structure/table, src.loc))
		return
	else if (bullets)
		var/turf/trg = get_turf(target)
		var/obj/effect/foam_dart_dummy/D = new/obj/effect/foam_dart_dummy(get_turf(src))
		bullets--
		D.icon_state = "foamdart"
		D.name = "foam dart"
		playsound(user, 'sound/items/syringeproj.ogg', VOL_EFFECTS_MASTER)

		for(var/i=0, i<6, i++)
			if (D)
				if(D.loc == trg) break
				step_towards(D,trg)

				for(var/mob/living/M in D.loc)
					if(!isliving(M)) continue
					if(M == user) continue
					visible_message("<span class='warning'>[M] was hit by the foam dart!</span>")
					new /obj/item/toy/ammo/crossbow(M.loc)
					qdel(D)
					return

				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density)
						new /obj/item/toy/ammo/crossbow(A.loc)
						qdel(D)

			sleep(1)

		spawn(10)
			if(D)
				new /obj/item/toy/ammo/crossbow(D.loc)
				qdel(D)

		return
	else if (bullets == 0)
		user.Weaken(5)
		visible_message("<span class='warning'>[user] realized they were out of ammo and starting scrounging for some!</span>")

/obj/item/toy/crossbow/attack(mob/M, mob/user)
	add_fingerprint(user)

// ******* Check

	if (src.bullets > 0 && M.lying)

		visible_message("<span class='warning'><B>[user] casually lines up a shot with [M]'s head and pulls the trigger!</B></span><br>\
			<span class='warning'>[M] was hit in the head by the foam dart!</span>", "<span class='warning'>You hear the sound of foam against skull</span>")

		playsound(user, 'sound/items/syringeproj.ogg', VOL_EFFECTS_MASTER)
		new /obj/item/toy/ammo/crossbow(M.loc)
		src.bullets--
	else if (M.lying && src.bullets == 0)
		visible_message("<span class='warning'><B>[user] casually lines up a shot with [M]'s head and pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!</B></span>", "<span class='warning'>You hear someone fall</span>")
		user.Weaken(5)
	return

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	w_class = SIZE_MINUSCULE

/obj/effect/foam_dart_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/toy.dmi'
	icon_state = "null"
	anchored = TRUE
	density = FALSE


/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sword0"
	item_state = "sword0"
	var/active = FALSE
	w_class = SIZE_TINY
	attack_verb = list("attacked", "struck", "hit")
	var/blade_color = "blue"

/obj/item/toy/sword/atom_init()
	. = ..()
	blade_color = pick("red", "blue", "green", "purple", "yellow", "pink", "black")
	switch(blade_color)
		if("red")
			light_color = COLOR_RED
		if("blue")
			light_color = COLOR_BLUE
		if("green")
			light_color = COLOR_GREEN
		if("purple")
			light_color = COLOR_PURPLE
		if("yellow")
			light_color = COLOR_YELLOW
		if("pink")
			light_color = COLOR_PINK
		if("black")
			light_color = COLOR_GRAY

	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list()

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE
	AddComponent(/datum/component/swiping, SCB)

/obj/item/toy/sword/attack_self(mob/user)
	active = !active
	if (active)
		to_chat(user, "<span class='notice'>You extend the plastic blade with a quick flick of your wrist.</span>")
		playsound(user, 'sound/weapons/saberon.ogg', VOL_EFFECTS_MASTER)
		icon_state = "sword[blade_color]"
		item_state = icon_state
		w_class = SIZE_NORMAL
		hitsound = list('sound/weapons/blade1.ogg')
		set_light(2)
	else
		to_chat(user, "<span class='notice'>You push the plastic blade back down into the handle.</span>")
		playsound(user, 'sound/weapons/saberoff.ogg', VOL_EFFECTS_MASTER)
		icon_state = "sword0"
		item_state = "sword0"
		w_class = SIZE_TINY
		hitsound = initial(hitsound)
		set_light(0)

	update_inv_mob()

	add_fingerprint(user)
	return

/obj/item/toy/sword/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/sword))
		to_chat(user, "<span class='notice'>You attach the ends of the two \
			toy energy swords, making a single double-bladed toy weapon! \
			You're cool.</span>")
		var/obj/item/toy/dualsword/newsword = new(user.loc)
		user.unEquip(I)
		user.unEquip(src)
		qdel(I)
		qdel(src)
		user.put_in_hands(newsword)

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	hitsound = list('sound/weapons/bladeslice.ogg')
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_BACK
	force = 5
	throwforce = 5
	w_class = SIZE_SMALL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")

/obj/item/toy/dualsword
	name = "double-bladed energy sword"
	desc = "Handle with care."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "dualsaber0"
	var/active = FALSE
	w_class = SIZE_TINY
	attack_verb = list("attacked", "struck", "hit")
	var/blade_color = "blue"
	sweep_step = 2
	var/wieldsound = 'sound/weapons/saberon.ogg'
	var/unwieldsound = 'sound/weapons/saberoff.ogg'
	var/hitsound_wielded = list('sound/weapons/blade1.ogg')

/obj/item/toy/dualsword/atom_init()
	. = ..()
	blade_color = pick("red", "blue", "green", "purple", "yellow", "pink", "black")
	switch(blade_color)
		if("red")
			light_color = COLOR_RED
		if("blue")
			light_color = COLOR_BLUE
		if("green")
			light_color = COLOR_GREEN
		if("purple")
			light_color = COLOR_PURPLE
		if("yellow")
			light_color = COLOR_YELLOW
		if("pink")
			light_color = COLOR_PINK
		if("black")
			light_color = COLOR_GRAY

	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list()

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	SCB.can_sweep_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/toy/dualsword, can_swipe))
	SCB.can_spin_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/toy/dualsword, can_swipe))
	SCB.on_get_sweep_objects = CALLBACK(src, TYPE_PROC_REF(/obj/item/toy/dualsword, get_sweep_objs))
	AddComponent(/datum/component/swiping, SCB)

	var/datum/twohanded_component_builder/TCB = new
	TCB.wieldsound = wieldsound
	TCB.unwieldsound = unwieldsound
	TCB.attacksound = hitsound_wielded
	TCB.on_wield = CALLBACK(src, PROC_REF(on_wield))
	TCB.on_unwield = CALLBACK(src, PROC_REF(on_unwield))
	AddComponent(/datum/component/twohanded, TCB)

/obj/item/toy/dualsword/proc/on_wield()
	set_light(2)
	w_class = SIZE_SMALL
	flags_2 |= CANT_BE_INSERTED
	return FALSE

/obj/item/toy/dualsword/proc/on_unwield()
	set_light(0)
	flags_2 &= ~CANT_BE_INSERTED
	w_class = initial(w_class)
	return FALSE

/obj/item/toy/dualsword/proc/can_swipe(mob/user)
	return HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED)

/obj/item/toy/dualsword/proc/get_sweep_objs(turf/start, obj/item/I, mob/user, list/directions, sweep_delay)
	var/list/directions_opposite = list()
	for(var/dir_ in directions)
		directions_opposite += turn(dir_, 180)

	var/list/sweep_objects = list()
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions, sweep_delay)
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions_opposite, sweep_delay)
	return sweep_objects

/obj/item/toy/dualsword/update_icon()
	if(HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED))
		icon_state = "dualsaber[blade_color]1"
	else
		icon_state = "dualsaber0"
	clean_blood()//blood overlays get weird otherwise, because the sprite changes.

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = SIZE_MINUSCULE

/obj/item/toy/snappop/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	new /obj/effect/decal/cleanable/ash(src.loc)
	visible_message("<span class='warning'>The [src.name] explodes!</span>","<span class='warning'>You hear a snap!</span>")
	playsound(src, 'sound/effects/snap.ogg', VOL_EFFECTS_MASTER)
	qdel(src)

/obj/item/toy/snappop/Crossed(atom/movable/AM)
	. = ..()
	if((ishuman(AM))) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/H = AM
		if(H.m_intent == "run")
			to_chat(H, "<span class='warning'>You step on the snap pop!</span>")

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 0, src)
			s.start()
			new /obj/effect/decal/cleanable/ash(src.loc)
			visible_message("<span class='warning'>The [src.name] explodes!</span>","<span class='warning'>You hear a snap!</span>")
			playsound(src, 'sound/effects/snap.ogg', VOL_EFFECTS_MASTER)
			qdel(src)

/*
 * Water flower
 */
/obj/item/toy/waterflower
	name = "Water Flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	var/empty = 0

/obj/item/toy/waterflower/atom_init()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = src
	R.add_reagent("water", 10)
	. = ..()

/obj/item/toy/waterflower/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/toy/waterflower/afterattack(atom/target, mob/user, proximity, params)
	if(locate(/obj/structure/table, loc))
		return

	else if(istype(target, /obj/structure/reagent_dispensers/watertank) && proximity)
		target.reagents.trans_to(src, 10)
		to_chat(user, "<span class='notice'>You refill your flower!</span>")
		return

	else if(src.reagents.total_volume < 1)
		src.empty = 1
		to_chat(user, "<span class='notice'>Your flower has run dry!</span>")
		return

	else
		src.empty = 0


		var/obj/effect/decal/D = new/obj/effect/decal(get_turf(src))
		D.name = "water"
		D.icon = 'icons/obj/chemical.dmi'
		D.icon_state = "chempuff"
		D.create_reagents(5)
		reagents.trans_to(D, 1)
		playsound(src, 'sound/effects/spray3.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -6)

		spawn(0)
			for(var/i=0, i<1, i++)
				step_towards(D,target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/T in get_turf(D))
					D.reagents.reaction(T)
					if(ismob(T) && T:client)
						to_chat(T:client, "<span class='warning'>[user] has sprayed you with water!</span>")
					if(ishuman(T))
						var/mob/living/carbon/human/H = T
						var/list/inv_contents = list()
						for(var/obj/item/I in H.contents)
							if(I == src) continue
							if(istype(I, /obj/item/weapon/implant)) continue
							inv_contents += I
						if(inv_contents.len)
							for(var/n=3,n>0,n--)
								var/obj/item/I = pick(inv_contents)
								I.make_wet()
				sleep(4)
			qdel(D)

		return

/obj/item/toy/waterflower/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "[reagents.total_volume] unit\s of water left!")


/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	w_class = SIZE_TINY
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user)
	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You play with [src].</span>")
		playsound(user, 'sound/mecha/mechstep.ogg', VOL_EFFECTS_MASTER, 20)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, "<span class='notice'>You play with [src].</span>")
			playsound(user, 'sound/mecha/mechturn.ogg', VOL_EFFECTS_MASTER, 20)
			cooldown = world.time
			return
	..()

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"


/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_BACK
	force = 5
	throwforce = 5
	w_class = SIZE_SMALL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")

/* NYET.
/obj/item/weapon/toddler
	icon_state = "toddler"
	name = "toddler"
	desc = "This baby looks almost real. Wait, did it just burp?"
	force = 5
	w_class = SIZE_NORMAL
	slot_flags = SLOT_FLAGS_BACK
*/

//This should really be somewhere else but I don't know where. w/e
/obj/item/weapon/inflatable_duck
	name = "inflatable duck"
	desc = "No bother to sink or swim when you can just float!"
	icon_state = "inflatable"
	item_state = "inflatable"
	icon = 'icons/obj/clothing/belts.dmi'
	slot_flags = SLOT_FLAGS_BELT

/*
 * Action Figures
 */

/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = null
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	w_class = SIZE_TINY
	var/cooldown = 0
	var/toysay = "What the fuck did you do?"

/obj/item/toy/figure/atom_init()
	. = ..()
	desc = "A \"Space Life\" brand [src]."

/obj/item/toy/figure/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = world.time + 50
		to_chat(user, "<span class='notice'>The [src] says \"[toysay]\"</span>")
		playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 20)

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	icon_state = "assistant"
	toysay = "Grey tide world wide!"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	icon_state = "atmos"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	icon_state = "bartender"
	toysay = "Where is Pun Pun?"

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."

/obj/item/toy/figure/botanist
	name = "Botanist action figure"
	icon_state = "botanist"
	toysay = "Dude, I see colors..."

/obj/item/toy/figure/captain
	name = "Captain action figure"
	icon_state = "captain"
	toysay = "Any heads of staff?"

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	icon_state = "chaplain"
	toysay = "Praise Space Jesus!"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	icon_state = "chef"
	toysay = "Pun-Pun is a tasty burger."

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	icon_state = "chemist"
	toysay = "Get your pills!"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	icon_state = "clown"
	toysay = "Honk!"

/obj/item/toy/figure/ian
	name = "Ian action figure"
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/dsquad
	name = "Death Squad Officer action figure"
	icon_state = "dsquad"
	toysay = "Eliminate all threats!"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	icon_state = "engineer"
	toysay = "Oh god, the singularity is loose!"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	icon_state = "geneticist"
	toysay = "Smash!"

/obj/item/toy/figure/hop
	name = "Head of Personel action figure"
	icon_state = "hop"
	toysay = "Giving out all access!"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	icon_state = "hos"
	toysay = "Get the justice chamber ready, I think we got a joker here."

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	icon_state = "qm"
	toysay = "Please sign this form in triplicate and we will see about geting you a welding mask within 3 business days."

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."

/obj/item/toy/figure/lawyer
	name = "Lawyer action figure"
	icon_state = "lawyer"
	toysay = "My client is a dirty traitor!"

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	icon_state = "librarian"
	toysay = "One day while..."

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	icon_state = "md"
	toysay = "The patient is already dead!"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	icon_state = "mime"
	toysay = "..."

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	icon_state = "miner"
	toysay = "Oh god it's eating my intestines!"

/obj/item/toy/figure/ninja
	name = "Ninja action figure"
	icon_state = "ninja"
	toysay = "Oh god! Stop shooting, I'm friendly!"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	icon_state = "wizard"
	toysay = "Ei Nath!"

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	icon_state = "rd"
	toysay = "Blowing all of the borgs!"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	icon_state = "roboticist"
	toysay = "Big stompy mechs!"

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	icon_state = "scientist"
	toysay = "For science!"

/obj/item/toy/figure/syndie
	name = "Nuclear Operative action figure"
	icon_state = "syndie"
	toysay = "Get that fucking disk!"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	icon_state = "secofficer"
	toysay = "I am the law!"

/obj/item/toy/figure/virologist
	name = "Virologist action figure"
	icon_state = "virologist"
	toysay = "The cure is potassium!"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	icon_state = "warden"
	toysay = "Seventeen minutes for coughing at an officer!"

/obj/item/toy/figure/iaa
	name = "Internal Affairs Agent action figure"
	icon_state = "iaa"
	toysay = "I'll make a report!"

/obj/item/toy/figure/blueofficer
	name = "Blueshield Officer"
	icon_state = "blueofficer"
	toysay = "On guard of the heads!"

/obj/item/toy/figure/xenobio
	name = "Xenobiologist"
	icon_state = "xenobio"
	toysay = "Ghost, come here, there's a rune for summoning a admantive golem!"

/obj/item/toy/figure/xenoarcheolog
	name = "Xenoarcheologist"
	icon_state = "xenoarcheolog"
	toysay = "Excavation, excavation, death!"
/*
Owl & Griffin toys
*/
/obj/item/toy/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon = 'icons/obj/toy.dmi'
	icon_state = "owlprize"
	w_class = SIZE_TINY
	var/cooldown = 0

/obj/item/toy/owl/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You won't get away this time, Griffin!", "Stop right there, criminal!", "Hoot! Hoot!", "I am the night!")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 20)
		loc.visible_message("<span class='danger'>[bicon(src)] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon = 'icons/obj/toy.dmi'
	icon_state = "griffinprize"
	w_class = SIZE_TINY
	var/cooldown = 0

/obj/item/toy/griffin/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You can't stop me, Owl!", "My plan is flawless! The vault is mine!", "Caaaawwww!", "You will never catch me!")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 20)
		loc.visible_message("<span class='danger'>[bicon(src)] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/*
 * Fake nuke
 */
/obj/item/toy/nuke
	name = "Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	w_class = SIZE_TINY
	var/cooldown = 0
	var/emagged = FALSE

/obj/item/toy/nuke/attack_self(mob/user)
	if(cooldown > world.time)
		var/timeleft = (cooldown - world.time)
		to_chat(user, "<span class='alert'>Nothing happens, and '</span>[round(timeleft/10)]<span class='alert'>' appears on a small display.</span>")
		return
	cooldown = world.time + 3 MINUTES
	user.visible_message("<span class='warning'>[user] presses a button on [src].</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>", "<span class='italics'>You hear the click of a button.</span>")
	icon_state = "nuketoy"
	addtimer(CALLBACK(src, PROC_REF(alarm)), 5, TIMER_STOPPABLE)

/obj/item/toy/nuke/proc/alarm() //first timer
	playsound(src, 'sound/machines/Alarm.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	addtimer(CALLBACK(src, PROC_REF(boom)), 115, TIMER_STOPPABLE)

/obj/item/toy/nuke/proc/boom() //second timer
	if(emagged)
		visible_message("<span class='warning'>[pick("GOT DAT FUKKEN DISK" , "KA-BEEEM" , "WHAT MAKE'S ME A GOOD NUKER?")]</span>")
		visible_message("[src] violently explodes!")
		var/turf/T = get_turf(loc)
		if(T)
			T.hotspot_expose(700,125)
			explosion(T, 0, 0, 2, rand(1,2))
		qdel(src)
		return
	icon_state = "nuketoycool"
	VARSET_IN(src, icon_state, "nuketoyidle", cooldown - world.time)

/obj/item/toy/nuke/emag_act(mob/user)
	if(emagged)
		return
	to_chat(user, "<span class='alert'>You short-circuit \the [src].</span>")
	emagged = TRUE
/*
 * Fake meteor
 */
/obj/item/toy/minimeteor
	name = "Mini-Meteor"
	desc = "Relive the excitement of a meteor shower! SweetMeat-eor. Co is not responsible for any injuries, headaches or hearing loss caused by Mini-Meteor?"
	icon = 'icons/obj/toy.dmi'
	icon_state = "minimeteor"
	w_class = SIZE_TINY

/obj/item/toy/minimeteor/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return

	playsound(src, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER)
	for(var/mob/M in orange(10, src))
		if(M.stat == CONSCIOUS && !isAI(M))\
			shake_camera(M, 3, 1)
	qdel(src)

/*
 * A Deck of Cards
 */

/obj/item/toy/cards
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/cards.dmi'
	icon_state = "deck"
	w_class = SIZE_TINY
	var/list/cards = list()
	var/normal_deck_size = 52 // How many cards should be in the full deck.
	var/list/integrity = list() // Is populated in atom_init(), determines which cards SHOULD be in the full deck.


/obj/item/toy/cards/update_icon() // Some foreshadowing here.
	if(cards.len > normal_deck_size/2)
		icon_state = "[initial(icon_state)]_full"
	else if(cards.len > normal_deck_size/4)
		icon_state = "[initial(icon_state)]_half"
	else if(cards.len >= 1)
		icon_state = "[initial(icon_state)]_low"
	else if(cards.len == 0)
		icon_state = "[initial(icon_state)]_empty"

/obj/item/toy/cards/proc/fill_deck(from_c, to_c) // Made, so we can fill from 6 to 10 instead of 2 to 10.
	for(var/i in from_c to to_c)
		cards += "[i] of Hearts"
		cards += "[i] of Spades"
		cards += "[i] of Clubs"
		cards += "[i] of Diamonds"
	cards += "King of Hearts"
	cards += "King of Spades"
	cards += "King of Clubs"
	cards += "King of Diamonds"
	cards += "Queen of Hearts"
	cards += "Queen of Spades"
	cards += "Queen of Clubs"
	cards += "Queen of Diamonds"
	cards += "Jack of Hearts"
	cards += "Jack of Spades"
	cards += "Jack of Clubs"
	cards += "Jack of Diamonds"
	cards += "Ace of Hearts"
	cards += "Ace of Spades"
	cards += "Ace of Clubs"
	cards += "Ace of Diamonds"
	update_icon()

/obj/item/toy/cards/atom_init()
	. = ..()
	fill_deck(2, 10)
	integrity += cards

/obj/item/toy/cards/attack_hand(mob/user)
	if(cards.len == 0)
		to_chat(user, "<span class='notice'>There are no more cards to draw.</span>")
		return
	var/obj/item/toy/singlecard/H = remove_card()
	H.pickup(user)
	user.put_in_active_hand(H)
	user.visible_message("<span class='notice'>[user] draws a card from the deck.</span>", "<span class='notice'>You draw a card from the deck.</span>")
	update_icon()

/obj/item/toy/cards/proc/remove_card()
	var/obj/item/toy/singlecard/H = new/obj/item/toy/singlecard(loc)
	var/choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	cards -= choice
	return H

/obj/item/toy/cards/attack_self(mob/user)
	cards = shuffle(cards)
	user.SetNextMove(CLICK_CD_INTERACT)
	playsound(user, 'sound/items/cardshuffle.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='notice'>[user] shuffles the deck.</span>", "<span class='notice'>You shuffle the deck.</span>")

/obj/item/toy/cards/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/C = I
		if(C.parentdeck == src)
			src.cards += C.cardname
			user.visible_message("<span class='notice'>[user] adds a card to the bottom of the deck.</span>","<span class='notice'>You add the card to the bottom of the deck.</span>")
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
		update_icon()

	else if(istype(I, /obj/item/toy/cardhand))
		var/obj/item/toy/cardhand/C = I
		if(C.parentdeck == src)
			src.cards += C.currenthand
			user.visible_message("<span class='notice'>[user] puts their hand of cards in the deck.</span>", "<span class='notice'>You put the hand of cards in the deck.</span>")
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
		update_icon()

	else
		return ..()

/obj/item/toy/cards/MouseDrop(atom/over_object)
	. = ..()
	var/mob/M = usr
	if(over_object == M && iscarbon(usr) && !usr.incapacitated())
		if(Adjacent(usr))
			M.put_in_hands(src)
		else
			to_chat(usr, "<span class='notice'>You can't reach it from here.</span>")

	if(M.l_hand == src || M.r_hand == src)
		to_chat(usr, "<span class='notice'>You pick up the deck.</span>")

/obj/item/toy/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/cards.dmi'
	icon_state = "hand2"
	w_class = SIZE_MINUSCULE
	var/list/currenthand = list()
	var/obj/item/toy/cards/parentdeck = null
	var/choice = null


/obj/item/toy/cardhand/attack_self(mob/user)
	user.set_machine(src)
	interact(user)

/obj/item/toy/cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='byond://?src=\ref[src];pick=[t]'>A [t]</a><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_content(dat)
	popup.open()


/obj/item/toy/cardhand/Topic(href, href_list)
	if(..())
		return
	if(!ishuman(usr) || usr.incapacitated())
		return
	var/mob/living/carbon/human/cardUser = usr
	if(href_list["pick"])
		if (cardUser.get_item_by_slot(SLOT_L_HAND) == src || cardUser.get_item_by_slot(SLOT_R_HAND) == src)
			var/choice = href_list["pick"]
			var/obj/item/toy/singlecard/C = new/obj/item/toy/singlecard(cardUser.loc)
			src.currenthand -= choice
			C.parentdeck = src.parentdeck
			C.cardname = choice
			C.pickup(cardUser)
			cardUser.put_in_any_hand_if_possible(C)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from \his hand.</span>", "<span class='notice'>You take the [C.cardname] from your hand.</span>")

			interact(cardUser)

			if(src.currenthand.len < 3)
				src.icon_state = "hand2"
			else if(src.currenthand.len < 4)
				src.icon_state = "hand3"
			else if(src.currenthand.len < 5)
				src.icon_state = "hand4"

			if(src.currenthand.len == 1)
				var/obj/item/toy/singlecard/N = new/obj/item/toy/singlecard(src.loc)
				N.parentdeck = src.parentdeck
				N.cardname = src.currenthand[1]
				cardUser.remove_from_mob(src)
				N.pickup(cardUser)
				cardUser.put_in_any_hand_if_possible(N)
				to_chat(cardUser, "<span class='notice'>You also take [currenthand[1]] and hold it.</span>")
				cardUser << browse(null, "window=cardhand")
				qdel(src)
		return

/obj/item/toy/cardhand/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			src.currenthand += C.cardname
			user.visible_message("<span class='notice'>[user] adds a card to their hand.</span>", "<span class='notice'>You add the [C.cardname] to your hand.</span>")
			interact(user)
			if(currenthand.len > 4)
				src.icon_state = "hand5"
			else if(currenthand.len > 3)
				src.icon_state = "hand4"
			else if(currenthand.len > 2)
				src.icon_state = "hand3"
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
	else
		return ..()



/obj/item/toy/singlecard
	name = "card"
	desc = "A card."
	icon = 'icons/obj/cards.dmi'
	icon_state = "singlecard_down"
	w_class = SIZE_MINUSCULE
	var/cardname = null
	var/obj/item/toy/cards/parentdeck = null
	var/flipped = 0
	pixel_x = -5

/obj/item/toy/singlecard/examine(mob/user)
	..()
	if((src in user) && ishuman(user))
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.get_item_by_slot(SLOT_L_HAND) == src || cardUser.get_item_by_slot(SLOT_R_HAND) == src)
			cardUser.visible_message("<span class='notice'>[cardUser] checks \his card.</span>", "<span class='notice'>The card reads: [src.cardname]</span>")
		else
			to_chat(cardUser, "<span class='notice'>You need to have the card in your hand to check it.</span>")


/obj/item/toy/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(!ishuman(usr) || usr.incapacitated())
		return
	if(!flipped)
		src.flipped = 1
		if (cardname)
			src.icon_state = "sc_[cardname]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades"
			src.name = "What Card"
		src.pixel_x = 5
	else if(flipped)
		src.flipped = 0
		src.icon_state = "singlecard_down"
		src.name = "card"
		src.pixel_x = -5

/obj/item/toy/singlecard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			var/obj/item/toy/cardhand/H = new/obj/item/toy/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += src.cardname
			H.parentdeck = C.parentdeck
			user.remove_from_mob(C)
			H.pickup(user)
			user.put_in_active_hand(H)
			to_chat(user, "<span class='notice'>You combine the [C.cardname] and the [src.cardname] into a hand.</span>")
			qdel(C)
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")

	else if(istype(I, /obj/item/toy/cardhand))
		var/obj/item/toy/cardhand/H = I
		if(H.parentdeck == parentdeck)
			H.currenthand += cardname
			user.remove_from_mob(src)
			user.visible_message("<span class='notice'>[user] adds a card to \his hand.</span>", "<span class='notice'>You add the [cardname] to your hand.</span>")
			H.interact(user)
			if(H.currenthand.len > 4)
				H.icon_state = "hand5"
			else if(H.currenthand.len > 3)
				H.icon_state = "hand4"
			else if(H.currenthand.len > 2)
				H.icon_state = "hand3"
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")

	else
		return ..()

/obj/item/toy/singlecard/attack_self(mob/user)
	if(!ishuman(usr) || usr.incapacitated())
		return
	Flip()

/obj/item/toy/singlecard/AltClick(mob/user)
	if(!ishuman(usr) || usr.incapacitated())
		return
	Flip()

/*
 * Casino Caps
 */
/obj/item/toy/caps
	name = "caps"
	desc = "Маленькие разноцветные фишки."

	icon = 'icons/obj/casino.dmi'
	icon_state = "caps_2"

	w_class = SIZE_MIDGET

	var/capsAmount = 1

/obj/item/toy/caps/atom_init(mapload, capsAmount = 1)
	. = ..()

	if(capsAmount <= 0)
		capsAmount = 1
	src.capsAmount = capsAmount
	update_icon()

/obj/item/toy/caps/update_icon()
	switch(capsAmount)
		if(1)
			icon_state = "caps_1_[pick(list("r", "g", "y", "b"))]"
		if(2 to 9)
			icon_state = "caps_2"
			w_class = SIZE_MINUSCULE
		if(10 to 25)
			icon_state = "caps_3"
			w_class = SIZE_TINY
		if(25 to 99)
			icon_state = "caps_4"
			w_class = SIZE_TINY
		if(100 to 249)
			icon_state = "caps_5"
			w_class = SIZE_SMALL
		else
			icon_state = "caps_6"
			w_class = SIZE_SMALL

/obj/item/toy/caps/examine(mob/user)
	..()
	to_chat(user, "Фишек в стопке: [capsAmount].")

/obj/item/toy/caps/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/caps))
		var/obj/item/toy/caps/Caps = I

		capsAmount += Caps.capsAmount
		qdel(Caps)
		update_icon()

/obj/item/toy/caps/attack_hand(mob/user)
	if(capsAmount == 1)
		user.put_in_active_hand(src)
		return

	var/static/icon/radial_icons = 'icons/hud/radial.dmi'
	var/static/radial_pickAll = image(icon = radial_icons, icon_state = "radial_pickup")
	var/static/radial_pickFew = image(icon = radial_icons, icon_state = "radial_split")
	var/list/options = list()

	options["Взять всё"] = radial_pickAll
	options["Взять часть"] = radial_pickFew

	var/choice = show_radial_menu(user, src, options, require_near = TRUE, tooltips = TRUE)

	if(choice == "Взять всё")
		user.put_in_active_hand(src)
		return

	var/pickupAmount = text2num(input(user, "Сколько фишек взять?", "1") as text)
	if(pickupAmount <= 0 || pickupAmount > capsAmount)
		return

	var/obj/item/toy/caps/Caps = new(get_turf(src), pickupAmount)
	Caps.pickup(user)
	user.put_in_active_hand(Caps)

	user.visible_message("<span class='notice'>[user] берёт [pickupAmount] [pluralize_russian(pickupAmount, "фишку", "фишки", "фишек")] из стопки.</span>", "<span class='notice'>Вы берёте [pickupAmount] [pluralize_russian(pickupAmount, "фишку", "фишки", "фишек")] из стопки.</span>")

	if(pickupAmount == capsAmount)
		qdel(src)
		return

	capsAmount -= pickupAmount
	update_icon()

/obj/item/toy/caps/MouseDrop(atom/over_object)
	. = ..()
	var/mob/M = usr
	if(over_object == M && iscarbon(usr) && !usr.incapacitated())
		if(Adjacent(usr))
			M.put_in_hands(src)
		else
			to_chat(usr, "<span class='notice'>Вы не можете дотянуться.</span>")

	if(M.l_hand == src || M.r_hand == src)
		to_chat(usr, "<span class='notice'>Вы берёте [capsAmount] [pluralize_russian(capsAmount, "фишку", "фишки", "фишек")].</span>")


/*
 * Poly prizes
 */
/obj/item/toy/prize/poly
	icon_state = "poly_classic"

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/poly/attack_self(mob/user)
	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You play with [src].</span>")
		cooldown = world.time

/obj/item/toy/prize/poly/attack_hand(mob/user)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, "<span class='notice'>You play with [src].</span>")
			cooldown = world.time
			return
	..()

/obj/item/toy/prize/poly/polyclassic
	name = "toy classic Poly"
	desc = "Mini-Borg action figure! Limited edition! 1/11. First in collection. First Poly."

/obj/item/toy/prize/poly/polypink
	name = "toy pink Poly"
	desc = "Mini-Borg action figure! Limited edition! 2/11. Parties. Are. Serious!"
	icon_state = "poly_pink"

/obj/item/toy/prize/poly/polydark
	name = "toy dark Poly"
	desc = "Mini-Borg action figure! Limited edition! 3/11. Dangerously."
	icon_state = "poly_dark"

/obj/item/toy/prize/poly/polywhite
	name = "toy white Poly"
	desc = "Mini-Borg action figure! Limited edition! 4/11. Don't throw at snow."
	icon_state = "poly_white"


/obj/item/toy/prize/poly/polyalien
	name = "toy alien Poly"
	desc = "Mini-Borg action figure! Limited edition! 5/11. ...Huh?"
	icon_state = "poly_alien"

/obj/item/toy/prize/poly/polyjungle
	name = "toy jungle Poly"
	desc = "Mini-Borg action figure! Limited edition! 6/11. Commencing operation Snake Eater."
	icon_state = "poly_jungle"

/obj/item/toy/prize/poly/polyfury
	name = "toy fury Poly"
	desc = "Mini-Borg action figure! Limited edition! 7/11. Behold the flames of fury, the fires in hell shall purge me clean!"
	icon_state = "poly_fury"

/obj/item/toy/prize/poly/polysky
	name = "toy sky Poly"
	desc = "Mini-Borg action figure! Limited edition! 8/11. A little bit of blue sky in a dark space."
	icon_state = "poly_sky"

/obj/item/toy/prize/poly/polysec
	name = "toy security Poly"
	desc = "Mini-Borg action figure! Limited edition! 9/11. Good old security Poly."
	icon_state = "poly_sec"

/obj/item/toy/prize/poly/polycompanion
	name = "toy companion Poly"
	desc = "Mini-Borg action figure! Limited edition! 10/11. He's loves you."
	icon_state = "poly_companion"

/obj/item/toy/prize/poly/polycompanion/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You have clicked a switch behind the toy.</span>")
	src.icon_state = "poly_companion" + pick("1","2","")
	update_inv_mob()

/obj/item/toy/prize/poly/polygold
	name = "golden Poly"
	desc = "Mini-Borg action figure! Limited edition! 11/11. Fully from gold and platinum."
	icon_state = "poly_gold"

/obj/item/toy/prize/poly/polyspecial
	name = "toy special Poly"
	desc = "Mini-Borg action figure! Limited edition! 11/11. Fully from gold and platinum."
	icon_state = "poly_special"

/obj/item/toy/prize/poly/polyspecial/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You have clicked a switch behind the toy.</span>")
	src.icon_state = "poly_special" + pick("1","2","")
	update_inv_mob()

/*
 * Carp plushie
 */

/obj/item/toy/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	item_state = "carp_plushie"
	attack_verb = list("bitten", "eaten", "fin slapped")
	var/bitesound = 'sound/weapons/bite.ogg'
	var/next_hug = 0

/obj/item/toy/carpplushie/atom_init()
	. = ..()
	icon_state = pick("carpplushie", "icecarp", "silentcarp", "electriccarp", "goldcarp", "toxincarp", "dragoncarp", "dragoncarp", "pinkcarp", "candycarp", "nebulacarp", "voidcarp")

/obj/item/toy/carpplushie/attack(mob/M, mob/user)
	. = ..()
	playsound(src, bitesound, VOL_EFFECTS_MASTER, 20)

/obj/item/toy/carpplushie/attack_self(mob/user)
	if(next_hug < world.time)
		playsound(src, bitesound, VOL_EFFECTS_MASTER, 20)
		to_chat(user, "<span class='notice'>You pet [src]. D'awww.</span>")
		next_hug = world.time + 8

/*
 * Plushie
 */

/obj/item/toy/plushie
	name = "plushie"
	desc = "An adorable, soft, and cuddly plushie."
	icon = 'icons/obj/toy.dmi'
	var/poof_sound = 'sound/weapons/thudswoosh.ogg'
	attack_verb = list("poofed", "bopped", "whapped", "cuddled", "fluffed")
	var/next_hug = 0
	var/list/cuddle_verbs = list("hugs", "cuddles", "snugs")

/obj/item/toy/plushie/attack(mob/M, mob/user)
	. = ..()
	playsound(src, poof_sound, VOL_EFFECTS_MASTER, 20) // Play the whoosh sound in local area

/obj/item/toy/plushie/attack_self(mob/user)
	if(next_hug < world.time)
		next_hug = world.time + 8
		var/cuddle_verb = pick(cuddle_verbs)
		user.visible_message("<span class='notice'>[user] [cuddle_verb] the [src].</span>")
		playsound(src, poof_sound, VOL_EFFECTS_MASTER)

/obj/random/plushie
	name = "plushie"
	desc = "This is a random plushie"
	icon = 'icons/obj/toy.dmi'
	icon_state = "redfox"

/obj/random/plushie/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/plushie)) // exclude the base type.

/obj/item/toy/plushie/corgi // dogs are basically the best
	name = "corgi plushie"
	icon_state = "corgi"

/obj/item/toy/plushie/space_whale
	name = "space whale"
	icon_state = "tau_kit"

/obj/item/toy/plushie/girly_corgi
	name = "corgi plushie"
	icon_state = "girlycorgi"

/obj/item/toy/plushie/robo_corgi
	name = "borgi plushie"
	icon_state = "robotcorgi"

/obj/item/toy/plushie/octopus
	name = "octopus plushie"
	icon_state = "loveable"

/obj/item/toy/plushie/face_hugger
	name = "facehugger plushie"
	icon_state = "huggable"

/obj/item/toy/plushie/red_fox
	name = "red fox plushie"
	icon_state = "redfox"

/obj/item/toy/plushie/black_fox
	name = "black fox plushie"
	icon_state = "blackfox"

/obj/item/toy/plushie/marble_fox
	name = "marble fox plushie"
	icon_state = "marblefox"

/obj/item/toy/plushie/blue_fox
	name = "blue fox plushie"
	icon_state = "bluefox"

/obj/item/toy/plushie/orange_fox
	name = "orange fox plushie"
	icon_state = "orangefox"

/obj/item/toy/plushie/coffee_fox
	name = "coffee fox plushie"
	icon_state = "coffeefox"

/obj/item/toy/plushie/pink_fox
	name = "pink fox plushie"
	icon_state = "pinkfox"

/obj/item/toy/plushie/purple_fox
	name = "purple fox plushie"
	icon_state = "purplefox"

/obj/item/toy/plushie/crimson_fox
	name = "crimson fox plushie"
	icon_state = "crimsonfox"

/obj/item/toy/plushie/deer
	name = "deer plushie"
	icon_state = "deer"

/obj/item/toy/plushie/black_cat
	name = "black cat plushie"
	icon_state = "blackcat"

/obj/item/toy/plushie/grey_cat
	name = "grey cat plushie"
	icon_state = "greycat"

/obj/item/toy/plushie/white_cat
	name = "white cat plushie"
	icon_state = "whitecat"

/obj/item/toy/plushie/orange_cat
	name = "orange cat plushie"
	icon_state = "orangecat"

/obj/item/toy/plushie/siamese_cat
	name = "siamese cat plushie"
	icon_state = "siamesecat"

/obj/item/toy/plushie/tabby_cat
	name = "tabby cat plushie"
	icon_state = "tabbycat"

/obj/item/toy/plushie/tuxedo_cat
	name = "tuxedo cat plushie"
	icon_state = "tuxedocat"

//////////////////////////////////////////////////////
//				Random figures						//
//////////////////////////////////////////////////////

/obj/random/randomfigure
	name = "action figure"
	desc = "This is a random figure"
	icon = 'icons/obj/toy.dmi'
	icon_state = "random_toy"

/obj/random/randomfigure/item_to_spawn()
	var/list/figures = list(	/obj/item/toy/prize/ripley						= 1,
							/obj/item/toy/prize/fireripley					= 1,
							/obj/item/toy/prize/deathripley					= 1,
							/obj/item/toy/prize/gygax						= 1,
							/obj/item/toy/prize/durand						= 1,
							/obj/item/toy/prize/honk						= 1,
							/obj/item/toy/prize/marauder					= 1,
							/obj/item/toy/prize/seraph						= 1,
							/obj/item/toy/prize/mauler						= 1,
							/obj/item/toy/prize/odysseus					= 1,
							/obj/item/toy/prize/phazon						= 1,
							/obj/item/toy/waterflower						= 1,
							/obj/item/toy/nuke								= 1,
							/obj/item/toy/minimeteor						= 2,
							/obj/item/toy/carpplushie						= 2,
							/obj/item/toy/owl								= 2,
							/obj/item/toy/griffin							= 2,
							/obj/item/toy/figure/cmo						= 1,
							/obj/item/toy/figure/assistant					= 1,
							/obj/item/toy/figure/atmos						= 1,
							/obj/item/toy/figure/bartender					= 1,
							/obj/item/toy/figure/borg						= 1,
							/obj/item/toy/figure/botanist					= 1,
							/obj/item/toy/figure/captain					= 1,
							/obj/item/toy/figure/cargotech					= 1,
							/obj/item/toy/figure/ce							= 1,
							/obj/item/toy/figure/chaplain					= 1,
							/obj/item/toy/figure/chef						= 1,
							/obj/item/toy/figure/chemist					= 1,
							/obj/item/toy/figure/clown						= 1,
							/obj/item/toy/figure/ian						= 1,
							/obj/item/toy/figure/detective					= 1,
							/obj/item/toy/figure/dsquad						= 1,
							/obj/item/toy/figure/engineer					= 1,
							/obj/item/toy/figure/geneticist					= 1,
							/obj/item/toy/figure/hop						= 1,
							/obj/item/toy/figure/hos						= 1,
							/obj/item/toy/figure/qm							= 1,
							/obj/item/toy/figure/janitor					= 1,
							/obj/item/toy/figure/lawyer						= 1,
							/obj/item/toy/figure/librarian					= 1,
							/obj/item/toy/figure/md							= 1,
							/obj/item/toy/figure/mime						= 1,
							/obj/item/toy/figure/ninja						= 1,
							/obj/item/toy/figure/wizard						= 1,
							/obj/item/toy/figure/rd							= 1,
							/obj/item/toy/figure/roboticist					= 1,
							/obj/item/toy/figure/scientist					= 1,
							/obj/item/toy/figure/syndie						= 1,
							/obj/item/toy/figure/secofficer					= 1,
							/obj/item/toy/figure/virologist					= 1,
							/obj/item/toy/figure/warden						= 1,
							/obj/item/toy/figure/iaa						= 1,
							/obj/item/toy/figure/blueofficer				= 1,
							/obj/item/toy/figure/xenobio					= 1,
							/obj/item/toy/figure/xenoarcheolog				= 1,
							/obj/item/toy/prize/poly/polyclassic			= 1,
							/obj/item/toy/prize/poly/polypink				= 1,
							/obj/item/toy/prize/poly/polydark				= 1,
							/obj/item/toy/prize/poly/polywhite				= 1,
							/obj/item/toy/prize/poly/polyalien				= 1,
							/obj/item/toy/prize/poly/polyjungle				= 1,
							/obj/item/toy/prize/poly/polyfury				= 1,
							/obj/item/toy/prize/poly/polysky				= 1,
							/obj/item/toy/prize/poly/polysec				= 1,
							/obj/item/toy/prize/poly/polycompanion			= 1,
							/obj/item/toy/prize/poly/polygold				= 1,
							/obj/item/toy/prize/poly/polyspecial			= 1
							)
	return pick(figures)

//////////////////////////////////////////////////////
//				Random Toys							//
//////////////////////////////////////////////////////

/obj/random/randomtoy
	name = "random toy"
	desc = "This is a random toy"
	icon = 'icons/obj/toy.dmi'
	icon_state = "random_toy"

/obj/random/randomtoy/item_to_spawn()
	return pick(subtypesof(/obj/item/toy)) // exclude the base type.

//////////////////////////////////////////////////////
//				Magic 8-Ball / Conch				//
//////////////////////////////////////////////////////

/obj/item/toy/eight_ball
	name = "Magic 8-Ball"
	desc = "Mystical! Magical! Ages 8+!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "eight-ball"
	w_class = SIZE_TINY
	var/use_action = "shakes the ball"
	var/last_time_used = 0
	var/list/possible_answers = list("Definitely", "All signs point to yes.", "Most likely.", "Yes.", "Ask again later.", "Better not tell you now.", "Future Unclear.", "Maybe.", "Doubtful.", "No.", "Don't count on it.", "Never.")
	var/answer_sound = 'sound/effects/bubble_pop.ogg'

/obj/item/toy/eight_ball/attack_self(mob/user)
	if(last_time_used < world.time)
		last_time_used = world.time + 30
		var/answer = pick(possible_answers)
		user.visible_message("<span class='notice'>[user] focuses on their question and [use_action]...</span>")
		sleep(10)
		user.visible_message("<span class='notice'>[bicon(src)] The [src] says \"[answer]\"</span>")
		if(answer_sound)
			playsound(src, answer_sound, VOL_EFFECTS_MASTER, 20)
		return
	else
		to_chat(user, "<span class='notice'>[src] doesn't seem to answer...</span>")
		return

/obj/item/toy/eight_ball/conch
	name = "Magic Conch Shell"
	desc = "All hail the Magic Conch!"
	icon_state = "conch"
	w_class = SIZE_TINY
	use_action = "pulls the string"
	possible_answers = list("Yes.", "No.", "Try asking again.", "Nothing.", "I don't think so.", "Neither.", "Maybe someday.")
	answer_sound = null

/obj/item/toy/eight_ball/conch/attack_self(mob/user)
	. = ..()
	flick("conch_use",src)
	playsound(src, 'sound/items/polaroid2.ogg', VOL_EFFECTS_MASTER, 20)




//////////////////////////////////////////////////////
//			  	       Moo Can   				    //
//////////////////////////////////////////////////////

/obj/item/toy/moocan
	name = "moo can"
	desc = "A toy that makes 'mooo' when used."
	icon = 'icons/obj/toy.dmi'
	icon_state = "mooo"
	w_class = SIZE_TINY
	var/cooldown = FALSE

/obj/item/toy/moocan/attack_self(mob/user)
	if(!cooldown)
		var/message = pick("Moooooo!", "Mooo", "Moo?", "MOOOO!")
		to_chat(user, "<span class='notice'>You flip the moo can [src].</span>")
		playsound(user, 'sound/items/moo.ogg', VOL_EFFECTS_MASTER, 20)
		loc.visible_message("<span class='danger'>[bicon(src)] [message]</span>")
		cooldown = TRUE
		spawn(30) cooldown = FALSE
		return
	..()


/obj/item/toy/xmas_cracker
	name = "xmas cracker"
	icon = 'icons/obj/christmas.dmi'
	icon_state = "cracker"
	desc = "Directions for use: Requires two people, one to pull each end."
	var/cracked = FALSE

/obj/item/toy/xmas_cracker/attack(mob/target, mob/user)
	if( !cracked && ishuman(target) && (target.stat == CONSCIOUS) && !target.get_active_hand() )
		target.visible_message("<span class='notice'>[user] and [target] pop \an [src]! *pop*</span>", "<span class='notice'>You pull \an [src] with [target]! *pop*</span>", "<span class='notice'>You hear a *pop*.</span>")
		var/obj/item/weapon/paper/Joke = new /obj/item/weapon/paper(user.loc)
		Joke.name = "[pick("awful","terrible","unfunny")] joke"
		Joke.info = pick("What did one snowman say to the other?\n\n<i>'Is it me or can you smell carrots?'</i>",
			"Why couldn't the snowman get laid?\n\n<i>He was frigid!</i>",
			"Where are santa's helpers educated?\n\n<i>Nowhere, they're ELF-taught.</i>",
			"What happened to the man who stole advent calanders?\n\n<i>He got 25 days.</i>",
			"What does Santa get when he gets stuck in a chimney?\n\n<i>Claus-trophobia.</i>",
			"Where do you find chili beans?\n\n<i>The north pole.</i>",
			"What do you get from eating tree decorations?\n\n<i>Tinsilitis!</i>",
			"What do snowmen wear on their heads?\n\n<i>Ice caps!</i>",
			"Why is Christmas just like life on ss13?\n\n<i>You do all the work and the fat guy gets all the credit.</i>",
			"Why doesn't Santa have any children?\n\n<i>Because he only comes down the chimney.</i>")
		new /obj/item/clothing/head/festive(target.loc)
		user.update_icons()
		cracked = 1
		icon_state = "cracker1"
		var/obj/item/toy/xmas_cracker/other_half = new /obj/item/toy/xmas_cracker(target)
		other_half.cracked = 1
		other_half.icon_state = "cracker2"
		target.put_in_active_hand(other_half)
		playsound(user, 'sound/effects/snap.ogg', VOL_EFFECTS_MASTER)
		return 1
	return ..()
//////////////////////////////////////////////////////
//				Foamblade							//
//////////////////////////////////////////////////////
/obj/item/toy/foamblade
	name = "foam blade"
	desc = "It says \"Sternside Changs #1 fan\" on it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamblade"
	item_state = "arm_blade"
	w_class = SIZE_TINY
