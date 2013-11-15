package application.module.main
{
	import application.common.AppCommon;
	
	import com.greensock.TweenMax;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.ViewStack;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.WindowedApplication;
	
	/**
	 * 主界面
	 * @author LOLO
	 */
	public class Main extends WindowedApplication
	{
		public var toolMenu:Group;
		public var toolListVS:ViewStack;
		public var showToolBtn:Button;
		
		public var exportMcBtn:Button;
		public var uiEditorBtn:Button;
		
		private var _currentToolBtn:Button;
		
		
		public function Main()
		{
			
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			AppCommon.app = this as LoloToolBox;
			AppCommon.stage = this.stage;
			
			stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler();
			
			_currentToolBtn = exportMcBtn;
			showToolBtn_clickHandler();
		}
		
		
		private function stage_resizeHandler(event:Event=null):void
		{
			var height:int = AppCommon.stage.stageHeight - 35;
			toolMenu.graphics.clear();
			toolMenu.graphics.beginFill(0xFFFFFF, 0.8);
			toolMenu.graphics.drawRect(0, 0, AppCommon.stage.stageWidth, height);
			toolMenu.graphics.endFill();
		}
		
		
		
		
		/**
		 * 展开或者关闭工具列表
		 * @param event
		 */
		protected function showToolBtn_clickHandler(event:MouseEvent=null):void
		{
			TweenMax.killTweensOf(toolMenu);
			
			if(showToolBtn.label == "收起工具列表") {
				showToolBtn.label = _currentToolBtn.label;
				TweenMax.to(toolMenu, 0.2, { autoAlpha:0 });
			}
			else {
				showToolBtn.label = "收起工具列表";
				TweenMax.to(toolMenu, 0.3, { autoAlpha:1 });
			}
		}
		
		
		/**
		 * 点击工具菜单中的按钮
		 * @param event
		 */
		protected function toolMenuBtn_clickHandler(event:MouseEvent):void
		{
			_currentToolBtn = event.target as Button;
			showToolBtn_clickHandler();
			
			switch(_currentToolBtn)
			{
				case exportMcBtn:
					toolListVS.selectedIndex = 0;
					break;
				case uiEditorBtn:
					toolListVS.selectedIndex = 1;
					break;
			}
		}
		
		
		
		/**
		 * 打开或者关闭设置面板
		 * @param event
		 */
		protected function settingBtn_clickHandler(event:MouseEvent):void
		{
			
		}
		//
	}
}