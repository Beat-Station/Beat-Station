/obj/screen/combo
	name = "combo"
	icon_state = ""
	mouse_opacity = 0
	layer = 18
	var/cooldown = 0

/obj/screen/combo/update_icon(streak = "", num = 100)
	overlays.Cut()
	icon_state = ""
	cooldown = world.time + num
	var/i = 1
	if(streak && length(streak))
		icon_state = "combo"
		while(i <= length(streak))
			var/n_letter = copytext(streak, i, i + 1)//copies text from a certain distance. In this case, only one letter at a time.
			var/image/img = image(icon, src, "combo_[n_letter]")
			if(img)
				i++
				var/spacing = 16
				img.pixel_x = -16 - spacing * length(streak) / 2 + spacing * i
				overlays += img