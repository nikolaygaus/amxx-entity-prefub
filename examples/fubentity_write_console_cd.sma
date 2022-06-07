
#include <amxmodx>
#include <api_fubentity>

public plugin_init() {

	register_plugin("[FubEntity]: Write Custom Data In Console", _sEntityPrefub_Version, "Ragamafona");

	// @note: cd_input <key> <i/r/s> <value> <index>
	// 			cd_input "testkey" "r" "23.45" "5"
	register_concmd("cd_input", "@ServerCommand_CdInput", ADMIN_RCON);
}

@ServerCommand_CdInput(const pPlayer, const iLevel) {

	// cmd_access
	if(pPlayer != (is_dedicated_server() ? 0 : 1))
	{
		if(iLevel > 0 && ~get_user_flags(pPlayer) & iLevel)
		{
			return PLUGIN_HANDLED;
		}
	}

	new iArgsNum = read_argc();

	if(iArgsNum < 2)
	{
		console_print(pPlayer, "Not enough or too many arguments.");
		return PLUGIN_HANDLED;
	}

	enum {Arg_Key = 1, Arg_Type, Arg_Value, Arg_Entity};

	new szKey[MAX_NAME_LENGTH];

	read_argv(Arg_Key, szKey, MAX_NAME_LENGTH - 1);
	remove_quotes(szKey);
	trim(szKey);

	if(iArgsNum == 2)
	{
		console_print(pPlayer, "Key ^"%s^" - has been removed.", szKey);
		return PLUGIN_HANDLED;
	}

	new iEntityData = read_argv_int(Arg_Entity);
	new szConsoleMessage[256];
	new szType[2];

	formatex(szConsoleMessage, charsmax(szConsoleMessage), "Id: %i, Key: ^"%s^" - setted ", iEntityData, szKey);
	read_argv(Arg_Type, szType, charsmax(szType));
	
	switch(szType[0])
	{
		case 'i':
		{
			new iValue = read_argv_int(Arg_Value);

			fubentity_set_data(iEntityData, szKey, eType_Integer, iValue, true);

			strcat(szConsoleMessage, fmt("integer: ^"%i^"", iValue), charsmax(szConsoleMessage));
		}
		case 'r', 'f':
		{
			new Float: flValue = read_argv_float(Arg_Value);

			fubentity_set_data(iEntityData, szKey, eType_Float, flValue, true);

			strcat(szConsoleMessage, fmt("real: ^"%f^"", flValue), charsmax(szConsoleMessage));
		}
		case 's':
		{
			new szBuffer[128]; // 128 is magic, yeap ;)

			read_argv(Arg_Value, szBuffer, charsmax(szBuffer));
			remove_quotes(szBuffer);
			trim(szBuffer);

			fubentity_set_data(iEntityData, szKey, eType_String, szBuffer, true);

			strcat(szConsoleMessage, fmt("string: ^"%s^"", szBuffer), charsmax(szConsoleMessage));
		}
		default:
		{
			console_print(pPlayer, "No argument type specified!");
			return PLUGIN_HANDLED;
		}
	}

	console_print(pPlayer, szConsoleMessage);

	return PLUGIN_HANDLED;
}