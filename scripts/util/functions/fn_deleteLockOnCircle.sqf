/*/////////////////////////////////////////////////
Author: Bernhard
			   
File: fn_deleteLockOnCircle.sqf
Parameters: waypoint to which the circle belongs
Return: true  - if there was a circle to delete 
		false - if there was no circle to delete

Example:
	[_waypoint] call UTIL_fnc_deleteLockOnCircle;  // with _position being a waypoint position most of the time

*///////////////////////////////////////////////

params ["_waypoint"];

private _return = false;

private _description = waypointDescription _waypoint;
if (_description != "") then {
	private _waypointDescriptionTokens = _description splitString ",";
	if (_waypointDescriptionTokens#0 != "LockOnCircle") exitWith  {
		diag_log format ["fn_deleteLockOnCircle.sqf: Unknown waypoint description read: %1", _description];
	};
	private _helper = objectFromNetId (_waypointDescriptionTokens#1);
	private _lockOnTriggerCircle = objectFromNetId (_waypointDescriptionTokens#2);
	private _lockOnTriggerCircleMarker = _waypointDescriptionTokens#3;

	// delete old circles
	{ deleteVehicle _x } forEach (attachedObjects _helper);	// this includes _lockOnTriggerCircle
	deleteVehicle _helper;
	// deleteVehicle _lockOnTriggerCircle;
	deleteMarker _lockOnTriggerCircleMarker;
	_return = true;
};

_return;
