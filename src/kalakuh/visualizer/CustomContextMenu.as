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
		
		public static var menu : ContextMenu;
		
		public function CustomContextMenu() 
		{
			
		}
		
		public static function createContextMenu () : ContextMenu {
			menu = new ContextMenu();
			
			menu.hideBuiltInItems();
			var credits : ContextMenuItem = new ContextMenuItem("Made by Juha Harviainen", false);
			var theme : ContextMenuItem = new ContextMenuItem("Select a theme:", true);
			menu.customItems = [credits, theme];
			
			newStyle("Automagical", new Pair(0, 0));
			newStyle("Night Shadow", Main.NIGHTSHADOW);
			newStyle("Blessed Day", Main.BLESSED_DAY);
			//newStyle("Summer Dream", Main.SUMMERDREAM);
			newStyle("Into Darkness", Main.INTO_DARKNESS);
			newStyle("Fire Within", Main.FIRE_WITHIN);
			newStyle("Spectrum", Main.SPECTRUM);
			newStyle("Black 'n' White", Main.BLACK_N_WHITE);
			newStyle("Icicles", Main.ICICLES);
			newStyle("Stardust", Main.STARDUST);
			newStyle("Experimental", Main.EXPERIMENTAL);
			
			menu.customItems[2].separatorBefore = true;
			
			return menu;
		}
		
		private static function newStyle (name : String, color : Pair) : void {
			var style : ContextMenuItem = new ContextMenuItem(name);
			var onClick : Function = function(e : ContextMenuEvent) : void {
				Main.setSongColor(color);
			}
			style.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onClick);
			menu.customItems.push(style);
		}
	}
}