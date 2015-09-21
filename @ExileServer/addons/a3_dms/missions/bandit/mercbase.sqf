/*
	Sample mission (duplicate for testing purposes)
*/

private ["_num", "_side", "_difficulty", "_AICount", "_staticGuns", "_baseObjs", "_crate", "_missionAIUnits", "_missionObjs", "_msgStart", "_msgWIN", "_msgLOSE", "_missionName", "_markers", "_time", "_added", "_cleanup"];

// For logging purposes
_num = DMS_MissionCount;


// Set mission side (only "bandit" is supported for now)
_side = "bandit";


// find position
_pos = call DMS_fnc_findSafePos;


// Set general mission difficulty
_difficulty = "hardcore";


// Create AI
_AICount = 6 + (round (random 2));

_group =
[
	[_pos,[-9.48486,-12.4834,0]] call DMS_fnc_CalcPos,
	_AICount,
	"hardcore",
	"random",
	_side
] call DMS_fnc_SpawnAIGroup;

// Use "base" waypoint instead
while {(count (waypoints _group)) > 0} do
{
	deleteWaypoint ((waypoints _group) select 0);
};

[
	_group,
	[_pos,[-9.48486,-12.4834,0]] call DMS_fnc_CalcPos,
	"base"
] call DMS_fnc_SetGroupBehavior;


_staticGuns =
[
	[
		[_pos,[-6.29138,3.9917,0]] call DMS_fnc_CalcPos
	],
	_group,
	"assault",
	"hardcore",
	"bandit",
	"O_HMG_01_high_F"
] call DMS_fnc_SpawnAIStatic;

(_staticGuns select 0) setDir 15;


_baseObjs =
[
	"base1",
	_pos
] call DMS_fnc_ImportFromM3E;


// Create Crate
_crate = ["Box_NATO_AmmoOrd_F",_pos] call DMS_fnc_SpawnCrate;

// Pink Crate ;)
_crate setObjectTextureGlobal [0,"#(rgb,8,8,3)color(1,0.08,0.57,1)"];
_crate setObjectTextureGlobal [1,"#(rgb,8,8,3)color(1,0.08,0.57,1)"];


// Define mission-spawned AI Units
_missionAIUnits =
[
	_group 		// We only spawned the single group for this mission
];

// Define mission-spawned objects and loot values
_missionObjs =
[
	_staticGuns+_baseObjs,			// base objects and static gun
	[],
	[[_crate,"Sniper"]]
];

// Define Mission Start message
_msgStart = format["<t color='#FFFF00' size='1.25'> Mercenary Base </t><br/> A mercenary base has been located at %1! There's reports of a dandy crate inside of it...",mapGridPosition _pos];

// Define Mission Win message
_msgWIN = format["<t color='#0080ff' size='1.25'> Mercenary Base </t><br/> Convicts have successfully assaulted the Mercenary Base and obtained the dandy crate!"];

// Define Mission Lose message
_msgLOSE = format["<t color='#FF0000' size='1.25'> Mercenary Base </t><br/> Seems like the Mercenaries packed up and drove away..."];

// Define mission name (for map marker and logging)
_missionName = "Mercenary Base";

// Create Markers
_markers =
[
	_pos,
	_missionName,
	_difficulty
] call DMS_fnc_CreateMarker;

// Record time here (for logging purposes, otherwise you could just put "diag_tickTime" into the "DMS_AddMissionToMonitor" parameters directly)
_time = diag_tickTime;

// Parse and add mission info to missions monitor
_added =
[
	_pos,
	[
		[
			"kill",
			_group
		],
		[
			"playerNear",
			[_pos,DMS_playerNearRadius]
		]
	],
	[
		_time,
		(DMS_MissionTimeOut select 0) + random((DMS_MissionTimeOut select 1) - (DMS_MissionTimeOut select 0))
	],
	_missionAIUnits,
	_missionObjs,
	[_msgWIN,_msgLOSE],
	_markers,
	_side
] call DMS_fnc_AddMissionToMonitor;

// Check to see if it was added correctly, otherwise delete the stuff
if !(_added) exitWith
{
	diag_log format ["DMS ERROR :: Attempt to set up mission %1 with invalid parameters for DMS_AddMissionToMonitor! Deleting mission objects and resetting DMS_MissionCount.",_missionName];

	// Delete AI units and the crate. I could do it in one line but I just made a little function that should work for every mission (provided you defined everything correctly)
	_cleanup = [];
	{
		_cleanup pushBack _x;
	} forEach _missionAIUnits;

	_cleanup pushBack ((_missionObjs select 0)+(_missionObjs select 1));
	
	{
		_cleanup pushBack (_x select 0);
	} foreach (_missionObjs select 2);

	_cleanup call DMS_fnc_CleanUp;


	// Delete the markers directly
	{deleteMarker _x;} forEach _markers;


	// Reset the mission count
	DMS_MissionCount = DMS_MissionCount - 1;
};


// Notify players
_msgStart call DMS_fnc_BroadcastMissionStatus;



if (DMS_DEBUG) then
{
	diag_log format ["DMS_DEBUG MISSION: (%1) :: Mission #%2 started at %3 with %4 AI units and %5 difficulty at time %6",_missionName,_num,_pos,_AICount,_difficulty,_time];
};