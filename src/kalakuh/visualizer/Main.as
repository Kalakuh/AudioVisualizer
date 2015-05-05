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
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
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
		private var np : Text;
		private var text : Text;
		private var renderer : Sprite = new Sprite();
		
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
			
			addChild(renderer);
			np = new Text(2, "Press space to load a song", 10, true);
			addChild(np);
			text = new Text(2.5, "", 40, true);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}
		
		private function onKey (e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.SPACE) {
				removeEventListener(Event.ENTER_FRAME, update);
				array = new Array();
				for (var i : uint = 0; i < 32; i++) {
					array.push(0);
				}
				
				reference = new FileReference();
				reference.addEventListener(Event.SELECT, onSelect);
				reference.browse([new FileFilter(".mp3 files", "*.mp3")]);
			}
		}
		
		private function onSelect (e : Event) : void {
			np.setText("Now playing");
			reference.addEventListener(Event.COMPLETE, onComplete);
			reference.load();
		}
		
		private function onComplete (e : Event) : void {
			reference.removeEventListener(Event.COMPLETE, onComplete);
			reference.removeEventListener(Event.SELECT, onSelect);
			
			var ref : FileReference = e.target as FileReference;
			var arr : ByteArray = ref["data"];
			text.setText(ref.name.substring(0, ref.name.lastIndexOf(".")));
			var sound : Sound = new Sound();
			sound.loadCompressedDataFromByteArray(arr, arr.length);
			if (channel != null) channel.stop();
			channel = sound.play();
			channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			renderer.filters = [new BlurFilter(8, 8, 1)];//, new GlowFilter(0xFFFFFF, 1, 8, 8, 3, 2)];
			addChild(text);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function onSoundComplete (e : Event) : void {
			removeChild(text);
			np.setText("Press space to load a song");
			addChild(button);
		}
		
		private function update (e : Event) : void {
			var bytes : ByteArray = new ByteArray();
			SoundMixer.computeSpectrum(bytes);
			renderer.graphics.clear();
			var c : uint = 0xFFFF99;
			renderer.graphics.lineStyle(2, c);
			
			var vals : Array = new Array(32);
			for (var z : uint = 0; z < 64; z++) {
				vals[z] = 0;
				for (var y : uint = 0; y < 8; y++) {
					vals[z % 32] += bytes.readFloat();
				}
			}
			
			for (var x : uint = 0; x < 32; x += 1) {
				vals[x] /= 16;
				array[x] *= 0.95;
				array[x] += Math.abs(vals[x]);
				array[x] = Math.max(array[x], 0.05);
				c -= (x < 256 ? 0x030000 : -0x030000);
				
				renderer.graphics.beginFill(c);
				renderer.graphics.drawRect(stage.stageWidth / 2 - 256 + (x + 1) * 16 - 13, stage.stageHeight - 10 - array[x] * 30, 10, array[x] * 30);
				renderer.graphics.endFill();
			}
		}
	}
}