/*
	[API]: Entity Prefub
	
	- Позволяет устанавливать различные данные по ключам и строить некую иерархию использования функций
	предоставленными нативами.

	- Allows you to set various data by keys and build a certain hierarchy of using functions
	provided by the native.
	
	p.s. это некий аналог модулю Custom Entity Data и замена pev.
	p.s. it is a kind of analogue of the Custom Entity Data module and a replacement for pev.

	(c) Ragamafona (vk.com/felhalas)
*/

#if defined _fubentity_included
	#endinput
#endif

#define _fubentity_included

stock const _sEntityPrefub_Version[] = "2.2.0";
#define _EntityPrefub_Version 220

enum _: {

	eType_Integer = 0,
	eType_Float,
	eType_String
};

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
 * @param iForwardType  Forward type
 * 
 * @return              none
 */
forward evtfent_setted_data(const pEntity, const szKey[], const iForwardType);

/**
 * Hook change key data.
 * 
 * @param pEntity       Index
 * @param szKey         Key
 * @param bPost         Pre/Post event
 * 
 * @return              none
 */
forward evtfent_change_data(const pEntity, const szKey[], const bool: bPost);

/**
 * Set key value.
 * 
 * @param pEntity 		Index
 * @param szKey 		Key
 * @param iArgType 		Type Data
 * @param any:... 		Value
 * 
 * @note				Usage examples:
 *                      [
 * 							fubentity_set_data(pPlayer, "crystal", eType_Integer, 5);
 * 							fubentity_set_data(pPlayer, "damage", eType_Float, 15.0);
 * 							fubentity_set_data(pPlayer, "zombiename", eType_String, "hunter");
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
 * @param iArgType 		Type Data
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
 * 
 * @note				Usage examples:
 * 						[
 * 							fubentity_set_data(228, "crystal", eType_Float, 100.0);
 * 							fubentity_unset_data(228, "crystal");
 * 						]
 * 
 * @return 				none
 */
native fubentity_unset_data(const pEntity, const szKey[]);

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
 * @param bUseForward   Enable forward hook
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