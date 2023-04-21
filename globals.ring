#
# Global identifiers
#

_VERSION = "0.0.1"

# Global instances
goPrinter = new Printer
goBuilder = new Builder

# Global config file (json)
goConfig = NULL

# Project global variables
_PROJECT_NAME = ""
_PROJECT_VERSION = ""
_PROJECT_DESCRIPTION = ""
_PROJECT_APPLICATION = ""
_PROJECT_ENTRY_POINT = ""
_PROJECT_AUTHOR = ""
_PROJECT_LICENSE = ""
_PROJECT_ROOT = ""
_PROJECT_OUTPUT = ""


#
# Updates the project variables
#
func updateProjectVariables
	goConfig = loadConfigFile()
	_PROJECT_NAME = goConfig[:NAME]
	_PROJECT_VERSION = goConfig[:VERSION]
	_PROJECT_DESCRIPTION = goConfig[:DESCRIPTION]
	_PROJECT_APPLICATION = goConfig[:APPLICATION]
	_PROJECT_ENTRY_POINT = goConfig[:ENTRY_POINT]
	_PROJECT_AUTHOR = goConfig[:AUTHOR]
	_PROJECT_LICENSE = goConfig[:LICENSE]
	_PROJECT_ROOT = goConfig[:ROOT]
	_PROJECT_OUTPUT = goConfig[:OUTPUT]

#
# Loads the configuration file
#
func loadConfigFile	
	cBuildFile = currentDir() + '\build.json'
	if not fexists(cBuildFile)
		goPrinter.print(CC_FG_RED, "File does not exists: ")
		? cBuildFile
		return
	ok
	return JSON2List(read(cBuildFile))


#
# Creates a Config.fpw file
#
func createFPWFile tcOutput
	cBuffer = 
`
* =========================================================== *
* config.fpw
*
* Created by :USER_NAME
* Console Application
* Copyright ® :YEAR :USER_NAME. All rights reserved.
* =========================================================== *

SCREEN = OFF
RESOURCE = OFF
`

	cBuffer = substr(cBuffer, ":USER_NAME", SysGet("USERNAME"))
	cBuffer = substr(cBuffer, ":YEAR", right(date(), 4))
	write(tcOutput + "\config.fpw", cBuffer)


func getFoxConsoleContent
	lcBuffer = 
`
if type('_vfp.cli') != 'O'
	addproperty(_vfp, 'cli', .null.)
endif
_vfp.cli = createobject("Console")

* ================================= *
* Console class
* ================================= *
define class console as custom
	StdOut = 0
	StdIn = 0


	function init
		this.loadLibraries()
		AllocConsole()
		this.StdOut = GetStdHandle(-11)
		this.StdIn = GetStdHandle(-10)
		=SetConsoleTextAttribute(this.StdOut, 0x07)
		=SetConsoleTitle(_screen.caption)
	endfunc


	function print(cOutput)
		local nBytesWritten
		if vartype(cOutput) <> "C"
			cOutput=iif(!empty(cOutput), alltrim(transform(cOutput)), "")
		endif

		nBytesWritten=0
		if WriteConsole(this.StdOut, @cOutput, len(cOutput), @nBytesWritten, 0) = 0
			=GetLastError()
		endif
		return nBytesWritten
	endfunc

	function PrintLn(cOutput)
		this.print(cOutput)
		this.print(chr(13)+chr(10))
	endfunc


	function input(tcTitle)
		if empty(tcTitle)
			tcTitle = ""
		endif
		this.print(tcTitle)
		return this.ReadLn()
	endfunc


	function ReadLn(nBufsize)
		local cBuffer, nBytesRead, lcResult
		if vartype(nBufsize) <> "N"
			nBufsize=1024
		endif
		cBuffer = replicate(chr(0), nBufsize)
		nBytesRead=0
		if ReadConsole(this.StdIn, @cBuffer, nBufsize, @nBytesRead, 0) = 0
			=GetLastError()
			return ""
		endif
		lcResult = substr(cBuffer, 1, nBytesRead)
		return strtran(alltrim(lcResult), chr(13) + chr(10), "")
	endfunc


	function readkey
		return this.ReadLn()
	endfunc

	hidden function loadLibraries
		declare integer GetLastError in kernel32
		declare integer GetStdHandle in kernel32 long nStdHandle
		declare integer AllocConsole in kernel32
		declare integer FreeConsole in kernel32
		declare integer CloseHandle in kernel32 integer hObject
		declare integer SetConsoleTitle in kernel32 string lpConsoleTitle

		declare integer WriteConsole in kernel32;
			integer hConsoleOutput, string @lpBuffer,;
			integer nNumberOfCharsToWrite,;
			integer @lpNumberOfCharsWritten,;
			integer lpReserved

		declare integer ReadConsole in kernel32;
			integer hConsoleInput, string @lpBuffer,;
			integer nNumberOfCharsToRead,;
			integer @lpNumberOfCharsRead, integer lpReserved

		declare integer SetConsoleTextAttribute in kernel32;
			integer hConsoleOutput, SHORT wAttributes

		declare SHORT ExitProcess in WIN32API integer uExitCode
	endfunc

	function destroy
		=FreeConsole()
		=CloseHandle(this.StdOut)
		=CloseHandle(this.StdIn)
	endfunc

	function exit(tnReturnValue)
		=ExitProcess(tnReturnValue)
	endfunc

enddefine
`
return lcBuffer
