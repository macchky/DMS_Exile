/*
	DMS_fnc_AddMissionToMonitor
	Created by eraser1

	Parses and adds mission information to "DMS_Mission_Arr" for Mission Monitoring.

	Usage:
	[
		_position,
		[
			[
				_completionType1,
				_completionArgs1
			],
			[
				_completionType2,
				_completionArgs3
			],
			...
			[
				_completionTypeN,
				_completionArgsN
			],
		],
		[
			_timeStarted,
			_timeUntilFail
		],
		[
			_AIUnitOrGroup1,
			_AIUnitOrGroup2,
			...,
			_AIUnitOrGroupN
		],
		[
			[_cleanupObj1,_cleanupObj2,...,_cleanupObjX],
			[_vehicle1,_vehicle2,...,_vehicleX],
			[
				[_crate1,_crate_loot_values1],
				[_crate2,_crate_loot_values2]
			]
		],
		[_msgWIN,_msgLose],
		[_markerDot,_markerCircle],
		_side
	] call DMS_fnc_AddMissionToMonitor;

	Returns whether or not info was added successfully

	 "_completionInfo", "_timeOutInfo", "_inputUnits", "_missionObjs", "_messages", "_markers", "_side", "_timeStarted", "_timeUntilFail"
*/

private ["_added", "_pos", "_OK", "_completionInfo", "_timeOutInfo", "_inputUnits", "_missionObjs", "_messages", "_markers", "_timeStarted", "_timeUntilFail", "_buildings", "_vehs", "_crate_info_array", "_msgWIN", "_msgLose", "_markerDot", "_markerCircle", "_side","_arr"];


_added = false;

_OK = params
[
	["_pos","",[[]],[2,3]],
	["_completionInfo","",[[]]],
	["_timeOutInfo","",[[]],[1,2]],
	["_inputUnits","",[[]]],
	["_missionObjs","",[[]],[3]],
	["_messages","",[[]],[2]],
	["_markers","",[[]],[2]],
	["_side","bandit",[""]]
];

if (!_OK) exitWith
{
	diag_log format ["DMS ERROR :: Calling DMS_fnc_AddMissionToMonitor with invalid parameters: %1",_this];
	false;
};


try
{
	if (_completionInfo isEqualTo []) then
	{
		throw "_completionInfo is empty!";
	};

	_timeOutInfo params
	[
		["_timeStarted",diag_tickTime,[0]],
		["_timeUntilFail",(DMS_MissionTimeOut select 0) + random((DMS_MissionTimeOut select 1) - (DMS_MissionTimeOut select 0)),[0]]
	];

	_units = [];

	{
		if (((typeName _x) == "OBJECT") && {!isNull _x}) then
		{
			_units pushBack _x;
		}
		else
		{
			if (((typeName _x) == "GROUP") && {!isNull _x}) then
			{
				{
					_units pushBack _x;
				} forEach (units _x);
			};
		};
	} forEach _inputUnits;

	_OK = _missionObjs params
	[
		["_buildings","",[[]]],
		["_vehs","",[[]]],
		["_crate_info_array","",[[]]]
	];

	if (!_OK) then
	{
		throw format["_missionObjs |%1|",_missionObjs];
	};

	_OK = _messages params
	[
		["_msgWIN","",[""]],
		["_msgLose","",[""]]
	];

	if (!_OK) then
	{
		throw format["_messages |%1|",_messages];
	};

	_OK = _markers params
	[
		["_markerDot","",[""]],
		["_markerCircle","",[""]]
	];

	if (!_OK) then
	{
		throw format["_markers |%1|",_markers];
	};

	_arr = 
	[
		_pos,
		_completionInfo,
		[
			_timeStarted,
			_timeUntilFail
		],
		_units,
		[
			_buildings,
			_vehs,
			_crate_info_array
		],
		[
			_msgWIN,
			_msgLose
		],
		[
			_markerDot,
			_markerCircle
		],
		_side
	];
	DMS_Mission_Arr pushBack _arr;
	_added = true;

	if (DMS_DEBUG) then
	{
		diag_log format ["DMS_DEBUG AddMissionToMonitor :: Added |%1| to DMS_Mission_Arr!",_arr];
	};
}
catch
{
	diag_log format ["DMS_AddMissionToMonitor ERROR :: Invalid parameter: %1",_exception];
};

_added