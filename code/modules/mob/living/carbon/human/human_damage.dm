//Updates the mob's health from bodyparts and mob damage variables
// todo: for some reason mobs call it several times per life tick
/mob/living/carbon/human/updatehealth()
	var/total_burn = 0
	var/total_brute = 0
	for(var/obj/item/organ/external/BP in bodyparts) // hardcoded to streamline things a bit
		if(BP.is_robotic() && !BP.vital)
			continue // *non-vital* robot limbs don't count towards shock and crit
		total_brute += BP.brute_dam
		total_burn += BP.burn_dam

	health = maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute
	med_hud_set_health()
	med_hud_set_status()

	if( ((maxHealth - total_burn) < config.health_threshold_dead) && stat == DEAD)
		if(!HAS_TRAIT(src, TRAIT_BURNT))
			ADD_TRAIT(src, TRAIT_BURNT, GENERIC_TRAIT)
			update_body()

// =============================================

// because of organ humans have two types of brain damage
// this is too obscure and we need to do something about it

/mob/living/carbon/human/getBrainLoss()
	if(!should_have_organ(O_BRAIN))
		brainloss = 0
		return brainloss

	var/obj/item/organ/internal/brain/IO = organs_by_name[O_BRAIN]

	if(!IO)
		return maxHealth * 2

	var/res = brainloss

	if(IO.is_bruised())
		res += 20
	if(IO.is_broken())
		res += 50

	res = min(res, maxHealth * 2)

	return res

/mob/living/carbon/human/adjustBrainLoss(amount)
	if(amount > 0 && !should_have_organ(O_BRAIN))
		return

	return ..()

// =============================================

// Humans don't use bruteloss or fireloss vars
// These procs fetch a cumulative total damage from all bodyparts
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.is_robotic() && !BP.vital)
			continue // robot limbs don't count towards shock and crit
		amount += BP.brute_dam
	return amount

/mob/living/carbon/human/adjustBruteLoss(amount)
	if(amount > 0)
		return take_overall_damage(amount, 0)
	else
		return heal_overall_damage(-amount, 0)

/mob/living/carbon/human/resetBruteLoss()
	heal_overall_damage(getBruteLoss(), 0)

// =============================================

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.is_robotic() && !BP.vital)
			continue // robot limbs don't count towards shock and crit
		amount += BP.burn_dam
	return amount

/mob/living/carbon/human/adjustFireLoss(amount)
	if(amount > 0 && (RESIST_HEAT in mutations))
		return

	if(amount > 0)
		return take_overall_damage(0, amount)
	else
		return heal_overall_damage(0, -amount)

/mob/living/carbon/human/resetFireLoss()
	heal_overall_damage(0, getFireLoss())

// =============================================

/mob/living/carbon/human/adjustOxyLoss(amount)
	if(amount > 0 && !should_have_organ(O_LUNGS))
		return

	return ..()

// =============================================

/mob/living/carbon/human/adjustCloneLoss(amount)
	. = ..()

	time_of_last_damage = world.time

	if (. > 0)
		var/mut_prob = min(80, getCloneLoss()+10)
		if (prob(mut_prob))
			var/list/candidates = list()
			for (var/obj/item/organ/external/BP in bodyparts)
				if(!(BP.status & ORGAN_MUTATED))
					candidates += BP
			if (candidates.len)
				var/obj/item/organ/external/BP = pick(candidates)
				BP.mutate()
				to_chat(src, "<span class = 'notice'>Something is not right with your [BP.name]...</span>")
				return
	else if(. < 0)
		var/heal_prob = max(0, 80 - getCloneLoss())
		if (prob(heal_prob))
			for (var/obj/item/organ/external/BP in bodyparts)
				if (BP.status & ORGAN_MUTATED)
					BP.unmutate()
					to_chat(src, "<span class = 'notice'>Your [BP.name] is shaped normally again.</span>")
					return

	if (getCloneLoss() < 1)
		for (var/obj/item/organ/external/BP in bodyparts)
			if (BP.status & ORGAN_MUTATED)
				BP.unmutate()
				to_chat(src, "<span class = 'notice'>Your [BP.name] is shaped normally again.</span>")
	med_hud_set_health()


// =============================================

/mob/living/carbon/human/Stun(amount, ignore_canstun = FALSE)
	if((HULK in mutations) && !ignore_canstun)
		return SetStunned(0)
	..()

/mob/living/carbon/human/Weaken(amount, ignore_canstun = FALSE)
	if((HULK in mutations) && !ignore_canstun)
		return SetWeakened(0)
	..()

/mob/living/carbon/human/Paralyse(amount, ignore_canstun = FALSE)
	if((HULK in mutations) && !ignore_canstun)
		return SetParalysis(0)
	..()

////////////////////////////////////////////

//Returns a list of damaged bodyparts
/mob/living/carbon/human/proc/get_damaged_bodyparts(brute, burn)
	var/list/parts = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		if((brute && BP.brute_dam) || (burn && BP.burn_dam))
			parts += BP
	return parts

//Returns a list of damageable bodyparts
/mob/living/carbon/human/proc/get_damageable_bodyparts()
	var/list/parts = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.is_damageable())
			parts += BP
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_bodypart_damage(brute, burn)
	var/list/parts = get_damaged_bodyparts(brute, burn)
	if(!parts.len)
		return
	var/obj/item/organ/external/BP = pick(parts)
	BP.heal_damage(brute, burn)

	updatehealth()

//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_bodypart_damage(brute, burn, sharp = 0, edge = 0)
	var/list/parts = get_damageable_bodyparts()
	if(!parts.len)
		return

	var/obj/item/organ/external/BP = pick(parts)
	var/damage_flags = (sharp ? DAM_SHARP : 0) | (edge ? DAM_EDGE : 0)

	if(BP.take_damage(brute, burn, damage_flags))

		updatehealth()
		speech_problem_flag = 1

// Damage certain bodyparts
/mob/living/carbon/human/proc/take_certain_bodypart_damage(list/parts_name, brute, burn, sharp = 0, edge = 0)
	for(var/name in parts_name)
		var/obj/item/organ/external/BP = get_bodypart(name)
		if(!BP)
			continue

		var/damage_flags = (sharp ? DAM_SHARP : FALSE) | (edge ? DAM_EDGE : FALSE)

		if(BP.take_damage(brute, burn, damage_flags))
			updatehealth()

//Heal MANY external bodyparts, in random order
/mob/living/carbon/human/heal_overall_damage(brute, burn)
	var/list/parts = get_damaged_bodyparts(brute, burn)
	while(parts.len && (brute > 0 || burn > 0))
		var/obj/item/organ/external/BP = pick(parts)
		var/brute_was = BP.brute_dam
		var/burn_was = BP.burn_dam
		BP.heal_damage(brute, burn)
		brute -= (brute_was - BP.brute_dam)
		burn -= (burn_was - BP.burn_dam)
		parts -= BP
	updatehealth()

	speech_problem_flag = 1


// damage MANY external bodyparts, in random order
// todo return value
/mob/living/carbon/human/take_overall_damage(brute, burn, sharp = 0, edge = 0, used_weapon = null)

	var/list/parts = get_damageable_bodyparts()
	if(!parts.len)
		return

	var/damage_flags = (sharp ? DAM_SHARP : 0) | (edge ? DAM_EDGE : 0)

	while(parts.len && (brute > 0 || burn > 0) )
		var/obj/item/organ/external/BP = pick(parts)

		var/brute_per_part = round(brute / parts.len, 0.1)
		var/burn_per_part = round(burn / parts.len, 0.1)

		var/brute_was = BP.brute_dam
		var/burn_was = BP.burn_dam

		BP.take_damage(brute_per_part, burn_per_part, damage_flags, used_weapon)
		brute -= (BP.brute_dam - brute_was)
		burn -= (BP.burn_dam - burn_was)

		parts -= BP

	updatehealth()



////////////////////////////////////////////

/*
This function restores the subjects blood to max.
*/
/mob/living/carbon/human/proc/restore_blood()
	blood_add(BLOOD_VOLUME_NORMAL - blood_amount(exact = TRUE))
	fixblood()


/*
This function restores all bodyparts.
*/
/mob/living/carbon/human/restore_all_bodyparts()
	for(var/obj/item/organ/external/BP in bodyparts)
		BP.rejuvenate()
	for(var/BP_ZONE in species.has_bodypart)
		if(!bodyparts_by_name[BP_ZONE])
			var/path = species.has_bodypart[BP_ZONE]
			var/obj/item/organ/external/E = new path(null)
			E.insert_organ(src)

/mob/living/carbon/human/restore_all_organs()
	for(var/organ_tag in species.has_organ)
		var/obj/item/organ/O = organs_by_name[organ_tag]
		if(!O)
			O = species.has_organ[organ_tag]
			O = new O(null)
			O.insert_organ(src)

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/obj/item/organ/external/BP = get_bodypart(zone)
	if(isbodypart(BP))
		if(BP.heal_damage(brute, burn))
			med_hud_set_health()
	else
		return 0

/mob/living/carbon/human/proc/get_bodypart(zone)
	if(!zone)
		zone = BP_CHEST

	else if(zone in list(O_EYES , O_MOUTH))
		zone = BP_HEAD
	else if(zone == BP_ACTIVE_ARM)
		zone = hand ? BP_L_ARM : BP_R_ARM
	else if(zone == BP_INACTIVE_ARM)
		zone = hand ? BP_R_ARM : BP_L_ARM

	return bodyparts_by_name[zone]

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, damage_flags = 0, obj/used_weapon = null)
	if(damagetype == HALLOSS && HAS_TRAIT(src, TRAIT_NO_PAIN))
		return FALSE

	//Handle other types of damage or healing
	if(damage < 0 || !(damagetype in list(BRUTE, BURN)))
		..(damage, damagetype, def_zone, blocked)
		return TRUE

	handle_suit_punctures(damagetype, damage)

	if(blocked >= 100)
		return FALSE

	var/obj/item/organ/external/BP = null
	if(isbodypart(def_zone))
		BP = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		BP = get_bodypart(check_zone(def_zone))

	if(!BP)
		return FALSE

	if(blocked)
		damage *= blocked_mult(blocked)

	var/datum/wound/created_wound
	damageoverlaytemp = 20
	switch(damagetype)
		if(BRUTE)
			created_wound = BP.take_damage(damage, 0, damage_flags, used_weapon)
		if(BURN)
			created_wound = BP.take_damage(0, damage, damage_flags, used_weapon)
	if(damage > 8 && (BP.status & ORGAN_SPLINTED))
		BP.status &= ~ORGAN_SPLINTED
		playsound(src, 'sound/effects/splint_broke.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='bold warning'>You see how the splint falls off from [src]'s [BP.name]!</span>")
	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	updatehealth()


	return created_wound
