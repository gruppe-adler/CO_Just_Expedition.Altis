/*/////////////////////////////////////////////////
Author: Bernhard
			   
File: fn_makeSuicideWaypoint.sqf
Parameters: waypoint to be changed into the suicide attack target
Return: none

Example:
	_waypoint call UTIL_fnc_makeSuicideWaypoint;

*///////////////////////////////////////////////

params ["_waypointGroup","_waypointIndex"];

// plausibility check
private _vics = assignedVehicles _waypointGroup;
if !(_vics#0 isKindOf "UAV_01_base_F") exitWith {
	diag_log format ["fn_makeSuicideWaypoint.sqf: Type %1 does not support suicide waypoint", typeOf (_vics#0)];
};

private _waypoint = _this;
private _lockOnRadius = 50;


// visualize circle for Zeus at which target lock-on will be attempted
private _circles = [getWPPos _waypoint] call UTIL_fnc_createLockOnCircle;
_circles params ["_helper", "_lockOnTriggerCircle", "_lockOnTriggerCircleMarker"];
_waypoint setWaypointDescription format ["LockOnCircle,%1,%2,%3", netId _helper, netId _lockOnTriggerCircle, _lockOnTriggerCircleMarker];


// steer drone into target if it is close enough
[{ 	// condition code
	params ["_waypoint", "_lockOnRadius"];
	private _dronePos = getPos leader (_waypoint#0);
	private _distance = ( _dronePos distance2D (getWPPos _waypoint) ); 	// if drone to waypoint distance gets below lock on radius
	// systemChat format ["%1m", floor _distance];
	_distance < _lockOnRadius;	// condition at which the suicide drone will start searching for targets
}, 	
{ 
	params ["_waypoint", "_lockOnRadius"];

	[_waypoint] call UTIL_fnc_deleteLockOnCircle;	// remove green lock-on circles

	private _searchRadius = _lockOnRadius*1.5;

	// visualize search radius for Zeus
	private _search4TargetsCircle = createVehicle ["Sign_Circle_F", getWPPos _waypoint, [], 0, "CAN_COLLIDE"];
	_search4TargetsCircle remoteExec ["hideObject", 0];				// hide circle for everyone
	_search4TargetsCircle setObjectTexture [0,"#(argb,8,8,3)color(1,0,0,0.1,ca)"];	// make circle red
	_search4TargetsCircle setVectorDirAndUp [[0, 0, 1],[0, 1, 0]];	// lay circle flat on ground
	_search4TargetsCircle setObjectScale _searchRadius/17;			// scale to proper size (circle has a 17m radius by default)
	// show circle for Zeus
	["zen_common_execute", [{
			params ["_search4TargetsCircle"];
			private _hide = isNull curatorCamera;	// hide if not in Zeus mode
			_search4TargetsCircle hideObject _hide;
			if (!_hide) then {
				playSound "Beep_Target";	// notification sound					
			};
		}, [_search4TargetsCircle]]] call CBA_fnc_globalEvent;
	// 2D circle on map
	_search4TargetsCircleMarker = createMarkerLocal ["search4TargetsCircleMarker", getWPPos _waypoint];
	_search4TargetsCircleMarker setMarkerShapeLocal "ELLIPSE";
	_search4TargetsCircleMarker setMarkerSizeLocal [_searchRadius, _searchRadius];
	_search4TargetsCircleMarker setMarkerAlphaLocal 0.3;
	_search4TargetsCircleMarker setMarkerColorLocal "ColorRed";
	_search4TargetsCircleMarker setMarkerBrushLocal "SolidBorder";
	// delete circles after 4s
	[{ 
		params ["_search4TargetsCircle", "_search4TargetsCircleMarker"];
		deleteVehicle _search4TargetsCircle; 
		deleteMarker _search4TargetsCircleMarker;
	}, [_search4TargetsCircle, _search4TargetsCircleMarker], 4] call CBA_fnc_waitAndExecute;


	// prepare target list
	private _potentialTargets = nearestObjects [getWPPos _waypoint, ["CAManBase", "Car", "Tank"], _searchRadius, true];   // nearby people or vics are prio #2
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
			_pullForce = _forwardVector vectorMultiply 50;
			_drone addForce [_pullForce, [0,0,0]];

		}, 0, [_drone, _target]] call CBA_fnc_addPerFrameHandler;
	} forEach (assignedVehicles (_waypoint#0));
}, [_waypoint, _lockOnRadius], 

// timeout time and code
60, 
{
	params ["_waypoint", "_lockOnRadius"];
	diag_log format ["fn_makeSuicideWaypoint.sqf: Waypoint %1 not reached before timeout.", _waypoint];
	[_waypoint] call UTIL_fnc_deleteLockOnCircle;	// remove green lock-on circles
}
] call CBA_fnc_waitUntilAndExecute;
