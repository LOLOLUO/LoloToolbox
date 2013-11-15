package application.module.main
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import lolo.data.SharedData;
	import lolo.utils.StringUtil;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.DropDownList;
	import spark.components.Panel;
	import spark.components.TextInput;
	
	public class Setting extends Panel
	{
		public var toolPathText:TextInput;
		public var platformDDL:DropDownList;
		public var qualityDDL:DropDownList;
		public var compressCB:CheckBox;
		
		public var explorerPathText:TextInput;
		public var nppPathText:TextInput;
		public var winRarPathText:TextInput;
		public var mxmlcPathText:TextInput;
		public var adtPathText:TextInput;
		public var tpPathText:TextInput;
		public var png2atfPathText:TextInput;
		
		
		/**浏览目录*/
		private var _browseBtn:Button;
		private var _browseFile:File;
		
		private var _soData:Object = SharedData.soData;
		
		
		/**
		 * 初始化，入口
		 * @param event
		 */
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			platformDDL.dataProvider = new ArrayCollection([
				{label:"iOS"}, {label:"Android"}, {label:"Win/Mac"}, {label:"All"}
			]);
			platformDDL.selectedIndex = 0;
			
			qualityDDL.dataProvider = new ArrayCollection([
				{label:"High"}, {label:"Low"}
			]);
			qualityDDL.selectedIndex = 0;
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitingHandler);
			
			if(_soData.settings) {
				toolPathText.text = _soData.settings.toolPathText;
				platformDDL.selectedIndex = _soData.settings.platformDDL;
				qualityDDL.selectedIndex = _soData.settings.qualityDDL;
				compressCB.selected = _soData.settings.compressCB;
				
				explorerPathText.text = _soData.settings.explorerPathText;
				nppPathText.text = _soData.settings.nppPathText;
				winRarPathText.text = _soData.settings.winRarPathText;
				mxmlcPathText.text = _soData.settings.mxmlcPathText;
				adtPathText.text = _soData.settings.adtPathText;
				tpPathText.text = _soData.settings.tpPathText;
				png2atfPathText.text = _soData.settings.png2atfPathText;
			}
			
			(this.parent as IVisualElementContainer).removeElement(this);
			
			_browseFile = new File();
			_browseFile.addEventListener(Event.SELECT, browseFile_selectHandler);
		}
		
		
		/**
		 * 退出时事件
		 * @param event
		 */
		protected function exitingHandler(event:Event=null):void
		{
			_soData.settings = {
				toolPathText : toolPathText.text,
				compressCB : compressCB.selected,
				platformDDL : platformDDL.selectedIndex,
				qualityDDL : qualityDDL.selectedIndex,
				
				explorerPathText : explorerPathText.text,
				nppPathText : nppPathText.text,
				winRarPathText : winRarPathText.text,
				mxmlcPathText : mxmlcPathText.text,
				adtPathText : adtPathText.text,
				tpPathText : tpPathText.text,
				png2atfPathText : png2atfPathText.text
			};
			
			SharedData.so.flush();
		}
		
		
		/**
		 * 点击关闭按钮
		 * @param event
		 */
		protected function closeBtn_clickHandler(event:MouseEvent):void
		{
			PopUpManager.removePopUp(this);
			exitingHandler();
		}
		
		
		/**
		 * 点击浏览按钮
		 * @param event
		 */
		protected function browseBtn_clickHandler(event:MouseEvent):void
		{
			_browseBtn = event.target as Button;
			if(browseFileIsDirectory) {
				_browseFile.browseForDirectory("请选择文件夹");
			}
			else {
				_browseFile.browse();
			}
		}
		
		
		/**
		 * 选择文件夹完成
		 * @param event
		 */
		protected function browseFile_selectHandler(event:Event):void
		{
			var label:TextInput = this[_browseBtn.id.slice(0, _browseBtn.id.length-3) + "Text"];
			label.text = StringUtil.backslashToSlash(_browseFile.nativePath);
			if(browseFileIsDirectory) label.text+= "/";
		}
		
		
		
		/**
		 * 浏览的目标是否为文件夹
		 * @return 
		 */
		protected function get browseFileIsDirectory():Boolean
		{
//			return _browseBtn == toolPathBtn;
			return false;
		}
		
		
		protected function compressCB_clickHandler(event:MouseEvent):void
		{
			platformDDL.enabled = compressCB.selected;
		}
		//
	}
}