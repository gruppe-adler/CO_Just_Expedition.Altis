/*/////////////////////////////////////////////////
Author: Bernhard
			   
File: fn_prepareDemolitionDrone.sqf
Parameters: drone to prepare for demolition
Return: none

Example:
	_this call UTIL_fnc_prepareDemolitionDrone;  // in drone's Execute field

*///////////////////////////////////////////////

params ["_drone"];

private _demoBlock = "ModuleExplosive_DemoCharge_F" createVehicle position _drone;	// spawn demolition block
_demoBlock attachTo [_drone, [0, 0, 0.15]];		// attach to drone
[_demoBlock, { { _x addCuratorEditableObjects [[_this], false] } forEach allCurators; }] remoteExec ["call", 2];  // make object visible to Zeus

_drone addMPEventHandler ["MPKilled", {		// when drone dies...
	params ["_drone", "_killer", "_instigator", "_useEffects"];
	{ _x setDamage 1; } forEach (attachedObjects _drone);	// ...trigger explosive charge
}];
