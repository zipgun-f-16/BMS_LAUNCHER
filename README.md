# BMS_LAUNCHER
Launch Interface for Falcon BMS 4.33

This program is an alternative to the released Falcon BMS Launcher.  It allows you to easily customize your pre-launch options, select your starting theater, modify your MP-session phone book, and launch IVC and BMS with one button.

It installs an ini file in your ..\User\Config folder named Launcher.ini.  It also installs a PNG image used as the background.  The ini file has a version parameter to ensure your options are updated with new releases.  If you receive a warning, simply delete your Launcher.ini file and let the new release reinstall it.

The program has five pages:

LAUNCH: This is the default screen and provides the Launch buttons, and a preview of your current pre-launch conditions.

Options: This screen provides configuration of BMS command-line options and the entry of a password for your IVC Server (if desired). See page 20 of the BMS manual for more information on these options.

Tools: This page launches other tools supplied with BMS.  Please refer to the BMS Manual for more information.

Theaters: This page presents a menu of your installed theaters, showing your currently active theater.  Prior to launching Falcon BMS, you can select your desired theater and skip the native select-and-reload behavior. If your theater file contains blank lines it will be detected and the utility will offer to correct your TDF file.

PhoneBook: The BMS program does not support copy-paste into the COMM menu (phone book). This page will present your current phone book showing the valid, modern fields.  You can modify or delete an entry by a RIGHT click on the desired line. To add a line, click ADD_ROW and then modify (RIGHT CLICK) to enter your information.

This is beta software, please back-up any files prior to use (theater.tdf, and phonebook.ini are modified by the utility).

Thanks for trying it and watch for future enhancements.

;
;   BMS LAUNCHER by ZIPGUN  ©2018
;	V0.2	14Jul18
;
