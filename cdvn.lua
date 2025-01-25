local player = game.Players.LocalPlayer
-- Luarmor API Integration
local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()

api.script_id = "4aa3438fe1274380a7d25a7b705121b7"
-- Ensure the API loaded successfully
if not api then
    player:Kick("Failed to load Luarmor API. Please check your connection.")
    return
end

-- Validate the user's key using the Luarmor API
local script_key = getgenv().Key
local status = api.check_key(script_key) -- Pass the 32-character user key here

if status and status.code == "KEY_VALID" then
    -- Key is valid, proceed with the script
    print("Welcome! Seconds left: " .. (status.data.auth_expire - os.time()))
    print("Is key from ad system? " .. (status.data.note == "Ad Reward" and "YES" or "NO"))
    api.load_script()
    -- Load your actual script or loader here

elseif status and status.code == "KEY_HWID_LOCKED" then
    -- Key is locked to another HWID
    player:Kick("Your key is HWID locked. Please reset or use the correct device.")

elseif status and status.code == "KEY_INCORRECT" then
    -- Key is incorrect
    player:Kick("Your key is incorrect. Please check and try again.")

else
    -- Handle fallback cases (e.g., blacklisted key, empty key, etc.)
    player:Kick("Key check failed: " .. (status.message or "Unknown error") .. " Code: " .. (status.code or "UNKNOWN"))
end
wait(2)
