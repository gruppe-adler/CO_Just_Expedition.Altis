/*/////////////////////////////////////////////////
Author: Bernhard
			   
File: fn_createLockOnCircle.sqf
Parameters: position on where to create the circle
Return: [_circleObject3D, _circleMarkerName2D] - 3D circle object and 2D map marker

Example:
	[_position] call UTIL_fnc_createLockOnCircle;  // with _position being a waypoint position most of the time

*///////////////////////////////////////////////

params ["_position"];

// 3D circle for curator camera (Zeus)
private _lockOnTriggerCircle = createVehicle ["Sign_Circle_F", _position, [], 0, "CAN_COLLIDE"];
_lockOnTriggerCircle remoteExec ["hideObject", 0];		// hide circle for everyone
["zen_common_execute", [{	// show circle for Zeus
		if (isNull curatorCamera) exitWith {};	// keep hidden if not in Zeus mode
		params ["_lockOnTriggerCircle", "_lockOnRadius"];
		_lockOnTriggerCircle hideObject false;
		_lockOnTriggerCircle setObjectTexture [0,"#(argb,8,8,3)color(0.2,1,0.2,0.1,ca)"];	// make circle green
		_lockOnTriggerCircle setVectorDirAndUp [[0, 0, 1],[0, 1, 0]];	// lay circle flat on ground (again after moving)
		_lockOnTriggerCircle setObjectScale _lockOnRadius/17;			// scale to proper size (circle has a 17m radius by default)				
	}, [_lockOnTriggerCircle, _lockOnRadius]]] call CBA_fnc_globalEvent;
// 2D circle on map
_lockOnTriggerCircleMarker = createMarkerLocal [ format ["lockOnTriggerCircleMarker_%1", diag_tickTime], _position];
_lockOnTriggerCircleMarker setMarkerShapeLocal "ELLIPSE";
_lockOnTriggerCircleMarker setMarkerSizeLocal [_lockOnRadius, _lockOnRadius];
_lockOnTriggerCircleMarker setMarkerAlphaLocal 0.3;
_lockOnTriggerCircleMarker setMarkerColorLocal "ColorGreen";
_lockOnTriggerCircleMarker setMarkerBrushLocal "SolidBorder";

[_lockOnTriggerCircle, _lockOnTriggerCircleMarker];
