local CustomItems = {}

function CustomItems.summon_into_inventory(client, itemid, amount)
	local myitem = Item(itemid);
	local stackable = myitem:Stackable();
	local stacksize = myitem:StackSize();
	local item_charges = 0;
	local slot = 30;
	local item_size = myitem:Size()
	local my_inv = client:GetInventory();
	local slots = inventory_list();
	local is_bag = (myitem:BagSlots() > 0 and true or false);
	
	if (client:GetClientVersion() >= 6) then
		is_bag = false; --RoF++ bags can go inside other bags
	end
	
	if (stackable) then
		for i, slot in pairs(slots) do
			if (client:GetItemIDAt(slot) == itemid) then
				item_charges = my_inv:GetItem(slot):GetCharges();
				if (item_charges < stacksize) then
					local stack_diff = stacksize - item_charges;
					local added_amount = 0;
					
					if (amount > stack_diff) then
						added_amount = stack_diff;
					else
						added_amount = amount;
					end
					client:SummonItem(itemid, (added_amount + item_charges), 0, 0, 0, 0, 0, false, slot);
					amount = amount - added_amount;
				end
			end
			if (amount <= 0) then
				return; --we are finished...
			end
		end
		--Now we summon into FreeInventory spaces
		if (amount > stacksize) then
			local remaining = math.mod(amount, stacksize);
			--Summon the amount of full stacks first..
			for i = 1, math.floor(amount/stacksize) do
				slot = my_inv:FindFreeSlot(is_bag, true, item_size);
				client:SummonItem(itemid, stacksize, 0, 0, 0, 0, 0, false, slot);
			end
			--Summon the remaining items
			if (remaining > 0) then
				slot = my_inv:FindFreeSlot(is_bag, true, item_size);
				client:SummonItem(itemid, remaining, 0, 0, 0, 0, 0, false, slot);
			end
		else
			--Just summon the full stack as its not greater than stacksize..
			slot = my_inv:FindFreeSlot(is_bag, true, item_size);
			client:SummonItem(itemid, amount, 0, 0, 0, 0, 0, false, slot);
		end
	else
		for i = 1, amount do
			slot = my_inv:FindFreeSlot(is_bag, true, item_size);
			client:SummonItem(itemid, 1, 0, 0, 0, 0, 0, false, slot);
		end
	end
end

--Generate Inventory table..
--my @slots = (22..29, 251..330);
function inventory_list()
	local inv_list = {};
	
	for i = 22, 29 do
		table.insert(inv_list, i);
	end
	
	for i = 251, 330 do
		table.insert(inv_list, i);
	end
	
	return inv_list;
end

function CustomItems.collect_quest(client, required)
	
	local slots = inventory_list();
	local count_total = 0;
	local stackable = false;
	local money_total = 0;
	
	local curr_item;
	local my_inv = client:GetInventory();
	
	for key, value in pairs(required) do
		count_total = 0; --Reset count for each item..
		if (type(key) == "string") then 
			if (key:findi("platinum")) then
				money_total = money_total + (value[1] * 1000);
			elseif (key:findi("gold")) then
				money_total = money_total + (value[1] * 100);
			elseif (key:findi("silver")) then
				money_total = money_total + (value[1] * 10);
			elseif (key:findi("copper")) then
				money_total = money_total + (value[1]);
			end
		end
		
		--ITEM CHECK
		if (type(key) == "number") then
			curr_item = Item(key);
			stackable = curr_item:Stackable();
			-- INVENTORY LOOP
			for i, slot in pairs(slots) do
				if (client:GetItemIDAt(slot) == key) then
					if (stackable) then
						count_total = count_total + my_inv:GetItem(slot):GetCharges();
					else
						count_total = count_total + 1;
					end
				end
				
				if (count_total >= value[1]) then
					break; -- Jump from this check...
				end
			end
			-- INVENTORY LOOP
			if (count_total < value[1]) then
				collect_quest_failed(client, required);
				return false;
			end
		end --ITEM CHECK
	end -- Item Loop
	
	--If we make it here we have all the Items...
	if (money_total > 0) then
		if (client:TakeMoneyFromPP(money_total, true)) then
			quest_collect_remove(client, required);
			return true;
		else
			client:Message(335, "You are missing the required money!");
			return false;
		end
	else
		quest_collect_remove(client, required);
		return true;
	end
	
	return false; --We shouldn't hit this.. but if we do.. they failed
end

function quest_collect_remove(client, required)
	local slots = inventory_list();
	local stackable = false;
	local money_total = 0;
	
	local curr_item;
	local my_inv = client:GetInventory();
	local item_charges = 0;
	
	for key, value in pairs(required) do
		--ITEM CHECK
		if (type(key) == "number") then
			curr_item = Item(key);
			stackable = curr_item:Stackable();
			-- INVENTORY LOOP
			for i, slot in pairs(slots) do
				if (client:GetItemIDAt(slot) == key) then
					if (stackable) then
						item_charges = my_inv:GetItem(slot):GetCharges();
						if (item_charges >= value[1]) then
							client:DeleteItemInInventory(slot, value[1], true);
							value[1] = 0;
						else
							client:DeleteItemInInventory(slot, item_charges, true);
							value[1] = value[1] - item_charges;
						end
					else
						item_charges = 1;
						client:DeleteItemInInventory(slot, 0, true);
						value[1] = value[1] - 1;
					end
				end
				
				if (value[1] <= 0) then
					break; -- Jump from this check...
				end
			end
			-- INVENTORY LOOP
		end --ITEM CHECK
	end -- Item Loop
end

function collect_quest_failed(client, required)
	local slots = inventory_list();
	local count_total = 0;
	local stackable = false;
	local money_total = 0;
	
	local curr_item;
	local my_inv = client:GetInventory();
	
	client:Message(335, "Missing required items!");
	for key, value in pairs(required) do
		count_total = 0; --Reset count for each item..		
		--ITEM CHECK
		if (type(key) == "number") then
			curr_item = Item(key);
			stackable = curr_item:Stackable();
			-- INVENTORY LOOP
			for i, slot in pairs(slots) do
				if (client:GetItemIDAt(slot) == key) then
					if (stackable) then
						count_total = count_total + my_inv:GetItem(slot):GetCharges();
					else
						count_total = count_total + 1;
					end
				end
				
				if (count_total >= value[1]) then
					break; -- Jump from this check...
				end
			end
			-- INVENTORY LOOP
			if (count_total < value[1] or count_total == 0) then
				client:Message(335, value[1] .. "x " .. eq.item_link(key) .. " you have " .. count_total .. ".");
			end
		end --ITEM CHECK
	end -- Item Loop
end


--[[
chance == chance for loottable to be picked to drop if this fails.. the loottable is skipped!
loot_table == table of items... example below has ITEMID, item drop chance and charges!
droplimit == max number of drops from table.. if that number is hit it will stop trying to addloot .. this number is increased by double_loot value!
mindrop == min number of drops from table.. will keep trying till this number is reached .. this number is increased by double_loot value!

-- 50 chance for loottable and 1 chance for item would result in  1 / 200 drop chance!
-- 10 chance for loottable and 1 chance for item would result in  1 / 1000 drop chance! (.1 * 0.01)
-- 1 chance for loottable and 1 chance for item would result in 1 / 10,000 drop chance! (0.01 * 0.01)
-- the Debug will tell you the chance of drop if turned on
-- If mindrop is set.. as it loops the chance to drop INCREASES to lower the number of itterations needed to meet the required drop amount!

EXAMPLE:
function event_spawn(e)
	local CustomItems = require("custom_items");
	local loot_table = {
		[1001] = {1},  -- [itemid] = {chance_item, charges, equip(0,1)}
		[1002] = {1},
		[1003] = {1},
		[1004] = {1},
		[13005] = {1, 5},
		[13006] = {1},
	};
	e.self:AddLoot(50, loot_table, 1, 0);
end
--]]
function NPC:AddLoot(chance, loot_table, droplimit, mindrop)
	local qdebug = false;
	local double_loot = 1;
	local dropped = 0;
	local curr_item = 0;
	local stack_count = 0;
	local loop_count = 0;
	if(droplimit == nil) then droplimit = 0; end
	if(mindrop == nil) then mindrop = 0; end
	local do_loop = (mindrop > 0 and true) or false; -- NoLoop true
	local equip_item = false;
	local loot_slots = 0;
		
	droplimit = droplimit * double_loot;
	mindrop = mindrop * double_loot;
	
	local add_table = math.random(100);
	if (add_table > chance) then return; end -- We must roll lower than the chance
	
	local items = {};
	for key, value in pairs(loot_table) do
		table.insert(items, key);
	end
	
	
	repeat
		loop_count = loop_count + 1;
		for i = 1, double_loot do
			--Sort Items randomly to make for more random loot  (re-randomizes after a Double_loot call)
			for i = table.maxn(items), 2, -1 do -- backwards
				local r = math.random(i) -- select a random number between 1 and i
				items[i], items[r] = items[r], items[i] -- swap the randomly selected item to position i
			end 
		
			for g, itemid in pairs(items) do
				if (math.random(100) <= (loot_table[itemid][1] + (loop_count - 1))) then
					curr_item = Item(itemid);
					if (curr_item:Slots() > 0) then
						if (loot_table[itemid][3] == nil) then
							equip_item = false;
						elseif (loot_table[itemid][3] > 0) then
							equip_item = true;
						end
					end
					stack_count = loot_table[itemid][2];
					if(stack_count == nil or stack_count == 0) then stack_count = 1; end --Make sure we have at least 1
					--if (qdebug) then self:Shout("EntID: " .. self:GetID() .. " ItemID: " .. itemid .. " chance: 1 / " .. (1/((chance / 100) *(loot_table[itemid][1]/100))) .. " mindrop: " .. mindrop .. " droplimit: " .. droplimit) end
					if (qdebug) then eq.GMSay("EntID: " .. self:GetID() .. " ItemID: " .. itemid .. " chance: 1 / " .. (1/((chance / 100) *(loot_table[itemid][1]/100))) .. " mindrop: " .. mindrop .. " droplimit: " .. droplimit .. " equiped: " .. (equip_item and '1' or '0'), 315); end
					dropped = dropped + 1;
					if (curr_item:Stackable() or curr_item:MaxCharges() > 0) then
							self:AddItem(itemid, stack_count, equip_item);
					else
						--Multiple of a stackable item...
						for m = 1, stack_count do
							self:AddItem(itemid, 1, equip_item);
						end
					end
					--Check if we exceed the drop limit
					if (droplimit > 0 and dropped >= droplimit) then return; end
				end
			end
		end
		if (loop_count >= 100) then return; end -- Loop limit incase your loottables are dumb as fuuuck
	until ((dropped >= mindrop and mindrop > 0) or do_loop == false)
end


return CustomItems;