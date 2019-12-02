#Require plugins... Mysql.pl

#plugin::InstancePopup("zonesn", version, levelreq, $zonetext)
sub InstanceSignal {
	my $client = plugin::val('$client');
	my $id = $_[0];	
	my $inviter = $client->GetEntityVariable("inst_inviter");
	my $dest_zone = $client->GetEntityVariable("inst_zonesn");
	my $zone_version = $client->GetEntityVariable("inst_version");
	my @zone_info = plugin::ZoneInfo($dest_zone);
	$client->SetEntityVariable("inst_zoneid", $zone_info[0]);
	$client->SetEntityVariable("inst_x", $zone_info[2]);
	$client->SetEntityVariable("inst_y", $zone_info[3]);
	$client->SetEntityVariable("inst_z", $zone_info[4]);	
	my $instance_id = quest::GetInstanceID("$dest_zone", $zone_version);

	if ($instance_id == 0) {
		my $new_id = $id + 200000;
		plugin::DiaWind2("{bullet} Join Instance ID {orange}$id~: <br>"
						. " {in} {bullet} From: {lb}$inviter~<br>"
						. " {in} {bullet} Zone: {y}$zone_info[1]~<br><br>"
						. " {linebreak}<br> "
						. " {in} {bullet}This will take you to the safespot of the zone."
						. " popupid:$new_id wintype:1 mysterious noquotes", "Join", "No thanks");
	} else {
		plugin::DiaWind2("You were invited to an instance by {lb}$inviter~ for {y}$zone_info[1]~ ($id) but already saved to id ({r}$instance_id~). mysterious noquotes");
	}
}

sub InstanceJoin {
	my $client = plugin::val('$client');
	quest::AssignToInstance($_[0]);
	quest::MovePCInstance($client->GetEntityVariable("inst_zoneid"), $_[0], $client->GetEntityVariable("inst_x"), $client->GetEntityVariable("inst_y"),  $client->GetEntityVariable("inst_z"), 0);
	plugin::DiaWind2("You are now assigned to instance ID $_[0]. mysterious");
}

sub InstanceCommands {
	my $client = plugin::val('$client');
	my $zonesn = plugin::val('$zonesn');
	my $instanceversion = plugin::val('$instanceversion');
	my $text = plugin::val('$text');
	my $instanceid = plugin::val('$instanceid');
	my @arg =();
	
	if ($text=~/^#i /i && $instanceid > 0) {
		@arg = split(" ", $text);
		if ($arg[1]=~/invite/i) {
			for (2 .. $#arg) {
				quest::crosszonesetentityvariablebyclientname($arg[$_], "inst_inviter", $client->GetCleanName());
				quest::crosszonesetentityvariablebyclientname($arg[$_], "inst_zonesn", $zonesn);
				quest::crosszonesetentityvariablebyclientname($arg[$_], "inst_version", $instanceversion);
				quest::crosszonesignalclientbyname($arg[$_], 200000 + $instanceid);
			}
		} elsif ($arg[1]=~/^leave$/i) {
			$client->Message(335, "Now leaving instance ID $instanceid.");
			quest::RemoveFromInstance($instanceid);
			quest::zone("qrg");
		} elsif ($arg[1]=~/delete/i) {
			$client->Message(335, "Deleting instance!");
			quest::UpdateInstanceTimer($instanceid, 15);
		}
	}
}

sub InstancePopup {
	my $yel = plugin::PWColor("Yellow");
	my $fire = plugin::PWColor("Goldenrod");
	my $grn = plugin::PWColor("Forest Green");
	my $purple = plugin::PWColor("Light Purple");
	my $red = plugin::PWColor("Red");
	my $gray = plugin::PWColor("Gray");
	my $client = plugin::val('$client');
	
	my $dest_zone = $_[0];
	my @zone_info = plugin::ZoneInfo($dest_zone);
	my $dest_zoneID = $zone_info[0];
	my $zone_version = $_[1];
	my $req_level = $_[2];
	my $inst_popup_id = $_[3];
	my $zonetext = $_[4];
	
	my $break = ("---------------------------------------");
	my $indent = plugin::PWIndent();
	my $group = $client->GetGroup();
	my $charID = $client->CharacterID();
	my $PartySaved = "";
	my $instance = "";
	
	my %version_names = (
		0 => "$gray". "Normal</c>",
		1 => "$red". "Hard</c>",
		2 => "$purple" . "Epic</c>"
	);

		my $dbh = plugin::LoadMysql();
		if($group) {
			$PartySaved = plugin::CheckSaved(plugin::CheckParty($group->GetID), $dest_zoneID, $zone_version);
			my $instance_id = quest::GetInstanceID("$dest_zone", $zone_version);
			if($instance_id == 0) {
				$instance = ("You are not currently bound to this instance.");
			}
			elsif($instance_id > 0) {
				my $myInstance = $dbh->prepare("SELECT il.`start_time`, il.`duration` FROM instance_list il
												INNER JOIN instance_list_player ilp ON il.`id` = ilp.`id` 
												WHERE ilp.`charid` = $charID and il.`zone` = $dest_zoneID and il.`version` = $zone_version;");
				$myInstance->execute();
				my @thisInstance = $myInstance->fetchrow_array();
				
				my $hours = plugin::GetTimeLeft($thisInstance[0]+$thisInstance[1],"H");
				my $minutes = plugin::GetTimeLeft($thisInstance[0]+$thisInstance[1],"M");
				my $seconds = plugin::GetTimeLeft($thisInstance[0]+$thisInstance[1],"S");
				
				my $minLeft = $minutes % 60;
				my $secLeft = $seconds % 60;
				
				$instance = ("You are currently bound to this instance for $hours hour(s) $minLeft minutes $secLeft seconds.");
			}				
		} else {
			my $instance_id = quest::GetInstanceID("$dest_zone", $zone_version);
			if($instance_id == 0)
			{
				$instance = ("You are not currently bound to this instance.");
			}
			elsif($instance_id > 0)
			{
				my $myInstance = $dbh->prepare("SELECT il.`start_time`, il.`duration` FROM instance_list il
												INNER JOIN instance_list_player ilp ON il.`id` = ilp.`id` 
												WHERE ilp.`charid` = $charID and il.`zone` = $dest_zoneID and il.`version` = $zone_version;");
				$myInstance->execute();
				my @thisInstance = $myInstance->fetchrow_array();
				
				my $hours = plugin::GetTimeLeft($thisInstance[0]+$thisInstance[1],"H");
				my $minutes = plugin::GetTimeLeft($thisInstance[0]+$thisInstance[1],"M");
				my $seconds = plugin::GetTimeLeft($thisInstance[0]+$thisInstance[1],"S");
				
				my $minLeft = $minutes % 60;
				my $secLeft = $seconds % 60;
				
				$instance = ("You are currently bound to this instance for $hours hour(s) $minLeft minutes $secLeft seconds.");
			}
		}
		$client->Popup2("Instance", "$yel Zone:</c> " . $zone_info[1] ." ($version_names{$zone_version})<br>
										$yel Level Requirement:</c> $req_level+<br>$break<br>
										$indent$grn$instance</c><br>
										$indent - $zonetext<br><br>
										<br>$PartySaved
										$break<br><br>
										$fire Click 'Enter' to enter this instance.<br><br>
										#i invite player player (to add players)<br>
										#i leave (to leave instance ID)<br>
										",$inst_popup_id,0,1,0,"Enter","Not Now");
}

#plugin::InstanceResponse(zonesn, version, x, y, z, time);
sub InstanceResponse {
	my $client = plugin::val('$client');
	my $name = plugin::val('$name');
	my $group = $client->GetGroup();
	my $dest_zone = $_[0];
	my @zone_info = plugin::ZoneInfo($dest_zone);
	my $dest_zoneID = $zone_info[0];
	my $zone_version = $_[1];
	my $desy_x = $_[2];
	my $desy_y = $_[3];
	my $desy_z = $_[4];
	my $inst_timer = $_[5];
	
	if($group) {
		my $group_id = $group->GetID();
		my $instance_id = quest::GetInstanceID("$dest_zone", $zone_version);
		
		if($instance_id == 0 && $group->GetLeaderName() ne $name) {
			$client->Message(335, "Only the party leader (" .$group->GetLeaderName().") may create the instance!");
		}
		elsif($instance_id == 0 && $group->GetLeaderName() eq $name) {
			my $new_instance = quest::CreateInstance("$dest_zone", $zone_version, $inst_timer);
			quest::AssignGroupToInstance($new_instance);
			quest::MovePCInstance($dest_zoneID, $new_instance,$desy_x,$desy_y,$desy_z, 0);
		}
		elsif($instance_id > 0) {
			quest::MovePCInstance($dest_zoneID, $instance_id,$desy_x,$desy_y,$desy_z, 0);
		}
	} else {
		my $instance_id = quest::GetInstanceID("$dest_zone", $zone_version);
		
		if($instance_id == 0) {
			my $new_instance = quest::CreateInstance("$dest_zone", $zone_version, $inst_timer);
			quest::AssignToInstance($new_instance);
			quest::MovePCInstance($dest_zoneID, $new_instance,$desy_x,$desy_y,$desy_z, 0);
		} else {
			quest::MovePCInstance($dest_zoneID, $instance_id,$desy_x,$desy_y,$desy_z, 0);
		}
	}
}

#plugin::CheckSaved(plugin::CheckParty(groupID), dest_zone_id, version)
sub CheckSaved {
	my $client = plugin::val('$client');
	my $dest_zoneID = $_[1];
	my $zone_version = $_[2];
	my $dbh = plugin::LoadMysql();
	
	my $query = "SELECT c.`name`, il.id,   il.`start_time`+il.`duration` AS TIMER FROM character_data c
			INNER JOIN instance_list_player ilp ON c.id = ilp.charid
			INNER JOIN instance_list il ON il.id = ilp.id
			WHERE ilp.`charid` IN ($_[0]) and il.`zone` = $dest_zoneID and il.`version` = $zone_version";
			
	my $saved = $dbh->prepare($query);
	$saved->execute();
	my $saved_members = "";
	while (my @row = $saved->fetchrow_array())
	{
		$saved_members .= "<br>$row[0] - ($row[1]) -  " . plugin::GetTimeLeft($row[2],"H") . " hours " . plugin::GetTimeLeft($row[2],"M") % 60 . " minutes " . plugin::GetTimeLeft($row[2],"S") % 60 . " seconds.";
	}
	return $saved_members;
}

#plugin::CheckParty(groupID)
sub CheckParty {
	my $dbh = plugin::LoadMysql();
	my @Members = ();
	$sth = $dbh->prepare("SELECT `charid` FROM group_id WHERE groupid = $_[0]");
	$sth->execute();
	while (my @row = $sth->fetchrow_array()) {
		push (@Members, $row[0]);
	}
	my $format_members = "";
	foreach $m (@Members)
	{
		if($m == $Members[$#Members])
		{
			$format_members .= "$m";
		}
		else
		{
			$format_members .= "$m, ";
		}
	}
	
	return $format_members;
}

sub ZoneInfo {
	my $client = plugin::val('$client');
		#zonesn => [zoneid, long_name, safex, safey, safez]
	my %zone_info = (
		"abysmal" => [279, "The Abysmal Sea", 0, -199, 140],
		"acrylia" => [154, "The Acrylia Caverns", -665, 20, 4],
		"airplane" => [71, "The Plane of Sky", 614, 1415, -650],
		"akanon" => [55, "Ak'Anon", -35, 47, 4],
		"akheva" => [179, "The Akheva Ruins", 60, -1395, 22],
		"alkabormare" => [709, "Al'Kabor's Nightmare", 1104, -86, -14],
		"anguish" => [317, "Anguish, the Fallen Palace", -9, -2466, -79],
		"apprentice" => [999, "Designer Apprentice", 0, 0, 0],
		"arcstone" => [369, "Arcstone, Isle of Spirits", 1630, -279, 5],
		"arelis" => [725, "Valley of Lunanyn", -1964, 3512, 135],
		"arena" => [77, "The Arena", 146, -1009, 51],
		"arena2" => [180, "The Arena Two", 460.9, -41.4, 24.6],
		"argath" => [724, "Argath, Bastion of Illdaera", -217, -9, 14],
		"arthicrex" => [485, "Arthicrex", 517, -1662, 200],
		"arttest" => [996, "Art Testing Domain", 0, 0, 0],
		"ashengate" => [406, "Ashengate, Reliquary of the Scale", 0, -375, 8],
		"atiiki" => [418, "Jewel of Atiiki", -916, -1089, -39],
		"aviak" => [53, "Aviak Village", 0, 0, 0],
		"barindu" => [283, "Barindu, Hanging Gardens", 590, -1457, -123],
		"barren" => [422, "Barren Coast", 1203, 698, 54],
		"barter" => [346, "The Barter Hall", 0, 0, 0],
		"bazaar" => [151, "The Bazaar", -71, -250, 33],
		"bazaar" => [151, "The Bazaar", 140, -821, 5],
		"beastdomain" => [728, "Beasts' Domain", 4761, -4859, 200],
		"befallen" => [36, "Befallen", 35, -82, 3],
		"befallenb" => [411, "Befallen", 0, 0, 0],
		"beholder" => [16, "Gorge of King Xorbb", -21.44, -512.23, 45.13],
		"bertoxtemple" => [469, "Temple of Bertoxxulous", 2, -2, 2],
		"blackburrow" => [17, "Blackburrow", 39, -159, 3],
		"blacksail" => [428, "Blacksail Folly", -165, 5410, 307],
		"bloodfields" => [301, "The Bloodfields", -1763, 2140, -928],
		"bloodmoon" => [445, "Bloodmoon Keep", -4, 34, 8],
		"bothunder" => [209, "Bastion of Thunder", 178, 207, -1620],
		"breedinggrounds" => [757, "The Breeding Grounds", 0, 0, 3],
		"brellsarena" => [492, "Brell's Arena", 3, -304, -4],
		"brellsrest" => [480, "Brell's Rest", 116, -700, 53],
		"brellstemple" => [490, "Brell's Temple", 1, 43, 3],
		"broodlands" => [337, "The Broodlands", -1613, -1016, 99],
		"brotherisland" => [800, "Brotherhood Island", -3331, -4052, 328],
		"buriedsea" => [423, "The Buried Sea", 3130, -1721, 308],
		"burningwood" => [87, "The Burning Wood", -821, -4942, 204],
		"butcher" => [68, "Butcherblock Mountains", -700, 2550, 3],
		"cabeast" => [106, "Cabilis East", -417, 1362, 8],
		"cabwest" => [82, "Cabilis West", 767, -783, 8],
		"cauldron" => [70, "Dagnor's Cauldron", 320, 2815, 473],
		"causeway" => [303, "Nobles' Causeway", -1674, -239, 317],
		"cazicthule" => [48, "Accursed Temple of CazicThule", -74, 71, 4],
		"chambersa" => [304, "Muramite Proving Grounds", 0, 0, 0],
		"chambersb" => [305, "Muramite Proving Grounds", 0, 0, 0],
		"chambersc" => [306, "Muramite Proving Grounds", 0, 0, 0],
		"chambersd" => [307, "Muramite Proving Grounds", 0, 0, 0],
		"chamberse" => [308, "Muramite Proving Grounds", 0, 0, 0],
		"chambersf" => [309, "Muramite Proving Grounds", 0, 0, 0],
		"chapterhouse" => [760, "Chapterhouse of the Fallen", -119, -197, 2],
		"charasis" => [105, "The Howling Stones", 0, 0, 4],
		"chardok" => [103, "Chardok", 859, 119, 106],
		"chardokb" => [277, "Chardok: The Halls of Betrayal", -190, 290, 7],
		"citymist" => [90, "The City of Mist", -734, 28, 4],
		"cityofbronze" => [732, "Erillion, City of Bronze", 1415, -1, 3],
		"clz" => [190, "Loading", 0, 0, 0],
		"cobaltscar" => [117, "Cobaltscar", 895, -939, 318],
		"codecay" => [200, "The Crypt of Decay", -170, -65, -93],
		"commonlands" => [408, "The Commonlands", -3492, 180, 15],
		"commons" => [21, "West Commonlands", -1334.24, 209.57, -51.47],
		"convorteum" => [491, "The Convorteum", 28, -24, -42],
		"coolingchamber" => [483, "The Cooling Chamber", -35, -130, 59],
		"corathus" => [365, "Corathus Creep", 16, -337, -46],
		"corathusa" => [366, "Sporali Caverns", -49.3, 49.84, -10.76],
		"corathusb" => [367, "The Corathus Mines", 2, 90, -15],
		"crescent" => [394, "Crescent Reach", -8, 11, 2],
		"crushbone" => [58, "Crushbone", 158, -644, 4],
		"cryptofshade" => [449, "Crypt of Shade", 985, -445, -39],
		"crystal" => [121, "The Crystal Caverns", 303, 487, -74],
		"crystallos" => [446, "Crystallos, Lair of the Awakened", -65, -200, -75],
		"crystalshard" => [756, "The Crystal Caverns: Fragment of Fear", 303, 487, -74],
		"cshome" => [26, "Sunset Home", 0, 100, 0],
		"dalnir" => [104, "The Crypt of Dalnir", 0, 0, 6],
		"dawnshroud" => [174, "The Dawnshroud Peaks", 2085, 0, 89],
		"deadbone" => [427, "Deadbone Reef", -3817, 4044, 314],
		"delvea" => [341, "Lavaspinner's Lair", -246, -1578, 68],
		"delveb" => [342, "Tirranun's Delve", -138, -355, 17],
		"devastation" => [372, "The Devastation", 1390, 216, 53],
		"devastationa" => [373, "The Seething Wall", -141, 1059, 4],
		"direwind" => [405, "Direwind Cliffs", -329, -1845, 10],
		"discord" => [470, "Korafax, Home of the Riders", 28, -20, -16],
		"discordtower" => [471, "Citadel of the Worldslayer", 0, -48, -48],
		"drachnidhive" => [354, "The Hive", 0, 0, 0],
		"drachnidhivea" => [355, "The Hatchery", 0, 0, 0],
		"drachnidhiveb" => [356, "The Cocoons", 21.25, 1248.2, 150.27],
		"drachnidhivec" => [357, "Queen Sendaii`s Lair", -55.72, -70.27, -755],
		"dragoncrypt" => [495, "Lair of the Risen", 0, 0, 3.37],
		"dragonscale" => [442, "Dragonscale Hills", -1954, 3916, 19],
		"dragonscaleb" => [451, "Deepscar's Den", 58, 20, 6],
		"dranik" => [336, "The Ruined City of Dranik", -1112, -1953, -369],
		"dranikcatacombsa" => [328, "Catacombs of Dranik", 0, 0, -8],
		"dranikcatacombsb" => [329, "Catacombs of Dranik", 222.17, 665.96, -13.21],
		"dranikcatacombsc" => [330, "Catacombs of Dranik", -20, -218, -1.78],
		"dranikhollowsa" => [318, "Dranik's Hollows", 0, 0, 0],
		"dranikhollowsb" => [319, "Dranik's Hollows", 0, -447, -36],
		"dranikhollowsc" => [320, "Dranik's Hollows", 5, -51, -41],
		"draniksewersa" => [331, "Sewers of Dranik", 0, 0, 0],
		"draniksewersb" => [332, "Sewers of Dranik", 0, 0, 0],
		"draniksewersc" => [333, "Sewers of Dranik", 0, 0, 0],
		"draniksscar" => [302, "Dranik's Scar", -1519, -1468, 260],
		"dreadlands" => [86, "The Dreadlands", 9565, 2806, 1050],
		"dreadspire" => [351, "Dreadspire Keep", 1358, -1030, -572],
		"droga" => [81, "The Temple of Droga", 290, 1375, 6],
		"dulak" => [225, "Dulak's Harbor", 438, 548, 4],
		"eastkarana" => [15, "Eastern Plains of Karana", 865, 15, -33],
		"eastkorlach" => [362, "The Undershore", -950, -1130, 184],
		"eastkorlacha" => [363, "Snarlstone Dens", 16, 3, -12],
		"eastsepulcher" => [734, "Sepulcher East", -753.24, -140.6, 2.94],
		"eastwastes" => [116, "Eastern Wastes", -4296, -5049, 147],
		"eastwastesshard" => [755, "East Wastes: Zeixshi-Kar's Awakening", -4222, -8892, 146],
		"echo" => [153, "The Echo Caverns", -800, 840, -25],
		"ecommons" => [22, "East Commonlands", -1485, 9.2, -51],
		"elddar" => [378, "The Elddar Forest", 606, 296, -36],
		"elddara" => [379, "Tunare's Shrine", 0, 0, -6],
		"emeraldjungle" => [94, "The Emerald Jungle", 4648, -1223, 2],
		"erudnext" => [24, "Erudin", -338, 75, 20],
		"erudnint" => [23, "The Erudin Palace", 808, 712, 21],
		"erudsxing" => [98, "Erud's Crossing", 795, -1767, 11],
		"erudsxing2" => [130, "Marauders Mire", 0, 0, 0],
		"everfrost" => [30, "Everfrost Peaks", 629, 3139, -60],
		"eviltree" => [758, "Evantil, the Vile Oak", 1441, -205, 86],
		"fallen" => [706, "Erudin Burning", 59, -15, 0],
		"fearplane" => [72, "The Plane of Fear", 1282, -1139, 5],
		"feerrott" => [47, "The Feerrott", 905, 1051, 25],
		"feerrott2" => [700, "The Feerrott", 952.95, 1022.59, 40.83],
		"felwithea" => [61, "Northern Felwithe", 94, -25, 3],
		"felwitheb" => [62, "Southern Felwithe", -790, 320, -10],
		"ferubi" => [284, "Ferubi, Forgotten Temple of Taelosia", 1485, 596, 111.8],
		"fhalls" => [998, "The Forgotten Halls", -74, -843, -11],
		"fieldofbone" => [78, "The Field of Bone", 1617, -1684, -50],
		"firiona" => [84, "Firiona Vie", 1440, -2392, 1],
		"foundation" => [486, "The Foundation", 1168.49, -1023.98, -209],
		"freeportacademy" => [385, "Academy of Arcane Sciences", -141, -336, 49],
		"freeportarena" => [388, "Arena", -6.75, -42.5, 3],
		"freeportcityhall" => [389, "City Hall", -46.98, -31.21, -9.92],
		"freeporteast" => [382, "East Freeport", -725, -425, 7],
		"freeporthall" => [391, "Hall of Truth: Bounty", -432, 569, -100],
		"freeportmilitia" => [387, "Freeport Militia House: My Precious", 7, -243, 3],
		"freeportsewers" => [384, "Freeport Sewers", -1298, 111, -80],
		"freeporttemple" => [386, "Temple of Marr", 0, 0, 10],
		"freeporttheater" => [390, "Theater of the Tranquil", 0, -6, -28],
		"freeportwest" => [383, "West Freeport", -67, 0, -82],
		"freporte" => [10, "East Freeport", -648, -1097, -52.2],
		"freportn" => [8, "North Freeport", 211, -296, 4],
		"freportw" => [9, "West Freeport", 181, 335, -24],
		"frontiermtns" => [92, "Frontier Mountains", -4262, -633, 116],
		"frostcrypt" => [402, "Frostcrypt, Throne of the Shade King", 0, -40, 2],
		"frozenshadow" => [111, "The Tower of Frozen Shadow", 200, 120, 0],
		"fungalforest" => [481, "Fungal Forest", 2704, 233, 342],
		"fungusgrove" => [157, "The Fungus Grove", -1005, -2140, -308],
		"gfaydark" => [54, "The Greater Faydark", 10, -20, 0],
		"greatdivide" => [118, "The Great Divide", -965, -7720, -557],
		"grelleth" => [759, "Grelleth's Palace, the Chateau of Filth", 0, 24, 3],
		"griegsend" => [163, "Grieg's End", 3461, -19, -5],
		"grimling" => [167, "Grimling Forest", -1020, -950, 22],
		"grobb" => [52, "Grobb", 0, -100, 3],
		"growthplane" => [127, "The Plane of Growth", 3016, -2522, -19],
		"guardian" => [447, "The Mechamatic Guardian", -115, 60, 4],
		"guildhall" => [345, "Guild Hall", 0, 1, 3],
		"guildlobby" => [344, "Guild Lobby", 19, -55, 5],
		"guka" => [229, "Deepest Guk: Cauldron of Lost Souls", 101, -841, 1],
		"gukb" => [234, "The Drowning Crypt", 0, 0, 0],
		"gukbottom" => [66, "The Ruins of Old Guk", -217, 1197, -78],
		"gukc" => [239, "Deepest Guk: Ancient Aqueducts", -804, -372, 96],
		"gukd" => [244, "The Mushroom Grove", 0, 0, 0],
		"guke" => [249, "Deepest Guk: The Curse Reborn", 680, -1031, 59],
		"gukf" => [254, "Deepest Guk: Chapel of the Witnesses", -714, 550, 32],
		"gukg" => [259, "The Root Garden", 0, 0, 0],
		"gukh" => [264, "Deepest Guk: Accursed Sanctuary", 834, -667, -92],
		"guktop" => [65, "The City of Guk", 7, -36, 4],
		"gunthak" => [224, "The Gulf of Gunthak", -938, 1461, 15],
		"gyrospireb" => [440, "Gyrospire Beza", -9, -843, 4],
		"gyrospirez" => [441, "Gyrospire Zeka", -9, -843, 4],
		"halas" => [29, "Halas", 0, 0, 3],
		"harbingers" => [335, "Harbinger's Spire", 122, -98, 10],
		"hateplane" => [76, "Plane of Hate", -353.08, -374.8, 3.75],
		"hateplaneb" => [186, "The Plane of Hate", -393, 656, 3],
		"hatesfury" => [228, "Hate's Fury", -924, 107, 0],
		"highkeep" => [6, "High Keep", 88, -16, 4],
		"highpass" => [5, "Highpass Hold", -104, -14, 4],
		"highpasshold" => [407, "Highpass Hold", -219, -148, -24],
		"highpasskeep" => [412, "HighKeep", 0, 0, 0],
		"hillsofshade" => [444, "Hills of Shade", -216, -1950, -50],
		"hohonora" => [211, "The Halls of Honor", -2678, -323, 3],
		"hohonorb" => [220, "The Temple of Marr", 975, 2, 396],
		"hole" => [39, "The Hole", -1050, 640, -80],
		"hollowshade" => [166, "Hollowshade Moor", 2420, 1241, 40],
		"housegarden" => [703, "The Grounds", 102.16, -0.87, -28.89],
		"iceclad" => [110, "The Iceclad Ocean", 340, 5330, -17],
		"icefall" => [400, "Icefall Glacier", 765, -1871, -46],
		"ikkinz" => [294, "Ikkinz, Chambers of Transcendence", -157, 23, -2],
		"illsalin" => [347, "Ruins of Illsalin", 308, -182, -32],
		"illsalina" => [348, "Illsalin Marketplace", 8, 0, -20],
		"illsalinb" => [349, "Temple of Korlach", 0, 0, 0],
		"illsalinc" => [350, "The Nargil Pits", 0, 0, -15],
		"inktuta" => [296, "Inktu'Ta, the Unmasked Chapel", 0, 65, -2],
		"innothule" => [46, "Innothule Swamp", -588, -2192, -25],
		"innothuleb" => [413, "The Innothule Swamp", -1029, -1778, 19],
		"jaggedpine" => [181, "The Jaggedpine Forest", 1800, 1319, -13],
		"jardelshook" => [424, "Jardel's Hook", 4677, -784, 373],
		"kael" => [113, "Kael Drakkel", -633, -47, 128],
		"kaelshard" => [754, "Kael Drakkel: The King's Madness", -633, -47, 128],
		"kaesora" => [88, "Kaesora", 40, 370, 102],
		"kaladima" => [60, "South Kaladim", -2, -18, 3],
		"kaladimb" => [67, "North Kaladim", -267, 414, 3.75],
		"karnor" => [102, "Karnor's Castle", 302, 18, 6],
		"katta" => [160, "Katta Castellum", -545, 645, 1],
		"kattacastrum" => [416, "Katta Castrum", -2, -425, -20],
		"kedge" => [64, "Kedge Keep", 14, 100, 302],
		"kerraridge" => [74, "Kerra Isle", -859.97, 474.96, 23.75],
		"kithforest" => [410, "Kithicor Forest", 0, 0, 0],
		"kithicor" => [20, "Kithicor Forest", 3828, 1889, 459],
		"kodtaz" => [293, "Kod'Taz, Broken Trial Grounds", -1475, 1548, -302.12],
		"korascian" => [476, "Korascian Warrens", 24, -77, 25],
		"kurn" => [97, "Kurn's Tower", 0, 0, 7],
		"lakeofillomen" => [85, "Lake of Ill Omen", -5383, 5747, 70],
		"lakerathe" => [51, "Lake Rathetear", 1213, 4183, 3],
		"lavastorm" => [27, "The Lavastorm Mountains", -25, 182, -74],
		"letalis" => [169, "Mons Letalis", -623, -1249, -29],
		"lfaydark" => [57, "The Lesser Faydark", -1770, -108, 0],
		"lichencreep" => [487, "Lichen Creep", 94, -1270, -5],
		"load" => [184, "Loading Zone", -316, 5, 8.2],
		"load2" => [185, "New Loading Zone", -260, -4, -724],
		"lopingplains" => [443, "Loping Plains", -3698, -1289, 722],
		"maiden" => [173, "The Maiden's Eye", 1905, 940, -150],
		"maidensgrave" => [429, "Maiden's Grave", 4455, 2042, 307],
		"mansion" => [437, "Meldrath's Majestic Mansion", 0, -73, 3],
		"mechanotus" => [436, "Fortress Mechanotus", -1700, 350, 404],
		"mesa" => [397, "Goru`kar Mesa", -85, -2050, 19],
		"mira" => [232, "Miragul's Menagerie: Silent Gallery", 649, 564, -89],
		"miragulmare" => [710, "Miragul's Nightmare", -102, 36, -108],
		"mirb" => [237, "Miragul's Menagerie: Frozen Nightmare", 607, 1504, 28],
		"mirc" => [242, "The Spider Den", -769, 763, -186],
		"mird" => [247, "Miragul's Menagerie: Hushed Banquet", 228, -457, 2],
		"mire" => [252, "The Frosted Halls", 0, 0, 0],
		"mirf" => [257, "The Forgotten Wastes", 0, 0, 0],
		"mirg" => [262, "Miragul's Menagerie: Heart of the Menagerie", 434, -15, 56],
		"mirh" => [267, "The Morbid Laboratory", 0, 0, 0],
		"miri" => [271, "The Theater of Imprisoned Horror", 0, 0, 0],
		"mirj" => [275, "Miragul's Menagerie: Grand Library", 1153, -901, 28],
		"mischiefplane" => [126, "The Plane of Mischief", -395, -1410, 115],
		"mistmoore" => [59, "The Castle of Mistmoore", 120, -330, -178],
		"misty" => [33, "Misty Thicket", 0, 0, 2.43],
		"mistythicket" => [415, "The Misty Thicket", 662, -7, 4],
		"mmca" => [233, "Mistmoore's Catacombs: Forlorn Caverns", -594, -365, 6],
		"mmcb" => [238, "Mistmoore's Catacombs: Dreary Grotto", -522, -22, 23],
		"mmcc" => [243, "Mistmoore's Catacombs: Struggles within the Progeny", -424, -108, 2],
		"mmcd" => [248, "Mistmoore's Catacombs: Chambers of Eternal Affliction", -144, -647, 1],
		"mmce" => [253, "Mistmoore's Catacombs: Sepulcher of the Damned", -605, 372, 1],
		"mmcf" => [258, "Mistmoore's Catacombs: Scion Lair of Fury", -184, 399, -12],
		"mmcg" => [263, "Mistmoore's Catacombs: Cesspits of Putrescence", 427, 413, 4],
		"mmch" => [268, "Mistmoore's Catacombs: Aisles of Blood", -367, -323, 17],
		"mmci" => [272, "Mistmoore's Catacombs: Halls of Sanguinary Rites", 589, -275, 4],
		"mmcj" => [276, "Mistmoore's Catacombs: Infernal Sanctuary", 258, 548, 4],
		"monkeyrock" => [425, "Monkey Rock", -4084, -3067, 307],
		"moors" => [395, "Blightfire Moors", 3263, -626, -20],
		"morellcastle" => [707, "Morell's Castle", -30, -219, -36],
		"mseru" => [168, "Marus Seru", -1668, 540, -6],
		"nadox" => [227, "The Crypt of Nadox", -1340, -70, 5],
		"najena" => [44, "Najena", 858, -76, 4],
		"natimbi" => [280, "Natimbi, the Broken Shores", -1557, -853, 239],
		"necropolis" => [123, "Dragon Necropolis", 2000, -100, 5],
		"nedaria" => [182, "Nedaria's Landing", -1737, -181, 256],
		"neighborhood" => [712, "Sunrise Hills", 2035, -2940, 6],
		"nektropos" => [28, "Nektropos", 0, 0, 0],
		"nektulos" => [25, "The Nektulos Forest", 235, -911, 24],
		"nektulos" => [25, "The Nektulos Forest", -259, -1201, -5],
		"nektulosa" => [368, "Shadowed Grove", -11, 134, -13],
		"neriaka" => [40, "Neriak - Foreign Quarter", 157, -3, 31],
		"neriakb" => [41, "Neriak - Commons", -500, 3, -10],
		"neriakc" => [42, "Neriak - 3rd Gate", -969, 892, -52],
		"neriakd" => [43, "Neriak Palace", 0, 0, 0],
		"netherbian" => [161, "Netherbian Lair", 14, 1787, -62],
		"nexus" => [152, "Nexus", 0, 0, -28],
		"nightmareb" => [221, "The Lair of Terris Thule", 1608, 30, -327],
		"northkarana" => [13, "The Northern Plains of Karana", -382, -284, -8],
		"northro" => [392, "North Desert of Ro", -1262, 8590, 40],
		"nro" => [34, "Northern Desert of Ro", 299.12, 3537.9, -24.5],
		"nurga" => [107, "The Mines of Nurga", -1762, -2200, 6],
		"oasis" => [37, "Oasis of Marr", 903.98, 490.03, 6.4],
		"oceangreenhills" => [466, "Oceangreen Hills", -1140, 4542, 73],
		"oceangreenvillage" => [467, "Oceangreen Village", 83, -72, 3],
		"oceanoftears" => [409, "The Ocean of Tears", -7925, 1610, -292],
		"oggok" => [49, "Oggok", -99, -345, 4],
		"oldblackburrow" => [468, "BlackBurrow", 7, -377, 46],
		"oldbloodfield" => [472, "Old Bloodfields", -2097, 2051, 3],
		"oldcommons" => [457, "Old Commonlands", -3492, 180, 15],
		"olddranik" => [474, "City of Dranik", -1799, 986, -184],
		"oldfieldofbone" => [452, "Field of Scale", 1692, 1194, -49],
		"oldhighpass" => [458, "Highpass Hold", 0, 0, -5],
		"oldkaesoraa" => [453, "Kaesora Library", 33.67, -20.86, 3.37],
		"oldkaesorab" => [454, "Kaesora Hatchery", -64, -30, 2],
		"oldkithicor" => [456, "Bloody Kithicor", -255, 1189, 10],
		"oldkurn" => [455, "Kurn's Tower", 20, -265, 5],
		"oot" => [69, "Ocean of Tears", -9200, 390, 6],
		"overthere" => [93, "The Overthere", 1450, -3500, 309],
		"paineel" => [75, "Paineel", 200, 800, 3],
		"paludal" => [156, "The Paludal Caverns", -241, -3721, 195],
		"paw" => [18, "The Lair of the Splitpaw", 63, -122, 3],
		"pellucid" => [488, "Pellucid Grotto", -779, -424, -53],
		"permafrost" => [73, "The Permafrost Caverns", 61, -121, 2],
		"pillarsalra" => [730, "Pillars of Alra", 423, -1762, 46],
		"poair" => [215, "The Plane of Air", 532, 884, -90],
		"podisease" => [205, "The Plane of Disease", -1750, -1245, -56],
		"poeartha" => [218, "The Plane of Earth", -1150, 200, 71],
		"poearthb" => [222, "The Plane of Earth", -762, 328, -56],
		"pofire" => [217, "The Plane of Fire", -1387, 1210, -182],
		"poinnovation" => [206, "The Plane of Innovation", 263, 516, -53],
		"pojustice" => [201, "The Plane of Justice", 58, -61, 5],
		"poknowledge" => [202, "The Plane of Knowledge", -285, -148, -159],
		"ponightmare" => [204, "The Plane of Nightmares", 1668, 282, 212],
		"postorms" => [210, "The Plane of Storms", -1795, -2059, -471],
		"potactics" => [214, "Drunder, the Fortress of Zek", -210, 10, -35],
		"potimea" => [219, "The Plane of Time", -37, -110, 8],
		"potimeb" => [223, "The Plane of Time", 851, -141, 396],
		"potorment" => [207, "Torment, the Plane of Pain", -341, 1706, -491],
		"potranquility" => [203, "The Plane of Tranquility", -1507, 701, -878],
		"povalor" => [208, "The Plane of Valor", 190, -1668, 65],
		"powar" => [213, "Plane of War", 0, 0, 0],
		"powater" => [216, "The Plane of Water", -165, -1250, 4],
		"precipiceofwar" => [473, "The Precipice of War", 985, -1110, 285],
		"provinggrounds" => [316, "Muramite Provinggrounds", -124, -5676, -306],
		"qcat" => [45, "The Qeynos Aqueduct System", 80, 860, -38],
		"qey2hh1" => [12, "The Western Plains of Karana", -531, 15, -3],
		"qeynos" => [1, "South Qeynos", 0, 10, 5],
		"qeynos2" => [2, "North Qeynos", -74, 428, 3],
		"qeytoqrg" => [4, "The Qeynos Hills", 83, 508, 0],
		"qinimi" => [281, "Qinimi, Court of Nihilia", -1053, 438, -16],
		"qrg" => [3, "The Surefall Glade", 0, 0, 2],
		"qvic" => [295, "Qvic, Prayer Grounds of Calling", -2515, 767, -647],
		"qvicb" => [299, "Qvic, the Hidden Vault", 0, 0, -6.25],
		"rage" => [374, "Sverag, Stronghold of Rage", 0, 1065, 7],
		"ragea" => [375, "Razorthorn, Tower of Sullon Zek", 354, 63, 3],
		"rathechamber" => [477, "Rathe Council Chamber", -19, -10, -22],
		"rathemtn" => [50, "The Rathe Mountains", 1831, 3825, 28],
		"redfeather" => [430, "Redfeather Isle", 2531, -3638, 312],
		"relic" => [370, "Relic, the Artifact City", 861, 618, -265],
		"resplendent" => [729, "The Resplendent Temple", -33, 81, 9],
		"riftseekers" => [334, "Riftseekers' Sanctum", -1, 297, -208],
		"rivervale" => [19, "Rivervale", 0, 0, 4],
		"riwwi" => [282, "Riwwi, Coliseum of Games", 454, -650, 35],
		"roost" => [398, "Blackfeather Roost", -1592, 2125, -308],
		"rubak" => [727, "Rubak Oseka, Temple of the Sea", -61.83, -1.71, 525],
		"ruja" => [230, "The Rujarkian Hills: Bloodied Quarries", 805, -123, -95],
		"rujb" => [235, "The Rujarkian Hills: Halls of War", 367, -776, -12],
		"rujc" => [240, "The Rujarkian Hills: Wind Bridges", -1315, -515, -12],
		"rujd" => [245, "The Rujarkian Hills: Prison Break", -322, 1254, -96],
		"ruje" => [250, "The Rujarkian Hills: Drudge Hollows", 500, -1876, -222],
		"rujf" => [255, "The Rujarkian Hills: Fortified Lair of the Taskmasters", -290, -571, -460],
		"rujg" => [260, "The Rujarkian Hills: Hidden Vale of Deceit", 238, -1163, 130],
		"rujh" => [265, "The Rujarkian Hills: Blazing Forge ", 656, -1250, -15],
		"ruji" => [269, "The Rujarkian Hills: Arena of Chance", 833, -1871, -222],
		"rujj" => [273, "The Rujarkian Hills: Barracks of War", 750, -134, 26],
		"runnyeye" => [11, "The Liberated Citadel of Runnyeye", 201, 90, 4],
		"sarithcity" => [726, "Sarith, City of Tides", -490, 916, -2],
		"scarlet" => [175, "The Scarlet Desert", -1678, -1054, -98],
		"sebilis" => [89, "The Ruins of Sebilis", 0, 250, 44],
		"sepulcher" => [733, "Sepulcher of Order", 1, -262, 0],
		"shadeweaver" => [165, "Shadeweaver's Thicket", -3570, -2122, -93],
		"shadowhaven" => [150, "Shadow Haven", 190, -982, -28],
		"shadowrest" => [187, "Shadowrest", -27.3, -245.6, 8.1],
		"shadowspine" => [364, "Shadow Spine", 2, 408, 72],
		"shardslanding" => [752, "Shard's Landing", -495, -1965, 4],
		"sharvahl" => [155, "The City of Shar Vahl", 85, -1135, -188],
		"shiningcity" => [484, "Kernagir, the Shining City", -19, -22, -42],
		"shipmvm" => [435, "The Open Sea", -69, -47, 44],
		"shipmvp" => [431, "The Open Sea", 0, 68, 47],
		"shipmvu" => [432, "The Open Sea", -118, -193, 29],
		"shippvu" => [433, "The Open Sea", -116, -97, 46],
		"shipuvu" => [434, "The Open Sea", -116, -97, 46],
		"shipworkshop" => [439, "S.H.I.P. Workshop", 530, 457, 10],
		"silyssar" => [420, "Silyssar, New Chelsith", 167, -50, -66],
		"sirens" => [125, "Siren's Grotto", -33, 196, 4],
		"skyfire" => [91, "The Skyfire Mountains", -4286, -1140, 38],
		"skylance" => [371, "Skylance", 0, -95, 2],
		"skyshrine" => [114, "Skyshrine", -730, -210, 0],
		"sleeper" => [128, "The Sleeper's Tomb", 0, 0, 5],
		"sncrematory" => [288, "Sewers of Nihilia, Emanating Cre", 31, 175, -17],
		"snlair" => [286, "Sewers of Nihilia, Lair of Trapp", 234, -70, -14],
		"snplant" => [287, "Sewers of Nihilia, Purifying Pla", 150, 127, -7],
		"snpool" => [285, "Sewers of Nihilia, Pool of Sludg", 137, -5, -19],
		"soldunga" => [31, "Solusek's Eye", -486, -476, 73],
		"soldungb" => [32, "Nagafen's Lair", -263, -424, -108],
		"soldungc" => [278, "The Caverns of Exile", 307, -307, -14],
		"solrotower" => [212, "The Tower of Solusek Ro", -1, -2915, -766],
		"soltemple" => [80, "The Temple of Solusek Ro", 36, 262, 0],
		"solteris" => [421, "Solteris, the Throne of Ro", 0, 0, -20],
		"somnium" => [708, "Sanctum Somnium", -2, 195, 0],
		"southkarana" => [14, "The Southern Plains of Karana", 1294, 2348, -6],
		"southro" => [393, "South Desert of Ro", -581, -520, 126],
		"sro" => [35, "Southern Desert of Ro", 286, 1265, 79],
		"sseru" => [159, "Sanctus Seru", -232, 1166, 59],
		"ssratemple" => [162, "Ssraeshza Temple", 0, 0, 4],
		"steamfactory" => [438, "The Steam Factory", -870, 66, 121],
		"steamfont" => [56, "Steamfont Mountains", -272.86, 159.86, -21.4],
		"steamfontmts" => [448, "The Steamfont Mountains", -170, -42, 2],
		"steppes" => [399, "The Steppes", -896, -2360, 3],
		"stillmoona" => [338, "Stillmoon Temple", -9, -78, -30],
		"stillmoonb" => [339, "The Ascent", 169, 1027, 44],
		"stonebrunt" => [100, "The Stonebrunt Mountains", -1643, -3428, -7],
		"stonehive" => [396, "Stone Hive", -1331, -521, 26],
		"stonesnake" => [489, "Volska's Husk", 50, 24, 0],
		"suncrest" => [426, "Suncrest Isle", -2241, -650, 316],
		"sunderock" => [403, "Sunderock Springs", -393, -3454, 4],
		"swampofnohope" => [83, "The Swamp of No Hope", 2945, 2761, 6],
		"tacvi" => [298, "Tacvi, The Broken Temple", 4, 9, -8],
		"taka" => [231, "Takish-Hiz: Sunken Library", -77, 493, 3],
		"takb" => [236, "Takish-Hiz: Shifting Tower", 380, -544, 7],
		"takc" => [241, "Takish-Hiz: Fading Temple", 251, 33, 3],
		"takd" => [246, "Takish-Hiz: Royal Observatory", -282, 133, 7],
		"take" => [251, "Takish-Hiz: River of Recollection", 375, -406, 19],
		"takf" => [256, "Takish-Hiz: Sandfall Corridors", 69, 1, 3],
		"takg" => [261, "Takish-Hiz: Balancing Chamber", -214, 234, 22],
		"takh" => [266, "Takish-Hiz: Sweeping Tides", -147, 392, -1],
		"taki" => [270, "Takish-Hiz: Antiquated Palace", 617, 119, -3],
		"takishruins" => [376, "Ruins of Takish-Hiz", -983, 269, 62],
		"takishruinsa" => [377, "The Root of Ro", 18, -138, -29],
		"takj" => [274, "Takish-Hiz: Prismatic Corridors", -143, 625, -21],
		"tempesttemple" => [799, "Tempest Temple", -140, -35, 175],
		"templeveeshan" => [124, "The Temple of Veeshan", -499, -2086, -36],
		"tenebrous" => [172, "The Tenebrous Mountains", 1810, 51, -36],
		"thalassius" => [417, "Thalassius, the Coral Keep", 37, -86, 23],
		"theater" => [380, "Theater of Blood", 2933, 719, 376],
		"theatera" => [381, "Deathknell, Tower of Dissonance", 0, -108, 4],
		"thedeep" => [164, "The Deep", -700, -398, -60],
		"thegrey" => [171, "The Grey", 349, -1994, -26],
		"thenest" => [343, "The Nest", -234, -55, -85],
		"thevoida" => [459, "The Void", -79, -158, 33],
		"thevoidb" => [460, "The Void", -79, -158, 33],
		"thevoidc" => [461, "The Void", -79, -158, 33],
		"thevoidd" => [462, "The Void", -79, -158, 33],
		"thevoide" => [463, "The Void", -79, -158, 33],
		"thevoidf" => [464, "The Void", -79, -158, 33],
		"thevoidg" => [465, "The Void", -79, -158, 33],
		"thuledream" => [711, "Fear Itself", 1282, -1139, 5],
		"thulehouse1" => [701, "House of Thule", 0, -332, 4],
		"thulehouse2" => [702, "House of Thule, Upper Floors", -91, 338, 64],
		"thulelibrary" => [704, "The Library", 0, 0, 0],
		"thundercrest" => [340, "Thundercrest Isles", 1641, -646, 114],
		"thurgadina" => [115, "The City of Thurgadin", 0, -1222, 0],
		"thurgadinb" => [129, "Icewell Keep", 0, 250, 0],
		"timorous" => [96, "Timorous Deep", 2194, -5392, 6],
		"tipt" => [289, "Tipt, Treacherous Crags", -448, -2374, 12],
		"torgiran" => [226, "The Torgiran Mines", -620, -323, 5],
		"toskirakk" => [475, "Toskirakk", -402.5, 309.17, 20.18],
		"towerofrot" => [800, "Tower of Rot", -140, -35, 175],
		"tox" => [38, "Toxxulia Forest", 203, 2295, -45],
		"toxxulia" => [414, "Toxxulia Forest", -718, 2102, 26],
		"trakanon" => [95, "Trakanon's Teeth", 1486, 3868, -336],
		"tutorial" => [183, "EverQuest Tutorial", 0, 0, 0],
		"tutoriala" => [188, "The Mines of Gloomingdeep", 0, 0, 0],
		"tutorialb" => [189, "The Mines of Gloomingdeep", 18, -147, 20],
		"twilight" => [170, "The Twilight Sea", -1858, -420, -10],
		"txevu" => [297, "Txevu, Lair of the Elite", -332, -1, -420],
		"umbral" => [176, "The Umbral Plains", 1900, -474, 23],
		"underquarry" => [482, "The Underquarry", 46, -190, -196],
		"unrest" => [63, "The Estate of Unrest", 52, -38, 3],
		"uqua" => [292, "Uqua, the Ocean God Chantry", -17, -7, -26],
		"valdeholm" => [401, "Valdeholm", 119, -3215, 3],
		"veeshan" => [108, "Veeshan's Peak", 1783, -5, 15],
		"veksar" => [109, "Veksar", 1, -486, -27],
		"velketor" => [112, "Velketor's Labyrinth", -65, 581, -152],
		"vergalid" => [404, "Vergalid Mines", 14, 0, 3],
		"vexthal" => [158, "Vex Thal", -1655, 257, -35],
		"vxed" => [290, "Vxed, the Crumbling Caverns", -427, -3552, 14],
		"wakening" => [119, "The Wakening Land", -5000, -673, -195],
		"wallofslaughter" => [300, "Wall of Slaughter", -1461, -2263, -69],
		"warrens" => [101, "The Warrens", -930, 748, -37],
		"warslikswood" => [79, "The Warsliks Woods", -468, -1429, 198],
		"weddingchapel" => [493, "Wedding Chapel", -87, 0, 0],
		"weddingchapeldark" => [494, "Wedding Chapel", -87, 0, 0],
		"well" => [705, "The Well", 0, 0, 52],
		"westkorlach" => [358, "Stoneroot Falls", -2229, 395, 895],
		"westkorlacha" => [359, "Prince's Manor", -1549, 577, 4],
		"westkorlachb" => [360, "Caverns of the Lost", 0, 4, 4],
		"westkorlachc" => [361, "Lair of the Korlach", -57, 197, 43],
		"westsepulcher" => [735, "Sepulcher West", 745, -206, 8],
		"westwastes" => [120, "The Western Wastes", -3499, -4099, -18],
		"windsong" => [731, "Windsong Sanctuary", -600, -505, -23],
		"xorbb" => [753, "Valley of King Xorbb", -803, -1740, 132],
		"yxtta" => [291, "Yxtta, Pulpit of Exiles ", 1235, 1300, -348],
		"zhisza" => [419, "Zhisza, the Shissar Sanctuary", 6, -856, 5]
	);
	my $zonetouse = lc($_[0]);
	my @zone_return = ();
	for $x (0 .. 4) {
		push (@zone_return, $zone_info{$zonetouse}[$x]);
	}
	
	return @zone_return;
}

sub zoneidtosn {
	my %zone_list = (
		279 => "abysmal",
		154 => "acrylia",
		71 => "airplane",
		55 => "akanon",
		179 => "akheva",
		709 => "alkabormare",
		317 => "anguish",
		999 => "apprentice",
		369 => "arcstone",
		725 => "arelis",
		77 => "arena",
		180 => "arena2",
		724 => "argath",
		485 => "arthicrex",
		996 => "arttest",
		406 => "ashengate",
		418 => "atiiki",
		53 => "aviak",
		283 => "barindu",
		422 => "barren",
		346 => "barter",
		151 => "bazaar",
		151 => "bazaar",
		728 => "beastdomain",
		36 => "befallen",
		411 => "befallenb",
		16 => "beholder",
		469 => "bertoxtemple",
		17 => "blackburrow",
		428 => "blacksail",
		301 => "bloodfields",
		445 => "bloodmoon",
		209 => "bothunder",
		757 => "breedinggrounds",
		492 => "brellsarena",
		480 => "brellsrest",
		490 => "brellstemple",
		337 => "broodlands",
		423 => "buriedsea",
		87 => "burningwood",
		68 => "butcher",
		106 => "cabeast",
		82 => "cabwest",
		70 => "cauldron",
		303 => "causeway",
		48 => "cazicthule",
		304 => "chambersa",
		305 => "chambersb",
		306 => "chambersc",
		307 => "chambersd",
		308 => "chamberse",
		309 => "chambersf",
		760 => "chapterhouse",
		105 => "charasis",
		103 => "chardok",
		277 => "chardokb",
		90 => "citymist",
		732 => "cityofbronze",
		190 => "clz",
		117 => "cobaltscar",
		200 => "codecay",
		408 => "commonlands",
		21 => "commons",
		491 => "convorteum",
		483 => "coolingchamber",
		365 => "corathus",
		366 => "corathusa",
		367 => "corathusb",
		394 => "crescent",
		58 => "crushbone",
		449 => "cryptofshade",
		121 => "crystal",
		446 => "crystallos",
		756 => "crystalshard",
		26 => "cshome",
		104 => "dalnir",
		174 => "dawnshroud",
		427 => "deadbone",
		341 => "delvea",
		342 => "delveb",
		372 => "devastation",
		373 => "devastationa",
		405 => "direwind",
		470 => "discord",
		471 => "discordtower",
		354 => "drachnidhive",
		355 => "drachnidhivea",
		356 => "drachnidhiveb",
		357 => "drachnidhivec",
		495 => "dragoncrypt",
		442 => "dragonscale",
		451 => "dragonscaleb",
		336 => "dranik",
		328 => "dranikcatacombsa",
		329 => "dranikcatacombsb",
		330 => "dranikcatacombsc",
		318 => "dranikhollowsa",
		319 => "dranikhollowsb",
		320 => "dranikhollowsc",
		331 => "draniksewersa",
		332 => "draniksewersb",
		333 => "draniksewersc",
		302 => "draniksscar",
		86 => "dreadlands",
		351 => "dreadspire",
		81 => "droga",
		225 => "dulak",
		15 => "eastkarana",
		362 => "eastkorlach",
		363 => "eastkorlacha",
		734 => "eastsepulcher",
		116 => "eastwastes",
		755 => "eastwastesshard",
		153 => "echo",
		22 => "ecommons",
		378 => "elddar",
		379 => "elddara",
		94 => "emeraldjungle",
		24 => "erudnext",
		23 => "erudnint",
		98 => "erudsxing",
		130 => "erudsxing2",
		30 => "everfrost",
		758 => "eviltree",
		706 => "fallen",
		72 => "fearplane",
		47 => "feerrott",
		700 => "feerrott2",
		61 => "felwithea",
		62 => "felwitheb",
		284 => "ferubi",
		998 => "fhalls",
		78 => "fieldofbone",
		84 => "firiona",
		486 => "foundation",
		385 => "freeportacademy",
		388 => "freeportarena",
		389 => "freeportcityhall",
		382 => "freeporteast",
		391 => "freeporthall",
		387 => "freeportmilitia",
		384 => "freeportsewers",
		386 => "freeporttemple",
		390 => "freeporttheater",
		383 => "freeportwest",
		10 => "freporte",
		8 => "freportn",
		9 => "freportw",
		92 => "frontiermtns",
		402 => "frostcrypt",
		111 => "frozenshadow",
		481 => "fungalforest",
		157 => "fungusgrove",
		54 => "gfaydark",
		118 => "greatdivide",
		759 => "grelleth",
		163 => "griegsend",
		167 => "grimling",
		52 => "grobb",
		127 => "growthplane",
		447 => "guardian",
		345 => "guildhall",
		344 => "guildlobby",
		229 => "guka",
		234 => "gukb",
		66 => "gukbottom",
		239 => "gukc",
		244 => "gukd",
		249 => "guke",
		254 => "gukf",
		259 => "gukg",
		264 => "gukh",
		65 => "guktop",
		224 => "gunthak",
		440 => "gyrospireb",
		441 => "gyrospirez",
		29 => "halas",
		335 => "harbingers",
		76 => "hateplane",
		186 => "hateplaneb",
		228 => "hatesfury",
		6 => "highkeep",
		5 => "highpass",
		407 => "highpasshold",
		412 => "highpasskeep",
		444 => "hillsofshade",
		211 => "hohonora",
		220 => "hohonorb",
		39 => "hole",
		166 => "hollowshade",
		703 => "housegarden",
		110 => "iceclad",
		400 => "icefall",
		294 => "ikkinz",
		347 => "illsalin",
		348 => "illsalina",
		349 => "illsalinb",
		350 => "illsalinc",
		296 => "inktuta",
		46 => "innothule",
		413 => "innothuleb",
		181 => "jaggedpine",
		424 => "jardelshook",
		113 => "kael",
		754 => "kaelshard",
		88 => "kaesora",
		60 => "kaladima",
		67 => "kaladimb",
		102 => "karnor",
		160 => "katta",
		416 => "kattacastrum",
		64 => "kedge",
		74 => "kerraridge",
		410 => "kithforest",
		20 => "kithicor",
		293 => "kodtaz",
		476 => "korascian",
		97 => "kurn",
		85 => "lakeofillomen",
		51 => "lakerathe",
		27 => "lavastorm",
		169 => "letalis",
		57 => "lfaydark",
		487 => "lichencreep",
		184 => "load",
		185 => "load2",
		443 => "lopingplains",
		173 => "maiden",
		429 => "maidensgrave",
		437 => "mansion",
		436 => "mechanotus",
		397 => "mesa",
		232 => "mira",
		710 => "miragulmare",
		237 => "mirb",
		242 => "mirc",
		247 => "mird",
		252 => "mire",
		257 => "mirf",
		262 => "mirg",
		267 => "mirh",
		271 => "miri",
		275 => "mirj",
		126 => "mischiefplane",
		59 => "mistmoore",
		33 => "misty",
		415 => "mistythicket",
		233 => "mmca",
		238 => "mmcb",
		243 => "mmcc",
		248 => "mmcd",
		253 => "mmce",
		258 => "mmcf",
		263 => "mmcg",
		268 => "mmch",
		272 => "mmci",
		276 => "mmcj",
		425 => "monkeyrock",
		395 => "moors",
		707 => "morellcastle",
		168 => "mseru",
		227 => "nadox",
		44 => "najena",
		280 => "natimbi",
		123 => "necropolis",
		182 => "nedaria",
		712 => "neighborhood",
		28 => "nektropos",
		25 => "nektulos",
		25 => "nektulos",
		368 => "nektulosa",
		40 => "neriaka",
		41 => "neriakb",
		42 => "neriakc",
		43 => "neriakd",
		161 => "netherbian",
		152 => "nexus",
		221 => "nightmareb",
		13 => "northkarana",
		392 => "northro",
		34 => "nro",
		107 => "nurga",
		37 => "oasis",
		466 => "oceangreenhills",
		467 => "oceangreenvillage",
		409 => "oceanoftears",
		49 => "oggok",
		468 => "oldblackburrow",
		472 => "oldbloodfield",
		457 => "oldcommons",
		474 => "olddranik",
		452 => "oldfieldofbone",
		458 => "oldhighpass",
		453 => "oldkaesoraa",
		454 => "oldkaesorab",
		456 => "oldkithicor",
		455 => "oldkurn",
		69 => "oot",
		93 => "overthere",
		75 => "paineel",
		156 => "paludal",
		18 => "paw",
		488 => "pellucid",
		73 => "permafrost",
		730 => "pillarsalra",
		215 => "poair",
		205 => "podisease",
		218 => "poeartha",
		222 => "poearthb",
		217 => "pofire",
		206 => "poinnovation",
		201 => "pojustice",
		202 => "poknowledge",
		204 => "ponightmare",
		210 => "postorms",
		214 => "potactics",
		219 => "potimea",
		223 => "potimeb",
		207 => "potorment",
		203 => "potranquility",
		208 => "povalor",
		213 => "powar",
		216 => "powater",
		473 => "precipiceofwar",
		316 => "provinggrounds",
		45 => "qcat",
		12 => "qey2hh1",
		1 => "qeynos",
		2 => "qeynos2",
		4 => "qeytoqrg",
		281 => "qinimi",
		3 => "qrg",
		295 => "qvic",
		299 => "qvicb",
		374 => "rage",
		375 => "ragea",
		477 => "rathechamber",
		50 => "rathemtn",
		430 => "redfeather",
		370 => "relic",
		729 => "resplendent",
		334 => "riftseekers",
		19 => "rivervale",
		282 => "riwwi",
		398 => "roost",
		727 => "rubak",
		230 => "ruja",
		235 => "rujb",
		240 => "rujc",
		245 => "rujd",
		250 => "ruje",
		255 => "rujf",
		260 => "rujg",
		265 => "rujh",
		269 => "ruji",
		273 => "rujj",
		11 => "runnyeye",
		726 => "sarithcity",
		175 => "scarlet",
		89 => "sebilis",
		733 => "sepulcher",
		165 => "shadeweaver",
		150 => "shadowhaven",
		187 => "shadowrest",
		364 => "shadowspine",
		752 => "shardslanding",
		155 => "sharvahl",
		484 => "shiningcity",
		435 => "shipmvm",
		431 => "shipmvp",
		432 => "shipmvu",
		433 => "shippvu",
		434 => "shipuvu",
		439 => "shipworkshop",
		420 => "silyssar",
		125 => "sirens",
		91 => "skyfire",
		371 => "skylance",
		114 => "skyshrine",
		128 => "sleeper",
		288 => "sncrematory",
		286 => "snlair",
		287 => "snplant",
		285 => "snpool",
		31 => "soldunga",
		32 => "soldungb",
		278 => "soldungc",
		212 => "solrotower",
		80 => "soltemple",
		421 => "solteris",
		708 => "somnium",
		14 => "southkarana",
		393 => "southro",
		35 => "sro",
		159 => "sseru",
		162 => "ssratemple",
		438 => "steamfactory",
		56 => "steamfont",
		448 => "steamfontmts",
		399 => "steppes",
		338 => "stillmoona",
		339 => "stillmoonb",
		100 => "stonebrunt",
		396 => "stonehive",
		489 => "stonesnake",
		426 => "suncrest",
		403 => "sunderock",
		83 => "swampofnohope",
		298 => "tacvi",
		231 => "taka",
		236 => "takb",
		241 => "takc",
		246 => "takd",
		251 => "take",
		256 => "takf",
		261 => "takg",
		266 => "takh",
		270 => "taki",
		376 => "takishruins",
		377 => "takishruinsa",
		274 => "takj",
		124 => "templeveeshan",
		172 => "tenebrous",
		417 => "thalassius",
		380 => "theater",
		381 => "theatera",
		164 => "thedeep",
		171 => "thegrey",
		343 => "thenest",
		459 => "thevoida",
		460 => "thevoidb",
		461 => "thevoidc",
		462 => "thevoidd",
		463 => "thevoide",
		464 => "thevoidf",
		465 => "thevoidg",
		711 => "thuledream",
		701 => "thulehouse1",
		702 => "thulehouse2",
		704 => "thulelibrary",
		340 => "thundercrest",
		115 => "thurgadina",
		129 => "thurgadinb",
		96 => "timorous",
		289 => "tipt",
		226 => "torgiran",
		475 => "toskirakk",
		38 => "tox",
		414 => "toxxulia",
		95 => "trakanon",
		183 => "tutorial",
		188 => "tutoriala",
		189 => "tutorialb",
		170 => "twilight",
		297 => "txevu",
		176 => "umbral",
		482 => "underquarry",
		63 => "unrest",
		292 => "uqua",
		401 => "valdeholm",
		108 => "veeshan",
		109 => "veksar",
		112 => "velketor",
		404 => "vergalid",
		158 => "vexthal",
		290 => "vxed",
		119 => "wakening",
		300 => "wallofslaughter",
		101 => "warrens",
		79 => "warslikswood",
		493 => "weddingchapel",
		494 => "weddingchapeldark",
		705 => "well",
		358 => "westkorlach",
		359 => "westkorlacha",
		360 => "westkorlachb",
		361 => "westkorlachc",
		735 => "westsepulcher",
		120 => "westwastes",
		731 => "windsong",
		753 => "xorbb",
		291 => "yxtta",
		419 => "zhisza"
		);
		return $zone_list{$_[0]};
}

1;