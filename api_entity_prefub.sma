
#include <amxmodx>
#include <api_fubentity>

//	#define DEBUG_MODE

new Trie: g_trDataSave = Invalid_Trie;
new g_fwdSettedData;
new g_fwdChangeData;

public plugin_precache() {

	register_plugin("[API]: Entity Prefub", _sEntityPrefub_Version, "Ragamafona");
	create_cvar("entity_prefub", _sEntityPrefub_Version, FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY, "Plugin version");

	ExecuteForward(CreateMultiForward("__fubentity_version_check", ET_IGNORE, FP_STRING, FP_STRING), _, FubEntity_Version_Major, FubEntity_Version_Minor);

	g_trDataSave = TrieCreate();

	g_fwdSettedData = CreateMultiForward("evtfent_setted_data", ET_IGNORE, FP_CELL, FP_STRING, FP_CELL, FP_CELL);
	g_fwdChangeData = CreateMultiForward("evtfent_change_data", ET_IGNORE, FP_CELL, FP_STRING, FP_CELL, FP_CELL);

#if defined DEBUG_MODE
	register_srvcmd("cd_print_keys", "@ServerCommand_PrintKeys");
#endif
}

public plugin_natives()	{

	register_native("fubentity_set_data", "@__fubentity_set_data", .style = false);
	register_native("fubentity_get_data", "@__fubentity_get_data", .style = false);

	register_native("fubentity_isset_data", "@__fubentity_isset_data", .style = false);
	register_native("fubentity_unset_data", "@__fubentity_unset_data", .style = false);
	register_native("fubentity_clear_data", "@__fubentity_clear_data", .style = false);
}

bool: @__fubentity_set_data(const iPluginId, const iParamsCount) {

	enum {Arg_Entity = 1, Arg_Key, Arg_Type, Arg_Value, Arg_UseForward};

	static pEntity;
	static iTypeData;
	static szKey[FubEntity_MaxKeyLength];
	static szKeyTrie[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];
	static bool: bUseForward;
	static bool: bHasData;

	pEntity = get_param(Arg_Entity);
	iTypeData = get_param(Arg_Type);
	bUseForward = false;

	if(iParamsCount == Arg_UseForward)
	{
		bUseForward = bool: get_param_byref(Arg_UseForward);
	}

	get_string(Arg_Key, szKey, FubEntity_MaxKeyLength - 1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", pEntity, szKey);

	if(bUseForward == true)
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
			static Float: flArray[1];

			flArray[0] = get_float_byref(Arg_Value);
			TrieSetArray(g_trDataSave, szKeyTrie, flArray, sizeof(flArray));
		}
		case eType_String:
		{
			static szValueString[FubEntity_MaxStringDataLength];

			get_string(Arg_Value, szValueString, FubEntity_MaxStringDataLength-1);
			TrieSetString(g_trDataSave, szKeyTrie, szValueString);
		}
		default:
		{
			static iValue;

			iValue = get_param_byref(Arg_Value);
			TrieSetCell(g_trDataSave, szKeyTrie, iValue);
		}
	}

	if(bUseForward == true)
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

	static pEntity;
	static szKey[FubEntity_MaxKeyLength];
	static szKeyTrie[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];

	pEntity = get_param(Arg_Entity);

	get_string(Arg_Key, szKey, FubEntity_MaxKeyLength-1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", pEntity, szKey);

	switch(get_param(Arg_Type))
	{
		case eType_Float:
		{
			static Float: flArray[1];

			flArray[0] = 0.0; // For those who receive data without cd_isset
			TrieGetArray(g_trDataSave, szKeyTrie, flArray, sizeof(flArray));

			return Float: flArray[0];
		}
		case eType_String:
		{
			static szValueString[FubEntity_MaxStringDataLength];

			szValueString[0] = 0; // For those who receive data without cd_isset
			TrieGetString(g_trDataSave, szKeyTrie, szValueString, FubEntity_MaxStringDataLength-1);
			set_string(Arg_Value, szValueString, get_param(Arg_ValueSize));

			return true;
		}
		default:
		{
			static iReturn;

			iReturn = 0; // For those who receive data without cd_isset
			TrieGetCell(g_trDataSave, szKeyTrie, iReturn);

			return iReturn;
		}
	}

	return 0;
}

bool: @__fubentity_isset_data() {

	enum {Arg_Entity = 1, Arg_Key};

	static szKey[FubEntity_MaxKeyLength];
	static szKeyTrie[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];

	get_string(Arg_Key, szKey, FubEntity_MaxKeyLength - 1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", get_param(Arg_Entity), szKey);

	return TrieKeyExists(g_trDataSave, szKeyTrie);
}

bool: @__fubentity_unset_data() {

	enum {Arg_Entity = 1, Arg_Key, Arg_UseForward};

	static pEntity;
	static szKey[FubEntity_MaxKeyLength];
	static szKeyTrie[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];

	pEntity = get_param(Arg_Entity);

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

	static Snapshot: hListKeys = Invalid_Snapshot;
	static szKey[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];
	static szLeft[FubEntity_MaxIndexLength];
	static szBuffer[FubEntity_MaxKeyLength];
	static pEntity;
	static bool: bUseForward;
	static iCountKeys;
	static i;
	static iSize;

	hListKeys = TrieSnapshotCreate(g_trDataSave);
	pEntity = get_param(Arg_Entity);
	bUseForward = bool: get_param(Arg_UseForward);
	iCountKeys = 0;

	for(i = 0, iSize = TrieSnapshotLength(hListKeys); i < iSize; i++)
	{
		TrieSnapshotGetKey(hListKeys, i, szKey, charsmax(szKey));
		strtok2(szKey, szLeft, charsmax(szLeft), szBuffer, charsmax(szBuffer), ':');

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

#if defined DEBUG_MODE
@ServerCommand_PrintKeys() {

	static Snapshot: hListKeys = Invalid_Snapshot;
	static szKey[FubEntity_MaxKeyLength + FubEntity_MaxIndexLength];
	static szLeft[FubEntity_MaxIndexLength];
	static szBuffer[FubEntity_MaxKeyLength];
	static i;
	static iSize;

	hListKeys = TrieSnapshotCreate(g_trDataSave);

	for(i = 0, iSize = TrieSnapshotLength(hListKeys); i < iSize; i++)
	{
		TrieSnapshotGetKey(hListKeys, i, szKey, charsmax(szKey));
		strtok2(szKey, szLeft, charsmax(szLeft), szBuffer, charsmax(szBuffer), ':');

		server_print("%i. id: [%s] | key: [%s]", i + 1, szLeft, szBuffer);
	}

	server_print("[#] Print keys count: %i", iSize);

	TrieSnapshotDestroy(hListKeys);
	return iSize;
}
#endif

#if AMXX_VERSION_NUM < 183
public plugin_end() {

	TrieDestroy(g_trDataSave);
	DestroyForward(g_fwdSettedData);
	DestroyForward(g_fwdChangeData);
}
#endif