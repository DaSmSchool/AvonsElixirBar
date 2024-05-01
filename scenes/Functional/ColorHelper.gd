class_name ColorHelper

static func average_color(col1:Color, col2:Color):
	var newColor : Color = Color()
	if abs(col1.h-col2.h) > 0.5:
		#add 1 to the smallest oh the hue values, and use that for average
		newColor.h = ((min(col1.h, col2.h)+1)-max(col1.h, col2.h)/2)+min(col1.h, col2.h)
		newColor.h -= floor(newColor.h)
	
	newColor.s = lerpf(col1.s, col2.s, 0.5)
	newColor.v = lerpf(col1.v, col2.v, 0.5)
	
	return newColor
