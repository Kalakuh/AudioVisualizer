package kalakuh.visualizer.font 
{
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author Juha Harviainen
	 */
	public class Star extends Shape 
	{
		private var r : Number;
		private var velX : Number = 0;
		private var velY : Number = 0;
		
		public function Star() 
		{
			super();
			r = Math.random() * 1.2 + 0.5;
			graphics.beginFill(0xffffff);
			graphics.drawCircle(0, 0, r + (Math.random() - 0.5) * 1.5);
		}
		
		public function update (dx : Number, dy : Number) : void {
			this.x += velX * r;
			this.y += velY * r;
			if (x < 0) x += stage.stageWidth;
			if (y < 0) y += stage.stageHeight;
			if (x > stage.stageWidth) x -= stage.stageWidth;
			if (y > stage.stageHeight) y -= stage.stageHeight;
			velX *= 0.965;
			velY *= 0.965;
			velX += dx;
			velY += dy;
		}
	}

}