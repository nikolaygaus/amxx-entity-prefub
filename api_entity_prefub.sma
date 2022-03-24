
#include <amxmodx>
#include <api_fubentity>

new Trie: g_trDataSave;
new g_fwdSettedData;
new g_fwdChangeData;

public plugin_precache() {

	register_plugin("[API]: Entity Prefub", _sEntityPrefub_Version, "Ragamafona");
	create_cvar("entity_prefub", _sEntityPrefub_Version, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY, "Plugin version");

	ExecuteForward(CreateMultiForward("__fubentity_version_check", ET_IGNORE, FP_STRING, FP_STRING), _, FubEntity_Version_Major, FubEntity_Version_Minor);

	g_trDataSave = TrieCreate();

	g_fwdSettedData = CreateMultiForward("evtfent_setted_data", ET_IGNORE, FP_CELL, FP_STRING, FP_CELL, FP_CELL);
	g_fwdChangeData = CreateMultiForward("evtfent_change_data", ET_IGNORE, FP_CELL, FP_STRING, FP_CELL, FP_CELL);
}

public plugin_natives()	{

	register_native("fubentity_set_data", "@__fubentity_set_data", .style = false);
	register_native("fubentity_get_data", "@__fubentity_get_data", .style = false);
	register_native("fubentity_isset_data", "@__fubentity_isset_data", .style = false);
	register_native("fubentity_unset_data", "@__fubentity_unset_data", .style = false);
	register_native("fubentity_clear_data", "@__fubentity_clear_data", .style = false);
}

bool: @__fubentity_set_data(const iPluginId, const iParamsCount) {

	enum {Arg_Entity = 1, Arg_Key, Arg_Type, Arg_Value, Arg_IgnoreForward};

	new pEntity = get_param(Arg_Entity);
	new szKey[FubEntity_MaxKeyLength];
	new szKeyTrie[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];
	new bool: bIgnoreForward;
	new iTypeData = get_param(Arg_Type);

	if(iParamsCount >= Arg_IgnoreForward)
	{
		bIgnoreForward = bool: get_param(Arg_IgnoreForward);
	}

	get_string(Arg_Key, szKey, FubEntity_MaxKeyLength-1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", pEntity, szKey);

	new bool: bHasData;

	if(bIgnoreForward == false)
	{
		bHasData = TrieKeyExists(g_trDataSave, szKeyTrie);

		if(bHasData)
		{
			ExecuteForward(g_fwdChangeData, _, pEntity, szKey, iTypeData, false);
		}
	}

	switch(iTypeData)
	{
		case eType_Float:
		{
			new Float: flArray[1];

			flArray[0] = get_float_byref(Arg_Value);
			TrieSetArray(g_trDataSave, szKeyTrie, flArray, sizeof(flArray));
		}
		case eType_String:
		{
			new szValueString[FubEntity_MaxStringDataLength];

			get_string(Arg_Value, szValueString, FubEntity_MaxStringDataLength-1);
			TrieSetString(g_trDataSave, szKeyTrie, szValueString);
		}
		default:
		{
			new iValue = get_param_byref(Arg_Value);
			TrieSetCell(g_trDataSave, szKeyTrie, iValue);
		}
	}

	if(bIgnoreForward == false)
	{
		if(bHasData)
		{
			ExecuteForward(g_fwdChangeData, _, pEntity, szKey, iTypeData, true);
		}
		else
		{
			ExecuteForward(g_fwdSettedData, _, pEntity, szKey, iTypeData, eCustomData_Set);
		}
	}

	return true;
}

any: @__fubentity_get_data() {

	enum {Arg_Entity = 1, Arg_Key, Arg_Type, Arg_Value, Arg_ValueSize};

	new pEntity = get_param(Arg_Entity);
	new szKey[FubEntity_MaxKeyLength];
	new szKeyTrie[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];

	get_string(Arg_Key, szKey, FubEntity_MaxKeyLength-1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", pEntity, szKey);

	switch(get_param(Arg_Type))
	{
		case eType_Float:
		{
			new Float: flArray[1];

			TrieGetArray(g_trDataSave, szKeyTrie, flArray, sizeof(flArray));

			return Float: flArray[0];
		}
		case eType_String:
		{
			new szValueString[FubEntity_MaxStringDataLength];

			TrieGetString(g_trDataSave, szKeyTrie, szValueString, FubEntity_MaxStringDataLength-1);
			set_string(Arg_Value, szValueString, get_param(Arg_ValueSize));

			return true;
		}
		default:
		{
			new iReturn;

			TrieGetCell(g_trDataSave, szKeyTrie, iReturn);

			return iReturn;
		}
	}

	return 0;
}

bool: @__fubentity_isset_data() {

	enum {Arg_Entity = 1, Arg_Key};

	new szKey[FubEntity_MaxKeyLength];
	new szKeyTrie[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];

	get_string(Arg_Key, szKey, FubEntity_MaxKeyLength - 1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", get_param(Arg_Entity), szKey);

	return TrieKeyExists(g_trDataSave, szKeyTrie);
}

bool: @__fubentity_unset_data() {

	enum {Arg_Entity = 1, Arg_Key, Arg_UseForward};

	new pEntity = get_param(Arg_Entity);
	new szKey[FubEntity_MaxKeyLength];
	new szKeyTrie[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];

	get_string(Arg_Key, szKey, FubEntity_MaxKeyLength - 1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", pEntity, szKey);

	if(TrieKeyExists(g_trDataSave, szKeyTrie) == false)
	{
		return false;
	}

	if(bool: get_param(Arg_UseForward))
	{
		ExecuteForward(g_fwdSettedData, _, pEntity, szKey, -1, eCustomData_UnSet);
	}

	TrieDeleteKey(g_trDataSave, szKeyTrie);

	return true;
}

@__fubentity_clear_data() {

	enum {Arg_Entity = 1, Arg_UseForward};

	new Snapshot: hListKeys = TrieSnapshotCreate(g_trDataSave);
	new szKey[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];
	new szLeft[FubEntity_MaxIndexLength];
	new szBuffer[FubEntity_MaxKeyLength];
	new pEntity = get_param(Arg_Entity);
	new bool: bUseForward = bool: get_param(Arg_UseForward);
	new iCountKeys;

	for(new iCase; iCase < TrieSnapshotLength(hListKeys); iCase++)
	{
		TrieSnapshotGetKey(hListKeys, iCase, szKey, charsmax(szKey));
		strtok2(szKey, szLeft, charsmax(szLeft), szBuffer, charsmax(szBuffer), ':', true);

		if(str_to_num(szLeft) != pEntity)
		{
			continue;
		}

		if(bUseForward)
		{
			ExecuteForward(g_fwdSettedData, _, pEntity, szBuffer, -1, eCustomData_UnSet);
		}

		TrieDeleteKey(g_trDataSave, szKey);
		iCountKeys++;
	}

	TrieSnapshotDestroy(hListKeys);
	return iCountKeys;
}

#if AMXX_VERSION_NUM < 183
public plugin_end() {

	TrieDestroy(g_trDataSave);
	DestroyForward(g_fwdSettedData);
	DestroyForward(g_fwdChangeData);
}
#endif