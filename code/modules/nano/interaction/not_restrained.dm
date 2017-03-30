 /**
  * This state only checks if the user isn't incapacitated
 **/

/var/global/datum/topic_state/not_restrained_state/not_restrained_state = new()

/datum/topic_state/not_restrained_state/can_use_topic(src_object, mob/user)
	if(user.stat)
		return STATUS_CLOSE
	if(user.restrained())
		return STATUS_DISABLED
	return STATUS_INTERACTIVE