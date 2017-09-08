/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = 1
	anchored = 1
	burn_state = FLAMMABLE
	burntime = 25

/obj/structure/dresser/attack_hand(mob/user as mob)
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user) && anchored)
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
		H.update_body()

/obj/structure/dresser/attackby(obj/item/weapon/W, mob/user, params)
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(iswrench(W))
		if(anchored)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] is loosening [src]'s bolts.", \
								 "<span class='notice'>You are loosening [src]'s bolts...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc || !anchored)
					return
				user.visible_message("[user] loosened [src]'s bolts!", \
									 "<span class='notice'>You loosen [src]'s bolts!</span>")
				anchored = 0
		else
			if(!isfloorturf(loc))
				user.visible_message("<span class='warning'>A floor must be present to secure [src]!</span>")
				return
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] is securing [src]'s bolts...", \
								 "<span class='notice'>You are securing [src]'s bolts...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				if(!loc || anchored)
					return
				user.visible_message("[user] has secured [src]'s bolts.", \
									 "<span class='notice'>You have secured [src]'s bolts.</span>")
				anchored = 1
	else
		if(iscrowbar(W) && !anchored)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("[user] is attempting to dismantle [src].", \
								"<span class='notice'>You begin to dismantle [src]...</span>")
			if(do_after(user, 40 * W.toolspeed, target = src))
				new /obj/item/stack/sheet/wood (loc, 30)
				qdel(src)
		else if(istype(W, /obj/item/clothing/underwear))
			user.drop_item()
			qdel(W)
			to_chat(user, "<span class='notice'>You put [W] into [src].</span>")
	..()