package kalakuh.visualizer 
{
	import flash.ui.ContextMenu;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.ui.ContextMenuItem;
	/**
	 * ...
	 * @author Juha Harviainen
	 */
	public class CustomContextMenu 
	{
		
		public function CustomContextMenu() 
		{
			
		}
		
		public static function createContextMenu () : ContextMenu {
			var menu : ContextMenu = new ContextMenu();
			
			menu.hideBuiltInItems();
			var credits : ContextMenuItem = new ContextMenuItem("Made by Juha Harviainen", false);
			var theme : ContextMenuItem = new ContextMenuItem("Select a theme:", true);
			var nightshadow : ContextMenuItem = new ContextMenuItem("Night Shadow", true);
			nightshadow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onNightshadow);
			var summerdream : ContextMenuItem = new ContextMenuItem("Summer Dream");
			summerdream.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSummerdream);
			var intodarkness : ContextMenuItem = new ContextMenuItem("Into Darkness");
			intodarkness.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onIntodarkness);
			var firewithin : ContextMenuItem = new ContextMenuItem("Fire Within");
			firewithin.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onFirewithin);
			var blessedday : ContextMenuItem = new ContextMenuItem("Blessed Day");
			blessedday.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onBlessedday);
			var spectrum : ContextMenuItem = new ContextMenuItem("Spectrum");
			spectrum.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSpectrum);
			var blacknwhite : ContextMenuItem = new ContextMenuItem("Black 'n' White");
			blacknwhite.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onBlacknwhite);
			var automagical : ContextMenuItem = new ContextMenuItem("Automagical");
			automagical.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onAutomagical);
			
			menu.customItems = [credits, theme, nightshadow, summerdream, intodarkness, firewithin, blessedday, spectrum, blacknwhite, automagical];
			
			return menu;
		}
		
		private static function onNightshadow (e : ContextMenuEvent) : void { Main.setSongColor(Main.NIGHTSHADOW); }
		private static function onSummerdream (e : ContextMenuEvent) : void { Main.setSongColor(Main.SUMMERDREAM); }
		private static function onIntodarkness (e : ContextMenuEvent) : void { Main.setSongColor(Main.INTO_DARKNESS); }
		private static function onFirewithin (e : ContextMenuEvent) : void { Main.setSongColor(Main.FIRE_WITHIN); }
		private static function onBlessedday (e : ContextMenuEvent) : void { Main.setSongColor(Main.BLESSED_DAY); }
		private static function onSpectrum (e : ContextMenuEvent) : void { Main.setSongColor(Main.SPECTRUM); }
		private static function onBlacknwhite (e : ContextMenuEvent) : void { Main.setSongColor(Main.BLACK_N_WHITE); }
		private static function onAutomagical (e : ContextMenuEvent) : void { Main.setSongColor(new Pair(0, 0)); }
	}

}