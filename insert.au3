#include <array.au3>
;#include <dataset.au3>
#INCLUDE <FILE.AU3>
_dataset_matchList(@ScriptDir &"\metadata.txt")
if @error then
msgbox(16, "Ha ocurrido un error", "Código: " &@error)
Else
MsgBox(0, "éxito", "La lista ha sido arreglada satisfactoriamente.")
EndIf
func _dataset_matchList($sListPath = @ScriptDir &"\list.txt")
;declarar:
local $aList, $aSplit, $hFile
if not FileExists($sListPath) then Return SetError(1, 0, "")
;abrir list:
$aList = FileReadToArray($sListPath)
if @error then return SetError(2, 0, "")
;obteniendo número de líneas, aunque también se puede hacer con uBound.
$iLines = @extended
$hFile = FileOpen(StringTrimRight($sListPath, 4) &"_converted.txt", $FO_APPEND)
If $hFile = -1 Then return SetError(3, 0, "")
for $I = 0 to $iLines -1
FileWriteLine($hFile, "wavs/" & $aList[$I])
Next
FileClose($hFile)
return 1
EndFunc