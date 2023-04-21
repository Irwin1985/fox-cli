# standard libraries
load "stdlib.ring"
load "stdlibcore.ring"
load "consolecolors.ring"
load "jsonlib.ring"
load "internetlib.ring"

# custom libraries
load "globals.ring"
load "console_app.ring"
load "vb_script.ring"
load "builder.ring"
load "printer.ring"


#
# Evaluates the entered commands
#
func runCommands
	aCommands = getCommands()
	nLen = len(aCommands)

	if nLen = 0 # no commands passed
		printHelp()
		return
	ok
	
	cCommand  = aCommands[1]
	cProjectName = ""
	if len(aCommands) >= 2
		cProjectName = aCommands[2]
	ok

	aArgs = []
	if len(aCommands) > 2
		for i=3 to len(aCommands)
			add(aArgs, aCommands[i])
		next
	ok

	# Dispatch commands
	switch cCommand
	on "new"
		validateCommand(len(aArgs))
		goBuilder.createOrInitProject(cProjectName, false)

	on "run"
		updateProjectVariables()	
		goBuilder.runProject(cProjectName, aArgs)

	on "build"
		updateProjectVariables()
		validateCommand(len(aArgs))
		goBuilder.buildProject()

	on "init"
		validateCommand(len(aArgs))
		cProjectName = getLastFolderName(currentDir())
		goBuilder.createOrInitProject(cProjectName, true)

	else
		goPrinter.print(CC_FG_RED, "Unknown command ")
		goPrinter.println(CC_FG_DARK_YELLOW, cCommand)
		bye
	off


#
# Validate 2 arguments
#
func validateCommand tnLen
	if tnLen > 0
		goPrinter.println(CC_FG_RED, "Unexpected arguments...")
		printHelp()
		bye
	ok


#
# Parses the command line arguments
#
func getCommands
	aCommands = []
	aArgs = sysargv
	for i = 2 to len(aArgs)
		add(aCommands, aArgs[i])
	next

	return aCommands


#
# prints the commands information in the screen
#
func printHelp
	goPrinter.println(CC_FG_GRAY, copy("=", 75))
	goPrinter.println(CC_FG_GRAY, "Fox CLI app for Visual Foxpro projects management (fox) v" + _VERSION)
	goPrinter.println(CC_FG_GRAY, "2023, Irwin Rodriguez <rodriguez.irwin@gmail.com>")
	goPrinter.println(CC_FG_GRAY, copy("=", 75))
	goPrinter.println(CC_FG_GRAY, "Usage    : fox [command]")
	goPrinter.print(CC_FG_GRAY, "Command  : ")
	goPrinter.println(CC_FG_DARK_YELLOW, "new <project name>")
	goPrinter.print(CC_FG_GRAY, "Command  : ")
	goPrinter.println(CC_FG_DARK_YELLOW, "run <project name>")
	goPrinter.print(CC_FG_GRAY, "Command  : ")
	goPrinter.println(CC_FG_DARK_YELLOW, "build <project name>")
	goPrinter.println(CC_FG_GRAY, copy("=", 75))


#
# gets the generated executable file name
#
func getExecutableName
	cOutput = _PROJECT_OUTPUT
	cExt = ""
	if _PROJECT_APPLICATION = "4"
		cExt = ".app"
	but _PROJECT_APPLICATION = "5" or _PROJECT_APPLICATION = "6"
		cExt = ".dll"
	else
		cExt = ".exe"
	ok

	if lower(right(cOutput, 4)) != cExt
		cOutput += cExt
	ok
	return _PROJECT_ROOT + "\bin\" + cOutput


#
# Check if the file exists
#
func checkFile tcFilePath
	if not fExists(tcFilePath)
		goPrinter.print(CC_FG_RED, "File does not exist: ")
		? tcFilePath
		bye
	ok


#
# Get the last folder name in a given directory.
#
func getLastFolderName tcDirectory
	lcDir = tcDirectory
	if right(lcDir, 1) = "\"
		lcDir = substr(lcDir, 1, len(lcDir)-1)
	ok
	
	lcName = ""
	
	for i in lcDir
		if i = "\"
			lcName = ""
		else
			lcName += i
		ok
	next
	
	return lcName
