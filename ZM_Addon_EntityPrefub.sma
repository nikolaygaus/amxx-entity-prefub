
new const PluginVersion[] = "2.0.0";

#include <amxmodx>
#include <api_fubentity>

const MaxIndexLength = 16;
const MaxKeyLength = 64;
const MaxStringDataLength = 128;

new Trie: g_trDataSave;

public plugin_precache() {

	register_plugin("[API]: Entity Prefub", PluginVersion, "Ragamafona");

	g_trDataSave = TrieCreate();
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
	new iType = get_param(Arg_Type);

	get_string(Arg_Key, szKey, MaxKeyLength-1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", pEntity, szKey);

	switch(iType)
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

	return true;
}

any: @__fubentity_get_data() {

	enum {Arg_Entity = 1, Arg_Key, Arg_Type, Arg_Value, Arg_ValueSize};

	new pEntity = get_param(Arg_Entity);
	new szKey[MaxKeyLength];
	new szKeyTrie[MaxKeyLength + MaxIndexLength];
	new iType = get_param(Arg_Type);

	get_string(Arg_Key, szKey, MaxKeyLength-1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", pEntity, szKey);

	switch(iType)
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

			return 1;
		}
		default:
		{
			new iReturn;

			TrieGetCell(g_trDataSave, szKeyTrie, iReturn);

			return iReturn;
		}
	}

	return FubEntity_NotExists;
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

	new szKey[MaxKeyLength];
	new szKeyTrie[MaxKeyLength + MaxIndexLength];

	get_string(Arg_Key, szKey, MaxKeyLength - 1);
	formatex(szKeyTrie, charsmax(szKeyTrie), "%i:%s", get_param(Arg_Entity), szKey);

	if(bool: TrieKeyExists(g_trDataSave, szKeyTrie) == false)
		return false;

	TrieDeleteKey(g_trDataSave, szKeyTrie);
	return true;
}

bool: @__fubentity_clear_data() {

	enum {Arg_Entity = 1};

	new Snapshot: hListKeys = TrieSnapshotCreate(g_trDataSave);
	new szKey[MaxKeyLength];
	new szLeft[MaxIndexLength];
	new szBuffer[2];
	new pEntity = get_param(Arg_Entity);

	for(new iCase; iCase < TrieSnapshotLength(hListKeys); iCase++)
	{
		TrieSnapshotGetKey(hListKeys, iCase, szKey, charsmax(szKey));
		strtok2(szKey, szLeft, charsmax(szLeft), szBuffer, charsmax(szBuffer), ':', true);

		if(str_to_num(szLeft) != pEntity)
			continue;

		TrieDeleteKey(g_trDataSave, szKey);
	}

	TrieSnapshotDestroy(hListKeys);
	return true;
}