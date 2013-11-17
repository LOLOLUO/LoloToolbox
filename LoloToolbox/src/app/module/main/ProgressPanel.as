package app.module.main
{
	import app.common.AppCommon;
	
	import mx.controls.ProgressBar;
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Panel;
	
	
	/**
	 * 进度面板
	 * @author LOLO
	 */
	public class ProgressPanel extends Panel
	{
		public var progressBar:ProgressBar;
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			(this.parent as IVisualElementContainer).removeElement(this);
		}
		
		
		/**
		 * 显示面板
		 */
		public function show(total:Number=0, value:Number=0, label:String="%3 %%"):void
		{
			if(!this.parent) {
				x = AppCommon.stage.stageWidth - width >> 1;
				y = AppCommon.stage.stageHeight - height >> 1;
				PopUpManager.addPopUp(this, AppCommon.toolbox, true);
			}
			
			if(total == 0) total = progressBar.maximum;
			progressBar.setProgress(value, total);
			progressBar.label = label;
		}
		
		/**
		 * 隐藏面板
		 */
		public function hide():void
		{
			if(this.parent) {
				PopUpManager.removePopUp(this);
			}
		}
		
		/**
		 * 进度递增一次
		 */
		public function addProgress():void
		{
			progressBar.setProgress(progressBar.value + 1, progressBar.maximum);
		}
		//
	}
}