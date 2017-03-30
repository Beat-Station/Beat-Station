/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = 1
	anchored = 1

/obj/structure/dresser/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/underwear))
		user.drop_item()
		qdel(I)
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		return
	..()

/obj/structure/dresser/attack_hand(mob/user as mob)
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		var/choice = input(user, "Underwear, Undershirt, or Socks?", "Changing") as null|anything in list("Underwear","Undershirt","Socks")

		if(!Adjacent(user))
			return
		switch(choice)
			if("Underwear")
				var/new_undies = input(user, "Select your underwear", "Changing")  as null|anything in underwear_list
				if(new_undies)
					var/obj/item/clothing/underwear/underpants/up = underwear_list[new_undies]
					H.equip_or_collect(new up.type(), slot_underpants)

			if("Undershirt")
				var/new_undies = input(user, "Select your undershirt", "Changing")  as null|anything in undershirt_list
				if(new_undies)
					var/obj/item/clothing/underwear/undershirt/up = undershirt_list[new_undies]
					H.equip_or_collect(new up.type(), slot_undershirt)

			if("Socks")
				var/list/valid_sockstyles = list()
				for(var/sockstyle in socks_list)
					var/datum/sprite_accessory/S = socks_list[sockstyle]
					if(!(H.species.name in S.species_allowed))
						continue
					valid_sockstyles[sockstyle] = socks_list[sockstyle]
				var/new_socks = input(user, "Choose your socks:", "Changing")  as null|anything in valid_sockstyles
				if(new_socks)
					H.socks = new_socks

		add_fingerprint(H)
		H.update_inv_underwear()