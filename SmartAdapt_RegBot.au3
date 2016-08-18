
;first fraction Number
$ffxnum = 15

For $fxn = $ffxnum To 35 Step 1
   ;click on image
   MouseClick("left", 879, 176, 2)
   Sleep(8000)
   If $fxn==19 Or $fxn==24 Or $fxn==29 Or $fxn==34 Then
	  ContinueLoop
   EndIf
   RunReg($fxn)
   ;click save
   MouseClick("left",34,85)
   Sleep(60000)
Next



;**************************************
;*Functions*
;**************************************
Func RunReg($fxnum)


   ;click auto match
   MouseClick("left", 616, 85, 1)
   Sleep(1000)

   ;enter name of registration
   MouseClick("left", 909, 419, 2)
   $s = StringFormat("CT CBCT FX%d",$fxnum)
   Send($s)
   Sleep(1000)

   ;click on CT
   MouseClick("left", 705, 489, 1)
   Sleep(1000)

   ;send the enter key
   Send("{Enter}")
   Sleep(8000)

   ;move ROI edges
   MoveRoiEdge("A")
   MoveRoiEdge("P")
   MoveRoiEdge("L")
   MoveRoiEdge("R")

   ;run the rigid registration
   $wndNm = "Auto Matching - \\Remote"
   WinActivate($wndNm)
   Send("{Enter}")
   Sleep(10000)

   ;close the rigid window
   WinActivate($wndNm)
   For $tn = 1 To 11 Step 1
	  Send("{TAB}")
	  Sleep(100)
   Next
   Sleep(1000)
   Send("{Enter}")
   Sleep(2000)

   ;open the deformable window
   MouseClick("left", 685, 85, 1)
   Sleep(2000)

   ;move ROI edges
   MoveRoiEdge("A")
   MoveRoiEdge("P")
   MoveRoiEdge("L")
   MoveRoiEdge("R")

   ;run the rigid registration
   $wndNm = "Deformable Registration - \\Remote"
   WinActivate($wndNm)
   Send("{Enter}")
   Sleep(180000)

EndFunc

;Function to find and move the ROI edge
Func MoveRoiEdge($s)
   If StringCompare("P",$s)==0 Then
	  ;posterior
	  $stX = 900
	  $stY = 374
	  $step = 1
   EndIf

   If StringCompare("A",$s)==0 Then
	  ;anterior
	  $stX = 1470
	  $stY = 374
	  $step = -1
   EndIf
   If StringCompare("R",$s)==0 Then
	  ;left
	  $stX = 900
	  $stY = 908
	  $step = 1
   EndIf
   If StringCompare("L",$s)==0 Then
	  ;right
	  $stX = 1470
	  $stY = 908
	  $step = -1
   EndIf

   ;MsgBox($MB_SYSTEMMODAL, "", "Color: " & $stX)
   ;MouseMove($stX,$stY)

   ;find the red box
   $offset = 0
   For $i = 1 To 500 Step 1
	  $offset = $offset + $step
	  $iColor1 = PixelGetColor($offset + $stX, $stY-1)
	  $iColor2 = PixelGetColor($offset + $stX, $stY)
	  $iColor3 = PixelGetColor($offset + $stX, $stY+1)
	  If $iColor1==16711680 or $iColor2==16711680 Or $iColor3==16711680 Then
		 ;make sure 9 pixels over there's another red pixel
		 $iColor1 = PixelGetColor(9*$step + $offset + $stX, $stY-1)
		 $iColor2 = PixelGetColor(9*$step + $offset + $stX, $stY)
		 $iColor3 = PixelGetColor(9*$step + $offset + $stX, $stY+1)
		 If $iColor1==16711680 Or $iColor2==16711680 Or $iColor3==16711680 Then
			;we found the box!
			MouseMove(4*$step + $offset + $stX, $stY)
			;MsgBox($MB_SYSTEMMODAL, "", "Color: " & $iColor)
			ExitLoop
		 EndIf
	  EndIf
	  ;MsgBox($MB_SYSTEMMODAL, "", "Color: " & $iColor)
   Next

   MouseDown("left")
   MouseMove($stX, $stY)
   MouseUp("left")
   ;MouseClickDrag("left", 1113, 904, 920, 904)

EndFunc