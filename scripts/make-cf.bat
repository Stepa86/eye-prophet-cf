set WORKSPACE=%~dp0workspace
set SRC=%~dp0src
set EDT_PROJECT=%~dp0..\eye-prophet-cf
set CF=%~dp0..\cf\1Cv8.cf
rd /S /Q %SRC%
md %SRC%
rd /S /Q %WORKSPACE%
md %WORKSPACE%
call ring edt workspace export --project %EDT_PROJECT% --configuration-files %SRC% --workspace-location %WORKSPACE%
call runner compile -s %SRC% -o %CF%
