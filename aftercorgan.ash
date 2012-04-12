/*
**Wole's aftercore Steel Organ Script**

http://kolmafia.us/showthread.php?t=
This is meant for aftercore, but could in theory be used in-run. 
Settings are useMall = true/false
*/

script "aftercorgan.ash";
notify "Wole";

import <zlib.ash>;

string afterCorganVersion = "0.02";		// This is the script's version!


//int Aftercore_PAGE = 9999;
// check_version("Aftercore", "Aftercore", afterCorganVersion, Aftercore_PAGE);


//Settings
setvar("woleUseMall", true);

//Constants and stuff
boolean useMall = vars["woleUseMall"].to_boolean();

familiar oldFam = my_familiar();
familiar itemFam = best_fam("items");

boolean hasMusk = have_skill($skill[musk]);
boolean hasCantata = have_skill($skill[cantata]);
boolean hasSmooth = have_skill($skill[smooth]);
boolean hasSonata = have_skill($skill[sonata]);

//Want a boolean to check if I have an item. Not really necessary, but makes it cleaner later
boolean haveItem(item i){
   if (item_amount(i) >= 1) {
      return true;
      }
   else return false;
}

//This checks for Combat modifier skills and casts/shrugs them
void combatModBuff(string rate){
	if (rate = "plus") {
		if (have_effect($effect[smooth movements]) > 0) {
			cli_execute("shrug smooth movements");
		}
		if (have_effect($effect[Sonata of Sneakiness]) > 0) {
			cli_execute("shrug Sonata of Sneakiness");
		}
		if (hasMusk && have_effect($effect[musk]) == 0){
			use_skill($skill[musk]);
		}
		if (hasCantata && have_effect($effect[cantata]) == 0){
			use_skill($skill[cantata]);
		}
	}
	if (rate = "minus") {
		if (have_effect($effect[musk]) > 0) {
			cli_execute("shrug musk");
		}
		if (have_effect($effect[cantata]) > 0) {
			cli_execute("shrug cantata");
		}
		if (hasSmooth && have_effect($effect[smooth movements]) == 0){
			use_skill($skill[smooth movements]);
		}
		if (hasSonata && have_effect($effect[sonata of sneakiness]) == 0){
			use_skill($skill[sonata of sneakiness]);
		}
	}
}

//This runs adventures
void runAdv(location place) {
   if(my_adventures() >=1) {
      adventure(1, place);
   }
   else {
      print("Out of adventures","red");
      abort();
   }
}

//Data type for the items that a musician wants, and for if he has gotten an item
record musician {
   item item1;
   item item2;
   boolean isdone;
};

//Map for what Golly wants, using above data type
musician [string] gollyMap;

gollyMap["Bognort"].item1 = $item[giant marshmallow]; 
gollyMap["Bognort"].item2 = $item[gin-soaked blotter paper]; 
gollyMap["Bognort"].isdone = false; 

gollyMap["Stinkface"].item1 = $item[beer-scented teddy bear]; 
gollyMap["Stinkface"].item2 = $item[gin-soaked blotter paper]; 
gollyMap["Stinkface"].isdone = false; 

gollyMap["Flargwurm"].item1 = $item[booze-soaked cherry]; 
gollyMap["Flargwurm"].item2 = $item[sponge cake]; 
gollyMap["Flargwurm"].isdone = false; 

gollyMap["Jim"].item1 = $item[comfy pillow]; 
gollyMap["Jim"].item2 = $item[sponge cake]; 
gollyMap["Jim"].isdone = false; 

//This checks if I have enough stuff for Golly. Excess code is for clarity.
boolean gollyDone() {
   int ma = item_amount($item[giant marshmallow]);
   int gi = item_amount($item[gin-soaked blotter paper]);
   int be = item_amount($item[beer-scented teddy bear]);
   int bo = item_amount($item[booze-soaked cherry]);
   int sp = item_amount($item[sponge cake]);
   int co = item_amount($item[comfy pillow]);
   if ((ma + gi + be) == 2 && (bo + sp + co) == 2) {
      return true;
   }
   else return false;
}

//This give and item to a musician in the Arena.
void giveToGolly(item i, string who){
   int item_number = i.to_int();
   print("Giving " + i + "to " + who, "blue");
   visit_url("pandamonium.php?action=sven&bandmember=" + who + "&togive=" + item_number + "&preaction=try&bandcamp=Give+It");
}

//This maxes items, casts +combat/clears -combat buffs if you have them and finishes the Comedy Club parts
void comedyClub() {
   maximize("item", false);
   print("Trying to get Observational Glasses", "blue");
   while(item_amount($item[Observational glasses]) == 0) {
   combatModBuff("plus");
   runAdv($location[Belilafs Comedy Club]);
   }
   equip($slot[acc3], $item[Observational glasses]);
   equip($slot[weapon], $item[hilarious comedy prop]);
   equip($slot[off-hand], $item[Comic Hellhound Puppet]);
   foreach string in $strings[insult, prop, observe] {
      visit_url("pandamonium.php?action=mourn&preaction="+string);
   }
   print("Comedy club done", "blue");
}

//This maxes items, casts -combat/clears +combat buffs if you have them and finishes the Arena parts
void arena() {
   maximize("item",false);
   print("Trying to get stuff for musicians", "blue");
   
//Gather the non-com drops until you can finish it
   while (!gollyDone()) {
      combatModBuff("minus");
      runAdv($location[Hey Deze Arena]);
   }
//Give the items to the musicians
   foreach key in gollyMap {
      if (!gollyMap[key].isdone && haveItem(gollyMap[key].item1)) {
         giveToGolly(gollyMap[key].item1, key);
         gollyMap[key].isdone = true;
      }
      if (!gollyMap[key].isdone && haveItem(gollyMap[key].item2)) {
         giveToGolly(gollyMap[key].item2, key);
         gollyMap[key].isdone = true;
      }
   }
   print("Arena done", "blue");
}
//This buys imp airs and bus passes if needed and then clears the Panda Square
void pandaSquare() {
   print("Clearing Panda Square", "blue");
   visit_url("pandamonium.php?action=moan");
   int airs = item_amount($item[imp air]);
   int passes = item_amount($item[bus pass]);
   if (useMall && (airs < 5 || passes < 5)) {
      print("Buying remaining airs and passes from mall", "blue");
      buy(5 - airs, $item[imp air]);
      buy(5 - passes, $item[bus pass]);
   }
   if (!useMall && (airs < 5 || passes < 5)){
      print("Farming imp airs in the Comedy Club", "blue");
      while (item_amount($item[imp air]) < 5) {
         runAdv($location[Comedy Club]);
      }
      print("Farming bus passes in the Comedy Club", "blue");
      while (item_amount($item[bus pass]) < 5) {
         runAdv($location[Hey Deze Arena]);
      }
   }
   visit_url("pandamonium.php?action=moan");
   print("Panda Square done", "blue");
}

//This switches to an +’tem fam, runs everything, and gathers the steel organ
void main(){
   print("Let's go!", "blue");
   visit_url("pandamonium.php");
   use_familiar(itemFam);
   comedyClub();
   arena();
   pandaSquare();
   visit_url("pandamonium.php?action=temp");
   use_familiar(oldFam);
   print("Hopefully we're done now, don't forget to drink your steel margarita!", "green");
}
