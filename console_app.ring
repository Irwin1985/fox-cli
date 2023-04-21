class ConsoleApp

	func createFiles
		lcRoot = _PROJECT_ROOT
		cBuffer = 
`
* =========================================================== *
* main.prg
*
* Created by :USER_NAME
* Console Application
* Copyright ® :YEAR :USER_NAME. All rights reserved.
* =========================================================== *

do ../code/programs/FoxConsole

_vfp.cli.Println("Hello World!")
_vfp.cli.Println("Press ENTER to exit...")
_vfp.cli.readkey()
_vfp.cli.exit(0)
`

	cBuffer = substr(cBuffer, ":USER_NAME", SysGet("USERNAME"))
	cBuffer = substr(cBuffer, ":YEAR", right(date(), 4))
	write(lcRoot + "\code\programs\main.prg", cBuffer)

	# Write CONFIG.FPW
	createFPWFile(lcRoot + "\other\txt")

	# Download FoxConsole.prg
	lcURL = "https://raw.githubusercontent.com/Irwin1985/FoxConsole/main/foxconsole.prg"
	lcContent = download(lcURL)
	if len(lcContent) = 0
		lcContent = getFoxConsoleContent()
	ok
	write(lcRoot + "\code\programs\FoxConsole.prg", lcContent)
