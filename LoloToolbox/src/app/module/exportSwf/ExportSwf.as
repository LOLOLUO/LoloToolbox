package app.module.exportSwf
{
	import app.common.AppCommon;
	import app.common.AppConstants;
	import app.controls.GridBackground;
	import app.controls.GroupBox;
	import app.utils.SwfUtil;
	
	import com.greensock.TweenMax;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import lolo.utils.StringUtil;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.graphics.codec.PNGEncoder;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.List;
	import spark.components.NavigatorContent;
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	
	
	/**
	 * 将传统的Swf中的导出类，对应的生成序列帧位图
	 * @author LOLO
	 */
	public class ExportSwf extends NavigatorContent
	{
		public var gridBG:GridBackground;
		public var controlBox:GroupBox;
		
		public var swfPathText:TextInput;
		public var openSwfBtn:Button;
		
		public var elementList:List;
		
		public var allSelectCB:CheckBox;
		
		public var boundsWidthText:TextInput;
		public var boundsHeightText:TextInput;
		public var setBoundsBtn:Button;
		public var setAllBoundsBtn:Button;
		
		public var exportBtn:Button;
		
		
		/**用于浏览和加载SWF文件数据*/
		private var _swfFile:File;
		/**用于显示元件的容器*/
		private var _elementC:UIComponent;
		/**需要导出的元件列表*/
		private var _exportElementList:Array;
		
		
		
		public function ExportSwf()
		{
			super();
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			_elementC = new UIComponent();
			_elementC.mouseEnabled = _elementC.mouseChildren = false;
			_elementC.x = gridBG.x;
			_elementC.y = gridBG.y;
			this.addElement(_elementC);
			
			_swfFile = new File();
			_swfFile.addEventListener(Event.SELECT, swfFile_eventHandler);
			_swfFile.addEventListener(Event.COMPLETE, swfFile_eventHandler);
			
			AppCommon.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler();
		}
		
		
		private function stage_resizeHandler(event:Event=null):void
		{
			controlBox.x = AppCommon.stage.stageWidth - controlBox.width - 5;
			gridBG.width = AppCommon.stage.stageWidth - gridBG.x - controlBox.width - 15;
			gridBG.height = AppCommon.stage.stageHeight - AppCommon.toolbox.toolListVS.y - gridBG.y - 5;
			if(elementList.selectedItem) drawElementBounds(elementList.selectedItem);
		}
		
		
		
		
		/**
		 * 点击打开SWF文件按钮
		 * @param event
		 */
		protected function openSwfBtn_clickHandler(event:MouseEvent):void
		{
			_swfFile.browseForOpen("请选择要载入的SWF文件", [AppConstants.FILE_FILTER_SWF]);
		}
		
		private function swfFile_eventHandler(event:Event):void
		{
			if(event.type == Event.SELECT) {
				swfPathText.text = _swfFile.nativePath;
				_swfFile.load();
				boundsWidthText.enabled = boundsHeightText.enabled = setBoundsBtn.enabled = setAllBoundsBtn.enabled = false;
				exportBtn.enabled = false;
			}
			else {
				SwfUtil.parseSwf(_swfFile.data, parseSwfComplete);
			}
		}
		
		/**
		 * 解析SWF数据完成
		 * @param list
		 */
		private function parseSwfComplete(list:Array):void
		{
			//绘制所有元件的边界
			for(var i:int=0; i < list.length; i++)
			{
				var data:Object = list[i];
				data.export = true;
				var bounds:Rectangle = data.instance.getBounds(data.instance);
				if(data.instance is MovieClip) {
					for(var n:int=1; n < data.instance.totalFrames; n++) {
						data.instance.gotoAndStop(n + 1);
						var rect:Rectangle = data.instance.getBounds(data.instance);
						if(rect.x < bounds.x) bounds.x = rect.x;
						if(rect.y < bounds.y) bounds.y = rect.y;
						if(rect.width > bounds.width) bounds.width = rect.width;
						if(rect.height > bounds.height) bounds.height = rect.height;
					}
				}
				bounds.x = int(bounds.x);
				bounds.y = int(bounds.y);
				bounds.width = Math.ceil(bounds.width);
				bounds.height = Math.ceil(bounds.height);
				data.bounds = bounds;
				
				drawElementBounds(data);
			}
			
			
			elementList.dataProvider = new ArrayList(list);
			allSelectCB.selected = true;
			
			playOrStopCurrentElement(false);
			_elementC.removeChildren();
			exportBtn.enabled = true;
		}
		
		
		/**
		 * 元件列表有选中
		 * @param event
		 */
		protected function elementList_changeHandler(event:IndexChangeEvent):void
		{
			var data:Object = elementList.selectedItem;
			
			playOrStopCurrentElement(false);
			_elementC.removeChildren();
			_elementC.addChild(data.instance);
			playOrStopCurrentElement(true);
			
			boundsWidthText.text = data.bounds.width;
			boundsHeightText.text = data.bounds.height;
			boundsWidthText.enabled = boundsHeightText.enabled = setBoundsBtn.enabled = setAllBoundsBtn.enabled = true;
		}
		
		/**
		 * 绘制元件的边界，并将该元件居中到舞台（格子背景）
		 * @param element
		 * @param bounds
		 */
		private function drawElementBounds(item:Object):void
		{
			var element:Sprite = item.instance;
			var bounds:Rectangle = item.bounds;
			
			element.graphics.clear();
			element.graphics.beginFill(0, 0);
			element.graphics.lineStyle(1, 0xCC0000);
			element.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
			element.graphics.endFill();
			
			element.x = (gridBG.width - bounds.width) / 2 - bounds.x;
			element.y = (gridBG.height - bounds.height) / 2 - bounds.y;
		}
		
		/**
		 * 设置并绘制元件的边界大小，并将该元件居中到舞台（格子背景）
		 * @param item
		 * @param width
		 * @param height
		 */
		private function setElementBounds(item:Object, width:uint, height:uint):void
		{
			item.bounds.x -= width - item.bounds.width >> 1;
			item.bounds.y -= height - item.bounds.height >> 1;
			item.bounds.width = width;
			item.bounds.height = height;
			
			drawElementBounds(item);
		}
		
		/**
		 * 点击设置边界按钮
		 * @param event
		 */
		protected function setBoundsBtn_clickHandler(event:MouseEvent):void
		{
			var width:uint = uint(boundsWidthText.text);
			var height:uint = uint(boundsHeightText.text);
			
			if(event.target == setBoundsBtn) {
				setElementBounds(elementList.selectedItem, width, height);
			}
			else {
				for(var i:int=0; i < elementList.dataProvider.length; i++) {
					setElementBounds(elementList.dataProvider.getItemAt(i), width, height);
				}
			}
		}
		
		
		
		/**
		 * 停止或者播放当前正在查看的元件（如果元件是MC）
		 * @param isPlay
		 */
		private function playOrStopCurrentElement(isPlay:Boolean):void
		{
			if(_elementC.numChildren == 0) return;
			var mc:MovieClip = _elementC.getChildAt(0) as MovieClip;
			if(mc) {
				isPlay
				? mc.addEventListener(Event.ENTER_FRAME, currentElement_enterFrameHandler)
				: mc.removeEventListener(Event.ENTER_FRAME, currentElement_enterFrameHandler);
			}
		}
		private function currentElement_enterFrameHandler(event:Event):void
		{
			var mc:MovieClip = event.target as MovieClip;
			if(mc.currentFrame == mc.totalFrames) {
				mc.gotoAndStop(1);
			}
			else {
				mc.nextFrame();
			}
		}
		
		
		
		/**
		 * 全选或者反选所有导出元件
		 * @param event
		 */
		protected function allSelectCB_clickHandler(event:MouseEvent):void
		{
			for(var i:int = 0; i < elementList.dataGroup.numChildren; i++) {
				(elementList.dataGroup.getChildAt(i) as SwfItemRenderer).exportCB.selected = allSelectCB.selected;
			}
		}
		
		
		
		/**
		 * 点击导出按钮
		 * @param event
		 */
		protected function exportBtn_clickHandler(event:MouseEvent):void
		{
			//找出要导出的元件列表
			_exportElementList = [];
			for(var i:int = 0; i < elementList.dataProvider.length; i++) {
				var itemData:Object = elementList.dataProvider.getItemAt(i);
				if(itemData.export) {
					_exportElementList.push(itemData);
				}
			}
			
			if(_exportElementList.length == 0) {
				Alert.show("没有需要导出的元件！", "提示");
				return;
			}
			
			AppCommon.toolbox.progressPane.show(_exportElementList.length);
			
			//删除根目录的内容
			var rootDirectory:File = new File(AppCommon.toolbox.settingPanel.filePathText.text + "exportSwf");
			try { rootDirectory.deleteDirectory(true); } catch(error:Error) { }
			
			TweenMax.delayedCall(0.5, exportNextElement);
		}
		
		/**
		 * 导出下一个元件
		 */
		private function exportNextElement():void
		{
			var info:Object = _exportElementList.shift();
			var element:Sprite = info.instance;
			var mc:MovieClip = element as MovieClip;
			var bounds:Rectangle = info.bounds;
			var name:String = info.name.replace("::", ".");
			element.graphics.clear();
			
			//根目录
			var rootDirectory:File = new File(AppCommon.toolbox.settingPanel.filePathText.text + "exportSwf");
			if(mc) {
				for(var i:int=0; i < mc.totalFrames; i++) {
					mc.gotoAndStop(i+1);
					savePng(
						new File(rootDirectory.nativePath + "/" + name +"/" + StringUtil.leadingZero(i+1, String(mc.totalFrames).length) +".png"),
						bounds, mc
					);
				}
			}
			else {
				savePng(
					new File(rootDirectory.nativePath + "/" + name +"/1.png"),
					bounds, element
				);
			}
			
			drawElementBounds(info);
			AppCommon.toolbox.progressPane.addProgress();
			
			//导出完毕
			if(_exportElementList.length == 0) {
				Alert.show("导出完毕！\n可点击[OK]查看。", "提示", Alert.OK|Alert.CANCEL, null, closeHandler);
				AppCommon.toolbox.progressPane.hide();
			}
			else {
				TweenMax.delayedCall(0.01, exportNextElement);
			}
		}
		
		/**
		 * 保存一张png图像
		 * @param file
		 * @param bounds
		 * @param drawTarget
		 */
		private function savePng(file:File, bounds:Rectangle, drawTarget:DisplayObject):void
		{
			var bitmapData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
			bitmapData.draw(drawTarget, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(new PNGEncoder().encode(bitmapData));
			fs.close();
		}
		
		
		/**
		 * 保存完毕，查看目录
		 * @param event
		 */
		private function closeHandler(event:CloseEvent):void
		{
			if(event.detail == Alert.OK) {
				var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				var args:Vector.<String> = new Vector.<String>();
				
				args.push(StringUtil.slashToBackslash(AppCommon.toolbox.settingPanel.filePathText.text + "exportSwf"));
				
				info.executable = new File(AppCommon.toolbox.settingPanel.explorerPathText.text);
				info.arguments = args;
				new NativeProcess().start(info);
			}
		}
		//
	}
}