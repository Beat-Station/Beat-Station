#define MANIFEST_ERROR_CHANCE 5

/obj/item/weapon/paper/manifest
	name = "supply manifest"
	var/errors = 0
	var/points = 0
	var/ordernumber = 0

/obj/item/weapon/paper/manifest/New(atom/A, number, cost)
	..()
	ordernumber = number
	points = cost

	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_COUNT
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_NAME
	if(prob(MANIFEST_ERROR_CHANCE))
		errors |= MANIFEST_ERROR_ITEM

/obj/item/weapon/paper/manifest/proc/is_approved()
	return stamped && stamped.len && !is_denied()

/obj/item/weapon/paper/manifest/proc/is_denied()
	return stamped && (/obj/item/weapon/stamp/denied in stamped)

/datum/supply_order
	var/ordernum
	var/orderer = null
	var/orderer_rank
	var/comment = null
	var/crates
	var/datum/supply_pack/pack = null

/datum/supply_order/New(datum/supply_pack/pack, orderer, orderer_rank, comment, crates)
	ordernum = shuttle_master.ordernum++
	src.pack = pack
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.comment = comment
	src.crates = crates

/datum/supply_order/proc/generateRequisition(turf/T)
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(T)

	playsound(T, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)

	P.name = "Requisition Form - [crates] '[pack.name]' for [orderer]"
	P.info += "<h3>[station_name] Supply Requisition Form</h3><hr>"
	P.info += "INDEX: #[shuttle_master.ordernum]<br>"
	P.info += "REQUESTED BY: [orderer]<br>"
	P.info += "RANK: [orderer_rank]<br>"
	P.info += "REASON: [comment]<br>"
	P.info += "SUPPLY CRATE TYPE: [pack.name]<br>"
	P.info += "NUMBER OF CRATES: [crates]<br>"
	P.info += "ACCESS RESTRICTION: [pack.access ? get_access_desc(pack.access) : "None"]<br>"
	P.info += "CONTENTS:<br>"
	P.info += pack.printout()
	P.info += "<hr>"
	P.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	P.update_icon()
	return P

/datum/supply_order/proc/generateManifest(obj/structure/closet/crate/C)
	var/obj/item/weapon/paper/manifest/P = new(C, ordernum, pack.cost)

	var/station_name = (P.errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()
	var/packages_amount = shuttle_master.shoppinglist.len + ((P.errors & MANIFEST_ERROR_COUNT) ? rand(1,2) : 0)

	P.name = "Shipping Manifest - '[pack.name]' for [orderer]"
	P.info = "<h3>[command_name()] Shipping Manifest</h3><hr><br>"
	P.info += "Order: #[ordernum]<br>"
	P.info += "Destination: [station_name]<br>"
	P.info += "Requested By: [orderer]<br>"
	P.info += "Rank: [orderer_rank]<br>"
	P.info += "Reason: [comment]<br>"
	P.info += "Supply Crate Type: [pack.name]<br>"
	P.info += "Access Restriction: [pack.access ? get_access_desc(pack.access) : "None"]<br>"
	P.info += "[packages_amount] PACKAGES IN THIS SHIPMENT<br>"
	P.info += "CONTENTS:<br><ul>"
	for(var/atom/movable/AM in C.contents - P)
		if((P.errors & MANIFEST_ERROR_ITEM))
			if(prob(50))
				P.info += "<li>[AM.name]</li>"
			else
				continue
		P.info += "<li>[AM.name]</li>"
	//manifest finalisation
	P.info += "</ul><br>"
	P.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>" // And now this is actually meaningful.
	P.loc = C

	C.manifest = P
	C.announce_beacons = pack.announce_beacons.Copy()

	C.update_icon()
	P.update_icon()

	return P

/datum/supply_order/proc/generate(turf/T)
	var/obj/structure/closet/crate/C = pack.generate(T)
	var/obj/item/weapon/paper/manifest/M = generateManifest(C)

	if(M.errors & MANIFEST_ERROR_ITEM)
		if(istype(C, /obj/structure/closet/crate/secure) || istype(C, /obj/structure/closet/crate/large))
			M.errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lost = max(round(C.contents.len / 10), 1)
			while(--lost >= 0)
				qdel(pick(C.contents))
	return C