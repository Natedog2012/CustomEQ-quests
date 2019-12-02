local custom = {}

function custom.summon_into_inventory(client, itemid, amount)
	local myitem = Item(itemid);
	local stackable = myitem:Stackable();
	local stacksize = myitem:StackSize();
	local item_charges = 0;
	local slot = 30;
	local item_size = myitem:Size()
	local my_inv = client:GetInventory();
	local is_bag = (myitem:BagSlots() > 0 and true or false);
	
	if (client:GetClientVersion() >= 6) then
		is_bag = false; --RoF++ bags can go inside other bags
	end
	
	if (stackable) then
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

return custom;