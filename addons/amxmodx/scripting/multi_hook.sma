#include <amxmodx>
#include <ToolKit>

#define PLUGIN_NAME             "Multi Hook"
#define PLUGIN_VERSION          "1.0.0"
#define PLUGIN_AUTHOR           "by fgd"

enum eCvars
{
    CVAR_HOOK_ACCESS[6]
};

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    register_clcmd("+hook", "Clcmd_HookOn");
    register_clcmd("-hook", "Clcmd_HookOff");
}

public Clcmd_HookOn(id)
{

}

public Clcmd_HookOff(id)
{

}