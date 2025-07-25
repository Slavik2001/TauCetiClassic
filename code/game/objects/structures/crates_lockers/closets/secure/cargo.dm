/obj/structure/closet/secure_closet/cargotech
	name = "Cargo Technician's Locker"
	req_access = list(access_cargo)
	icon_state = "securecargo"
	icon_closed = "securecargo"
	icon_opened = "securecargo_open"


/obj/structure/closet/secure_closet/cargotech/PopulateContents()
	new /obj/item/clothing/under/rank/cargotech(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/brown(src)
	new /obj/item/clothing/head/soft/cargo(src)
	new /obj/item/weapon/storage/pouch/medium_generic(src)
//	new /obj/item/weapon/cartridge/quartermaster(src)
	if(SSenvironment.envtype[z] == ENV_TYPE_SNOW)
		new /obj/item/clothing/suit/hooded/wintercoat/cargo(src)
		new /obj/item/clothing/suit/hooded/wintercoat/cargo(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/santa(src)

/obj/structure/closet/secure_closet/quartermaster
	name = "Quartermaster's Locker"
	req_access = list(access_qm)
	icon_state = "secureqm"
	icon_closed = "secureqm"
	icon_opened = "secureqm_open"

/obj/structure/closet/secure_closet/quartermaster/PopulateContents()
	new /obj/item/clothing/under/rank/postal_dude_shirt(src)
	new /obj/item/device/remote_device/quartermaster(src)
	new /obj/item/clothing/suit/storage/postal_dude_coat(src)
	new /obj/item/clothing/under/rank/cargo(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/black(src)
//	new /obj/item/weapon/cartridge/quartermaster(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/weapon/tank/air(src)
	new /obj/item/clothing/mask/gas/coloured(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/clothing/head/soft/cargo(src)
	new /obj/item/weapon/mining_voucher(src)
	new /obj/item/weapon/survivalcapsule(src)
	new /obj/item/clothing/accessory/medal/cargo(src)
	new /obj/item/weapon/storage/pouch/medium_generic(src)
	new /obj/item/weapon/storage/pouch/large_generic(src)
	if(SSenvironment.envtype[z] == ENV_TYPE_SNOW)
		new /obj/item/clothing/suit/hooded/wintercoat/cargo(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/santa(src)

/obj/structure/closet/secure_closet/recycler
	name = "Recycler's Locker"
	req_access = list(access_recycler)
	icon_state = "securecargo"
	icon_closed = "securecargo"
	icon_opened = "securecargo_open"

/obj/structure/closet/secure_closet/recycler/PopulateContents()
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/storage/bag/trash/miners(src)
	new /obj/item/clothing/under/rank/recycler(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/head/soft/cargo(src)
	new /obj/item/clothing/head/helmet/space/globose/recycler(src)
	new /obj/item/clothing/suit/space/globose/recycler(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/storage/pouch/small_generic(src)
	if(SSenvironment.envtype[z] == ENV_TYPE_SNOW)
		new /obj/item/clothing/suit/hooded/wintercoat/cargo(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/santa(src)
