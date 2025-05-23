/mob/living/simple_animal/bee
	name = "bees"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bees1"
	icon_dead = "bees1"
	var/strength = 1
	var/feral = 0
	var/mut = 0
	var/toxic = 0
	var/turf/target_turf
	var/mob/target_mob
	var/obj/machinery/apiary/parent
	pass_flags = PASSMOB | PASSTABLE
	turns_per_move = 6
	w_class = SIZE_MINUSCULE
	var/obj/machinery/hydroponics/my_hydrotray

/mob/living/simple_animal/bee/atom_init(mapload, obj/machinery/apiary/new_parent)
	. = ..()
	parent = new_parent

/mob/living/simple_animal/bee/Destroy()
	if(parent)
		parent.owned_bee_swarms -= src
		parent = null
	target_turf = null
	target_mob = null
	my_hydrotray = null
	return ..()

/mob/living/simple_animal/bee/Life()
	..()

	if(stat == CONSCIOUS)
		//if we're strong enough, sting some people
		var/mob/living/carbon/human/M = target_mob
		var/sting_prob = 40 // Bees will always try to sting.
		if(M in view(src,1)) // Can I see my target?
			if(prob(max(feral * 10, 0)))	// Am I mad enough to want to sting? And yes, when I initially appear, I AM mad enough
				var/obj/item/clothing/worn_suit = M.wear_suit
				var/obj/item/clothing/worn_helmet = M.head
				if(worn_suit) // Are you wearing clothes?
					sting_prob -= min(worn_suit.armor[BIO],70) // Is it sealed? I can't get to 70% of your body.
				if(istype(worn_helmet) && worn_helmet)
					sting_prob -= min(worn_helmet.armor[BIO],30) // Is your helmet sealed? I can't get to 30% of your body.
				if( prob(sting_prob) && (M.stat == CONSCIOUS || (M.stat == UNCONSCIOUS && prob(25))) ) // Try to sting! If you're not moving, think about stinging.
					M.apply_damage(min(strength, 2) + mut, BRUTE, null, null, DAM_SHARP) // Stinging. The more mutated I am, the harder I sting.
					M.apply_damage((round(feral/10,1)*(max((round(strength/20,1)),1)))+toxic, TOX) // Bee venom based on how angry I am and how many there are of me!
					to_chat(M, "<span class='warning'>Ай! Они жалятся!</span>")

		//if we're chasing someone, get a little bit angry
		if(target_mob && prob(5))
			feral++

		//calm down a little bit
		if(feral > 0)
			if(prob(feral * 20))
				feral -= 1
		else
			//if feral is less than 0, we're becalmed by smoke or steam
			if(feral < 0)
				feral += 1

			if(target_mob)
				target_mob = null
				target_turf = null
			if(strength > 5)
				//calm down and spread out a little
				var/mob/living/simple_animal/bee/B = new(get_turf(pick(orange(src,1))))
				B.strength = rand(1,5)
				src.strength -= B.strength
				if(src.strength <= 5)
					src.icon_state = "bees[src.strength]"
				B.icon_state = "bees[B.strength]"
				if(src.parent)
					B.parent = src.parent
					parent.owned_bee_swarms.Add(B)

		//make some noise
		if(prob(0.5))
			visible_message("<span class='notice'>[pick("Жжжжжжжжжж.")]</span>")

		//smoke, water and steam calms us down
		var/calming = 0
		var/list/calmers = list(/obj/effect/effect/smoke/chem, \
		/obj/effect/effect/water, \
		/obj/effect/effect/foam, \
		/obj/effect/effect/steam, \
		/obj/effect/mist)

		for(var/this_type in calmers)
			var/mob/living/simple_animal/check_effect = locate() in src.loc
			if(istype(check_effect))
				if(check_effect.type == this_type)
					calming = 1
					break

		if(calming)
			if(feral > 0)
				visible_message("<span class='notice'>Пчелы успокаиваются.</span>")
			feral = -10
			target_mob = null
			target_turf = null
			wander = TRUE

		for(var/mob/living/simple_animal/bee/B in src.loc)
			if(B == src)
				continue

			if(feral > 0)
				src.strength += B.strength
				qdel(B)
				src.icon_state = "bees[src.strength]"
				if(strength > 5)
					icon_state = "bees_swarm"
			else if(prob(10))
				//make the other swarm of bees stronger, then move away
				var/total_bees = B.strength + src.strength
				if(total_bees < 10)
					B.strength = min(5, total_bees)
					src.strength = total_bees - B.strength

					B.icon_state = "bees[B.strength]"
					if(src.strength <= 0)
						qdel(src)
						return
					src.icon_state = "bees[B.strength]"
					density = TRUE
					step(src, pick(NORTH,SOUTH,EAST,WEST))
					density = FALSE
				break

		if(target_mob)
			if(target_mob in view(src,7))
				target_turf = get_turf(target_mob)
				wander = FALSE

			else // My target's gone! But I might still be pissed! You there. You look like a good stinging target!
				for(var/mob/living/carbon/G in view(src,7))
					target_mob = G
					break

		if(target_turf)
			if(AStar(src, target_turf, TYPE_PROC_REF(/turf, Distance), 1))
				Move(get_step(src, get_dir(src,target_turf)))
				if (prob(0.1))
					visible_message("<span class='notice'>The bees swarm after [target_mob]!</span>")
			if(src.loc == target_turf)
				target_turf = null
				wander = TRUE
		else
			//find some flowers, harvest
			//angry bee swarms don't hang around
			if(feral > 0)
				turns_per_move = rand(1,3)
			else if(feral < 0)
				turns_since_move = 0
			else if(!my_hydrotray || my_hydrotray.loc != src.loc || !my_hydrotray.planted || my_hydrotray.dead || !my_hydrotray.myseed)
				var/obj/machinery/hydroponics/my_hydrotray = locate() in src.loc
				if(my_hydrotray)
					if(my_hydrotray.planted && !my_hydrotray.dead && my_hydrotray.myseed)
						turns_per_move = rand(20,50)
					else
						my_hydrotray = null

		pixel_x = rand(-12,12)
		pixel_y = rand(-12,12)

	if(!parent && prob(10))
		strength -= 1
		if(strength <= 0)
			qdel(src)
		else if(strength <= 5)
			icon_state = "bees[strength]"

	//debugging
	/*icon_state = "[strength]"
	if(strength > 5)
		icon_state = "unknown"*/
