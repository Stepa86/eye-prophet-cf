rd /S /Q config
md config
rd /S /Q workspace
md workspace
call ring edt workspace export --project ../eye-prophet-cf --configuration-files ./config --workspace-location ./workspace
call runner compile -s config -o ./cf/1Cv8.cf
