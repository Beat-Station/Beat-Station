#define ORDER_SCREEN_WIDTH 630 //width of order computer interaction window
#define ORDER_SCREEN_HEIGHT 580 //height of order computer interaction window
#define SUPPLY_SCREEN_WIDTH 630 //width of supply computer interaction window
#define SUPPLY_SCREEN_HEIGHT 620 //height of supply computer interaction window

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
	var/datum/supply_pack/content_pack

/obj/machinery/computer/ordercomp
	name = "Supply Ordering Console"
	desc = "Used to order supplies from cargo staff."
	icon = 'icons/obj/computer.dmi'
	icon_screen = "request"
	circuit = /obj/item/weapon/circuitboard/ordercomp
	var/reqtime = 0
	var/last_viewed_group = "categories"
	var/datum/supply_pack/content_pack

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
		var/datum/supply_pack/pack = shuttle_master.supply_packs[set_name]
		if(!pack.contraband && !pack.hidden && !pack.special && pack.group == cat)
			// 0/1 after the pack name (set_name) is a boolean for ordering multiple crates
			packs_list.Add(list(list("name" = pack.name, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("contents" = set_name))))

	data["supply_packs"] = packs_list
	if(content_pack)
		var/pack_name = sanitize(content_pack.name)
		data["contents_name"] = pack_name
		data["contents"] = content_pack.printout()
		data["contents_access"] = content_pack.access ? get_access_desc(content_pack.access) : "None"

	var/requests_list[0]
	for(var/set_name in shuttle_master.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			// Check if the user owns the request, so they can cancel requests
			var/obj/item/weapon/card/id/I = user.get_id_card()
			var/owned = 0
			if(I && SO.orderer == I.registered_name)
				owned = 1
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.pack.name, "orderedby" = SO.orderer, "owned" = owned, "command1" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in shuttle_master.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.pack.name, "orderedby" = SO.orderer)))
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
		var/datum/supply_pack/P = shuttle_master.supply_packs[index]
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
			if(SO.ordernum == ordernum && (I && SO.orderer == I.registered_name))
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
			var/datum/supply_pack/P = shuttle_master.supply_packs[topic]
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
		var/datum/supply_pack/pack = shuttle_master.supply_packs[set_name]
		if((pack.hidden && emagged) || (pack.contraband && contraband) || (pack.special && pack.special_enabled) || (!pack.contraband && !pack.hidden && !pack.special))
			if(pack.group == cat)
				// 0/1 after the pack name (set_name) is a boolean for ordering multiple crates
				packs_list.Add(list(list("name" = pack.name, "cost" = pack.cost, "command1" = list("doorder" = "[set_name]0"), "command2" = list("doorder" = "[set_name]1"), "command3" = list("contents" = set_name))))

	data["supply_packs"] = packs_list
	if(content_pack)
		var/pack_name = sanitize(content_pack.name)
		data["contents_name"] = pack_name
		data["contents"] = content_pack.printout()
		data["contents_access"] = content_pack.access ? get_access_desc(content_pack.access) : "None"

	var/requests_list[0]
	for(var/set_name in shuttle_master.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			if(!SO.comment)
				SO.comment = "No comment."
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.pack.name, "orderedby" = SO.orderer, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum))))
	data["requests"] = requests_list

	var/orders_list[0]
	for(var/set_name in shuttle_master.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.pack.name, "orderedby" = SO.orderer, "comment" = SO.comment)))
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
				O.pack = shuttle_master.supply_packs[pick(shuttle_master.supply_packs)]
				O.orderer = random_name(pick(MALE,FEMALE), species = "Human")
				shuttle_master.shoppinglist += O
				investigate_log("Random [O.pack] crate added to supply shuttle")

	else if(href_list["doorder"])
		if(world.time < reqtime)
			visible_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			nanomanager.update_uis(src)
			return 1

		var/index = copytext(href_list["doorder"], 1, lentext(href_list["doorder"])) //text2num(copytext(href_list["doorder"], 1))
		var/multi = text2num(copytext(href_list["doorder"], -1))
		if(!isnum(multi))
			return 1
		var/datum/supply_pack/P = shuttle_master.supply_packs[index]
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
		for(var/datum/supply_order/SO in shuttle_master.requestlist)
			if(SO.ordernum == ordernum)
				if(shuttle_master.points >= SO.pack.cost)
					shuttle_master.points -= SO.pack.cost
					shuttle_master.requestlist -= SO
					shuttle_master.shoppinglist += SO
					investigate_log("[key_name(usr)] has authorized an order for [SO.pack.name]. Remaining points: [shuttle_master.points].", "cargo")

	else if(href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		for(var/datum/supply_order/SO in shuttle_master.requestlist)
			if(SO.ordernum == ordernum)
				shuttle_master.requestlist -= SO
				break

	else if(href_list["last_viewed_group"])
		content_pack = null
		last_viewed_group = text2num(href_list["last_viewed_group"])

	else if(href_list["contents"])
		var/topic = href_list["contents"]
		if(topic == 1)
			content_pack = null
		else
			var/datum/supply_pack/P = shuttle_master.supply_packs[topic]
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