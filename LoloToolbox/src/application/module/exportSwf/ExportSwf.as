package application.module.exportSwf
{
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.modules.Module;
	
	public class ExportSwf extends Module
	{
		public var aaBtn:Button;
		
		public function ExportSwf()
		{
			super();
		}
		
		protected function aaBtn_clickHandler(event:MouseEvent):void
		{
			trace(aaBtn);
		}
	}
}