/*/////////////////////////////////////////////////
Author: Bernhard
			   
File: fn_attachAmmoBoxToStomper.sqf
Parameters: drone to prepare for demolition
Return: none

Example:
	_this call UTIL_fnc_attachAmmoBoxToStomper;  // in container's Execute field

*///////////////////////////////////////////////

params ["_container"];

if !(_container isKindOf "ReammoBox_F") exitWith {}; 

private _stompers = (nearestObjects [_container, ["UGV_01_base_F"], 5]);   // find nearby Stompers
// systemChat format ["Stompers nearby the container: %1", _stompers];
if (_stompers isNotEqualTo []) then {
	private _stomper = _stompers#0;
	diag_log format ["Attaching ammo container %1 to Stomper %2", _container, _stomper];
	_container attachTo [_stomper, [0.41, -0.05, 0.1]];
	_container setDir -90;
};
