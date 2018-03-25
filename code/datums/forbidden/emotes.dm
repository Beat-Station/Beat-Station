/*
 *
 * EMOTE DECLARATION
 *
 */
var/global/list/forbidden_emotes = list()	// stores /datum/forbidden/action/emote indexed by name

/datum/forbidden/emote
	var/name

/datum/forbidden/emote/proc/actionButton(mob/living/carbon/human/H, mob/living/carbon/human/P)
	return

/datum/forbidden/emote/proc/conditions(mob/living/carbon/human/H, mob/living/carbon/human/P)
	if(get_dist(H, P) > 1)
		return -1
	if(H.incapacitated(ignore_lying = TRUE))
		return -1
	if(P == H)
		return -1
	return 1

	//	return -1 = button doesn't appears on UI
	//	return 0 = disabled button
	//	return 1 = clickable button

/datum/forbidden/emote/proc/showText(mob/living/carbon/human/H, mob/living/carbon/human/P, begins = 0)
	return

/datum/forbidden/emote/proc/logAction(mob/living/carbon/human/H, mob/living/carbon/human/P, text = null)
	if(text)
		add_logs(H, P, text)

/datum/forbidden/emote/proc/doAction(mob/living/carbon/human/H, mob/living/carbon/human/P, begins = 0)
	return

/*
 *
 * EMOTES
 *
 */

// Kiss
/datum/forbidden/emote/kiss
	name = "kiss"

/datum/forbidden/emote/kiss/actionButton(mob/living/carbon/human/H, mob/living/carbon/human/P)
	return "Kiss [P.gender == FEMALE ? "her" : "his"] lips"

/datum/forbidden/emote/kiss/conditions(mob/living/carbon/human/H, mob/living/carbon/human/P)
	. = ..(H, P)
	if(. != -1)
		if(!H.check_has_mouth() || !P.check_has_mouth())
			. = -1
		else if(!H.is_face_clean() || !P.is_face_clean())
			. = 0

/datum/forbidden/emote/kiss/showText(mob/living/carbon/human/H, mob/living/carbon/human/P)
	H.visible_message("<span class='erp'><b>[H]</b> kisses <b>[P]</b>.</span>")

/datum/forbidden/emote/kiss/logAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	..(H, P, "kissed")

/datum/forbidden/emote/kiss/doAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	H.pleasure += 1 * rand(0.9, 1.2)
	if(H.pleasure >= MAX_PLEASURE)
		H.cum(P, "floor")

	P.pleasure += 1 * rand(0.9, 1.2)
	if(P.pleasure >= MAX_PLEASURE)
		P.cum(H, "floor")
	..()


// Lick (tajaran kiss)
/datum/forbidden/emote/lick
	name = "lick"

/datum/forbidden/emote/lick/actionButton(mob/living/carbon/human/H, mob/living/carbon/human/P)
	return "Lick [P.gender == FEMALE ? "her" : "his"] lips"

/datum/forbidden/emote/lick/conditions(mob/living/carbon/human/H, mob/living/carbon/human/P)
	. = ..(H, P)
	if(. != -1)
		if(!H.check_has_mouth() || !P.check_has_mouth())
			. = -1
		else if(H.species.name != "Tajaran") // Only tajarans can lick other's lips
			. = -1
		else if(!H.is_face_clean() || !P.is_face_clean())
			. = 0

/datum/forbidden/emote/lick/showText(mob/living/carbon/human/H, mob/living/carbon/human/P)
	H.visible_message("<span class='erp'><b>[H]</b> licks [P]'s lips.</span>")

/datum/forbidden/emote/lick/logAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	..(H, P, "licked")

/datum/forbidden/emote/lick/doAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	H.pleasure += 1 * rand(0.9, 1.2)
	if(H.pleasure >= MAX_PLEASURE)
		H.cum(P, "floor")

	P.pleasure += 1 * rand(0.9, 1.2)
	if(P.pleasure >= MAX_PLEASURE)
		P.cum(H, "floor")
	..()


// French Kiss
/datum/forbidden/emote/frenchkiss
	name = "french-kiss"

/datum/forbidden/emote/frenchkiss/actionButton(mob/living/carbon/human/H, mob/living/carbon/human/P)
	return "Give [P.gender == FEMALE ? "her" : "him"] a french kiss"

/datum/forbidden/emote/frenchkiss/conditions(mob/living/carbon/human/H, mob/living/carbon/human/P)
	. = ..(H, P)
	if(. != -1)
		if(!H.check_has_mouth() || !P.check_has_mouth())
			. = -1
		else if(!H.is_face_clean() || !P.is_face_clean())
			. = 0

/datum/forbidden/emote/frenchkiss/showText(mob/living/carbon/human/H, mob/living/carbon/human/P)
	H.visible_message("<span class='erp'><b>[H]</b> gives <b>[P]</b> a french kiss.</span>")

/datum/forbidden/emote/frenchkiss/logAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	..(H, P, "french-kissed")

/datum/forbidden/emote/frenchkiss/doAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	H.pleasure += 2 * rand(0.9, 1.2)
	if(H.pleasure >= MAX_PLEASURE)
		H.cum(P, "floor")

	P.pleasure += 2 * rand(0.9, 1.2)
	if(P.pleasure >= MAX_PLEASURE)
		P.cum(H, "floor")

	..()


// Cheek Kiss
/datum/forbidden/emote/cheekkiss
	name = "cheek-kiss"

/datum/forbidden/emote/cheekkiss/actionButton(mob/living/carbon/human/H, mob/living/carbon/human/P)
	return "Give [P.gender == FEMALE ? "her" : "him"] a cheek kiss"

/datum/forbidden/emote/cheekkiss/conditions(mob/living/carbon/human/H, mob/living/carbon/human/P)
	. = ..(H, P)
	if(. != -1)
		if(!H.check_has_mouth() || !P.check_has_mouth())
			. = -1
		else if(!H.is_face_clean() || !P.is_face_clean())
			. = 0

/datum/forbidden/emote/cheekkiss/showText(mob/living/carbon/human/H, mob/living/carbon/human/P)
	H.visible_message("<span class='erp'><b>[H]</b> gives <b>[P]</b> a cheek kiss.</span>")

/datum/forbidden/emote/cheekkiss/logAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	..(H, P, "cheek-kissed")

/datum/forbidden/emote/cheekkiss/doAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	..()


// Slap that ass!
/datum/forbidden/emote/assslap
	name = "ass-slap"

/datum/forbidden/emote/assslap/actionButton(mob/living/carbon/human/H, mob/living/carbon/human/P)
	return "Slap [P.gender == FEMALE ? "her" : "his"] ass"

/datum/forbidden/emote/assslap/conditions(mob/living/carbon/human/H, mob/living/carbon/human/P)
	. = ..(H, P)
	if(. != -1)
		if(!H.has_hands() || !P.species.anus)
			. = -1

/datum/forbidden/emote/assslap/showText(mob/living/carbon/human/H, mob/living/carbon/human/P)
	H.visible_message("<span class='erp'><b>[H]</b> slaps [P]'s ass.</span>")

/datum/forbidden/emote/assslap/logAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	..(H, P, "ass-slapped")

/datum/forbidden/emote/assslap/doAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	playsound(H.loc, 'sound/effects/snap.ogg', 50, 1)
	..()


// Aquela sacaneada
/datum/forbidden/emote/boobgrab
	name = "boob-grab"

/datum/forbidden/emote/boobgrab/actionButton(mob/living/carbon/human/H, mob/living/carbon/human/P)
	if(prob(1))
		return "Dar aquela sacaneada"

	return "Grab her boobs"

/datum/forbidden/emote/boobgrab/conditions(mob/living/carbon/human/H, mob/living/carbon/human/P)
	. = ..(H, P)
	if(. != -1)
		if(!H.has_hands() || !P.has_vagina())
			. = -1

/datum/forbidden/emote/boobgrab/showText(mob/living/carbon/human/H, mob/living/carbon/human/P)
	H.visible_message("<span class='erp'><b>[H]</b> grabs [P]'s boobs.</span>")

/datum/forbidden/emote/boobgrab/logAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	..(H, P, "boob-grabbed")

/datum/forbidden/emote/boobgrab/doAction(mob/living/carbon/human/H, mob/living/carbon/human/P)
	P.pleasure += 1 * rand(0.9, 1.2)
	if(P.pleasure >= MAX_PLEASURE)
		P.cum(H, "floor")
	..()
