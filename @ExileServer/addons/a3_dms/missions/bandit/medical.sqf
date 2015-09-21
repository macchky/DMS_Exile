/*
	Sample mission (duplicate for testing purposes)
*/

private ["_num", "_side", "_pos", "_difficulty", "_AICount", "_group", "_crate", "_crate_loot_values", "_msgStart", "_msgWIN", "_msgLOSE", "_missionName", "_missionAIUnits", "_missionObjs", "_markers", "_time", "_added","_building","_vehicle"];

// For logging purposes
_num = DMS_MissionCount;


// Set mission side (only "bandit" is supported for now)
_side = "bandit";


// find position
_pos = call DMS_fnc_findSafePos;


// Set general mission difficulty
_difficulty = "easy";


// Create AI
// TODO: Spawn AI only when players are nearby
_AICount = 4 + (round (random 2));

_group =
[
	_pos,					// Position of AI
	_AICount,				// Number of AI
	"easy",			// "random","hardcore","difficult","moderate", or "easy"
	"random", 				// "random","assault","MG","sniper" or "unarmed" OR [_type,_launcher]
	_side 					// "bandit","hero", etc.
] call DMS_fnc_SpawnAIGroup;


// Create Crate
_crate = ["Box_NATO_Wps_F",_pos] call DMS_fnc_SpawnCrate;

_building = createVehicle ["Land_Medevac_HQ_V1_F",[(_pos select 0) - 10, (_pos select 1),-0.1],[], 0, "CAN_COLLIDE"];

_vehicle = ["I_Truck_02_medical_F",_pos] call DMS_fnc_SpawnNonPersistentVehicle;


// Set crate loot values
_crate_loot_values =
[
	5,		// Weapons
	[9,["Exile_Item_InstaDoc","Exile_Item_PlasticBottleFreshWater"]],		// Items
	3 		// Backpacks
];


// Define mission-spawned AI Units
_missionAIUnits =
[
	_group 		// We only spawned the single group for this mission
];

// Define mission-spawned objects and loot values
_missionObjs =
[
	[_building],			// No spawned buildings
	[_vehicle],
	[[_crate,_crate_loot_values]]
];

// Define Mission Start message
_msgStart = format["<t color='#FFFF00' size='1.25'>Deranged Doctors! </t><br/> A group of deranged doctors have set up a field hospital, sieze it for your own!"];

// Define Mission Win message
_msgWIN = format["<t color='#0080ff' size='1.25'>Deranged Doctors! </t><br/> Convicts have claimed the medical supplies for their own!"];

// Define Mission Lose message
_msgLOSE = format["<t color='#FF0000' size='1.25'>Deranged Doctors! </t><br/> Hawkeye has ran off with the medical supplies, everything is gone!"];

// Define mission name (for map marker and logging)
_missionName = "Deranged Doctors";

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