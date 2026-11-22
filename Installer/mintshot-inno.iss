#ifndef ProductId
  #define ProductId "MintShot"
#endif
#ifdef TestBuild
  #define OutputName "MintShotSetup-Test"
  #define StartupKey "Software\MintShotInstallerFixture\" + ProductId + "\Run"
  #define LegacyUninstallKey "Software\Microsoft\Windows\CurrentVersion\Uninstall\" + ProductId + "_legacy"
#else
  #ifdef ReleaseBuild
    #define OutputName "MintShotSetup-1.0.40"
  #elif defined(AboutPreview)
    #define OutputName "MintShotSetup-1.0.39-Preview"
  #elif defined(SmoothWheelLogo)
    #define OutputName "MintShotSetup-SmoothWheel-Logo"
  #else
    #define OutputName "MintShotSetup-1.0.38"
  #endif
  #define StartupKey "Software\Microsoft\Windows\CurrentVersion\Run"
  #define LegacyUninstallKey "Software\Microsoft\Windows\CurrentVersion\Uninstall\MintShot"
#endif

[Setup]
AppId={#ProductId}
AppName=MintShot
#ifdef ReleaseBuild
AppVersion=1.0.40
VersionInfoVersion=1.0.40.0
#elif defined(AboutPreview)
AppVersion=1.0.39
#else
AppVersion=1.0.38
#endif
#ifdef ReleaseBuild
AppVerName=MintShot 1.0.40
#else
AppVerName=MintShot
#endif
AppPublisher=MintShot
DefaultDirName={autopf}\MintShot
UsePreviousAppDir=no
DefaultGroupName=MintShot
DisableProgramGroupPage=yes
DisableDirPage=no
DisableWelcomePage=no
DisableReadyPage=no
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
UsePreviousPrivileges=no
MinVersion=10.0
#ifdef TestBuild
OutputDir=..\work\inno-smoke-build
#elif defined(ReleaseBuild)
OutputDir=..\Releases
#else
OutputDir=..\Releases
#endif
OutputBaseFilename={#OutputName}
SetupIconFile=..\Resources\MintShot-feather.ico
UninstallDisplayIcon={app}\MintShot.exe
#ifdef ReleaseBuild
UninstallDisplayName=MintShot 1.0.40
#elif defined(AboutPreview)
UninstallDisplayName=MintShot 1.0.39
#else
UninstallDisplayName=MintShot
#endif
WizardStyle=classic
WizardImageFile=mintshot-wizard.bmp
WizardSmallImageFile=mintshot-wizard-small.bmp
WizardImageStretch=no
ShowLanguageDialog=yes
UsePreviousLanguage=yes
LanguageDetectionMethod=uilanguage
Compression=lzma2
SolidCompression=yes
CloseApplications=no
RestartApplications=no
SetupLogging=yes
UninstallLogMode=append
#ifndef TestBuild
AppMutex=Local\MintShot.SingleInstance
SetupMutex=Local\MintShot.InnoSetup
#endif

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Messages]
WelcomeLabel1=Вас приветствует мастер установки MintShot
WelcomeLabel2=Программа установит MintShot на ваш компьютер.%n%nВыделяйте область экрана, добавляйте заметки и сохраняйте скриншоты.%n%nДля продолжения нажмите «Далее».
FinishedHeadingLabel=Установка MintShot завершена
FinishedLabelNoIcons=Программа MintShot установлена на ваш компьютер.
FinishedLabel=Программа MintShot установлена на ваш компьютер. Для выхода из программы установки нажмите «Завершить».

[Tasks]
Name: "desktopicon"; Description: "Создать значок на рабочем столе"; GroupDescription: "Ярлыки:"; Flags: unchecked
Name: "startup"; Description: "Запускать MintShot при входе в Windows"; GroupDescription: "Автозагрузка:"; Flags: unchecked; Check: not IsAdminInstallMode

[Files]
#ifdef ReleaseBuild
Source: "..\Build\MintShot.exe"; DestDir: "{app}"; Flags: ignoreversion
#elif defined(AboutPreview)
Source: "..\outputs\MintShot-AboutPreview\MintShot.exe"; DestDir: "{app}"; Flags: ignoreversion
#elif defined(SmoothWheelLogo)
Source: "..\outputs\MintShot-SmoothWheel-Logo\MintShot.exe"; DestDir: "{app}"; Flags: ignoreversion
#else
Source: "..\outputs\MintShot-v61\MintShot.exe"; DestDir: "{app}"; Flags: ignoreversion
#endif
Source: "..\Resources\Geometry\LICENSE"; DestDir: "{app}"; DestName: "Lucide-LICENSE.txt"; Flags: ignoreversion

[Icons]
#ifdef TestBuild
Name: "{app}\FixtureShortcuts\MintShot"; Filename: "{app}\MintShot.exe"; WorkingDir: "{app}"; IconFilename: "{app}\MintShot.exe"
Name: "{app}\FixtureShortcuts\Удалить MintShot"; Filename: "{uninstallexe}"
#else
Name: "{group}\MintShot"; Filename: "{app}\MintShot.exe"; WorkingDir: "{app}"; IconFilename: "{app}\MintShot.exe"; AppUserModelID: "MintShot.Desktop"
Name: "{group}\Удалить MintShot"; Filename: "{uninstallexe}"
Name: "{autodesktop}\MintShot"; Filename: "{app}\MintShot.exe"; WorkingDir: "{app}"; Tasks: desktopicon
#endif

[Registry]
Root: HKCU; Subkey: "{#StartupKey}"; ValueType: string; ValueName: "MintShot"; ValueData: """{app}\MintShot.exe"""; Flags: uninsdeletevalue; Check: ShouldEnableStartup
Root: HKCU; Subkey: "{#StartupKey}"; ValueName: "MintShot"; Flags: deletevalue; Check: ShouldDisableStartup

[Run]
#ifndef TestBuild
Filename: "{app}\MintShot.exe"; Description: "Запустить MintShot"; Flags: nowait postinstall skipifsilent
#endif

[InstallDelete]
Type: files; Name: "{app}\Uninstall.exe"; Check: IsLegacyInstall
Type: files; Name: "{app}\install.manifest"; Check: IsLegacyInstall
#ifdef TestBuild
Type: files; Name: "{app}\FixtureOldShortcut.lnk"; Check: IsLegacyInstall
#else
Type: files; Name: "{autoprograms}\MintShot.lnk"; Check: IsLegacyInstall
#endif

[Code]
var
  LegacyInstall: Boolean;
  StartupInitialized: Boolean;
  StartupWasEnabled: Boolean;

function InitializeSetup(): Boolean;
begin
  StartupWasEnabled := (not IsAdminInstallMode) and RegValueExists(HKCU, '{#StartupKey}', 'MintShot');
  Result := True;
end;

function IsLegacyInstall(): Boolean;
begin
  Result := LegacyInstall;
end;

function IsOwnedLegacyRoot(Root: String): Boolean;
var
  Marker: AnsiString;
begin
  Result := False;
  if LoadStringFromFile(AddBackslash(Root) + 'install.manifest', Marker) then
    Result := Pos('MintShot-8e4f68b8-915d-44fd-a625-74d835af4bdd', String(Marker)) = 1;
end;

function ShouldEnableStartup(): Boolean;
begin
  if IsAdminInstallMode then begin
    Result := False;
    Exit;
  end;
  if WizardSilent or (not StartupInitialized) then
    Result := StartupWasEnabled or WizardIsTaskSelected('startup')
  else
    Result := WizardIsTaskSelected('startup');
end;

function ShouldDisableStartup(): Boolean;
begin
  Result := (not IsAdminInstallMode) and (not ShouldEnableStartup());
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if (CurPageID = wpSelectTasks) and (not StartupInitialized) and (not WizardSilent) and (not IsAdminInstallMode) then begin
    if StartupWasEnabled then
      WizardForm.TasksList.Checked[1] := True;
    StartupInitialized := True;
  end;
end;

function UnderFolder(Path: String; Parent: String): Boolean;
var
  NormalPath: String;
  NormalParent: String;
begin
  NormalPath := AddBackslash(ExpandFileName(Path));
  NormalParent := AddBackslash(ExpandFileName(Parent));
  Result := CompareText(Copy(NormalPath, 1, Length(NormalParent)), NormalParent) = 0;
end;

function ScopeError(Path: String): String;
var
  ProtectedPath: Boolean;
begin
  Result := '';
  if IsAdminInstallMode then Exit;
  ProtectedPath := UnderFolder(Path, ExpandConstant('{commonpf32}')) or UnderFolder(Path, ExpandConstant('{win}'));
  if IsWin64 then ProtectedPath := ProtectedPath or UnderFolder(Path, ExpandConstant('{commonpf64}'));
  if ProtectedPath then
    Result := 'В эту папку нельзя установить программу в режиме «Только для меня».' + #13#10 + #13#10 + 'Оставьте папку по умолчанию или перезапустите установщик и выберите «Для всех пользователей», чтобы Windows запросила права администратора.';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Error: String;
begin
  Result := True;
  if (CurPageID = wpSelectDir) and (not WizardSilent) then begin
    Error := ScopeError(WizardDirValue());
    if Error <> '' then begin
      MsgBox(Error, mbInformation, MB_OK);
      Result := False;
    end;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  Result := ScopeError(ExpandConstant('{app}'));
  if Result <> '' then Exit;
#ifndef TestBuild
  if CheckForMutexes('Local\MintShot.SingleInstance') then begin
    Result := 'MintShot сейчас запущен. Закройте его через значок в трее → «Выход», затем нажмите «Повторить».';
    Exit;
  end;
#endif
  LegacyInstall := (not IsAdminInstallMode) and IsOwnedLegacyRoot(ExpandConstant('{app}'));
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  PreviousRoot: String;
begin
  if (CurStep = ssPostInstall) and LegacyInstall then begin
    if RegQueryStringValue(HKCU, '{#LegacyUninstallKey}', 'InstallLocation', PreviousRoot) then
      if CompareText(RemoveBackslashUnlessRoot(PreviousRoot), RemoveBackslashUnlessRoot(ExpandConstant('{app}'))) = 0 then
        RegDeleteKeyIncludingSubkeys(HKCU, '{#LegacyUninstallKey}');
  end;
end;

function InitializeUninstall(): Boolean;
begin
  Result := True;
#ifndef TestBuild
  if CheckForMutexes('Local\MintShot.SingleInstance') then begin
    MsgBox('Сначала завершите MintShot: значок в трее → «Выход». Затем повторите удаление.', mbInformation, MB_OK);
    Result := False;
  end;
#endif
end;

function UninstallProgressFormCloseQuery(): Boolean;
begin
  Result := True;
end;
