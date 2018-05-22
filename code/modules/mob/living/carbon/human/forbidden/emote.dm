/*
 * EMOTES
 */

/mob/living/carbon/human/proc/actionEmote(mob/living/carbon/human/P, datum/forbidden/emote/emote)
	if(!istype(P) || !istype(emote) || !check_forbidden_cooldown() || !config.forbidden_active)
		return 0

	if(!emote.conditions(src, P))
		return 0

	click_CD = world.time + 10

	face_atom(P)

	emote.logAction(src, P)
	emote.showText(src, P)
	emote.doAction(src, P)

	return 1