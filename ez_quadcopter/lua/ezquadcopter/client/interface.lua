hook.Add("VGUIMousePressed", "ezquadcopter_click_sound_VGUIMousePressed", function(_, mouseCode)
	if (mouseCode == MOUSE_FIRST) and easzy.quadcopter.interface and easzy.quadcopter.config.clickSound then
		surface.PlaySound("easzy/ez_quadcopter/click.wav")
	end
end)
