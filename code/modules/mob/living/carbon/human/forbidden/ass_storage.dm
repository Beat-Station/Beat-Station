/*
 *
 * ANAL STORAGE
 *
 */

/obj/item/weapon/storage/ass
	name = "ass storage"
	max_w_class = 2
	max_combined_w_class = 4
	silent = 1

/mob/living/carbon/human
	var/obj/item/weapon/storage/ass/ass_storage = new

/mob/living/carbon/human/attackby(obj/item/I, mob/user, params)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.a_intent == I_GRAB && H.zone_sel && H.zone_sel.selecting == "groin")
			if(ass_storage(H, I))
				return 1
	..()

/mob/living/carbon/human/proc/ass_storage(mob/living/carbon/human/H, obj/item/I = null)
	if(!species.anus)
		return 0

	if(!is_nude())
		to_chat(H, "<span class='notice'>You can't access [src == H ? "your" : "[src]'s"] anus.")
		return 0

	var/his = (src == H ? H.gender == FEMALE ? "her" : "his" : "[src]'s")
	var/your = (src == H ? "your" : "[src]'s")

	if(I)
		if(istype(I, /obj/item/weapon/disk/nuclear))
			to_chat(H, "<span class='warning'>Central command would kill you if you put it in there.</span>")
			return 1

		H.visible_message("<span class='notice'>[H] begins to put \the [I] inside [his] anus!", "<span class='notice'>You begin to put \the [I] inside [your] anus!")
		if(do_after(H, 30, target = src))
			if(ass_storage.can_be_inserted(I, 1))
				ass_storage.handle_item_insertion(I, 1)
				to_chat(H, "<span class='notice'>You put \the [I] inside [your] anus.")
			else
				to_chat(H, "<span class='warning'>\The [I] doesn't fit in [your] anus.")
	else
		H.visible_message("<span class='notice'>[H] begins to search inside [his] anus!", "<span class='notice'>You begin to search inside [your] anus!")
		if(do_after(H, 30, target = src))
			var/i = 0
			for(var/obj/item in ass_storage)
				i += 1
				ass_storage.remove_from_storage(item, loc)
			if(i == 0)
				to_chat(H, "<span class='warning'>[capitalize(your)] anus is empty.")
			else
				to_chat(H, "<span class='notice'>You remove everything from [your] anus.")
	return 1