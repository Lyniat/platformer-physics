:; # ------------------- Auto loader for DragonRuby ------------------------
:; # last tested with v 6.38 on Windows 11 and macOS 26.0.1
:; # you might have to execute 'chmod +x run.bat' first on macOS or Linux
:; # ---------------------- POSIX (bash/zsh/dash) --------------------------
:; if [ -z 0 ]; then # prevent batch prelude from running in POSIX shells
@echo off
goto :MICROSOFT
:; fi

# Exit on errors, treat unset vars as errors, fail pipes properly
set -euo pipefail

currentdir=""
prev="$PWD"

# Walk upward until we find the dragonruby executable or reach root
while [ ! -e "$PWD/dragonruby" ]; do
  base="${PWD##*/}"

  # Build relative path from project root to current directory
  if [ -n "$currentdir" ]; then
    currentdir="$base/$currentdir"
  else
    currentdir="$base"
  fi

  cd .. || break

  # Root guard: stop if we can't go up anymore
  if [ "$PWD" = "$prev" ]; then
    printf 'Error: "dragonruby" not found in any parent directory.\n' >&2
    exit 1
  fi
  prev="$PWD"
done

# Fallback to "." if currentdir is empty (rare edge case)
: "${currentdir:=.}"

# Execute DragonRuby with the constructed relative path
exec "./dragonruby" "$currentdir"

exit 0

:MICROSOFT
REM -------------------- Windows (CMD) ---------------------------------
setlocal enabledelayedexpansion

set "current_dir="
set "prev=%CD%"

:LOOP
REM Check if dragonruby.exe exists here
if exist "dragonruby.exe" (
  set "dr_path=%CD%"
  goto RUN
)

REM Extract folder name and accumulate relative path
for %%a in ("%CD%") do (
  if defined current_dir (
    set "current_dir=%%~nxa\!current_dir!"
  ) else (
    set "current_dir=%%~nxa"
  )
)

cd ..

REM Root guard: stop if we didn't move
if /I "%CD%"=="%prev%" (
  echo Error: "dragonruby.exe" not found in any parent directory.& exit /b 1
)
set "prev=%CD%"
goto LOOP

:RUN
REM Launch DragonRuby: "" = empty window title for `start`
start "" "%dr_path%\dragonruby.exe" "%current_dir%"
exit /b 0