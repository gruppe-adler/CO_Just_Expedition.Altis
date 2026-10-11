/*/////////////////////////////////////////////////
Author: Bernhard
			   
File: fn_playIntro.sqf
Parameters: none
Return: none

Example:
	spawn MOVE_fnc_playIntro;

*///////////////////////////////////////////////

// if (isServer) then {
// 	[getPos target_pier vectorAdd [0, 0, 150], 0] call UTIL_fnc_spawnFlare;
// 	[getPos target_bunker_E vectorAdd [0, 0, 150], 0] call UTIL_fnc_spawnFlare;
// 	[getPos target_bunker_C_E vectorAdd [0, 0, 150], 0] call UTIL_fnc_spawnFlare;
// 	[getPos target_bunker_W vectorAdd [0, 0, 150], 0] call UTIL_fnc_spawnFlare;
// };

if (!hasInterface) exitWith {};

setViewDistance (2000 max viewDistance);

BIS_fnc_establishingShot_fakeUAV = nil;		// workaround for BI bug
[
	aircraft_carrier,  // cam target and rotational center
	"""USS Freedom"" nord-östlich von Altis", // intro text
	65,     // altitude of cam
	140,    // radius of cam rotation
	135,    // 180 means looking from South to North
	0,      // 0 counter clockwise rotation, 1 clockwise rotation
	[
		// ["\A3\ui_f\data\Map\Markers\Military\marker_CA.paa", [0, 1, 0, 1], target_pier, 1, 1, 0, "Pier", 0],
		// ["\A3\ui_f\data\Map\Markers\Military\marker_CA.paa", [0, 1, 0, 1], target_bunker_E, 1, 1, 0, "Bunker East", 0],
		// ["\A3\ui_f\data\Map\Markers\Military\marker_CA.paa", [0, 1, 0, 1], target_bunker_C_E, 1, 1, 0, "Bunker Center", 0],
		// ["\A3\ui_f\data\Map\Markers\Military\marker_CA.paa", [0, 1, 0, 1], target_bunker_W, 1, 1, 0, "Bunker West", 0] 
	],
	0, 
	true, 
	13		// duration of shot
] spawn BIS_fnc_establishingShot;
camUseNVG true;

// get objects to animate
private _carrierParts = aircraft_carrier getVariable ["bis_carrierParts", []];
private _hull4_2 = (_carrierParts select { (_x#0) isKindOf "Land_Carrier_01_hull_04_2_F"})#0#0;
private _hull4_1 = (_carrierParts select { (_x#0) isKindOf "Land_Carrier_01_hull_04_1_F"})#0#0;
private _hull7 = (_carrierParts select { (_x#0) isKindOf "Land_Carrier_01_hull_07_1_F"})#0#0;
private _launchInfos = [
	[_hull4_2, "Deflector_1", intro_sentinel1, "Vanguard-1"],
	[_hull4_1, "Deflector_2", intro_sentinel2, "Vanguard-2"],
	[_hull7, "Deflector_4", intro_sentinel4, "Vanguard-3"]
];

// helper funtion to launch drone
private _fnc_launchDrone = {
	params ["_part", "_animation", "_drone", "_callsign"];

	// turn deflectors up
	[_part, [_animation, _animation+"_hydraulic_1", _animation+"_hydraulic_2", _animation+"_hydraulic_3"], 10] spawn BIS_fnc_carrier01AnimateDeflectors;

	// wait until deflector is up, then launch drone
	waitUntil { (_part animationPhase _animation) >= 9.9 };	
	[_drone] call BIS_fnc_aircraftCatapultLaunch;
	waitUntil { speed _drone > 200 };
	west createVehicleCrew _drone;
	(group _drone) setGroupIdGlobal [_callsign];
	sleep 2;
	
	// turn deflectors down
	[_part, [_animation, _animation+"_hydraulic_1", _animation+"_hydraulic_2", _animation+"_hydraulic_3"], 0] spawn BIS_fnc_carrier01AnimateDeflectors;

	// set loiter waypoint after launch
	private _altitude = 1500;
	switch (_drone) do
	{
		case intro_sentinel1: { _altitude = 2000; };
		case intro_sentinel2: { _altitude = 2250; };
		case intro_sentinel4: { _altitude = 2500; };
	};
	_drone flyInHeightASL [_altitude, _altitude, _altitude]; 
	private _radius = _altitude;
	private _waypoint = (group _drone) addWaypoint [getMarkerPos "sentinel_loiter_center", -1];
	_waypoint setWaypointType "LOITER";
	_waypoint setWaypointLoiterType "CIRCLE";
	_waypoint setWaypointLoiterRadius _radius;
	_waypoint setWaypointLoiterAltitude _altitude;
};

// helper funtion to play ambient radio sound
private _fnc_playAmbientRadioSound = {
	waitUntil { (_this animationPhase "Deflector_1") >= 1.0 };
	private _in = playSoundUI ["\A3\Dubbing_Radio_F\Sfx\in2c.ogg"];
	waitUntil { soundParams _in isEqualTo [] };
	private _ambient = playSoundUI ["A3\Sounds_F\sfx\radio\ambient_radio14.wss"];
	waitUntil { soundParams _ambient isEqualTo [] };
	private _out = playSoundUI ["\A3\Dubbing_Radio_F\Sfx\out2c.ogg"];
};

// animate backblast deflectors and launch drones
{ 
	if (_forEachIndex == 0) then { _hull4_2 spawn _fnc_playAmbientRadioSound; };	// play ambient radio sound
	sleep 2; 
	_x spawn _fnc_launchDrone; 
} forEach _launchInfos;
