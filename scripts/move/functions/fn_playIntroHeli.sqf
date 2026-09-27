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

private _spawnedScriptHandle = [intro_heli, _unitCaptureData] spawn BIS_fnc_unitPlay;
waitUntil {scriptDone _spawnedScriptHandle};
intro_heli engineOn false;
