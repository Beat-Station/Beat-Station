#define ORDER_SCREEN_WIDTH 625 //width of order computer interaction window
#define ORDER_SCREEN_HEIGHT 580 //height of order computer interaction window
#define SUPPLY_SCREEN_WIDTH 625 //width of supply computer interaction window
#define SUPPLY_SCREEN_HEIGHT 620 //height of supply computer interaction window

/obj/item/weapon/paper/manifest
	name = "supply manifest"
	var/erroneous = 0
	var/points = 0
	var/ordernumber = 0

/obj/item/weapon/paper/manifest/proc/is_approved()
	return stamped && stamped.len && !is_denied()

/obj/item/weapon/paper/manifest/proc/is_denied()
	return stamped && (/obj/item/weapon/stamp/denied in stamped)

var/list/blacklisted_cargo_types = typecacheof(list(
		/mob/living,
		/obj/structure/blob,
		/obj/structure/spider/spiderling,
		/obj/item/weapon/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/device/radio/beacon,
		/obj/singularity,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/telepad,
		/obj/machinery/clonepod,
		/obj/effect/hierophant,
		/obj/item/device/warp_cube,
		/obj/machinery/quantumpad
	))

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 10

	dir = 8
	travelDir = 90
	width = 12
	dwidth = 5
	height = 7
	roundstart_move = "supply_away"

	var/list/storage_objects = list(
		/obj/structure/closet,
		/obj/item/weapon/storage,
		/obj/item/weapon/moneybag,
		/obj/item/weapon/folder, // Selling a folder of stamped manifests? Sure, why not!
		/obj/structure/filingcabinet,
		/obj/structure/ore_box,
	)
	var/list/exports = list()
	var/list/exports_floor = list()

	// When TRUE, these vars allow exporting emagged/contraband items, and add some special interactions to existing exports.
	var/contraband = FALSE
	var/emagged = FALSE

/obj/docking_port/mobile/supply/register()
	if(!..())
		return 0
	shuttle_master.supply = src
	return 1

/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return check_blacklist(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/dock()
	. = ..()
	if(.)	return .

	buy()
	sell()

/obj/docking_port/mobile/supply/proc/check_blacklist(areaInstance)
	for(var/trf in areaInstance)
		var/turf/T = trf
		for(var/a in T.GetAllContents())
			if(is_type_in_typecache(a, blacklisted_cargo_types))
				return FALSE
	return TRUE

/obj/docking_port/mobile/supply/proc/buy()
	if(!is_station_level(z))		//we only buy when we are -at- the station
		return 1

	if(!shuttle_master.shoppinglist.len)
		return 2

	var/list/emptyTurfs = list()
	for(var/turf/simulated/T in areaInstance)
		if(T.density)
			continue

		var/contcount
		for(var/atom/A in T.contents)
			if(istype(A,/atom/movable/lighting_overlay))
				continue
			if(istype(A,/obj/machinery/light))
				continue //hacky but whatever, shuttles need three spots each for this shit
			if(!A.simulated)
				continue
			contcount++

		if(contcount)
			continue

		emptyTurfs += T

	for(var/datum/supply_order/SO in shuttle_master.shoppinglist)
		if(!SO.object)
			throw EXCEPTION("Supply Order [SO] has no object associated with it.")
			continue

		var/turf/T = pick_n_take(emptyTurfs)		//turf we will place it in
		if(!T)
			shuttle_master.shoppinglist.Cut(1, shuttle_master.shoppinglist.Find(SO))
			return

		var/errors = 0
		if(prob(5))
			errors |= MANIFEST_ERROR_COUNT
		if(prob(5))
			errors |= MANIFEST_ERROR_NAME
		if(prob(5))
			errors |= MANIFEST_ERROR_ITEM
		SO.createObject(T, errors)

	shuttle_master.shoppinglist.Cut()

/obj/docking_port/mobile/supply/proc/sell()
	if(z != level_name_to_num(CENTCOMM))		//we only sell when we are -at- centcomm
		return 1

	if(!exports_list.len) // No exports list? Generate it!
		setupExports()

	var/msg = ""
	var/sold_atoms = ""

	for(var/atom/movable/AM in areaInstance)
		if(AM.anchored)
			continue
		// Sell tech levels
		if(istype(AM, /obj/item/weapon/disk/tech_disk))
			var/obj/item/weapon/disk/tech_disk/disk = AM
			if(!disk.stored)
				continue
			var/datum/tech/tech = disk.stored
			var/cost = tech.getCost(shuttle_master.techLevels[tech.id])
			if(cost)
				shuttle_master.techLevels[tech.id] = tech.level
				for(var/mob/M in player_list)
					if(M.mind)
						for(var/datum/job_objective/further_research/objective in M.mind.job_objectives)
							objective.unit_completed(cost)
		sold_atoms += export_item_and_contents(AM, contraband, emagged, dry_run = FALSE)

	if(sold_atoms)
		sold_atoms += "."

	for(var/a in exports_list)
		var/datum/export/E = a
		var/export_text = E.total_printout()
		if(!export_text)
			continue

		msg += export_text + "\n"
		shuttle_master.points += E.total_cost
		E.export_end()

	shuttle_master.centcom_message = msg


/obj/docking_port/mobile/supply/proc/recursive_sell(var/obj/O, var/level=0)
	var/sold_atoms = " [O.name]"
	var/list/xports = exports
	if(level == 0)
		xports = exports_floor // If on the floor level, sell floor exports only
	level++

	for(var/a in xports)
		var/datum/export/E = a
		if(E.applies_to(O, contraband, emagged))
			E.sell_object(O, contraband, emagged)
			break

	if(level < 10 && is_type_in_list(O, storage_objects))
		for(var/obj/thing in O)
			sold_atoms += recursive_sell(thing, level)
	qdel(O)
	return sold_atoms

/********************
    SUPPLY ORDER
 ********************/
/datum/supply_order
	var/ordernum
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/orderedbyRank
	var/comment = null
	var/crates

/datum/controller/process/shuttle/proc/generateSupplyOrder(packId, _orderedby, _orderedbyRank, _comment, _crates)
	if(!packId)
		return
	var/datum/supply_packs/P = supply_packs["[packId]"]
	if(!P)
		return

	var/datum/supply_order/O = new()
	O.ordernum = ordernum++
	O.object = P
	O.orderedby = _orderedby
	O.orderedbyRank = _orderedbyRank
	O.comment = _comment
	O.crates = _crates

	requestlist += O

	return O

/datum/supply_order/proc/generateRequisition(atom/_loc)
	if(!object)
		return

	var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(_loc)
	playsound(_loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	reqform.name = "Requisition Form - [crates] '[object.name]' for [orderedby]"
	reqform.info += "<h3>[station_name] Supply Requisition Form</h3><hr>"
	reqform.info += "INDEX: #[shuttle_master.ordernum]<br>"
	reqform.info += "REQUESTED BY: [orderedby]<br>"
	reqform.info += "RANK: [orderedbyRank]<br>"
	reqform.info += "REASON: [comment]<br>"
	reqform.info += "SUPPLY CRATE TYPE: [object.name]<br>"
	reqform.info += "NUMBER OF CRATES: [crates]<br>"
	reqform.info += "ACCESS RESTRICTION: [object.access ? get_access_desc(object.access) : "None"]<br>"
	reqform.info += "CONTENTS:<br>"
	reqform.info += object.manifest
	reqform.info += "<hr>"
	reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

	reqform.update_icon()	//Fix for appearing blank when printed.

	return reqform

/datum/supply_order/proc/createObject(atom/_loc, errors=0)
	if(!object)
		return

	//create the crate
	var/atom/Crate = new object.containertype(_loc)
	Crate.name = "[object.containername] [comment ? "([comment])":"" ]"
	if(object.access)
		Crate:req_access = list(text2num(object.access))

	//create the manifest slip
	var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest()
	slip.erroneous = errors
	slip.points = object.cost
	slip.ordernumber = ordernum

	var/stationName = (errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()
	var/packagesAmt = shuttle_master.shoppinglist.len + ((errors & MANIFEST_ERROR_COUNT) ? rand(1,2) : 0)

	slip.name = "Shipping Manifest - '[object.name]' for [orderedby]"
	slip.info = "<h3>[command_name()] Shipping Manifest</h3><hr><br>"
	slip.info +="Order: #[ordernum]<br>"
	slip.info +="Destination: [stationName]<br>"
	slip.info +="Requested By: [orderedby]<br>"
	slip.info +="Rank: [orderedbyRank]<br>"
	slip.info +="Reason: [comment]<br>"
	slip.info +="Supply Crate Type: [object.name]<br>"
	slip.info +="Access Restriction: [object.access ? get_access_desc(object.access) : "None"]<br>"
	slip.info +="[packagesAmt] PACKAGES IN THIS SHIPMENT<br>"
	slip.info +="CONTENTS:<br><ul>"

	//we now create the actual contents
	var/list/contains
	if(istype(object, /datum/supply_packs/misc/randomised))
		var/datum/supply_packs/misc/randomised/SO = object
		contains = list()
		if(object.contains.len)
			for(var/j=1, j<=SO.num_contained, j++)
				contains += pick(object.contains)
	else
		contains = object.contains

	for(var/typepath in contains)
		if(!typepath)	continue
		var/atom/A = new typepath(Crate)
		if(object.amount && A.vars.Find("amount") && A:amount)
			A:amount = object.amount
		slip.info += "<li>[A.name]</li>"	//add the item to the manifest (even if it was misplaced)

	if(istype(Crate, /obj/structure/closet/critter)) // critter crates do not actually spawn mobs yet and have no contains var, but the manifest still needs to list them
		var/obj/structure/closet/critter/CritCrate = Crate
		if(CritCrate.content_mob)
			var/mob/crittername = CritCrate.content_mob
			slip.info += "<li>[initial(crittername.name)]</li>"

	if((errors & MANIFEST_ERROR_ITEM))
		//secure and large crates cannot lose items
		if(findtext("[object.containertype]", "/secure/") || findtext("[object.containertype]","/largecrate/"))
			errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lostAmt = max(round(Crate.contents.len/10), 1)
			//lose some of the items
			while(--lostAmt >= 0)
				qdel(pick(Crate.contents))

	//manifest finalisation
	slip.info += "</ul><br>"
	slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>" // And now this is actually meaningful.
	slip.loc = Crate
	if(istype(Crate, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/CR = Crate
		CR.manifest = slip
		CR.update_icon()
		CR.announce_beacons = object.announce_beacons.Copy()
	if(istype(Crate, /obj/structure/largecrate))
		var/obj/structure/largecrate/LC = Crate
		LC.manifest = slip
		LC.update_icon()

	return Crate

/***************************
    ORDER/REQUESTS CONSOLE
 **************************/
/obj/machinery/computer/supplycomp
	name = "Supply Shuttle Console"
	desc = "Used to order supplies."
	icon_screen = "supply"
	req_access = list(access_cargo)
	circuit = /obj/item/weapon/circuitboard/supplycomp
	var/temp = null
	var/reqtime = 0
	var/contraband = FALSE
	var/last_viewed_group = "categories"
	var/datum/supply_packs/content_pack

/obj/machinery/computer/ordercomp
	name = "Supply Ordering Console"
	desc = "Used to order supplies from cargo staff."
	icon = 'icons/obj/computer.dmi'
	icon_screen = "request"
	circuit = /obj/item/weapon/circuitboard/ordercomp
	var/reqtime = 0
	var/last_viewed_group = "categories"
	var/datum/supply_packs/content_pack

/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/ordercomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	ui = nanomanager.try_update_ui(user, src, ui_key, ui)
	if(!ui)
		ui = new(user, src, ui_key, "order_console.tmpl", name, ORDER_SCREEN_WIDTH, ORDER_SCREEN_HEIGHT)
		ui.open()

/obj/machinery/computer/ordercomp/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["last_viewed_group"] = last_viewed_group

	var/category_list[0]
	for(var/category in all_supply_groups)
		category_list.Add(list(list("name" = get_supply_group_name(category), "category" = category)))
	data["categories"] = category_list

	var/cat = text2num(last_viewed_group)
	var/packs_list[0]
	for(var/set_name in shuttle_master.supply_packs)
		var/datum/supply_packs/pack = shuttle_master.supply_packs[set_name]
		if(!pack.contraband && !pack.hidden && !pack.special && pack.group == cat)
			// 0/1 after the pack name (set_name) is a boolean for ordering multiple crates
			packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("contents" = set_name))))

	data["supply_packs"] = packs_list
	if(content_pack)
		var/pack_name = sanitize(content_pack.name)
		data["contents_name"] = pack_name
		data["contents"] = content_pack.manifest
		data["contents_access"] = content_pack.access ? get_access_desc(content_pack.access) : "None"

	var/requests_list[0]
	for(var/set_name in shuttle_master.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			// Check if the user owns the request, so they can cancel requests
			var/obj/item/weapon/card/id/I = user.get_id_card()
			var/owned = 0
			if(I && SO.orderedby == I.registered_name)
				owned = 1
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "owned" = owned, "command1" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in shuttle_master.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby)))
	data["orders"] = orders_list

	data["points"] = round(shuttle_master.points)
	data["send"] = list("send" = 1)

	data["moving"] = shuttle_master.supply.mode != SHUTTLE_IDLE
	data["at_station"] = shuttle_master.supply.getDockedId() == "supply_home"
	data["timeleft"] = shuttle_master.supply.timeLeft(600)

	return data

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["doorder"])
		if(world.time < reqtime)
			visible_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			nanomanager.update_uis(src)
			return 1

		var/index = copytext(href_list["doorder"], 1, lentext(href_list["doorder"])) //text2num(copytext(href_list["doorder"], 1))
		var/multi = text2num(copytext(href_list["doorder"], -1))
		if(!isnum(multi))
			return 1
		var/datum/supply_packs/P = shuttle_master.supply_packs[index]
		if(!istype(P))
			return 1
		var/crates = 1
		if(multi)
			var/num_input = input(usr, "Amount:", "How many crates?") as null|num
			if(!num_input || ..())
				return 1
			crates = Clamp(round(num_input), 1, 20)

		var/timeout = world.time + 600
		var/reason = input(usr,"Reason:","Why do you require this item?","") as null|text
		if(world.time > timeout || !reason || ..())
			return 1
		reason = sanitize(copytext(reason, 1, MAX_MESSAGE_LEN))

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		reqtime = (world.time + 5) % 1e5

		//make our supply_order datums
		for(var/i = 1; i <= crates; i++)
			var/datum/supply_order/O = shuttle_master.generateSupplyOrder(index, idname, idrank, reason, crates)
			if(!O)	return
			if(i == 1)
				O.generateRequisition(loc)

	else if(href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		var/obj/item/weapon/card/id/I = usr.get_id_card()
		for(var/i=1, i<=shuttle_master.requestlist.len, i++)
			var/datum/supply_order/SO = shuttle_master.requestlist[i]
			if(SO.ordernum == ordernum && (I && SO.orderedby == I.registered_name))
				shuttle_master.requestlist.Cut(i,i+1)
				break

	else if(href_list["last_viewed_group"])
		content_pack = null
		last_viewed_group = text2num(href_list["last_viewed_group"])

	else if(href_list["contents"])
		var/topic = href_list["contents"]
		if(topic == 1)
			content_pack = null
		else
			var/datum/supply_packs/P = shuttle_master.supply_packs[topic]
			content_pack = P

	add_fingerprint(usr)
	nanomanager.update_uis(src)
	return 1

/obj/machinery/computer/supplycomp/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_hand(mob/user)
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return 1

	post_signal("supply")
	ui_interact(user)
	return

/obj/machinery/computer/supplycomp/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='notice'>Special supplies unlocked.</span>")
		emagged = TRUE
		contraband = TRUE

/obj/machinery/computer/supplycomp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	ui = nanomanager.try_update_ui(user, src, ui_key, ui)
	if(!ui)
		ui = new(user, src, ui_key, "supply_console.tmpl", name, SUPPLY_SCREEN_WIDTH, SUPPLY_SCREEN_HEIGHT)
		ui.open()

/obj/machinery/computer/supplycomp/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["last_viewed_group"] = last_viewed_group

	var/category_list[0]
	for(var/category in all_supply_groups)
		category_list.Add(list(list("name" = get_supply_group_name(category), "category" = category)))
	data["categories"] = category_list

	var/cat = text2num(last_viewed_group)
	var/packs_list[0]
	for(var/set_name in shuttle_master.supply_packs)
		var/datum/supply_packs/pack = shuttle_master.supply_packs[set_name]
		if((pack.hidden && emagged) || (pack.contraband && contraband) || (pack.special && pack.special_enabled) || (!pack.contraband && !pack.hidden && !pack.special))
			if(pack.group == cat)
				// 0/1 after the pack name (set_name) is a boolean for ordering multiple crates
				packs_list.Add(list(list("name" = pack.name, "amount" = pack.amount, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("contents" = set_name))))

	data["supply_packs"] = packs_list
	if(content_pack)
		var/pack_name = sanitize(content_pack.name)
		data["contents_name"] = pack_name
		data["contents"] = content_pack.manifest
		data["contents_access"] = content_pack.access ? get_access_desc(content_pack.access) : "None"

	var/requests_list[0]
	for(var/set_name in shuttle_master.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			if(!SO.comment)
				SO.comment = "No comment."
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in shuttle_master.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment)))
	data["orders"] = orders_list

	data["canapprove"] = (shuttle_master.supply.getDockedId() == "supply_away") && !(shuttle_master.supply.mode != SHUTTLE_IDLE)
	data["points"] = round(shuttle_master.points)
	data["send"] = list("send" = 1)
	data["message"] = shuttle_master.centcom_message ? shuttle_master.centcom_message : "Remember to stamp and send back the supply manifests."

	data["moving"] = shuttle_master.supply.mode != SHUTTLE_IDLE
	data["at_station"] = shuttle_master.supply.getDockedId() == "supply_home"
	data["timeleft"] = shuttle_master.supply.timeLeft(600)
	data["can_launch"] = !shuttle_master.supply.canMove()
	return data

/obj/machinery/computer/supplycomp/proc/is_authorized(mob/user)
	if(allowed(user))
		return 1

	if(user.can_admin_interact())
		return 1

	return 0

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return 1

	if(!is_authorized(usr))
		return 1

	if(!shuttle_master)
		log_runtime(EXCEPTION("The shuttle_master controller datum is missing somehow."), src)
		return 1

	if(href_list["send"])
		if(shuttle_master.supply.canMove())
			to_chat(usr, "<span class='warning'>For safety reasons the automated supply shuttle cannot transport live organisms, classified nuclear weaponry or homing beacons.</span>")
		else if(shuttle_master.supply.getDockedId() == "supply_home")
			shuttle_master.supply.emagged = emagged
			shuttle_master.supply.contraband = contraband
			shuttle_master.toggleShuttle("supply", "supply_home", "supply_away", 1)
			investigate_log("[key_name(usr)] has sent the supply shuttle away. Remaining points: [shuttle_master.points]. Shuttle contents: [shuttle_master.sold_atoms]", "cargo")
		else if(!shuttle_master.supply.request(shuttle_master.getDock("supply_home")))
			post_signal("supply")
			if(LAZYLEN(shuttle_master.shoppinglist) && prob(10))
				var/datum/supply_order/O = new /datum/supply_order()
				O.ordernum = shuttle_master.ordernum
				O.object = shuttle_master.supply_packs[pick(shuttle_master.supply_packs)]
				O.orderedby = random_name(pick(MALE,FEMALE), species = "Human")
				shuttle_master.shoppinglist += O
				investigate_log("Random [O.object] crate added to supply shuttle")

	else if(href_list["doorder"])
		if(world.time < reqtime)
			visible_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			nanomanager.update_uis(src)
			return 1

		var/index = copytext(href_list["doorder"], 1, lentext(href_list["doorder"])) //text2num(copytext(href_list["doorder"], 1))
		var/multi = text2num(copytext(href_list["doorder"], -1))
		if(!isnum(multi))
			return 1
		var/datum/supply_packs/P = shuttle_master.supply_packs[index]
		if(!istype(P))
			return 1
		var/crates = 1
		if(multi)
			var/num_input = input(usr, "Amount:", "How many crates?") as null|num
			if(!num_input || !is_authorized(usr) || ..())
				return 1
			crates = Clamp(round(num_input), 1, 20)

		var/timeout = world.time + 600
		var/reason = input(usr,"Reason:","Why do you require this item?","") as null|text
		if(world.time > timeout || !reason || !is_authorized(usr) || ..())
			return 1
		reason = sanitize(copytext(reason, 1, MAX_MESSAGE_LEN))

		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"

		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name

		//make our supply_order datums
		for(var/i = 1; i <= crates; i++)
			var/datum/supply_order/O = shuttle_master.generateSupplyOrder(index, idname, idrank, reason, crates)
			if(!O)	return 1
			if(i == 1)
				O.generateRequisition(loc)

	else if(href_list["confirmorder"])
		if(shuttle_master.supply.getDockedId() != "supply_away" || shuttle_master.supply.mode != SHUTTLE_IDLE)
			return 1
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		var/datum/supply_packs/P
		for(var/i=1, i<=shuttle_master.requestlist.len, i++)
			var/datum/supply_order/SO = shuttle_master.requestlist[i]
			if(SO.ordernum == ordernum)
				O = SO
				P = O.object
				if(shuttle_master.points >= P.cost)
					shuttle_master.requestlist.Cut(i,i+1)
					shuttle_master.points -= P.cost
					shuttle_master.shoppinglist += O
					investigate_log("[key_name(usr)] has authorized an order for [P.name]. Remaining points: [shuttle_master.points].", "cargo")
				else
					to_chat(usr, "<span class='warning'>There are insufficient supply points for this request.</span>")
				break

	else if(href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		for(var/i=1, i<=shuttle_master.requestlist.len, i++)
			var/datum/supply_order/SO = shuttle_master.requestlist[i]
			if(SO.ordernum == ordernum)
				shuttle_master.requestlist.Cut(i,i+1)
				break

	else if(href_list["last_viewed_group"])
		content_pack = null
		last_viewed_group = text2num(href_list["last_viewed_group"])

	else if(href_list["contents"])
		var/topic = href_list["contents"]
		if(topic == 1)
			content_pack = null
		else
			var/datum/supply_packs/P = shuttle_master.supply_packs[topic]
			content_pack = P

	add_fingerprint(usr)
	nanomanager.update_uis(src)
	return 1

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)

/**********
    MISC
 **********/
/area/supply/station
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

/area/supply/dock
	name = "Supply Shuttle"
	icon_state = "shuttle3"
	requires_power = 0

/obj/structure/plasticflaps
	name = "\improper plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = 4
	var/list/mobs_can_pass = list(
		/mob/living/carbon/slime,
		/mob/living/simple_animal/mouse,
		/mob/living/silicon/robot/drone,
		/mob/living/simple_animal/bot/mulebot
		)
	var/state = PLASTIC_FLAPS_NORMAL
	var/can_deconstruct = TRUE

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	switch(state)
		if(PLASTIC_FLAPS_NORMAL)
			to_chat(user, "<span class='notice'>[src] are <b>screwed</b> to the floor.</span>")
		if(PLASTIC_FLAPS_DETACHED)
			to_chat(user, "<span class='notice'>[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>sliced</b> apart.</span>")

/obj/structure/plasticflaps/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(isscrewdriver(W))
		if(state == PLASTIC_FLAPS_NORMAL)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] unscrews [src] from the floor.</span>", "<span class='notice'>You start to unscrew [src] from the floor...</span>", "You hear rustling noises.")
			if(do_after(user, 180*W.toolspeed, target = src))
				if(state != PLASTIC_FLAPS_NORMAL)
					return
				state = PLASTIC_FLAPS_DETACHED
				anchored = FALSE
				to_chat(user, "<span class='notice'>You unscrew [src] from the floor.</span>")
		else if(state == PLASTIC_FLAPS_DETACHED)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] screws [src] to the floor.</span>", "<span class='notice'>You start to screw [src] to the floor...</span>", "You hear rustling noises.")
			if(do_after(user, 40*W.toolspeed, target = src))
				if(state != PLASTIC_FLAPS_DETACHED)
					return
				state = PLASTIC_FLAPS_NORMAL
				anchored = TRUE
				to_chat(user, "<span class='notice'>You screw [src] from the floor.</span>")
	else if(iswelder(W))
		if(state == PLASTIC_FLAPS_DETACHED)
			var/obj/item/weapon/weldingtool/WT = W
			if(!WT.remove_fuel(0, user))
				return
			playsound(loc, WT.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] slices apart [src].</span>", "<span class='notice'>You start to slice apart [src].</span>", "You hear welding.")
			if(do_after(user, 120*WT.toolspeed, target = src))
				if(state != PLASTIC_FLAPS_DETACHED)
					return
				to_chat(user, "<span class='notice'>You slice apart [src].</span>")
				var/obj/item/stack/sheet/plastic/five/P = new(loc)
				P.add_fingerprint(user)
				qdel(src)
	else
		. = ..()

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/stool/bed/B = A
	if(istype(A, /obj/structure/stool/bed) && B.buckled_mob)//if it's a bed/chair and someone is buckled, it will not pass
		return 0

	if(istype(A, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/C = A
		if(C.move_delay)
			return 0

	if(istype(A, /obj/vehicle))	//no vehicles
		return 0

	var/mob/living/M = A
	if(istype(M))
		if(M.lying)
			return ..()
		for(var/mob_type in mobs_can_pass)
			if(istype(A, mob_type))
				return ..()
		if(istype(A, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.is_small)
				return ..()
		return 0

	return ..()


/obj/structure/plasticflaps/CanAStarPass(ID, to_dir, caller)
	if(istype(caller, /mob/living))
		for(var/mob_type in mobs_can_pass)
			if(istype(caller, mob_type))
				return 1

		var/mob/living/M = caller
		if(!M.ventcrawler && M.mob_size > MOB_SIZE_SMALL)
			return 0
	return 1

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
		if(3)
			if(prob(5))
				qdel(src)

/obj/structure/plasticflaps/proc/deconstruct(disassembled = TRUE)
	if(can_deconstruct)
		new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "\improper Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

/obj/structure/plasticflaps/mining/initialize()
	air_update_turf(1)
	..()

/obj/structure/plasticflaps/mining/Destroy()
	air_update_turf(1)
	return ..()

/obj/structure/plasticflaps/mining/CanAtmosPass(turf/T)
	return 0

#undef ORDER_SCREEN_WIDTH
#undef ORDER_SCREEN_HEIGHT
#undef SUPPLY_SCREEN_WIDTH
#undef SUPPLY_SCREEN_HEIGHT
