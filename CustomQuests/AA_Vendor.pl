#############################
####### AA Merchant #########
### Created by : NatedogEZ ##
#############################
sub ITEMLIST {
# ItemID -> Cost -> TXT REMINDER OF ITEM -> Slot type -> Stack Size (1 default higher number for items with charges or stackables)
# Slot type //1 = Plate // 2= Cloth // 3 = Leather // 4 = Chain // 5 = Accessory // 6 = Novelty // 7 = Expendable // 8 = Weapons
	%IL = (
	1 => [4201, 5, "Bronze Helm", 1, 1],
	2 => [4202, 5, "Bronze Mask", 5, 1],
	3 => [4203, 5, "Bronze Collar", 5, 1],
	4 => [4204, 5, "Bronze Breastplate", 1, 1],
	5 => [4205, 5, "Bronze Pauldron", 5, 1],
	6 => [9662, 2, "Misty Thicket Picnic", 7, 20],
	7 => [61993, 2, "Honeyed Qeynos Afternoon Tea", 7, 20],
	8 => [2956, 5888, "Short Sword of Flame", 8, 1]
	);
}

sub EVENT_SAY
{
ITEMLIST(); #Load itemlist
my %typetext = (
		1 => "Plate",
		2 => "Cloth",
		3 => "Leather",
		4 => "Chain",
		5 => "Accessory",
		6 => "Novelty",
		7 => "Expendable",
		8 => "Weapons"
		);
my $empty = $client->GetItemIDAt(quest::getinventoryslotid("cursor"));   #Check cursor for an itemID will be HUGE number if INVALID or no item
my $total = $client->GetAAPoints();
my $plate = quest::saylink("Type 1",1,"Plate"); #1
my $cloth = quest::saylink("Type 2",1, "Cloth"); #2
my $leather = quest::saylink("Type 3",1,"Leather"); #3
my $chain = quest::saylink("Type 4",1,"Chain"); #4
my $accessory = quest::saylink("Type 5",1,"Accessory"); #5
my $novelty = quest::saylink("Type 6",1,"Novelty");#6
my $expendable = quest::saylink("Type 7",1,"Expendable");  #7
my $weapons = quest::saylink("Type 8",1,"Weapons");  #8

	if($text=~/Hail/i)
    {
		#$itemsid = undef;
		#$itemcost = undef;
		plugin::Whisper("Hi there $name do you want to browse my items?");
		$client->Message(315, "[$plate] || [$cloth] || [$leather] || [$chain] || [$accessory] || [$novelty] || [$expendable] || [$weapons]");
	}
	elsif($text=~/^Type /i)
	{
		my $n = 1;
		my $TYPE = substr($text, 5);
		if($TYPE == 0 || $TYPE > 8) {$client->Message(13, "Invalid type!"); return;}
		$client->Message(315, "==== $typetext{$TYPE} items ===");
		$client->Message(315, " ");	
			while ($IL{$n}[0])
			{
				my $typeslot = $IL{$n}[3];
				if($typeslot==$TYPE)
				{
					my $itemlink = quest::varlink($IL{$n}[0]);
					my $saylink = quest::saylink("Buy $n",1,"Buy");
					my $cost = int($IL{$n}[1]);
					my $stack = int($IL{$n}[4]);
					$client->Message(315, "$saylink >for $cost AA points > $itemlink x $stack");
					$client->Message(315, " ");				
				}
				$n++;
			}
		$client->Message(315, "=============");
		$client->Message(315, "[$plate] || [$cloth] || [$leather] || [$chain] || [$accessory] || [$novelty] || [$expendable] || [$weapons]");
		$client->Message(315, " ");	
	}
	######## Item Saylink Start
	elsif($text=~/^buy /i)
	{
		my $Indent = plugin::PWIndent();
		my @BUY =  split / /, substr($text, 4);
		if(!$IL{$BUY[0]}[0]) {$client->Message(13, "Invalid buy request!"); return;}
		if($client->GetItemStat($IL{$BUY[0]}[0], "loregroup") != 0 && plugin::check_hasitem($client, $IL{$BUY[0]}[0])) {$client->Message(13, "ERROR: Lore conflict you may not buy a Lore item you already possess!"); return;}
		my $cost = int($IL{$BUY[0]}[1]);
		my $createitem = $IL{$BUY[0]}[0];
		my $itemlink = quest::varlink($IL{$BUY[0]}[0]);
		my $stack = int($IL{$BUY[0]}[4]);
		if($empty == -1)   #Checks the cursor itemID to see if its valid returns a huge number for invalid
		{
			if($total >= $cost)         #Cost of the item
			{
				$client->SetEntityVariable("BUYID", $BUY[0]);
				quest::popup("Buy $IL{$BUY[0]}[2]?",                     
                                "<br>$Indent Item:<c \"#00FFFF\"> $IL{$BUY[0]}[2] </c> QTY $IL{$BUY[0]}[4]<br>
                               
                               &nbsp;&nbsp;&nbsp;&nbsp; [ <c \"#FFFF00\">Yes</c> ] to confirm
                                $Indent [ <c \"#FFFF00\">No</c> ] to choose again ", 10002, 1, 0);
			}
			else 
			{
				plugin::Whisper("You need " . ($cost-$total) . " more AA points for $itemlink.");  #Player did not have enough AA
			}
		}
		else
		{
			plugin::Whisper("You are holding an item please put it in your bags before you buy something."); #Player is holding an item already
		}		
	}
}

sub EVENT_POPUPRESPONSE {
	if($popupid == 10002)
	{
		ITEMLIST(); #Load itemlist
		my $empty = $client->GetItemIDAt(quest::getinventoryslotid("cursor"));
		my $total = $client->GetAAPoints();	
		my $BUY = $client->GetEntityVariable("BUYID");
		
		if(!$IL{$BUY}[0]) {$client->Message(13, "Invalid buy request!"); return;}
		my $cost = int($IL{$BUY}[1]);
		my $createitem = $IL{$BUY}[0];
		my $itemlink = quest::varlink($IL{$BUY}[0]);
		my $stack = int($IL{$BUY}[4]);
		if($empty == -1)   #Checks the cursor itemID to see if its valid returns a huge number for invalid
		{
			if($total >= $cost)         #Cost of the item
			{
				$total = int($total-$cost);     
				$client->SetAAPoints($total); 
				#Itemname
				quest::summonitem($createitem,$stack);  
				$client->Message(315, "You now have $total AA points to spend.");
			}
			else 
			{
				plugin::Whisper("You need more AA points for $itemlink.");  #Player did not have enough AA
			}
		}
		else
		{
			plugin::Whisper("You are holding an item please put it in your bags before you buy something."); #Player is holding an item already
		}
	}
}