:; if [ -z 0 ]; then #
@echo off
goto :MICROSOFT
fi

while ! [[ -n $(find "$PWD"/ -maxdepth 1 -name "dragonruby") ]] ; do
    currentdir=${PWD##*/}/${currentdir}
    cd ..
done
./dragonruby ${currentdir}

exit 0

:MICROSOFT
for /f "delims=\" %%a in ("%cd%") do set current-dir=%%~nxa

:LOOP
if exist dragonruby.exe (
set dr-path=%CD%
) else (
cd..
if not exist dragonruby.exe (
for /f "delims=\" %%a in ("%cd%") do set current-dir=%%~nxa\%current-dir%
)
goto :LOOP
)

start %dr-path%\dragonruby.exe %current-dir%