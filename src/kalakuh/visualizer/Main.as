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
	import flash.display.Bitmap;
	import flash.filters.*;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class Main extends Sprite 
	{
		private var reference : FileReference;
		private var button : Sprite;
		private var channel : SoundChannel;
		[Embed(source = "load.png")]private var img : Class;
		private var array : Array;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			//stage.displayState = StageDisplayState.FULL_SCREEN;
			
			button = new Sprite();
			button.x = stage.stageWidth / 2 - 2;
			button.y = stage.stageHeight / 2 - 1;
			addChild(button);
			
			var bmp : Bitmap = new img();
			button.addChild(bmp);
			bmp.x -= bmp.width / 2;
			bmp.y -= bmp.width / 2;
			
			filters = [new GlowFilter(0xFFFFFF, 1, 8, 8, 3, 2)];
			
			button.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick (e : Event) : void {
			removeEventListener(Event.ENTER_FRAME, update);
			array = new Array();
			for (var i : uint = 0; i < 512; i++) {
				array.push(0);
			}
			
			reference = new FileReference();
			reference.addEventListener(Event.SELECT, onSelect);
			reference.browse([new FileFilter(".mp3 files", "*.mp3")]);
		}
		
		private function onSelect (e : Event) : void {
			reference.addEventListener(Event.COMPLETE, onComplete);
			reference.load();
		}
		
		private function onComplete (e : Event) : void {
			removeChild(button);
			
			reference.removeEventListener(Event.COMPLETE, onComplete);
			reference.removeEventListener(Event.SELECT, onSelect);
			
			var ref : FileReference = e.target as FileReference;
			var arr : ByteArray = ref["data"];
			var sound : Sound = new Sound();
			sound.loadCompressedDataFromByteArray(arr, arr.length);
			if (channel != null) channel.stop();
			channel = sound.play();
			channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function onSoundComplete (e : Event) : void {
			addChild(button);
		}
		
		private function update (e : Event) : void {
			var bytes : ByteArray = new ByteArray();
			SoundMixer.computeSpectrum(bytes);
			graphics.clear();
			
			for (var x : uint = 0; x < 512; x += 1) {
				graphics.lineStyle(2, 0xFFFF99);// : 0xFFCC66);
				var val : Number = bytes.readFloat();
				array[x] *= 0.95;
				array[x] += Math.abs(val);
				
				graphics.moveTo(stage.stageWidth / 2 + Math.sin((360 * x / 512.0) * Math.PI / 180) * 64, stage.stageHeight / 2 + Math.cos((360 * x / 512.0) * Math.PI / 180) * 64);
				graphics.lineTo(stage.stageWidth / 2 + Math.sin((360 * x / 512.0) * Math.PI / 180) * (64 + array[x] * 20), stage.stageHeight / 2 + Math.cos((360 * x / 512.0) * Math.PI / 180) * (64 + array[x] * 20));
			}
		}
	}
}