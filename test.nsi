
### TimeStamp
!ifndef TimeStamp
    !define TimeStamp "!insertmacro _TimeStamp"
    !macro _TimeStamp FormatedString
        !ifdef __UNINSTALL__
            Call un.__TimeStamp
        !else
            Call __TimeStamp
        !endif
        Pop ${FormatedString}
    !macroend
 
    !macro __TimeStamp UN
    Function ${UN}__TimeStamp
        ClearErrors
        ## Store the needed Registers on the stack
            Push $0 ; Stack $0
            Push $1 ; Stack $1 $0
            Push $2 ; Stack $2 $1 $0
            Push $3 ; Stack $3 $2 $1 $0
            Push $4 ; Stack $4 $3 $2 $1 $0
            Push $5 ; Stack $5 $4 $3 $2 $1 $0
            Push $6 ; Stack $6 $5 $4 $3 $2 $1 $0
            Push $7 ; Stack $7 $6 $5 $4 $3 $2 $1 $0
            ;Push $8 ; Stack $8 $7 $6 $5 $4 $3 $2 $1 $0
     
        ## Call System API to get the current system Time
            System::Alloc 16
            Pop $0
            System::Call 'kernel32::GetLocalTime(i) i(r0)'
            System::Call '*$0(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2)i (.r1, .r2, n, .r3, .r4, .r5, .r6, .r7)'
            System::Free $0
     
            IntFmt $2 "%02i" $2
            IntFmt $3 "%02i" $3
            IntFmt $4 "%02i" $4
            IntFmt $5 "%02i" $5
            IntFmt $6 "%02i" $6
     
        ## Generate Timestamp
            ;StrCpy $0 "YEAR=$1$\nMONTH=$2$\nDAY=$3$\nHOUR=$4$\nMINUITES=$5$\nSECONDS=$6$\nMS$7"
            StrCpy $0 "$1$2$3$4$5$6.$7"
     
        ## Restore the Registers and add Timestamp to the Stack
            ;Pop $8  ; Stack $7 $6 $5 $4 $3 $2 $1 $0
            Pop $7  ; Stack $6 $5 $4 $3 $2 $1 $0
            Pop $6  ; Stack $5 $4 $3 $2 $1 $0
            Pop $5  ; Stack $4 $3 $2 $1 $0
            Pop $4  ; Stack $3 $2 $1 $0
            Pop $3  ; Stack $2 $1 $0
            Pop $2  ; Stack $1 $0
            Pop $1  ; Stack $0
            Exch $0 ; Stack ${TimeStamp}
     
    FunctionEnd
    !macroend
    !insertmacro __TimeStamp ""
    !insertmacro __TimeStamp "un."
!endif
###########

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

  ;Name and file
  Name "Modern UI Test"
  OutFile "WelcomeFinish.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\ModernUItest"

  ;Get installation folder from registry if available
  ;InstallDirRegKey HKCU "Software\ModernUItest" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

  ;show the install details
  ShowInstDetails show 
  ShowUninstDetails show

  ;do not close details pages immediately
  !define MUI_FINISHPAGE_NOAUTOCLOSE
  !define MUI_UNFINISHPAGE_NOAUTOCLOSE

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections
Section -SETTINGS
  ;set global install path
  ;set overwrite
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
SectionEnd

;This function creates a GUID and puts it to top of stack (Pop $0)
Function CreateGUID
  Push $0
  Push $1
  Push $2
  System::Alloc 80 
  System::Alloc 16 
  System::Call 'ole32::CoCreateGuid(i sr1) i' 
  System::Call 'ole32::StringFromGUID2(i r1, i sr2, i 80) i' 
  System::Call 'kernel32::WideCharToMultiByte(i 0, i 0, i r2, \
                i 80, t .r0, i ${NSIS_MAX_STRLEN}, i 0, i 0) i' 
  System::Free $1 
  System::Free $2
  Pop $2
  Pop $1
  Exch $0
FunctionEnd

;main install section
Section "Main Section" MainSec
  ;set install type and cwd (read only)
  SectionIn RO ;read only

  ;clear any errors
  ClearErrors

  ;overwrite existing files
  SetOverwrite on

  ;create a logging text file to current dir
  MessageBox MB_OK "creating a logging file"
  FileOpen $2 "$DESKTOP\test.txt" w

  ;write a unique GUID 
  Call CreateGUID
  Pop $0
  FileWrite $2 $0
  FileWrite $2 "????"

  ;write the timestamp and then close the log file
  ${TimeStamp} $1
  FileWrite $2 $1
  FileClose $2

  ;create necessary directories
  CreateDirectory "$INSTDIR\test_folder"

  ;install files to install directory
  File /oname=test_folder\test.txt test.txt

  ;write registry keys
  WriteRegStr HKCU "Software\ModernUItest" "Install_Dir" $INSTDIR

 

  ;create shortcuts
  CreateDirectory "$SMPROGRAMS\TEST_NSIS_THING"
  CreateShortCut "$SMPROGRAMS\TEST_NSIS_THING\test.lnk" "$INSTDIR\test_folder\test.txt"

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_MainSec ${LANG_ENGLISH} "A test section."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${MainSec} $(DESC_MainSec)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;Delete Registry keys 
  DeleteRegKey HKCU "Software\ModernUItest"

  ;remove installer, then the text file sitting on desktop & folder
  Delete "$INSTDIR\Uninstall.exe"
  Delete "$Desktop\test.txt"
  Delete "$INSTDIR\test_folder\test.txt"

  ;remove inner directories
  RMDir "$INSTDIR\test_folder"
  RMDir "$INSTDIR"

  ;DeleteRegKey /ifempty HKCU "Software\Modern UI Test"

SectionEnd