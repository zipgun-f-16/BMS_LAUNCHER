#SingleInstance force
;
;   BMS LAUNCHER by ZIPGUN  ©2018
;	V0.2	14Jul18
;
G_Start:
{
;
;look for ini - if not there, create one
BMS_VER := "Falcon BMS 4.33 U1"

if (DEV ==1)
{
	BMS_VER := "Falcon BMS 4.34 (Internal)"
}
RegRead, BMS_DIR, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, baseDir	
RegRead, curTheater, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, curTheater
fileOK := true
launchIni := BMS_DIR . "\User\Config\Launcher.ini"
			try{
			FileOpen( launchIni, "r")	;; try to move the file to itself -- checks for an open file
			} catch e {													;; see if there was an error
				if(A_LastError != 2){
					msgbox Can not open INI file -- Error %A_LastError%
					ExitApp
					}
				fileOK := false
				}
if(!fileOK){
	IniWrite, val=0`ntxt=, %launchIni%, Windowed
	IniWrite, val=0`ntxt= , %launchIni%, MonoLog
	IniWrite, val=`ntxt=, %launchIni%, NoMovie
	IniWrite, val=0`ntxt=, %launchIni%, Acmi
	IniWrite, val=0`ntxt=, %launchIni%, Eye
	IniWrite, val=0`nbwUv=1024`ntxt=, %launchIni%, BW
	IniWrite, val=0`npwd=`ntxt=, %launchIni%, IVC_PW
	IniWrite, val=64, %launchIni%, 64_32
	IniWrite, Key=Falcon BMS 4.33 U1\, %launchIni%, BMS_Version
	IniWrite, ver=v.2, %launchIni%, Launcher
}
				
	IniRead, iniVer, %launchIni%, Launcher, ver
if(iniVer!= "v.2"){
	msgBox Wrong Version`r`n - Delete Launcher.ini from your Config folder`r`n - And restart
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
DEV	:= 0
mainUp := 0
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
bgImage := BMS_DIR . "\User\Config\launcher.png"
ifNotExist, %bgImage%
	fileInstall, C:\out\launch\launcher.png, %bgImage%
}
MainFlow:
{
;optA := []
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
/*
optA[1] := WindowV
optA[2] := MonoV
optA[3] := MovieV
optA[4] := AcmiV
optA[5] := EyeV
optA[6] := bwV
optA[7] := ivcV
*/
if(64_32 == 0){
	64V = 0
	32V = 1
;	optA[8] := 0
;	optA[9] := 1
	}
if(64_32 == 1){
	64V = 1
	32V = 0
;	optA[8] := 1
;	optA[9] := 0
	}
empty := false  ;used in blank line check
}
;--------------------------------------------
;				G U I   B U I L D
;--------------------------------------------
;
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
CustomColor =  0xD6D6D6
;
;-------------- launch    G U I
;
{
gui, L:new, +LastFound +AlwaysOnTop  +ToolWindow
Gui, L:Color, %CustomColor%
Gui, L:Menu, MenuBar
Gui, L:Add, Picture, xm+0 ym+0 0x4000000 vback +AltSubmit, %bgImage%
;Gui, L:Add, Picture, xm+0 ym+0 0x4000000 vback +AltSubmit, %A_ScriptDir%\launcher.png
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
Gui, L:Add, Text, xs+12 ys+120 w250 +E0x20 +BackgroundTrans cWhite vcurrOpt R3 gOptionHandler, Options: %curOpts%
Gui, L:Add, Text, xs+12 ys+200 w250 +E0x20 +BackgroundTrans cWhite vcurrBin  gOptionHandler,  %binVer%
if(ivcV == 1){
		Gui, L:Add, Text, xs+60 ys+200 w250 +E0x20  +BackgroundTrans cWhite center vivcTxt  , IVC Server PW
		Gui, L:Add, Text, xs+60 ys+220 w250 +E0x20  +BackgroundTrans cWhite center vcurrPWD  givcVUpd, %ivc_pw%		
	}else{
		Gui, L:Add, Text, xs+60 ys+200 w250 +E0x20  +BackgroundTrans cWhite center  vivcTxt , 
		Gui, L:Add, Text, xs+60 ys+220 w250 +E0x20 +BackgroundTrans cWhite center vcurrPWD  givcVUpd,
	}
		Gui, Font, s4 
		Gui, L:Add, Text, xs+10 ys+240 w50 +E0x20 +BackgroundTrans cWhite,©2018 ZIPGUN  
;Gui, Font, s10 bold, Verdana  

WinSet, TransColor, %CustomColor%
}
;
;-------------- options   G U I
;
{
gui, O:new, +LastFound  +ToolWindow
Gui, O:Color, %CustomColor%
Gui, O:Menu, MenuBar
Gui, O:Add, Picture, xm+0 ym+0 0x4000000 vback +AltSubmit, %A_ScriptDir%\launcher.png
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
if(ivcV == 1){
		
		Gui, O:Add, CheckBox, xs+150 ys+70 w12 h12 vivcV givcUpd +Checked,		
		Gui, O:Font, bold underline
		Gui, O:Add, text, xs+175 ys+68 w105 vivcVt BackgroundTrans +E0x20 cWhite , IVC SERV PWD
		Gui, O:Font, norm		
		Gui, O:Add, text, xs+110 ys+110 w180 vivc_pwd givcVUpd  -Background, %ivc_pw%
	}else{
	
		Gui, O:Add, CheckBox, xs+150 ys+70 w12 h12 vivcV givcUpd ,
		Gui, O:Font, norm strike
		Gui, O:Add, text, xs+175 ys+68 w95 vivcVt  BackgroundTrans +E0x20 cWhite , ivc serv pwd
		Gui, O:Font, norm	
		Gui, O:Add, text, xs+110 ys+110 w180 vivc_pwd givcVUpd , ____
		GuiControl, +hidden, ivc_pwd
		
	}
;------------------- 32-64 radio
;	
{
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
	
Gui, O:Font, s10 , Verdana
Gui, O:Add, Text, +center cWhite +BackgroundTrans +E0x20 ,`r`r`rSee BMS Manual Pg. 20
Gui, O:Font, s10 , Verdana 
;Gui, Add, BUTTON, xs%closeX% ys%closeY%  gLaunchHandler  +Border, Return
WinSet, TransColor, %CustomColor%
}
}			; end of options gui
;
;-------------- tools
;
{
num := 6
;Gui, Tab, Tools
gui, TO:new, +LastFound +ToolWindow
Gui, TO:Menu, MenuBar
Gui, TO:Add, Picture, xm+0 ym+0 0x4000000 vback +AltSubmit, %A_ScriptDir%\launcher.png
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
Gui, TO:Add, BUTTON, xs%closeX% ys%closeY%  gLaunchHandler cWhite +Border, Return
WinSet, TransColor, %CustomColor%
}
;
;---------- DISPLAY WINDOW
;
{
Gui, L:Show, , BMS Launcher
return
}
LaunchHandler:
{
	Gui,+LastFound
	WinGetPos,mainx, mainy,mainw,mainh
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
	WinGetPos,mainx, mainy,mainw,mainh


;	WinSet, TransColor, %CustomColor%
;	Gui, O:Show, , Options
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
	WinGetPos,mainx, mainy,mainw,mainh
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
	WinGetPos,mainx, mainy,mainw,mainh

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
	WinGetPos,mainx, mainy,mainw,mainh
		Gui, L:Hide
	Gui, TO:HIDE
	Gui, TH:HIDE
	Gui, O:HIDE
gosub pb_build
return
}
;
;-------------- theaters
;
BuildTheaterGui:
{
gui, TH:new, +LastFound +ToolWindow
Gui, TH:Menu, MenuBar
Gui, TH:Add, Picture, xm+0 ym+0 0x4000000 vback +AltSubmit, %A_ScriptDir%\launcher.png
Gui, TH:Add, GroupBox, xm+%tabX% ym+%tabY%  w%tabWdt% h%tabHgt%  Section w%secW% h%secH% hwndTHbox E0x00000020 ,
	gosub TheaterGui
theaterBuilt := true
return
}
;Gui, Add, Button, x%closeX% y%closeY% w50 h20 gCloser, Close
Gui, Font, s10 bold, Verdana  

;
;-------------- phonebook
;Gui, Tab, Phonebook
gosub pb_build
Return
;
;-------------- L A U N C H   B U T T O N S  --------------------------------------------
;
Launch2:
{
IniRead, ivcT, %launchIni%, IVC_PW, txt
	runStr = "%BMS_DIR%\Bin\x86\IVC\IVC Server.exe" 
	Run, *RunAs %runStr% %ivcT% 
	sleep 10
	}
Launch1:
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
;		MsgBox, %runStr%
		runStr = "%BMS_DIR%\Bin\x64\Falcon BMS.exe" %runOpts%

	}else{
		runStr = "%BMS_DIR%\Bin\x86\Falcon BMS.exe" %runOpts%
;		MsgBox, "run %BMS_DIR%Bin\x86\%runOpts%
		}
	Run, *RunAs %runStr% , %BMS_DIR%
ExitApp	
}
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
;-------------- BANDWIDTH OPTION ENTRY   --------------------------------------------
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

}
;
;-------------- O P T I O N S   P R O C E S S I N G   --------------------------------------------
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
if(64V == 1){
 64_32 := 64
 }
if(32V == 1){
 64_32 := 32
 }
; MsgBox, Window=%windowV% `r`nMono=%MonoV%`r`nMovie=%MovieV%`r`n64=%64V%`r`n32=%32V%`r`n64_32=%64_32%
IniWrite, %WindowV%, %launchIni%, Windowed, val
IniWrite, %MonoV%, %launchIni%, MonoLog, val
IniWrite, %MovieV%, %launchIni%, NoMovie, val
IniWrite, %AcmiV%, %launchIni%, Acmi, val
IniWrite, %EyeV%, %launchIni%, Eye, val
IniWrite, %bwV%, %launchIni%, BW, val
IniWrite, %64_32%, %launchIni%, 64_32, val
if(WindowV == 1){													;change
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
if(MonoV == 1){													;change
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
if(MovieV == 1){													;change
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
if(AcmiV == 1){													;change
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
if(EyeV == 1){													;change
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
if(bwV == 1){													;change
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
if(ivcV == 1){													;change
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
if(64V == 1){													;change
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
GuiControl, L:,currOpt ,Options: %WindowT% %MonoT% %MovieT% %AcmiT% `r`n %EyeT% %bwT%
GuiControl, moveDraw ,L:currOpt ,w250
GuiControl, L:,currBin , %64_32% bit
GuiControl, moveDraw ,L:currBin ,w250

 return
 }
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
;-------------- L A U N C H  AVIONICS CONFIG  B U T T O N  --------------------------------------------
;	
AvConfig:
{
	runStr = "%BMS_DIR%\Bin\x86\Avionics Configurator.exe"
		RunwAIT, *RunAs %runStr% , %BMS_DIR%\Bin\x86"
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
changeT:
{
	Gui, TH:submit, nohide	
	tt := theaterArray[cT]

/*	
loop, maxT{
	if(cT%A_Index% == 1){
		newTheater := 
	}
}
*/		
;    LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.
;    ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"
    MsgBox, 4, , Change theater to %tt%.  Continue?
	   IfMsgBox, No
	   return
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, curTheater, %tt%
		RegRead, curTheater, HKEY_LOCAL_MACHINE\SOFTWARE\Benchmark Sims\%BMS_VER%, curTheater	

		GuiControl, L:, CTheater , Theater`r`n %curTheater%
		gui, L:submit, nohide
return
}
pb_build:
gui, PB:new, +LastFound +ToolWindow
Gui, PB:Menu, MenuBar
Gui,PB: Font,CDefault,Fixedsys
Gui,PB: Margin, 10, 10
Gui, PB:Add, ListView,  w700 h600 grid cWhite backgroundteal hwndpbLV1 vpbLV1 gListViewEvents +altsubmit -multi, Entry|Name|Server_IP|Voice_IP|IVC_PWD|BW
            gosub pbFill
            Gui,PB:add,button,  Default gAddNew1,ADD_ROW
           Gui,PB:add,button,  x+5 gPB_Help,-=HELP=-
		   Gui, PB:Add, StatusBar,%A_Space%
			SB_SetParts(800/3, 800/3)		
;			SB_SetText("RIGHT CLICK ENTRY LINE TO MODIFY", 1, 2)
gui, PB: show, x%mainx% y%mainy% w800 h700, RIGHT CLICK ENTRY LINE TO MODIFY or DELETE
;
;-------- SCROLL CLICK MESSAGE
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
		IniRead, BW, %phonebook%, %Entry%, SetBandWidth
			LV_Add("", Entry, Name, Server_IP, Voice_IP, IVC_PWD, BW)
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
Modify1:
RowNumber := LV_GetNext()
ModAdd:
Gui,3: +AlwaysonTop
Gui,3: Font, s10, Verdana
gui, 3:listview, LV%Tabnumber%
Gui, 3:Add, Text, x10 y21 w75 h25 +Center, Entry
Gui, 3:Add, Text, x92 y19 w280 h30 vC1, %C1%
Gui, 3:Add, Text, x11 y69 w76 h29 +Center, Name
Gui, 3:Add, Edit, x92 y69 w280 h30 vC2, %C2%
Gui, 3:Add, Text, x12 y117 w79 h31 +Center, IP
Gui, 3:Add, Edit, x92 y119 w280 h30 vC3, %C3%
Gui, 3:Add, Text, x12 y170 w74 h28 +Center, IVC IP
Gui, 3:Add, Edit, x92 y169 w280 h30 vC4, %C4%
Gui, 3:Add, Text, x12 y219 w80 h30 +Center, IVC PWD
Gui, 3:Add, Edit, x92 y219 w280 h30 vC5, %C5%
Gui, 3:Add, Text, x12 y269 w80 h30 +Center, B/W
Gui, 3:Add, Edit, x93 y268 w280 h30 vC6, %C6%
Gui, 3:Add, Button, x22 y309 w90 h30 gACCEPT1, Accept
;if(!pbNew){
		Gui, 3:Add, Button, x152 y309 w80 h30 gPB_DELETE, DELETE
;	}else{
;		pbNew := False
;	}
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
lv_modify(rownumber, "col1" , C1 )
lv_modify(rownumber, "col2" , C2 )
lv_modify(rownumber, "col3" , C3 )
lv_modify(rownumber, "col4" , C4 )
lv_modify(rownumber, "col5" , C5 )
lv_modify(rownumber, "col6" , C6 )
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
IniWrite, %A_Space%%C6%, %phonebook%, %C1%, SetBandWidth

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

Pre := "Description = NEW`nProtocol = 4`nType = 0`nCOMPort = 0`nBaudrate = 0`nLANrate = 0`nWANrate = 0`nJetnetrate = 0`nModemrate = 0`nParity = 0`nStopbits = 0`nFlowcontrol = 0`nIPaddress =0.0.0.0`nPhonenumber = `nVoicehostip=`nVoicehostPwd =`nSetBandWidth = "
;msgbox "new" %n_entry% `r`n %pre%
IniWrite, %pre%, %phonebook%, %n_entry%
/*
IniWrite, %A_Space%%C2%, , %n_entry%, Description
IniWrite, %A_Space%%C3%, %phonebook%, %n_entry%, IPaddress
IniWrite, %A_Space%%C4%, %phonebook%, %n_entry%, Voicehostip
IniWrite, %A_Space%%C5%, %phonebook%, %n_entry%, VoicehostPwd
IniWrite, %A_Space%%C6%, %phonebook%, %n_entry%, SetBandWidth
*/
gui, PB:destroy
goto pb_build
return