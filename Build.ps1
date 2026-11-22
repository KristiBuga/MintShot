$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    $framework = Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319'
    $compiler = Join-Path $framework 'csc.exe'
    if (!(Test-Path -LiteralPath $compiler)) {
        throw '.NET Framework 4.x compiler was not found.'
    }
    New-Item -ItemType Directory -Force -Path 'Build' | Out-Null
    $arguments = @(
        '/nologo', '/target:winexe', '/optimize+', '/codepage:65001',
        '/define:SMOOTH_WHEEL_PREVIEW;ABOUT_PREVIEW',
        '/out:Build/MintShot.exe', '/win32icon:Resources/MintShot-feather.ico',
        '/reference:System.Web.Extensions.dll',
        ('/reference:' + (Join-Path $framework 'WPF/WindowsBase.dll')),
        ('/reference:' + (Join-Path $framework 'WPF/PresentationCore.dll')),
        '/resource:Core/MintShot.Core.exe,MintShot.Payload',
        '/resource:Resources/MintShot-feather.ico,MintShot.Icon',
        '/resource:Resources/mintshot-logo-ui.png,MintShot.Logo',
        '/resource:Resources/mintshot-logo-notification.png,MintShot.NotificationLogo',
        '/resource:Resources/Geometry/LICENSE,MintShot.LucideLicense'
    )
    $icons = [ordered]@{
        move = 'hand'
        pen = 'pencil-ruler'
        line = 'slash'
        arrow = 'move-up-right'
        box = 'square-dashed'
        color = 'pipette'
        undo = 'corner-up-left'
        copy = 'clipboard-copy'
        save = 'file-down'
        reset = 'crop'
        close = 'circle-x'
    }
    foreach ($icon in $icons.GetEnumerator()) {
        $arguments += '/resource:Resources/Geometry/' + $icon.Value + '.svg,MintShot.Geometry.' + $icon.Key
    }
    $files = 'LauncherLean FastOverlayLean FrameClock TrayClickHotkeys AppBrandLean StartupOption NotificationBrand36 InlineTextCleanDrag TextEditorFrameClean GlobalHotkeys QuickAccessSettings QuickAccessOverlay CaptureDestination UpdateService MintTheme MintSettingsInputs DesktopFrame CaptureSpecks GeometricIcons MintAbout CaptureBlur CaptureMarker EditorHistory PenStabilizer'.Split(' ')
    foreach ($file in $files) { $arguments += 'Source\' + $file + '.txt' }
    & $compiler @arguments
    if ($LASTEXITCODE -ne 0) { throw 'MintShot compilation failed.' }
    Copy-Item -LiteralPath 'Resources/Geometry/LICENSE' -Destination 'Build/Lucide-LICENSE.txt'
    Write-Output 'Built Build/MintShot.exe'
}
finally { Pop-Location }
