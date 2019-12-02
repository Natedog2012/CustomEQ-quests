sub UpgradeItem {
	my $client = plugin::val('$client');
	my $yel = plugin::PWColor("Yellow");
	my $gold = plugin::PWColor("Goldenrod");
	my $red = plugin::PWColor("Red");
	my $orange = plugin::PWColor("Orange");
	my $break = ("---------------------------------------");
	my $indent = plugin::PWIndent();
	my $item_name1 = "";
	my $item_name2 = "";
	my $percentage = 0;
	my %first_slot = (
		22 => 251,
		23 => 261,
		24 => 271,
		25 => 281,
		26 => 291,
		27 => 301,
		28 => 311,
		29 => 321
	);
	my %upgrade_items = (
	 #rank	#itemid	 #count	 #chance
		0 => [13006, 5, 80],
		1 => [13006, 5, 70],
		2 => [13006, 5, 60],
		3 => [13006, 5, 50],
		4 => [13006, 5, 40],
		5 => [13006, 5, 35],
		6 => [13006, 5, 30],
		7 => [13006, 5, 25],
		8 => [13006, 5, 20]
	);
	
	my $bag_slot = plugin::find_container($client,17021);
	if(!$bag_slot) { return; }
	#$client->Message(335, "Bag is in slot $bag_slot");
	my $item1 = $client->GetItemAt($first_slot{$bag_slot});
	my $item2 = $client->GetItemAt($first_slot{$bag_slot} + 1);
	my $item_id1 = 0;
	my $item_id2 = 0;
	my $ITEMNAME1 = "";
	my $ITEMNAME2 = "";
	my $rank = "";
	
	if($item1 && $item2) {
		$item_id1 = $item1->GetID();
		$item_id2 = $item2->GetID();
		$ITEMNAME1 = $item1->GetName();
		$ITEMNAME2 = $item2->GetName();
		#$client->Message(335, "$item_id1 Item1: " . $item1->GetName() . " $item_id2 Item2: " . $item2->GetName());
		$item_name1 = substr($item1->GetName(), -2);
		$rank = substr($item_name1, -1);
		
		if($item_name1 =~/\+9/i) {
			$client->Message(13, "This item is fully upgraded");
			return;
		} elsif ($item_name1 =~/\+6|\+7|\+8/i) {
			if($item_id2 == $upgrade_items{$rank}[0] && $item2->GetCharges() >= $upgrade_items{$rank}[1]) {
				$percentage = $upgrade_items{$rank}[2];
			}
		} elsif ($item_name1 =~/\+3|\+4|\+5/i) {
			if($item_id2 == $upgrade_items{$rank}[0] && $item2->GetCharges() >= $upgrade_items{$rank}[1]) {
				$percentage = $upgrade_items{$rank}[2];
			}
		} elsif ($item_name1 =~/\+0|\+1|\+2/i) {
			if($item_id2 == $upgrade_items{$rank}[0] && $item2->GetCharges() >= $upgrade_items{$rank}[1]) {
				$percentage = $upgrade_items{$rank}[2];
			}
		}
		
		if($percentage > 0) {
			quest::popup("Would you like to upgrade?","$yel Item to Upgrade:</c> $ITEMNAME1 <br>
						 $yel Material Required:</c> $ITEMNAME2 <br>
						 $yel Material Amount Required:</c> $upgrade_items{$rank}[1] <br>
						 $orange You have a $percentage% chance to upgrade this item.</c> <br>
						 $break <br>
						 $red !!!! DISCLAIMER !!!! </c> Please make sure all augments are removed from the item as they will $red NOT </c> be returned
						 if the item successfully upgrades. Any tinkered effects will be lost. <br><br><br>
						 $gold Click 'Yes' to attempt to upgrade your item.
						 ",10006,1,0);
		} else {
			$client->Message(13, "Items do not match.");
		}
	} else {
		$client->Message(13, "Items missing from container.");
	}
}

sub UpgradeItemConfirm {
	my $client = plugin::val('$client');
	my $item_name1 = "";
	my $item_name2 = "";
	my $percentage = 0;
	my %first_slot = (
		22 => 251,
		23 => 261,
		24 => 271,
		25 => 281,
		26 => 291,
		27 => 301,
		28 => 311,
		29 => 321
	);
	my %upgrade_items = (
	 #rank	#itemid	 #count	 #chance
		0 => [13006, 5, 80],
		1 => [13006, 5, 70],
		2 => [13006, 5, 60],
		3 => [13006, 5, 50],
		4 => [13006, 5, 40],
		5 => [13006, 5, 35],
		6 => [13006, 5, 30],
		7 => [13006, 5, 25],
		8 => [13006, 5, 20]
	);
	
	my $bag_slot = plugin::find_container($client,17021);
	if(!$bag_slot) { return; }
	#$client->Message(335, "Bag is in slot $bag_slot");
	my $item1 = $client->GetItemAt($first_slot{$bag_slot});
	my $item2 = $client->GetItemAt($first_slot{$bag_slot} + 1);
	my $item_id1 = 0;
	my $item_id2 = 0;
	my $ITEMNAME1 = "";
	my $ITEMNAME2 = "";
	my $charges = 0;
	my $aug1 = 0;
	my $aug2 = 0;
	my $aug3 = 0;
	my $aug4 = 0;
	my $aug5 = 0;
	my $rank = "";
	
	if($item1 && $item2) {
		$item_id1 = $item1->GetID();
		$item_id2 = $item2->GetID();
		$ITEMNAME1 = $item1->GetName();
		$ITEMNAME2 = $item2->GetName();
		#$client->Message(335, "$item_id1 Item1: " . $item1->GetName() . " $item_id2 Item2: " . $item2->GetName());
		$item_name1 = substr($item1->GetName(), -2);
		$rank = substr($item_name1, -1);
		#$client->Message(335, "substr is $item_name1");
		
		if($item_name1 =~/\+9/i) {
			$client->Message(13, "This item is fully upgraded");
			return;
		} elsif ($item_name1 =~/\+6|\+7|\+8/i) {
			if($item_id2 == $upgrade_items{$rank}[0] && $item2->GetCharges() >= $upgrade_items{$rank}[1]) {
				$percentage = $upgrade_items{$rank}[2];
				$charges = $upgrade_items{$rank}[1];
			}
		} elsif ($item_name1 =~/\+3|\+4|\+5/i) {
			if($item_id2 == $upgrade_items{$rank}[0] && $item2->GetCharges() >= $upgrade_items{$rank}[1]) {
				$percentage = $upgrade_items{$rank}[2];
				$charges = $upgrade_items{$rank}[1];
			}
		} elsif ($item_name1 =~/\+0|\+1|\+2/i) {
			if($item_id2 == $upgrade_items{$rank}[0] && $item2->GetCharges() >= $upgrade_items{$rank}[1]) {
				$percentage = $upgrade_items{$rank}[2];
				$charges = $upgrade_items{$rank}[1];
			}
		}
		
		if($percentage > 0) {
			my $random = int(rand(100)+1);
			if ($random <= $percentage) {
				$aug1 = $client->GetAugmentIDAt($first_slot{$bag_slot}, 0) > 0 && $client->GetAugmentIDAt($first_slot{$bag_slot}, 0) < 2000000 ? $client->GetAugmentIDAt($first_slot{$bag_slot}, 0) : 0;
				$aug2 = $client->GetAugmentIDAt($first_slot{$bag_slot}, 1) > 0 && $client->GetAugmentIDAt($first_slot{$bag_slot}, 1) < 2000000 ? $client->GetAugmentIDAt($first_slot{$bag_slot}, 1) : 0;
				$aug3 = $client->GetAugmentIDAt($first_slot{$bag_slot}, 2) > 0 && $client->GetAugmentIDAt($first_slot{$bag_slot}, 2) < 2000000 ? $client->GetAugmentIDAt($first_slot{$bag_slot}, 2) : 0;
				$aug4 = $client->GetAugmentIDAt($first_slot{$bag_slot}, 3) > 0 && $client->GetAugmentIDAt($first_slot{$bag_slot}, 3) < 2000000 ? $client->GetAugmentIDAt($first_slot{$bag_slot}, 3) : 0;
				$aug5 = $client->GetAugmentIDAt($first_slot{$bag_slot}, 4) > 0 && $client->GetAugmentIDAt($first_slot{$bag_slot}, 4) < 2000000 ? $client->GetAugmentIDAt($first_slot{$bag_slot}, 4) : 0;
				
				$client->DeleteItemInInventory($first_slot{$bag_slot},0,1);
				$client->DeleteItemInInventory($first_slot{$bag_slot} + 1,$charges,1);
				$client->SummonItem($item_id1 + 1, 1, 0, $aug1, $aug2, $aug3, $aug4, $aug5, $first_slot{$bag_slot});
				$client->Message(15,"Upgrade Succeeded. Congratulations on your new " . quest::varlink($item_id1 +1) ."!");
			} else {
				$client->DeleteItemInInventory($first_slot{$bag_slot} + 1,$charges,1);
				$client->Message(15, "Upgrade failed.");
			}
		} else {
			$client->Message(13, "Items do not match.");
		}
	} else {
		$client->Message(13, "Items missing from container.");
	}
}

# AddLoot(amount, chance, @itemarray) 
 sub AddLoot {
	my $amount = shift;   #Number of times to try the items (4 = Up to 4 items)
	my $chance = shift;   #Chance out of ... (500 =  1 out of 500)
	my @itemdrop = @_;	  #Array of items sent to the plugin
	
	
	#Set to 2 for double lootz!
	my $Double_Loot = 1;
	
	for($n = 1; $n <= $amount; $n++)
	{
		for($i = 1; $i <= $Double_Loot; $i++) 
		{
			my $random_number = int(rand($chance)+1);
			if($random_number <= 1)
			{
				my $itemz = $itemdrop[ rand @itemdrop ];
				quest::addloot($itemz, 1);
			}
		}
	}
}

sub TrainDiscs {
	my $client = plugin::val('$client');
	my $class = plugin::val('$class');
	my $level1 = $_[0] ? $_[0] : $client->GetLevel();
	my $level2 = $_[1] ? $_[1] : $client->GetLevel();
	#my %discs = (
	#	"Warrior" => [4688, 6750]
	#);
	#for(0 .. (@{$discs{$class}}-1)) {
	#	$client->TrainDiscBySpellID($discs{$class}[$_]);
	#}
	my $types = "none";
	if ($class eq "Warrior") {
		$types = "classes1";
	} elsif ($class eq "Rogue") {
		$types = "classes9";
	} elsif ($class eq "Monk") {
		$types = "classes7";
		$client->Message(335, "We are a monk");
	} elsif ($class eq "Berskerer") {
		$types = "classes16";
	}
	
	
	my $dbh = plugin::LoadMysql();
	my $sth = $dbh->prepare("SELECT id FROM spells_new WHERE `$types` >= $level1 and `$types` <= $level2");
	$sth->execute();
	while (@row = $sth->fetchrow_array()) {
		$client->TrainDiscBySpellID($row[0]);
	}
}

sub TrainSpells {
	my $client = plugin::val('$client');
	my $class = plugin::val('$class');
	my $level1 = $_[0] ? $_[0] : $client->GetLevel();
	my $level2 = $_[1] ? $_[1] : $client->GetLevel();
	#my %spells = (
	#	"Cleric" => [11]
	#);
	#for(0 .. (@{$spells{$class}}-1)) {
	#	$client->ScribeSpell($spells{$class}[$_], $client->GetFreeSpellBookSlot());
	#}
	
	my $type = "none";
	if ($class eq "Cleric") {
		$types = "classes2";
	} elsif ($class eq "Paladin") {
		$types = "classes3";
	} elsif ($class eq "Ranger") {
		$types = "classes4";
	} elsif ($class eq "Shadowknight") {
		$types = "classes5";
	} elsif ($class eq "Druid") {
		$types = "classes6";
	} elsif ($class eq "Bard") {
		$types = "classes8";
	} elsif ($class eq "Shaman") {
		$types = "classes10";
	} elsif ($class eq "Necromancer") {
		$types = "classes11";
	} elsif ($class eq "Wizard") {
		$types = "classes12";
	} elsif ($class eq "Mage") {
		$types = "classes13";
	} elsif ($class eq "Enchanter") {
		$types = "classes14";
	} elsif ($class eq "Beastlord") {
		$types = "classes15";
	}
	
	
	my $dbh = plugin::LoadMysql();
	my $sth = $dbh->prepare("SELECT id FROM spells_new WHERE `$types` >= $level1 and `$types` <= $level2");
	$sth->execute();
	while (@row = $sth->fetchrow_array()) {
		$client->ScribeSpell($row[0], $client->GetFreeSpellBookSlot());
	}
}

1;