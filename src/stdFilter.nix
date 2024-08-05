k: v:
if
  builtins.match "^import|^scopedImport|^builtins|^fetch.*|^current.*|^nixPath|^storePath|^getEnv" k
  != null
then
  null
else
  { ${k} = v; }
