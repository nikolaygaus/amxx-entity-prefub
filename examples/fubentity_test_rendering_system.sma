
#include <amxmodx>
#include <fakemeta>
#include <reapi>
#include <api_fubentity>

new const CD_kModel[] = "trsmdl";
new const g_szEntityModel[] = "models/player/vip/vip.mdl";

enum _: eData_Player {

	epl_iMenuType,
	epl_iInput,
	epl_pEntity,

	epl_iFxMode[2],
	Float: epl_flColor[4]
};

new g_aPlayerData[MAX_PLAYERS + 1][eData_Player];

public plugin_precache() {

	precache_model(g_szEntityModel);
}

public plugin_init() {

	register_plugin("[FubEntity]: Test Rendering", _sEntityPrefub_Version, "Ragamafona");

	register_clcmd("say /render", "@ClientCommand_Render", ADMIN_RCON);
	register_concmd("rs_input", "@ClientCommand_Input", ADMIN_RCON);
}

public client_putinserver(pPlayer) {

	g_aPlayerData[pPlayer][epl_flColor][3] = 150.0;
}

public client_disconnected(pPlayer) {

	new pEntity = g_aPlayerData[pPlayer][epl_pEntity];

	if(!is_nullent(pEntity))
	{
		set_entvar(pEntity, var_flags, FL_KILLME);
	}

	arrayset(g_aPlayerData[pPlayer], 0, eData_Player);
}

@ClientCommand_Render(const pPlayer, const iLevel) {

	if(!is_user_connected(pPlayer))
	{
		return;
	}

	if(iLevel > 0 && ~get_user_flags(pPlayer) & iLevel)
	{
		return;
	}

	Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = 0);
}

@ClientCommand_Input(const pPlayer, const iLevel) {

	if(!is_user_connected(pPlayer))
	{
		return;
	}

	if(iLevel > 0 && ~get_user_flags(pPlayer) & iLevel)
	{
		return;
	}

	new iInputNum = g_aPlayerData[pPlayer][epl_iInput];

	if(!iInputNum)
	{
		return;
	}

	if(read_argc() != 2)
	{
		return;
	}

	g_aPlayerData[pPlayer][epl_flColor][iInputNum - 1] = read_argv_float(1);
	Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = 0);

	g_aPlayerData[pPlayer][epl_iInput] = 0;
}

Open_MenuMain(const pPlayer, const iType) {

	new pMenuId = menu_create("\rTest rendering", "@Handle_MenuMain");

	static const szRenderFx[][] = {

		"kRenderFxNone",
		"kRenderFxPulseSlow",
		"kRenderFxPulseFast",
		"kRenderFxPulseSlowWide",
		"kRenderFxPulseFastWide",
		"kRenderFxFadeSlow",
		"kRenderFxFadeFast",
		"kRenderFxSolidSlow",
		"kRenderFxSolidFast",
		"kRenderFxStrobeSlow",
		"kRenderFxStrobeFast",
		"kRenderFxStrobeFaster",
		"kRenderFxFlickerSlow",
		"kRenderFxFlickerFast",
		"kRenderFxNoDissipation",
		"kRenderFxDistort",           /* Distort/scale/translate flicker */
		"kRenderFxHologram",          /* kRenderFxDistort + distance fade */
		"kRenderFxDeadPlayer",        /* kRenderAmt is the player index */
		"kRenderFxExplode",           /* Scale up really big! */
		"kRenderFxGlowShell",         /* Glowing Shell */
		"kRenderFxClampMinScale"     /* Keep this sprite from getting very small (SPRITES only!) */
	};

	static const szRenderMode[][] = {

		"kRenderNormal",		/* src */
		"kRenderTransColor",	/* c*a+dest*(1-a) */
		"kRenderTransTexture",	/* src*a+dest*(1-a) */
		"kRenderGlow",			/* src*a+dest -- No Z buffer checks */
		"kRenderTransAlpha",	/* src*srca+dest*(1-srca) */
		"kRenderTransAdd"		/* src*a+dest */
	};

	switch(iType)
	{
		case 0:
		{
			menu_additem(pMenuId, fmt("%s entity", is_nullent(g_aPlayerData[pPlayer][epl_pEntity]) ? "Create" : "Remove"));
			menu_additem(pMenuId, fmt("Fx: \r%s", szRenderFx[g_aPlayerData[pPlayer][epl_iFxMode][0]]));
			menu_additem(pMenuId, fmt("Mode: \r%s", szRenderMode[g_aPlayerData[pPlayer][epl_iFxMode][1]]));
			menu_additem(pMenuId, fmt("R: \r%.0f", g_aPlayerData[pPlayer][epl_flColor][0]));
			menu_additem(pMenuId, fmt("G: \r%.0f", g_aPlayerData[pPlayer][epl_flColor][1]));
			menu_additem(pMenuId, fmt("B: \r%.0f", g_aPlayerData[pPlayer][epl_flColor][2]));
			menu_additem(pMenuId, fmt("Amt: \r%.0f", g_aPlayerData[pPlayer][epl_flColor][3]));

			Func_UpdateEntityRender(pPlayer);
		}
		case 1:
		{
			new iArraySize = sizeof(szRenderFx);

			for(new a; a < iArraySize; a++)
			{
				menu_additem(pMenuId, szRenderFx[a]);
			}
		}
		case 2:
		{
			new iArraySize = sizeof(szRenderMode);

			for(new a; a < iArraySize; a++)
			{
				menu_additem(pMenuId, szRenderMode[a]);
			}
		}
	}
	
	menu_display(pPlayer, pMenuId, 0);
}

@Handle_MenuMain(const pPlayer, const pMenuId, const pItem) {

	if(pItem == MENU_EXIT)
	{
		menu_destroy(pMenuId);
		return PLUGIN_HANDLED;
	}

	new iMenuType = g_aPlayerData[pPlayer][epl_iMenuType];

	switch(iMenuType)
	{
		case 0:
		{
			switch(pItem)
			{
				case 0:
				{
					new pEntity = g_aPlayerData[pPlayer][epl_pEntity];

					if(is_nullent(pEntity))
					{
						{
							static const szDefaultClassname[] = "info_target";
							
							pEntity = rg_create_entity(szDefaultClassname);
						}

						new Float: flOrigin[3];

						set_entvar(pEntity, var_movetype, MOVETYPE_NOCLIP);
						set_entvar(pEntity, var_solid, SOLID_NOT);

						get_entvar(pPlayer, var_origin, flOrigin);
						//	set_entvar(pEntity, var_origin, flOrigin);
						engfunc(EngFunc_SetOrigin, pEntity, flOrigin);

						get_entvar(pPlayer, var_v_angle, flOrigin);
						//	flOrigin[0] = flOrigin[2] = 0.0;
						set_entvar(pEntity, var_angles, flOrigin);

						if(fubentity_isset_data(pPlayer, CD_kModel))
						{
							new szBuffer[128];
							fubentity_get_data(pPlayer, CD_kModel, eType_String, szBuffer, charsmax(szBuffer));
							
							engfunc(EngFunc_SetModel, pEntity, szBuffer);
						}
						else
						{
							engfunc(EngFunc_SetModel, pEntity, g_szEntityModel);
						}
						//	set_entvar(pEntity, var_body, 1);
					}
					else
					{
						set_entvar(pEntity, var_flags, FL_KILLME);
						pEntity = 0;
					}

					g_aPlayerData[pPlayer][epl_pEntity] = pEntity;
					Func_UpdateEntityRender(pPlayer);

					Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = 0);
				}
				case 1, 2:
				{
					Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = pItem);
				}
				//case 3, 4, 5, 6:
				case 3..6:
				{
					g_aPlayerData[pPlayer][epl_iInput] = pItem - 2;
					client_cmd(pPlayer, "messagemode ^"rs_input^"");
				}
			}
		}
		case 1, 2:
		{
			g_aPlayerData[pPlayer][epl_iFxMode][iMenuType - 1] = pItem;
			Open_MenuMain(pPlayer, g_aPlayerData[pPlayer][epl_iMenuType] = 0);
		}
	}

	menu_destroy(pMenuId);
	return PLUGIN_HANDLED;
}

Func_UpdateEntityRender(const pPlayer) {

	new pEntity = g_aPlayerData[pPlayer][epl_pEntity];

	if(is_nullent(pEntity))
	{
		return;
	}

	new Float: flColor[3];

	flColor[0] = g_aPlayerData[pPlayer][epl_flColor][0];
	flColor[1] = g_aPlayerData[pPlayer][epl_flColor][1];
	flColor[2] = g_aPlayerData[pPlayer][epl_flColor][2];

	UTIL_SetRendering(pEntity, 
		g_aPlayerData[pPlayer][epl_iFxMode][0],
		flColor,
		g_aPlayerData[pPlayer][epl_iFxMode][1],
		g_aPlayerData[pPlayer][epl_flColor][3]
	);
}

public evtfent_setted_data(const pPlayer, const szKey[], const iTypeData, const iTypeForward) {

	if(iTypeForward == eCustomData_UnSet)
	{
		return;
	}

	if(strcmp(CD_kModel, szKey))
	{
		return;
	}

	Func_UpdateModel(pPlayer);
}

public evtfent_change_data(const pPlayer, const szKey[], const iTypeData, const bool: bPost) {

	if(bPost == false)
	{
		return;
	}

	if(strcmp(CD_kModel, szKey))
	{
		return;
	}

	Func_UpdateModel(pPlayer);
}

Func_UpdateModel(const pPlayer) {

	new pEntity = g_aPlayerData[pPlayer][epl_pEntity];

	if(is_nullent(pEntity))
	{
		return;
	}

	new szBuffer[128];
	fubentity_get_data(pPlayer, CD_kModel, eType_String, szBuffer, charsmax(szBuffer));

	engfunc(EngFunc_SetModel, pEntity, szBuffer);
}

//

stock UTIL_SetRendering(const pEntity, const iFx, const Float: flColors[3], const iMode, const Float: flAmmount) {
	
	set_entvar(pEntity, var_renderfx, iFx);
	set_entvar(pEntity, var_rendercolor, flColors);
	set_entvar(pEntity, var_rendermode, iMode);
	set_entvar(pEntity, var_renderamt, flAmmount);
}