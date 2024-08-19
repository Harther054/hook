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

new g_fHookEndPos[MAX_PLAYERS + 1][3];

new g_iBitHookAccess;

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    register_clcmd("+hook", "Clcmd_HookOn");
    register_clcmd("-hook", "Clcmd_HookOff");

    CreateMultiForward("hook_on_start", ET_STOP, FP_CELL);
    CreateMultiForward("hook_on_update", ET_STOP, FP_CELL);
    CreateMultiForward("hook_on_end", ET_STOP, FP_CELL);

    register_forward(FM_PlayerPostThink, "MultiHook_PostThink", true);

    CreateCvars();

    g_iBitHookAccess = read_flags(g_Cvars[CVAR_HOOK_ACCESS]);
}

public client_putinserver(id)
{
    if(IsAccess(id, g_iBitHookAccess))
        g_DataStatus[id][bHOOK_USE] = true;
}

public client_disconnected(id)
{
    g_DataStatus[id][bHOOK_USE] = false;
}

public Clcmd_HookOn(id)
{
    if(g_DataStatus[id][bHOOK_USE])
    {
        g_DataStatus[id][bHOOK_GIVE] = true;

        if(g_DataStatus[id][bHOOK_FIX])
            get_user_origin(id, g_fHookEndPos[id], 3);

        ExecuteForward("hook_on_start", _, id);
    }
    else 
        client_print_color(id, print_team_red, "^3[^4Multi Hook^3]^1 У вас ^3нет ^1прав ^4доступа");

    return PLUGIN_HANDLED;
}

public Clcmd_HookOff(id)
{
    if(g_DataStatus[id][bHOOK_USE])
    {
        g_DataStatus[id][bHOOK_GIVE] = false;

        ExecuteForward("hook_on_end", _, id);
    }

    return PLUGIN_HANDLED;
}

public MultiHook_PostThink(id)
{
    if(g_DataStatus[id][bHOOK_GIVE])
    {
        static Float: fStartPos[3];
        
        get_entvar(id, var_origin, fStartPos);

        if(!g_DataStatus[id][bHOOK_FIX])
            get_user_origin(id, g_fHookEndPos[id], 3);

        new Float: fEndPos[3];
        IVecFVec(g_fHookEndPos[id], fEndPos);

        static Float: fDistance;
        fDistance = get_distance_f(fEndPos, fStartPos);

        static Float: fSpeed;
        fSpeed = float(500) / fDistance;

        static Float: fVelocity[3];

        if(fDistance > 25.0)
        {
            fVelocity[0] = (fEndPos[0] - fStartPos[0]) * fSpeed;
            fVelocity[1] = (fEndPos[1] - fStartPos[1]) * fSpeed;
            fVelocity[2] = (fEndPos[2] - fStartPos[2]) * fSpeed;

            set_entvar(id, var_velocity, fVelocity);

            ExecuteForward("hook_on_update", _, id);
        }
        else 
        {
            Clcmd_HookOff(id);
        }
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