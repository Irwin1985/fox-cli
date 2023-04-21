class VBScript

	func createAndBuildFiles
		lcRoot = _PROJECT_ROOT
		lcPRGBuilder = lcRoot + "\.meta\builder.prg"
		lcVBScript = lcRoot + "\createProject.vbs"
		createPRGBuilder(lcPRGBuilder)

		lcBuffer = 
`	
' Run VisualFoxPro
Set oVFP9 = CreateObject("VisualFoxPro.Application.9")
oVFP9.DoCmd("DO :PROGRAM_BUILDER")
oVFP9.DoCmd("CLEAR ALL")
Set oVFP9 = Nothing
WScript.Quit 0
`
	lcBuffer = substr(lcBuffer, ':PROGRAM_BUILDER', lcPRGBuilder)
	write(lcVBScript, lcBuffer)

	# Execute build files
	executeBuildFiles(lcPRGBuilder, lcVBScript)


#
# run the building files
#
func executeBuildFiles tcPRGBuilder, tcVBScript
	checkFile(tcPRGBuilder)
	checkFile(tcVBScript)
	
	# Execute build files
	systemSilent(tcVBScript)
	
	# Check for errors
	lcErrFile = _PROJECT_ROOT + "\.meta\" + _PROJECT_NAME + ".err"
	if fExists(lcErrFile)
		lcContent = read(lcErrFile)
		goPrinter.println(CC_FG_RED, copy("=", 75))
		goPrinter.println(CC_FG_RED, "COMPILATION ERROR: ")
		goPrinter.println(CC_FG_RED, lcContent)
		goPrinter.println(CC_FG_RED, copy("=", 75))
		deleteFile(lcErrFile)
	ok
	

	# delete files
	lcFxpFile = substr(tcPRGBuilder, 1, len(tcPRGBuilder)-3) + "fxp"
	deleteFile(tcPRGBuilder)
	deleteFile(tcVBScript)

	if fExists(lcFxpFile)
		deleteFile(lcFxpFile)
	ok


#
# Create the PRG builder program
#
func createPRGBuilder tcPRGBuilder
	lcBuffer = 
`
gcProjectName 	= ":PROJECT_NAME"
gnProjectType 	= :PROJECT_APPLICATION && console app (exe)
gcRoot 					= ":PROJECT_ROOT"
gcMainFile 			= ":PROJECT_ENTRY_POINT"
gcOutput   			= ":PROJECT_OUTPUT"

#Define BUILDACTION_REBUILD 	1 && Rebuilds the project. (Default)
#Define BUILDACTION_BUILDAPP 	2 && Creates an .app file.
#Define BUILDACTION_BUILDEXE 	3 && Creates an .exe file.
#Define BUILDACTION_BUILDDLL 	4 && Creates a .dll file.
#Define BUILDACTION_BUILDMTDLL 	5 && Creates a multithreaded .dll file.

Cd (gcRoot)
Set Default To (gcRoot)

Local Array laFolders[11,2]
Local loFiles

laFolders[1,1] = Addbs(gcRoot) + "classes"
laFolders[1,2] = "vcx"

laFolders[2,1] = Addbs(gcRoot) + "code\app"
laFolders[2,2] = "app;exe"

laFolders[3,1] = Addbs(gcRoot) + "code\lib"
laFolders[3,2] = "fll"

laFolders[4,1] = Addbs(gcRoot) + "code\programs"
laFolders[4,2] = "prg"

laFolders[5,1] = Addbs(gcRoot) + "data"
laFolders[5,2] = "dbf;dbc;qpr"

laFolders[6,1] = Addbs(gcRoot) + "documents\forms"
laFolders[6,2] = "scx"

laFolders[7,1] = Addbs(gcRoot) + "documents\labels"
laFolders[7,2] = "lbx"

laFolders[8,1] = Addbs(gcRoot) + "documents\reports"
laFolders[8,2] = "frx"

laFolders[9,1] = Addbs(gcRoot) + "other\menu"
laFolders[9,2] = "mnx"

laFolders[10,1] = Addbs(gcRoot) + "other\other"
laFolders[10,2] = "bmp;msk"

laFolders[11,1] = Addbs(gcRoot) + "other\txt"
laFolders[11,2] = "txt;h;asp;log;htm;html;fpw"

* Create the project and put it in .meta folder
Cd .meta

* Delete old files (if any)
Local array laProjectFiles[3]
laProjectFiles[1] = gcProjectName + ".pjx"
laProjectFiles[2] = gcProjectName + ".pjt"
laProjectFiles[3] = gcProjectName + ".err"
local lnIndex

for lnIndex = 1 to alen(laProjectFiles)
	If File(laProjectFiles[lnIndex])
		Try
			Delete File (laProjectFiles[lnIndex])
		Catch
		Endtry
	Endif
endfor

Modify Project (gcProjectName) Nowait Noshow Noprojecthook
Local loProject
loProject = _vfp.Projects(1)

* Get files from folders
Local i
For i=1 To Alen(laFolders, 1)
	Set Path To (laFolders[i,1]) additive
	loFiles = findFilesByType(laFolders[i,1], laFolders[i,2])
	For Each lcFile In loFiles
		loProject.Files.Add(lcFile)
		If Lower(justext(lcFile)) == 'fpw'
			loProject.Files.Item(lcFile).Type = 'T'
		EndIf
		* TODO(irwin): consider excluded files.
	EndFor
	loFiles = .null.
Endfor

* Set the main file
loProject.SetMain(gcMainFile)
loProject.Debug = .T.
loProject.Encrypted = .t.
loProject.ProjectHookLibrary = ''

* Build the solution
lcPJXFileName = Addbs(gcRoot) + gcProjectName + ".pjx"
lcOutput = Addbs(gcRoot) + "bin\" + gcOutput
lnBuildType = BUILDACTION_BUILDEXE

local lnType
do case
case inlist(gnProjectType, 1, 2, 3)
	lnType = BUILDACTION_BUILDEXE
case gnProjectType == 4
	lnType = BUILDACTION_BUILDAPP
case gnProjectType == 5
	lnType = BUILDACTION_BUILDDLL
case gnProjectType == 6
	lnType = BUILDACTION_BUILDMTDLL
endcase
_vfp.Projects.Item(1).Build(lcOutput, lnType, .f., .f.)
loProject.Close()
* END

* ==================================================== *
* FUNCTION HELPERS
* ==================================================== *
Function findFilesByType(tcFolder, tcExtensions)
	Local loResult, j, k
	loResult = Createobject("Collection")
	If Directory(tcFolder)
		Dimension laFiles(1)
		For j = 1 To Getwordcount(tcExtensions, ';')
			GetAllFiles(Addbs(tcFolder), Getwordnum(tcExtensions, j, ';'), @laFiles)
		EndFor

		For k = 1 To Alen(laFiles, 1)
			If Type('laFiles[k]') == 'C'
				loResult.Add(laFiles[k])
			Endif
		Endfor
	Endif
	Wait Clear
	Return loResult
Endfunc


Function GetAllFiles
	Lparameters cDirectory, cType, aryParam

	Local Array aryTemp(1,5)
	Local nCount, nMax, nLen, cFile
	Set Default To (cDirectory)
	=Adir(aryTemp, "*.*","AHRSD",1)
	nMax = Alen(aryTemp,1)

	For nCount = 1 To nMax
		cFile = Alltrim(aryTemp(nCount,1))
		If !(cFile == ".") And !(cFile == "..")
			If "D" $ aryTemp(nCount,5)
				GetAllFiles(Addbs(cDirectory + cFile), cType, @aryParam)
			Else
				If Lower(Right(cFile, 4)) == '.' + cType
					nLen = Alen(aryParam)
					If !Empty(aryParam(nLen))
						Dimension aryParam(nLen + 1)
						nLen = nLen + 1
					Endif
					aryParam(nLen) = cDirectory + cFile
				Endif
			Endif
		Endif
	Endfor
Endfunc
`
	lcMainFile = _PROJECT_ROOT + "\code\programs\" + _PROJECT_ENTRY_POINT
	lcBuffer = substr(lcBuffer, ':PROJECT_NAME', _PROJECT_NAME)
	lcBuffer = substr(lcBuffer, ':PROJECT_APPLICATION', _PROJECT_APPLICATION)
	lcBuffer = substr(lcBuffer, ':PROJECT_ROOT', _PROJECT_ROOT)
	lcBuffer = substr(lcBuffer, ':PROJECT_ENTRY_POINT', lcMainFile)
	lcBuffer = substr(lcBuffer, ':PROJECT_OUTPUT', _PROJECT_OUTPUT)
	write(tcPRGBuilder, lcBuffer)
