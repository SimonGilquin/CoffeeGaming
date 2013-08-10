(Get-Host).UI.RawUI.WindowTitle = "Karma Tests"
$env:CHROME_BIN="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$basedir = Split-Path -parent (Split-Path -parent $PSCommandPath)
karma start $basedir/karma.conf.js