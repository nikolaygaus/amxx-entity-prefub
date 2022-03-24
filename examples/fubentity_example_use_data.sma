
new const PluginVersion[] = "1.0.1";

#include <amxmodx>
#include <api_fubentity>

new const CD_kMoney[] = "money";

new g_iPlayerMoney[MAX_PLAYERS + 1];

public plugin_init() {

	register_plugin("[FubEntity]: Example Use Data", PluginVersion, "Ragamafona");

	register_concmd("cd_usedata", "@ServerCommand_UseData");

	fubentity_set_data(0, CD_kMoney, eType_Integer, 0, false);
}

@ServerCommand_UseData(const pEntity) {

	Func_SetMoney(pEntity, g_iPlayerMoney[pEntity] + 100);
}

public client_putinserver(pPlayer) {

	fubentity_set_data(pPlayer, CD_kMoney, eType_Integer, 0, false);
}

public client_disconnected(pPlayer) {

	g_iPlayerMoney[pPlayer] = 0;
	fubentity_unset_data(pPlayer, CD_kMoney);
}

Func_SetMoney(const pPlayer, const iValue) {

	g_iPlayerMoney[pPlayer] = iValue;
	fubentity_set_data(pPlayer, CD_kMoney, eType_Integer, iValue, false);
}

public evtfent_change_data(const pEntity, const szKey[], const iTypeData, const bool: bPost) {

	if(bPost == false)
		return;

	if(strcmp(szKey, CD_kMoney))
		return;

	g_iPlayerMoney[pEntity] = fubentity_get_data(pEntity, CD_kMoney, iTypeData);
}