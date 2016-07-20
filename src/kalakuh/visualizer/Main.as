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
	
	/**
	 * ...
	 * @author Juha Harviainen
	 */
	
	/**
	 *      TODO list 
	 * ---------------------
	 * ~ Fix 'g'
	 */
	public class Main extends Sprite 
	{
		private var reference : FileReference;
		private var button : Sprite;
		private var channel : SoundChannel;
		private var array : Array;
		private var np : Text;
		private var text : Text;
		private var time : Text;
		private var renderer : Sprite = new Sprite();
		private var stars : Vector.<Star> = new Vector.<Star>();
		private var songLength : uint = 0;
		[Embed(source = "img/space.jpg")]private var bgImg : Class;
		private var background : Bitmap = new bgImg();
		private var bgContainer : Sprite = new Sprite();
		private var playing : Boolean = false;
		
		private static var updFilter : Boolean = true;
		
		public static const NIGHTSHADOW : Pair = new Pair(0xE600FF, 0x2250C2);
		public static const SUMMERDREAM : Pair = new Pair(0x00F794, 0x8DFF46);
		public static const INTO_DARKNESS : Pair = new Pair(0xA10CF7, 0x1D082C);
		public static const FIRE_WITHIN : Pair = new Pair(0xF5A105, 0xEB2C0E);
		public static const BLACK_N_WHITE : Pair = new Pair(0xCCCCCC, 0x333333);
		public static const BLESSED_DAY : Pair = new Pair(0x0FF5CB, 0xF2FA07);
		public static const SPECTRUM : Pair = new Pair(0xF27296, 0x49F249);
		public static const ICICLES : Pair = new Pair(0x05F6FA, 0xFFFFFF);
		public static const STARDUST : Pair = new Pair(0x150E9E, 0xFFFB00);
		public static const EXPERIMENTAL : Pair = new Pair(0xFC44F0, 0x00FFBF);
		private static var songColor : Pair = SPECTRUM;
		private static var customColor : Pair = new Pair(0, 0);
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addChild(bgContainer);
			bgContainer.x = stage.stageWidth / 2;
			bgContainer.y = stage.stageHeight / 2;
			background.x -= background.width / 2;
			background.y -= background.height / 2;
			bgContainer.scaleX = 0.35;
			bgContainer.scaleY = 0.35;
			background.alpha = 0.5;
			bgContainer.addChild(background);
			
			for (var x : uint = 0; x < 200; x++) {
				var star : Star = new Star();
				addChild(star);
				stars.push(star);
				star.init();
			}
			
			array = new Array();
			for (var i : uint = 0; i < 128; i++) {
				array.push(0);
			}
			
			addChild(renderer);
			np = new Text(2, "Press space to load a song", 150, true);
			addChild(np);
			text = new Text(2.4, "", 180, true);
			time = new Text(2, "", 220, true);
			this.contextMenu = CustomContextMenu.createContextMenu();
			
			mouseEnabled = false;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		public static function setSongColor (newColor : Pair) : void {
			songColor = newColor;
			updFilter = true;
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
			array = new Array();
			for (var i : uint = 0; i < 128; i++) {
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
			try { // if the song is reaaaaally long, this loop will process so long that Flash throws an Error
				while (arr.bytesAvailable > 0) {
					var num : int = arr.readByte();
					color += Math.abs(num);
					if (arr.bytesAvailable % 3 == 0) r += (num + 128);
					else if (arr.bytesAvailable % 3 == 1) g += (num + 128);
					else b += (num + 128)
				}	
			} catch (e : Error) {
				// lolz
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
			songLength = int(sound.length / 1000);
			
			addChild(text);
			addChild(time);
			playing = true;
			bgContainer.scaleX = bgContainer.scaleY = 0.35;
		}
		
		private function onSoundComplete (e : Event) : void {
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			removeChild(text);
			removeChild(time);
			np.setText("Press space to load a song");
			playing = false;
		}
		
		private function update (e : Event) : void {
			var bytes : ByteArray = new ByteArray();
			SoundMixer.computeSpectrum(bytes, true, 0);
			
			if (playing) {
				var secs : int = int(channel.position / 1000);
				time.setText(int(secs / 60) + ":" + ((secs % 60) < 10 ? "0" : "") + (secs % 60) + " - " + int(songLength / 60) + ":" + ((songLength % 60) < 10 ? "0" : "") + songLength % 60);
			}
			if (updFilter) updFilter = false, renderer.filters = [new BlurFilter(4, 4, 1)];
			var vals : Array = new Array();
			var sum : Number = 0;
			var left : Number = 0;
			var right : Number = 0;
			for (var z : uint = 0; z < 256; z++) {
				vals[z] = 0;
				if (playing) {
					var val : Number = bytes.readFloat();
					sum += Math.abs(val);
					if (z % 128 < 64) left += val;
					else right += val;
					vals[z % 128] += val;
				}
			}
			var avg : Number = sum / 4 / 256;
			var lavg : Number = left / 4 / 128;
			var ravg : Number = right / 4 / 128;
			if (playing) for each (var star : Star in stars) star.update();
			renderer.graphics.clear();
			var sf : uint = songColor.first;
			var ss : uint = songColor.second;
			if (sf == 0) {
				sf = customColor.first;
				ss = customColor.second;
			}
			var c : uint = sf;
			
			if (playing) bgContainer.scaleX += (songLength / 2 - secs) * 0.00120 / songLength;
			if (playing) bgContainer.scaleY += (songLength / 2 - secs) * 0.00120 / songLength;
			
			for (var x : uint = 0; x < 128; x += 1) {
				vals[x] /= 1.5;
				array[x] *= 0.835;
				array[x] += vals[x];
				c += int(((((ss & 0xFF0000) >> 16) - ((sf & 0xFF0000) >> 16)) / 128)) << 16;
				c += int(((((ss & 0xFF00) >> 8) - ((sf & 0xFF00) >> 8)) / 128)) << 8;
				c += int(((((ss & 0xFF)) - ((sf & 0xFF))) / 128));
				
				renderer.graphics.lineStyle(2, c);
				renderer.graphics.beginFill(c);
				renderer.graphics.drawRect(7 * x + (stage.stageWidth - 128 * 7) / 2, stage.stageHeight / 2, 3, -Math.min(-array[x], -0.1) * 45);
				renderer.graphics.endFill();
			}
		}
	}
}