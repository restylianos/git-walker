function execCommand(command)
    local handler = io.popen(command)
    local result = handler:read("*a")
    handler:close()
    return result
end


local function binWalk(totalHashes, currentPosition, direction)
    -- this walks
    local nextPosition = nil
    
    if direction == "right" then
        nextPosition = math.min(currentPosition + math.floor((totalHashes - currentPosition) / 2), totalHashes)
    elseif direction == "left" then
        nextPosition = math.max(currentPosition - math.floor(currentPosition / 2), 1)
    end
    
    return nextPosition
end


local function extractCommitHashes(gitLogOutput)
    -- return the hashes in a table in order to navigate based on index
    local hashes = {}
    for hash in gitLogOutput:gmatch("[^\n]+") do
        table.insert(hashes, 1, hash) -- reverse order
    end
    return hashes
end

-- start
print (string.rep("=", "60"))

local args = { ... }
local branch = "main"
if #args > 0 then
    branch = args[0]
    print("[+] Using branch " .. branch .. " !")
else
    print("[+] No branch provided. Using main as fallback.")
end

local totalResults = tonumber(execCommand("git rev-list --count " .. branch))
print("\27[33;94m[i]\27[0m Total commits in branch: " .. branch .. " => " .. totalResults)

local hashes = extractCommitHashes(execCommand("git log --format=%H"));

local navigationCount = math.floor(totalResults / 2)
print("Current position " .. navigationCount .. " from " .. totalResults .. ".")

while true do
    print("\27[033;33m[!]\27[0m Use k(binary back), l(binary forward),h(back),j(forward) keys to navigate in history. Use q key to exit.")
    local userInput = io.read()

    if userInput == "k" or userInput == "l"  then
        local searchDirection = userInput == "k" and "left" or "right"
        navigationCount = binWalk(totalResults, navigationCount, searchDirection)

    elseif userInput == "h" or userInput == "j"  then
        local decrease = userInput == "h" 
        print(navigationCount,totalResults)
        if decrease == true then
            if  navigationCount == 1 then
                print("[!] Max history limit reach")
            else
                navigationCount = navigationCount - 1
            end
        end
        if decrease == false then 
            if navigationCount==totalResults then 
                print("[!] Max history limit reach")
            else
                navigationCount = navigationCount + 1
            end
        end

       
    elseif userInput == "q" then 
        print("Exiting!")
        execCommand("git switch " .. branch)
        break
    else 
        print("\27[033;33m[!]\27[0m Invalid option!")
    end

    execCommand("git checkout " .. hashes[navigationCount])
    print("Current position " .. navigationCount .. " from " .. totalResults .. ".")
end


print (string.rep("=", "60"))
return 0

-- end