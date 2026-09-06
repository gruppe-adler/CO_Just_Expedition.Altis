params ["_player", "_didJIP"];
enableSaving [false, false];

enableSentences false;  // disable radio transmissions to be heard and seen on screen 


// allow U menu for easier team management
["InitializePlayer", [player, true]] call BIS_fnc_dynamicGroups;


// draw red line between suicide drone and its target
["zen_curatorDisplayLoaded", {	// wait for player to open Zeus for the 1st time as we need to check if zeus, and we cannot do that at mission time 0 due to race-condition
	
	// draw in 3D space
	addMissionEventHandler ["Draw3D", {
		if (isNull curatorCamera) exitWith {};	// only draw when in Zeus mode
		{
			_x params ["_drone", "_target"];
			drawLine3D [ASLToAGL getPosASL _drone, ASLToAGL getPosASL _target, [1,0,0,1], 20];
		} forEach SuicideDrones;
	}];


	// draw on map (2D space)
	[{!isNull (findDisplay 312 displayCtrl 50)}, {
		private _map = findDisplay 312 displayCtrl 50;
		_map ctrlAddEventHandler ["Draw", toString {
			private _map = (_this#0);
			// (_this#0) drawLine [getPos zeus1, getPos drone1, [1,0,0,1]];
			{
				_x params ["_drone", "_target"];
				_map drawLine [getPos _drone, getPos _target, [1,0,0,1], 8];
			} forEach SuicideDrones;
		}];	
	}, nil, 
	// timeout time and code
	5, 
	{ diag_log "initPlayerLocal.sqf: Couldn't register draw handler for suicide drone targets on Zeus map" }
	] call CBA_fnc_waitUntilAndExecute;


	// move green circles when suicide waypoints move
	(getAssignedCuratorLogic player) addEventHandler ["CuratorWaypointEdited", {
		params ["_curator", "_group", "_waypointID"];

		private _waypoint = [_group,_waypointID];
		private _didDelete = [_waypoint] call UTIL_fnc_deleteLockOnCircle;	// delete old circles
		if (_didDelete) then {
			// create new circles (on new position)
			private _circles = [getWPPos _waypoint] call UTIL_fnc_createLockOnCircle;
			_circles params ["_lockOnTriggerCircle", "_lockOnTriggerCircleMarker"];
			_waypoint setWaypointDescription format ["LockOnCircles,%1,%2", netId _lockOnTriggerCircle, _lockOnTriggerCircleMarker];
		};
	}];

    [_thisType, _thisId] call CBA_fnc_removeEventHandler;	// remove event immediately
}] call CBA_fnc_addEventHandlerArgs;


// ACE menu with Zeus utilities
private _prepareDemolitionDroneAction = ["prepareDemolitinDrone","Prepare Demolition Drone","\A3\Drones_F\Air_F_Gamma\UAV_01\Data\UI\Map_UAV_01_CA.paa",{ { _x call UTIL_fnc_prepareDemolitionDrone; } forEach curatorSelected#0; },{"UAV_01_base_F" call UTIL_fnc_curatorSelectedIsKindOf;}] call ace_interact_menu_fnc_createAction;
[["ACE_ZeusActions"], _prepareDemolitionDroneAction] call ace_interact_menu_fnc_addActionToZeus;

private _prepareSniperDroneAction = ["prepareSniperDrone","Prepare Sniper Drone","\lxWS\air_f_lxWS\Data\UI\UAV_02_CA.paa",{ { _x call UTIL_fnc_prepareSniperDrone; } forEach curatorSelected#0; },{"UAV_02_Base_lxWS" call UTIL_fnc_curatorSelectedIsKindOf;}] call ace_interact_menu_fnc_createAction;
[["ACE_ZeusActions"], _prepareSniperDroneAction] call ace_interact_menu_fnc_addActionToZeus;

private _makeSuicideWaypointAction = ["makeSuicideWaypoint","Make Suicide Waypoint","\A3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa",{ { _x call UTIL_fnc_makeSuicideWaypoint; } forEach curatorSelected#2; },{ true /* define condition */}] call ace_interact_menu_fnc_createAction;
[["ACE_ZeusActions", "ZeusWaypoints"], _makeSuicideWaypointAction] call ace_interact_menu_fnc_addActionToZeus;
