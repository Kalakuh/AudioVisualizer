package kalakuh.visualizer 
{
	import flash.display.Shape;
	import flash.filters.BlurFilter;
	
	/**
	 * ...
	 * @author Juha Harviainen
	 */
	public class Star extends Shape 
	{
		private var r : Number;
		private var ox : Number;
		private var oy : Number;
		
		public function Star() 
		{
			super();
			r = Math.random() * 1.2 + 0.5;
			graphics.beginFill(0xffffff);
			graphics.drawCircle(0, 0, r + (Math.random() - 0.5) * 1.5);
			filters = [new BlurFilter(4, 4, 2)];
			ox = Math.random() - 0.5;
			oy = Math.random() - 0.5;
			ox *= 5;
			oy *= 5;
		}
		
		public function init () : void {
			var a : int = int(Math.random() * 693);
			for (var i : int = 0; i < a; i++) update();
		}
		
		public function update () : void {
			alpha = 0.85;
			if (scaleX > 4 && Math.random() > 0.9) scaleX = 1;
			else if (x < -300 || y < -300 || x > stage.stageWidth + 300 || y > stage.stageHeight + 300) scaleX = 1;
			scaleY = scaleX;
			x = stage.stageWidth / 2 + ox * (scaleX - 1) * 256;
			y = stage.stageHeight / 2 + oy * (scaleY - 1) * 256;
			if (scaleX > 3) alpha = (4 - scaleX) * 0.85;
			if (scaleX < 1.3) alpha = (scaleX - 1) / 0.3 * 0.85;
			scaleX *= 1.002;
		}
	}

}