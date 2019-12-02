#checks to see if player has item
#useage plugin::check_hasitem($client, itemid);
sub check_slot {
    my $client = shift;
    my $itemid = shift;

	my @slots = (0..30, 251..340, 2000..2023, 2030..2270, 2500..2501, 2531..2550, 9999);
	foreach $slot (@slots) {
		if ($client->GetItemIDAt($slot) == $itemid) {
			return $slot;
		}

		for ($i = 0; $i < 5; $i++) {
			if ($client->GetAugmentIDAt($slot, $i) == $itemid) {
				return $slot;
			}
		}
    }
	return 0;
}

sub find_container {
    my $client = shift;
    my $itemid = shift;

	my @slots = (22 .. 29);
	foreach $slot (@slots) {
		if ($client->GetItemIDAt($slot) == $itemid) {
			return $slot;
		}
    }
	return 0;
}

#plugin::collect_quest($client, itemid => count, itemid => count)
#Can do money amount as well.. example...
# ... plugin::collect_quest($client, 1001 => 5, 1002 => 2, "platinum" => 1, "gold" => 5, "silver" => 5, "copper" => 5)
# ...
#THE TAKEMONEYFROM PP ONLY WORKS UP TO 2,147,000~ platinum.. so be aware!

sub collect_quest {
    my $client = shift;
	my %required = @_;
	my $count_total = 0;
	my $stackable = 0;
	my $money_total = 0;
	
	my @slots = (22..29, 251..330);
	
	foreach my $req (keys %required) {
		$count_total = 0;
		
		if ($req =~/platinum/i) {
			$money_total += $required{$req} * 1000;
			next;
		} elsif ($req=~/gold/i) {
			$money_total += $required{$req} * 100;
			next;
		} elsif ($req =~/silver/i) {
			$money_total += $required{$req} * 10;
			next;
		}  elsif ($req =~/copper/i) {
			$money_total += $required{$req};
			next;
		}
		
		foreach $slot (@slots) {
			if ($client->GetItemIDAt($slot) == $req) {
				$stackable = $client->GetItemStat($req, "stackable");
				if($stackable) {
					$count_total+= $client->GetItemAt($slot)->GetCharges();
				} else {
					$count_total++;
				}
				
				#We have enough of this item.. stop checking..
				if($count_total >= $required{$req}) {
					last;
				}
			}
		}
		if ($count_total < $required{$req} || $count_total == 0) {
			#We failed this check.. return 0
			plugin::collect_quest_failed($client, %required);
			return 0;
		}
	}
	
	if ($money_total > 0) {
		if ($client->TakeMoneyFromPP($money_total, 1)) {
			plugin::collect_quest_remove($client, %required);
			return 1;
		} else {
			plugin::Whisper("You do not have enough money for this hand in!");
			return 0;
		}
	} else {
		plugin::collect_quest_remove($client, %required);
		return 1;
	}
}

sub collect_quest_remove {
    my $client = shift;
	my %required = @_;
	my $count_total = 0;
	my $stackable = 0;
	my $item_charges = 0;
	
	my @slots = (22..29, 251..330);
	
	foreach my $req (keys %required) {
		$count_total = 0;
		if ($req =~/platinum|gold|silver|copper/i) {
			next;
		}
		
		foreach $slot (@slots) {
			if ($client->GetItemIDAt($slot) == $req) {
				$stackable = $client->GetItemStat($req, "stackable");
				
				if($stackable) {
					$item_charges = $client->GetItemAt($slot)->GetCharges();
					if ($item_charges >= $required{$req}) {
						$client->DeleteItemInInventory($slot, $required{$req}, 1);
						$required{$req} = 0;
					}
					elsif($item_charges < $required{$req} && $item_charges > 0) {
						$client->DeleteItemInInventory($slot, $item_charges, 1);
						$required{$req}-= $item_charges;
					}
				} else {
				#non-stackable items must be 0 charges to remove the entire item
					$item_charges = 1;
					$client->DeleteItemInInventory($slot, 0, 1);
					$required{$req}-= $item_charges;
				}
				
				#We removed enough of the item.. jump to next item!
				if ($required{$req} <= 0) {
					last;
				}
			}
		}
	}
}

#Called when they are missing required items...
sub collect_quest_failed {
	my $client = shift;
	my %required = @_;
	my $count_total = 0;
	my $stackable = 0;
	
	my @slots = (22..29, 251..330);
	
	$client->Message(335, "Missing required items!");
	foreach my $req (keys %required) {
		$count_total = 0;
		
		if ($req =~/platinum|gold|silver|copper/i) {
			next;
		}
		
		foreach $slot (@slots) {
			if ($client->GetItemIDAt($slot) == $req) {
				$stackable = $client->GetItemStat($req, "stackable");
				if($stackable) {
					$count_total+= $client->GetItemAt($slot)->GetCharges();
				} else {
					$count_total++;
				}
				
				#We have enough of this item.. stop checking..
				if($count_total >= $required{$req}) {
					last;
				}
			}
		}
		
		if ($count_total < $required{$req} || $count_total == 0) {
			$client->Message(335,"" . $required{$req} . "x " . quest::varlink($req) . " you have  " . $count_total);
		}
	}
}


#plugin::collect_quest_remove($client, itemid, amountcheck)
#sub collect_quest_remove {
#    my $client = shift;
#    my $itemid = shift;
#	my $count = shift;
#	my $item_charges;
#	my $stackable = 0;
#	
#	#Ignore cursor / cursor bags Slots 30 / 331-340
#	my @slots = (22..29, 251..330);
#	foreach $slot (@slots) {
#		if ($client->GetItemIDAt($slot) == $itemid) {
#			$stackable = $client->GetItemStat($itemid, "stackable");
#			
#			#stackable items must remove charges...
#			if($stackable) {
#				$item_charges = $client->GetItemAt($slot)->GetCharges();
#				if ($item_charges >= $count) {
#					$client->DeleteItemInInventory($slot, $count, 1);
#					$count = 0;
#				}
#				elsif($item_charges < $count && $item_charges > 0) {
#					$client->DeleteItemInInventory($slot, $item_charges, 1);
#					$count-= $item_charges;
#				}
#			} else {
#			#non-stackable items must be 0 charges to remove the entire item
#				$item_charges = 1;
#				$client->DeleteItemInInventory($slot, 0, 1);
#				$count-= $item_charges;
#			}
#		}
#		if($count <= 0) {
#			return 1;
#		}
#    }
#	return 0;
#}

sub summon_into_inventory {
	my $client = shift;
	my $itemid = shift;
	my $amount = shift;
	
	my $stackable = $client->GetItemStat($itemid, "stackable");
	my $stack_size = $client->GetItemStat($itemid, "stacksize");
	my $item_charges = 0;
	
	my @slots = (22..29, 251..330);
	
	#If stackable.. lets find spots where it will fit current stacks already in place...
	if($stackable) {
		foreach $slot (@slots) {
			if ($client->GetItemIDAt($slot) == $itemid) {
				#stackable items must remove charges...
					$item_charges = $client->GetItemAt($slot)->GetCharges();
					if ($item_charges < $stack_size) {
						my $stack_diff = $stack_size - $item_charges; #How many can fit in this current stack...
						my $added_amount = 0;
						
						if ($amount > $stack_diff) {
							$added_amount = $stack_diff;
						} else {
							$added_amount = $amount;
						}
						#SummonItem(THIS, item_id, charges=0, attune=0, aug1=0, aug2=0, aug3=0, aug4=0, aug5=0, slot_id=30)
						$client->SummonItem($itemid, $item_charges + $added_amount, 0, 0, 0, 0, 0, 0, $slot);
						$amount -= $added_amount;
					}
			}
			if($amount <= 0) { #We finished brah
				return;
			}
		}
	}
	
	#Now we place the rest of the items into open slots..
	
	foreach $slot (@slots) {
		my $check_bag = 0;
		#Slots 251 -330 require a bag in the correct slot..
		if ($slot >= 251 && $slot <= 260) {
			$check_bag = 22;
		} elsif ($slot >= 261 && $slot <= 270) {
			$check_bag = 23;
		} elsif ($slot >= 271 && $slot <= 280) {
			$check_bag = 24;
		} elsif ($slot >= 281 && $slot <= 290) {
			$check_bag = 25;
		} elsif ($slot >= 291 && $slot <= 300) {
			$check_bag = 26;
		} elsif ($slot >= 301 && $slot <= 310) {
			$check_bag = 27;
		} elsif ($slot >= 311 && $slot <= 320) {
			$check_bag = 28;
		} elsif ($slot >= 321 && $slot <= 330) {
			$check_bag = 29;
		}
		
		if ($check_bag > 0) {
			if ($client->GetItemIDAt($check_bag) == -1) {
				#No bag here.. skip slot..
				next;
			} else {
				#There is an item here.. check if its a bag..
				my $bag_slots = $client->GetItemStat($client->GetItemIDAt($check_bag), "bagslots");
				if ($bag_slots > 0) {
					#This is a bag.. zomg.. see if the slot is valid..
					my $max_slot = (($check_bag * 10) + 30) + $bag_slots;
					if ($slot > $max_slot) {
						next; #This slot is not valid with this bag size...
					} else {
						#We are in a valid slot... check bag size...
						my $bag_size = $client->GetItemStat($client->GetItemIDAt($check_bag), "bagsize");
						my $item_size = $client->GetItemStat($itemid, "size");
						if ($item_size > $bag_size) {
							next; #This slit is not valid.. as this bag is too small
						}
					}
				} else {
					next; #This item is not a bag.. do not check this slot..
				}
			}
		}
		
		if ($client->GetItemIDAt($slot) == -1) {
			if ($stackable) {
				if ($stack_size > $amount) {
					$client->SummonItem($itemid, $amount, 0, 0, 0, 0, 0, 0, $slot);
					$amount = 0;
				} elsif ($amount >= $stack_size) {
					$client->SummonItem($itemid, $stack_size, 0, 0, 0, 0, 0, 0, $slot);
					$amount -= $stack_size;
				}
			} else {
				$client->SummonItem($itemid, 1, 0, 0, 0, 0, 0, 0, $slot);  #Charged items.. would have to be handled differently..
				$amount--;
			}
		}
		if($amount <= 0) { #We finished brah
				return;
		}
	}
	
	#NO MORE VALID SLOTS... time to summon the rest to cursor...
	if ($amount > 0) {
		while ($amount > 0) {
			if ($stackable) {
				if ($stack_size > $amount) {
					$client->SummonItem($itemid, $amount);
					$amount = 0;
				} elsif ($amount >= $stack_size) {
					$client->SummonItem($itemid, $stack_size);
					$amount -= $stack_size;
				}
			} else {
				$client->SummonItem($itemid, 1);
				$amount--;
			}
		}
	}
	return;
}

###Test shit
sub RecipeHash {
    my %recipehash = (
    7870 => { #recipe_id
    "text" => "copper ingots", #text for resulting item ID
    "result" => 1001, #common result
    "qty" => 12,
    "uncommonresult" => 1002, #uncommon result
    "uncommontext" => "sand", #text for rare item
    "uncommonchance" => 35, #chance of obtaining this result
    "uncommonqty" => 20,
    "rareresult" => 1003,
    "raretext" => "manastone",
    "rarechance" => 10,
    "rareqty" => 12,
    "urareresult" => 1004,
    "uraretext" => "silver breastplate",
    "urarechance" => 10,
    "urareqty" => 1,
    "epicresult" => 1005,
    "epictext" => "bag of foreign money",
    "epicchance" => 5,
    "epicqty" => 1,
    "legendaryresult" => 1006,
    "legendarytext" => "gold ingot",
    "legendarychance" => 1,
    "legendaryqty" => 1,
    },
    );
    return %recipehash;
}
 
sub HasRecipe {
    my %recipehash = RecipeHash();
    return (defined $recipehash{$_[0]} ? 1 : 0);
}
 
 
sub GetRecipeData {
    my %recipehash = RecipeHash();
    return (defined $recipehash{$_[0]} && defined $recipehash{$_[0]}{$_[1]} ? $recipehash{$_[0]}{$_[1]} : 0);
}



1;