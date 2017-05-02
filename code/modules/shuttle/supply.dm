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