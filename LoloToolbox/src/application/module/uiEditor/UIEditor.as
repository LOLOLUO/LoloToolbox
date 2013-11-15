package application.module.uiEditor
{
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.modules.Module;
	
	public class UIEditor extends Module
	{
		public var aaBtn:Button;
		
		public function UIEditor()
		{
			super();
		}
		
		protected function aaBtn_clickHandler(event:MouseEvent):void
		{
			trace(aaBtn);
		}
	}
}