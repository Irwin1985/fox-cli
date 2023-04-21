class Printer
	#
	# Prints 'Operation completed successfully' on the screen
	#
	func printOperationCompleted
		cMsg = "The operation completed successfully."
		? cc_print(CC_FG_GREEN, cMsg)


	func print tnColor, tcText
		cc_print(tnColor, tcText)


	func println tnColor, tcText
		? cc_print(tnColor, tcText)
