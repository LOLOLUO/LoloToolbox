package app.module.main
{
	import app.common.AppCommon;
	import app.module.exportSwf.ExportSwfView;
	
	import com.greensock.TweenMax;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import lolo.data.SharedData;
	import lolo.utils.StringUtil;
	
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.WindowedApplication;
	
	/**
	 * 主界面
	 * @author LOLO
	 */
	public class Main extends WindowedApplication
	{
		public var toolListVS:ViewStack;
		public var showToolBtn:Button;
		public var settingBtn:Button;
		
		/**工具菜单，工具激活按钮列表*/
		public var toolMenu:Group;
		public var exportMcBtn:Button;
		public var uiEditorBtn:Button;
		
		public var exportSwf:ExportSwfView;
		
		public var settingPanel:SettingPanelView;
		public var progressPane:ProgressPanelView;
		
		/**当前正在使用的工具对应的，工具激活按钮*/
		private var _currentToolBtn:Button;
		
		private var _soData:Object = SharedData.soData;
		
		
		public function Main()
		{
			
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			AppCommon.toolbox = this as LoloToolbox;
			AppCommon.stage = this.stage;
			
			this.nativeWindow.x = Capabilities.screenResolutionX - this.nativeWindow.width >> 1;
			this.nativeWindow.y = Capabilities.screenResolutionY - this.nativeWindow.height - 40 >> 1;
			
			stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler();
			
			//第一次使用工具箱
			if(_soData.settings == null) {
				settingPanel.filePathText.text = StringUtil.backslashToSlash(File.documentsDirectory.nativePath) + "/LoloToolbox/";
				settingPanel.showOrHide();
				Alert.show("这是您第一次使用LoloToolbox，请认真配置好相关程序路径，以及其他设置项！", "提示");
			}
		}
		
		
		private function stage_resizeHandler(event:Event=null):void
		{
			var height:int = AppCommon.stage.stageHeight - 35;
			toolMenu.graphics.clear();
			toolMenu.graphics.beginFill(0xFFFFFF, 0.8);
			toolMenu.graphics.drawRect(0, 0, AppCommon.stage.stageWidth, height);
			toolMenu.graphics.endFill();
			
			settingBtn.x = AppCommon.stage.stageWidth - settingBtn.width - 3;
			
			if(settingPanel.parent) {
				settingPanel.x = AppCommon.stage.stageWidth - settingPanel.width >> 1;
				settingPanel.y = AppCommon.stage.stageHeight - settingPanel.height >> 1;
			}
			
			if(progressPane.parent) {
				progressPane.x = AppCommon.stage.stageWidth - progressPane.width >> 1;
				progressPane.y = AppCommon.stage.stageHeight - progressPane.height >> 1;
			}
		}
		
		
		
		
		/**
		 * 展开或者关闭工具列表
		 * @param event
		 */
		protected function showToolBtn_clickHandler(event:MouseEvent=null):void
		{
			TweenMax.killTweensOf(toolMenu);
			
			if(showToolBtn.label == "收起工具列表") {
				if(_currentToolBtn == null) return;
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
					toolListVS.selectedIndex = 1;
					break;
				case uiEditorBtn:
					toolListVS.selectedIndex = 2;
					break;
			}
		}
		
		
		
		/**
		 * 打开或者关闭设置面板
		 * @param event
		 */
		protected function settingBtn_clickHandler(event:MouseEvent):void
		{
			settingPanel.showOrHide();
		}
		//
	}
}