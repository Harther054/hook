#include <amxmodx>
#include <ToolKit>

#define PLUGIN_NAME             "Multi Hook"
#define PLUGIN_VERSION          "1.0.0"
#define PLUGIN_AUTHOR           "by fgd"

enum eCvars
{
    CVAR_HOOK_ACCESS[6]
};

new g_Cvars[eCvars];

new iBitHookAccess;

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    register_clcmd("+hook", "Clcmd_HookOn");
    register_clcmd("-hook", "Clcmd_HookOff");

    CreateCvars();

    iBitHookAccess = read_flags(g_Cvars[CVAR_HOOK_ACCESS]);
}

public Clcmd_HookOn(id)
{

}

public Clcmd_HookOff(id)
{

}

CreateCvars()
{
    bind_pcvar_string(
        create_cvar(
            .name = "hook_access",
            .string = "r",
            .description = "Флаг доступа к паутинке"
        ), g_Cvars[CVAR_HOOK_ACCESS], charsmax(g_Cvars[CVAR_HOOK_ACCESS]));
}