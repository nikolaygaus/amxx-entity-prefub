/*
	[API]: Entity Prefub
	
	- Позволяет устанавливать различные данные по ключам и строить некую иерархию использования функций
	предоставленными нативами.

	- Allows you to set various data by keys and build a certain hierarchy of using functions
	provided by the native.
	
	p.s. это некий аналог модулю Custom Entity Data и замена хранению данных в pev.
	p.s. it is a kind of analogue of the Custom Entity Data module and a replacement for pev.

	(c) Ragamafona (vk.com/felhalas)
*/

#if defined _fubentity_included
	#endinput
#endif

#define _fubentity_included

const FubEntity_MaxIndexLength = 16;
const FubEntity_MaxKeyLength = 64;
const FubEntity_MaxStringDataLength = 128;

enum _: {

	eType_Integer = 0,
	eType_Float,
	eType_String
};

// * Just for lovers
#define eType_Int eType_Integer
#define eType_Real eType_Float
#define eType_Str eType_String

enum _: {

	eCustomData_UnSet = 0,
	eCustomData_Set
};

/**
 * Hook set/unset key.
 * eCustomData_UnSet: Since the forward is executed before the operation, data can still be unloaded from the key.
 * 
 * @param pEntity       Index
 * @param szKey         Key
 * @param iTypeData     Data type
 * @param iTypeForward  Forward type
 * 
 * @return              none
 */
forward evtfent_setted_data(const pEntity, const szKey[], const iTypeData, const iTypeForward);

/**
 * Hook change key data.
 * 
 * @param pEntity       Index
 * @param szKey         Key
 * @param iTypeData     Data type
 * @param bPost         Pre/Post event
 * 
 * @return              none
 */
forward evtfent_change_data(const pEntity, const szKey[], const iTypeData, const bool: bPost);

/**
 * Set key value.
 * 
 * @param pEntity 		Index
 * @param szKey 		Key
 * @param iArgType 		Data type
 * @param any:... 		Value
 * @param bUseForward   Whether to call forward set data? - true or false (param[5])
 * 
 * @note				The sixth argument controls the forward call. Allows you to set data without calling forward.
 * 
 * @note				Usage examples:
 *                      [
 * 							fubentity_set_data(pPlayer, "crystal", eType_Integer, 5, true);
 * 							fubentity_set_data(pPlayer, "damage", eType_Float, 15.0, true);
 * 							fubentity_set_data(pPlayer, "zombiename", eType_String, "hunter", true);
 * 
 * 							// silent type
 * 							fubentity_set_data(pPlayer, "mypassword", eType_String, "bestsilentdata", false);
 *                      ]
 * 
 * @return 				none
 */
native fubentity_set_data(const pEntity, const szKey[], const iArgType = eType_Integer, any:...);

/**
 * Get key value.
 * 
 * @param pEntity 		Index
 * @param szKey 		Key
 * @param iArgType 		Data type
 * @param szValue 		String Buffer
 * @param iValueSize	String buffer length 
 * 
 * @note				Usage examples:
 *                      [
 * 							new iReturn = fubentity_get_data(pEntity, "crystal", eType_Integer);
 * 							new Float: flReturn = fubentity_get_data(pPlayer, "damage", eType_Float);
 * 							new szReturn[32]; fubentity_get_data(pPlayer, "zombiename", eType_String, szReturn, charsmax(szReturn));
 *                      ]
 * 
 * @return 				Value integer or float.
 */
native any: fubentity_get_data(const pEntity, const szKey[], const iArgType = eType_Integer, const szValue[] = "", const iValueSize = 0);

/**
 * Removing a key and its value.
 * 
 * @param pEntity 		Index
 * @param szKey 		Key
 * @param bUseForward   Whether to call forward set data? - true or false
 * 
 * @note				Usage examples:
 * 						[
 * 							fubentity_set_data(228, "crystal", eType_Float, 100.0);
 * 							fubentity_unset_data(228, "crystal");
 * 						]
 * 
 * @return 				none
 */
native fubentity_unset_data(const pEntity, const szKey[], const bool: bUseForward = true);

/**
 * Key verification.
 * 
 * @param pEntity       Index
 * @param szKey         Key
 * 
 * @note                Usage examples:
 *                      [
 *                          if(fubentity_isset_data(228, "crystal"))
 *                          {
 *                              ...
 *                          }
 *                      ]
 * 
 * @return              none
 */
native bool: fubentity_isset_data(const pEntity, const szKey[]);

/**
 * Removing getting keys by index.
 * 
 * @param pEntity 		Index
 * @param bUseForward   Whether to call forward set data? - true or false
 * 
 * @note				Usage examples:
 * 						[
 * 							fubentity_set_data(228, "mykey", eType_Integer, 100);
 * 							fubentity_clear_data(228);
 * 						]
 * 
 * @return 				Removed keys count
 */
native fubentity_clear_data(const pEntity, const bool: bUseForward = false);

/*
 * Reduction of functions due to macros
 */

#define cd_set fubentity_set_data

#define cd_set_s(%0,%1,%2,%3) fubentity_set_data(%0,%1,%2,%3,false)

#define cd_unset fubentity_unset_data

#define cd_unset_s(%0,%1) fubentity_unset_data(%0,%1,false)

#define cd_get fubentity_get_data

#define cd_isset fubentity_isset_data

#define cd_clear fubentity_clear_data

stock any: cd_get_if(const pEntity, const szKey[], const iArgType, const any: iReturn = -1) {

	if(fubentity_isset_data(pEntity, szKey))
		return fubentity_get_data(pEntity, szKey, iArgType);

	return iReturn;
}

/**
 * This is the callback from the main plugin that gives major/minor versions
 * for verifying compatibility for EntityPrefub versions.
 * If an AMXX plugin gets a failure, then you do need to upgrade to the latest
 * version of the EntityPrefub plugins or update the files included for AMXX plugins.
 * Do not modify this!
 */

/**
 * EntityPrefub version
 */

#define _EntityPrefub_Version 240
#define FubEntity_Version_Major "2"
#define FubEntity_Version_Minor "4"
#define FubEntity_Version_Patch "0"
#define _sEntityPrefub_Version FubEntity_Version_Major + "." + FubEntity_Version_Minor + "." + FubEntity_Version_Patch

public __fubentity_version_check(const majorVersion[], const minorVersion[]) {

	if(strcmp(majorVersion, FubEntity_Version_Major) != 0) {

		set_fail_state("[FubEntity]: Api major version mismatch; expected %s, real %s",
			FubEntity_Version_Major, majorVersion);

		return;
	}

	if(strcmp(minorVersion, FubEntity_Version_Minor) != 0) {

		set_fail_state("[FubEntity]: Api minor version mismatch; expected at least %s, real %s",
			FubEntity_Version_Minor, minorVersion);

		return;
	}
}