Unicode true
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "WinMessages.nsh"
!ifndef VERSION
!define VERSION "0.6.0"
!endif
!ifndef BUILD_DIR
!define BUILD_DIR "..\..\build\windows"
!endif
!ifndef OUTPUT
!define OUTPUT "..\..\dist\LivingEarth3D-Setup-${VERSION}.exe"
!endif
!define APP_NAME "Living Earth 3D Development"
!define APP_KEY "LivingEarth3DDevelopment"
Name "${APP_NAME}"
OutFile "${OUTPUT}"
InstallDir "$LOCALAPPDATA\Programs\${APP_NAME}"
InstallDirRegKey HKCU "Software\${APP_KEY}" "InstallDir"
RequestExecutionLevel user
SetCompressor /SOLID lzma
ShowInstDetails nevershow
VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "FileDescription" "Living Earth 3D Installer"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "LegalCopyright" "Living Earth 3D contributors"
!define MUI_ICON "..\..\assets\icon.ico"
!define MUI_UNICON "..\..\assets\icon.ico"
!define MUI_WELCOMEPAGE_TITLE "Living Earth 3D · Development Preview"
!define MUI_WELCOMEPAGE_TEXT "Explore Earth with the next development build. This preview installs the globe, optional screensaver, and desktop shortcut. Your local preferences are preserved."
!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN "$INSTDIR\LivingEarth3D.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch Living Earth 3D"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"
!macro CloseApplication FUNCTION_NAME
Function ${FUNCTION_NAME}
  FindWindow $0 "" "${APP_NAME}"
  ${If} $0 != 0
    IfSilent running_abort
    MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "Living Earth 3D is running. Close it to continue?" IDYES request_close
    Abort
    request_close:
    SendMessage $0 ${WM_CLOSE} 0 0 /TIMEOUT=1000
    StrCpy $1 0
    wait_for_close:
    IsWindow $0 still_running finished_close
    still_running:
    Sleep 100
    IntOp $1 $1 + 1
    IntCmp $1 100 close_timeout wait_for_close close_timeout
    close_timeout:
    MessageBox MB_OK "Please close Living Earth 3D, then run this installer again."
    running_abort:
    Abort
    finished_close:
  ${EndIf}
FunctionEnd
!macroend
!insertmacro CloseApplication CloseLivingEarth
!insertmacro CloseApplication un.CloseLivingEarth
Function un.onInit
  Call un.CloseLivingEarth
FunctionEnd
Function .onInit
  Call CloseLivingEarth
  ${IfNot} ${RunningX64}
    MessageBox MB_OK "Living Earth 3D requires 64-bit Windows."
    Abort
  ${EndIf}
FunctionEnd
Section "Living Earth 3D"
  SetShellVarContext current
  SetOutPath "$INSTDIR"
  File "${BUILD_DIR}\LivingEarth3D.exe"
  File /oname=LivingEarth3D.scr "${BUILD_DIR}\LivingEarth3D.exe"
  File "update.ps1"
  File "..\..\assets\Godot-LICENSE.txt"
  File "..\..\assets\earth\THREE-LICENSE.txt"
  File "..\..\assets\earth\CC-BY-4.0.txt"
  File "..\..\assets\earth\ATTRIBUTION.md"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\LivingEarth3D.exe"
  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\LivingEarth3D.exe"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\${APP_KEY}" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_KEY}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_KEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_KEY}" "Publisher" "Jaison Norton"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_KEY}" "UninstallString" '$\"$INSTDIR\Uninstall.exe$\"'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_KEY}" "DisplayIcon" "$INSTDIR\LivingEarth3D.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_KEY}" "NoRepair" 1
SectionEnd
Section "Uninstall"
  SetShellVarContext current
  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk"
  RMDir "$SMPROGRAMS\${APP_NAME}"
  Delete "$INSTDIR\LivingEarth3D.exe"
  Delete "$INSTDIR\update.ps1"
  Delete "$INSTDIR\LivingEarth3D.scr"
  Delete "$INSTDIR\Godot-LICENSE.txt"
  Delete "$INSTDIR\THREE-LICENSE.txt"
  Delete "$INSTDIR\CC-BY-4.0.txt"
  Delete "$INSTDIR\ATTRIBUTION.md"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "Software\${APP_KEY}"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_KEY}"
SectionEnd
