/*/////////////////////////////////////////////////
Author: Bernhard
			   
File: fn_makeSuicideWaypoint.sqf
Parameters: waypoint to be changed into the suicide attack target
Return: none

Example:
	_waypoint call UTIL_fnc_makeSuicideWaypoint;

*///////////////////////////////////////////////

params ["_waypointGroup","_waypointIndex"];
private _waypoint = _this;

// plausibility check
private _vics = assignedVehicles _waypointGroup;
if !(_vics#0 isKindOf "UAV_01_base_F") exitWith {
	diag_log format ["fn_makeSuicideWaypoint.sqf: Type %1 does not support suicide waypoint", typeOf (_vics#0)];
};

_waypoint setWaypointScript "A3\functions_f\Waypoints\fn_wpLand.sqf []";
_waypoint setWaypointType "SCRIPTED";
