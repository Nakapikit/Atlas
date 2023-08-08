@echo off
setlocal EnableDelayedExpansion

whoami /user | find /i "S-1-5-18" > nul 2>&1 || (
	call RunAsTI.cmd "%~f0" "%*"
	exit /b
)

echo This will break a majority of UWP apps and their deployment.
echo Extra note: This breaks the "About" page in Immersive Control Panel. If you require it, enable the AppX service.
pause

:: Detect if a Microsoft account is used
PowerShell -NoP -C "Get-LocalUser | Select-Object Name,PrincipalSource" | findstr /C:"MicrosoftAccount" > nul 2>&1 && set MSACCOUNT=yes || set MSACCOUNT=no
if "!MSACCOUNT!" == "no" (call setSvc.cmd wlidsvc 4) else (echo "Microsoft Account detected, not disabling wlidsvc...")

:: Disable the option for Microsoft Store in the "Open with" dialog
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoUseStoreOpenWith" /t REG_DWORD /d "1" /f > nul 2>&1

:: Block access to Microsoft Store
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "RemoveWindowsStore" /t REG_DWORD /d "1" /f > nul 2>&1

for %%a in (
	"AppXSvc"
	"ClipSVC"
	"FileCrypt"
	"FileInfo"
	"InstallService"
	"LicenseManager"
	"TokenBroker"
	"WinHttpAutoProxySvc"
) do (
	call setSvc.cmd %%~a 4
)

echo Finished, please reboot your device for changes to apply.
pause
exit /b