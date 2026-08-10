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

// steer drone into target if it is close enough
private _lockOnRadius = 50;
[{ 	params ["_waypoint", "_lockOnRadius"];
	private _dronePos = getPos leader (_waypoint#0);
	private _distance = ( _dronePos distance2D (getWPPos _waypoint) ); 	// if drone to waypoint distance gets below lock on radius
	// systemChat format ["%1m", floor _distance];
	_distance < _lockOnRadius;
}, 	
{ 
	params ["_waypoint", "_lockOnRadius"];

	// prepare target list
	private _potentialTargets = nearestObjects [getWPPos _waypoint, ["CAManBase", "Car", "Tank"], _lockOnRadius*1.5, true];   // nearby people or vics are prio #2
	private _aliveTargets = _potentialTargets select { alive _x };
	{
		private _drone = _x;

		// acquire target
		private _target = waypointAttachedVehicle _waypoint;	// attached vic is prio #1
		if (isNull _target) then {
			_target = selectRandom _aliveTargets;
		};

		if (isNil "_target") exitWith {
			// systemChat "No target for suicide drone found";
		};
		
		_drone setVariable ["suicideTarget", _target, true];

		// maintain list of drones with targets
		SuicideDrones pushBack [_drone, _target];
		publicVariable "SuicideDrones";	
		[{	// garbage collector for dead drones/targets
			private _filterCode = { 
				_x params ["_drone", "_target"]; 
				(!alive _drone) || { !alive _target }; 
			};
			private _elementsWithDeadMembers = SuicideDrones select _filterCode;
			SuicideDrones = SuicideDrones - _elementsWithDeadMembers;
			publicVariable "SuicideDrones";
		}, 5] call CBA_fnc_addPerFrameHandler;

		// kill drone once it collides with the target
		_drone addEventHandler ["EpeContactStart", {
			params ["_drone", "_collisionObject", "_selection1", "_selection2", "_force", "_reactForce", "_worldPos"];
			private _target = _drone getVariable ["suicideTarget", objNull];
			if (_target == _collisionObject) then {
				_drone setDamage 1;
			};		
		}];	

		// add loop to lock on to target (inspired by Drongo's work but heavily modified)
		[{
			params ["_args", "_handle"];
			_args params ["_drone", "_target"];

			if ((!alive _drone) || { !alive _target } ) then {			
				[_handle] call CBA_fnc_removePerFrameHandler;	// exit loop
			};

			private _forwardVector = vectorNormalized ((getPos _target) vectorDiff (getPos _drone));
			_targetVelocity = _forwardVector vectorMultiply 30;
			_drone addForce [_targetVelocity, [0,0,0]];

		}, 0, [_drone, _target]] call CBA_fnc_addPerFrameHandler;
	} forEach (assignedVehicles (_waypoint#0));
}, [_waypoint, _lockOnRadius], 

// timeout time and code
60, 
{
	params ["_waypoint", "_lockOnRadius"];
	diag_log format ["fn_makeSuicideWaypoint.sqf: Waypoint %1 not reached before timeout.", _waypoint];
}
] call CBA_fnc_waitUntilAndExecute;
