#include <MsgBoxConstants.au3>


;Constants to be set for each patient. Make sure these are right!
$ffx = 15;first fraction
$lfx = 35;last fraction
$ctn = 2;how many images precede the planning CT image
Global $skipfx[4] = [19, 24, 29, 34] ;which fractions to skip, can only skip 4


;****************************************************************
;Main Loop
For $fxn = $ffx To $lfx Step 1
   ;click on image
   MouseClick("left", 879, 176, 2)
   ;wait for image to open
   WaitImgOpen($fxn)

   If $fxn==$skipfx[0] Or $fxn==$skipfx[1] Or $fxn==$skipfx[2] Or $fxn==$skipfx[3] Then
	  ContinueLoop
   EndIf
   RunReg($fxn,$ctn)
   ;click save
   MouseClick("left",34,85)
   Sleep(60000)
Next



;**************************************
;*Functions*
;**************************************
Func WaitImgOpen($fxn)
   ;create window name based on fraction number, this is important that the fx number matches the CBCT Number
   $win_name = StringFormat("Loading slices of image 'CBCT_%d' - \\Remote",$fxn)
   Sleep(1000)
   for $i = 1 to 20 step 1
	  ;if window disappears, then quit waiting
	  if WinExists($win_name)==0 Then
		 ExitLoop
	  EndIf
	  ;wait for 1 second and check again
	  Sleep(1000)
   Next
EndFunc

;************************************
Func RunReg($fxnum,$ctn)

   ;click auto match
   MouseClick("left", 616, 85, 1)
   Sleep(1000)

   ;enter name of registration
   $wndNm = "New Rigid Registration - \\Remote"
   WinActivate($wndNm)
   Send("+{END}")

   ;MouseClick("left", 909, 419, 2)
   $s = StringFormat("CT CBCT FX%d",$fxnum)
   Send($s)
   Sleep(1000)

   ;click on CT
   Send("{TAB}")
   Send("{TAB}")
   for $i = 1 to $ctn step 1
	  Send("{DOWN}")
   next

   ;send the enter key
   Send("{Enter}")
   Sleep(1000)

   if WinExists("Operation Failed - \\Remote") Then
	  MsgBox($MB_SYSTEMMODAL, "", "Error, probably need to activate the course.")
	  Exit
   EndIf


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
	  $stY = 906
	  $step = 1
   EndIf
   If StringCompare("L",$s)==0 Then
	  ;right
	  $stX = 1470
	  $stY = 906
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
			MouseMove(3*$step + $offset + $stX, $stY)
			;MsgBox($MB_SYSTEMMODAL, "", "Color: " & $iColor)
			ExitLoop
		 EndIf
	  EndIf
	  ;MsgBox($MB_SYSTEMMODAL, "", "Color: " & $iColor)
   Next
   Sleep(100)
   MouseDown("left")
   MouseMove($stX, $stY)
   MouseUp("left")
   ;MouseClickDrag("left", 1113, 904, 920, 904)

EndFunc