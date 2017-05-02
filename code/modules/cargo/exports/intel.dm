// Drop the dox!

// Selling Syndicate docs to NT
/datum/export/intel
	cost = 25000
	unit_name = "original article"
	message = "of enemy intelligence"
	var/global/originals_recieved = list()
	var/global/copies_recieved = list()
	var/copy_path = null
	export_types = list(/obj/item/documents/syndicate)

/datum/export/intel/applies_to(obj/O, contr = 0, emag = 0)
	if(!..())
		return FALSE

	if(emagged != emag) // Emagging the console will stop you from selling Syndicate docs to NT.
		return FALSE

	// No docs double-selling!
	if(O.type in originals_recieved)
		return FALSE

	return TRUE

/datum/export/intel/get_cost(obj/O)
	if(O.type in copies_recieved)
		return ..() - 15000 // Already have a copy of it, deduce the cost.
	return ..()

/datum/export/intel/sell_object(obj/O)
	..()
	originals_recieved += O.type


// Selling NT docs to Syndicate
/datum/export/intel/syndie
	message = "of Nanotrasen intelligence"
	export_types = list(/obj/item/documents/nanotrasen)
	emagged = TRUE

// Selling Syndicate docs to Syndicate, why not?
/datum/export/intel/syndie/recovered
	cost = 15000
	unit_name = "recovered article"
	message = "of Syndicate intelligence"
	export_types = list(/obj/item/documents/syndicate)
	// Syndicate only wants originals of their docs recovered.