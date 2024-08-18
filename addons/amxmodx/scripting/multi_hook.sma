#include <amxmodx>
#include <ToolKit>

#define PLUGIN_NAME             "Multi Hook"
#define PLUGIN_VERSION          "1.0.0"
#define PLUGIN_AUTHOR           "by fgd"

enum _: eHookStatus
{
    bool:bHOOK_USE,
    bool:bHOOK_GIVE,
    bool:bHOOK_FIX
}

enum eCvars
{
    CVAR_HOOK_ACCESS[6]
};

new g_DataStatus[MAX_PLAYERS + 1][eHookStatus], g_Cvars[eCvars];

new Float: g_fHookOriginP[MAX_PLAYERS + 1][3];

new g_iBitHookAccess;

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    register_clcmd("+hook", "Clcmd_HookOn");
    register_clcmd("-hook", "Clcmd_HookOff");

    register_forward(FM_PlayerPostThink, "MultiHook_PostThink", true);

    CreateCvars();

    g_iBitHookAccess = read_flags(g_Cvars[CVAR_HOOK_ACCESS]);
}

public Clcmd_HookOn(id)
{
    if(!IsAccess(id, g_iBitHookAccess))
    {
        client_print_color(id, print_team_red, "^3[^4Multi Hook^3]^1 У вас ^3нет ^1прав ^4доступа");
        return PLUGIN_HANDLED;
    }
    if(g_DataStatus[id][bHOOK_USE])
    {
        g_DataStatus[id][bHOOK_GIVE] = true;

        if(g_DataStatus[id][bHOOK_FIX])
            velocity_by_aim(id, 9999, g_fHookOriginP[id]);
    }

    return PLUGIN_HANDLED;
}

public Clcmd_HookOff(id)
{
    if(g_DataStatus[id][bHOOK_USE])
    {
        g_DataStatus[id][bHOOK_GIVE] = false;
    }

    return PLUGIN_HANDLED;
}

public MultiHook_PostThink(id)
{
    if(g_DataStatus[id][bHOOK_GIVE])
    {
        static Float: fStartPos[3], Float:fEndPos[3];
        
        get_entvar(id, var_origin, fStartPos);

        if(!g_DataStatus[id][bHOOK_FIX])
            velocity_by_aim(id, 9999, g_fHookOriginP[id]);

    }
}

CreateCvars()
{
    bind_pcvar_string(
        create_cvar(
            .name = "hook_access",
            .string = "r",
            .description = "Флаг доступа к паутинке"
        ), g_Cvars[CVAR_HOOK_ACCESS], charsmax(g_Cvars[CVAR_HOOK_ACCESS]));

    AutoExecConfig(true, "multi_hook", "multi_hook");
}