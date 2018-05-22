/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. It has an oxygen tank for safe transport in space."
	icon_state = "critter"
	icon_closed = "critter"
	icon_opened = "critteropen"
	material_drop = /obj/item/stack/sheet/wood
	material_drop_amount = 4
	var/obj/item/weapon/tank/emergency_oxygen/tank

/obj/structure/closet/crate/critter/New()
	..()
	tank = new

/obj/structure/closet/crate/critter/Destroy()
	var/turf/T = get_turf(src)
	if(tank)
		tank.forceMove(T)
		tank = null
	return ..()

/obj/structure/closet/crate/critter/update_icon()
	overlays.Cut()
	if(opened)
		icon_state = icon_opened
	else
		icon_state = icon_closed
		if(manifest)
			overlays += "manifest"

/obj/structure/closet/crate/critter/return_air()
	if(tank)
		return tank.air_contents
	else
		return loc.return_air()