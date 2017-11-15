//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTHER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

// Supply Groups
var/const/supply_emergency 	= 1
var/const/supply_security 	= 2
var/const/supply_engineer	= 3
var/const/supply_medical	= 4
var/const/supply_science	= 5
var/const/supply_organic	= 6
var/const/supply_materials 	= 7
var/const/supply_misc		= 8
var/const/supply_vend		= 9

var/list/all_supply_groups = list(supply_emergency,supply_security,supply_engineer,supply_medical,supply_science,supply_organic,supply_materials,supply_misc,supply_vend)

/proc/get_supply_group_name(var/cat)
	switch(cat)
		if(1)
			return "Emergency"
		if(2)
			return "Security"
		if(3)
			return "Engineering"
		if(4)
			return "Medical"
		if(5)
			return "Science"
		if(6)
			return "Food and Livestock"
		if(7)
			return "Raw Materials"
		if(8)
			return "Miscellaneous"
		if(9)
			return "Vending"

/datum/supply_pack
	var/name = "Crate"
	var/group = supply_misc
	var/hidden = FALSE
	var/contraband = FALSE
	var/cost = 700
	var/access = FALSE
	var/access_any = FALSE
	var/list/contains = list()
	var/crate_name = "crate"
	var/crate_type = /obj/structure/closet/crate
	var/special = FALSE //Event/Station Goals/Admin enabled packs
	var/special_enabled = FALSE
	var/list/announce_beacons = list() // Particular beacons that we'll notify the relevant department when we reach


/datum/supply_pack/proc/printout()
	. = "<ul>"
	for(var/item in contains)
		var/atom/movable/AM = item
		. += "<li>[initial(AM.name)]</li>"
	. += "</ul>"

/datum/supply_pack/proc/generate(turf/T)
	var/obj/structure/closet/crate/C = new crate_type(T)
	C.name = crate_name
	if(access)
		C.req_access = list(access)
	if(access_any)
		C.req_one_access = access_any

	fill(C)

	return C

/datum/supply_pack/proc/fill(obj/structure/closet/crate/C)
	for(var/item in contains)
		new item(C)

////// Use the sections to keep things tidy please /Malkevin

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Emergency ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/emergency	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	crate_type = /obj/structure/closet/crate/internals
	group = supply_emergency


/datum/supply_pack/emergency/evac
	name = "Emergency Equipment Crate"
	contains = list(/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/medbot,
					/mob/living/simple_animal/bot/medbot,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas)
	cost = 3500
	crate_type = /obj/structure/closet/crate/internals
	crate_name = "emergency crate"
	group = supply_emergency

/datum/supply_pack/emergency/internals
	name = "Internals Crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air)
	cost = 1000
	crate_name = "internals crate"

/datum/supply_pack/emergency/firefighting
	name = "Firefighting Crate"
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/device/flashlight,
					/obj/item/device/flashlight,
					/obj/item/weapon/tank/oxygen/red,
					/obj/item/weapon/tank/oxygen/red,
					/obj/item/weapon/extinguisher,
					/obj/item/weapon/extinguisher,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red)
	cost = 1000
	crate_type = /obj/structure/closet/crate
	crate_name = "firefighting crate"

/datum/supply_pack/emergency/atmostank
	name = "Firefighting Watertank Crate"
	contains = list(/obj/item/weapon/watertank/atmos)
	cost = 1000
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "firefighting watertank crate"
	access = access_atmospherics

/datum/supply_pack/emergency/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/weapon/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/grenade/chem_grenade/antiweed,
					/obj/item/weapon/grenade/chem_grenade/antiweed)
	cost = 1500
	crate_type = /obj/structure/closet/crate/secure/hydrosec
	crate_name = "weed control crate"
	access = access_hydroponics
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_pack/emergency/specialops
	name = "Special Ops Supplies"
	contains = list(/obj/item/weapon/storage/box/emps,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/pen/sleepy,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 2000
	crate_type = /obj/structure/closet/crate
	crate_name = "special ops crate"
	hidden = 1

/datum/supply_pack/emergency/syndicate
	name = "ERROR_NULL_ENTRY"
	contains = list(/obj/item/weapon/storage/box/syndicate)
	cost = 14000
	crate_type = /obj/structure/closet/crate
	crate_name = "crate"
	hidden = 1

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security
	name = "HEADER"
	crate_type = /obj/structure/closet/crate/secure/gear
	access = access_security
	group = supply_security
	announce_beacons = list("Security" = list("Head of Security's Desk", "Warden", "Security"))


/datum/supply_pack/security/supplies
	name = "Security Supplies Crate"
	contains = list(/obj/item/weapon/storage/box/flashbangs,
					/obj/item/weapon/storage/box/teargas,
					/obj/item/weapon/storage/box/flashes,
					/obj/item/weapon/storage/box/handcuffs)
	cost = 1000
	crate_name = "security supply crate"

////// Armor: Basic

/datum/supply_pack/security/helmets
	name = "Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet)
	cost = 1000
	crate_name = "helmet crate"

/datum/supply_pack/security/justiceinbound
	name = "Standard Justice Enforcer Crate"
	contains = list(/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/mask/gas/sechailer,
					/obj/item/clothing/mask/gas/sechailer)
	cost = 6000 //justice comes at a price. An expensive, noisy price.
	crate_name = "justice enforcer crate"

/datum/supply_pack/security/armor
	name = "Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	cost = 1000
	crate_name = "armor crate"

////// Weapons: Basic

/datum/supply_pack/security/baton
	name = "Stun Batons Crate"
	contains = list(/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded,
					/obj/item/weapon/melee/baton/loaded)
	cost = 1000
	crate_name = "stun baton crate"

/datum/supply_pack/security/laser
	name = "Lasers Crate"
	contains = list(/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser,
					/obj/item/weapon/gun/energy/laser)
	cost = 1500
	crate_name = "laser crate"

/datum/supply_pack/security/taser
	name = "Stun Guns Crate"
	contains = list(/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser,
					/obj/item/weapon/gun/energy/gun/advtaser)
	cost = 1500
	crate_name = "stun gun crate"

/datum/supply_pack/security/disabler
	name = "Disabler Crate"
	contains = list(/obj/item/weapon/gun/energy/disabler,
					/obj/item/weapon/gun/energy/disabler,
					/obj/item/weapon/gun/energy/disabler)
	cost = 1000
	crate_name = "disabler crate"

/datum/supply_pack/security/forensics
	name = "Forensics Crate"
	contains = list(/obj/item/device/detective_scanner,
					/obj/item/weapon/storage/box/evidence,
					/obj/item/device/camera,
					/obj/item/device/taperecorder,
					/obj/item/toy/crayon/white,
					/obj/item/clothing/head/det_hat)
	cost = 2000
	crate_name = "forensics crate"

///// Armory stuff

/datum/supply_pack/security/armory
	name = "HEADER"
	crate_type = /obj/structure/closet/crate/secure/weapon
	access = access_armory
	announce_beacons = list("Security" = list("Warden", "Head of Security's Desk"))

///// Armor: Specialist

/datum/supply_pack/security/armory/riothelmets
	name = "Riot Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot)
	cost = 1500
	crate_name = "riot helmets crate"

/datum/supply_pack/security/armory/riotarmor
	name = "Riot Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot)
	cost = 1500
	crate_name = "riot armor crate"

/datum/supply_pack/security/armory/riotshields
	name = "Riot Shields Crate"
	contains = list(/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot,
					/obj/item/weapon/shield/riot)
	cost = 2000
	crate_name = "riot shields crate"

/datum/supply_pack/security/bullethelmets
	name = "Bulletproof Helmets Crate"
	contains = list(/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt)
	cost = 1000
	crate_name = "bulletproof helmet crate"

/datum/supply_pack/security/armory/bulletarmor
	name = "Bulletproof Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof)
	cost = 1500
	crate_name = "tactical armor crate"

/datum/supply_pack/security/armory/swat
	name = "SWAT gear crate"
	contains = list(/obj/item/clothing/head/helmet/swat,
					/obj/item/clothing/head/helmet/swat,
					/obj/item/clothing/suit/space/swat,
					/obj/item/clothing/suit/space/swat,
					/obj/item/weapon/kitchen/knife/combat,
					/obj/item/weapon/kitchen/knife/combat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/weapon/storage/belt/military/assault,
					/obj/item/weapon/storage/belt/military/assault)
	cost = 6000
	crate_name = "assault armor crate"

/datum/supply_pack/security/armory/laserarmor
	name = "Ablative Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof)		// Only two vests to keep costs down for balance
	cost = 2000
	crate_type = /obj/structure/closet/crate/secure/plasma
	crate_name = "ablative armor crate"

/////// Weapons: Specialist

/datum/supply_pack/security/armory/ballistic
	name = "Riot Shotguns Crate"
	contains = list(/obj/item/weapon/gun/projectile/shotgun/riot,
					/obj/item/weapon/gun/projectile/shotgun/riot,
					/obj/item/weapon/gun/projectile/shotgun/riot,
					/obj/item/weapon/storage/belt/bandolier,
					/obj/item/weapon/storage/belt/bandolier,
					/obj/item/weapon/storage/belt/bandolier)
	cost = 5000
	crate_name = "riot shotgun crate"

/datum/supply_pack/security/armory/ballisticauto
	name = "Combat Shotguns Crate"
	contains = list(/obj/item/weapon/gun/projectile/shotgun/automatic/combat,
					/obj/item/weapon/gun/projectile/shotgun/automatic/combat,
					/obj/item/weapon/gun/projectile/shotgun/automatic/combat,
					/obj/item/weapon/storage/belt/bandolier,
					/obj/item/weapon/storage/belt/bandolier,
					/obj/item/weapon/storage/belt/bandolier)
	cost = 8000
	crate_name = "combat shotgun crate"

/datum/supply_pack/security/armory/buckshotammo
	name = "Buckshot Ammo Crate"
	contains = list(/obj/item/ammo_box/shotgun/buck,
					/obj/item/weapon/storage/box/buck,
					/obj/item/weapon/storage/box/buck,
					/obj/item/weapon/storage/box/buck,
					/obj/item/weapon/storage/box/buck,
					/obj/item/weapon/storage/box/buck)
	cost = 4500
	crate_name = "buckshot ammo crate"

/datum/supply_pack/security/armory/slugammo
	name = "Slug Ammo Crate"
	contains = list(/obj/item/ammo_box/shotgun,
					/obj/item/weapon/storage/box/slug,
					/obj/item/weapon/storage/box/slug,
					/obj/item/weapon/storage/box/slug,
					/obj/item/weapon/storage/box/slug,
					/obj/item/weapon/storage/box/slug)
	cost = 4500
	crate_name = "slug ammo crate"

/datum/supply_pack/security/armory/expenergy
	name = "Energy Guns Crate"
	contains = list(/obj/item/weapon/gun/energy/gun,
					/obj/item/weapon/gun/energy/gun)			// Only two guns to keep costs down
	cost = 2500
	crate_type = /obj/structure/closet/crate/secure/plasma
	crate_name = "energy gun crate"

/datum/supply_pack/security/armory/eweapons
	name = "Incendiary Weapons Crate"
	contains = list(/obj/item/weapon/flamethrower/full,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary,
					/obj/item/weapon/grenade/chem_grenade/incendiary)
	cost = 1500	// its a fecking flamethrower and some plasma, why the shit did this cost so much before!?
	crate_type = /obj/structure/closet/crate/secure/plasma
	crate_name = "incendiary weapons crate"
	access = access_heads

/datum/supply_pack/security/armory/wt550
	name = "WT-550 Auto Rifle Crate"
	contains = list(/obj/item/weapon/gun/projectile/automatic/wt550,
					/obj/item/weapon/gun/projectile/automatic/wt550)
	cost = 3500
	crate_name = "auto rifle crate"

/datum/supply_pack/security/armory/wt550ammo
	name = "WT-550 Rifle Ammo Crate"
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,)
	cost = 3000
	crate_name = "auto rifle ammo crate"

/////// Implants & etc

/datum/supply_pack/security/armory/mindshield
	name = "Mindshield Implants Crate"
	contains = list (/obj/item/weapon/storage/lockbox/mindshield)
	cost = 4000
	crate_name = "mindshield implant crate"

/datum/supply_pack/security/armory/trackingimp
	name = "Tracking Implants Crate"
	contains = list (/obj/item/weapon/storage/box/trackimp)
	cost = 2000
	crate_name = "tracking implant crate"

/datum/supply_pack/security/armory/chemimp
	name = "Chemical Implants Crate"
	contains = list (/obj/item/weapon/storage/box/chemimp)
	cost = 2000
	crate_name = "chemical implant crate"

/datum/supply_pack/security/armory/exileimp
	name = "Exile Implants Crate"
	contains = list (/obj/item/weapon/storage/box/exileimp)
	cost = 3000
	crate_name = "exile implant crate"

/datum/supply_pack/security/securitybarriers
	name = "Security Barriers Crate"
	contains = list(/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier,
					/obj/machinery/deployable/barrier)
	cost = 2000
	crate_name = "security barriers crate"

/datum/supply_pack/security/securityclothes
	name = "Security Clothing Crate"
	contains = list(/obj/item/clothing/under/rank/security/corp,
					/obj/item/clothing/under/rank/security/corp,
					/obj/item/clothing/head/soft/sec/corp,
					/obj/item/clothing/head/soft/sec/corp,
					/obj/item/clothing/under/rank/warden/corp,
					/obj/item/clothing/head/beret/sec/warden,
					/obj/item/clothing/under/rank/head_of_security/corp,
					/obj/item/clothing/head/HoS/beret)
	cost = 3000
	crate_name = "security clothing crate"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Engineering /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/engineering
	name = "HEADER"
	group = supply_engineer
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk"))
	crate_type = /obj/structure/closet/crate/engineering


/datum/supply_pack/engineering/fueltank
	name = "Fuel Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 800
	crate_type = /obj/structure/closet/crate/large
	crate_name = "fuel tank crate"

/datum/supply_pack/engineering/tools		//the most robust crate
	name = "Toolbox Crate"
	contains = list(/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/mechanical,
					/obj/item/weapon/storage/toolbox/mechanical,
					/obj/item/weapon/storage/toolbox/mechanical)
	cost = 1000
	crate_name = "electrical maintenance crate"

/datum/supply_pack/engineering/powergamermitts
	name = "Insulated Gloves Crate"
	contains = list(/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow)
	cost = 2000	//Made of pure-grade bullshittinium
	crate_name = "insulated gloves crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/power
	name = "Power Cell Crate"
	contains = list(/obj/item/weapon/stock_parts/cell/high,		//Changed to an extra high powercell because normal cells are useless
					/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high)
	cost = 1000
	crate_name = "electrical maintenance crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/engiequipment
	name = "Engineering Gear Crate"
	contains = list(/obj/item/weapon/storage/belt/utility,
					/obj/item/weapon/storage/belt/utility,
					/obj/item/weapon/storage/belt/utility,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat)
	cost = 1000
	crate_name = "engineering gear crate"

/datum/supply_pack/engineering/solar
	name = "Solar Pack Crate"
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly, // 21 Solar Assemblies. 1 Extra for the controller
					/obj/item/weapon/circuitboard/solar_control,
					/obj/item/weapon/tracker_electronics,
					/obj/item/weapon/paper/solar)
	cost = 2000
	crate_name = "solar pack crate"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/engine
	name = "Emitter Crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 1000
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "emitter crate"
	access = access_ce
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/engineering/engine/field_gen
	name = "Field Generator Crate"
	contains = list(/obj/machinery/field/generator,
					/obj/machinery/field/generator)
	cost = 1000
	crate_name = "field generator crate"

/datum/supply_pack/engineering/engine/sing_gen
	name = "Singularity Generator Crate"
	contains = list(/obj/machinery/the_singularitygen)
	cost = 1000
	crate_name = "singularity generator crate"

/datum/supply_pack/engineering/engine/tesla
	name = "Energy Ball Generator Crate"
	contains = list(/obj/machinery/the_singularitygen/tesla)
	cost = 1000
	crate_name = "energy ball generator crate"

/datum/supply_pack/engineering/engine/coil
	name = "Tesla Coil Crate"
	contains = list(/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil)
	cost = 1000
	crate_name = "tesla coil crate"

/datum/supply_pack/engineering/engine/grounding
	name = "Grounding Rod Crate"
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	cost = 1000
	crate_name = "grounding rod crate"

/datum/supply_pack/engineering/engine/collector
	name = "Collector Crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	cost = 1000
	crate_name = "collector crate"

/datum/supply_pack/engineering/engine/PA
	name = "Particle Accelerator Crate"
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	cost = 2500
	crate_name = "particle accelerator crate"

/datum/supply_pack/engineering/engine/spacesuit
	name = "Space Suit Crate"
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	cost = 3000
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "space suit crate"
	access = access_eva

/datum/supply_pack/engineering/inflatable
	name = "Inflatable barriers Crate"
	contains = list(/obj/item/weapon/storage/briefcase/inflatable,
					/obj/item/weapon/storage/briefcase/inflatable,
					/obj/item/weapon/storage/briefcase/inflatable)
	cost = 2000
	crate_name = "inflatable barrier crate"

/datum/supply_pack/engineering/engine/supermatter_shard
	name = "Supermatter Shard Crate"
	contains = list(/obj/machinery/power/supermatter_shard)
	cost = 5000 //So cargo thinks twice before killing themselves with it
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "supermatter shard crate"
	access = access_ce

/datum/supply_pack/engineering/engine/teg
	name = "Thermo-Electric Generator Crate"
	contains = list(
		/obj/machinery/power/generator,
		/obj/item/pipe/circulator,
		/obj/item/pipe/circulator)
	cost = 2500
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "thermo-electric generator crate"
	access = access_ce
	announce_beacons = list("Engineering" = list("Chief Engineer's Desk", "Atmospherics"))

/datum/supply_pack/engineering/conveyor
	name = "Conveyor Assembly Crate"
	contains = list(/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_switch_construct,
					/obj/item/weapon/paper/conveyor)
	cost = 1500
	crate_name = "conveyor assembly crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Medical /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/medical
	name = "HEADER"
	crate_type = /obj/structure/closet/crate/medical
	group = supply_medical
	announce_beacons = list("Medbay" = list("Medbay", "Chief Medical Officer's Desk"), "Security" = list("Brig Medbay"))


/datum/supply_pack/medical/supplies
	name = "Medical Supplies Crate"
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/charcoal,
					/obj/item/weapon/reagent_containers/glass/bottle/charcoal,
					/obj/item/weapon/reagent_containers/glass/bottle/epinephrine,
					/obj/item/weapon/reagent_containers/glass/bottle/epinephrine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/morphine,
					/obj/item/weapon/reagent_containers/glass/bottle/toxin,
					/obj/item/weapon/reagent_containers/glass/bottle/toxin,
					/obj/item/weapon/reagent_containers/glass/beaker/large,
					/obj/item/weapon/reagent_containers/glass/beaker/large,
					/obj/item/stack/medical/bruise_pack,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/storage/box/syringes,
				    /obj/item/weapon/storage/box/bodybags)
	cost = 2000
	crate_type = /obj/structure/closet/crate/medical
	crate_name = "medical supplies crate"

/datum/supply_pack/medical/firstaid
	name = "First Aid Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular)
	cost = 1000
	crate_name = "first aid kits crate"

/datum/supply_pack/medical/firstaidadv
	name = "Advanced First Aid Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/adv,
					/obj/item/weapon/storage/firstaid/adv,
					/obj/item/weapon/storage/firstaid/adv,
					/obj/item/weapon/storage/firstaid/adv)
	cost = 1000
	crate_name = "advanced first aid kits crate"

/datum/supply_pack/medical/firstaibrute
	name = "Brute Treatment Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/brute,
					/obj/item/weapon/storage/firstaid/brute)
	cost = 1000
	crate_name = "brute first aid kits crate"

/datum/supply_pack/medical/firstaidburns
	name = "Burns Treatment Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/fire)
	cost = 1000
	crate_name = "fire first aid kits crate"

/datum/supply_pack/medical/firstaidtoxins
	name = "Toxin Treatment Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/toxin)
	cost = 1000
	crate_name = "toxin first aid kits crate"

/datum/supply_pack/medical/firstaidoxygen
	name = "Oxygen Treatment Kits Crate"
	contains = list(/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/o2)
	cost = 1000
	crate_name = "oxygen first aid kits crate"

/datum/supply_pack/medical/virus
	name = "Virus Crate"
	contains = list(/obj/item/weapon/reagent_containers/glass/bottle/flu_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/cold,
					/obj/item/weapon/reagent_containers/glass/bottle/epiglottis_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/liver_enhance_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/weapon/reagent_containers/glass/bottle/magnitis,
					/obj/item/weapon/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/weapon/reagent_containers/glass/bottle/brainrot,
					/obj/item/weapon/reagent_containers/glass/bottle/hullucigen_virion,
					/obj/item/weapon/reagent_containers/glass/bottle/anxiety,
					/obj/item/weapon/reagent_containers/glass/bottle/beesease,
					/obj/item/weapon/storage/box/syringes,
					/obj/item/weapon/storage/box/beakers,
					/obj/item/weapon/reagent_containers/glass/bottle/mutagen)
	cost = 2500
	crate_type = /obj/structure/closet/crate/secure/plasma
	crate_name = "virus crate"
	access = access_cmo
	announce_beacons = list("Medbay" = list("Virology", "Chief Medical Officer's Desk"))


/datum/supply_pack/medical/bloodpacks
	name = "Blood Pack Variety Crate"
	contains = list(/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/empty,
					/obj/item/weapon/reagent_containers/blood/APlus,
					/obj/item/weapon/reagent_containers/blood/AMinus,
					/obj/item/weapon/reagent_containers/blood/BPlus,
					/obj/item/weapon/reagent_containers/blood/BMinus,
					/obj/item/weapon/reagent_containers/blood/OPlus,
					/obj/item/weapon/reagent_containers/blood/OMinus)
	cost = 3500
	crate_type = /obj/structure/closet/crate/freezer
	crate_name = "blood pack crate"

/datum/supply_pack/medical/iv_drip
	name = "IV Drip Crate"
	contains = list(/obj/machinery/iv_drip)
	cost = 3000
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "IV drip crate"
	access = access_cmo

/datum/supply_pack/medical/surgery
	name = "Surgery Crate"
	contains = list(/obj/item/weapon/cautery,
					/obj/item/weapon/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/weapon/tank/anesthetic,
					/obj/item/weapon/FixOVein,
					/obj/item/weapon/hemostat,
					/obj/item/weapon/scalpel,
					/obj/item/weapon/bonegel,
					/obj/item/weapon/retractor,
					/obj/item/weapon/bonesetter,
					/obj/item/weapon/circular_saw)
	cost = 2500
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "surgery crate"
	access = access_medical


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Science /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/science
	name = "HEADER"
	group = supply_science
	announce_beacons = list("Research Division" = list("Science", "Research Director's Desk"))
	crate_type = /obj/structure/closet/crate/sci

/datum/supply_pack/science/robotics
	name = "Robotics Assembly Crate"
	contains = list(/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/box/flashes,
					/obj/item/weapon/stock_parts/cell/high,
					/obj/item/weapon/stock_parts/cell/high)
	cost = 1000
	crate_type = /obj/structure/closet/crate/secure/scisec
	crate_name = "robotics assembly crate"
	access = access_robotics
	announce_beacons = list("Research Division" = list("Robotics", "Research Director's Desk"))


/datum/supply_pack/science/robotics/mecha_ripley
	name = "Circuit Crate (Ripley APLU)"
	contains = list(/obj/item/weapon/book/manual/ripley_build_and_repair,
					/obj/item/weapon/circuitboard/mecha/ripley/main, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/ripley/peripherals) //TEMPORARY due to lack of circuitboard printer
	cost = 3000
	crate_name = "\improper APLU \"Ripley\" circuit crate"

/datum/supply_pack/science/robotics/mecha_odysseus
	name = "Circuit Crate (Odysseus)"
	contains = list(/obj/item/weapon/circuitboard/mecha/odysseus/peripherals, //TEMPORARY due to lack of circuitboard printer
					/obj/item/weapon/circuitboard/mecha/odysseus/main) //TEMPORARY due to lack of circuitboard printer
	cost = 2500
	crate_name = "\improper \"Odysseus\" circuit crate"

/datum/supply_pack/science/plasma
	name = "Plasma Assembly Crate"
	contains = list(/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/weapon/tank/plasma,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer)
	cost = 1000
	crate_type = /obj/structure/closet/crate/secure/plasma
	crate_name = "plasma assembly crate"
	access = access_tox_storage
	group = supply_science

/datum/supply_pack/science/shieldwalls
	name = "Shield Generators Crate"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	cost = 2000
	crate_type = /obj/structure/closet/crate/secure/scisec
	crate_name = "shield generators crate"
	access = access_teleporter


/datum/supply_pack/science/transfer_valves
	name = "Tank Transfer Valves Crate"
	contains = list(/obj/item/device/transfer_valve,
					/obj/item/device/transfer_valve)
	cost = 6000
	crate_type = /obj/structure/closet/crate/secure/scisec
	crate_name = "tank transfer valves crate"
	access = access_rd

/datum/supply_pack/science/prototype
	name = "Machine Prototype Crate"
	contains = list(/obj/item/device/machineprototype)
	cost = 8000
	crate_type = /obj/structure/closet/crate/secure/scisec
	crate_name = "machine prototype crate"
	access = access_research

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Organic /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/organic
	name = "HEADER"
	group = supply_organic
	crate_type = /obj/structure/closet/crate/freezer


/datum/supply_pack/organic/food
	name = "Food Crate"
	contains = list(/obj/item/weapon/reagent_containers/food/condiment/flour,
					/obj/item/weapon/reagent_containers/food/condiment/rice,
					/obj/item/weapon/reagent_containers/food/condiment/milk,
					/obj/item/weapon/reagent_containers/food/condiment/soymilk,
					/obj/item/weapon/reagent_containers/food/condiment/saltshaker,
					/obj/item/weapon/reagent_containers/food/condiment/peppermill,
					/obj/item/weapon/kitchen/rollingpin,
					/obj/item/weapon/storage/fancy/egg_box,
					/obj/item/weapon/reagent_containers/food/condiment/enzyme,
					/obj/item/weapon/reagent_containers/food/condiment/sugar,
					/obj/item/weapon/reagent_containers/food/snacks/meat/monkey,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	cost = 1000
	crate_name = "food crate"
	announce_beacons = list("Kitchen" = list("Kitchen"))

/datum/supply_pack/organic/pizza
	name = "Pizza Crate"
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable,
					/obj/item/pizzabox/hawaiian)
	cost = 6000
	crate_name = "Pizza crate"

/datum/supply_pack/organic/monkey
	name = "Monkey Crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes)
	cost = 2000
	crate_name = "monkey crate"

/datum/supply_pack/organic/farwa
	name = "Farwa Crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/farwacubes)
	cost = 2000
	crate_name = "farwa crate"


/datum/supply_pack/organic/wolpin
	name = "Wolpin Crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/wolpincubes)
	cost = 2000
	crate_name = "wolpin crate"


/datum/supply_pack/organic/skrell
	name = "Neaera Crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/neaeracubes)
	cost = 2000
	crate_name = "neaera crate"

/datum/supply_pack/organic/stok
	name = "Stok Crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes/stokcubes)
	cost = 2000
	crate_name = "stok crate"

/datum/supply_pack/organic/party
	name = "Party Equipment Crate"
	contains = list(/obj/item/weapon/storage/box/drinkingglasses,
					/obj/item/weapon/reagent_containers/food/drinks/shaker,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/patron,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/weapon/reagent_containers/food/drinks/cans/ale,
					/obj/item/weapon/reagent_containers/food/drinks/cans/ale,
					/obj/item/weapon/reagent_containers/food/drinks/cans/beer,
					/obj/item/weapon/reagent_containers/food/drinks/cans/beer,
					/obj/item/weapon/reagent_containers/food/drinks/cans/beer,
					/obj/item/weapon/reagent_containers/food/drinks/cans/beer,
					/obj/item/weapon/grenade/confetti,
					/obj/item/weapon/grenade/confetti)
	cost = 2000
	crate_name = "party equipment"
	announce_beacons = list("Bar" = list("Bar"))

//////// livestock
/datum/supply_pack/organic/critter
	crate_type = /obj/structure/closet/crate/critter

/datum/supply_pack/organic/critter/cow
	name = "Cow Crate"
	cost = 3000
	contains = list(/mob/living/simple_animal/cow)
	crate_name = "cow crate"

/datum/supply_pack/organic/critter/goat
	name = "Goat Crate"
	cost = 2500
	contains = list(/mob/living/simple_animal/hostile/retaliate/goat)
	crate_name = "goat crate"

/datum/supply_pack/organic/critter/chicken
	name = "Chicken Crate"
	cost = 2000
	contains = list(/mob/living/simple_animal/chick)
	crate_name = "chicken crate"

/datum/supply_pack/organic/critter/chicken/generate()
	. = ..()
	for(var/i in 1 to rand(1, 3))
		new /mob/living/simple_animal/chick(.)

/datum/supply_pack/organic/critter/turkey
	name = "Turkey Crate"
	cost = 2000
	contains = list(/mob/living/simple_animal/turkey)
	crate_name = "turkey crate"

/datum/supply_pack/organic/critter/corgi
	name = "Corgi Crate"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/corgi,
					/obj/item/clothing/accessory/petcollar)
	crate_name = "corgi crate"

/datum/supply_pack/organic/critter/corgi/generate()
	. = ..()
	if(prob(50))
		var/mob/living/simple_animal/pet/corgi/D = locate() in .
		qdel(D)
		new /mob/living/simple_animal/pet/corgi/Lisa(.)

/datum/supply_pack/organic/critter/cat
	name = "Cat Crate"
	cost = 5000 //Cats are worth as much as corgis.
	contains = list(/mob/living/simple_animal/pet/cat,
				/obj/item/clothing/accessory/petcollar)
	crate_name = "cat crate"

/datum/supply_pack/organic/critter/cat/generate()
	. = ..()
	if(prob(50))
		var/mob/living/simple_animal/pet/cat/C = locate() in .
		qdel(C)
		new /mob/living/simple_animal/pet/cat/Proc(.)

/datum/supply_pack/organic/critter/pug
	name = "Pug Crate"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/pug,
				/obj/item/clothing/accessory/petcollar)
	crate_name = "pug crate"

/datum/supply_pack/organic/critter/fox
	name = "Fox Crate"
	cost = 5500 //Foxes are cool.
	contains = list(/mob/living/simple_animal/pet/fox,
			/obj/item/clothing/accessory/petcollar)
	crate_name = "fox crate"

/datum/supply_pack/organic/critter/butterfly
	name = "Butterflies Crate"
	cost = 5000
	contains = list(/mob/living/simple_animal/butterfly)
	crate_name = "butterflies crate"
	contraband = 1

/datum/supply_pack/organic/critter/butterfly/generate()
	. = ..()
	for(var/i in 1 to 49)
		new /mob/living/simple_animal/butterfly(.)

/datum/supply_pack/organic/critter/deer
	name = "Deer Crate"
	cost = 5600 //Deer are best.
	contains = list(/mob/living/simple_animal/deer)
	crate_name = "deer crate"

////// hippy gear

/datum/supply_pack/organic/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/spray/plantbgone,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/reagent_containers/glass/bottle/ammonia,
					/obj/item/weapon/hatchet,
					/obj/item/weapon/cultivator,
					/obj/item/device/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron) // Updated with new things
	cost = 1500
	crate_type = /obj/structure/closet/crate/hydroponics
	crate_name = "hydroponics crate"
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_pack/misc/hydroponics/hydrotank
	name = "Hydroponics Watertank Crate"
	contains = list(/obj/item/weapon/watertank)
	cost = 1000
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "hydroponics watertank crate"
	access = access_hydroponics
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_pack/organic/hydroponics/seeds
	name = "Seeds Crate"
	contains = list(/obj/item/seeds/chili,
					/obj/item/seeds/berry,
					/obj/item/seeds/corn,
					/obj/item/seeds/eggplant,
					/obj/item/seeds/tomato,
					/obj/item/seeds/soya,
					/obj/item/seeds/wheat,
					/obj/item/seeds/wheat/rice,
					/obj/item/seeds/carrot,
					/obj/item/seeds/sunflower,
					/obj/item/seeds/chanter,
					/obj/item/seeds/potato,
					/obj/item/seeds/sugarcane)
	cost = 1000
	crate_name = "seeds crate"

/datum/supply_pack/organic/hydroponics/exoticseeds
	name = "Exotic Seeds Crate"
	contains = list(/obj/item/seeds/nettle,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/nymph,
					/obj/item/seeds/nymph,
					/obj/item/seeds/nymph,
					/obj/item/seeds/plump,
					/obj/item/seeds/liberty,
					/obj/item/seeds/amanita,
					/obj/item/seeds/reishi,
					/obj/item/seeds/banana,
					/obj/item/seeds/eggplant/eggy,
					/obj/item/seeds/random,
					/obj/item/seeds/random)
	cost = 1500
	crate_name = "exotic seeds crate"

/datum/supply_pack/organic/hydroponics/beekeeping_fullkit
	name = "Beekeeping Starter Kit"
	contains = list(/obj/structure/beebox,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/queen_bee/bought,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	cost = 1500
	crate_name = "beekeeping starter kit"

/datum/supply_pack/organic/hydroponics/beekeeping_suits
	name = "2 Beekeeper suits"
	contains = list(/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	cost = 1000
	crate_name = "beekeeper suits"

//Bottler
/datum/supply_pack/organic/bottler
	name = "Brewing Buddy Bottler Unit"
	contains = list(/obj/machinery/bottler,
					/obj/item/weapon/wrench)
	cost = 3500
	crate_name = "bottler crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Materials ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/materials
	name = "HEADER"
	group = supply_materials
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk", "Atmospherics"))


/datum/supply_pack/materials/metal50
	name = "50 Metal Sheets Crate"
	contains = list(/obj/item/stack/sheet/metal/fifty)
	cost = 1000
	crate_name = "metal sheets crate"

/datum/supply_pack/materials/plasteel20
	name = "20 Plasteel Sheets Crate"
	contains = list(/obj/item/stack/sheet/plasteel/twenty)
	cost = 3000
	crate_name = "plasteel sheets crate"

/datum/supply_pack/materials/plasteel50
	name = "50 Plasteel Sheets Crate"
	contains = list(/obj/item/stack/sheet/plasteel/fifty)
	cost = 5000
	crate_name = "plasteel sheets crate"

/datum/supply_pack/materials/glass50
	name = "50 Glass Sheets Crate"
	contains = list(/obj/item/stack/sheet/glass/fifty)
	cost = 1000
	crate_name = "glass sheets crate"

/datum/supply_pack/materials/wood30
	name = "30 Wood Planks Crate"
	contains = list(/obj/item/stack/sheet/wood/thirty)
	cost = 1500
	crate_name = "wood planks crate"

/datum/supply_pack/materials/cardboard50
	name = "50 Cardboard Sheets Crate"
	contains = list(/obj/item/stack/sheet/cardboard/fifty)
	cost = 1000
	crate_name = "cardboard sheets crate"

/datum/supply_pack/materials/sandstone30
	name = "30 Sandstone Blocks Crate"
	contains = list(/obj/item/stack/sheet/mineral/sandstone/thirty)
	cost = 2000
	crate_name = "sandstone blocks crate"


/datum/supply_pack/materials/plastic30
	name = "30 Plastic Sheets Crate"
	contains = list(/obj/item/stack/sheet/plastic/thirty)
	cost = 2500
	crate_name = "plastic sheets crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/misc
	name = "HEADER"
	group = supply_misc

/datum/supply_pack/misc/mule
	name = "MULEbot Crate"
	contains = list(/mob/living/simple_animal/bot/mulebot)
	cost = 2000
	crate_type = /obj/structure/closet/crate/large/mule
	crate_name = "\improper MULEbot crate"

/datum/supply_pack/misc/watertank
	name = "Water Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 800
	crate_type = /obj/structure/closet/crate/large
	crate_name = "water tank crate"

/datum/supply_pack/misc/hightank
	name = "High-Capacity Water Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/watertank/high)
	cost = 1200
	crate_type = /obj/structure/closet/crate/large
	crate_name = "high-capacity water tank crate"

/datum/supply_pack/misc/lasertag
	name = "Laser Tag Crate"
	contains = list(/obj/item/weapon/gun/energy/laser/redtag,
					/obj/item/weapon/gun/energy/laser/redtag,
					/obj/item/weapon/gun/energy/laser/redtag,
					/obj/item/weapon/gun/energy/laser/bluetag,
					/obj/item/weapon/gun/energy/laser/bluetag,
					/obj/item/weapon/gun/energy/laser/bluetag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm)
	cost = 1500
	crate_name = "laser tag crate"

/datum/supply_pack/misc/religious_supplies
	name = "Religious Supplies Crate"
	contains = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/weapon/storage/bible/booze,
					/obj/item/weapon/storage/bible/booze,
					/obj/item/clothing/suit/hooded/chaplain_hoodie,
					/obj/item/clothing/suit/hooded/chaplain_hoodie)
	cost = 4000
	crate_name = "religious supplies crate"


///////////// Paper Work

/datum/supply_pack/misc/paper
	name = "Bureaucracy Crate"
	contains = list(/obj/structure/filingcabinet/chestdrawer,
					/obj/item/device/camera_film,
					/obj/item/weapon/hand_labeler,
					/obj/item/stack/tape_roll,
					/obj/item/weapon/paper_bin,
					/obj/item/weapon/pen,
					/obj/item/weapon/pen/blue,
					/obj/item/weapon/pen/red,
					/obj/item/weapon/stamp/denied,
					/obj/item/weapon/stamp/granted,
					/obj/item/weapon/folder/blue,
					/obj/item/weapon/folder/red,
					/obj/item/weapon/folder/yellow,
					/obj/item/weapon/clipboard,
					/obj/item/weapon/clipboard)
	cost = 1500
	crate_name = "bureaucracy crate"

/datum/supply_pack/misc/toner
	name = "Toner Cartridges Crate"
	contains = list(/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner,
					/obj/item/device/toner)
	cost = 1000
	crate_name = "toner cartridges crate"

/datum/supply_pack/misc/artscrafts
	name = "Arts and Crafts Supplies Crate"
	contains = list(/obj/item/weapon/storage/fancy/crayons,
	/obj/item/device/camera,
	/obj/item/device/camera_film,
	/obj/item/device/camera_film,
	/obj/item/weapon/storage/photo_album,
	/obj/item/stack/packageWrap,
	/obj/item/weapon/reagent_containers/glass/paint/red,
	/obj/item/weapon/reagent_containers/glass/paint/green,
	/obj/item/weapon/reagent_containers/glass/paint/blue,
	/obj/item/weapon/reagent_containers/glass/paint/yellow,
	/obj/item/weapon/reagent_containers/glass/paint/violet,
	/obj/item/weapon/reagent_containers/glass/paint/black,
	/obj/item/weapon/reagent_containers/glass/paint/white,
	/obj/item/weapon/reagent_containers/glass/paint/remover,
	/obj/item/weapon/poster/random_official,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper)
	cost = 1000
	crate_name = "arts and crafts crate"

/datum/supply_pack/misc/posters
	name = "Corporate Posters Crate"
	contains = list(/obj/item/weapon/poster/random_official,
					/obj/item/weapon/poster/random_official,
					/obj/item/weapon/poster/random_official,
					/obj/item/weapon/poster/random_official,
					/obj/item/weapon/poster/random_official)
	cost = 800
	crate_name = "corporate posters crate"

///////////// Janitor Supplies

/datum/supply_pack/misc/janitor
	name = "Janitorial Supplies Crate"
	contains = list(/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/mop,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/storage/bag/trash,
					/obj/item/weapon/reagent_containers/spray/cleaner,
					/obj/item/weapon/reagent_containers/glass/rag,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner)
	cost = 1000
	crate_name = "janitorial supplies crate"
	announce_beacons = list("Janitor" = list("Janitorial"))

/datum/supply_pack/misc/janitor/janicart
	name = "Janitorial Cart and Galoshes Crate"
	contains = list(/obj/structure/janitorialcart,
					/obj/item/clothing/shoes/galoshes)
	cost = 1000
	crate_type = /obj/structure/closet/crate/large
	crate_name = "janitorial cart crate"

/datum/supply_pack/misc/janitor/janitank
	name = "Janitor Watertank Backpack"
	contains = list(/obj/item/weapon/watertank/janitor)
	cost = 1000
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "janitor watertank crate"
	access = access_janitor

/datum/supply_pack/misc/janitor/lightbulbs
	name = "Replacement Lights Crate"
	contains = list(/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed)
	cost = 1000
	crate_name = "replacement lights crate"

/datum/supply_pack/misc/noslipfloor
	name = "High-traction Floor Tiles"
	contains = list(/obj/item/stack/tile/noslip/loaded)
	cost = 2000
	crate_name = "high-traction floor tiles"

///////////// Costumes

/datum/supply_pack/misc/costume
	name = "Standard Costume Crate"
	contains = list(/obj/item/weapon/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/clown,
					/obj/item/weapon/bikehorn,
					/obj/item/weapon/storage/backpack/mime,
					/obj/item/clothing/under/mime,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/gloves/color/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/suit/suspenders,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofbanana
					)
	cost = 1000
	crate_type = /obj/structure/closet/crate/secure
	crate_name = "standard costumes"
	access = access_theatre

/datum/supply_pack/misc/wizard
	name = "Wizard Costume Crate"
	contains = list(/obj/item/weapon/twohanded/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	cost = 2000
	crate_name = "wizard costume crate"

/datum/supply_pack/misc/mafia
	name = "Mafia Supply Crate"
	contains = list(/obj/item/clothing/suit/browntrenchcoat,
					/obj/item/clothing/suit/blacktrenchcoat,
					/obj/item/clothing/head/fedora/whitefedora,
					/obj/item/clothing/head/fedora/brownfedora,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/under/flappers,
					/obj/item/clothing/under/mafia,
					/obj/item/clothing/under/mafia/vest,
					/obj/item/clothing/under/mafia/white,
					/obj/item/clothing/under/mafia/sue,
					/obj/item/clothing/under/mafia/tan,
					/obj/item/weapon/gun/projectile/shotgun/toy/tommygun,
					/obj/item/weapon/gun/projectile/shotgun/toy/tommygun)
	cost = 1500
	crate_name = "mafia supply crate"

/datum/supply_pack/misc/randomised
	name = "Collectible Hats Crate"
	cost = 20000
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/crown/fancy,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/HoS,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	crate_name = "collectable hats crate! Brought to you by Bass.inc!"

/datum/supply_pack/misc/randomised/fill(obj/structure/closet/crate/C)
	var/list/L = contains.Copy()
	for(var/i in 1 to num_contained)
		var/item = pick_n_take(L)
		new item(C)

/datum/supply_pack/misc/randomised/printout()
	. = "Contains any [num_contained] of:"
	. += ..()


/datum/supply_pack/misc/foamforce
	name = "Foam Force Crate"
	contains = list(/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy,
					/obj/item/weapon/gun/projectile/shotgun/toy)
	cost = 1000
	crate_name = "foam force crate"

/datum/supply_pack/misc/foamforce/bonus
	name = "Foam Force Pistols Crate"
	contains = list(/obj/item/weapon/gun/projectile/automatic/toy/pistol,
					/obj/item/weapon/gun/projectile/automatic/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol)
	cost = 4000
	crate_name = "foam force pistols crate"
	contraband = 1

/datum/supply_pack/misc/bigband
	name = "Big band instrument collection"
	contains = list(/obj/item/device/instrument/violin,
					/obj/item/device/instrument/guitar,
					/obj/item/device/instrument/eguitar,
					/obj/item/device/instrument/glockenspiel,
					/obj/item/device/instrument/accordion,
					/obj/item/device/instrument/saxophone,
					/obj/item/device/instrument/trombone,
					/obj/item/device/instrument/recorder,
					/obj/item/device/instrument/harmonica,
					/obj/item/device/instrument/xylophone,
					/obj/structure/piano)
	cost = 5000
	crate_name = "Big band musical instruments collection"

/datum/supply_pack/misc/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/weapon/storage/pill_bottle/random_drug_bottle,
					/obj/item/weapon/poster/random_contraband,
					/obj/item/weapon/storage/fancy/cigarettes/dromedaryco,
					/obj/item/weapon/storage/fancy/cigarettes/cigpack_shadyjims)
	name = "Contraband Crate"
	cost = 3000
	crate_name = "crate"	//let's keep it subtle, eh?
	contraband = 1

/datum/supply_pack/misc/formalwear //This is a very classy crate.
	name = "Formal Wear Crate"
	contains = list(/obj/item/clothing/under/blacktango,
					/obj/item/clothing/under/assistantformal,
					/obj/item/clothing/under/assistantformal,
					/obj/item/clothing/under/lawyer/bluesuit,
					/obj/item/clothing/suit/storage/lawyer/bluejacket,
					/obj/item/clothing/under/lawyer/purpsuit,
					/obj/item/clothing/suit/storage/lawyer/purpjacket,
					/obj/item/clothing/under/lawyer/black,
					/obj/item/clothing/suit/storage/lawyer/blackjacket,
					/obj/item/clothing/accessory/waistcoat,
					/obj/item/clothing/accessory/blue,
					/obj/item/clothing/accessory/red,
					/obj/item/clothing/accessory/black,
					/obj/item/clothing/head/bowlerhat,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/head/flatcap,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/head/that,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/under/suit_jacket/charcoal,
					/obj/item/clothing/under/suit_jacket/navy,
					/obj/item/clothing/under/suit_jacket/burgundy,
					/obj/item/clothing/under/suit_jacket/checkered,
					/obj/item/clothing/under/suit_jacket/tan,
					/obj/item/weapon/lipstick/random)
	cost = 3000 //Lots of very expensive items. You gotta pay up to look good!
	crate_name = "formal-wear crate"

/datum/supply_pack/misc/teamcolors		//For team sports like space polo
	name = "Team Jerseys Crate"
	// 4 red jerseys, 4 blue jerseys, and 1 beach ball
	contains = list(/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/weapon/beach_ball)
	cost = 1500
	crate_name = "team jerseys crate"

/datum/supply_pack/misc/polo			//For space polo! Or horsehead Quiditch
	name = "Polo Supply Crate"
	// 6 brooms, 6 horse masks for the brooms, and 1 beach ball
	contains = list(/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/weapon/twohanded/staff/broom,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/weapon/beach_ball)
	cost = 2000
	crate_name = "polo supply crate"

///////////// Station Goals

/datum/supply_pack/misc/bsa
	name = "Bluespace Artillery Parts"
	cost = 15000
	special = TRUE
	contains = list(/obj/item/weapon/circuitboard/machine/bsa/front,
					/obj/item/weapon/circuitboard/machine/bsa/middle,
					/obj/item/weapon/circuitboard/machine/bsa/back,
					/obj/item/weapon/circuitboard/computer/bsa_control
					)
	crate_name = "bluespace artillery parts crate"

/datum/supply_pack/misc/dna_vault
	name = "DNA Vault Parts"
	cost = 12000
	special = TRUE
	contains = list(
					/obj/item/weapon/circuitboard/machine/dna_vault
					)
	crate_name = "dna vault parts crate"

/datum/supply_pack/misc/dna_probes
	name = "DNA Vault Samplers"
	cost = 3000
	special = TRUE
	contains = list(/obj/item/device/dna_probe,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe,
					/obj/item/device/dna_probe
					)
	crate_name = "dna samplers crate"


/datum/supply_pack/misc/shield_sat
	name = "Shield Generator Satellite"
	cost = 3000
	special = TRUE
	contains = list(
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield
					)
	crate_name = "shield sat crate"


/datum/supply_pack/misc/shield_sat_control
	name = "Shield System Control Board"
	cost = 5000
	special = TRUE
	contains = list(
					/obj/item/weapon/circuitboard/computer/sat_control
					)
	crate_name = "shield control board crate"

///////////// Bathroom Fixtures

/datum/supply_pack/misc/toilet
	name = "Lavatory Crate"
	cost = 1000
	contains = list(
					/obj/item/weapon/bathroom_parts,
					/obj/item/weapon/bathroom_parts/urinal
					)
	crate_name = "lavatory crate"

/datum/supply_pack/misc/hygiene
	name = "Hygiene Station Crate"
	cost = 1000
	contains = list(
					/obj/item/weapon/bathroom_parts/sink,
					/obj/item/mounted/shower
					)
	crate_name = "hygiene station crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Vending /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/vending
	name = "HEADER"
	group = supply_vend

/datum/supply_pack/vending/autodrobe
	name = "Autodrobe Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/autodrobe,
					/obj/item/weapon/vending_refill/autodrobe)
	cost = 1500
	crate_name = "autodrobe supply crate"

/datum/supply_pack/vending/clothes
	name = "Clothing Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/suitdispenser,
					/obj/item/weapon/vending_refill/shoedispenser,
					/obj/item/weapon/vending_refill/hatdispenser,
					/obj/item/weapon/vending_refill/clothing)
	cost = 1500
	crate_name = "clothing supply crate"

/datum/supply_pack/vending/pets
	name = "Pet Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/crittercare,
					/obj/item/weapon/vending_refill/crittercare,
					/obj/item/weapon/vending_refill/crittercare)
	cost = 1500
	crate_name = "pet supply crate"

/datum/supply_pack/vending/bar
	name = "Bar Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/boozeomat,
					/obj/item/weapon/vending_refill/boozeomat,
					/obj/item/weapon/vending_refill/boozeomat)
	cost = 1500
	crate_name = "bar supply crate"
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_pack/vending/coffee
	name = "Coffee Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/coffee,
					/obj/item/weapon/vending_refill/coffee,
					/obj/item/weapon/vending_refill/coffee)
	cost = 1500
	crate_name = "coffee supply crate"

/datum/supply_pack/vending/snack
	name = "Snack Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/snack,
					/obj/item/weapon/vending_refill/snack,
					/obj/item/weapon/vending_refill/snack)
	cost = 1500
	crate_name = "snacks supply crate"

/datum/supply_pack/vending/chinese
	name = "Chinese Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/chinese,
					/obj/item/weapon/vending_refill/chinese,
					/obj/item/weapon/vending_refill/chinese)
	cost = 1500
	crate_name = "chinese supply crate"

/datum/supply_pack/vending/cola
	name = "Softdrinks Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/cola,
					/obj/item/weapon/vending_refill/cola,
					/obj/item/weapon/vending_refill/cola)
	cost = 1500
	crate_name = "softdrinks supply crate"

/datum/supply_pack/vending/cigarette
	name = "Cigarette Supply Crate"
	contains = list(/obj/item/weapon/vending_refill/cigarette,
					/obj/item/weapon/vending_refill/cigarette,
					/obj/item/weapon/vending_refill/cigarette)
	cost = 1500
	crate_name = "cigarette supply crate"