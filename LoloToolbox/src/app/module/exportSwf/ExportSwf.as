package app.module.exportSwf
{
	import app.common.AppCommon;
	import app.common.AppConstants;
	import app.controls.GridBackground;
	import app.controls.GroupBox;
	import app.utils.SwfUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.List;
	import spark.components.NavigatorContent;
	import spark.components.TextInput;
	
	
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
		
		/**用于浏览和加载SWF文件数据*/
		private var _swfFile:File;
		
		
		
		public function ExportSwf()
		{
			super();
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			trace("ok!");
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
			gridBG.height = AppCommon.stage.stageHeight - AppCommon.app.toolListVS.y - gridBG.y - 5;
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
		//
	}
}