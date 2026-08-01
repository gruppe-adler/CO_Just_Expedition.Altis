// attach vehicle ammo container to Stomper if nearby
["ReammoBox_F", "init",{
    params ["_container"];
    _container call UTIL_fnc_attachAmmoBoxToStomper;
}, true, [], true] call CBA_fnc_addClassEventHandler;
