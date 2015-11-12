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
	import flash.ui.ContextMenu;
	import flash.utils.ByteArray;
	import flash.display.StageDisplayState;
	import flash.display.Bitmap;
	import flash.filters.*;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import kalakuh.visualizer.font.Star;
	
	/**
	 * ...
	 * @author Kalakuh
	 */
	public class Main extends Sprite 
	{
		private var reference : FileReference;
		private var button : Sprite;
		private var channel : SoundChannel;
		private var array : Array;
		private var np : Text;
		private var text : Text;
		private var renderer : Sprite = new Sprite();
		private var stars : Vector.<Star> = new Vector.<Star>();
		
		public static const NIGHTSHADOW : Pair = new Pair(0xE600FF, 0x2250C2);
		public static const SUMMERDREAM : Pair = new Pair(0x00F794, 0x8DFF46);
		public static const INTO_DARKNESS : Pair = new Pair(0xA10CF7, 0x1D082C);
		public static const FIRE_WITHIN : Pair = new Pair(0xF5A105, 0xEB2C0E);
		public static const BLACK_N_WHITE : Pair = new Pair(0xCCCCCC, 0x333333);
		public static const BLESSED_DAY : Pair = new Pair(0x0FF5CB, 0xF2FA07);
		public static const SPECTRUM : Pair = new Pair(0xF27296, 0x49F249);
		private static var songColor : Pair = new Pair(0, 0);
		private static var customColor : Pair = new Pair(0, 0);
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			for (var x : uint = 0; x < 150; x++) {
				var star : Star = new Star();
				star.x = Math.random() * stage.stageWidth;
				star.y = Math.random() * stage.stageHeight;
				addChild(star);
				stars.push(star);
			}
			
			addChild(renderer);
			np = new Text(2, "Press space to load a song", 10, true);
			addChild(np);
			text = new Text(2.4, "", 40, true);
			this.contextMenu = CustomContextMenu.createContextMenu();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		}
		
		public static function setSongColor (newColor : Pair) : void {
			songColor = newColor;
		}
		
		private function onKey (e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.SPACE) {
				reference = new FileReference();
				reference.addEventListener(Event.SELECT, onSelect);
				reference.browse([new FileFilter(".mp3 files", "*.mp3")]);
			} else if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.UP) {
				if (stage.displayState == StageDisplayState.NORMAL) {
					stage.displayState = StageDisplayState.FULL_SCREEN;
				} else {
					stage.displayState = StageDisplayState.NORMAL;
				}
			}
		}
		
		private function onSelect (e : Event) : void {
			removeEventListener(Event.ENTER_FRAME, update);
			array = new Array();
			for (var i : uint = 0; i < 64; i++) {
				array.push(0);
			}
			np.setText("Now playing");
			reference.addEventListener(Event.COMPLETE, onComplete);
			reference.load();
		}
		
		private function onComplete (e : Event) : void {
			reference.removeEventListener(Event.COMPLETE, onComplete);
			reference.removeEventListener(Event.SELECT, onSelect);
			
			var ref : FileReference = e.target as FileReference;
			var arr : ByteArray = ref["data"];
			
			var color : uint = 0;
			var r : uint = 0;
			var g : uint = 0;
			var b : uint = 0;
			while (arr.bytesAvailable > 0) {
				var num : int = arr.readByte();
				color += Math.abs(num);
				if (arr.bytesAvailable % 3 == 0) r += (num + 128);
				else if (arr.bytesAvailable % 3 == 1) g += (num + 128);
				else b += (num + 128)
			}
			r %= 256;
			g %= 256;
			b %= 256;
			customColor = new Pair(color, (r<<16)|(g<<8)|b);
			arr.position = 0;
			
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
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			removeChild(text);
			np.setText("Press space to load a song");
		}
		
		private function update (e : Event) : void {
			var bytes : ByteArray = new ByteArray();
			SoundMixer.computeSpectrum(bytes, true, 0);
			
			var vals : Array = new Array();
			var sum : Number = 0;
			var left : Number = 0;
			var right : Number = 0;
			for (var z : uint = 0; z < 128; z++) {
				vals[z] = 0;
				for (var y : uint = 0; y < 4; y++) {
					var val : Number = Math.abs(bytes.readFloat());
					sum += val;
					if (z % 64 < 32) left += val;
					else right += val;
					vals[z % 64] += val;
				}
			}
			var avg : Number = sum / 4 / 128;
			var lavg : Number = left / 4 / 64;
			var ravg : Number = right / 4 / 64;
			for each (var star : Star in stars) star.update((25 - 1 / (0.04 + avg)) / 85, ((10 - 1 / (0.1 + lavg)) - 2 * (10 - 1 / (0.1 + ravg))) / 85);
			renderer.graphics.clear();
			var sf : uint = songColor.first;
			var ss : uint = songColor.second;
			if (sf == 0) {
				sf = customColor.first;
				ss = customColor.second;
			}
			var c : uint = sf;
			
			for (var x : uint = 0; x < 64; x += 1) {
				vals[x] /= 10;
				array[x] *= 0.95;
				array[x] += Math.abs(vals[x]);
				array[x] = Math.max(array[x], 0.05);
				c += int(((((ss & 0xFF0000) >> 16) - ((sf & 0xFF0000) >> 16)) / 64)) << 16;
				c += int(((((ss & 0xFF00) >> 8) - ((sf & 0xFF00) >> 8)) / 64)) << 8;
				c += int(((((ss & 0xFF)) - ((sf & 0xFF))) / 64));
				
				renderer.graphics.lineStyle(2, c);
				renderer.graphics.beginFill(c);
				renderer.graphics.drawRect(stage.stageWidth / 2 - 512 + (x + 1) * 16 - 13, stage.stageHeight - 10 - array[x] * 30, 10, array[x] * 30);
				renderer.graphics.endFill();
			}
		}
	}
}