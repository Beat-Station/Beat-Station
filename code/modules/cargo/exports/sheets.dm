//
// Sheet Exports
//

/datum/export/stack
	unit_name = "sheet"

/datum/export/stack/get_amount(obj/O)
	var/obj/item/stack/S = O
	if(istype(S))
		return S.amount
	return 0

// Common materials.
// For base materials, see materials.dm

// Plasteel. Lightweight, strong and contains some plasma too.
/datum/export/stack/plasteel
	cost = 85
	message = "of plasteel"
	export_types = list(/obj/item/stack/sheet/plasteel)

// Plastic. Cheaper than plasteel.
/datum/export/stack/plastic
	cost = 45
	message = "of plastic"
	export_types = list(/obj/item/stack/sheet/plastic)

// Reinforced Glass. Common building material. 1 glass + 0.5 metal, cost is rounded up.
/datum/export/stack/rglass
	cost = 8
	message = "of reinforced glass"
	export_types = list(/obj/item/stack/sheet/rglass)

// Wood. Quite expensive in the grim and dark 26 century.
/datum/export/stack/wood
	cost = 25
	unit_name = "wood plank"
	export_types = list(/obj/item/stack/sheet/wood)

// Cardboard. Cheap.
/datum/export/stack/cardboard
	cost = 2
	message = "of cardboard"
	export_types = list(/obj/item/stack/sheet/cardboard)

// Sandstone. Literally dirt cheap.
/datum/export/stack/sandstone
	cost = 1
	unit_name = "block"
	message = "of sandstone"
	export_types = list(/obj/item/stack/sheet/mineral/sandstone)

// Cable.
/datum/export/stack/cable
	cost = 0.2
	unit_name = "cable piece"
	export_types = list(/obj/item/stack/cable_coil)

/datum/export/stack/cable/get_cost(O)
	return round(..())


// Weird Stuff

// Alien Alloy. Like plasteel, but better.
// Major players would pay a lot to get some, so you can get a lot of money from producing and selling those.
// Just don't forget to fire all your production staff before the end of month.
/datum/export/stack/abductor
	cost = 5000
	message = "of alien alloy"
	export_types = list(/obj/item/stack/sheet/mineral/abductor)
