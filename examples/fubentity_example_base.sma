
#include <amxmodx>
#include <api_fubentity>

new const CustomKeyData[] = "gaus";

public plugin_precache() {

	register_plugin("[FubEntity]: Example", _sEntityPrefub_Version, "Ragamafona");

	fubentity_set_data(0, CustomKeyData, eType_Integer, 123, true);
	fubentity_set_data(0, CustomKeyData, eType_Integer, 321, true);
	fubentity_unset_data(0, CustomKeyData, true);

	fubentity_set_data(1, CustomKeyData, eType_Integer, 123, true);
	fubentity_clear_data(1, true);
}

public evtfent_setted_data(const pEntity, const szKey[], const iTypeData, const iTypeForward) {

	server_print("[%s] > Index: (%i), Key: (%s)", iTypeForward ? "SET" : "UNSET", pEntity, szKey);
}

public evtfent_change_data(const pEntity, const szKey[], const iTypeData, const bool: bPost) {

	server_print("[%s][CHANGE] > Index: (%i), Key: (%s), Value: (%i)", 
		bPost ? "POST" : "PRE", pEntity, szKey, fubentity_get_data(pEntity, szKey, iTypeData));
}

/**
 * This method did not allow, if necessary, to change the data that had just arrived.
 * Therefore, the implementation was split into two separate forwards.
 */

/*
public evtfent_change_data(const pEntity, const szKey[], const iForwardType) {

	new const szForwardType[][] = {

		"UNSET",
		"SET",
		"CHANGE"
	};

	server_print("[%s] > Index: (%i), Key: (%s)", szForwardType[iForwardType], pEntity, szKey);

	if(strcmp(szKey, CustomKeyData))
		return;

	if(iForwardType == eCustomData_Change)
	{
		server_print("[PRE][CHANGE] > Index: (%i), Key: (%s), Value: (%i)", 
			pEntity, szKey, fubentity_get_data(pEntity, szKey, eType_Integer));

		RequestFrame("@RequestFrame_HookNewValue", pEntity);
	}
}

@RequestFrame_HookNewValue(const pEntity) {

	server_print("[POST][CHANGE] > Index: (%i), Key: (%s), Value: (%i)", 
			pEntity, CustomKeyData, fubentity_get_data(pEntity, CustomKeyData, eType_Integer));

	fubentity_unset_data(pEntity, CustomKeyData);
}
*/