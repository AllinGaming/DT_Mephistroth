# Mephistroth 按键禁用助手（乌龟服专用）
SLASH_DTSCREENTEST1 = "/dtscreentest"
SlashCmdList["DTSCREENTEST"] = function(_) OnShacklesCast() end

------------------------------------------------------------
--  Slash commands
------------------------------------------------------------
SLASH_COCTEST1 = "/coctest"
SlashCmdList["COCTEST"] = function(_) OnShacklesCastCoc() end

------------------------------------------------------------
--  Slash commands
------------------------------------------------------------
SLASH_DTMOVETEST1 = "/dtmovetest"
SlashCmdList["DTMOVETEST"] = fu


/dtqe on to disable q and e keys too
/dtqe off to disable disabling q and e

What does this addon do?
1 - When the chat window message "Mephistroph begins to cast Shackles of the Legion" is detected, a grey overlay on your screen (see picture) will tell you to release your movement keys.
2 - Your movement keys (WASD) will be unbound 0.1 seconds before the Shackles of the Legion cast is completed.
3 - After the Shackles of the Legion cast is completed, the addon will check whether you have the Shackles debuff or not after 0.1 seconds.
    a) If you have the debuff, it will keep your movement keys unbound for 6 seconds and then rebind them.
    b) If you do not have the Shackles debuff, it will rebind your movement keys.

What if I use Q & E for movement?
The /dtqe command will toggle the disabling of the Q & E keys (see picture).
NOTE - this is something you setup BEFORE the raid. The setting only needs to be setup once as the addon will remember your choice.

Version Control
The /dtver command checks if the people in the raid have the addon and which version they are using.

Limitations
1 - You will still be able to move by holding down left + right mouse buttons. So, it is still possible to break the shackles this way!
2 - This addon will not stop you if you are ALREADY MOVING when the check (0.1 seconds left) occurs. It will only PREVENT your movement after the check has completed.
3 - If you RELEASE your movement keys during the check you will be stuck in an autorun state and break the shackles. NOBODY should be trying to optimise their movement with only 0.1 seconds left; that is a ridiculous level of optimisation

