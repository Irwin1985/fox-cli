class Builder
	#
	# create or initialize a project
	#
	func createOrInitProject tcProjectName, tbInit
		cCurDir = currentDir()
		createProjectStructure(tcProjectName, tbInit)
		createBuildFile(tcProjectName)
		updateProjectVariables() # refresh global variables
		createFoxFiles()
		chDir(cCurDir)
		goPrinter.printOperationCompleted()


	#
	# run an existing project
	#
	func runProject tcProjectName, taArgs
		# we need to build the project first
		if buildProject()
			cExecutable = getExecutableName()		
			if not fExists(cExecutable)
				goPrinter.print(CC_FG_RED, "Executable not found: ")
				? cExecutable
				return
			ok
			# detructure arguments
			cArgs = ""
			for arg in taArgs
				cArgs += " " + arg
			next
			# run the executable
			goPrinter.println(CC_FG_YELLOW, "Running executable...")
			system(cExecutable + " " + cArgs)
		ok
	

	#
	# builds the project
	#
	func buildProject	
		goPrinter.print(CC_FG_YELLOW, "Building project: ")
		? _PROJECT_NAME
		
		cExecutable = _PROJECT_ROOT + "\bin\" + _PROJECT_OUTPUT
	
	 	loVBScript = new VBScript
		loVBScript.createAndBuildFiles()

		# delete files
		
	
	
		return fexists(cExecutable)


	#
	# Create the project structure (folder / subfolder)
	#
	func createProjectStructure tcProjectName, tbInit
		lcRoot = currentDir()
		if not tbInit			
			lcRoot += "\" + tcProjectName
		ok
		laFolders = [
			lcRoot,
			lcRoot + "\.meta",
			lcRoot + "\bin",
			lcRoot + "\classes",
			lcRoot + "\code",
			lcRoot + "\data",
			lcRoot + "\documents",
			lcRoot + "\other"
		]
		
		laSubFolders = [
			[
				lcRoot + "\.meta"
			],
			[
				lcRoot + "\code",
				lcRoot + "\code\app",
				lcRoot + "\code\lib",
				lcRoot + "\code\programs"
			],
			[
				lcRoot + "\documents",
				lcRoot + "\documents\forms",
				lcRoot + "\documents\labels",
				lcRoot + "\documents\reports"
			],
			[
				lcRoot + "\other",
				lcRoot + "\other\menu",
				lcRoot + "\other\other",
				lcRoot + "\other\txt"
			]
		]
	
		for cFolder in laFolders
			if not DirExists(cFolder)
				OSCreateOpenFolder(cFolder)
			ok
		next
	
		for cSubfolder in laSubFolders
			chDir(cSubFolder[1])
			for i=2 to len(cSubFolder)
				if not DirExists(cSubFolder[i])
					OSCreateOpenFolder(cSubFolder[i])
				ok
			next
		next
		
		# select the project's directory
		chDir(lcRoot)


	#
	# Create the build file
	#
	func createBuildFile tcProjectName
		cBuffer = 
`{
	"name": ":PROJECT_NAME",
	"version": ":PROJECT_VERSION",
	"description": ":PROJECT_DESCRIPTION",	
	"application": ":PROJECT_APPLICATION",
	"entry_point": ":PROJECT_ENTRY_POINT",
	"author": ":PROJECT_AUTHOR",
	"license": ":PROJECT_LICENSE",
	"root": ":ROOT",
	"output": ":PROJECT_NAME.exe"
}`
		aInfo = askForProjectInfo()
		cBuffer = substr(cBuffer, ":PROJECT_NAME", tcProjectName)
		cBuffer = substr(cBuffer, ":PROJECT_VERSION", aInfo[:VERSION])
		cBuffer = substr(cBuffer, ":PROJECT_DESCRIPTION", aInfo[:DESCRIPTION])
		cBuffer = substr(cBuffer, ":PROJECT_APPLICATION", aInfo[:APPLICATION])
		cBuffer = substr(cBuffer, ":PROJECT_ENTRY_POINT", aInfo[:ENTRY_POINT])
		cBuffer = substr(cBuffer, ":PROJECT_AUTHOR", aInfo[:AUTHOR])
		cBuffer = substr(cBuffer, ":PROJECT_LICENSE", aInfo[:LICENSE])
		cBuffer = substr(cBuffer, ":ROOT", substr(currentDir(), "\", "\\"))
		write("build.json", cBuffer)


	#
	# Creates the foxpro files
	#
	func createFoxFiles
		lcAppType = _PROJECT_APPLICATION
		loAppBuilder = NULL
		switch lcAppType
		on "1"
			loAppBuilder = new ConsoleApp
		on "2"
			# nothing
		on "3"
			# nothing
		on "4"
			# nothing
		on "5"
			# nothing
		on "6"
			# nothing
		off
		if isNull(loAppBuilder)
			goPrinter.println("Invalid application type...")
			bye
		ok

		loAppBuilder.createFiles()


	#
	# Ask the user about the newly created project info.
	#
	func askForProjectInfo
		aInfo = [
			:version = "1.0.0",
			:description = "",
			:application = "1", // Console
			:entry_point = "main.prg",
			:author = "",
			:license = "MIT"
		]
		aCopy = aInfo
		# Project version
		? "This utility will walk you through creating a build.json file."
		? "It only covers the most common items, and tries to guess sensible defaults." + nl
		? "Press ^C at any time to quit."
		
		for entry in aInfo
			if len(aInfo[entry[1]]) > 0
				see entry[1] + ": (" + aInfo[entry[1]] + ") "
				if entry[1] = "application"
					see nl + "Please select the application type:" + nl
					? "1. Console (exe)"
					? "2. Desktop (exe use the screen)"
					? "3. Desktop (exe use top level form)"
					? "4. Application (app)"
					? "5. Single-threaded Library (dll)"
					? "6. Multi-threaded Library (dll)"
					see nl + "Default: (1)"
				ok
			else
				see entry[1] + ": " + aInfo[entry[1]]
			ok
			lcInput = getString()
			if len(lcInput) > 0
				aInfo[entry[1]] = lcInput
			ok		
		next
	
		# confirm input data
		? " ================ CHECK YOUR DATA ================"
		for cEntry in aInfo
			? cEntry[1] + ": " + cEntry[2]
		next
		? "Is this OK? (yes)"
		lcInput = getString()
		if lower(lcInput) = "no"
			return aCopy
		ok
		
		return aInfo
