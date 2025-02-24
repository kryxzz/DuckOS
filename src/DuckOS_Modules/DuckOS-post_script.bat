@echo off 

:: Set up echo in colors
chcp 65001 >nul 2>&1
set c_red=[31m
set c_green=[32m
set c_blue=[34m

:: heals why
set currentuser=C:\Windows\DuckOS_Modules\nsudo.exe -U:C -P:E -Wait

echo %c_green%The post install script is starting...

:: Make the script faster by putting an higher priority.
wmic process where name="cmd.exe" CALL setpriority 128

echo %c_red%Please wait. This may take a moment.

:: DuckOS Post Install Script.
:: made for stock Windows and duckOS
:: made by fikinoob#0001

:::::::::::::
:: Credits :: 
:::::::::::::

:: DuckOS' tweaks aren't 100% made by it's author, but the author and some people's tweaks..
:: Today you cannot make a good operating system by yourself.. you gotta use ATLEAST 1 source.
:: Here are credits to the people -- whos code is currently in use in this script: (no order)
:: 1. He3als - gave this idea to make DuckOS a open-sourced project
:: 2. Zusier - We use some tweaks he wrote for AtlasOS, which is an another good modified operating system based on windows!
:: 3. Imribiy - NIC settings
:: 4. CatGamerOP - I used his commands.. that delete registry classes :skull: :skull:
:: 5. stefkeec - block telemetry ip commands
:: 6. vojt. - provided toolbox icons
:: Various different sources and google..

:: Send a message!
start mshta.exe vbscript:Execute("msgbox ""Welcome to duckOS, a modification to Windows for enhanced privacy and performance! Thank you for downloading and using duckOS, we are preparing duckOS and will be available to use shortly.."",48+4096,""DuckOS Post Install Tweaks"":close")

:: Set enviroment variables for future use, example: toolbox
SETLOCAL EnableDelayedExpansion
for /f "tokens=2 delims==" %%a in ('wmic os get TotalVisibleMemorySize /format:value ^| findstr "TotalVisibleMemorySize"') do set "TotalVisibleMemorySize=%%a"
set /a RAM=%TotalVisibleMemorySize%+1024000

for /f "delims=:{}" %%i in ('wmic path Win32_systemenclosure get ChassisTypes^| findstr [0-9]') do set "CHASSIS=%%i"
set /a LAPTOP=0
if %CHASSIS% GTR 7 ( 
if %CHASSIS% LSS 17 ( set /a LAPTOP=1 )
if %CHASSIS% GTR 28 ( set /a LAPTOP=1 ) 
)

:: Import services.reg and any other registry file in there.
cd C:\Windows\DuckOS_Modules
for %%i in (C:\Windows\DuckOS_Modules\*.reg) do reg import %%i
echo ! Please dont close anything. 

:: Block every single websites telemetry with the help of a modified hosts file.
echo %c_blue%Block every single websites telemetry with the help of a modified hosts file.
curl -l -s https://winhelp2002.mvps.org/hosts.txt -o %SystemRoot%\System32\drivers\etc\hosts.temp
if exist %SystemRoot%\System32\drivers\etc\hosts.temp (
    cd %SystemRoot%\System32\drivers\etc
    del /f /q hosts
    ren hosts.temp hosts 
    echo %c_green%Done!
)

::::::::::::::::::::::::
:: Windows Appearance ::
::::::::::::::::::::::::

:: Enable dark mode, disable transparency
:: WE DONT LIKE LIGHT MODE!
echo %c_green%Enabling dark mode, disable transparency..
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Set UTC to prevent issues with dual booting (specifically with Linux)
reg add "HKLM\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f > nul

:::::::::::::::::::::::::
:: Automatic Repairing :: -- manual version in the post install folder located on the desktop
:::::::::::::::::::::::::

:: What does it do? This bassiclly makes sure your apps install, if they don't exist, they will try to be installed..
:: The code below is user friendly, we don't have to simplify it even more..

:: 7zip
if not exist "%programfiles%\7-zip\7zFM.exe" (
	echo ! 7zip not found, trying to reinstall..
	if exist %SystemRoot%\Setup\Files\7z2201-x64.msi (
		echo ! 7zip installer detected in %Systemroot%\Setup\Files\7z2201-x64.msi.. reinstalling..
		start /wait "" "%SystemRoot%\Setup\Files\7z2201-x64.msi" /passive
		echo ! 7zip installation done.
	)
)

:: Debloat 7zip - security
cd /d %ProgramFiles%\7-zip
echo %c_green%Debloating 7-Zip...
for %%i in (*.txt *.chm) do del /F /Q "%%i"

:: Install DirectX
echo %c_green%Installing DirectX
start /wait "" "%SYSTEMROOT%\DuckOS_Modules\DirectX\dxsetup.exe" /silent
echo %c_green%Done.

:: Ask the user if they use "Windows Firewall", if not, disable it.. if yes, do nothing..
call :MsgBox "Will you NOT use Windows Firewall? -- NOTE: It breaks microsoft store reinstallation. Pressing 'no' re-enables it!"  "VBYesNo+VBQuestion" "Configuration"
if errorlevel 7 (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "Start" /t REG_DWORD /d "4" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\BFE" /v "Start" /t REG_DWORD /d "4" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "DisableNotifications" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "DisableNotifications" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "EnableFirewall" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "DisableNotifications" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "1" /f
) else if errorlevel 6 (
	echo %c_green%OK! Skipped removal. Re-Enabling Windows Firewall.
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "Start" /t REG_DWORD /d "2" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\BFE" /v "Start" /t REG_DWORD /d "2" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "EnableFirewall" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "DisableNotifications" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "EnableFirewall" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "DisableNotifications" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "EnableFirewall" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "DisableNotifications" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" /v "DoNotAllowExceptions" /t REG_DWORD /d "0" /f
)

:: Ask the user if they want to use OpenShell instead of the Windows 10's start menu
call :MsgBox "Would you like to install OpenShell -- includes renaming the Window 10's start menu, breaking icon's functionality on the taskbar.."  "VBYesNo+VBQuestion" "Configuration"
if errorlevel 7 (
	:: i got bored of debuging this so im just making it go to a label
	call InstallOpenShell 2>nul
)

:: Debloat OpenShell -- if it exists
echo %c_green%Debloating Openshell...
if exist %ProgramFiles%\Open-Shell (
	cd /d %ProgramFiles%\Open-Shell
	for %%i in (OpenShell.chm *.lnk OpenShellReadme.rtf) do del /F /Q "%%i"
	cd /d %ProgramFiles%\Open-Shell\Skins
	for %%i in (*.skin *.skin7) do del /F /Q "%%i"
)
echo %c_green%Done.

:: Remove Telemetry IPs - rest is done through NTLite
echo %c_red%Disabling Telemetry IPs..
netsh advfirewall firewall add rule name="Block Windows Telemetry" dir=in action=block remoteip=134.170.30.202,137.116.81.24,157.56.106.189,184.86.53.99,2.22.61.43,2.22.61.66,204.79.197.200,23.218.212.69,65.39.117.23,65.55.108.23,64.4.54.254 enable=yes > nul
netsh advfirewall firewall add rule name="Block NVIDIA Telemetry" dir=in action=block remoteip=8.36.80.197,8.36.80.224,8.36.80.252,8.36.113.118,8.36.113.141,8.36.80.230,8.36.80.231,8.36.113.126,8.36.80.195,8.36.80.217,8.36.80.237,8.36.80.246,8.36.113.116,8.36.113.139,8.36.80.244,216.228.121.209 enable=yes > nul

:: Disable Data Collection (telemetry)
:: Gives you privacy :)
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MaxTelemetryAllowed" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowDeviceNameInTelemetry" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "LimitEnhancedDiagnosticDataWindowsAnalytics" /t REG_DWORD /d "0" /f

echo %c_green%Done.

:: Known Issues when adding languages in Windows 10 -- link https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/language-packs-known-issue?view=windows-10
schtasks /Change /Disable /TN "\Microsoft\Windows\LanguageComponentsInstaller\Uninstallation" >nul 2>nul
reg add "HKLM\Software\Policies\Microsoft\Control Panel\International" /v "BlockCleanupOfUnusedPreinstalledLangPacks" /t REG_DWORD /d "1" /f

:: Disable MS Edge's scheduled tasks
echo %c_green%Disable Microsoft Edge's scheduled tasks.
schtasks /Change /Disable /TN "\MicrosoftEdgeUpdateTaskMachineCore" >nul 2>nul
schtasks /Change /Disable /TN "\MicrosoftEdgeUpdateTaskMachineUA" >nul 2>nul
echo %c_green%Done.

:: Edge Settings incase the user want's to install it.. so it already has settings configured.
echo %c_green%Configure edge settings incase the user reinstalls it..
reg add "HKLM\Software\Policies\Microsoft\Windows\EdgeUI" /v "DisableMFUTracking" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\MicrosoftEdge\Main" /v "AllowPrelaunch" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Remove Edge from Program Files (x86)
echo %c_green%Removing edge from Program Files (x86)...
rd /s /q "C:\Program Files (x86)\Microsoft"
echo %c_green%Done.

:: Remove Edge's registry keys
echo %c_green%Removing edge's registry keys / leftovers...
reg delete "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f >nul 2>nul
reg delete "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" /f >nul 2>nul
reg delete "HKLM\Software\Classes\MSEdgeHTM" /f >nul 2>nul
reg delete "HKLM\System\CurrentControlSet\Services\EventLog\Application\edgeupdate" /f >nul 2>nul
reg delete "HKLM\System\CurrentControlSet\Services\EventLog\Application\edgeupdatem" /f >nul 2>nul
reg delete "HKLM\Software\WOW6432Node\Clients\StartMenuInternet\Microsoft Edge" /f >nul 2>nul
reg delete "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" /f >nul 2>nul
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" /f >nul 2>nul
reg delete "HKLM\Software\WOW6432Node\Microsoft\EdgeUpdate" /f >nul 2>nul
reg delete "HKLM\Software\WOW6432Node\Microsoft\Edge" /f >nul 2>nul
reg delete "HKLM\Software\Clients\StartMenuInternet\Microsoft Edge" /f >nul 2>nul
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Device Metadata" /f >nul 2>nul
echo %c_green%Done.

:: Set up the toolbox to be in the context menu
echo %c_green%Setting up the toolbox in the context menu..
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\DuckOS Toolbox\command" /v "" /d "C:\Windows\DuckOS_Modules\DuckOS_Toolbox\DuckOS Toolbox.exe" /t REG_SZ /f
echo %c_green%Done.

:: Import the powerplan
echo %c_green%Importing a custom power plan..
powercfg -import "C:\Windows\DuckOS_Modules\Duck.pow" 11111111-1111-1111-1111-111111111111
powercfg /s 11111111-1111-1111-1111-111111111111
echo %c_green%Done.

:: MAKE THE CACHE CLEANER START ON STARTUP by modifying the shell value..
echo %c_green%Making the cache cleaner run on startup..
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "C:\Windows\explorer.exe, C:\ProgramData\Cache_Cleaner.bat" /F
echo %c_green%Done.

:: Disable unneeded Tasks -- already credited
echo %c_green%Disabling unneeded scheduled tasks.
schtasks /Change /Disable /TN "\Microsoft\Windows\PushToInstall\LoginCheck" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Ras\MobilityManager" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\Report policies" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Application Experience\StartupAppTask" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\WindowsUpdate\Scheduled Start" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Shell\FamilySafetyMonitor" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Shell\FamilySafetyMonitor" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Windows Error Reporting\QueueReporting" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Diagnosis\Scheduled" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\DiskFootprint\StorageSense" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\PushToInstall\LoginCheck" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\DiskCleanup\SilentCleanup" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Multimedia\Microsoft\Windows\Multimedia" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Time Zone\SynchronizeTimeZone" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Diagnosis\Scheduled" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan Static Task" >nul 2>nul
schtasks /Change /Disable /TN "\MicrosoftEdgeUpdateBrowserReplacementTask" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\WindowsUpdate\Scheduled Start" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\UPnP\UPnPHostConfig" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\DiskFootprint\Diagnostics" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Windows Filtering Platform\BfeOnLoltartTypeChange" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\International\Synchronize Language Settings" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Work" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskLogon" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Application Experience\PcaPatchDbTask" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Time Zone\SynchronizeTimeZone" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Shell\IndexerAutomaticMaintenance" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\WaaSMedic\PerformRemediation" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Autochk\Proxy" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskNetwork" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskLogon" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\InstallService\SmartRetry" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Printing\EduPrintProv" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Shell\IndexerAutomaticMaintenance" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\UpdateModelTask" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\Report policies" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\UpdateModelTask" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Multimedia\Microsoft\Windows\Multimedia" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Wininet\CacheTask" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Ras\MobilityManager" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\DiskCleanup\SilentCleanup" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\StateRepository\MaintenanceTasks" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Device Setup\Metadata Refresh" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\WaaSMedic\PerformRemediation" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\RetailDemo\CleanupOfflineContent" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Autochk\Proxy" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\BrokerInfrastructure\BgTaskregistrationMaintenanceTask" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Time Synchronization\SynchronizeTime" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Wininet\CacheTask" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Application Experience\PcaPatchDbTask" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Work" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Time Synchronization\ForceSynchronizeTime" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\InstallService\ScanForUpdatesAsUser" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Time Synchronization\ForceSynchronizeTime" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Application Experience\StartupAppTask" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\International\Synchronize Language Settings" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\UPnP\UPnPHostConfig" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\registry\regIdleBackup" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Time Synchronization\SynchronizeTime" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Printing\EduPrintProv" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Windows Error Reporting\QueueReporting" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\RetailDemo\CleanupOfflineContent" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\DiskFootprint\Diagnostics" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\InstallService\ScanForUpdates" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskNetwork" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\Device Setup\Metadata Refresh" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\StateRepository\MaintenanceTasks" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\BrokerInfrastructure\BgTaskRegistrationMaintenanceTask" >nul 2>nul
schtasks /Change /Disable /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan Static Task" >NUL 2>&1
schtasks /Change /Disable /TN "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" >NUL 2>&1
echo %c_green%Done.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Delete lot's of registry classes, credits goes to: FoxOS ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo %c_green%Cleaning up registry classes, credit: FoxOS -- CatGamerOP
reg delete "HKLM\System\CurrentControlSet\Control\Class\{990A2BD7-E738-46C7-B26F-1CF8FB9F1391}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4116F60B-25B3-4662-B732-99A6111EDC0B}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{D94EE5D8-D189-4994-83D2-F68D7D41B0E6}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{E0CBF06C-CD8B-4647-BB8A-263B43F0F974}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{C06FF265-AE09-48F0-812C-16753D7CBA83}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{D48179BE-EC20-11D1-B6B8-00C04FA372A7}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{997B5D8D-C442-4F2E-BAF3-9C8E671E9E21}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{6BDD1FC1-810F-11D0-BEC7-08002BE2092F}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4D36E97B-E325-11CE-BFC1-08002BE10318}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{A0A588A4-C46F-4B37-B7EA-C82FE89870C6}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{7EBEFBC0-3200-11D2-B4C2-00A0C9697D07}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4D36E965-E325-11CE-BFC1-08002BE10318}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{53D29EF7-377C-4D14-864B-EB3A85769359}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4658EE7E-F050-11D1-B6BD-00C04FA372A7}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{6BDD1FC5-810F-11D0-BEC7-08002BE2092F}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{DB4F6DDD-9C0E-45E4-9597-78DBBAD0F412}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4D36E978-E325-11CE-BFC1-08002BE10318}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4D36E977-E325-11CE-BFC1-08002BE10318}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{6D807884-7D21-11CF-801C-08002BE10318}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{CE5939AE-EBDE-11D0-B181-0000F8753EC4}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4D36E969-E325-11CE-BFC1-08002BE10318}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4D36E970-E325-11CE-BFC1-08002BE10318}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4D36E979-E325-11CE-BFC1-08002BE10318}" /f
reg delete "HKLM\System\CurrentControlSet\Control\Class\{4D36E96D-E325-11CE-BFC1-08002BE10318}" /f
echo %c_green%Done.

:: Disable "MAINTENANCE"
echo %c_green%Disabling MAINTENANCE...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics" /v "EnabledExecution" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\ScheduledDiagnostics" /v "EnabledExecution" /t REG_DWORD /d "0" /f >nul 2>&1
echo %c_green%Done.

:: Delete Adobe Font Type Manager
echo %c_green%Deleting Adobe Font Type Manager...
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Font Drivers" /v "Adobe Type Manager" /f
echo %c_green%Done.

:: Disable Camera Access when locked
echo %c_green%Disabling Camera Access when the PC is on locked screen.
reg add "HKLM\Software\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d "1" /f
echo %c_green%Done.

:: Disable Remote Assistance
echo %c_green%Disabling Remote Assistance.
reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v "fEnableChatControl" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v "fAllowFullControl" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\Remote Assistance" /v "fAllowToGetHelp" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Disable "Network Level Authentication"
echo %c_green%Disabling Network Level Authentication.
reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "1" /f
echo %c_green%Done.

:: Configure NIC Settings
echo %c_green%Configure NIC settings.
netsh int tcp set global timestamps=disabled
netsh int tcp set heuristics disabled
netsh int tcp set supplemental Internet congestionprovider=ctcp
netsh int tcp set global rsc=disabled

for /f "tokens=1" %%i in ('netsh int ip show interfaces ^| findstr [0-9]') do (
	netsh int ip set interface %%i routerdiscovery=disabled store=persistent
)

:: Disable Web in Search
echo %c_green%Disable Web in Search.
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f
echo %c_green%Done.

:: Disable Network Adapters
:: IPv6, Client for Microsoft Networks, QoS Packet Scheduler, File and Printer Sharing
powershell -NoProfile -Command "Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6, ms_msclient, ms_pacer, ms_server" >nul 2>&1

:: Mitigate against HiveNightmare/SeriousSAM
icacls %SystemRoot%\system32\config\* /inheritance:e

:: Remove SOME dependencies
reg add "HKLM\System\CurrentControlSet\Services\Dhcp" /v "DependOnService" /t REG_MULTI_SZ /d "NSI\0Afd" /f
reg add "HKLM\System\CurrentControlSet\Services\Dnscache" /v "DependOnService" /t REG_MULTI_SZ /d "nsi" /f
reg add "HKLM\System\CurrentControlSet\Services\rdyboost" /v "DependOnService" /t REG_MULTI_SZ /d "" /f
reg add "HKLM\System\CurrentControlSet\Control\Class\{71a27cdd-812a-11d0-bec7-08002be2092f}" /v "LowerFilters" /t REG_MULTI_SZ  /d "" /f
reg add "HKLM\System\CurrentControlSet\Control\Class\{71a27cdd-812a-11d0-bec7-08002be2092f}" /v "UpperFilters" /t REG_MULTI_SZ  /d "" /f

:: Set strong cryptography on 64 bit and 32 bit .Net Framework (version 4 and above) to fix a Scoop installation issue
:: Link to the source: https://github.com/ScoopInstaller/Scoop/issues/2040#issuecomment-369686748
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" /v "SchUseStrongCrypto" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\.NetFramework\v4.0.30319" /v "SchUseStrongCrypto" /t REG_DWORD /d "1" /f

:: Disable CEIP
echo %c_green%Disabling CEIP..
%currentuser% reg add "HKCU\Software\Policies\Microsoft\Messenger\Client" /v "CEIP" /t REG_DWORD /d "2" /f
reg add "HKLM\Software\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\AppV\CEIP" /v "CEIPEnable" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: BSOD settings
echo %c_green%Configuring BSOD settings.
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "CrashDumpEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "DisplayParameters" /t REG_DWORD /d "1" /f
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "AutoReboot" /t REG_DWORD /d "1" /f
echo %c_green%Done.

:: Disable Windows Insider and Build Previews
echo %c_green%Disable Windows Insider and build previews.
reg add "HKLM\Software\Microsoft\WindowsSelfHost\UI\Visibility" /v "HideInsiderPage" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableConfigFlighting" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\PreviewBuilds" /v "EnableExperimentation" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\PreviewBuilds" /v "AllowBuildPreview" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Maps Updates/Downloads
echo %c_green%Configuring Map Updates/Downloads..
reg add "HKLM\Software\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Application Compatability Settings
echo %c_green%Configuring 'Application Compatibility' settings...
reg add "HKLM\Software\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\AppCompat" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\AppCompat" /v "DisableEngine" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\AppCompat" /v "DisablePCA" /t REG_DWORD /d "1" /f
echo %c_green%Done.

:: Disable Mouse Acceleration
echo %c_green%Disabling Mouse Acceleration..
%currentuser% reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f
%currentuser% reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f
echo %c_green%Done.

:: Disable Annoying Keyboard Features
echo %c_green%Disabling Anoyying Keyboard Features..
%currentuser% reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Disable Connection Checking (pings Microsoft Servers)
:: May cause internet icon to show it is disconnected
echo %c_green%Disabling probing...
reg add "HKLM\System\CurrentControlSet\Services\NlaSvc\Parameters\Internet" /v "EnableActiveProbing" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Disable Download-Blocking.
echo %c_green%Disabling download blocking..
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d "1" /f
echo %c_green%Done.

:: Misc Quality of Life
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v "ShowedToastAtLevel" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Control Panel\International\User Profile" /v "HttpAcceptLanguageOptOut" /t REG_DWORD /d "1" /f
reg add "HKLM\System\CurrentControlSet\Control\Diagnostics\Performance" /v "DisableDiagnosticTracing" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" /v "ScenarioExecutionEnabled" /t REG_DWORD /d "0" /f

:: Content Delivery Manager
echo %c_green%Configuring Content Delivery Manager..
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-314563Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Disable Sleep Study
echo %c_green%Disabling sleep study..
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Power" /v "SleepStudyDisabled" /t REG_DWORD /d "1" /f
echo %c_green%Done.

:: Power
reg add "HKLM\System\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\Power" /v "EventProcessorEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f

:: Disable Shared Experiences
echo %c_green%Disabling Shared Experiences...
reg add "HKLM\Software\Policies\Microsoft\Windows\System" /v "EnableCdp" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Internet Explorer settings... who really uses it.. but still it's good to download librewolf lmfao
echo %c_green%Configuring Internet Explorer -- for the 1 time used to download firefox kekw
reg add "HKLM\Software\Microsoft\Internet Explorer\Main" /v "NoUpdateCheck" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Internet Explorer\Main" /v "Enable Browser Extensions" /t REG_SZ /d "no" /f
reg add "HKLM\Software\Microsoft\Internet Explorer\Main" /v "Isolation" /t REG_SZ /d "PMEM" /f
reg add "HKLM\Software\Microsoft\Internet Explorer\Main" /v "Isolation64Bit" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\BrowserEmulation" /v "IntranetCompatibilityMode" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer" /v "DisableFlashInIE" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\DomainSuggestion" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Security" /v "DisableSecuritySettingsCheck" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Security" /v "DisableFixSecuritySettings" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Privacy" /v "EnableInPrivateBrowsing" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Privacy" /v "ClearBrowsingHistoryOnExit" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Main" /v "EnableAutoUpgrade" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Main" /v "DisableFirstRunCustomize" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Main" /v "HideNewEdgeButton" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Feed Discovery" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Feeds" /v "BackgroundSyncStatus" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\FlipAhead" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Suggested Sites" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\TabbedBrowsing" /v "NewTabPageShow" /t REG_DWORD /d "1" /f

:: Hide audio devices that ARENT connected.
echo %c_green%Hiding audio devices that aren't connected...
reg add "HKCU\SOFTWARE\Microsoft\Multimedia\Audio\DeviceCpl" /v "ShowHiddenDevices" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Multimedia\Audio\DeviceCpl" /v "ShowDisconnectedDevices" /t REG_DWORD /d "0" /f >nul 2>&1
echo %c_green%Done.

:: Restore the photo viewer from Windows 7
echo %c_green%Restoring photo viewer from windows 7...
for %%i in (tif tiff bmp dib gif jfif jpe jpeg jpg jxr png) do (
	reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".%%~i" /t REG_SZ /d "PhotoViewer.FileAssoc.Tiff" /f >nul 2>&1
)
echo %c_green%Done.

:: Windows Media Player configuration
echo %c_green%Configuring Media Player..
reg add "HKLM\Software\Policies\Microsoft\WMDRM" /v "DisableOnline" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\WindowsMediaPlayer" /v "GroupPrivacyAcceptance" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\MediaPlayer\Preferences" /v "AcceptedEULA" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\MediaPlayer\Preferences" /v "FirstTime" /t REG_DWORD /d "1" /f >nul 2>&1
echo %c_green%Done.

:: MMCSS Settings
echo %c_green%Configuring MMCSS...
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "10" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "10" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "LazyModeTimeout" /t REG_DWORD /d "10000" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d "True" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "NoLazyMode" /t REG_DWORD /d "1" /f
echo %c_green%Done.

:: Disallow Background Apps
echo %c_green%Disallowing background apps..
reg add "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t REG_DWORD /d "2" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Set Win32PrioritySeparation 26 hex/38 dec
reg add "HKLM\System\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "38" /f

:: Disable Notification/Action Center
echo %c_green%Disabling notifications..
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoTileApplicationNotification" /t REG_DWORD /d "1" /f
echo %c_green%Done.

:: Misc stuff
%currentuser% reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d "80" /f
%currentuser% reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "500" /f
%currentuser% reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "1000" /f
%currentuser% reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f
%currentuser% reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9A12038010000000" /f

:: Visual Settings
echo %c_green%Disabling animations..
%currentuser% reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "3" /f
echo %c_green%Done.

:: Disable Storage Sense
echo %c_green%Disabling storage sense..
reg add "HKLM\Software\Policies\Microsoft\Windows\StorageSense" /v "AllowStorageSenseGlobal" /t REG_DWORD /d "0" /f
echo %c_green%Done.

:: Enable Virtualization Based Protection of code integrity
reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "0" /f

:: Install .CAB files in the "Context Menu"
reg delete "HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs" /f >nul 2>nul
reg add "HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs" /ve /t REG_SZ /d "Install" /f
reg add "HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs" /v "HasLUAShield" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs\Command" /ve /t REG_SZ /d "cmd /k dism /online /add-package /packagepath:\"%%1\"" /f

:: Add "Run with priority" to the context menu
reg add "HKEY_CLASSES_ROOT\exefile\shell\Priority" /v "MUIVerb" /t REG_SZ /d "Run with priority" /f
reg add "HKEY_CLASSES_ROOT\exefile\shell\Priority" /v "SubCommands" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\001flyout" /ve /t REG_SZ /d "Realtime" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\001flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /Realtime \"%%1\"" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\002flyout" /ve /t REG_SZ /d "High" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\002flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /High \"%%1\"" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\003flyout" /ve /t REG_SZ /d "Above normal" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\003flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /AboveNormal \"%%1\"" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\004flyout" /ve /t REG_SZ /d "Normal" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\004flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /Normal \"%%1\"" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\005flyout" /ve /t REG_SZ /d "Below normal" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\005flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /BelowNormal \"%%1\"" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\006flyout" /ve /t REG_SZ /d "Low" /f
reg add "HKEY_CLASSES_ROOT\exefile\Shell\Priority\shell\006flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /Low \"%%1\"" /f

:: Remove "Include in library" in the context menu
reg delete "HKEY_CLASSES_ROOT\Folder\ShellEx\ContextMenuHandlers\Library Location" /f >nul 2>nul
reg delete "HKLM\SOFTWARE\Classes\Folder\ShellEx\ContextMenuHandlers\Library Location" /f >nul 2>nul

:: Remove Share in context menu
reg delete "HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\ModernSharing" /f >nul 2>nul

:: Double click to import power-plans, but not set them automaticlly.
reg add "HKLM\Software\Classes\powerplan\DefaultIcon" /ve /t REG_SZ /d "%%WinDir%%\System32\powercpl.dll,1" /f
reg add "HKLM\Software\Classes\powerplan\Shell\open\command" /ve /t REG_SZ /d "powercfg /import \"%%1\"" /f
reg add "HKLM\Software\Classes\.pow" /ve /t REG_SZ /d "powerplan" /f
reg add "HKLM\Software\Classes\.pow" /v "FriendlyTypeName" /t REG_SZ /d "PowerPlan" /f

:: Set CSRSS to be a "high priority" process.
:: Csrss is responsible for mouse input latency, setting to high may yield an improvement in input latency.
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "3" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v "IoPriority" /t REG_DWORD /d "3" /f


:::::::::::::::::::::::::::
:: Storage Optimizations ::
:::::::::::::::::::::::::::

:: Storage System
fsutil behavior set memoryusage 2 >NUL 2>&1
fsutil behavior set mftzone 2 >NUL 2>&1
fsutil behavior set allowextchar 0 >NUL 2>&1
fsutil behavior set Bugcheckoncorrupt 0 >NUL 2>&1
fsutil behavior set disable8dot3 1 >NUL 2>&1
fsutil behavior set disablecompression 1 >NUL 2>&1
fsutil behavior set disabledeletenotify 0 >NUL 2>&1
fsutil behavior set disableencryption 1 >NUL 2>&1
fsutil behavior set disablelastaccess 1 >NUL 2>&1
fsutil behavior set encryptpagingfile 0 >NUL 2>&1

::::::::::::::::::::::::::
:: Memory Optimizations ::
::::::::::::::::::::::::::

:: Memory Management
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePageCombining" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnablePrefetcher" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableSuperfetch" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBoottrace" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f

:: SvcSplitThreshold
reg add "HKLM\System\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t reg_DWORD /d "%ram%" /f >NUL 2>&1

:: Large System Cache
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t reg_DWORD /d "1" /f >NUL 2>&1

:: Startup
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DelayedDesktopSwitchTimeout" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t reg_DWORD /d "0" /f >NUL 2>&1

:::::::::::::::::
:: Mitigations ::
:::::::::::::::::

:: Disable DmaRemapping
for /f %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /s /f DmaRemappingCompatible ^| find /i "Services\" ') do (
	reg add "%%i" /v "DmaRemappingCompatible" /t reg_DWORD /d "0" /f >NUL 2>&1
)

:: Disable Chain Validation
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t reg_DWORD /d "1" /f >NUL 2>&1

:: Disable FTH
reg add "HKLM\Software\Microsoft\FTH" /v "Enabled" /t reg_DWORD /d "0" /f >NUL 2>&1

:: CSRSS mitigations
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /v MitigationAuditOptions /t reg_BINARY /d "222222222222222222222222222222222222222222222222" /f >NUL 2>&1
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /v MitigationOptions /t reg_BINARY /d "222222222222222222222222222222222222222222222222" /f >NUL 2>&1
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass /t reg_DWORD /d "3" /f >NUL 2>&1
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority /t reg_DWORD /d "3" /f >NUL 2>&1

:: Set System Processes Priority below normal
for %%i in (lsass.exe sppsvc.exe SearchIndexer.exe fontdrvhost.exe sihost.exe ctfmon.exe) do (
  reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%i\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "5" /f
)


:: Set background apps priority below normal
for %%i in (OriginWebHelperService.exe ShareX.exe EpicWebHelper.exe SocialClubHelper.exe steamwebhelper.exe Discord.exe) do (
  reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%i\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d "5" /f
)

:: Correct Mitigation Values
powershell -NoProfile -Command Set-ProcessMitigation -System -Disable CFG >NUL 2>&1
for /f "tokens=3 skip=2" %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions"') do set mitigation_mask=%%a
for /L %%a in (0,1,9) do (
    set mitigation_mask=!mitigation_mask:%%a=2!
)
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions" /t reg_BINARY /d "%mitigation_mask%" /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t reg_BINARY /d "%mitigation_mask%" /f >NUL 2>&1

:: ASLR - find ntoskrnl strings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "MoveImages" /t reg_DWORD /d "0" /f >NUL 2>&1

:: Spectre & Meltdown
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettings /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t reg_DWORD /d "3" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t reg_DWORD /d "3" /f >NUL 2>&1

:: DWM
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\DWM" /v "DisallowAnimations" /t reg_DWORD /d "1" /f >NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "Composition" /t reg_DWORD /d "0" /f >NUL 2>&1

:: Security Tweaks 
reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v "RestrictNullSessAccess" /t reg_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v "DisableCompression" /t reg_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v "RestrictAnonymous" /t reg_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Control\Lsa" /v "RestrictAnonymousSAM" /t reg_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Services\NetBT\Parameters" /v "NodeType" /t reg_DWORD /d "2" /f >NUL 2>&1

:: Enable Hardware Accelerated Scheduling (HAGS)
reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t reg_DWORD /d "2" /f >NUL 2>&1

:: Restrict Windows' communication
reg add "HKLM\Software\Policies\Microsoft\InternetManagement" /v "RestrictCommunication" /t REG_DWORD /d "1" /f

:: Win32PrioritySeparation 26 hex/38 dec
reg add "HKLM\System\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t reg_DWORD /d "38" /f >NUL 2>&1

:: Mouse Settings
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t reg_SZ /d "10" /f >NUL 2>&1
reg add "HKU\.DEFAULT\Control Panel\Mouse" /v "MouseSpeed" /t reg_SZ /d "0" /f >NUL 2>&1
reg add "HKU\.DEFAULT\Control Panel\Mouse" /v "MouseThreshold1" /t reg_SZ /d "0" /f >NUL 2>&1
reg add "HKU\.DEFAULT\Control Panel\Mouse" /v "MouseThreshold2" /t reg_SZ /d "0" /f >NUL 2>&1
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t reg_BINARY /d 0000000000000000C0CC0C0000000000809919000000000040662600000000000033330000000000 /f >NUL 2>&1
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /t reg_BINARY /d 0000000000000000000038000000000000007000000000000000A800000000000000E00000000000 /f >NUL 2>&1

:: Disable Windows Error Reporting
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting" /v "LoggingDisabled" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting\Consent" /v "DefaultOverrideBehavior" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting\Consent" /v "DefaultConsent" /t REG_DWORD /d "0" /f

:: Delete Defaultuser0 used during OOBE
net user defaultuser0 /delete >NUL 2>&1 

:: Disable "Administrator" used using OEM
net user administrator /active:no >NUL 2>&1 

::::::::::::::
:: Internet ::
::::::::::::::

:: Disable Nagle's Algorithm
reg add "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t reg_DWORD /d "00000001" /f >NUL 2>&1  
for /f %%s in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s') do set "str=%%i" & if "!str:ServiceName_=!" neq "!str!" (
 	reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TCPNoDelay" /t reg_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TcpAckFrequency" /t reg_DWORD /d "1" /f >NUL 2>&1
	reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%s" /v "TcpDelAckTicks" /t reg_DWORD /d "0" /f >NUL 2>&1
)


:: Set max port to 65535
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t reg_DWORD /d "00065534" /f >NUL 2>&1

:: Reduce TIME_WAIT
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t reg_DWORD /d "00000030" /f >NUL 2>&1

:: Disable the TCP autotuning diagnostic tool
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "EnableWsd" /t reg_DWORD /d "00000000" /f >NUL 2>&1

:: Enable TCP Extensions for High Performance
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t reg_DWORD /d "00000001" /f >NUL 2>&1 

:: Detect congestion fail to receive acknowledgement for a packet within the estimated timeout
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPCongestionControl" /t reg_DWORD /d "00000001" /f >NUL 2>&1

:: Set the maximum number of concurrent connections (per server endpoint) allowed when making requests using an HttpClient object.
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "MaxConnectionsPerServer" /t reg_DWORD /d "00000016" /f >NUL 2>&1

:: Maximum number of HTTP 1.0 connections to a Web server
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v "MaxConnectionsPer1_0Server" /t reg_DWORD /d "00000016" /f >NUL 2>&1

:: TCP Congestion Control/Avoidance Algorithm
reg add "HKLM\System\CurrentControlSet\Control\Nsi\{eb004a03-9b1a-11d4-9123-0050047759bc}\0" /v "0200" /t reg_BINARY /d "0000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000ff000000000000000000000000000000000000000000ff000000000000000000000000000000" /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Control\Nsi\{eb004a03-9b1a-11d4-9123-0050047759bc}\0" /v "1700" /t reg_BINARY /d "0000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000ff000000000000000000000000000000000000000000ff000000000000000000000000000000" /f >NUL 2>&1

:: QOS
reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t reg_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t reg_DWORD /d "00000000" /f >NUL 2>&1
reg add "HKLM\Software\WOW6432Node\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows NT\DNSClient" /v "EnableMulticast" /t reg_DWORD /d "0" /f >NUL 2>&1

:: Network Priorities
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "LocalPriority" /t reg_DWORD /d "4" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "HostsPriority" /t reg_DWORD /d "5" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "DnsPriority" /t reg_DWORD /d "6" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v "NetbtPriority" /t reg_DWORD /d "7" /f >NUL 2>&1

:: Enable The Network Adapter Onboard Processor
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DisableTaskOffload" /t reg_DWORD /d "0" /f >NUL 2>&1

:: NIC Settings - credits: imbiriy
for /f %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" /v "*SpeedDuplex" /s ^| findstr  "HKEY"') do (
    for /f %%i in ('reg query "%%a" /v "*ReceiveBuffers" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "*ReceiveBuffers" /t REG_SZ /d "1024" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "*TransmitBuffers" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "*TransmitBuffers" /t REG_SZ /d "1024" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "*DeviceSleepOnDisconnect" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "*DeviceSleepOnDisconnect" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "*EEE" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "*EEE" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "*ModernStandbyWoLMagicPacket" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "*ModernStandbyWoLMagicPacket" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "*SelectiveSuspend" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "*SelectiveSuspend" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "*WakeOnMagicPacket" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "*WakeOnMagicPacket" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "*WakeOnPattern" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "*WakeOnPattern" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "AutoPowerSaveModeEnabled" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "AutoPowerSaveModeEnabled" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "EEELinkAdvertisement" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "EEELinkAdvertisement" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "EeePhyEnable" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "EeePhyEnable" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "EnableGreenEthernet" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "EnableModernStandby" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "EnableModernStandby" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "GigaLite" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "GigaLite" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "PowerDownPll" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "PowerDownPll" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "PowerSavingMode" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "PowerSavingMode" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "ReduceSpeedOnPowerDown" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "ReduceSpeedOnPowerDown" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "S5WakeOnLan" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "S5WakeOnLan" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "SavePowerNowEnabled" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "SavePowerNowEnabled" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "ULPMode" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "ULPMode" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "WakeOnLink" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "WakeOnLink" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "WakeOnSlot" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "WakeOnSlot" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "WakeUpModeCap" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "WakeUpModeCap" /t REG_SZ /d "0" /f >nul 2>&1
    )
    for /f %%i in ('reg query "%%a" /v "WakeUpModeCap" ^| findstr "HKEY"') do (
        Reg.exe add "%%i" /v "PnPCapabilities" /t REG_SZ /d "24" /f >nul 2>&1
    )
) >nul 2>&1

::::::::::::::::
:: GPU Tweaks ::
::::::::::::::::

:: DXKrnl
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v DpiMapIommuContiguous /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "CreateGdiPrimaryOnSlaveGPU" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DriverSupportsCddDwmInterop" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DxgkCddSyncDxAccess" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DxgkCddSyncGPUAccess" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DxgkCddWaitForVerticalBlankEvent" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DxgkCreateSwapChain" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DxgkFreeGpuVirtualAddress" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DxgkOpenSwapChain" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DxgkShareSwapChainObject" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DxgkWaitForVerticalBlankEvent" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "DxgkWaitForVerticalBlankEvent2" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "SwapChainBackBuffer" /t REG_DWORD /d "1" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v "TdrResetFromTimeoutAsync" /t REG_DWORD /d "1" /f >NUL 2>&1

::::::::::::::
:: MSI Mode ::
::::::::::::::

:: Set for the graphics card.
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID') do set "str=%%i" & if "!str:PCI\VEN_=!" neq "!str!" reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MessageNumberLimit" /f >NUL 2>&1
for /f %%a in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /L "VEN_"') do (
	reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t reg_DWORD /d "1" /f >NUL 2>&1
)

:: Set for USB / portable devices.
for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do (
	reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t reg_DWORD /d "1" /f >NUL 2>&1
)

:: Set for networking devices.
for /f %%a in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do (
	reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t reg_DWORD /d "1" /f >NUL 2>&1
)
for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\PCI"^| findstr "HKEY"') do (
	for /f "tokens=*" %%a in ('reg query "%%i"^| findstr "HKEY"') do reg delete "%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >NUL 2>&1
)
	
:: Disable Power Saving
for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "StorPort"^| findstr "StorPort"') do reg add "%%i" /v "EnableIdlePowerManagement" /t reg_DWORD /d "0" /f >NUL 2>&1
for /f "tokens=*" %%i in ('wmic PATH Win32_PnPEntity GET DeviceID ^| findstr "USB\VID_"') do (
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Storage" /v "StorageD3InModernStandby" /t	reg_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnhancedPowerManagementEnabled" /t	reg_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "AllowIdleIrpInD3" /t	reg_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnableSelectiveSuspend" /t	reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t	reg_DWORD /d "1" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "DeviceSelectiveSuspended" /t	reg_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendEnabled" /t	reg_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendOn" /t	reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t	reg_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "D3ColdSupported" /t	reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\stornvme\Parameters\Device" /v "IdlePowerMode" /t	reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\pci\Parameters" /v "ASPMOptOut" /t	reg_DWORD /d "1" /f
)

:: Import and set the powerplan
powercfg -delete a1841308-3541-4fab-bc81-f71556f20b4a
powercfg -delete 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg -delete e9a42b02-d5df-448d-aa00-03f14749eb61

:: Power Quality Of Life
:: Credits: zusier
if %LAPTOP% EQU 0 (
	for %%a in (AllowIdleIrpInD3 D3ColdSupported DeviceSelectiveSuspended EnableIdlePowerManagement	EnableSelectiveSuspend
		EnhancedPowerManagementEnabled IdleInWorkingState SelectiveSuspendEnabled SelectiveSuspendOn WaitWakeEnabled 
		WakeEnabled WdfDirectedPowerTransitionEnable) do (
		for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "%%a" ^| findstr "HKEY"') do (
			reg add "%%b" /v "%%a" /t REG_DWORD /d "0" /f >NUL 2>&1
		)
	)
) else (
	powercfg /s 381b4222-f694-41f0-9685-ff5bb260df2e >NUL 2>&1
)

:: Processor
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v DistanceThresholdInDIPS /t REG_DWORD /d 00000028 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v MagnetismDelayInMilliseconds /t REG_DWORD /d 00000032 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v MagnetismUpdateIntervalInMilliseconds /t REG_DWORD /d 00000010 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v AttractionRectInsetInDIPS /t REG_DWORD /d 00000005 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v IRRemoteNavigationDelta /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v CursorSensitivity /t REG_DWORD /d 00002710 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v VelocityInDIPSPerSecond /t REG_DWORD /d 00000168 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v CursorUpdateInterval /t REG_DWORD /d 1 /f >NUL 2>&1

:: Valorant DSCP policies
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Version" /t REG_SZ /d "1.0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Application Name" /t REG_SZ /d "valorant.exe" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Protocol" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Local Port" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Local IP" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Local IP Prefix Length" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Remote Port" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Remote IP" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Remote IP Prefix Length" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "DSCP Value" /t REG_SZ /d "46" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Throttle Rate" /t REG_SZ /d "-1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Version" /t REG_SZ /d "1.0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Application Name" /t REG_SZ /d "VALORANT-Win64-Shipping.exe" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Protocol" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Local Port" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Local IP" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Local IP Prefix Length" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Remote Port" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Remote IP" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Remote IP Prefix Length" /t REG_SZ /d "*" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "DSCP Value" /t REG_SZ /d "46" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\VALORANT" /v "Throttle Rate" /t REG_SZ /d "-1" /f

:: BCDEdit configuration.
bcdedit /deletevalue nx
bcdedit /deletevalue useplatformclock > NUL 2>&1
bcdedit /set disabledynamictick yes > NUL 2>&1
bcdedit /set useplatformtick yes > NUL 2>&1
bcdedit /timeout 10 > NUL 2>&1
bcdedit /set bootux disabled > NUL 2>&1
bcdedit /set bootmenupolicy Legacy > NUL 2>&1
bcdedit /set hypervisorlaunchtype off > NUL 2>&1
bcdedit /set tpmbootentropy ForceDisable > NUL 2>&1
bcdedit /set quietboot yes > NUL 2>&1
bcdedit /set {globalsettings} custom:16000067 true > NUL 2>&1
bcdedit /set {globalsettings} custom:16000069 true > NUL 2>&1
bcdedit /set {globalsettings} custom:16000068 true > NUL 2>&1

:: Set the DuckOS' name to DuckOS.. so it can be easily identified when dualbooting.
bcdedit /set {current} description DuckOS

:: Disable Recovery
reagentc /disable
bcdedit /set {current} recoveryenabled no

:: Disable Devices with DevManView
cd /d C:\Windows\DuckOS_Modules
devmanview /disable "Composite Bus Enumerator"
devmanview /disable "System Speaker" MemoryDiagnostic
devmanview /disable "System Timer"
devmanview /disable "UMBus Root Bus Enumerator"
devmanview /disable "Microsoft System Management BIOS Driver"
devmanview /disable "High Precision Event Timer"
devmanview /disable "PCI Encryption/Decryption Controller"
devmanview /disable "AMD PSP"
devmanview /disable "Intel SMBus"
devmanview /disable "Intel Management Engine"
devmanview /disable "PCI Memory Controller"
devmanview /disable "PCI standard RAM Controller"
devmanview /disable "Microsoft Kernel Debug Network Adapter"
devmanview /disable "SM Bus Controller"
devmanview /disable "NDIS Virtual Network Adapter Enumerator"
devmanview /disable "Numeric Data Processor"
devmanview /disable "Microsoft RRAS Root Enumerator"
devmanview /disable "WAN Miniport (IKEv2)"
devmanview /disable "WAN Miniport (IP)"
devmanview /disable "WAN Miniport (IPv6)"
devmanview /disable "WAN Miniport (L2TP)"
devmanview /disable "WAN Miniport (Network Monitor)"
devmanview /disable "WAN Miniport (PPPOE)"
devmanview /disable "WAN Miniport (PPTP)"
devmanview /disable "WAN Miniport (SSTP)"

:::::::::::::::::
:: CLEANING UP ::
:::::::::::::::::
 
:: Misc Tweaks
lodctr /r >nul 2>&1

:: Change the NTP server from the Windows Server to pool.ntp.org
sc config W32Time start=demand >nul 2>nul
sc start W32Time >nul 2>nul
w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"
sc queryex "w32time"|Find "STATE"|Find /v "RUNNING"||(
    net stop w32time
    net start w32time
) >nul 2>nul

:: Re-sync the time to pool.ntp.org
w32tm /config /update
w32tm /resync
sc stop W32Time
sc config W32Time start=disabled

:: Disable USB Autorun/play
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d "1" /f

:: Disable Network Navigation pane in file explorer
reg add "HKEY_CLASSES_ROOT\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder" /v "Attributes" /t REG_DWORD /d 2962489444 /f

:: tokens arg breaks path to just \Device instead of \Device Parameters
:: Disable Power savings on drives
for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "StorPort"^| findstr "StorPort"') do reg add "%%i" /v "EnableIdlePowerManagement" /t REG_DWORD /d "0" /f
powershell -NoProfile -Command "$devices = Get-WmiObject Win32_PnPEntity; $powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi; foreach ($p in $powerMgmt){$IN = $p.InstanceName.ToUpper(); foreach ($h in $devices){$PNPDI = $h.PNPDeviceID; if ($IN -like \"*$PNPDI*\"){$p.enable = $False; $p.psbase.put()}}}" >nul 2>nul

:: Unhide powerplan attributes
:: Credits to: Eugene Muzychenko
for /f "tokens=1-9* delims=\ " %%A in ('reg query HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings /s /f attributes /e') do (
  if /i "%%A" == "HKLM" (
    set Ident=
    if not "%%G" == "" (
      set Err=
      set Group=%%G
      set Setting=%%H
      if "!Group:~35,1!" == "" set Err=group
      if not "!Group:~36,1!" == "" set Err=group
      if not "!Setting!" == "" (
        if "!Setting:~35,1!" == "" set Err=setting
        if not "!Setting:~36,1!" == "" set Err=setting
        Set Ident=!Group!:!Setting!
      ) else (
        Set Ident=!Group!
      )
      if not "!Err!" == "" (
        echo ***** Error in !Err! GUID: !Ident"
      )
    )
  ) else if "%%A" == "Attributes" (
    if "!Ident!" == "" (
      echo ***** No group/setting GUIDs before Attributes value
    )
    set /a Attr = %%C
    set /a Hidden = !Attr! ^& 1
    if !Hidden! equ 1 (
      echo Unhiding !Ident!
      powercfg -attributes !Ident::= ! -attrib_hide
    )
  )
)

:: Windows Server Update Client ID
sc stop wuauserv >nul 2>nul
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v "SusClientId" /t REG_SZ /d "00000000-0000-0000-0000-000000000000" /f

:: Disable hibernation completely..
powercfg -h off
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /t reg_DWORD /d "0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t reg_DWORD /d "0" /f >NUL 2>&1

:: GPO for Startmenu (tiles)
reg add "HKLM\Software\Policies\Microsoft\Windows\Explorer" /v "LockedStartLayout" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\{2F5183E9-4A32-40DD-9639-F9FAF80C79F4}Machine\Software\Policies\Microsoft\Windows\Explorer" /v "StartLayoutFile" /t REG_EXPAND_SZ /d "C:\Windows\layout.xml" /f

:: disable windows updates
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "IncludeRecommendedUpdates" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AutoInstallMinorUpdates" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferQualityUpdates" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAUAsDefaultShutdownOption" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "	DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "AUPowerManagement" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "ManagePreviewBuildsPolicyValue" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAUShutdownOption" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableDualScan" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "EnableFeaturedSoftware" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferFeatureUpdatesPeriodInDays" /t REG_DWORD /d "365" /f
reg add "HKLM\Software\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t REG_DWORD /d "2" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "AllowAutoWindowsUpdateDownloadOverMeteredNetwork" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferFeatureUpdates" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "BranchReadinessLevel" /t REG_DWORD /d "20" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "ManagePreviewBuilds" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d "2" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "SetAutoRestartNotificationDisable" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferQualityUpdatesPeriodInDays" /t REG_DWORD /d "4" /f

:: Disable Speech Model Updates
reg add "HKLM\Software\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t REG_DWORD /d "0" /f

:: Data Queue Sizes -- for both the keyboard and the mouse!
reg add "HKLM\System\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "25" /f
reg add "HKLM\System\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "25" /f

:: File Explorer settings..
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoLowDiskSpaceChecks" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "LinkResolveIgnoreLinkInfo" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveSearch" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoResolveTrack" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInstrumentation" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ListviewShadow" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "NoRemoteDestinations" /t REG_DWORD /d "1" /f

:: Old Alt Tab
%currentuser% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" /t REG_DWORD /d "1" /f

:: Disable Text/Ink/Handwriting Telemetry
reg add "HKLM\Software\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d "1" /f

:: Disable Sending KMS client activation data to Microsoft automatically.. -- you tryna pirate?? damn??
reg add "HKLM\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" /v "NoGenTicket" /t REG_DWORD /d "1" /f

:: Disable Settings Sync
reg add "HKLM\Software\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSync" /t REG_DWORD /d "2" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSyncUserOverride" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\SettingSync" /v "DisableSyncOnPaidNetwork" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "5" /f

:: Disable Feedback
%currentuser% reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f

:: Hide "Meet Now" button. It's crap if we wanna be honest.
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f

:: Disable Location Tracking
reg add "HKLM\Software\Policies\Microsoft\FindMyDevice" /v "AllowFindMyDevice" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\FindMyDevice" /v "LocationSyncEnabled" /t REG_DWORD /d "0" /f

:: Advertising Info
reg add "HKLM\Software\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f

:: Delete the "Readyboost" tab from external drives.
reg delete "HKEY_CLASSES_ROOT\Drive\shellex\PropertySheetHandlers\{55B3A0BD-4D28-42fe-8CFB-FA3EDFF969B8}" /f >nul 2>nul

:: Disable Windows Media Player DRM Online Access
reg add "HKLM\Software\Policies\Microsoft\WMDRM" /v "DisableOnline" /t REG_DWORD /d "1" /f

:: Show all tasks on the "Control Panel", credits: Tenforums
reg add "HKLM\Software\Classes\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}" /ve /t REG_SZ /d "All Tasks" /f
reg add "HKLM\Software\Classes\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}" /v "InfoTip" /t REG_SZ /d "View list of all Control Panel tasks" /f
reg add "HKLM\Software\Classes\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}" /v "System.ControlPanel.Category" /t REG_SZ /d "5" /f
reg add "HKLM\Software\Classes\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}\DefaultIcon" /ve /t REG_SZ /d "%%WinDir%%\System32\imageres.dll,-27" /f
reg add "HKLM\Software\Classes\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}\Shell\Open\Command" /ve /t REG_SZ /d "explorer.exe shell:::{ED7BA470-8E54-465E-825C-99712043E01C}" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}" /ve /t REG_SZ /d "All Tasks" /f

:: Disable Fault Tolerant Heap
:: Link with explanations: https://docs.microsoft.com/en-us/windows/win32/win7appqual/fault-tolerant-heap
:: Works for Windows 7 and up!
reg add "HKLM\Software\Microsoft\FTH" /v "Enabled" /t REG_DWORD /d "0" /f

:: GameBar/FSE Settings
:: Disables Win+G shortcut
%currentuser% reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\GameBar" /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f
%currentuser% reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f
%currentuser% reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f
%currentuser% reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d "0" /f
%currentuser% reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "__COMPAT_LAYER" /t REG_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f

:: Disable DWM's AeroPeek
:: source: Winaero Tweaker
%currentuser% reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "EnableAeroPeek" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\DWM" /v "DisallowAnimations" /t REG_DWORD /d "1" /f
%currentuser% reg add "HKCU\SOFTWARE\Microsoft\Windows\DWM" /v "Composition" /t REG_DWORD /d "0" /f

:: Add batch (command prompt) files to the right-click "new file" menu
reg add "HKLM\Software\Classes\.bat\ShellNew" /v "ItemName" /t REG_EXPAND_SZ /d "@C:\Windows\System32\acppage.dll,-6002" /f
reg add "HKLM\Software\Classes\.bat\ShellNew" /v "NullFile" /t REG_SZ /d "" /f

:: Add registry files to the right-click "new file" menu
reg add "HKLM\Software\Classes\.reg\ShellNew" /v "ItemName" /t REG_EXPAND_SZ /d "@C:\Windows\regedit.exe,-309" /f
reg add "HKLM\Software\Classes\.reg\ShellNew" /v "NullFile" /t REG_SZ /d "" /f

:: "Merge as TrustedInstaller" for registry files
reg add "HKEY_CLASSES_ROOT\regfile\Shell\RunAs" /ve /t REG_SZ /d "Merge As TrustedInstaller" /f
reg add "HKEY_CLASSES_ROOT\regfile\Shell\RunAs" /v "HasLUAShield" /t REG_SZ /d "1" /f
reg add "HKEY_CLASSES_ROOT\regfile\Shell\RunAs\Command" /ve /t REG_SZ /d "nsudo -U:T -P:E reg import "%%1"" /f

:: Disable Bluetooth
echo %c_red%Disabling Bluetooth...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BluetoothUserService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
sc config BluetoothUserService start=disabled >nul 2>&1
sc config BTAGService start=disabled >nul 2>&1
sc config BthAvctpSvc start=disabled >nul 2>&1
sc config bthserv start=disabled >nul 2>&1

:: Disable HPET and Synthethic Timer
echo %c_red%Disabling HPET and Synthethic Timer...
powershell -MTA -Command "Get-PnpDevice | Where-Object { $_.InstanceId -like 'ACPI\PNP0103\2&daba3ff&*' } | Disable-PnpDevice -Confirm:$false"
bcdedit /deletevalue useplatformclock >nul 2>&1
bcdedit /set disabledynamictick yes >nul 2>&1
bcdedit /set useplatformtick yes >nul 2>&1

::::::::::::
:: Finish ::
::::::::::::

:: Do not reduce sounds while in a call
%currentuser% reg add "HKCU\SOFTWARE\Microsoft\Multimedia\Audio" /v "UserDuckingPreference" /t REG_DWORD /d "3" /f

:: ? (google it)
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\2674077835" /v "EnabledState" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\2674077835" /v "EnabledStateOptions" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\4095660171" /v "EnabledState" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\FeatureManagement\Overrides\4\4095660171" /v "EnabledStateOptions" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell" /v "BagMRU Size" /t REG_DWORD /d "1" /f >nul 2>&1

:: Switch from Public To Private firewall..
powershell -NoProfile "$net=get-netconnectionprofile; Set-NetConnectionProfile -Name $net.Name -NetworkCategory Private" >nul 2>&1

:: Ask if the user want's to send the user post install log..
:: feel free to send me "nice" messages through the webhook... AAAAAA
call :MsgBox "Do you want to send the post install log to fikinoob (duckOS author)?"  "VBYesNo+VBQuestion" "Question"
if %errorlevel% EQU 7 (
    cd /d %WinDir%\DuckOS_Modules\Get-Log
    powershell -EP Bypass -Command .\Get-ConsoleAsText.ps1 >>"%USERPROFILE%\Desktop\Post_Install_log.txt"
    timeout 0 /nobreak
    curl --silent --output /dev/null -F tasks=@"%USERPROFILE%\Desktop\Post_Install_log.txt" https://discord.com/api/webhooks/1009406828179894322/6z0oP7vDdTQAFhX5cyiFGKccXpVFb9lE2tgbX6jgqxjR1bz6-6xjaowvkHHJZ8kL4alT
    echo %c_green%Successfully Sent The Log file!
)

:: Cancel any pending shutdowns, delete the Modules folder, this post script and restart..
shutdown /a
shutdown /r /t 2 /f

:: Delete the post script!
start /min "" "cmd.exe" /c del /f /q %0
exit

:InstallOpenShell
if not exist %programfiles%\Open-Shell\StartMenu.exe (
	echo ! OpenShell not found, trying to reinstall..
	if exist %SystemRoot%\Setup\Files\OpenShellSetup_4_4_170.exe (
		echo ! OpenShell installer detected in %Systemroot%\Setup\Files\OpenShellSetup_4_4_170.exe .. reinstalling..
		start /wait "" "%SystemRoot%\Setup\Files\OpenShellSetup_4_4_170.exe" /qn ADDLOCAL=StartMenu
		echo ! OpenShell installation done.
	)
)

:MsgBox [Prompt] [Type] [Title]
    setlocal enableextensions
    set "tempFile=%temp%\%~nx0.%random%%random%%random%vbs.tmp"
    >"%tempFile%" echo(WScript.Quit msgBox("%~1",%~2,"%~3") & cscript //nologo //e:vbscript "%tempFile%"
    set "exitCode=%errorlevel%" & del "%tempFile%" >nul 2>nul
    endlocal & exit /b %exitCode%
