class_name ColorHelper

static func average_color(col1:Color, col2:Color):
	var h
	var s
	var v
	var newColor : Color
	# case if hue values are closer to wrapping around than their average
	if abs(col1.h-col2.h) > 0.5:
		#add 1 to the smallest oh the hue values, and use that for average
		h = ((min(col1.h, col2.h)+1)-max(col1.h, col2.h)/2)+min(col1.h, col2.h)
		h -= floor(h)
	else:
		h = lerpf(col1.h, col2.h, 0.5)
	
	s = lerpf(col1.s, col2.s, 0.5)
	print(str(s) + " from: col1.s(" + str(col1.s) + ") col2.s(" + str(col2.s) + ")")
	v = lerpf(col1.v, col2.v, 0.5)
	print(str(v) + " from: col1.v(" + str(col1.v) + ") col2.v(" + str(col2.v) + ")")
	
	newColor = Color.from_hsv(h,s,v)
	return newColor
