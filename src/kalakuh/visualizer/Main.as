package kalakuh.visualizer
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.Sound;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.display.StageDisplayState;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class Main extends Sprite 
	{
		private var reference : FileReference;
		private var button : Sprite;
		private var channel : SoundChannel;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			stage.displayState = StageDisplayState.FULL_SCREEN;
			
			button = new Sprite();
			button.x = 20;
			button.y = 20;
			button.graphics.beginFill(0xFF0000);
			button.graphics.drawCircle(0, 0, 15);
			button.graphics.endFill();
			addChild(button);
			button.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick (e : Event) : void {
			reference = new FileReference();
			reference.addEventListener(Event.SELECT, onSelect);
			reference.browse([new FileFilter(".mp3 files", "*.mp3")]);
		}
		
		private function onSelect (e : Event) : void {
			reference.addEventListener(Event.COMPLETE, onComplete);
			reference.load();
		}
		
		private function onComplete (e : Event) : void {
			reference.removeEventListener(Event.COMPLETE, onComplete);
			reference.removeEventListener(Event.SELECT, onSelect);
			
			var ref : FileReference = e.target as FileReference;
			var arr : ByteArray = ref["data"];
			var sound : Sound = new Sound();
			sound.loadCompressedDataFromByteArray(arr, arr.length);
			channel = sound.play();
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update (e : Event) : void {
			var bytes : ByteArray = new ByteArray();
			SoundMixer.computeSpectrum(bytes);
			graphics.clear();
			graphics.lineStyle(5, 0x44AAFF);
			
			for (var x : uint = 0; x < 512; x += 1) {
				var val : Number = bytes.readFloat();
				
				graphics.moveTo(x, stage.stageHeight / 2);
				graphics.lineTo(x, stage.stageHeight / 2 + (val * 200));
			}
		}
	}
	
}