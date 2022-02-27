try {
$paths = ls | ? { -not(($_.FullName -ilike "*love-bins*") -or ($_.FullName -ilike "*.ps1") -or ($_.FullName -ilike "*publish*")) } | % { $_.FullName; }


ls -Recurse .\publish\faultLines\ | Remove-Item -Recurse -Force 

# New-Item .\publish\faultLines\ -ItemType Directory
Remove-Item -Recurse -Force .\publish\faultLines.love
Compress-Archive $paths publish\faultLines.love
Push-location publish\
"Fault Lines" | npx love.js faultLInes.love faultLines -c
cd faultLines
web-dir
}
finally {
    Pop-location
}
# Compress-Archive (ls -Recurse) ..\CasterFightWeba.zip -Force
