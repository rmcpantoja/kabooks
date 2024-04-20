; Generate transcription stats:
#include "array.au3"
; #FUNCTION# ====================================================================================================================
; Name ..........: _ArraySortEx
; Description ...:
; Syntax ........: _ArraySortEx(Byref $aArray[, $iDescending = 0[, $iStart = 0[, $iEnd = 0[, $iSubItem = 0[, $iType = 2]]]]])
; Parameters ....: $aArray              - [in/out] an array of unknowns.
;                  $iDescending         - [optional] an integer value. Default is 0.
;                  $iStart              - [optional] an integer value. Default is 0.
;                  $iEnd                - [optional] an integer value. Default is 0.
;                  $iSubItem            - [optional] an integer value. Default is 0.
;                  $iType               - [optional] an integer value. Default is 2.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ArraySortEx(ByRef $aArray, $iDescending = 0, $iStart = 0, $iEnd = 0, $iSubItem = 0, $iType = 2)
	If $iDescending = Default Then $iDescending = 0
	If $iStart = Default Then $iStart = 0
	If $iEnd = Default Then $iEnd = 0
	If $iSubItem = Default Then $iSubItem = 0
	If $iType = Default Then $iType = 2 ; 0 = string sort, 1 = numeric sort, 2 = natural sort

	If Not IsArray($aArray) Then Return SetError(1, 0, 0)

	Local $iDims = UBound($aArray, $UBOUND_DIMENSIONS)
	If $iDims < 1 Or $iDims > 2 Then Return SetError(4, 0, 0)

	Local $iRows = UBound($aArray, $UBOUND_ROWS)
	If $iRows = 0 Then Return SetError(5, 0, 0)

	Local $iCols = UBound($aArray, $UBOUND_COLUMNS) ; always 0 for 1D array
	If $iDims = 2 And $iSubItem > $iCols - 1 Then Return SetError(3, 0, 0)

	If $iType < 0 Or $iType > 2 Then Return SetError(6, 0, 0)

	; Bounds checking
	If $iStart < 0 Then $iStart = 0
	If $iEnd <= 0 Or $iEnd > $iRows - 1 Then $iEnd = $iRows - 1
	If $iStart > $iEnd Then Return SetError(2, 0, 0)

	Local $tIndex = DllStructCreate("uint[" & ($iEnd - $iStart + 1) & "]")
	Local $pIndex = DllStructGetPtr($tIndex)
	Local $hDll = DllOpen("kernel32.dll")
	Local $hDllComp = DllOpen("shlwapi.dll")
	Local $lo, $hi, $mi, $r, $nVal1, $nVal2

	For $i = 1 To $iEnd - $iStart
		$lo = 0
		$hi = $i - 1
		If $iDims = 1 Then ; 1D
			Do
				$mi = Int(($lo + $hi) / 2)
				Switch $iType
					Case 2 ; Natural Sort
						$r = DllCall($hDllComp, 'int', 'StrCmpLogicalW', 'wstr', String($aArray[$i + $iStart]), _
								'wstr', String($aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart]))[0]
					Case 1 ; Numeric Sort
						$nVal1 = Number($aArray[$i + $iStart])
						$nVal2 = Number($aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart])
						$r = $nVal1 < $nVal2 ? -1 : $nVal1 > $nVal2 ? 1 : 0
					Case Else ; 0 = String Sort
						$r = StringCompare($aArray[$i + $iStart], $aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart])
				EndSwitch

				Switch $r
					Case -1
						$hi = $mi - 1
					Case 1
						$lo = $mi + 1
					Case 0
						ExitLoop
				EndSwitch
			Until $lo > $hi
		Else ; 2D
			Do
				$mi = Int(($lo + $hi) / 2)
				Switch $iType
					Case 2 ; Natural Sort
						$r = DllCall($hDllComp, 'int', 'StrCmpLogicalW', 'wstr', String($aArray[$i + $iStart][$iSubItem]), _
								'wstr', String($aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart][$iSubItem]))[0]
					Case 1 ; Numeric Sort
						$nVal1 = Number($aArray[$i + $iStart][$iSubItem])
						$nVal2 = Number($aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart][$iSubItem])
						$r = $nVal1 < $nVal2 ? -1 : $nVal1 > $nVal2 ? 1 : 0
					Case Else ; 0 = String Sort
						$r = StringCompare($aArray[$i + $iStart][$iSubItem], _
								$aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart][$iSubItem])
				EndSwitch

				Switch $r
					Case -1
						$hi = $mi - 1
					Case 1
						$lo = $mi + 1
					Case 0
						ExitLoop
				EndSwitch
			Until $lo > $hi
		EndIf

		DllCall($hDll, "none", "RtlMoveMemory", "struct*", $pIndex + ($mi + 1) * 4, _
				"struct*", $pIndex + $mi * 4, "ulong_ptr", ($i - $mi) * 4)
		DllStructSetData($tIndex, 1, $i, $mi + 1 + ($lo = $mi + 1))
	Next

	Local $aBackup = $aArray

	If $iDims = 1 Then ; 1D
		If Not $iDescending Then
			For $i = 0 To $iEnd - $iStart
				$aArray[$i + $iStart] = $aBackup[DllStructGetData($tIndex, 1, $i + 1) + $iStart]
			Next
		Else ; descending
			For $i = 0 To $iEnd - $iStart
				$aArray[$iEnd - $i] = $aBackup[DllStructGetData($tIndex, 1, $i + 1) + $iStart]
			Next
		EndIf
	Else ; 2D
		Local $iIndex
		If Not $iDescending Then
			For $i = 0 To $iEnd - $iStart
				$iIndex = DllStructGetData($tIndex, 1, $i + 1) + $iStart
				For $j = 0 To $iCols - 1
					$aArray[$i + $iStart][$j] = $aBackup[$iIndex][$j]
				Next
			Next
		Else ; descending
			For $i = 0 To $iEnd - $iStart
				$iIndex = DllStructGetData($tIndex, 1, $i + 1) + $iStart
				For $j = 0 To $iCols - 1
					$aArray[$iEnd - $i][$j] = $aBackup[$iIndex][$j]
				Next
			Next
		EndIf
	EndIf

	$tIndex = 0
	DllClose($hDll)
	DllClose($hDllComp)

	Return 1
EndFunc   ;==>_ArraySortEx

func get_transcripts($aTranscripts)
    local $aSplittedLine, $aTranscripts_dict[]
    local $iSimilarity
    local $sFilename
    for $I = 0 to uBound($aTranscripts) -1
        $aSplittedLine = StringSplit($aTranscripts_text, "|")
        $sFilename = $aSplittedLine[1]
        $iSimilarity = $aSplittedLine[4]
        $aTranscripts_dict[$I][1] = $sFilename
        $aTranscripts_dict[$I][2] = $iSimilarity
    next
    ; Sorting dict by key (filename)
    _ArraySortEx($aTranscripts_dict, Default, 1, Default, Default, 1)
    return $aTranscripts_dict
EndFunc

func generate_stats($sBase_dir, $sResult_file, $sOutput_stats_file, $iMin_similarity = 0.5)
	local $aMetadata, $aTranscripts
	local $sTranscript, $sStats
	if $sBase_dir = "" or $sBase_dir = default then $sBase_dir = @ScriptDir
	$sTranscript = $sBase_dir & "\" & $sResult_file
	$sStats = $sBase_dir & "\" & $sOutput_stats_file
	$aMetadata = FileReadToArray($sTranscript)
	$aTranscripts = get_transcripts($aMetadata)
	_arraydisplay($aTranscripts)
	local $aGood_files, $aBad_files, $aPriority_files
	for $I = 0 to UBound($aTranscripts) -1
		$sFilename = string($aTranscripts[$i][0])
		$iSimilarity = Number($aTranscripts[$i][1])
		switch $iSimilarity
			case 0.0
				$aPriority_files[$I][0] = $sFilename
				$aPriority_files[$I][1] = $iSimilarity
			case $iMin_similarity
				$aGood_files[$I][0] = $sFilename
				$aGood_files[$I][1] = $iSimilarity
			case else
				$aBad_files[$I][0] = $sFilename
				$aBad_files[$I][1] = $iSimilarity
		EndSwitch
	Next
	ConsoleWrite(UBound($aTranscripts) & " total files." &@crlf)
	ConsoleWrite(uBound($aGood_files) & " good files." &@CRLF)
	ConsoleWrite(uBound($aBad_files) & " bad files." &@CRLF)
	ConsoleWrite("and " & UBound($aPriority_files) & "priority files to review." & @CRLF)
	$hStats = FileOpen($sStats, 1)
	FileWrite($hStats, "Good files:" &@CRLF & _ArrayToString($aGood_files) &@CRLF)
	FileWrite($hStats, "Bad files:" &@CRLF & _ArrayToString($aBad_files) &@CRLF)
	FileWrite($hStats, "Files that you need to review:" &@CRLF & _ArrayToString($aPriority_files))
EndFunc

generate_stats(default, "resultado.txt", "stats.txt")