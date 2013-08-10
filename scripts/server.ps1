(Get-Host).UI.RawUI.WindowTitle = "Express Web server"
echo "Starting Web Server listening at http://localhost:3000/"
$basedir = Split-Path -parent (Split-Path -parent $PSCommandPath)
node $basedir/app.js