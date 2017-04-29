/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty wooden crate."
	icon_state = "largecrate"
	density = 1
	material_drop = /obj/item/stack/sheet/wood

/obj/structure/closet/crate/large/can_open()
	return 0

/obj/structure/closet/crate/large/can_close()
	return 0

/obj/structure/closet/crate/large/attack_hand(mob/user)
	add_fingerprint(user)
	if(manifest)
		tear_manifest(user)
	else
		to_chat(user, "<span class='warning'>You need a crowbar to pry this open!</span>")

/obj/structure/closet/crate/large/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/crowbar))
		var/turf/T = get_turf(src)
		if(manifest)
			tear_manifest(user)

		user.visible_message("[user] pries \the [src] open.", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='italics'>You hear splitting wood.</span>")
		playsound(src.loc, 'sound/weapons/slashmiss.ogg', 75, 1)

		for(var/i in 1 to rand(2, 5))
			new material_drop(src)
		for(var/atom/movable/AM in contents)
			AM.forceMove(T)

		qdel(src)
	else
		return ..()

/obj/structure/closet/crate/large/mule

/obj/structure/closet/crate/large/lisa
	icon_state = "lisacrate"

/obj/structure/closet/crate/large/lisa/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/pet/corgi/Lisa(loc)
	..()

/obj/structure/closet/crate/large/cow
	name = "cow crate"
	icon_state = "lisacrate"

/obj/structure/closet/crate/large/cow/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/cow(loc)
	..()

/obj/structure/closet/crate/large/goat
	name = "goat crate"
	icon_state = "lisacrate"

/obj/structure/closet/crate/large/goat/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/hostile/retaliate/goat(loc)
	..()

/obj/structure/closet/crate/large/cat
	name = "cat crate"
	icon_state = "lisacrate"

/obj/structure/closet/crate/large/cat/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/pet/cat(loc)
	..()

/obj/structure/closet/crate/large/chick
	name = "chicken crate"
	icon_state = "lisacrate"

/obj/structure/closet/crate/large/chick/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/crowbar))
		var/num = rand(4, 6)
		for(var/i = 0, i < num, i++)
			new /mob/living/simple_animal/chick(loc)
	..()