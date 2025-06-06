//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
/mob/living/carbon/monkey/equip_to_slot(obj/item/W, slot)
	if(!slot)
		return
	if(!istype(W))
		return

	W.screen_loc = null // will get moved if inventory is visible
	W.forceMove(src)

	switch(slot)
		if(SLOT_HEAD)
			head = W
			W.equipped(src, slot)
		if(SLOT_BACK)
			src.back = W
			W.equipped(src, slot)
		if(SLOT_WEAR_MASK)
			src.wear_mask = W
			W.equipped(src, slot)
		if(SLOT_HANDCUFFED)
			src.handcuffed = W
		if(SLOT_LEGCUFFED)
			src.legcuffed = W
			W.equipped(src, slot)
		if(SLOT_L_HAND)
			src.l_hand = W
			W.equipped(src, slot)
		if(SLOT_R_HAND)
			src.r_hand = W
			W.equipped(src, slot)
		if(SLOT_IN_BACKPACK)
			if(get_active_hand() == W)
				remove_from_mob(W)
			W.loc = src.back
		else
			to_chat(usr, "<span class='red'>You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	if(W == l_hand && slot != SLOT_L_HAND)
		l_hand = null
		W.update_inv_mob() // So items actually disappear from hands.
	else if(W == r_hand && slot != SLOT_R_HAND)
		r_hand = null
		W.update_inv_mob()

	W.plane = ABOVE_HUD_PLANE
	W.slot_equipped = slot
	W.update_inv_mob()
