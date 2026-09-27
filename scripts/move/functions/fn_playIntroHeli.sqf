/*/////////////////////////////////////////////////
Author: Bernhard
			   
File: fn_playIntroHeli.sqf
Parameters: none
Return: none

Example:
	call MOVE_fnc_playIntroHeli;

*///////////////////////////////////////////////

private _unitCaptureData = 
    #include "data_heli_landing1.sqf"
;

[intro_heli, _unitCaptureData] spawn BIS_fnc_unitPlay;
