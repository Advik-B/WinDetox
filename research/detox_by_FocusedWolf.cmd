@echo off
REM Version 46
title Cleanup
color 02

:CheckPermissions
    fltmc >nul 2>&1 || (
        echo Requesting administrative privileges...
        start cmd /c powershell.exe -Command "Start-Process cmd -Verb runas -ArgumentList '/c \"\"%~s0\"\" %*'"
        exit /b 0
    )

REM This file is used to clean Windows, Steam, and various other programs.
REM
REM NOTE: Before using this script, you need to run this command at least once to configure what gets cleaned by Disk Cleanup when its called by the script:
REM $ cleanmgr /sageset:1

REM http://www.codeproject.com/Tips/119828/Running-a-bat-file-as-administrator-Correcting-cur
setlocal enableextensions enabledelayedexpansion
cd /d "%~dp0"

if /i "%~1" == "nopause" (
    set NOPAUSE=1
) else (
    set NOPAUSE=0
)

if /i "%~2" == "simplecleaning" (
    set SIMPLECLEANING=1
) else (
    set SIMPLECLEANING=0
)

if /i "%~2" == "normalcleaning" (
    set NORMALCLEANING=1
) else (
    set NORMALCLEANING=0
)

if /i "%~2" == "fullcleaning" (
    set FULLCLEANING=1
) else (
    set FULLCLEANING=0
)

:Choice
    set CLEAN_UNIX_FILES=0
    set CLEAN_EVENT_LOG=0
    set RUN_SYSTEM_FILE_CHECKER_TOOL=0
    set RUN_STEAM_REPAIR_TOOL=0

    REM set RUN_CLEANMGR=1
    REM Disabled so i could move the code to DiskCleanup.bat.
    REM Didn't see a reason to delete it though.
    set RUN_CLEANMGR=0

    if /i "%SIMPLECLEANING%" equ "1" (
        set CLEAN_UNIX_FILES=0
        set CLEAN_EVENT_LOG=0
        set RUN_SYSTEM_FILE_CHECKER_TOOL=0
        set RUN_STEAM_REPAIR_TOOL=0
        set RUN_CLEANMGR=0
        goto :Work
    )

    if /i "%NORMALCLEANING%" equ "1" (
        set CLEAN_UNIX_FILES=0
        set CLEAN_EVENT_LOG=1
        set RUN_SYSTEM_FILE_CHECKER_TOOL=0
        set RUN_STEAM_REPAIR_TOOL=0

        REM set RUN_CLEANMGR=1
        REM Disabled so i could move the code to DiskCleanup.bat.
        REM Didn't see a reason to delete it though.
        set RUN_CLEANMGR=0

        goto :Work
    )

    if /i "%FULLCLEANING%" equ "1" (
        set CLEAN_UNIX_FILES=0
        set CLEAN_EVENT_LOG=1
        set RUN_SYSTEM_FILE_CHECKER_TOOL=1
        set RUN_STEAM_REPAIR_TOOL=1

        REM set RUN_CLEANMGR=1
        REM Disabled so i could move the code to DiskCleanup.bat.
        REM Didn't see a reason to delete it though.
        set RUN_CLEANMGR=0

        goto :Work
    )

:PROMPT_ONE
    cls
    set /p CLEAN_UNIX_FILES=Clean macOS and Linux metadata [0^|1]:
    if /i "%CLEAN_UNIX_FILES%" equ "0" goto :PROMPT_TWO
    if /i "%CLEAN_UNIX_FILES%" equ "1" goto :PROMPT_TWO
    goto :PROMPT_ONE
:PROMPT_TWO
    cls
    set /p CLEAN_EVENT_LOG=Clean Event Log [0^|1]:
    if /i "%CLEAN_EVENT_LOG%" equ "0" goto :PROMPT_THREE
    if /i "%CLEAN_EVENT_LOG%" equ "1" goto :PROMPT_THREE
    goto :PROMPT_TWO
:PROMPT_THREE
    cls
    set /p RUN_SYSTEM_FILE_CHECKER_TOOL=Run System File Checker tool [0^|1]:
    if /i "%RUN_SYSTEM_FILE_CHECKER_TOOL%" equ "0" goto :PROMPT_FOUR
    if /i "%RUN_SYSTEM_FILE_CHECKER_TOOL%" equ "1" goto :PROMPT_FOUR
    goto :PROMPT_THREE
:PROMPT_FOUR
    cls
    set /p RUN_STEAM_REPAIR_TOOL=Run Steam Repair tool [0^|1]:
    if /i "%RUN_STEAM_REPAIR_TOOL%" equ "0" goto :Work
    if /i "%RUN_STEAM_REPAIR_TOOL%" equ "1" goto :Work
    goto :PROMPT_FOUR

:CleanUnixFiles
    setlocal

    REM macOS crap removal.
    REM SOURCE: https://ardamis.com/2010/08/10/clean-up-those-mac-osx-hidden-files/

    if /i "%CLEAN_UNIX_FILES%" equ "1" (
        REM I took out C because why do Windows and AppData?
        for %%I in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do if exist %%I:\ (
            dir "%%I:\" > nul 2>&1
            if !errorlevel! equ 0 (
                echo.
                echo Removing macOS and Linux metadata from drive: %%I:\

                cd /d %%I:\

                REM http://en.wikipedia.org/wiki/Resource_fork
                del /f /s /q /a ._*

                REM http://en.wikipedia.org/wiki/.DS_Store
                del /f /s /q /a .DS_Store

                rd /s /q .fseventsd
                rd /s /q .Spotlight-V100

                REM http://en.wikipedia.org/wiki/Recycle_bin_(computing)
                rd /s /q .Trashes

                REM Linux specific.
                rd /s /q .Trash-1000
            )
        )
    )

    endlocal & goto :eof

:CleanChkdskFiles
    setlocal

    REM When a boot-time Chkdsk runs it creates bootsqm.dat and bootTel.dat files on every scanned drive.
    REM NOTE: I removed the /s option so it doesn't delete from subdirectories (which was causing a slow down). I think these files are only created at the top level of the drives.
    for %%I in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
        if exist "%%I:\bootsqm.dat" (
            del /f /s /q /a "%%I:\bootsqm.dat"
        )

        if exist "%%I:\bootTel.dat" (
            del /f /s /q /a "%%I:\bootTel.dat"
        )
    )

    endlocal & goto :eof

:CleanAdobe
    setlocal

    for /d %%D in ("%AppData%\Adobe\CCX Welcome\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Adobe\CCX Welcome\*"

    for /d %%D in ("%AppData%\Adobe\Common\Peak Files\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Adobe\Common\Peak Files\*"

    for /d %%D in ("%AppData%\Adobe\Common\Media Cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Adobe\Common\Media Cache\*"

    for /d %%D in ("%AppData%\Adobe\Common\Media Cache Files\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Adobe\Common\Media Cache Files\*"

    endlocal & goto :eof

:CleanOkular
    setlocal

    REM Delete the okular settings directory which contains recent-file data in the "\docdata" subdirectory.
    rd /s /q "%LocalAppData%\okular"

    REM Delete the okular settings file which contains a recent-files list.
    del /f /s /q /a "%LocalAppData%\okularrc"

    endlocal & goto :eof

:CleanOneNote
    setlocal

    for /d %%D in ("%LocalAppData%\Microsoft\OneNote\16.0\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Microsoft\OneNote\16.0\*"

    endlocal & goto :eof

:CleanMirc
    setlocal

    for /d %%D in ("%AppData%\mIRC\logs\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\mIRC\logs\*"

    endlocal & goto :eof

:CleanAtom
    setlocal

    REM Remove old versions.
    set directory=%LocalAppData%\atom
    set pathname="%directory%\app-*"
    set LatestVersionPath=""
    for /f %%d in ('dir %pathname% /b /a:d /o:d') do set LatestVersionPath="%directory%\%%d"
    if /i not %LatestVersionPath%=="" (
        REM echo Latest version detected: %LatestVersionPath%
        for /f %%d in ('dir %pathname% /b /a:d /o:d') do (
            if /i not "%directory%\%%d"==%LatestVersionPath% (
                echo Removing old version: "%directory%\%%d"
                rd /s /q "%directory%\%%d"
            )
        )
    )

    endlocal & goto :eof

:CleanDiscord
    setlocal

    for /d %%D in ("%AppData%\Discord\Cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Discord\Cache\*"

    REM Remove old versions.
    set directory=%LocalAppData%\Discord
    set pathname="%directory%\app-*"
    set LatestVersionPath=""
    for /f %%d in ('dir %pathname% /b /a:d /o:d') do set LatestVersionPath="%directory%\%%d"
    if /i not %LatestVersionPath%=="" (
        REM echo Latest version detected: %LatestVersionPath%
        for /f %%d in ('dir %pathname% /b /a:d /o:d') do (
            if /i not "%directory%\%%d"==%LatestVersionPath% (
                echo Removing old version: "%directory%\%%d"
                rd /s /q "%directory%\%%d"
            )
        )
    )

    endlocal & goto :eof

:CleanVirtualBox
    setlocal

    for /d %%D in ("%LocalAppData%\VirtualBox Dropped Files\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\VirtualBox Dropped Files\*"

    endlocal & goto :eof

:CleanVMware
    setlocal

    for /d %%D in ("%LocalAppData%\VMware\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\VMware\*"

    endlocal & goto :eof

:CleanJetBrainsDotPeek
    setlocal

    for /d %%D in ("%LocalAppData%\JetBrains\dotPeek\vAny\DecompilerCache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\JetBrains\dotPeek\vAny\DecompilerCache\*"

    endlocal & goto :eof

:CleanVisualStudio
    setlocal

    for /d %%D in ("%LocalAppData%\Microsoft\Web Platform Installer\installers\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Microsoft\Web Platform Installer\installers\*"

    for /d %%D in ("%UserProfile%\.nuget\packages\*") do rd /s /q "%%D"
    del /f /s /q /a "%UserProfile%\.nuget\packages\*"

    REM -----

    REM Scan for, and prompt for deletion of, "\TestResults" directories generated by unit-test projects.
    REM for /d /r "D:\Users\Wolf\Files\Archives\Projects\Visual Studio" %%D in (*TestResults) do rd /s "%%D"

    REM For all "TestResults" folders in my "Visual Studio" projects directory:
    REM     Delete all Deploy_Wolf folders in the TestResults folders.
    REM     Delete the parent folder if it is empty.
    REM echo. Searching to destroy Unit Test results in: D:\..\Visual Studio\..\..\TestResults

    REM for /d /r "D:\Users\Wolf\Files\Archives\Projects\Visual Studio" %%D in (*TestResults) do (
    REM     echo.
    REM     echo.Found: %%D

    REM     for /f "tokens=*" %%I in ('dir /b /a "%%D\Deploy_Wolf*"') do (
    REM         echo. Deleting TestResult: "%%D\%%I"
    REM         rd /s /q "%%D\%%I"
    REM     )

    REM     dir /b /a "%%D\*" | >nul findstr . && (
    REM         echo. * NOT deleting parent folder: Unknown files or folders found.
    REM     ) || (
    REM         echo. Deleting empty parent folder: "%%D"
    REM         rd /s /q "%%D"
    REM     )

    REM     echo.-----
    REM )

    endlocal & goto :eof

:CleanVSCode
    setlocal

    for /d %%D in ("%AppData%\Code\Cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Code\Cache\*"

    for /d %%D in ("%AppData%\Code\CachedData\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Code\CachedData\*"

    for /d %%D in ("%AppData%\Code\CachedExtensions\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Code\CachedExtensions\*"

    for /d %%D in ("%AppData%\Code\User\History\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Code\User\History\*"

    endlocal & goto :eof

:CleanNuGetCache
    setlocal

    REM SOURCE: https://docs.microsoft.com/en-us/nuget/consume-packages/managing-the-global-packages-and-cache-folders

    REM Clear the 3.x+ cache (use either command)
    dotnet nuget locals http-cache --clear
    REM  nuget locals http-cache -clear

    REM Clear the 2.x cache (NuGet CLI 3.5 and earlier only)
    REM  nuget locals packages-cache -clear

    REM Clear the global packages folder (use either command)
    dotnet nuget locals global-packages --clear
    REM  nuget locals global-packages -clear

    REM Clear the temporary cache (use either command)
    dotnet nuget locals temp --clear
    REM  nuget locals temp -clear

    REM Clear the plugins cache (use either command)
    dotnet nuget locals plugins-cache --clear
    REM  nuget locals plugins-cache -clear

    REM Clear all caches (use either command)
    dotnet nuget locals all --clear
    REM  nuget locals all -clear

    REM SOURCE: https://stackoverflow.com/questions/30933277/how-can-i-clear-the-nuget-package-cache-using-the-command-line?answertab=createdasc#tab-top
    del /f /s /q /a "%LocalAppData%\NuGet\Cache\*"

    endlocal & goto :eof

:CleanSmartGit
    setlocal

    REM Remove old versions.
    set directory=%AppData%\syntevo\SmartGit
    REM findstr lacks regex '+' operator so '[.0-9]+' expands to '[.0-9][.0-9]*'.
    set pattern="[.0-9][.0-9]*$"
    set LatestVersionPath=""
    for /f %%d in ('dir "%directory%" /b /a:d /o:d ^| findstr %pattern%') do (
        if %errorlevel% equ 0 (
            set LatestVersionPath="%directory%\%%d"
        )
    )
    if /i not %LatestVersionPath%=="" (
        REM echo Latest version detected: %LatestVersionPath%
        for /f %%d in ('dir "%directory%" /b /a:d /o:d ^| findstr %pattern%') do (
            if /i not "%directory%\%%d"==%LatestVersionPath% (
                echo Removing old version: "%directory%\%%d"
                rd /s /q "%directory%\%%d"
            )
        )
    )

    REM -----

    REM Remove old versions.
    set directory=%ProgramData%\chocolatey\lib\smartgit\tools
    REM findstr lacks regex '+' operator so '[0-9]+' expands to '[0-9][0-9]*'.
    set pattern="[0-9][0-9_]*-setup\.exe$"
    set LatestVersionPath=""
    for /f %%f in ('dir "%directory%" /b /a:-d /o:d ^| findstr %pattern%') do (
        if %errorlevel% equ 0 (
            set LatestVersionPath="%directory%\%%f"
        )
    )
    if /i not %LatestVersionPath%=="" (
        REM echo Latest version detected: %LatestVersionPath%
        for /f %%f in ('dir "%directory%" /b /a:-d /o:d ^| findstr %pattern%') do (
            if /i not "%directory%\%%f"==%LatestVersionPath% (
                echo Removing old version: "%directory%\%%f"
                del /f /s /q /a "%directory%\%%f"
            )
        )
    )

    endlocal & goto :eof

:CleanWindows
    setlocal

    REM -----

    if /i "%RUN_CLEANMGR%" equ "1" (
        REM NOTE: Run [$ Cleanmgr /sageset:1] to configure the set of items Cleanmgr will clean when started like this.
        start "" /wait Cleanmgr /sagerun:1
    )

    REM -----

    REM Run the System File Checker tool.
    REM SOURCE: https://support.microsoft.com/en-us/help/929833/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system
    REM SOURCE: https://answers.microsoft.com/en-us/windows/forum/all/event-viewer-error-when-creating-custom-view/dcf3203b-0258-4621-a724-1a674a702472
    if /i "%RUN_SYSTEM_FILE_CHECKER_TOOL%" equ "1" (
        Dism /Online /Cleanup-Image /Scanhealth
        Dism /Online /Cleanup-Image /Restorehealth
        sfc /scannow
        echo.
    )

    REM -----

    REM WinSxS cleanup.

    REM SOURCE: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder
    REM SOURCE: https://answers.microsoft.com/en-us/windows/forum/all/is-it-safe-dism-online-cleanup-image-spsuperseded/5efb8e9c-0d13-45d8-9b11-38abe61c9828
    REM SOURCE: https://blogs.technet.microsoft.com/askpfeplat/2014/05/13/how-to-clean-up-the-winsxs-directory-and-free-up-disk-space-on-windows-server-2008-r2-with-new-update/
    REM SOURCE: https://www.maketecheasier.com/clean-component-store-windows10/
    REM SOURCE: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder

    REM Displays information about the component store.
    Dism /Online /Cleanup-Image /AnalyzeComponentStore

    REM Cleanup service pack backup files
    Dism /Online /Cleanup-Image /SpSuperseded

    REM Deletes previous versions of updated components.
    REM StartComponentCleanup also exists as a Task Scheduler task that runs every 30 days on startup, so instead of waiting 30 days for cleanup you can delete that crap now.
    REM "Using the /StartComponentCleanup parameter of Dism.exe on a running version of Windows 10 or later gives you similar results to running the StartComponentCleanup task in Task Scheduler,
    REM except previous versions of updated components will be immediately deleted (without a 30 day grace period) and you will not have a 1-hour timeout limitation.": https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder
    Dism /Online /Cleanup-Image /StartComponentCleanup

    REM Removes all superseded versions of every component in the component store.
    REM Using this option removes the ability to uninstall the latest update.
    REM This cleaned the 9000+ files i had in C:\Windows\WinSxS\Temp\PendingRenames\
    Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase

    REM -----

    REM M$ is slow to fix the MMC error in event viewer. This is a workaround.
    REM SOURCE: https://www.bleepingcomputer.com/news/microsoft/windows-10-v1903-v1809-updates-break-event-viewer-custom-views/
    REM SOURCE: https://www.winhelponline.com/blog/windows-10-v1903-19h1-is-available-now/#eventvwr
    icacls "%ProgramData%\Microsoft\Event Viewer\Views\view_*.xml" /grant administrators:RX
    icacls "%ProgramData%\Microsoft\Event Viewer\Views\view_*.xml" /inheritance:r
    REM To revert the .xml file permissions to default, run this command:
    REM icacls "%ProgramData%\Microsoft\Event Viewer\Views\view_*.xml" /reset

    REM -----

    REM Rebuild Windows Management Instrumentation service files.
    REM SOURCE: https://www.reddit.com/r/GlobalOffensive/comments/brgvlw/i_finally_fixed_my_csgo_game_freezes_fps_drops_it/

    for /l %%x in (0,1,5) do (
        sc config winmgmt start= disabled
        net stop winmgmt /y
        sc query winmgmt | find /i "running"
        if !errorlevel! equ 1 (
            echo Windows Management Instrumentation service was successfully stopped...
            echo.
            del /f /s /q /a "%WinDir%\System32\wbem\Repository\*"
            goto :DoneDeletingWMIRepository
        )

        echo.
        echo Windows Management Instrumentation service still running...
        echo.
        timeout 1 > nul
    )
:DoneDeletingWMIRepository
    set count=0
    for %%A in (%WinDir%\System32\wbem\Repository\*) do set /a count+=1

    if /i "%count%" GTR "0" (
        echo.
        echo ERROR: Windows Management Instrumentation service prevented deletion of repository files.
        echo %count% files were not deleted.
        echo.
    )

    sc query winmgmt | find /i "running"
    if !errorlevel! equ 1 (
        echo.
        echo Restarting Windows Management Instrumentation service...
        echo.
        sc config winmgmt start= auto
        net start winmgmt
    )

    REM -----

    REM Clean logs.
    REM SOURCE: https://www.technipages.com/files-folders-you-can-safely-delete-in-windows-10
    REM SOURCE: https://forum.piriform.com/topic/34206-please-default-to-not-clean-windows-log-files/

    attrib -r -s -h "%WinDir%\Debug\*" /s /d
    for /d %%D in ("%WinDir%\Debug\*") do rd /s /q "%%D"
    del /f /s /q /a "%WinDir%\Debug\*"

    attrib -r -s -h "%WinDir%\Logs\*" /s /d
    for /d %%D in ("%WinDir%\Logs\*") do rd /s /q "%%D"
    del /f /s /q /a "%WinDir%\Logs\*"

    del /f /s /q /a "%WinDir%\inf\*.log"
    del /f /s /q /a "%WinDir%\Microsoft.NET\*.log"
    del /f /s /q /a "%WinDir%\Panther\*.log"
    del /f /s /q /a "%WinDir%\security\logs\*.log"
    del /f /s /q /a "%WinDir%\security\logs\*.old"
    del /f /s /q /a "%WinDir%\ServiceProfiles\LocalService\AppData\*.log"
    del /f /s /q /a "%WinDir%\ServiceProfiles\NetworkService\AppData\*.log"
    del /f /s /q /a "%WinDir%\SoftwareDistribution\*.log"
    REM NOTE: These lack /s so they are not recursive and only delete explicitly from safe-according-to-the-internet locations inside %WinDir%.
    REM With /s these could delete things from every subdirectory of %WinDir%\ which might be dangerous.
    del /f /s /q /a "%WinDir%\*.bak"
    del /f /s /q /a "%WinDir%\*.log"
    del /f /s /q /a "%WinDir%\*log.txt"

    REM Some files will give access-denied when you try to delete them but i found about 250 files that could be deleted.
    attrib -r -s -h "%ProgramData%\USOShared\Logs\*" /s /d
    for /d %%D in ("%ProgramData%\USOShared\Logs\*") do rd /s /q "%%D"
    del /f /s /q /a "%ProgramData%\USOShared\Logs\*"

    REM -----

    REM Clean crash dumps and error reports.

    for /d %%D in ("%WinDir%\Minidump\*") do rd /s /q "%%D"
    del /f /s /q /a "%WinDir%\Minidump\*"

    del /f /s /q /a "%WinDir%\*.mdmp"
    del /f /s /q /a "%WinDir%\*.dmp"
    del /f /s /q /a "%ProgramData%\*.mdmp"
    del /f /s /q /a "%ProgramData%\*.dmp"

    for /d %%D in ("%ProgramData%\Microsoft\Windows\WER\*") do rd /s /q "%%D"
    del /f /s /q /a "%ProgramData%\Microsoft\Windows\WER\*"

    REM -----

    attrib -r -s -h "%WinDir%\Prefetch\*" /s /d
    for /d %%D in ("%WinDir%\Prefetch\*") do rd /s /q "%%D"
    del /f /s /q /a "%WinDir%\Prefetch\*"

    REM -----

    REM Clean temp files.

    attrib -r -s -h "%WinDir%\Temp\*" /s /d
    for /d %%D in ("%WinDir%\Temp\*") do rd /s /q "%%D"
    del /f /s /q /a "%WinDir%\Temp\*"

    attrib -r -s -h "%ProgramData%\Temp\*" /s /d
    for /d %%D in ("%ProgramData%\Temp\*") do rd /s /q "%%D"
    del /f /s /q /a "%ProgramData%\Temp\*"

    REM -----

    REM Delete all files in %WinDir%\SoftwareDistribution\Download\ and C:\WUDownloadCache\
    net stop wuauserv /y
    net stop bits /y

    for /d %%D in ("%WinDir%\SoftwareDistribution\Download\*") do rd /s /q "%%D"
    del /f /s /q /a "%WinDir%\SoftwareDistribution\Download\*"

    for /d %%D in ("C:\WUDownloadCache\*") do rd /s /q "%%D"
    del /f /s /q /a "C:\WUDownloadCache\*"

    net start wuauserv
    net start bits

    REM -----

    REM Clean Event Logs.
    REM SOURCE: based on https://www.tenforums.com/tutorials/16588-clear-all-event-logs-event-viewer-windows-4.html

    if /i "%CLEAN_EVENT_LOG%" equ "1" (
        net stop NcdAutoSetup /y
        net stop netprofm /y
        net stop NlaSvc /y
        net stop EventLog /y

        del /f /s /q /a "%WinDir%\System32\winevt\Logs\*"

        net start EventLog
        net start NlaSvc
        net start netprofm
        net start NcdAutoSetup

        timeout /t 5

        for /f "tokens=*" %%g in ('wevtutil.exe el') do (
            echo clearing "%%g"
            wevtutil.exe cl "%%g"
        )

        echo.
        echo Event Logs have been cleared.
        echo.
    )

    REM -----

    REM Update Clock.

    net start w32time

    w32tm.exe /query /status /verbose

    w32tm.exe /config /manualpeerlist:"time.nist.gov pool.ntp.org" /syncfromflags:manual /update
    w32tm.exe /resync

    w32tm.exe /query /status /verbose

    REM -----

    REM Clean ARP Cache.

    arp -a
    netsh interface ip delete arpcache
    arp -a

    REM -----

    REM Flush AppCompatCache

    rundll32.exe kernel32.dll,BaseFlushAppcompatCache

    REM -----

    endlocal & goto :eof

:CleanWindowsUserData
    setlocal

    REM taskkill /f /im explorer.exe
    REM timeout /t 5

    REM Clear File Explorer History in Windows 10
    REM SOURCE: https://www.tenforums.com/tutorials/6712-clear-file-explorer-history-windows-10-a.html#option2
    del /f /s /q /a "%AppData%\Microsoft\Windows\Recent\*"
    del /f /s /q /a "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*"
    del /f /s /q /a "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*"

    REM TODO: An all-users limitation here because it only cleans for the current user
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /va /f
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /va /f

    REM timeout /t 5
    REM start explorer.exe

    REM -----

    REM Clean logs (User Specific).
    REM SOURCE: https://www.technipages.com/files-folders-you-can-safely-delete-in-windows-10
    REM SOURCE: https://forum.piriform.com/topic/34206-please-default-to-not-clean-windows-log-files/

    del /f /s /q /a "%LocalAppData%\Microsoft\Windows\*.log"
    del /f /s /q /a "%AppData%\..\LocalLow\Microsoft\Windows\*.log"
    del /f /s /q /a "%AppData%\Microsoft\Windows\*.log"

    REM -----

    REM Clean crash dumps and error reports (User Specific).

    for /d %%D in ("%LocalAppData%\CrashDumps\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\CrashDumps\*"

    REM Delete all .dmp files in app subdirectories
    del /f /s /q /a "%LocalAppData%\Packages\*.dmp"

    for /d %%D in ("%LocalAppData%\Microsoft\Windows\WER\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Microsoft\Windows\WER\*"

    REM -----

    REM Clean temp files (User Specific).

    REM %Temp% is an alias for %LocalAppData%\Temp
    REM attrib -r -s -h "%Temp%\*" /s /d
    REM for /d %%D in ("%Temp%\*") do rd /s /q "%%D"
    REM del /f /s /q /a "%Temp%\*"

    REM NOTE: If running these commands manually in cmd then replace %%D with %D.

    attrib -r -s -h "%LocalAppData%\Temp\*" /s /d
    for /d %%D in ("%LocalAppData%\Temp\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Temp\*"

    attrib -r -s -h "%AppData%\..\LocalLow\Temp\*" /s /d
    for /d %%D in ("%AppData%\..\LocalLow\Temp\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\..\LocalLow\Temp\*"

    attrib -r -s -h "%AppData%\Temp\*" /s /d
    for /d %%D in ("%AppData%\Temp\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Temp\*"

    REM -----

    REM Stop Scheduledtask.
    schtasks /end /tn "\Microsoft\Windows\Wininet\CacheTask"

    net stop COMSysApp /y
    taskkill /f /im dllhost.exe
    taskkill /f /im taskhost.exe
    taskkill /f /im taskhostex.exe

    for /d %%D in ("%LocalAppData%\Microsoft\Windows\INetCache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Microsoft\Windows\INetCache\*"

    del /f /s /q /a "%LocalAppData%\Microsoft\Windows\WebCache\*"

    net start COMSysApp

    REM -----

    endlocal & goto :eof

:CleanNVIDIA
    setlocal

    REM Remove Nvidia installer cache files left over by Nvidia after driver install.
    REM http://nvidia.custhelp.com/app/answers/detail/a_id/3333/%7E/disk-space-used-when-installing-nvidia-drivers
    REM Deletion of the Installer2 folder will not affect any of your currently installed NVIDIA drivers or software.
    REM At most, it will prevent complete installs from occurring in the case of using an older driver from the OS driver store.
    REM
    REM Q: I've performed a "clean install" and then uninstalled the drivers from my system, but files remain in the Installer2 folder.
    REM A: It is likely that you have performed some combination of multiple install/over-install/uninstall cycles and files from older drivers
    REM are left in the folder. The "clean install" removes only the current driver files before installing the new driver.
    REM In this case, the simplest way to remove the files is to delete the Installer2 folder.
    attrib -r -s -h "%ProgramFiles%\NVIDIA Corporation\Installer2\*" /s /d
    for /d %%D in ("%ProgramFiles%\NVIDIA Corporation\Installer2\*") do rd /s /q "%%D"
    del /f /s /q /a "%ProgramFiles%\NVIDIA Corporation\Installer2\*"

    REM Delete Nvidia crash dumps.
    attrib -r -s -h "%ProgramData%\NVIDIA Corporation\CrashDumps\*" /s /d
    for /d %%D in ("%ProgramData%\NVIDIA Corporation\CrashDumps\*") do rd /s /q "%%D"
    del /f /s /q /a "%ProgramData%\NVIDIA Corporation\CrashDumps\*"

    REM Delete Nvidia driver downloads.
    REM SOURCE: https://www.howtogeek.com/342322/why-does-nvidia-store-gigabytes-of-installer-files-on-your-hard-drive/
    for /d %%D in ("%ProgramData%\NVIDIA Corporation\Downloader\*") do rd /s /q "%%D"
    del /f /s /q /a "%ProgramData%\NVIDIA Corporation\Downloader\*"

    REM -----

    REM Clean Nvidia caches (User Specific).

    REM Nvidia cache locations: https://www.reddit.com/r/EscapefromTarkov/comments/g06vzk/some_things_to_check_after_the_not_only_this_file/?utm_medium=android_app&utm_source=share

    for /d %%D in ("%AppData%\NVIDIA\ComputeCache\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\NVIDIA\ComputeCache\*"

    for /d %%D in ("%LocalAppData%\D3DSCache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\D3DSCache\*"

    for /d %%D in ("%LocalAppData%\NVIDIA Corporation\NV_cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\NVIDIA Corporation\NV_cache\*"

    for /d %%D in ("%LocalAppData%\NVIDIA\DXCache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\NVIDIA\DXCache\*"

    for /d %%D in ("%LocalAppData%\NVIDIA\GLCache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\NVIDIA\GLCache\*"

    for /d %%D in ("%ProgramData%\NVIDIA Corporation\NV_Cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%ProgramData%\NVIDIA Corporation\NV_Cache\*"

    for /d %%D in ("%UserProfile%\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache\*") do rd /s /q "%%D"
    del /f /s /q /a "%UserProfile%\AppData\LocalLow\NVIDIA\PerDriverVersion\DXCache\*"

    REM -----

    endlocal & goto :eof

:CleanFirefox
    setlocal

    REM Delete all .dmp and .extra files in firefox subdirectories
    del /f /s /q /a "%AppData%\Mozilla\Firefox\*.dmp"
    del /f /s /q /a "%AppData%\Mozilla\Firefox\*.extra"

    cd /d %LocalAppData%\Mozilla\Firefox\Profiles\**.default\
    if !errorlevel! equ 0 (
        for /f "delims=" %%i in ('dir cache2 /b') do (
            REM Delete %%i if its a folder.
            if exist "cache2\%%i\" (
                rd /s /q "cache2\%%i\"
            )
            REM Delete %%i if its a file.
            if exist "cache2\%%i" (
                del /f /s /q /a "cache2\%%i"
            )
        )
    )

    endlocal & goto :eof

:CleanWaterfox
    setlocal

    REM Delete all .dmp and .extra files in waterfox subdirectories
    del /f /s /q /a "%AppData%\Waterfox\*.dmp"
    del /f /s /q /a "%AppData%\Waterfox\*.extra"

    cd /d %LocalAppData%\Waterfox\Profiles\**.default\
    if !errorlevel! equ 0 (
        for /f "delims=" %%i in ('dir cache2 /b') do (
            REM Delete %%i if its a folder.
            if exist "cache2\%%i\" (
                rd /s /q "cache2\%%i\"
            )
            REM Delete %%i if its a file.
            if exist "cache2\%%i" (
                del /f /s /q /a "cache2\%%i"
            )
        )
    )

    cd /d %LocalAppData%\Waterfox\Profiles\**.68-edition-default\
    if !errorlevel! equ 0 (
        for /f "delims=" %%i in ('dir cache2 /b') do (
            REM Delete %%i if its a folder.
            if exist "cache2\%%i\" (
                rd /s /q "cache2\%%i\"
            )
            REM Delete %%i if its a file.
            if exist "cache2\%%i" (
                del /f /s /q /a "cache2\%%i"
            )
        )
    )

    endlocal & goto :eof

:CleanLibreWolf
    setlocal

    REM Delete all .dmp and .extra files in waterfox subdirectories
    del /f /s /q /a "%AppData%\LibreWolf\*.dmp"
    del /f /s /q /a "%AppData%\LibreWolf\*.extra"

    cd /d %LocalAppData%\LibreWolf\Profiles\**.default\
    if !errorlevel! equ 0 (
        for /f "delims=" %%i in ('dir cache2 /b') do (
            REM Delete %%i if its a folder.
            if exist "cache2\%%i\" (
                rd /s /q "cache2\%%i\"
            )
            REM Delete %%i if its a file.
            if exist "cache2\%%i" (
                del /f /s /q /a "cache2\%%i"
            )
        )
    )

    cd /d %LocalAppData%\LibreWolf\Profiles\**.dev-edition-default\
    if !errorlevel! equ 0 (
        for /f "delims=" %%i in ('dir cache2 /b') do (
            REM Delete %%i if its a folder.
            if exist "cache2\%%i\" (
                rd /s /q "cache2\%%i\"
            )
            REM Delete %%i if its a file.
            if exist "cache2\%%i" (
                del /f /s /q /a "cache2\%%i"
            )
        )
    )

    endlocal & goto :eof

:CleanEdge
    setlocal

    REM Delete Edge cache files.
    for /d %%D in ("%LocalAppData%\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\*"

    endlocal & goto :eof

:CleanGoogle
    setlocal

    REM Delete all .dmp files in google subdirectories
    del /f /s /q /a "%LocalAppData%\Google\*.dmp"

    REM Delete GoogleChrome cache
    del /f /s /q /a "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*"
    del /f /s /q /a "%LocalAppData%\Google\Chrome\User Data\Default\Media Cache\*"

    REM Delete GoogleChrome site data
    for /d %%D in ("%LocalAppData%\Google\Chrome\User Data\Default\File System\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Google\Chrome\User Data\Default\File System\*"

    REM Delete GoogleEarth Cache
    for /d %%D in ("%UserProfile%\AppData\locallow\Google\GoogleEarth\Cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%UserProfile%\AppData\locallow\Google\GoogleEarth\Cache\*"

    endlocal & goto :eof

:CleanDropbox
    setlocal

    REM Delete all Dropbox log files
    del /f /s /q /a "%ProgramData%\Dropbox\Update\Log"

    endlocal & goto :eof

:CleanOBS
    setlocal

    REM Delete all OBS log files
    del /f /s /q /a "%AppData%\obs-studio\logs"

    REM Delete all OBS crash files
    del /f /s /q /a "%AppData%\obs-studio\crashes"

    endlocal & goto :eof

:CleanVLC
    setlocal

    REM Delete VLC Cache
    for /d %%D in ("%AppData%\vlc\crashdump\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\vlc\crashdump\*"

    REM Delete VLC Art
    for /d %%D in ("%AppData%\vlc\art\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\vlc\art\*"

    endlocal & goto :eof

:CleanLibreOffice
    setlocal

    REM Delete crash dumps
    for /d %%d in ("%AppData%\LibreOffice\*") do (
        if exist "%%d\crash\" (
            rd /s /q "%%d\crash\"
        )
    )

    endlocal & goto :eof

:CleanSteam
    setlocal

    REM ----- Kill Steam -----

    REM echo Attempting to close steam.exe gently
    REM taskkill /im steam.exe >nul 2>&1
    REM timeout /t 32

    echo Attempting to kill steam.exe if its still alive
    taskkill /f /im steam.exe >nul 2>&1
    timeout /t 3

    REM ----- Determine Steam directory -----

    REM SOURCE: https://stackoverflow.com/a/12071458/490748
    set RegKey="HKEY_CURRENT_USER\Software\Valve\Steam"
    set RegValue=SteamPath
    for /f "usebackq skip=2 tokens=1-2*" %%i in (`reg query !RegKey! /v !RegValue!`) do (
        set Name=%%i
        set Type=%%j
        set Data=%%k

        REM Get Steam's directory.
        set SteamPath=!Data!
    )

    REM Change forward slash to back slash.
    set SteamPath=%SteamPath:/=\%

    REM Clean all Steam folder.
    REM NOTE: Originally i had to manually do this first [call :CleanSteamLibrary "%SteamPath%"],
    REM       but now Steam smartly lists "C:\Program Files (x86)\Steam" as library 0 in libraryfolders.vdf (even if you never created an additional library folder).
    REM SOURCE: https://github.com/Cr4zyy/FactorioServerTool/issues/1#issue-233513424
    for /f usebackq^ delims^=^"^ tokens^=2^,4 %%i in ("%SteamPath%\steamapps\libraryfolders.vdf") do (
        call :CleanSteamLibrary "%%j"
    )

    REM ----- Repair Steam -----

    if /i "%RUN_STEAM_REPAIR_TOOL%" equ "1" (
        if exist "%SteamPath%\bin\steamservice.exe" (
            start "Steam" /wait "%SteamPath%\bin\steamservice.exe" /repair
        )
    )

    REM ----- Restart Steam -----

    if %NOPAUSE% equ 0 (
        if exist "%SteamPath%\Steam.exe" (
            start "Steam" "%SteamPath%\Steam.exe"
        )
    )

    endlocal & goto :eof

:CleanSteamLibrary
    setlocal

    REM ~ removes the " ".
    set LibraryDirectory=%~1

    REM Change forward slash to back slash.
    set LibraryDirectory=%LibraryDirectory:/=\%

    REM Change double back slash to single back slash.
    set LibraryDirectory=%LibraryDirectory:\\=\%

    if not exist "%LibraryDirectory%" goto :eof

    echo.
    echo Clean Steam Library: %LibraryDirectory%

    REM Get game-drive letter.
    REM set GameDriveLetter=%LibraryDirectory:~0,2%
    REM echo Game-Drive Letter: %GameDriveLetter%

    REM ----- Steam cleaning -----

    REM Steam appcache
    REM WARNING: Deleting this causes "Steamworks Common Redistributables" to download when Steam is started.
    REM for /d %%D in ("%LibraryDirectory%\appcache\*") do rd /s /q "%%D"
    REM del /f /s /q /a "%LibraryDirectory%\appcache\*"

    REM Steam overlayhtmlcache
    for /d %%D in ("%LibraryDirectory%\config\overlayhtmlcache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\config\overlayhtmlcache\*"

    REM Steam dump files
    for /d %%D in ("%LibraryDirectory%\dumps\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\dumps\*"

    REM Steam log files
    del /f /s /q /a "%LibraryDirectory%\logs\*"

    REM ----- Steam Download Cache cleaning -----
    REM https://steamcommunity.com/discussions/forum/1/1698293068434253400/
    REM https://steamcommunity.com/discussions/forum/1/3315110799614461632/

    REM If you have any steam downloads then you will probably need to start them over because this will delete the download progress.
    REM for /d %%D in ("%LibraryDirectory%\steamapps\downloading\*") do rd /s /q "%%D"
    REM del /f /s /q /a "%LibraryDirectory%\steamapps\downloading\*"

    for /d %%D in ("%LibraryDirectory%\steamapps\temp\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\temp\*"

    for /d %%D in ("%LibraryDirectory%\steamapps\workshop\downloads\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\workshop\downloads\*"

    for /d %%D in ("%LibraryDirectory%\steamapps\workshop\temp\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\workshop\temp\*"

    REM -----------------------------------------

    REM Delete Steam shader cache.
    for /d %%D in ("%LibraryDirectory%\steamapps\shadercache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\shadercache\*"

    REM Delete all .mdmp files in the Steam directories.
    del /f /s /q /a "%LibraryDirectory%\*.mdmp"

    REM Delete all .mdmp files on game drive.
    REM del /f /s /q /a "%GameDriveLetter%\*.mdmp"

    REM ----- Game cleaning -----

    REM ----- Aim Lab -----

    REM ----- Apex Legends -----

    for /d %%D in ("%LibraryDirectory%\steamapps\common\Apex Legends\Crashpad\db\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\common\Apex Legends\Crashpad\db\*"

    REM ----- ARK -----

    for /d %%D in ("%LibraryDirectory%\steamapps\common\ARK\ShooterGame\Saved\Logs\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\common\ARK\ShooterGame\Saved\Logs\*"

    REM ----- ARMA 3 -----

    REM ----- Deep Rock Galactic -----

    for /d %%D in ("%LibraryDirectory%\steamapps\common\Deep Rock Galactic\FSD\Saved\Config\CrashReportClient\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\common\Deep Rock Galactic\FSD\Saved\Config\CrashReportClient\*"

    for /d %%D in ("%LibraryDirectory%\steamapps\common\Deep Rock Galactic\FSD\Saved\Crashes\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\common\Deep Rock Galactic\FSD\Saved\Crashes\*"

    for /d %%D in ("%LibraryDirectory%\steamapps\common\Deep Rock Galactic\FSD\Saved\Logs\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\common\Deep Rock Galactic\FSD\Saved\Logs\*"

    REM ----- Escape from Tarkov -----

    REM WARNING: Lots of hardcoded custom paths here.

    REM The launcher has a "Clean Temp Folder" button that deletes this directory.
    for /d %%D in ("K:\Battlestate Games\BsgLauncher\Temp\*") do rd /s /q "%%D"
    del /f /s /q /a "K:\Battlestate Games\BsgLauncher\Temp\*"

    REM I use this custom temp folder path.
    for /d %%D in ("E:\Tarkov\*") do rd /s /q "%%D"
    del /f /s /q /a "E:\Tarkov\*"

    REM The launcher has a "Clean Temp Folder" button that deletes the contents of this directory.
    REM The issue is this contains the icon cache and the game has to take longer to regenerate these if you delete them, which means more SSD writing.
    REM for /d %%D in ("%Temp%\Battlestate Games\*") do rd /s /q "%%D"
    REM del /f /s /q /a "%Temp%\Battlestate Games\*"

    REM Delete logs.
    for /d %%D in ("K:\Battlestate Games\Escape from Tarkov\Logs\*") do rd /s /q "%%D"
    del /f /s /q /a "K:\Battlestate Games\Escape from Tarkov\Logs\*"

    for /d %%D in ("K:\Battlestate Games\Escape from Tarkov Arena\Logs\*") do rd /s /q "%%D"
    del /f /s /q /a "K:\Battlestate Games\Escape from Tarkov Arena\Logs\*"

    REM ----- Natural Selection 2 -----

    REM ----- PAYDAY 2 -----

    for /d %%D in ("%LibraryDirectory%\steamapps\common\PAYDAY 2\mods\logs\*") do rd /s /q "%%D"
    del /f /s /q /a "%LibraryDirectory%\steamapps\common\PAYDAY 2\mods\logs\*"

    REM mod-update downloads in "%LibraryDirectory%\steamapps\common\PAYDAY 2\mods\downloads\*"
    del /f /s /q /a "%LibraryDirectory%\steamapps\common\PAYDAY 2\mods\downloads\*.zip"

    REM ----- PUBG -----

    REM Disable PUBG loading screen by deleting loading screen videos
    REM del /f /s /q /a "%LibraryDirectory%\steamapps\common\PUBG\TslGame\Content\Movies\*"

    REM Disable PUBG_Test loading screen by deleting loading screen videos
    REM del /f /s /q /a "%LibraryDirectory%\steamapps\common\PUBG_Test\TslGame\Content\Movies\*"

    REM ----- Rising Storm 2 -----

    REM ----- SCUM -----

    REM ----- VRChat -----

    endlocal & goto :eof

:CleanSteamUserData
    setlocal

    REM ----- Kill Steam -----

    REM echo Attempting to close steam.exe gently
    REM taskkill /im steam.exe >nul 2>&1
    REM timeout /t 32

    echo Attempting to kill steam.exe if its still alive
    taskkill /f /im steam.exe >nul 2>&1
    timeout /t 3

    REM ----- Steam cleaning -----

    REM Chromium Embedded Framework
    for /d %%D in ("%LocalAppData%\CEF\User Data\Crashpad\reports\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\CEF\User Data\Crashpad\reports\*"

    REM html5app htmlcache
    for /d %%D in ("%LocalAppData%\Steam\html5app\htmlcache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Steam\html5app\htmlcache\*"

    REM Steam htmlcache
    for /d %%D in ("%LocalAppData%\Steam\htmlcache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Steam\htmlcache\*"

    REM ----- Game cleaning -----

    REM ----- Aim Lab -----

    REM Delete crash reports.
    for /d %%D in ("%UserProfile%\AppData\locallow\Statespace\aimlab_tb\backtrace\*") do rd /s /q "%%D"
    del /f /s /q /a "%UserProfile%\AppData\locallow\Statespace\aimlab_tb\backtrace\*"

    REM ----- Aliens Colonial Marines -----

    REM Delete Aliens Colonial Marines crashes.
    for /d %%D in ("%LocalAppData%\Endeavor\Saved\Config\CrashReportClient\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Endeavor\Saved\Config\CrashReportClient\*"

    REM ----- Apex Legends -----

    for /d %%D in ("D:\Users\Wolf\Saved Games\Respawn\Apex\assets\*") do rd /s /q "%%D"
    del /f /s /q /a "D:\Users\Wolf\Saved Games\Respawn\Apex\assets\*"

    REM ----- ARK -----

    REM ----- ARMA 3 -----

    REM Delete all .rpt, .bidmp, and .mdmp files in "%LocalAppData%\Arma 3\" and subdirectories
    del /f /s /q /a "%LocalAppData%\Arma 3\*.rpt"
    del /f /s /q /a "%LocalAppData%\Arma 3\*.bidmp"
    del /f /s /q /a "%LocalAppData%\Arma 3\*.mdmp"

    del /f /s /q /a "%LocalAppData%\Arma 3\AnimDataCache\*"
    del /f /s /q /a "%LocalAppData%\Arma 3\MonetizedServersCache\*"
    del /f /s /q /a "%LocalAppData%\Arma 3\MPMissionsCache\*"
    del /f /s /q /a "%LocalAppData%\Arma 3\OfficialServersCache\*"

    for /d %%D in ("%LocalAppData%\Arma 3\squads\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Arma 3\squads\*"

    del /f /s /q /a "%LocalAppData%\Arma 3\SteamPreviewCache\*"
    del /f /s /q /a "%LocalAppData%\Arma 3 Launcher\Logs\*"

    REM ----- DOOM -----

    REM Delete all crash files in DOOM subdirectories
    del /f /s /q /a "D:\Users\Wolf\Saved Games\id Software\DOOM\base\Crash*.html"

    REM Delete all errorlog files in DOOM subdirectories
    del /f /s /q /a "D:\Users\Wolf\Saved Games\id Software\DOOM\base\ErrorLog*.txt"

    REM ----- DOOM Eternal -----

    REM Delete DOOM Eternal crashes.
    for /d %%D in ("D:\Users\Wolf\Saved Games\id Software\DOOMEternal\base\crashes\*") do rd /s /q "%%D"
    del /f /s /q /a "D:\Users\Wolf\Saved Games\id Software\DOOMEternal\base\crashes\*"

    REM ----- Escape from Tarkov -----

    REM Delete analytics.
    for /d %%D in ("%UserProfile%\AppData\locallow\Battlestate Games\*") do rd /s /q "%%D"
    del /f /s /q /a "%UserProfile%\AppData\locallow\Battlestate Games\*"

    REM Delete logs.
    for /d %%D in ("%LocalAppData%\Battlestate Games\BsgLauncher\Logs\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Battlestate Games\BsgLauncher\Logs\*"

    REM Delete launcher CEF cache.
    for /d %%D in ("%LocalAppData%\Battlestate Games\BsgLauncher\CefCache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Battlestate Games\BsgLauncher\CefCache\*"

    REM ----- Natural Selection 2 -----

    for /d %%D in ("%AppData%\Natural Selection 2\cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Natural Selection 2\cache\*"

    for /d %%D in ("%AppData%\Natural Selection 2\dumps\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Natural Selection 2\dumps\*"

    for /d %%D in ("%AppData%\Natural Selection 2\Workshop\*") do rd /s /q "%%D"
    del /f /s /q /a "%AppData%\Natural Selection 2\Workshop\*"

    REM ----- PAYDAY 2 -----

    REM Crash logs.
    del /f /s /q /a "%LocalAppData%\PAYDAY 2\crash.txt"
    del /f /s /q /a "%LocalAppData%\PAYDAY 2\crashlog.txt"

    REM ----- PUBG -----

    rd /s /q "%LocalAppData%\TslGame\Saved\Config\CrashReportClient\"
    rd /s /q "%LocalAppData%\TslGame\Saved\Crashes\"
    rd /s /q "%LocalAppData%\TslGame\Saved\Demos\"
    rd /s /q "%LocalAppData%\TslGame\Saved\ImGui\"
    rd /s /q "%LocalAppData%\TslGame\Saved\Logs\"
    rd /s /q "%LocalAppData%\TslGame\Saved\webcache\"

    REM ----- Rising Storm 2 -----

    del /f /s /q /a "%Documents%\My Games\Rising Storm 2\ROGame\Logs\*"

    REM ----- SCUM -----

    rd /s /q "%LocalAppData%\SCUM\Saved\Config\CrashReportClient\"
    rd /s /q "%LocalAppData%\SCUM\Saved\Crashes\"
    rd /s /q "%LocalAppData%\SCUM\Saved\Logs\"

    REM ----- Squad -----

    rd /s /q "%LocalAppData%\SquadGame\Saved\Config\CrashReportClient\"
    rd /s /q "%LocalAppData%\SquadGame\Saved\Crashes\"
    rd /s /q "%LocalAppData%\SquadGame\Saved\LicensedServerCache\"
    rd /s /q "%LocalAppData%\SquadGame\Saved\Logs\"

    REM Apparently the map icon scale, and other settings?, are saved to the %LocalAppData%\SquadGame\Saved\SaveGames\SquadUI.sav file.
    REM rd /s /q "%LocalAppData%\SquadGame\Saved\SaveGames\"

    REM ----- VRChat -----

    for /d %%D in ("%UserProfile%\AppData\locallow\VRChat\*") do rd /s /q "%%D"
    del /f /s /q /a "%UserProfile%\AppData\locallow\VRChat\*"

    endlocal & goto :eof

REM TODO: Move whatever is useful to :CleanEAapp.
REM
REM  :CleanOrigin
REM      setlocal
REM
REM      REM ----- Kill Origin -----
REM
REM      REM echo Attempting to close Origin.exe gently
REM      REM taskkill /im Origin.exe >nul 2>&1
REM      REM timeout /t 32
REM
REM      echo Attempting to kill Origin.exe if its still alive
REM      taskkill /f /im Origin.exe >nul 2>&1
REM      timeout /t 3
REM
REM      REM ----- Origin cleaning -----
REM
REM      cd /d %ProgramData%
REM      if !errorlevel! equ 0 (
REM          REM Delete all the files and folders inside \Origin except for "LocalContent" because we're not supposed to for some reason: https://help.ea.com/en-us/help/faq/clear-cache-to-fix-problems-with-your-games/
REM          for /f "delims=" %%i in ('dir Origin /a /b') do (
REM              if /i "%%i" NEQ "LocalContent" (
REM                  REM Delete %%i if its a folder.
REM                  if exist "Origin\%%i\" (
REM                      rd /s /q "Origin\%%i\"
REM                  )
REM                  REM Delete %%i if its a file.
REM                  if exist "Origin\%%i" (
REM                      del /f /s /q /a "Origin\%%i"
REM                  )
REM              )
REM          )
REM      )
REM
REM      REM ----- Determine Origin directory -----
REM
REM      REM TODO
REM
REM      REM ----- Repair Origin -----
REM
REM      REM TODO
REM
REM      REM ----- Restart Origin -----
REM
REM      if %NOPAUSE% equ 0 (
REM          REM if exist "%SteamPath%\Steam.exe" (
REM          REM     start "Steam" "%SteamPath%\Steam.exe"
REM          REM )
REM
REM          if exist "G:\Origin\Origin.exe" (
REM              start "Origin" "G:\Origin\Origin.exe"
REM          )
REM      )
REM
REM      endlocal & goto :eof
REM
REM  :CleanOriginUserData
REM      setlocal
REM      REM SOURCE: https://help.ea.com/en-us/help/faq/clear-cache-to-fix-problems-with-your-games/
REM
REM      REM ----- Kill Origin -----
REM
REM      REM echo Attempting to close Origin.exe gently
REM      REM taskkill /im Origin.exe >nul 2>&1
REM      REM timeout /t 32
REM
REM      echo Attempting to kill Origin.exe if its still alive
REM      taskkill /f /im Origin.exe >nul 2>&1
REM      timeout /t 3
REM
REM      REM ----- Origin cleaning -----
REM
REM      rd /s /q "%AppData%\Origin\"
REM      rd /s /q "%LocalAppData%\Origin\"
REM
REM      endlocal & goto :eof

:CleanEAapp
    setlocal

    REM Remove old EA app clients.
    rd /s /q "%ProgramFiles%\Electronic Arts\EA Desktop\outdatedEADesktop\"
    rd /s /q "%ProgramFiles%\Electronic Arts\EA Desktop\StagedEADesktop\"

    endlocal & goto :eof

:CleanCODWarzoneUserData
    setlocal

    REM Delete files named like this: "crashdump_132287692447320985.zip".
    del /f /s /q /a "%Documents%\Call of Duty Modern Warfare\archive\*"

    REM Delete files named like this: "~crash".
    del /f /s /q /a "%Documents%\Call of Duty Modern Warfare\report\*"

    REM Delete files named like this: "gpu_report-2020_08_25-22_38_19.txt".
    del /f /s /q /a "%Documents%\Call of Duty Modern Warfare\report\gpu\*"

    REM Delete all Activision crash report folders.
    for /d %%D in ("%LocalAppData%\Activision\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Activision\*"

    endlocal & goto :eof

:CleanBattleNet
    setlocal

    REM Delete Blizzard Entertainment Battle.net cache.
    for /d %%D in ("%ProgramData%\Blizzard Entertainment\Battle.net\Cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%ProgramData%\Blizzard Entertainment\Battle.net\Cache\*"

    REM Delete Battle.net caches.
    for /d %%D in ("%ProgramData%\Battle.net\Agent\data\cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%ProgramData%\Battle.net\Agent\data\cache\*"

    for /d %%D in ("%LocalAppData%\Battle.net\BrowserCache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Battle.net\BrowserCache\*"

    for /d %%D in ("%LocalAppData%\Battle.net\Cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%LocalAppData%\Battle.net\Cache\*"

    REM Delete all .log files in Battle.net subdirectories.
    del /f /s /q /a "%ProgramData%\Battle.net\*.log"
    del /f /s /q /a "%LocalAppData%\Battle.net\*.log"

    REM Remove old Battle.net clients.
    set directory=G:\Battle.net\Battle.net
    set pathname="%directory%\Battle.net.*"
    set LatestVersionPath=""
    for /f %%d in ('dir %pathname% /b /a:d /o:d') do set LatestVersionPath="%directory%\%%d"
    if /i not %LatestVersionPath%=="" (
        REM  echo Latest version detected: %LatestVersionPath%
        for /f %%d in ('dir %pathname% /b /a:d /o:d') do (
            if /i not "%directory%\%%d"==%LatestVersionPath% (
                echo Removing old version: "%directory%\%%d"
                rd /s /q "%directory%\%%d"
            )
        )
    )

    REM Remove old Battle.net agents.
    set directory=%ProgramData%\Battle.net\Agent
    set pathname="%directory%\Agent.*"
    set LatestVersionPath=""
    for /f %%d in ('dir %pathname% /b /a:d /o:d') do set LatestVersionPath="%directory%\%%d"
    if /i not %LatestVersionPath%=="" (
        REM  echo Latest version detected: %LatestVersionPath%
        for /f %%d in ('dir %pathname% /b /a:d /o:d') do (
            if /i not "%directory%\%%d"==%LatestVersionPath% (
                echo Removing old version: "%directory%\%%d"
                rd /s /q "%directory%\%%d"
            )
        )
    )

    endlocal & goto :eof

:CleanBattlefield2042UserData
    setlocal

    REM Delete folders containing shader files named like this: "7040.md_veh_car__hdt_storm_01ob_veh_car__hdt_storm_04_base_bundle_3p\shaderdb.PcDx12". Supposedly this helps with performance but i question this?
    for /d %%D in ("%Documents%\Battlefield 2042\cache\*") do rd /s /q "%%D"
    del /f /s /q /a "%Documents%\Battlefield 2042\cache\*"

    REM Delete crash dumps.
    for /d %%D in ("%Documents%\Battlefield 2042\CrashDumps\*") do rd /s /q "%%D"
    del /f /s /q /a "%Documents%\Battlefield 2042\CrashDumps\*"

    endlocal & goto :eof

:CleanUbisoft
    setlocal

    REM Delete crash dumps.
    for /d %%D in ("G:\Ubisoft\Ubisoft Game Launcher\crashes\*") do rd /s /q "%%D"
    del /f /s /q /a "G:\Ubisoft\Ubisoft Game Launcher\crashes\*"

    endlocal & goto :eof

:CleanEpicGamesLauncher
    setlocal

    REM Remove web caches.
    set directory=%LocalAppData%\EpicGamesLauncher\Saved
    set pathname="%directory%\webcache_*"
    for /f %%d in ('dir %pathname% /b /a:d /o:d') do (
        echo Removing web caches: "%directory%\%%d"
        rd /s /q "%directory%\%%d"
    )

    endlocal & goto :eof

:Clean7Zip
    setlocal

    REM Remove tracks. 7-Zip tracks every archive you ever open with it in View > Folder History.
    reg delete "HKCU\SOFTWARE\7-Zip\FM" /v "FolderHistory" /f
    reg delete "HKCU\SOFTWARE\7-Zip\FM" /v "FolderShortcuts" /f
    reg delete "HKCU\SOFTWARE\7-Zip\FM" /v "PanelPath0" /f
    reg delete "HKCU\SOFTWARE\7-Zip\FM" /v "PanelPath1" /f

    endlocal & goto :eof

:CleanUser
    setlocal

    call :CleanAdobe
    call :CleanOkular
    call :CleanOneNote
    call :CleanMirc
    call :CleanAtom
    call :CleanDiscord
    call :CleanVirtualBox
    call :CleanVMware
    call :CleanJetBrainsDotPeek
    call :CleanVisualStudio
    call :CleanVSCode
    call :CleanNuGetCache
    call :CleanSmartGit
    call :CleanWindowsUserData
    call :CleanFirefox
    call :CleanWaterfox
    call :CleanLibreWolf
    call :CleanEdge
    call :CleanGoogle
    call :CleanOBS
    call :CleanVLC
    call :CleanLibreOffice
    call :CleanSteamUserData
    REM call :CleanOriginUserData
    call :CleanCODWarzoneUserData
    call :CleanBattleNet
    call :CleanBattlefield2042UserData
    call :Clean7Zip

    endlocal & goto :eof

:Work
    setlocal

    REM ----- Cleaning user data -----

    REM Clean the current user's data.
    REM Determine Document-folder location. The rest of the variables don't need to be modified since they are already pointing at the current user.
    for /f "tokens=1,3" %%i in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Personal') do set Documents=%%j
    if exist %Documents% (
        call :CleanUser
    )

    REM Clean "Stream" user data.
    if exist %UserProfile%\..\Stream (
        set Documents=D:\Users\Stream\Documents
        set AppData=%UserProfile%\..\Stream\AppData\Roaming
        set LocalAppData=%UserProfile%\..\Stream\AppData\Local
        set UserProfile=%UserProfile%\..\Stream
        call :CleanUser
    )

    REM If you have other user's you want to clean you can add them here like i did for the "Stream" user.

    REM TODO: Find an automatic way to clean all users.

    REM ----- Non-user-data cleaning -----

    REM These do not need to be repeated for each user.
    call :CleanUnixFiles
    call :CleanChkdskFiles
    call :CleanWindows
    call :CleanNVIDIA
    call :CleanDropbox
    call :CleanSteam
    REM call :CleanOrigin
    call :CleanUbisoft
    call :CleanEpicGamesLauncher
    call :CleanEAapp

    REM -----

    REM TODO: C:\Users\Wolf\MicrosoftEdgeBackups
    REM this might be something we can delete.
    REM People say closing edge deletes it but i didn't see that effect.
    REM Also ppl say its just a backup of your settings idk, https://www.tenforums.com/browsers-email/117960-no-more-microsoftedgebackups.html

    REM TODO: I think some of the attrib -r -s -h calls are unnecessary.

    endlocal

:End
    if %NOPAUSE% equ 0 pause
    goto :eof
