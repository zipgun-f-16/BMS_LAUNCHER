;
;   BMS LAUNCHER by ZIPGUN  ©2018
;	V0.5	28Jul18		-	Added Dev support (4.34)
;	V0.4	18Jul18		-	Cleaned up code & repainted ICON to make more visible
;	V0.3	16Jul18
;

#SingleInstance force
DetectHiddenWindows, On
;
; If not elevated, restart in admin mode
;
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

G_Start:
CurrVersion := "v.5"																	;; this version number for version check
;
;look for ini - if not there, create one in the proper folder 
;
PUB_VER := "Falcon BMS 4.33 U1"
DEV_VER := "Falcon BMS 4.34 (Internal)"
DEV_OK := false
PUB_OK := false
;:
;	-----		test for 4.34	------
;
RegRead, DEV_DIR, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%DEV_VER%, baseDir		
if(!errorlevel){
	DEV_OK := true
	}
;:
;	-----		test for good 4.33	------
;
RegRead, PUB_DIR, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%PUB_VER%, baseDir
if(!errorlevel){
	PUB_OK := true
	}

if(!DEV_OK & !PUB_OK){
		msgbox Can not find BMS in registry 									; we need one or the other (or both) to be valid
		ExitApp	
		}
		
if(DEV_OK & PUB_OK){
;
;	If both 4.33 and 4.34 are present  --- get which version to start
;
	Gui, +hwndGUI
	;Gui, Margin,0,0
	gui, Ver:new, +LastFound +AlwaysOnTop  +ToolWindow
	Gui, Ver:Font, s16 bold, Verdana  ; Set 10-point Verdana.
	Gui, Ver:Add, Text, ,WHICH BMS VERSION? 	
	Gui, Ver:Add, button,  +center   gVer433 hwnd433B  +E0x20, 4.33
	Gui, Ver:Add, button,  +center   gVer434 hwnd434B  +E0x20, 4.34	
	Gui, Ver:Add, button, +center   gVerCancel hwnd434B  +E0x20, CANCEL	
	GUI, Ver: show
	return
}
;
;				Set the target version of the life of the process
;
Ver433:
	Gui, Ver:destroy
	BMS_VER := PUB_VER
	BMS_DIR := PUB_DIR
	DEV_OK := false
	goto BeginProcess	

Ver434:
	Gui, Ver:destroy
	BMS_VER := DEV_VER
	BMS_DIR := DEV_DIR
	PUB_OK := false
	goto BeginProcess

VerCancel:
	exitapp
;
;			Let's get on with it!!
;

BeginProcess:
RegRead, curTheater, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, curTheater
fileOK := true
;
;			The INI file retains the last settings used -- start with defaults and then remember
;
launchIni := BMS_DIR . "\User\Config\Launcher.ini"
			try{
			FileOpen( launchIni, "r")	;; see if the INI exists
			} catch e {													;; see if there was an error
				if(A_LastError != 2){
					msgbox Can not open INI file -- Error %A_LastError%				; BAD ERROR!! (more than non-existent file)
					ExitApp
					}
				fileOK := false
				}
;
;			No INI file -- need to create one (first time only)
;
if(!fileOK){
	IniWrite, val=0`ntxt=, %launchIni%, Windowed
	IniWrite, val=0`ntxt= , %launchIni%, MonoLog
	IniWrite, val=`ntxt=, %launchIni%, NoMovie
	IniWrite, val=0`ntxt=, %launchIni%, Acmi
	IniWrite, val=0`ntxt=, %launchIni%, Eye
	IniWrite, val=0`nbwUv=1024`ntxt=, %launchIni%, BW
	IniWrite, val=0`npwd=`ntxt=, %launchIni%, IVC_PW
	IniWrite, val=64, %launchIni%, 64_32
	IniWrite, Key=%BMS_VER%, %launchIni%, BMS_Version
	if(DEV_OK){																		; 4.34 has user UL and DL
		IniWrite, val=4096, %launchIni%, yourUL
		IniWrite, val=4096, %launchIni%, yourDL
		IniWrite, val=0, %launchIni%, devTest										; dev test exe switch		
		}
	IniWrite, ver=%CurrVersion%, %launchIni%, Launcher										; current version
}

	IniRead, iniVer, %launchIni%, Launcher, ver

if(iniVer!= CurrVersion){
	msgBox Wrong Version`r`n `r`nCurrent Version is %CurrVersion%`r`n - Delete Launcher.ini from your Config folder`r`n - And restart
	ExitApp
	}
phonebook := BMS_DIR . "\User\Config\phonebkn.ini"
			try{
			FileOpen( phonebook, "r")	;; try to move the file to itself -- checks for an open file
			} catch e {													;; see if there was an error
				if(A_LastError != 2){
					msgbox Can not open phone book file -- Error %A_LastError%
					ExitApp
					}
				}

tabWdt := 300
tabHgt := 250
bgPicW := 600
bgPicH := 400
tabX := bgPicW/2 - (tabWdt/2)
tabY := bgPicH/2 - (tabHgt/2)+30
closeY := tabHgt-2
closeX := tabWdt-80
secW := (tabWdt)-5
secH := tabHgt-10
yOff := 10
xOff := 10
bgImage := BMS_DIR . "\User\Config\launcher.jpg"
ifNotExist, %bgImage%
	fileInstall, C:\launcher.jpg, %bgImage%
icon := BMS_DIR . "\User\Config\F-16.ico"
ifNotExist, %icon%
	fileInstall, C:\F-16.ico, %icon%
Menu, Tray, Icon , %icon%
MainFlow:

IniRead, WindowV, %launchIni%, Windowed, val
IniRead, WindowT, %launchIni%, Windowed, txt
IniRead, MonoV, %launchIni%, MonoLog, val
IniRead, MonoT, %launchIni%, MonoLog, txt
IniRead, MovieV, %launchIni%, NoMovie, val
IniRead, MovieT, %launchIni%, NoMovie, txt
IniRead, AcmiV, %launchIni%, Acmi, val
IniRead, AcmiT, %launchIni%, Acmi, txt
IniRead, EyeV, %launchIni%, Eye, val
IniRead, EyeT, %launchIni%, Eye, txt
IniRead, bwV, %launchIni%, BW, val
IniRead, bwUv, %launchIni%, BW, bwUv
IniRead, bwT, %launchIni%, BW, txt
IniRead, ivcV, %launchIni%, IVC_PW, val
IniRead, ivc_pw, %launchIni%, IVC_PW, pwd
IniRead, ivcT, %launchIni%, IVC_PW, txt
IniRead, 64_32, %launchIni%, 64_32, val

if(DEV_OK){																		; 4.34 has user UL and DL
	IniRead, yourUL, %launchIni%, yourUL, val
	IniRead, yourDL, %launchIni%, yourDL, val
	IniRead, devTest, %launchIni%, devTest, val
	}
if(64_32 == 0){
	64V = 0
	32V = 1

	}
if(64_32 == 1){
	64V = 1
	32V = 0

	}
;
;	Test fo a test EXE in Bin\.. folder
	If(64_32 == 64)
	{
		bin := "x64"
	}else{
		bin := "x86"
	}
		testExe := false
		run1 := BMS_DIR . "\Bin\" . bin . "\Falcon BMS Test.exe"							;test exe path
		if(FileExist(run1)){																; see if there is a test exe
			testExe := true
			}

empty := false  ;used in blank line check

;===================================================================================================================================================================================================
;-----------------------------------------------------------------    B U I L D    G U I S  -----------------------------------------------------------------------------------------
;===================================================================================================================================================================================================
{
Gui, +hwndGUI
;Gui, Margin,0,0
Menu, MenuBar, Add, LAUNCH, LaunchHandler
Menu, MenuBar, Add, Options, OptionHandler
Menu, MenuBar, Add, Tools, ToolsHandler
Menu, MenuBar, Add, Theaters, TheaterHandler
Menu, MenuBar, Add, PhoneBook, PhoneHandler
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add,
Menu, MenuBar, Add, CLOSE, Closer
}
CustomColor =  0xD6D6D6			; custom color that will be made transparent later  
Gosub LaunchBuild
Gosub OptionsBuild
gosub ToolsBuild
gosub TheaterBuild
;gosub PhoneBuild
gosub DisplayGui
return														;  wait for something good
;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------						launch    G U I							-------------------------------------------------------
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
LaunchBuild:
{
gui, L:new, +LastFound +AlwaysOnTop  +ToolWindow
Gui, L:Color, %CustomColor%
Gui, L:Menu, MenuBar
Gui, L:Add, Picture, xm+0 ym+0 0x4000000 vback +AltSubmit, %bgImage%
Gui, L:Add, GroupBox, xm+%tabX% ym+%tabY%  w%tabWdt% h%tabHgt%  Section w%secW% h%secH% hwndLbox E0x00000020 ,
Gui, L:Font, s16 bold, Verdana  ; Set 10-point Verdana.
Gui, L:Add, button, xs+12 ys+10 +center  cWhite gLaunch1 hwndL1b +BackgroundTrans +E0x20, Launch

Gui, L:Font, s10 , Verdana
Gui, L:Add, button, E0x20 +center cWhite gLaunch2, Launch`r`n IVC + BMS
Gui, Font, s12 , Verdana
Gui, L:Add, Text, xs+122 ys+10 w150 h60 vCTheater +center cWhite +BackgroundTrans +E0x20 , Theater:`r`n %curTheater%
Gui, Font, s10 , Verdana
;Gui, Add, Text, xs+122 ys+39 w200 h80  vCTheater +center Section , Theater:`r`n %curTheater%
curOpts := WindowT . MonoT . MovieT . AcmiT . "`r`n" . EyeT . bwT
binVer := 64_32 . " bit"
If(DEV_OK){
	if(devTest){
		if(testExe){
			devVer := "USE TEST EXE"
		}else{
			devVer := "NO TEST EXE FOUND"
			}
	}else{
		devVer := "STOCK VERSION"
		}
	}else{
	devVer := A_Space
	}
Gui, L:Add, Text, xs+12 ys+120 w250 +E0x20 +BackgroundTrans cWhite vcurrOpt R3 gOptionHandler, Options: %curOpts%
Gui, L:Add, Text, xs+12 ys+180 w250 +E0x20 +BackgroundTrans cWhite vcurrBin  gOptionHandler,  %binVer%
Gui, l:Font, s8
if(DEV_OK){
	Gui, L:Add, Text, xs+12 ys+200 w250 +E0x20 +BackgroundTrans cWhite vdevBin  gOptionHandler,  %devVer%				;text for test/stock switch
	}
if(ivcV == 1){
		Gui, L:Add, Text, xs+120 ys+200 w250 +E0x20  +BackgroundTrans cWhite center vivcTxt  , IVC Server PW
		Gui, L:Add, Text, xs+120 ys+220 w250 +E0x20  +BackgroundTrans cWhite center vcurrPWD  givcVUpd, %ivc_pw%
	}else{
		Gui, L:Add, Text, xs+120 ys+200 w250 +E0x20  +BackgroundTrans cWhite center  vivcTxt ,
		Gui, L:Add, Text, xs+120 ys+220 w250 +E0x20 +BackgroundTrans cWhite center vcurrPWD  givcVUpd,
	}
		Gui, Font, s4
		Gui, L:Add, Text, xs+10 ys+240 w50 +E0x20  +BackgroundTrans cWhite,©2018 ZIPGUN
;Gui, Font, s10 bold, Verdana

WinSet, TransColor, %CustomColor%				; make background disappear
return
}
;--------------------------------------------------------------------------------------------------------------------------------
;-------------- 									options   G U I							-------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------
OptionsBuild:
{
gui, O:new, +LastFound  +ToolWindow
Gui, O:Color, %CustomColor%
Gui, O:Menu, MenuBar
Gui, O:Add, Picture, xm+0 ym+0 0x4000000 vback +AltSubmit, %bgImage%
Gui, O:Font, s10, Verdana
Gui, O:Add, GroupBox, xm+%tabX% ym+%tabY%  w%tabWdt% h%tabHgt%  Section w%secW% h%secH% hwndObox E0x00000020 -wrap,

if(WindowV == 1){
		Gui, O:Add, CheckBox, xs+10 ys+20 w12 h12 vWindowV gOptionsUpd  BackgroundTrans +E0x20 +Checked,
		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+24 ys+18 w85 vWindowVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,WINDOWED
		Gui, O:Font, norm
	}else{
		Gui, O:Add, CheckBox, xs+10 ys+20 w12 h12 vWindowV gOptionsUpd  BackgroundTrans +E0x20 cWhite,
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+24 ys+18 w85 vWindowVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite  ,windowed
		Gui, O:Font, norm
	}
if(MonoV == 1){
		Gui, O:Add, CheckBox, xs+10 ys+40 w12 h12 vMonoV gOptionsUpd +Checked ,
		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+24 ys+38 w95 vMonoVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,MONO LOG
		Gui, O:Font, norm
	}else{
		Gui, O:Add, CheckBox, xs+10 ys+40 w12 h12 vMonoV gOptionsUpd ,
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+24 ys+38 w95 vMonoVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,mono log
		Gui, O:Font, norm
	}
if(MovieV == 1){
		Gui, O:Add, CheckBox, xs+10 ys+60 w12 h12 vMovieV gOptionsUpd +Checked ,
		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+24 ys+58 w95 vMovieVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,NO MOVIES
		Gui, O:Font, norm
	}else{
		Gui, O:Add, CheckBox, xs+10 ys+60 w12 h12 vMovieV gOptionsUpd ,
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+24 ys+58 w95 vMovieVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,no movies
		Gui, O:Font, norm
	}
;
;
if(AcmiV == 1){
		Gui, O:Add, CheckBox, xs+10 ys+80 w12 h12 vAcmiV gOptionsUpd +Checked ,
		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+24 ys+78 w95 vAcmiVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,AUTO ACMI
		Gui, O:Font, norm
	}else{
		Gui, O:Add, CheckBox, xs+10 ys+80 w12 h12 vAcmiV gOptionsUpd ,
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+24 ys+78 w95 vAcmiVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,auto acmi
		Gui, O:Font, norm

	}
if(EyeV == 1){
		Gui, O:Add, CheckBox, xs+10 ys+100 w12 h12 vEyeV gOptionsUpd +Checked ,
		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+24 ys+98 w95 vEyeVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,EYE FLY
		Gui, O:Font, norm
	}else{
		Gui, O:Add, CheckBox, xs+10 ys+100 w12 h12  vEyeV gOptionsUpd ,
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+24 ys+98 w95 vEyeVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,eye fly
		Gui, O:Font, norm
	}
;--------------  BW user entry
;		check and edit
if(!DEV_OK){
	if(bwV == 1){

		Gui, O:Add, CheckBox, xs+150 ys+20 w12 h12 vbwV gbwUpd +Checked c,
		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+175 ys+18 w95 vbwVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite , BW (kb)
		Gui, O:Font, norm
		Gui, O:Add, edit, xs+240 ys+18 vbwUv gbwVUpd  , %bwUv%
	}else{
		Gui, O:Add, CheckBox, xs+150 ys+20 w12 h12 vbwV gbwUpd ,
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+175 ys+18 w95 vbwVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite , bw (kb)
		Gui, O:Font, norm
		Gui, O:Add, edit, xs+240 ys+18 vbwUv gbwVUpd , ____
		GuiControl, +hidden, bwUv
		}
;
;			4.34 -- needs 2 entries
;		
	}else{								
		Gui, O:Add, text, xs+130 ys+20 w95 vbwDVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite , DL BW (kb)
		Gui, O:Font, s8
		Gui, O:Add, edit, xs+220 ys+18 w60 limit6 right vbwDLv gbwVUpd434  , %yourDL%
		Gui, O:Add, text, xs+130 ys+45 w95 vbwUVt gOptionsUpdb  BackgroundTrans +E0x20 cWhite , UL BW (kb)
		Gui, O:Font, s8
		Gui, O:Add, edit, xs+220 ys+40 w60 limit6 right vbwULv gbwVUpd434  , %yourUL%
		}
	
	
;
;--------------  IVC SERVER password user entry
;
if(ivcV == 1){

		Gui, O:Add, CheckBox, xs+150 ys+85 w12 h12 vivcV givcUpd +Checked,
		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+175 ys+80 w105 vivcVt BackgroundTrans +E0x20 cWhite , IVC SERV PWD
		Gui, O:Font, norm
		Gui, O:Add, text, xs+110 ys+110 w180 vivc_pwd givcVUpd  -Background, %ivc_pw%
	}else{

		Gui, O:Add, CheckBox, xs+150 ys+85 w12 h12 vivcV givcUpd ,
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+175 ys+80 w95 vivcVt  BackgroundTrans +E0x20 cWhite , ivc serv pwd
		Gui, O:Font, norm
		Gui, O:Add, text, xs+110 ys+110 w180 vivc_pwd givcVUpd , ____
		GuiControl, +hidden, ivc_pwd

	}
;------------------- 32-64 radio
;

if(64_32 == 64)
{
		Gui, O:Add, radio, xs+20 ys+150 w12 h12 v64V gOptionsUpd +Checked ,
		Gui, O:Add, radio, xs+90 ys+150 w12 h12 v32V gOptionsUpd ,

		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+10 ys+165 w60 v64Vt gOptionsUpdb  BackgroundTrans +E0x20 cWhite , 64 BIT
		Gui, O:Font, norm
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+80 ys+165 w60 v32Vt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,32 bit
		Gui, O:Font, norm
	}

if(64_32 == 32)
{
		Gui, O:Add, radio, xs+20 ys+150 w12 h12 v64V gOptionsUpd  ,
		Gui, O:Add, radio, xs+90 ys+150 w12 h12 v32V gOptionsUpd +Checked,
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+10 ys+165 w60 v64Vt gOptionsUpdb  BackgroundTrans +E0x20 cWhite , 64 bit
		Gui, O:Font, norm
		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+80 ys+165 w60 v32Vt gOptionsUpdb  BackgroundTrans +E0x20 cWhite ,32 BIT
		Gui, O:Font, norm


	}
;	
;------------------- dev test exe Y/N
;

if(DEV_OK){
; test for a test exe file
;		testExe := false
;		run1 := BMS_DIR . "\Bin\" . bin . "\Falcon BMS Test.exe"							;test exe path
;		if(FileExist(run1)){																; see if there is a test exe
;			testExe := true
;			}
	if(devTest)
	{
		if(testExe){
			Gui, O:Add, CheckBox, xs+150 ys+150 w12 h12 vdevTest gdevTest434 +Checked , 
			Gui, O:Add, text, xs+170 ys+150  vdevTestT gOptionsUpdb  BackgroundTrans +E0x20 cWhite , Use Test EXE
		}else{
			Gui, O:Add, CheckBox, xs+150 ys+150 w12 h12 vdevTest gdevTest434 +Checked, 
			Gui, O:Add, text, xs+170 ys+150  vdevTestT gOptionsUpdb  BackgroundTrans +E0x20 cWhite , Use Test EXE SET`nBUT NO TEST EXE`nFOUND - IGNORED
			}

	}else{
		Gui, O:Add, CheckBox, xs+150 ys+150 w12 h12 vdevTest gdevTest434 , 
		Gui, O:Add, text, xs+170 ys+150  vdevTestT gOptionsUpdb  BackgroundTrans +E0x20 cWhite , Use Test EXE	
	}

	Gui, O:Add, Text, xs+90 ys+220 cWhite +BackgroundTrans +E0x20 ,See BMS Manual Pg. 20
	Gui, O:Font, s10 , Verdana

WinSet, TransColor, %CustomColor%				; make background disappear

}
return
}			; end of options gui

;--------------------------------------------------------------------------------------------------------------------------------
;------------------------						T O O L S   G U I							-------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------
ToolsBuild:
{

;Gui, Tab, Tools
gui, TO:new, +LastFound +ToolWindow
Gui, TO:Menu, MenuBar
Gui, TO:Add, Picture, xm+0 ym+0 0x4000000 vback +AltSubmit, %bgImage%
Gui, TO:Color, %CustomColor%
Gui, TO:Add, GroupBox, xm+%tabX% ym+%tabY%  w%tabWdt% h%tabHgt%  Section w%secW% h%secH% hwndTObox E0x00000020 ,
Gui, TO:Font, s10 bold, Verdana
Gui, TO:Add, BUTTON, xs+10 ys+10 gConfig hwndBTN1 cWhite, Configuration
Gui, TO:Add, BUTTON, gdocs hwndBTN2 cWhite, Documentation and Manuals
Gui, TO:Add, BUTTON,  gdisplay hwndBTN3 cWhite, Conckpit Display Extraction
Gui, TO:Add, BUTTON,  givcClient hwndBTN4 cWhite, IVC Client
;Gui, TO:Add, BUTTON,  gAvConfig hwndBTN5 cWhite, Avionics Configurator
Gui, TO:Add, BUTTON,  gdbEdit hwndBTN6 cWhite, Editor
Gui, TO:Font, s10 , Verdana  ; Set 8-point Verdana.
;Gui, TO:Add, BUTTON, xs%closeX% ys%closeY%  gLaunchHandler cWhite +Border, Return
WinSet, TransColor, %CustomColor%				; make background disappear
return
}

;--------------------------------------------------------------------------------------------------------------------------------
;---------------------------				T H E A T U R E    G U I					-----------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------
TheaterBuild:
BuildTheaterGui:
{
gui, TH:new, +LastFound +ToolWindow
Gui, TH:Menu, MenuBar
Gui, TH:Add, Picture, xm+0 ym+0 0x4000000 vback +AltSubmit, %bgImage%
Gui, TH:Add, GroupBox, xm+%tabX% ym+%tabY%  w%tabWdt% h%tabHgt%  Section w%secW% h%secH% hwndTHbox E0x00000020 ,
	gosub TheaterGui
theaterBuilt := true
return
}

;--------------------------------------------------------------------------------------------------------------------------------
;---------------------------				P H O N E  B O O K    G U I					-----------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------
PhoneBuild:
{
gosub pb_build
Return
}

pb_build:												; build the phone book grid
{
gui, PB:new, +LastFound +ToolWindow
Gui, PB:Menu, MenuBar
Gui,PB: Font,CDefault,Fixedsys
Gui,PB: Margin, 10, 10
if(!DEV_OK){
	Gui, PB:Add, ListView,  w700 h600 grid cWhite backgroundteal hwndpbLV1 vpbLV1 gListViewEvents +altsubmit -multi, Entry|Name|Server_IP|Voice_IP|IVC_PWD|BW
}else{
	Gui, PB:Add, ListView,  w700 h600 grid cWhite backgroundteal hwndpbLV1 vpbLV1 gListViewEvents +altsubmit -multi, Entry|Name|Server_IP|Voice_IP|IVC_PWD|DOWN| UP |
	}
            gosub pbFill
            Gui,PB:add,button,  Default gAddNew1,ADD_ROW
           Gui,PB:add,button,  x+5 gPB_Help,-=HELP=-
		   Gui, PB:Add, StatusBar,%A_Space%
			SB_SetParts(800/3, 800/3)
;			SB_SetText("RIGHT CLICK ENTRY LINE TO MODIFY", 1, 2)
gui, PB: show, x%mainx% y%mainy% w800 h700, RIGHT CLICK ENTRY LINE TO MODIFY or DELETE
;
;-------- SCROLL CLICK MESSAGE on status bar
;
	loop
	{
		sbShow := Floor(mod(A_Sec,10)/3)

		if(sbShow == 0){
			SB_SetText("RIGHT CLICK ENTRY LINE TO MODIFY", 1, 2)
			SB_SetText(" ", 2, 0)
			SB_SetText(" ", 3, 0)
		}else{
			if(sbShow==1){
			SB_SetText("RIGHT CLICK ENTRY LINE TO DELETE", 2, 2)
			SB_SetText(" ", 1, 0)
			SB_SetText(" ", 3, 0)
			}else{
				SB_SetText("RIGHT CLICK ENTRY LINE TO MODIFY", 3, 2)
				SB_SetText(" ", 2, 0)
				SB_SetText(" ", 1, 0)
				}
			}
		sleep 750
	}
return
}
;-------------------------======================================================================================================-------------------------------------------------------------------
;------------------------=========================	D I S P L A Y    D E F A U L T (LAUNCH)    G U I	=========================------------------------------------------------------------------
;-------------------------======================================================================================================-------------------------------------------------------------------
DisplayGui:
{
Gui, L:Font, s8 , Verdana
gui, L:Add, StatusBar, , Current version is %CurrVersion%
Gui, L:Show, , BMS Launcher
return
}
;===================================================================================================================================================================================================
;-----------------------------------------------------------------    M E N U  B A R  P R O C E S S I N G  -----------------------------------------------------------------------------------------
;===================================================================================================================================================================================================
LaunchHandler:
{
	Gui,+LastFound
	WinGetPos,mainx, mainy,mainw,mainh						; discover where the window is now (user may move it)
	Gui, O:HIDE
	Gui, TH:HIDE
	Gui, TO:HIDE
	Gui, PB:HIDE
	Gui, L:Submit, nohide
	Gui, L:Show, x%mainx% y%mainy%

	return
	}
OptionHandler:
{
	Gui,+LastFound
	WinGetPos,mainx, mainy,mainw,mainh						; discover where the window is now (user may move it)

	Gui, O:Show, x%mainx% y%mainy% , Options
	Gui, L:Hide
	Gui, TH:Hide
	Gui, TO:Hide
	Gui, PB:Hide
	return
	}
ToolsHandler:
{
	Gui,+LastFound
	WinGetPos,mainx, mainy,mainw,mainh						; discover where the window is now (user may move it)
;	Gui, L:Minimize
	Gui, TO:Show,x%mainx% y%mainy% , TOOLS
	Gui, L:Hide
	Gui, TH:HIDE
	Gui, PB:HIDE
	Gui, O:HIDE
	return
	}
TheaterHandler:
{
	Gui,+LastFound
	WinGetPos,mainx, mainy,mainw,mainh						; discover where the window is now (user may move it)

	if (!theaterBuilt)
	{
		GoSub BuildTheaterGui										; build it once
	}
	Gui, TH:Show,x%mainx% y%mainy%  , THEATERS
	Gui, L:Hide
	Gui, TO:HIDE
	Gui, PB:HIDE
	Gui, O:HIDE
	return
	}
PhoneHandler:
{
	Gui,+LastFound
	WinGetPos,mainx, mainy,mainw,mainh						; discover where the window is now (user may move it)
		Gui, L:Hide
	Gui, TO:HIDE
	Gui, TH:HIDE
	Gui, O:HIDE	
	goto pb_build

return
}
;
;=================================================================================================================================================================================================================================
;--------------------------------------------------------------------------------------------------------- L A U N C H   B U T T O N S  -----------------------------------------------------------------------------------------
;=================================================================================================================================================================================================================================
;
Launch2:											; option to fire IVC server and then BMS
{
IniRead, ivcT, %launchIni%, IVC_PW, txt
	runStr = "%BMS_DIR%\Bin\x86\IVC\IVC Server.exe"
	Run, *RunAs %runStr% %ivcT%
	sleep 10
	}
Launch1:											; Launch BMS only
{
Gui, L:Destroy
Gui, O:Destroy
Gui, TO:Destroy
Gui, TH:Destroy
Gui, PB:Destroy
runOpts =%WindowT% %MonoT% %MovieT% %acmiT% %bwT%

; MsgBox, runStr = "%BMS_DIR%\Bin\x64\Falcon BMS.exe" %runOpts%
	If(64_32 == 64)
	{
		bin := "x64"
	}else{
		bin := "x86"
	}
	
if(!DEV_OK){
		runexe := "Falcon BMS.exe"
		run1 := BMS_DIR . "\Bin\" . bin . "\" . runexe
		runStr := BMS_DIR . "\Bin\" . bin . "\" . runexe . " " . runOpts
;				MsgBox, %runStr%

	if(!FileExist(run1)){
		MsgBox CRITICAL ERROR -- EXE FILE:`r`n`n %run1% `r`n`nDOES NOT EXIST - ABORTING
		exitapp
		}
	;MsgBox, %runStr%	

	Run, *RunAs %runStr% , %BMS_DIR%


	ExitApp															; end of 4.33 launch ===============
	}else{	
;	
;		============================================================================================================================================================================================
; 		===================================================					 4.34 launch 			================================================================================================
;		============================================================================================================================================================================================
;
		testExe := false
		run1 := BMS_DIR . "\Bin\" . bin . "\Falcon BMS Test.exe"							;test exe path
		r2 := BMS_DIR . "\Bin\x86\Hub.exe" . " " . runOpts
		if(FileExist(run1)){																; see if there is a test exe
			testExe := true
			}
		IfWinExist, Falcon BMS Launcher
		{
			MsgBox, Launcher Is Already Up -- Exiting
			ExitApp
		}

		IfWinNotExist, Falcon BMS Launcher
		{	
			run, *runas %r2%
			WinWait, Falcon BMS Launcher, , 3
			if ErrorLevel
			{
				MsgBox, WinWait timed out.
				return
			}
		}
		
		If(64_32 == 64){												; Click the desired exe bin type

			WinActivate, Falcon BMS Launcher
			MouseClick, left,  564,  65

		}else{

			WinWaitActive, Falcon BMS Launcher
			MouseClick, left,  569,  47

		}
		sleep 100

		WinWaitActive, Falcon BMS Launcher, 
		MouseClick, left,  305,  131
		
		run1 := BMS_DIR . "\Bin\" . bin . "\" . runexe		
		if(testExe){																	; a test exe exists -- expect a decision 
			WinWaitActive, Confirm	
;			winMove, 10,10
;			msgbox wait
			sleep 100
			if(devTest){
				WinActivate, Confirm
				Send y
			}else{
				WinActivate, Confirm
				Send n
			}
		}		
		ExitApp
	}											;; end of 4.34
	

}												;; end of launch1

;
;=================================================================================================================================================================================================================================
;----------------------------------------------------------------------------------------- T O O L S  B U T T O N   P R O C E S S I N G  -----------------------------------------------------------------------------------------
;=================================================================================================================================================================================================================================
;
;
;-------------- L A U N C H  CONFIG  B U T T O N  --------------------------------------------
;
Config:
{
	runStr = "%BMS_DIR%\Config.exe"
		RunwAIT, *RunAs %runStr% , %BMS_DIR%
		RETURN
		}
;
;-------------- L A U N C H  DOCS  B U T T O N  --------------------------------------------
;
docs:
{
	runStr = "%BMS_DIR%\Docs"
		Run,  %runStr%
		Gui, Mbg:Show
		goto LaunchHandler
		RETURN
		}
;
;-------------- L A U N C H  COCKPIT DISPLAY  B U T T O N  --------------------------------------------
;
display:
{
	runStr = "%BMS_DIR%\Bin\x86\Display Extraction.exe"
		RunwAIT, *RunAs %runStr% , %BMS_DIR%
		RETURN
		}
;
;-------------- L A U N C H  IVC CLIENT  B U T T O N  --------------------------------------------
;
ivcClient:
{
	runStr = "%BMS_DIR%\Bin\x86\IVC\IVC Client.exe"
		Run, *RunAs %runStr% , %BMS_DIR%\Bin\x86\IVC
		RETURN
		}

;
;-------------- L A U N C H  DB EDITOR  B U T T O N  --------------------------------------------
;
dbEdit:
{
If(64_32 == 64)
{
	runStr = "%BMS_DIR%\Bin\x64\Editor.exe" %runOpts%

}else{
	runStr = "%BMS_DIR%\Bin\x86\Editor.exe" %runOpts%
	}
RunwAIT, *RunAs %runStr% , %BMS_DIR%
RETURN
}
Closer:
GuiClose:
ExitApp
;
;=================================================================================================================================================================================================================================
;---------------------------------------------------------------------------------------------------- O P T I O N   P R O C E S S I N G  -----------------------------------------------------------------------------------------
;=================================================================================================================================================================================================================================
;

;
;-------------- IVC PASSWORD OPTION ENTRY   --------------------------------------------
;
ivcUpd:
ivcVUpd:
{
	guiControlGet ivcV
	if(ivcV == 1){
;		GuiControl, +checked, ivcV
		InputBox ivc_pw , IVC SERVER PASSWORD, Enter Password
		if ErrorLevel
			ivc_pw :=
		IniWrite, %ivcV%, %launchIni%, IVC_PW, val
		IniWrite, %ivc_pw%, %launchIni%, IVC_PW, pwd
		IniWrite, -w%ivc_pw%, %launchIni%, IVC_PW, txt
		GuiControl,, ivc_pwd, %ivc_pw%
		GuiControl, -Background, ivc_pwd
		GuiControl, Show, ivc_pwd
	}else{
;		GuiControl, -checked, ivcV
		GuiControl, +hidden, ivc_pwd
		IniWrite, %ivcV%, %launchIni%, IVC_PW, val
		IniWrite, "", %launchIni%, IVC_PW, pwd
		IniWrite, "", %launchIni%, IVC_PW, txt
		}
goto OptionsUpd
}
;
;-------------- 4.33 BANDWIDTH OPTION ENTRY   --------------------------------------------
;
bwUpd:
{
	guiControlGet bwV
	if(bwV == 1){
		GuiControl, +checked, bwV
		InputBox bwUv , Default Comms Bandwidth, Enter BW (kbs)
		if ErrorLevel
			bwUv := 1024
		IniWrite, %bwV%, %launchIni%, BW, val
		IniWrite, %bwUv%, %launchIni%, BW, bwUv
		IniWrite, -bw%bwUv%, %launchIni%, BW, txt
		GuiControl,, bwUv, %bwUv%
		GuiControl, Show, bwUv
	}else{
		GuiControl, -checked, vbwV
		GuiControl, +hidden, bwUv
		IniWrite, %bwV%, %launchIni%, BW, val
		IniWrite, "", %launchIni%, BW, bwUv
		IniWrite, "", %launchIni%, BW, txt
		}
GOTO OptionsUpd
}
;
;-------------- 4.34 BANDWIDTH OPTION ENTRY   --------------------------------------------
;
bwVUpd434:
{
	guiControlGet bwULV
	guiControlGet bwDLV
		IniWrite, %bwULV%, %launchIni%, yourUL, val
		IniWrite, %bwDLv%, %launchIni%, yourDL, val
;		GuiControl,, bwUv, %bwUv%
;		GuiControl, Show, bwUv

GOTO OptionsUpd
}
;
;-------------- 4.34 DEV TEST SWITCH   --------------------------------------------
;
devTest434:

if(DEV_OK){
	guiControlGet devTest
	if(devTest){															; switch to on
			If(64_32 == 64)
			{
				bin := "x64"
			}else{
				bin := "x86"
			}
		testExe := false
		run1 := BMS_DIR . "\Bin\" . bin . "\Falcon BMS Test.exe"							;test exe path
		if(FileExist(run1)){																; see if there is a test exe
			testExe := true

		}else{
			msgbox No Test EXE Found `n`nIGNORING REQUEST
			devTest = 0
			GuiControl, ,devTest, 0															; uncheck option
			GuiControl, ,devTestT,Use Test EXE
			}
	}		
		IniWrite, %devTest%, %launchIni%, devTest, val

GOTO OptionsUpd
}
;
;--------------  C O M M O N  O P T I O N S   P R O C E S S I N G   --------------------------------------------
;
bwVUpd:
OptionsUpdb:
OptionsUpd:
{
guiControlGet WindowV
guiControlGet MonoV
guiControlGet MovieV
guiControlGet AcmiV
guiControlGet EyeV
guiControlGet bwV
guiControlGet 64V
guiControlGet 32V
;guiControlGet devTest
if(DEV_OK){
	IniRead, %devTest%, %launchIni%, devTest, val
	}
if(64V == 1){
 64_32 := 64
 }
if(32V == 1){
 64_32 := 32
 }

; MsgBox, Window=%windowV% `r`nMono=%MonoV%`r`nMovie=%MovieV%`r`n64=%64V%`r`n32=%32V%`r`n64_32=%64_32%
;
;	Save current options in the ini file
;
IniWrite, %WindowV%, %launchIni%, Windowed, val
IniWrite, %MonoV%, %launchIni%, MonoLog, val
IniWrite, %MovieV%, %launchIni%, NoMovie, val
IniWrite, %AcmiV%, %launchIni%, Acmi, val
IniWrite, %EyeV%, %launchIni%, Eye, val
IniWrite, %bwV%, %launchIni%, BW, val
IniWrite, %64_32%, %launchIni%, 64_32, val

if(WindowV == 1){													;is it on?
		WindowT := " -window"
		IniWrite  %WindowT%, %launchIni%, Windowed, txt
		Gui, Font, norm bold underline cwhite
		GuiControl, Font ,WindowVt
		GuiControl, ,WindowVt ,WINDOWED
		GuiControl, move ,WindowVt ,w85
	}else{
		WindowT := ""
		IniWrite  %WindowT%, %launchIni%, Windowed, txt
		Gui, Font, norm	cwhite strike
		GuiControl, Font ,WindowVt
		GuiControl,,WindowVt ,windowed
		GuiControl, move ,WindowVt ,w85
		}
if(MonoV == 1){													;is it on?
		MonoT := " -mono"
		IniWrite, %MonoT%, %launchIni%, MonoLog, txt
		Gui, Font, norm bold underline cwhite
		GuiControl, Font ,MonoVt
		GuiControl, ,MonoVt ,MONO LOG
		GuiControl, move ,MonoVt ,w95
	}else{
		MonoT := ""
		IniWrite, %MonoT%, %launchIni%, MonoLog, txt
		Gui, Font, norm	cwhite strike
		GuiControl, Font ,MonoVt
		GuiControl,,MonoVt ,mono log
		GuiControl, move ,MonoVt ,w95
	}
if(MovieV == 1){													;is it on?
		MovieT := " -nomovie"
		IniWrite, %MovieT%, %launchIni%, NoMovie, txt
		Gui, Font, norm bold underline cwhite
		GuiControl, Font ,MovieVt
		GuiControl, ,MovieVt ,NO MOVIES
		GuiControl, move ,MovieVt ,w95
	}else{
		MovieT := ""
		IniWrite, %MovieT%, %launchIni%, NoMovie, txt
		Gui, Font, norm	strike cwhite
		GuiControl, Font ,MovieVt
		GuiControl, ,MovieVt ,no movies
		GuiControl, move ,MovieVt ,w95
	}
if(AcmiV == 1){													;is it on?
		AcmiT := " -acmi"
		IniWrite, %AcmiT%, %launchIni%, Acmi, txt
		Gui, Font, norm bold underline cwhite
		GuiControl, Font ,AcmiVt
		GuiControl, ,AcmiVt ,AUTO ACMI
		GuiControl, move ,AcmiVt ,w95
	}else{
		AcmiT := ""
		IniWrite, %AcmiT%, %launchIni%, Acmi, txt
		Gui, Font, norm cwhite strike
		GuiControl, Font ,AcmiVt
		GuiControl, ,AcmiVt ,auto acmi
		GuiControl, move ,AcmiVt ,w95
	}
if(EyeV == 1){													;is it on?
		EyeT := " -ef"
		IniWrite, %EyeT%, %launchIni%, Eye, txt
		Gui, Font, norm bold underline cwhite
		GuiControl, Font ,EyeVt
		GuiControl, ,EyeVt ,EYE FLY
		GuiControl, move ,EyeVt ,w60
	}else{
		EyeT := ""
		IniWrite, %EyeT%, %launchIni%, Eye, txt
		Gui, Font, norm STRIKE cwhite
		GuiControl, Font ,EyeVt
		GuiControl, ,EyeVt ,eye fly
		GuiControl, move ,EyeVt ,w60
	}
if(bwV == 1){													;is it on?
		Gui, Font, norm bold underline cwhite
		GuiControl, Font ,bwVt
		GuiControl, ,bwVt ,BW (KB)
		GuiControl, move ,bwVt ,w95
		bwT := " -bw" . bwUv
		IniWrite, %bwT%, %launchIni%, BW, txt
	}else{
		bwT := ""
		IniWrite, %bwT%, %launchIni%, BW, txt
		Gui, Font, norm STRIKE cwhite
		GuiControl, Font ,bwVt
		GuiControl, ,bwVt ,bw (kb)
		GuiControl, move ,EyeVt ,w95
	}
if(ivcV == 1){													;is it on?
		GuiControl, +checked, ivcV
		Gui, Font, norm bold underline cwhite
		GuiControl, Font ,ivcVt
		GuiControl, , ivcVt ,IVC SERV PWD
		GuiControl, move ,ivcVt ,w250
		ivcT := " -w " . ivc_pw
		IniWrite, %ivcT%, %launchIni%, IVC_PW, txt
		GuiControl, L:, ivcTxt  , IVC Server PW
		GuiControl, moveDraw ,L:ivcTxt ,w250
		GuiControl, L:, currPWD ,%ivc_pw%
		GuiControl, move ,L:currPWD ,w250
	}else{
		GuiControl, -checked, ivcV
		ivcT := ""
		IniWrite, %ivcT%, %launchIni%, IVC_PW, txt
		Gui, Font, norm STRIKE cwhite
		GuiControl, Font ,ivcVt
		GuiControl, , ivcVt ,ivc serv pwd
		GuiControl, move ,ivcVt ,w250
		GuiControl, L:, currPWD ,
		GuiControl, L:, ivcTxt ,
		GuiControl, move ,currPWD ,w250
		GuiControl, move ,ivcTxt ,w250
}
if(64V == 1){													;is it on?
		Gui, Font, norm bold underline cwhite
		GuiControl, Font ,64Vt
		GuiControl, ,64Vt , 64 BIT
		GuiControl, move ,64Vt ,w60
;	TURN OFF 32
		Gui, Font, norm STRIKE cwhite
		GuiControl, Font ,32Vt
		GuiControl, ,32Vt ,32 bit
		GuiControl, move ,32Vt ,w60
	}else{
;	TURN OFF 64
		Gui, Font, norm STRIKE cwhite
		GuiControl, Font ,64Vt
		GuiControl, ,64Vt ,64 bit
		GuiControl, move ,32Vt ,w60
		;	TURN ON 32
		Gui, Font, norm bold underline cwhite
		GuiControl, Font ,32Vt
		GuiControl, ,32Vt , 32 BIT
		GuiControl, move ,32Vt ,w60
	}
	
if(DEV_OK & devTest){													;dev test exe state?
;
;	Test fo a test EXE in Bin\.. folder
	If(64_32 == 64)
	{
		bin := "x64"
	}else{
		bin := "x86"
	}
		testExe := false
		run1 := BMS_DIR . "\Bin\" . bin . "\Falcon BMS Test.exe"							;test exe path
		if(FileExist(run1)){																; see if there is a test exe
			testExe := true
			Gui, Font, cwhite
			GuiControl, Font ,devBin
			GuiControl, L:,devBin ,  USE TEST EXE
			GuiControl, move ,devBin ,w200
		}else{
			Gui, Font, cwhite
			GuiControl, Font ,devBin
			GuiControl, L:,devBin ,  NO TEST EXE FOUND
			GuiControl, move ,devBin ,w200
			msgbox No Test EXE Found `n`nClearing Switch
			devTest = 0
			GuiControl, ,devTest, 0															; uncheck option
			IniWrite, %devTest%, %launchIni%, devTest, val									; remember in the ini
			}
	}else{															;	no test exe SELECTED
		Gui, Font, cwhite
		GuiControl, Font ,devBin
		GuiControl, L:,devBin ,  STOCK VERSION
		GuiControl, move ,devBin ,w200
	}

	
GuiControl, L:,currOpt ,Options: %WindowT% %MonoT% %MovieT% %AcmiT% `r`n %EyeT% %bwT%
GuiControl, moveDraw ,L:currOpt ,w250
GuiControl, L:,currBin , %64_32% bit
GuiControl, moveDraw ,L:currBin ,w250
 return
 }
;
;=================================================================================================================================================================================================================================
;------------------------------------------------------------------------------------------ T H E A T E R   G U I   P R O C E S S I N G  -----------------------------------------------------------------------------------------
;=================================================================================================================================================================================================================================
;
TheaterGui:
{
dataF := BMS_DIR . "\Data\"
theater_lst_loc := BMS_DIR . "\Data\Terrdata\theaterdefinition\theater.lst"
theater_lst_dir := BMS_DIR . "\Data\Terrdata\theaterdefinition"
ao := "Add-On "						; pattern for the check
terr := "Terrdata"
tRows :=5
;secW := (tabWdt/2)-20
secW := (tabWdt)-5
secH := tabHgt-10
gBox := 0
theaterArray := []
yOff := 10
xOff := 10
maxT := 0
Loop, read, %theater_lst_loc%
{
	If A_LoopReadLine=
	{
		empty := true
	}else{
		fChar := SubStr(A_LoopReadLine, 1, 1)
		If (fChar != "#")
		{
			tdf := dataF . A_LoopReadLine
			Loop
			{
				FileReadLine, line2, %tdf%, %A_Index%
;				MsgBox, "read: " %line2%
				line2 := RTrim(line2)
				if (SubStr(line2, 1, 5) == "name ")
				{
					numTheater++
					yOff := yOff+20
					radVar := numTheater<2 ? "vcT" : ""
					theaterName := SubStr(line2, 6)
					theaterArray[numTheater] := theaterName
					if(SubStr(line2, 6) == curTheater)
					{
							gui TH:Add, Radio, xs+%xOff% ys+%yOff% gchangeT %radVar% checked , %theaterName%

					}else{
				gui TH:Add, Radio, xs+%xOff% ys+%yOff% gchangeT %radVar%   , %theaterName%
					}
					break
				}

				if(numTheater > tRows and gBox == 0){
;					Gui, Add, GroupBox, xm+%secW%     ym+10  Section w%secW% h%secH% , Box #2
					xOff := (secW/2)-5
					yOff :=10
					gBox := 1
					}

			}								; inner loop end -- read for name in TDF file

		}									; not a # end
	}										; not empty line end
	maxT:= numTheater
}												; read loop end
If (empty)
{
	MsgBox, 4,, Empty lines found in Theater List`r`n   -- I can create a backup and remove blank lines`r`n`r`n CONTINUE?`r`n
	IfMsgBox Yes
	{
		FileCopy, %theater_lst_loc%, %theater_lst_dir%\theater.bak, 1
		fWork=%theater_lst_dir%\theater.wrk
			ifexist,%fWork%
			filedelete,%fWork%
		Loop, read, %theater_lst_loc%
		{
			If A_LoopReadLine=
			{

			}else{
				if(A_Index == 1)
				{
					fileappend, %A_LoopReadLine%, %fWork%
				}else{
					fileappend, `n%A_LoopReadLine%, %fWork%
				}
;				MsgBox, %A_Index%
			}
		}
		FileCopy, %fWork%, %theater_lst_dir%\theater.lst, 1
		MsgBox Theater List Updated -- Old Version Saved to:`r`n`r %theater_lst_dir%\theater.bak
;		Gui TH:Destroy
;		goto ChangeTheater
return
	}else{
		MsgBox Program will exit, please edit your list located at:`r`n`r%theater_lst_loc%
		return
	}
}

return
}
;
;--------------  C H A N G E  T H E A T E R   P R O C E S S I N G   --------------------------------------------
;
changeT:
{
	Gui, TH:submit, nohide
	tt := theaterArray[cT]

    MsgBox, 4, , Change theater to %tt%.  Continue?
	   IfMsgBox, No
	   return
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, curTheater, %tt%
		RegRead, curTheater, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, curTheater

		GuiControl, L:, CTheater , Theater`r`n %curTheater%		;update current theater on launch page 
		gui, L:submit, nohide
return
}
;
;=================================================================================================================================================================================================================================
;------------------------------------------------------------------------------------- P H O N E  B O O K   G U I   P R O C E S S I N G  -----------------------------------------------------------------------------------------
;=================================================================================================================================================================================================================================
;

;
;----------------   F I L L   P H O N E   B O O K  ----------------
;
pbFill:

Loop
{
 Entry := "Contact " . A_Index
		IniRead, Name, %phonebook%, %Entry%, Description
;		msgbox %Name%
			if(Name == "ERROR"){
				break
				}
		IniRead, Server_IP, %phonebook%, %Entry%, IPaddress
		IniRead, Voice_IP, %phonebook%, %Entry%, Voicehostip
		IniRead, IVC_PWD, %phonebook%, %Entry%, VoicehostPwd
	if(!DEV_OK){																	; EXTRA BW VALUE IN 4.34
		IniRead, BW, %phonebook%, %Entry%, SetBandWidth
		LV_Add("", Entry, Name, Server_IP, Voice_IP, IVC_PWD, BW)
		}else{
		IniRead, UBW, %phonebook%, %Entry%, SetBwUpload		
		IniRead, DBW, %phonebook%, %Entry%, SetBwDownload	
					
			LV_Add("", Entry, Name, Server_IP, Voice_IP, IVC_PWD, DBW, UBW)
			}
	LV_ModifyCol()  ; Auto-size each column to fit its contents.

}


NumRows := LV_GetCount()

return

;
;----------------   L I S T  V I E W  E V E N T S  ----------------
;
ListViewEvents:

    if(A_GuiEvent == "RightClick")
        {
        LV_GetText(C1, A_EventInfo, 1)
        LV_GetText(C2, A_EventInfo, 2)
		LV_GetText(C3, A_EventInfo, 3)
		LV_GetText(C4, A_EventInfo, 4)
		LV_GetText(C5, A_EventInfo, 5)
		LV_GetText(C6, A_EventInfo, 6)
			if(DEV_OK){														; EXTRA BW VALUE IN 4.34
				LV_GetText(C7, A_EventInfo, 7)
				}
        gosub,Modify1
        return
        }
    if A_GuiEvent=K
       {
       GetKeyState,state,DEL        ;- << DELETE
       if state=D
         {
         RowNumber:=LV_GetNext()
         LV_Delete(RowNumber)
         gosub,Modify2
         return
        }
      return
      }
RETURN
;--------------------------------------------------------------



;----------------   MODIFY  ----------------
;	 modify1 shows the edit window
;
;	 modify2 writes the changes
;
Modify1:
RowNumber := LV_GetNext()
ModAdd:
Gui,3: +AlwaysonTop
Gui,3: Font, s10, Verdana
gui, 3:listview, LV%Tabnumber%
Gui, 3:Add, Text, x10 y21 w75 h25 +Center, Entry
Gui, 3:Add, Text, x92 y21 w280 h30 vC1, %C1%
Gui, 3:Add, Text, x11 y51 w76 h29 +Center, Name
Gui, 3:Add, Edit, x92 y46 w280 h30 vC2, %C2%
Gui, 3:Add, Text, x12 y91 w79 h31 +Center, IP
Gui, 3:Add, Edit, x92 y86 w280 h30 vC3, %C3%					
Gui, 3:Add, Text, x12 y131 w74 h28 +Center, IVC IP
Gui, 3:Add, Edit, x92 y126 w280 h30 vC4, %C4%
Gui, 3:Add, Text, x12 y171 w80 h30 +Center, IVC PWD
Gui, 3:Add, Edit, x92 y166 w280 h30 vC5, %C5%

if(!DEV_OK){													; EXTRA BW VALUE IN 4.34
	Gui, 3:Add, Text, x12 y211 w80 h30 +Center, B/W
	Gui, 3:Add, Edit, x93 y206 w280 h30 vC6, %C6%
}else{
	Gui, 3:Add, Text, x12 y211 w80 h30 +Center, DOWN B/W
	Gui, 3:Add, Edit, x93 y206 w280 h30 vC6, %C6%	
	Gui, 3:Add, Text, x12 y251 w80 h30 +Center, UP B/W
	Gui, 3:Add, Edit, x93 y246 w280 h30 vC7, %C7%
	}
Gui, 3:Add, Button, x22 y309 w90 h30 gACCEPT1, Accept

Gui, 3:Add, Button, x152 y309 w80 h30 gPB_DELETE, DELETE

Gui, 3:Add, Button, x292 y309 w70 h30 gCANCEL1, Cancel
Gui,3:show,center, Modify or Delete Entry
return
;
;----------------   ACCEPT  ----------------
;
accept1:
Gui,3:default
Gui,3:submit,nohide
gui 3:listview, LV%Tabnumber%
;RowNumber := LV_GetNext()
c1:= % c1
c2:= % c2
;
;get the changes from the edit window
lv_modify(rownumber, "col1" , C1 )
lv_modify(rownumber, "col2" , C2 )
lv_modify(rownumber, "col3" , C3 )
lv_modify(rownumber, "col4" , C4 )
lv_modify(rownumber, "col5" , C5 )
if(!DEV_OK){													; EXTRA BW VALUE IN 4.34
	lv_modify(rownumber, "col6" , C6 )
}else{
	lv_modify(rownumber, "col6" , C6 )
	lv_modify(rownumber, "col7" , C7 )
	}
gosub,modify2
Gui,3:destroy
Gui,PB:destroy
goto pb_build
return

;
;---------------- D E L E T E --------------
;
PB_DELETE:
IniDelete, %phonebook%, %C1%
;msgbox num %RowNumber%
;msgbox nr %NumRows%

x1 := RowNumber + 1
	next := Substr(C1, 1, 8) . x1
while, x1 < NumRows + 1
{
;	msgbox next = %next%
	minus1 := Substr(next, 1, 8) . x1-1
	IniRead, clip, %phonebook%, %next%
;	msgbox read= %clip%
	IniWrite, %clip%, %phonebook%, %minus1%
	IniDelete, %phonebook%, %next%
	x1++
	next := Substr(next, 1, 8) . x1
}

Gui,3:destroy
gui, PB:destroy
goto pb_build
return

;
;----------------   CANCEL  ----------------
;
cancel1:
3Guiclose:
Gui,3:destroy
Gui,PB:destroy
goto pb_build
return
;
;------------------- Write Modified Text -------------------------
;
Modify2:

ControlGet,AA,List,,SysListView32%tabnumber%,%MainWindowTitle%        ;<< the correct name of listview

IniWrite, %A_Space%%C2%, %phonebook%, %C1%, Description
IniWrite, %A_Space%%C3%, %phonebook%, %C1%, IPaddress
IniWrite, %A_Space%%C4%, %phonebook%, %C1%, Voicehostip
IniWrite, %A_Space%%C5%, %phonebook%, %C1%, VoicehostPwd
if(!DEV_OK){																			; EXTRA BW VALUE IN 4.34
	IniWrite, %A_Space%%C6%, %phonebook%, %C1%, SetBandWidth
}else{
	IniWrite, %A_Space%%C6%, %phonebook%, %C1%, SetBwDownload
	IniWrite, %A_Space%%C7%, %phonebook%, %C1%, SetBwUpload
	}
return

;
;---------------- H E L P   B U T T O N  --------------
;
PB_Help:
MsgBox Right Click to modify an entry`r`n`nClick ADD_ROW to make a new entry `r`n --- and then right click to enter information
return

;
;---------------- A D D   N E W  --------------
;
AddNew1:
pbNew := true
n_entry := "Contact " . Numrows+1
if(!DEV_OK){																				; EXTRA BW VALUE IN 4.34
	Pre := "Description = NEW`nProtocol = 4`nType = 0`nCOMPort = 0`nBaudrate = 0`nLANrate = 0`nWANrate = 0`nJetnetrate = 0`nModemrate = 0`nParity = 0`nStopbits = 0`nFlowcontrol = 0`nIPaddress =0.0.0.0`nPhonenumber = `nVoicehostip=`nVoicehostPwd =`nSetBandWidth = "
}ELSE{
	Pre := "Description = NEW`nProtocol = 4`nType = 0`nCOMPort = 0`nBaudrate = 0`nLANrate = 0`nWANrate = 0`nJetnetrate = 0`nModemrate = 0`nParity = 0`nStopbits = 0`nFlowcontrol = 0`nIPaddress =0.0.0.0`nPhonenumber = `nVoicehostip=`nVoicehostPwd =`nSetBwDownload=" . yourDL . "`nSetBwUpload= " . yourUL
	}
;msgbox "new" %n_entry% `r`n %pre%
IniWrite, %pre%, %phonebook%, %n_entry%

gui, PB:destroy
goto pb_build
return
