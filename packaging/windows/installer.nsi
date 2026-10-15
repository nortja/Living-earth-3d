Unicode true
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!ifndef VERSION
!define VERSION "0.3.0"
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
Function .onInit
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
  File "..\..\assets\earth\ATTRIBUTION.md"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateShortcut "$DESKTOP\Living Earth 3D.lnk" "$INSTDIR\LivingEarth3D.exe"
  CreateDirectory "$SMPROGRAMS\Living Earth 3D"
  CreateShortcut "$SMPROGRAMS\Living Earth 3D\Living Earth 3D.lnk" "$INSTDIR\LivingEarth3D.exe"
  CreateShortcut "$SMPROGRAMS\Living Earth 3D\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\LivingEarth3D" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "DisplayName" "Living Earth 3D"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "Publisher" "Jaison Norton"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "UninstallString" '$\"$INSTDIR\Uninstall.exe$\"'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "DisplayIcon" "$INSTDIR\LivingEarth3D.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D" "NoRepair" 1
  IfSilent 0 done
  Exec '"$INSTDIR\LivingEarth3D.exe"'
  done:
SectionEnd
Section "Uninstall"
  SetShellVarContext current
  Delete "$DESKTOP\Living Earth 3D.lnk"
  Delete "$SMPROGRAMS\Living Earth 3D\Living Earth 3D.lnk"
  Delete "$SMPROGRAMS\Living Earth 3D\Uninstall.lnk"
  RMDir "$SMPROGRAMS\Living Earth 3D"
  Delete "$INSTDIR\LivingEarth3D.exe"
  Delete "$INSTDIR\update.ps1"
  Delete "$INSTDIR\LivingEarth3D.scr"
  Delete "$INSTDIR\Godot-LICENSE.txt"
  Delete "$INSTDIR\THREE-LICENSE.txt"
  Delete "$INSTDIR\ATTRIBUTION.md"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "Software\LivingEarth3D"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\LivingEarth3D"
SectionEnd
