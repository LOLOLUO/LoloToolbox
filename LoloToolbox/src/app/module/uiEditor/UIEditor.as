package app.module.uiEditor
{
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.NavigatorContent;
	
	public class UIEditor extends NavigatorContent
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