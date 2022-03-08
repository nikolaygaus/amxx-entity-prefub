
#include <amxmodx>
#include <api_fubentity>

const MaxIndexLength = 16;
const MaxKeyLength = 64;
const MaxStringDataLength = 128;

new Trie: g_trDataSave;
new g_fwdSettedData;
new g_fwdChangeData;

public plugin_precache() {

	register_plugin("[API]: Entity Prefub", _sEntityPrefub_Version, "Ragamafona");

	g_trDataSave = TrieCreate();
	g_fwdSettedData = CreateMultiForward("evtfent_setted_data", ET_IGNORE, FP_CELL, FP_STRING, FP_CELL);
	g_fwdChangeData = CreateMultiForward("evtfent_change_data", ET_IGNORE, FP_CELL, FP_STRING, FP_CELL);
}

public plugin_natives()	{

	register_native("fubentity_set_data", "@__fubentity_set_data", .style = false);
	register_native("fubentity_get_data", "@__fubentity_get_data", .style = false);
	register_native("fubentity_isset_data", "@__fubentity_isset_data", .style = false);
	register_native("fubentity_unset_data", "@__fubentity_unset_data", .style = false);
	register_native("fubentity_clear_data", "@__fubentity_clear_data", .style = false);
}

bool: @__fubentity_set_data() {

	enum {Arg_Entity = 1, Arg_Key, Arg_Type, Arg_Value};

	new pEntity = get_param(Arg_Entity);
	new szKey[MaxKeyLength];
	new szKeyTrie[MaxKeyLength + MaxIndexLength];

	get_string(Arg_Key, szKey, MaxKeyLength-1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", pEntity, szKey);

	new bool: bHasData = TrieKeyExists(g_trDataSave, szKeyTrie);

	if(bHasData)
	{
		ExecuteForward(g_fwdChangeData, _, pEntity, szKey, false);
	}
	else
	{
		ExecuteForward(g_fwdSettedData, _, pEntity, szKey, eCustomData_Set);
	}

	switch(get_param(Arg_Type))
	{
		case eType_Float:
		{
			new Float: flArray[1];

			flArray[0] = get_float_byref(Arg_Value);
			TrieSetArray(g_trDataSave, szKeyTrie, flArray, sizeof(flArray));
		}
		case eType_String:
		{
			new szValueString[MaxStringDataLength];

			get_string(Arg_Value, szValueString, MaxStringDataLength-1);
			TrieSetString(g_trDataSave, szKeyTrie, szValueString);
		}
		default:
		{
			new iValue = get_param_byref(Arg_Value);
			TrieSetCell(g_trDataSave, szKeyTrie, iValue);
		}
	}

	if(bHasData)
	{
		ExecuteForward(g_fwdChangeData, _, pEntity, szKey, true);
	}

	return true;
}

any: @__fubentity_get_data() {

	enum {Arg_Entity = 1, Arg_Key, Arg_Type, Arg_Value, Arg_ValueSize};

	new pEntity = get_param(Arg_Entity);
	new szKey[MaxKeyLength];
	new szKeyTrie[MaxKeyLength + MaxIndexLength];

	get_string(Arg_Key, szKey, MaxKeyLength-1);
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
			new szValueString[MaxStringDataLength];

			TrieGetString(g_trDataSave, szKeyTrie, szValueString, MaxStringDataLength-1);
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

	new szKey[MaxKeyLength];
	new szKeyTrie[MaxKeyLength + MaxIndexLength];

	get_string(Arg_Key, szKey, MaxKeyLength - 1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", get_param(Arg_Entity), szKey);

	return TrieKeyExists(g_trDataSave, szKeyTrie);
}

bool: @__fubentity_unset_data() {

	enum {Arg_Entity = 1, Arg_Key};

	new pEntity = get_param(Arg_Entity);
	new szKey[MaxKeyLength];
	new szKeyTrie[MaxKeyLength + MaxIndexLength];

	get_string(Arg_Key, szKey, MaxKeyLength - 1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", pEntity, szKey);

	if(TrieKeyExists(g_trDataSave, szKeyTrie) == false)
	{
		return false;
	}

	TrieDeleteKey(g_trDataSave, szKeyTrie);

	ExecuteForward(g_fwdSettedData, _, pEntity, szKey, eCustomData_UnSet);
	return true;
}

@__fubentity_clear_data() {

	enum {Arg_Entity = 1, Arg_UseForward};

	new Snapshot: hListKeys = TrieSnapshotCreate(g_trDataSave);
	new szKey[MaxKeyLength + MaxIndexLength];
	new szLeft[MaxIndexLength];
	new szBuffer[MaxKeyLength];
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

		TrieDeleteKey(g_trDataSave, szKey);
		iCountKeys++;

		if(bUseForward)
		{
			ExecuteForward(g_fwdSettedData, _, pEntity, szBuffer, eCustomData_UnSet);
		}
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