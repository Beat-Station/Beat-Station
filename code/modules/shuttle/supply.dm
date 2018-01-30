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
	callTime = 600

	dir = 8
	travelDir = 90
	width = 12
	dwidth = 5
	height = 7
	roundstart_move = "supply_away"

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
		return !check_blacklist(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/proc/check_blacklist(areaInstance)
	for(var/trf in areaInstance)
		var/turf/T = trf
		for(var/a in T.GetAllContents())
			if(is_type_in_typecache(a, blacklisted_cargo_types))
				return FALSE
	return TRUE

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/dock()
	. = ..()
	if(.) // Fly/enter transit.
		return .

	buy()
	sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(!is_station_level(z))		//we only buy when we are -at- the station
		return 1

	if(!shuttle_master.shoppinglist.len)
		return 2

	var/list/empty_turfs = list()
	for(var/turf/simulated/T in areaInstance)
		if(is_blocked_turf(T))
			continue
		empty_turfs += T

	for(var/datum/supply_order/SO in shuttle_master.shoppinglist)
		if(!empty_turfs.len)
			break
		shuttle_master.shoppinglist -= SO
		SO.generate(pick_n_take(empty_turfs))

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
		sold_atoms += export_item_and_contents(AM, contraband, emagged, dry_run = FALSE)

	if(sold_atoms)
		sold_atoms += "."

	for(var/a in exports_list)
		var/datum/export/E = exports_list[a]
		var/export_text = E.total_printout()
		if(!export_text)
			continue

		msg += export_text + "\n"
		shuttle_master.points += E.total_cost
		E.export_end()

	shuttle_master.centcom_message = msg

/datum/controller/process/shuttle/proc/generateSupplyOrder(packId, orderedby, orderedbyRank, comment, crates)
	if(!packId)
		return
	var/datum/supply_pack/P = supply_packs["[packId]"]
	if(!P)
		return

	var/datum/supply_order/O = new(P, orderedby, orderedbyRank, comment, crates)

	requestlist += O

	return O

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