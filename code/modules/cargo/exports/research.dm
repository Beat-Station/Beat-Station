// Sell tech levels
/datum/export/tech
	cost = 500
	unit_name = "technology data disk"
	export_types = list(/obj/item/weapon/disk/tech_disk)
	var/list/techLevels = list()

/datum/export/tech/applies_to(obj/O)
	var/obj/item/weapon/disk/tech_disk/D = O
	if(!istype(D) || !D.stored)
		return 0

/datum/export/tech/get_cost(obj/O)
	var/obj/item/weapon/disk/tech_disk/D = O
	if(!D.stored)
		return 0
	var/datum/tech/tech = D.stored
	return ..() * tech.getCost(techLevels[tech.id])

/datum/export/tech/sell_object(obj/O)
	..()
	var/obj/item/weapon/disk/tech_disk/D = O
	if(!D.stored)
		return

	var/datum/tech/tech = D.stored
	techLevels[tech.id] = tech.level
	var/cost = tech.getCost(techLevels[tech.id])
	for(var/mob/M in player_list)
		if(M.mind)
			for(var/datum/job_objective/further_research/OB in M.mind.job_objectives)
				OB.unit_completed(cost)
		CHECK_TICK