package app.module.exportSwf
{
	import app.common.AppCommon;
	import app.common.AppConstants;
	import app.controls.GridBackground;
	import app.controls.GroupBox;
	import app.utils.SwfUtil;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
	import mx.core.UIComponent;
	
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
		/**导出进度*/
		public var exportPB:ProgressBar;
		
		
		/**用于浏览和加载SWF文件数据*/
		private var _swfFile:File;
		/**用于显示实例的容器*/
		private var _instanceC:UIComponent;
		/**需要导出的元件列表*/
		private var _exportElementList:Array;
		
		
		
		public function ExportSwf()
		{
			super();
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			_instanceC = new UIComponent();
			_instanceC.mouseEnabled = _instanceC.mouseChildren = false;
			_instanceC.x = gridBG.x;
			_instanceC.y = gridBG.y;
			this.addElement(_instanceC);
			
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
			elementList.dataProvider = new ArrayList(list);
			allSelectCB.selected = true;
			
			_instanceC.removeChildren();
			exportBtn.enabled = true;
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
		 * 元件列表有选中
		 * @param event
		 */
		protected function elementList_changeHandler(event:IndexChangeEvent):void
		{
			var data:Object = elementList.selectedItem;
			
			_instanceC.removeChildren();
			_instanceC.addChild(data.instance);
			
			//还没计算过实例的大小，找出最大边界，并绘制边框
			if(!data.bounds) {
				var bounds:Rectangle = data.instance.getBounds(data.instance);
				if(data.instance is MovieClip) {
					for(var i:int=1; i < data.instance.totalFrames; i++) {
						data.instance.gotoAndStop(i);
						var rect:Rectangle = data.instance.getBounds(data.instance);
						if(rect.x < bounds.x) bounds.x = rect.x;
						if(rect.y < bounds.y) bounds.y = rect.y;
						if(rect.width > bounds.width) bounds.width = rect.width;
						if(rect.height > bounds.height) bounds.height = rect.height;
					}
					data.instance.play();
				}
				bounds.x = int(bounds.x);
				bounds.y = int(bounds.y);
				bounds.width = Math.ceil(bounds.width);
				bounds.height = Math.ceil(bounds.height);
				data.bounds = bounds;
				
				drawElementBounds(data);
			}
			
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
		 * 点击导出按钮
		 * @param event
		 */
		protected function exportBtn_clickHandler(event:MouseEvent):void
		{
			//找出要导出的元件列表
			_exportElementList = [];
			for(var i:int = 0; i < elementList.dataGroup.numChildren; i++) {
				if((elementList.dataGroup.getChildAt(i) as SwfItemRenderer).exportCB.selected) {
					_exportElementList.push(elementList.dataProvider.getItemAt(i));
				}
			}
			
			if(_exportElementList.length == 0) {
				Alert.show("没有需要导出的元件！", "提示");
				return;
			}
			
//			exportPB.setProgress(0, _exportElementList.length);
//			exportNextElement();
		}
		
		
		/**
		 * 导出下一个元件
		 */
		private function exportNextElement():void
		{
			
		}
		//
	}
}