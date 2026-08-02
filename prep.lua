local prep = {};

local containerNames = {
    'Inventory',
    'Safe',
    'Storage',
    'Temporary',
    'Locker',
    'Satchel',
    'Sack',
    'Case',
    'Wardrobe',
    'Safe2',
    'Wardrobe2',
    'Wardrobe3',
    'Wardrobe4',
    'Wardrobe5',
    'Wardrobe6',
    'Wardrobe7',
    'Wardrobe8',
    'Recycle'
};

local function HasItem(id)
    local inventory = AshitaCore:GetMemoryManager():GetInventory();
    for container = 0,16 do
        for index = 1,81 do
            local item = inventory:GetContainerItem(container, index);
            if (item.Id == id) and (item.Count > 0) then
                return true;
            end
        end
    end
    return false;
end

local function IsValid(item)
    if item == nil then
        return false;
    end

    if (item.Count == 0) or (item.Id == 0) then
        return false;
    end
    
    return true;
end

local furnitureTypes = T{ [10]=true, [11]=true, [12]=true, [14]=true };
local function CanMove(item)
    -- Don't try to move equipped, bazaared, etc.. items
    if (item.Flags ~= 0) then
        return false;
    end

    -- Don't try to move placed furniture
    local res = AshitaCore:GetResourceManager():GetItemById(item.Id);
    if furnitureTypes[res.Type] then
        local placeFlags = struct.unpack('B', item.Extra, 2);
        if (bit.band(placeFlags, 0x40) == 0x40) then
            return false;
        end
    end

    return true;
end

local function GetMatchingSlip(playerSlips, item)
    -- Verify the item's ID fits on a slip..
    local slipId, storageIndex = gData:GetSlip(item.Id);
    if not slipId then
        return false;
    end

    -- Verify the item is augmented if the slip expects it (relic augments)
    -- or not augmented if it doesn't (sky gear)
    if not gData:CheckAugment(slipId, item.Extra) then
        return false;
    end

    -- Verify the player has a matching slip..
    local playerSlip = playerSlips[slipId];
    if not playerSlip then
        return false;
    end

    -- Verify the matching slip doesn't already have the item in it..
    if gData:CheckSlipItem(playerSlip, storageIndex) then
        return false;
    end
    
    return playerSlip;
end

function prep:PreparePack(includeList)
    local shouldContain = (gSettings.ReversePack == true);
    local exclude = gSettings.ExcludePack;
    local prepItems = T{};
    local playerSlips = gData:GetPlayerSlips();
    for container = 0,16 do
        if gData:GetContainerAvailable(container) then
            local inventory = AshitaCore:GetMemoryManager():GetInventory();
            for index = 1,81 do
                local item = inventory:GetContainerItem(container, index);
                if IsValid(item) then
                    local playerSlip = GetMatchingSlip(playerSlips, item);
                    if playerSlip and CanMove(item) then
                        if (not exclude:contains(item.Id)) and (includeList:contains(item.Id) == shouldContain) then
                            local slipId = playerSlip.Item.Id;
                            if (type(prepItems[slipId]) ~= 'table') then
                                prepItems[slipId] = T{{ ItemId = slipId, Container = playerSlip.Container, Index = playerSlip.Index }};
                            end
                            prepItems[slipId]:append({ ItemId = item.Id, Container = container, Index = index });
                        end
                    end
                end
            end
        end
    end

    local freeSpace = gData:GetFreeSpace(0);
    local itemsRemaining = 0;
    local itemsRetrieved = 0;
    
    for _,slipItems in pairs(prepItems) do
        for _,item in ipairs(slipItems) do
            if (item.Container ~= 0) then
                if freeSpace > 0 then
                    self:RetrieveItem(item.Container, item.Index, item.ItemId);
                    freeSpace  = freeSpace - 1;
                    itemsRetrieved = itemsRetrieved + 1;
                else
                    itemsRemaining = itemsRemaining + 1;
                end
            end
        end
    end
    
    print(chat.header('Porter') .. chat.color1(2, itemsRetrieved) .. chat.message(' items were retrieved.  ') .. chat.color1(2, itemsRemaining) .. chat.message(' items remain.'));
    if gData:GetContainerAvailable(1) == false then
        print(chat.header('Porter') .. chat.error('Note that you are not currently in range of a nomad moogle or in the mog house.'))
    end
end

function prep:PrepareUnpack(includeList)
    local exclude = gSettings.ExcludeUnpack;
    local retrieveSlips = T{};
    local playerSlips = gData:GetPlayerSlips();
    for id,slip in pairs(playerSlips) do
        local slipItems = gData:GetSlipItems(slip);
        for _,item in pairs(slipItems) do
            if (includeList:contains(item)) and (not HasItem(item)) then
                retrieveSlips:append(slip);
                break;
            end
        end
    end

    local freeSpace = gData:GetFreeSpace(0);
    local itemsRemaining = 0;
    local itemsRetrieved = 0;
    
    for _,slip in ipairs(retrieveSlips) do
        if (slip.Container ~= 0) then
            if freeSpace > 0 then
                self:RetrieveItem(slip.Container, slip.Index, slip.Item.Id);
                freeSpace  = freeSpace - 1;
                itemsRetrieved = itemsRetrieved + 1;
            else
                itemsRemaining = itemsRemaining + 1;
            end
        end
    end
    
    print(chat.header('Porter') .. chat.color1(2, itemsRetrieved) .. chat.message(' items were retrieved.  ') .. chat.color1(2, itemsRemaining) .. chat.message(' items remain.'));
    if gData:GetContainerAvailable(1) == false then
        print(chat.header('Porter') .. chat.error('Note that you are not currently in range of a nomad moogle or in the mog house.'))
    end
end

function prep:RetrieveItem(container, index, id)
    local item = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(container, index);
    if CanMove(item) then
        local packet = struct.pack('LLBBBB', 0, 1, container, 0, index, 0x52);
        AshitaCore:GetPacketManager():AddOutgoingPacket(0x29, packet:totable());
        print(chat.header('Porter') .. chat.message('Retrieving a ') .. chat.color1(2, AshitaCore:GetResourceManager():GetItemById(id).Name[1]) .. chat.message(' from ') .. chat.color1(2, containerNames[container + 1]) .. chat.message('.'));
    end
end

return prep;