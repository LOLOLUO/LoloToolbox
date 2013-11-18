package app.module.imageCompressor
{
	import app.common.AppCommon;
	import app.controls.GroupBox;
	
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.events.ItemClickEvent;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	
	import spark.components.Button;
	import spark.components.HSlider;
	import spark.components.NavigatorContent;
	import spark.components.RadioButtonGroup;
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;
	
	
	/**
	 * 将传统的Swf中的导出类，对应的生成序列帧位图
	 * @author LOLO
	 */
	public class ImageCompressor extends NavigatorContent
	{
		public var contentC:GroupBox;
		public var typeGroup:RadioButtonGroup;
		
		public var directoryPathText:TextInput;
		public var qualityHS:HSlider;
		public var qualityText:TextInput;
		public var compressBtn:Button;
		
		/**用于选择文件夹*/
		private var _directory:File;
		/**用于加载图片*/
		private var _image:Loader;
		/**需要保存的文件列表*/
		private var _imageList:Vector.<File>;
		/**当前正在压缩的图像*/
		private var _currentImage:File;
		
		
		protected function addedToStageHandler(event:Event):void
		{
			_directory = new File();
			_directory.addEventListener(Event.SELECT, directory_selectHandler);
			
			_image = new Loader();
			_image.contentLoaderInfo.addEventListener(Event.COMPLETE, image_completeHandler);
			
			AppCommon.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler();
		}
		
		
		private function stage_resizeHandler(event:Event=null):void
		{
			contentC.x = AppCommon.stage.stageWidth - contentC.width >> 1;
			contentC.y = AppCommon.stage.stageHeight - contentC.height - AppCommon.toolbox.toolListVS.y >> 1;
		}
		
		
		
		/**
		 * 点击选择目录按钮
		 * @param event
		 */
		protected function directoryPathBtn_clickHandler(event:MouseEvent):void
		{
			_directory.browseForDirectory("请选择包含要压缩图像文件的目录");
		}
		
		/**
		 * 选中了文件夹
		 * @param event
		 */
		private function directory_selectHandler(event:Event):void
		{
			_imageList = new Vector.<File>();
			var arr:Array = _directory.getDirectoryListing();
			
			for(var i:int = 0; i < arr.length; i++) {
				var file:File = arr[i];
				if(file.extension == null) continue;
				var extension:String = file.extension.toLocaleLowerCase();
				if(extension == "jpg" || extension == "jpeg" || extension == "png") _imageList.push(file);
			}
			
			if(_imageList.length == 0) {
				Alert.show("所选的目录没有图像文件", "提示");
			}
			else {
				compressBtn.enabled = true;
				directoryPathText.text = _directory.nativePath;
			}
		}
		
		
		
		
		/**
		 * 点击压缩按钮
		 * @param event
		 */
		protected function compressBtn_clickHandler(event:MouseEvent):void
		{
			compressBtn.enabled = false;
			AppCommon.toolbox.progressPane.show(_imageList.length);
			TweenMax.delayedCall(0.5, compressNextImage);
		}
		
		/**
		 * 压缩下一张图像
		 */
		private function compressNextImage():void
		{
			_currentImage = _imageList.shift();
			_image.load(new URLRequest(_currentImage.nativePath));
		}
		
		private function image_completeHandler(event:Event):void
		{
			var imageData:BitmapData = (_image.content as Bitmap).bitmapData;
			var fileType:String = typeGroup.selectedValue as String;
			if(fileType == "auto") fileType = _currentImage.extension.toLocaleLowerCase();
			
			var encodedBytes:ByteArray = (fileType == "png") ? new PNGEncoder().encode(imageData) : new JPEGEncoder(qualityHS.value).encode(imageData);
			var name:String = _currentImage.name;
			var arr:Array = _currentImage.name.split(",");
			var name:String = "";
			for(var i:int=0; i < arr.length-1; i++) name += arr[i] + ".";
			
			var file:File = new File(AppCommon.toolbox.settingPanel.filePathText.text + "exportSwf" + "/" + name + fileType);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(encodedBytes);
			fs.close();
			
			AppCommon.toolbox.progressPane.addProgress();
			TweenMax.delayedCall(0.01, compressNextImage);
		}
		
		
		
		/**
		 * 导出类型有改变
		 * @param event
		 */
		protected function typeGroup_itemClickHandler(event:ItemClickEvent):void
		{
			qualityHS.enabled = qualityText.enabled = (typeGroup.selectedValue != "png");
		}
		
		
		/**
		 * 导出品质有改变
		 * @param event
		 */
		protected function qualityHS_changeHandler(event:Event):void
		{
			qualityText.text = qualityHS.value.toString();
		}
		
		protected function qualityText_focusOutHandler(event:FocusEvent):void
		{
			var value:int = int(qualityText.text);
			if(value < 50) value = 50;
			else if(value > 95) value = 95;
			qualityText.text = value.toString();
		}
		
		protected function qualityText_changeHandler(event:TextOperationEvent):void
		{
			qualityHS.value = int(qualityText.text);
		}
		//
	}
}