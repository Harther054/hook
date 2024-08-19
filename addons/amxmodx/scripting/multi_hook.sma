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

enum eForwards
{
    FWD_ON_START,
    FWD_ON_UPDATE,
    FWD_ON_END
};

new g_DataStatus[MAX_PLAYERS + 1][eHookStatus], g_Cvars[eCvars], g_Fwd[eForwards];

new Float: g_fHookEndPos[MAX_PLAYERS + 1][3];

new g_iBitHookAccess;

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    register_clcmd("+hook", "Clcmd_HookOn");
    register_clcmd("-hook", "Clcmd_HookOff");

    g_Fwd[FWD_ON_START] = CreateMultiForward("hook_on_start", ET_STOP, FP_CELL);
    g_Fwd[FWD_ON_UPDATE] = CreateMultiForward("hook_on_update", ET_STOP, FP_CELL, FP_FLOAT);
    g_Fwd[FWD_ON_END] = CreateMultiForward("hook_on_end", ET_STOP, FP_CELL);

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

        new fEndPos[3];
        get_user_origin(id, fEndPos, 3);
        IVecFVec(fEndPos, g_fHookEndPos[id]);

        ExecuteForward(g_Fwd[FWD_ON_START], _, id);
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

        ExecuteForward(g_Fwd[FWD_ON_END], _, id);
    }

    return PLUGIN_HANDLED;
}

public MultiHook_PostThink(id)
{
    if(g_DataStatus[id][bHOOK_GIVE])
    {
        static Float: fStartPos[3];
        
        get_entvar(id, var_origin, fStartPos);

        ExecuteForward(g_Fwd[FWD_ON_UPDATE], _, id, g_fHookEndPos[id]);

        static Float: fDistance;
        fDistance = get_distance_f(g_fHookEndPos[id], fStartPos);

        static Float: fSpeed;
        fSpeed = float(500) / fDistance;

        static Float: fVelocity[3];

        if(fDistance > 25.0)
        {
            fVelocity[0] = (g_fHookEndPos[id][0] - fStartPos[0]) * fSpeed;
            fVelocity[1] = (g_fHookEndPos[id][1] - fStartPos[1]) * fSpeed;
            fVelocity[2] = (g_fHookEndPos[id][2] - fStartPos[2]) * fSpeed;

            set_entvar(id, var_velocity, fVelocity);

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