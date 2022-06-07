
#include <amxmodx>
#include <api_fubentity>

enum _: eData_Keys {

	eKeys_pId,
	eKeys_szKey[FubEntity_MaxKeyLength],
	eKeys_szValue[FubEntity_MaxStringDataLength],
	eKeys_iType
};

new Array: g_arKeys = Invalid_Array;

public plugin_init() {

	register_plugin("[FubEntity]: Show keys for debug", _sEntityPrefub_Version, "Ragamafona");

	// @note: cd_keys <i/k/t/v> <cut index>
	// 			cd_keys
	// 			cd_keys k "testkey"
	register_concmd("cd_keys", "@ClientCommand_ShowKeys", ADMIN_RCON);
}

@ClientCommand_ShowKeys(const pPlayer, const iLevel) {

	// cmd_access
	if(pPlayer != (is_dedicated_server() ? 0 : 1))
	{
		if(iLevel > 0 && ~get_user_flags(pPlayer) & iLevel)
		{
			return PLUGIN_HANDLED;
		}
	}
		
	if(g_arKeys == Invalid_Array)
	{
		console_print(pPlayer, "g_arKeys is invalid array.");
		return PLUGIN_HANDLED;
	}

	enum {Cut_Id = 0, Cut_Key, Cut_Type, Cut_Value};

	new iCut = -1;
	new iArraySize = ArraySize(g_arKeys);
	new aTempDataCut[eData_Keys];

	if(read_argc() == 3)
	{
		enum {Arg_Type = 1, Arg_Value};

		new szType[2];

		read_argv(Arg_Type, szType, 1);

		switch(szType[0])
		{
			case 'i':
			{
				iCut = Cut_Id;
				aTempDataCut[eKeys_pId] = read_argv_int(Arg_Value);
			}
			case 'k':
			{
				iCut = Cut_Key;
				read_argv(Arg_Value, aTempDataCut[eKeys_szKey], FubEntity_MaxKeyLength - 1);
			}
			case 't':
			{
				iCut = Cut_Type;
				aTempDataCut[eKeys_iType] = read_argv_int(Arg_Value);
			}
			case 'v':
			{
				iCut = Cut_Value;
				read_argv(Arg_Value, aTempDataCut[eKeys_szValue], FubEntity_MaxStringDataLength - 1);
			}
			default:
			{
				console_print(pPlayer, "Type '%c' is bad. Only 'i/k/t/v'.", szType[0]);
				return PLUGIN_HANDLED;
			}
		}
	}

	new const szTypesData[][] = {"int", "real", "string"};
	new iResultDataCount;

	console_print(pPlayer, "- - - - - - - - - - -");

	for(new a, aTempData[eData_Keys]; a < iArraySize; a++)
	{
		ArrayGetArray(g_arKeys, a, aTempData);

		switch(iCut)
		{
			case Cut_Id:
			{
				if(aTempData[eKeys_pId] != aTempDataCut[eKeys_pId])
				{
					continue;
				}
			}
			case Cut_Key:
			{
				if(strcmp(aTempData[eKeys_szKey], aTempDataCut[eKeys_szKey]))
				{
					continue;
				}
			}
			case Cut_Type:
			{
				if(aTempData[eKeys_iType] != aTempDataCut[eKeys_iType])
				{
					continue;
				}
			}
			case Cut_Value:
			{
				if(strcmp(aTempData[eKeys_szValue], aTempDataCut[eKeys_szValue]))
				{
					continue;
				}
			}
		}

		console_print(pPlayer, "- Id:%i | %s | %s | %s", aTempData[eKeys_pId], aTempData[eKeys_szKey], szTypesData[aTempData[eKeys_iType]], aTempData[eKeys_szValue]);
		iResultDataCount++;
	}

	console_print(pPlayer, "- - - - - - - - - - -");
	console_print(pPlayer, "- Keys count: %i", iResultDataCount);
	console_print(pPlayer, "- - - - - - - - - - -");

	return PLUGIN_HANDLED;
}

public evtfent_setted_data(const pEntity, const szKey[], const iTypeData, const iTypeForward) {

	if(g_arKeys == Invalid_Array)
	{
		g_arKeys = ArrayCreate(eData_Keys, 0);
	}

	new iArrayPos = -1;
	new iArraySize = ArraySize(g_arKeys);
	new aTempData[eData_Keys];

	for(new a; a < iArraySize; a++)
	{
		ArrayGetArray(g_arKeys, a, aTempData);

		if(aTempData[eKeys_pId] != pEntity)
		{
			continue;
		}

		if(strcmp(aTempData[eKeys_szKey], szKey))
		{
			continue;
		}

		iArrayPos = a;
		break;
	}

	if(iArrayPos == -1)
	{
		if(iTypeForward == eCustomData_UnSet)
		{
			return;
		}

		aTempData[eKeys_pId] = pEntity;
		copy(aTempData[eKeys_szKey], FubEntity_MaxKeyLength - 1, szKey);
	}
	else if(iTypeForward == eCustomData_UnSet)
	{
		ArrayDeleteItem(g_arKeys, iArrayPos);
		return;
	}

	switch(iTypeData)
	{
		case eType_Integer:
		{
			num_to_str(fubentity_get_data(pEntity, szKey, eType_Integer), aTempData[eKeys_szValue], FubEntity_MaxStringDataLength - 1);
		}
		case eType_Float:
		{
			float_to_str(Float: fubentity_get_data(pEntity, szKey, eType_Float), aTempData[eKeys_szValue], FubEntity_MaxStringDataLength - 1);
		}
		case eType_String:
		{
			fubentity_get_data(pEntity, szKey, eType_String, aTempData[eKeys_szValue], FubEntity_MaxStringDataLength - 1);
		}
		default: // maybe ?!#?
		{
			log_amx("Bad data type....");
			return;
		}
	}

	aTempData[eKeys_iType] = iTypeData;

	if(iArrayPos == -1)
	{
		ArrayPushArray(g_arKeys, aTempData);
		return;
	}

	ArraySetArray(g_arKeys, iArrayPos, aTempData);
}

public evtfent_change_data(const pEntity, const szKey[], const iTypeData, const bool: bPost) {

	if(!bPost)
	{
		return;
	}

	// Pseudo recursion, yes ^_^
	evtfent_setted_data(pEntity, szKey, iTypeData, eCustomData_Set);
}