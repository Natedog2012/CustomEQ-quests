sub ZoneTime {
	my $value = $_[0];
	if ($value =~/morning/i) {
		quest::UpdateZoneHeader("fog_green", "60");
		quest::UpdateZoneHeader("fog_blue", "200");
		quest::UpdateZoneHeader("fog_red", "60");
		quest::UpdateZoneHeader("fog_minclip", "900");
		quest::UpdateZoneHeader("fog_maxclip", "1800");
	}
	elsif ($value =~/day/i) {
		quest::UpdateZoneHeader("fog_green", "120");
		quest::UpdateZoneHeader("fog_blue", "255");
		quest::UpdateZoneHeader("fog_red", "120");
		quest::UpdateZoneHeader("fog_minclip", "1000");
		quest::UpdateZoneHeader("fog_maxclip", "2000");
	}
	elsif ($value =~/evening/i) {
		quest::UpdateZoneHeader("fog_green", "60");
		quest::UpdateZoneHeader("fog_blue", "127");
		quest::UpdateZoneHeader("fog_red", "60");
		quest::UpdateZoneHeader("fog_minclip", "600");
		quest::UpdateZoneHeader("fog_maxclip", "1200");
	}
	elsif ($value =~/night/i) {
		quest::UpdateZoneHeader("fog_green", "12");
		quest::UpdateZoneHeader("fog_blue", "25");
		quest::UpdateZoneHeader("fog_red", "12");
		quest::UpdateZoneHeader("fog_minclip", "150");
		quest::UpdateZoneHeader("fog_maxclip", "500");
	}
}

sub PersistentNimbus{
	$npc = plugin::val('$npc');
	$n = 0;
	while($_[$n]){ 
		$npc->SpellEffect($_[$n], 500, 0, 1, 3000, 1); 
		$npc->SetEntityVariable("PersistentNimbus_" . $n, $_[$n]);
		$n++;
	}
}

sub CheckDPS {
	my $client = plugin::val('$client');
	my $target = shift;
	if($target->EntityVariableExists("dpsvar") && $target->GetEntityVariable("dpsvar") > 0) {
		my $death = time();
		my $seconds = $death - $target->GetEntityVariable("dpsvar");
		my $dps;
		if($seconds == 0) {
			$seconds = 1;
		}
		$client->Message(261, "DPS for [" 
					. quest::saylink($target->GetCleanName(), 1) . "] lasted " 
					. $seconds . " seconds EST DPS [" 
					. quest::saylink(plugin::commify(sprintf '%.2f', (($target->GetMaxHP()-$target->GetHP()) / $seconds)),1) ."]");
		$client->Message(261, " ");
		$client->Message(261, "[" . quest::saylink("DPS LIST", 1) . "]");
		my @hatelist = $target->GetHateList();
		my $n = 0;
		foreach $ent (@hatelist) {
			my $h_ent = $ent->GetEnt();
			if($h_ent) {
				my $h_dmg = $ent->GetDamage();
				my $h_dmg2 = plugin::commify($ent->GetDamage());
				my $h_hate = plugin::commify($ent->GetHate());
				if($n <= 15) {
					my $h_ent_name = $h_ent->GetName();
					$client->Message(261, "$h_ent_name - DMG $h_dmg - HATE $h_hate - EST DPS [" . quest::saylink(plugin::commify(sprintf '%.2f', ($h_dmg / $seconds)),1) ."]" );
					$n++;
				}
			}
		}
	}
}

sub RecipeReward {
	my $dbh = plugin::LoadMysql();
	$sth = $dbh->prepare("SELECT `item_id` FROM tradeskill_recipe_entries WHERE `recipe_id` = ? AND `successcount` > 0 LIMIT 1"); $sth->execute($_[0]);
	return $sth->fetchrow_array();
}

sub RandomHateClient {
	my $npc = plugin::val('$npc');
	my @HATELIST = $npc->GetHateList();
	my @client_list = ();
	foreach $HATE (@HATELIST) {
		my $hate_target = $HATE->GetEnt();
		if($hate_target && $hate_target->IsClient()) {
			push(@client_list, $hate_target->GetID());
		}
	}
	my $RAND_PLAYER = quest::ChooseRandom(@client_list);
	return $RAND_PLAYER;
}

sub gmgearme2 {
	my $client = plugin::val('$client');
	my $text = plugin::val('$text');
	my $ulevel = $client->GetLevel();
	my $items_list;
	
	my $do_target = $_[0];
	my $do_augs = $_[1];
	
	if ($client->GetTarget() && $client->GetTarget()->IsClient() && $client->GetTarget()->GetName() eq "$do_target") {
		$client->Message(335, "Now gearing up $do_target");
		$client = $client->GetTarget()->CastToClient();
		$ulevel = $client->GetLevel();
	}
	
		my %racelist = (
		1 => 1,
		2 => 2,
		3 => 4,
		4 => 8,
		5 => 16,
		6 => 32,
		7 => 64,
		8 => 128,
		9 => 256,
		10 => 512,
		11 => 1024,
		12 => 2048,
		128 => 4096,
		130 => 8192,
		330 => 16384,
		522 => 65535
		);
		my %slots = (
		0 => 1,
		1 => 18,
		2 => 4,
		3 => 8,
		4 => 18,
		5 => 32,
		6 => 64,
		7 => 128,
		8 => 256,
		9 => 1536,
		10 => 1536,
		11 => 2048,
		12 => 4096,
		13 => 8192,
		14 => 16384,
		15 => 98304,
		16 => 98304,
		17 => 131072,
		18 => 262144,
		19 => 524288,
		20 => 1048576
		);
		my %classes = (
		1 => 1,
		2 => 2,
		3 => 4,
		4 => 8,
		5 => 16,
		6 => 32,
		7 => 64,
		8 => 128,
		9 => 256,
		10 => 512,
		11 => 1024,
		12 => 2048,
		13 => 4096,
		14 => 8192,
		15 => 16384,
		16 => 32768
		);
		my %AUGTYPES = (
		1 => 1,
		2 => 2,
		3 => 4,
		4 => 8,
		5 => 16,
		6 => 32,
		7 => 64,
		8 => 128,
		9 => 256,
		10 => 512,
		11 => 1024,
		12 => 2048,
		13 => 4096,
		14 => 8192,
		15 => 16384,
		16 => 32768,
		17 => 65536,
		18 => 131072,
		19 => 262144,
		20 => 524288,
		21 => 1048576,
		22 => 2097152,
		23 => 4194304,
		24 => 8388608,
		25 => 16777216,
		26 => 33554432,
		27 => 67108864,
		28 => 134217728,
		29 => 268435456,
		30 => 536870912
		);
		my $dbh = plugin::LoadMysql();
		
		my $SCLASS = $classes{$client->GetClass()};
		my $SRACE = $racelist{$client->GetBaseRace()};
		my $query = "SELECT id, slots, hp, augslot1type, augslot2type, augslot3type, augslot4type, augslot5type, augslot1visible, augslot2visible, augslot3visible, augslot4visible, augslot5visible FROM items i WHERE 
					classes & $SCLASS
					and hp > 0
					and aagi >= 0
					and acha >= 0
					and adex >= 0
					and aint >= 0
					and asta >= 0
					and astr >= 0
					and awis >= 0
					and i.reqlevel <= $ulevel 
					and i.reclevel <= $ulevel
					and i.norent >= 1
					and i.itemtype != 54
					and races & $SRACE
					and deity = 0
					and charmfileid = 0 ".
					#"and source like '%custom%' ".
					#and id IN (109051,109432,109451,50459,50629,50221,50631,50226,50227,50229,50622,50627,50617,50625,50234,50232,50235,50236,50237,50623,50618,50217,50213,50216,50220,50218,50219,50215,50214,50630,50620,50621,50243,50241,50246,50242,50244,50239,50619,50626,109416,109032,109016,50449,50628,50225,50228,50223,50233,50224,50238,50245,50222,50231,50624,110460,110419,110293,110291,110456,110433,110412,110422,110430,110416,110401,110449,110440,110409,110452,110443,110406,110425,110447,50230,110009,110060,110012,110437,110019,109950,109550,109902,109810,109799,109789,109807,109938,109800,109793,109531,109918,109931,109518,109804,109502,109538,109456,109056,109287,110442,110400,110413,110418,110294,110448,110428,110455,110010,110410,110421,110426,110018,110048,110451,110458,110408,110004,109802,109785,109515,109797,109794,109919,109805,109791,109788,109532,109539,109808,109915,109932,50577,50592,109500,109939,109900,109519,109801,109516,109540,109927,109787,109809,109792,109803,109806,109936,109527,109796,109536,109940,109501,109901,1624,109947,109766,109547,109916,109544,109944,109739,110454,110405,110411,110292,110431,110415,110450,110402,110441,110438,110435,110235,110007,111305,111521,49656,50240,111304,111312,111516,111351,111350,111306,111327,111313,111356,111511,110444,110417,110407,110295,110423,110427,110420,110457,110257,110017,110788,110787,110786,110785,110434,110296,110414,110445,110459,110285,110453,110424,110429,110403,110029,110271,110244,110014,110789,110794,110793,110795,110768,110766,110958,110748,110558,110944,110544,110739,110525,110756,110925,110745)
					"Order by hp desc";
		
			$sth = $dbh->prepare($query);
			$sth->execute();
			my $rank = 0;
			while (@row = $sth->fetchrow_array()) 
			{ 
				$items_list[$rank] = [@row];
				$rank++;
			}
		my $query2 = "SELECT id, slots, hp, augtype FROM items i WHERE " .
					 "classes & $SCLASS " .
					 "and hp > 0 " .
					 "and i.reqlevel <= $ulevel " .
					 "and i.reclevel <= $ulevel " .
					 "and i.norent >= 1 " .
					 "and i.itemtype = 54 " .
					 "and races & $SRACE " .
					 "and deity = 0 " .
					 "and charmfileid = 0 ".
					 "Order by hp desc";
			$sth = $dbh->prepare($query2);
			$sth->execute();
			my $rank2 = 0;
			while (@row = $sth->fetchrow_array()) 
			{ 
				$aug_list[$rank2] = [@row];
				$rank2++;
			}
		
			OUTER: for my $i ( 0 .. 20) {
				$bestitem = 0;
				
				INNER: for my $g ( 0 .. $rank) {
					if($items_list[$g][0] > 0) {
						if($items_list[$g][2] > $client->GetItemStat($client->GetItemIDAt($i), "hp") && $slots{$i} & $items_list[$g][1]) {
							if($items_list[$g][0] == $client->GetItemIDAt($i)) { 
								next OUTER; 
							} #already have this item in this slot..
							if(plugin::check_hasitem($client, $items_list[$g][0]) && $client->GetItemStat($items_list[$g][0], "loregroup") != 0) { 
								$client->Message(335, "Already have it is LORE " . quest::varlink($items_list[$g][0]));
								next INNER;
							} else {
								$bestitem = $items_list[$g][0];
								if ($bestitem > 0) {
									#ADD BEST ITEM?
									my $augslot1, $augslot2, $augslot3, $augslot4, $augslot5 = 0;
									my @augarray = ();
									
									if ($do_augs == 1) {
										#aug 1
										if ($items_list[$g][3] > 0) { #Slot is active
											AUG1: for my $p ( 0 .. $rank2) {
												if ($slots{$i} & $aug_list[$p][1] ) { #This matches the slot..
													if((plugin::check_hasitem($client, $aug_list[$p][0]) || grep { $aug_list[$p][0] } @augarray) && $client->GetItemStat($aug_list[$p][0], "loregroup") != 0) {
														#We have this item already.. and its lore
														next AUG1;
													}
													if ($aug_list[$p][3] & $AUGTYPES{$items_list[$g][3]}) { #the aug matches augtype..
														$augslot1 = $aug_list[$p][0];
														push(@augarray, $aug_list[$p][0]);
														last AUG1;
													}
												}
											}
										}
										#aug 2
										if ($items_list[$g][4] > 0) { #Slot is active
											AUG2: for my $p ( 0 .. $rank2) {
												if ($slots{$i} & $aug_list[$p][1] ) { #This matches the slot..
													if((plugin::check_hasitem($client, $aug_list[$p][0]) || grep { $aug_list[$p][0] } @augarray) && $client->GetItemStat($aug_list[$p][0], "loregroup") != 0) {
														#We have this item already.. and its lore
														next AUG2;
													}
													if ($aug_list[$p][4] & $AUGTYPES{$items_list[$g][4]}) { #the aug matches augtype..
														$augslot2 = $aug_list[$p][0];
														push(@augarray, $aug_list[$p][0]);
														last AUG2;
													}
												}
											}
										}
										#aug 3
										if ($items_list[$g][5] > 0) { #Slot is active
											AUG3: for my $p ( 0 .. $rank2) {
												if ($slots{$i} & $aug_list[$p][1] ) { #This matches the slot..
													if((plugin::check_hasitem($client, $aug_list[$p][0]) || grep { $aug_list[$p][0] } @augarray) && $client->GetItemStat($aug_list[$p][0], "loregroup") != 0) {
														#We have this item already.. and its lore
														next AUG3;
													}
													if ($aug_list[$p][5] & $AUGTYPES{$items_list[$g][5]}) { #the aug matches augtype..
														$augslot3 = $aug_list[$p][0];
														push(@augarray, $aug_list[$p][0]);
														last AUG3;
													}
												}
											}
										}
										#aug 4
										if ($items_list[$g][6] > 0) { #Slot is active
											AUG4: for my $p ( 0 .. $rank2) {
												if ($slots{$i} & $aug_list[$p][1] ) { #This matches the slot..
													if((plugin::check_hasitem($client, $aug_list[$p][0]) || grep { $aug_list[$p][0] } @augarray) && $client->GetItemStat($aug_list[$p][0], "loregroup") != 0) {
														#We have this item already.. and its lore
														next AUG4;
													}
													if ($aug_list[$p][6] & $AUGTYPES{$items_list[$g][6]}) { #the aug matches augtype..
														$augslot3 = $aug_list[$p][0];
														push(@augarray, $aug_list[$p][0]);
														last AUG4;
													}
												}
											}
										}
										#aug 5
										if ($items_list[$g][7] > 0) { #Slot is active
											AUG5: for my $p ( 0 .. $rank2) {
												if ($slots{$i} & $aug_list[$p][1] ) { #This matches the slot..
													if((plugin::check_hasitem($client, $aug_list[$p][0]) || grep { $aug_list[$p][0] } @augarray) && $client->GetItemStat($aug_list[$p][0], "loregroup") != 0) {
														#We have this item already.. and its lore
														next AUG5;
													}
													if ($aug_list[$p][7] & $AUGTYPES{$items_list[$g][7]}) { #the aug matches augtype..
														$augslot3 = $aug_list[$p][0];
														push(@augarray, $aug_list[$p][0]);
														last AUG5;
													}
												}
											}
										}
									}
									
									
									$client->SummonItem($bestitem, 1, 0, $augslot1, $augslot2, $augslot3, $augslot4, $augslot5, $i);
									$client->Message(315, "Now equipping : ". quest::varlink($bestitem) . " into slot $i.");
								}
								next OUTER;
							}
							
						}
					}
				}
			}	
		if ($sth) { $sth->finish(); }
		$dbh->disconnect();
		$client->Message(335, "FINISHED!");
}

return 1;