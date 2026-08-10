// list of suicide drones and their targets
// format: [[_drone, _target]];
SuicideDrones = [];
publicVariable "SuicideDrones";


// allow U menu for easier team management
["Initialize", [true]] call BIS_fnc_dynamicGroups;


// set date and time
[[2029,10,24,5,40]] remoteExec ["setDate"];
