Unicode true
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "WinMessages.nsh"
!ifndef VERSION
!define VERSION "0.12.3"
!endif
!ifndef BUILD_DIR
!define BUILD_DIR "..\..\build\windows"
!endif
!ifndef OUTPUT
!define OUTPUT "..\..\dist\LivingEarth3D-Setup-${VERSION}.exe"
!endif
Name "Living Earth 3D"
OutFile "${OUTPUT}"
InstallDir "$LOCALAPPDATA\Programs\Living Earth 3D"
InstallDirRegKey HKCU "Software\LivingEarth3D" "InstallDir"
RequestExecutionLevel user
SetCompressor /SOLID lzma
ShowInstDetails nevershow
VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "Living Earth 3D"
VIAddVersionKey "FileDescription" "Living Earth 3D Installer"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "LegalCopyright" "Living Earth 3D contributors"
!define MUI_ICON "..\..\assets\icon.ico"
!define MUI_UNICON "..\..\assets\icon.ico"
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
  find_again:
  FindWindow $0 "" "Living Earth 3D"
  ${If} $0 == 0
    FindWindow $0 "LivingEarth3D.SaverHost" ""
  ${EndIf}
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
    Goto find_again
  ${EndIf}
FunctionEnd
!macroend
!insertmacro CloseApplication CloseLivingEarth
!insertmacro CloseApplication un.CloseLivingEarth
Function un.onInit
  CreateDirectory "$INSTDIR\.updates"
  FileOpen $2 "$INSTDIR\.updates\cancel" w
  FileWrite $2 "cancel"
  FileClose $2
  Sleep 1200
  Call un.CloseLivingEarth
FunctionEnd
Function .onInit
  IfFileExists "$INSTDIR\update.ps1" 0 skip_update_cancel
  CreateDirectory "$INSTDIR\.updates"
  FileOpen $2 "$INSTDIR\.updates\cancel" w
  FileWrite $2 "cancel"
  FileClose $2
  Sleep 1200
  skip_update_cancel:
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
  File "${BUILD_DIR}\LivingEarth3D.scr"
  File "update.ps1"
  File "update-core.ps1"
  File /oname=LivingEarth3D-${VERSION}.ico "..\..\assets\icon.ico"
  File "..\..\assets\Godot-LICENSE.txt"
  File "..\..\assets\earth\THREE-LICENSE.txt"
  File "..\..\assets\earth\CC-BY-4.0.txt"
  File "..\..\assets\earth\ATTRIBUTION.md"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateShortcut "$DESKTOP\Living Earth 3D.lnk" "$INSTDIR\LivingEarth3D.exe" "" "$INSTDIR\LivingEarth3D-${VERSION}.ico" 0
  CreateDirectory "$SMPROGRAMS\Living Earth 3D"
  CreateShortcut "$SMPROGRAMS\Living Earth 3D\Living Earth 3D.lnk" "$INSTDIR\LivingEarth3D.exe" "" "$INSTDIR\LivingEarth3D-${VERSION}.ico" 0
  CreateShortcut "$SMPROGRAMS\Living Earth 3D\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  CreateShortcut "$SMPROGRAMS\Living Earth 3D\Use Living Earth 3D screensaver.lnk" "$INSTDIR\LivingEarth3D.scr" "/select"
  WriteRegStr HKCU "Software\LivingEarth3D" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "DisplayName" "Living Earth 3D"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "Publisher" "Jaison Norton"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "UninstallString" '$\"$INSTDIR\Uninstall.exe$\"'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "DisplayIcon" "$INSTDIR\LivingEarth3D-${VERSION}.ico"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "NoRepair" 1
  System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, p 0, p 0)'
SectionEnd
Section "Uninstall"
  SetShellVarContext current
  ExecWait '"$INSTDIR\LivingEarth3D.scr" /unregister'
  Delete "$DESKTOP\Living Earth 3D.lnk"
  Delete "$SMPROGRAMS\Living Earth 3D\Living Earth 3D.lnk"
  Delete "$SMPROGRAMS\Living Earth 3D\Uninstall.lnk"
  Delete "$SMPROGRAMS\Living Earth 3D\Use Living Earth 3D screensaver.lnk"
  RMDir "$SMPROGRAMS\Living Earth 3D"
  Delete "$INSTDIR\LivingEarth3D.exe"
  Delete "$INSTDIR\update.ps1"
  Delete "$INSTDIR\update-core.ps1"
  RMDir /r "$INSTDIR\.updates"
  Delete "$INSTDIR\LivingEarth3D.scr"
  Delete "$INSTDIR\LivingEarth3D-*.ico"
  Delete "$INSTDIR\Godot-LICENSE.txt"
  Delete "$INSTDIR\THREE-LICENSE.txt"
  Delete "$INSTDIR\CC-BY-4.0.txt"
  Delete "$INSTDIR\ATTRIBUTION.md"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "Software\LivingEarth3D"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D"
SectionEnd
