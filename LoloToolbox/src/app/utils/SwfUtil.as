package app.utils
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	/**
	 * SWF文件工具
	 * @author LOLO
	 */
	public class SwfUtil
	{
		/**需要解析的SWF列表*/
		private static var _swfList:Array = [];
		/**当前正在解析的SWF信息*/
		private static var _currentSwfInfo:Object;
		/**用于载入SWF文件*/
		private static var _swfLoader:Loader;
		/**SWF文件将会被载入到该域中*/
		private static var _swfDomain:ApplicationDomain;
		/**是否正在解析SWF中*/
		private static var _running:Boolean;
		
		
		
		/**
		 * 异步方式解析SWF数据。
		 * 解析完成时，将所有导出类（Sprite或MovieClip）声明成实例，并组成数组。
		 * 或者只将导出类的名称组成数组。
		 * 然后将数组作为参数，传回给回调函数
		 * @param data SWF文件的数据
		 * @param callback 回调函数
		 * @param createInstance 是否需要将所有导出类创建成实例
		 * @return 
		 */
		public static function parseSwf(data:ByteArray, callback:Function, createInstance:Boolean=true):void
		{
			if(_swfLoader == null) {
				_swfLoader = new Loader();
				_swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoader_completeHandler);
			}
			
			_swfList.push({ data:data, callback:callback, createInstance:createInstance });
			parseNextSwf();
		}
		
		
		/**
		 * 解析队列中的下一个swf
		 */
		private static function parseNextSwf():void
		{
			if(_swfList.length == 0 || _running) return;
			
			_running = true;
			_currentSwfInfo = _swfList.shift();
			
			_swfDomain = new ApplicationDomain();
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowLoadBytesCodeExecution = true;
			loaderContext.applicationDomain = _swfDomain;
			_swfLoader.loadBytes(_currentSwfInfo.data, loaderContext);
		}
		
		
		/**
		 * 载入swf成功
		 * @param event
		 */
		private static function swfLoader_completeHandler(event:Event):void
		{
			var dNames:Vector.<String> = _swfDomain.getQualifiedDefinitionNames();
			var result:Array = [];
			var tempClass:Class;
			for(var i:int = 0; i < dNames.length; i++) {
				//需要创建成实例
				if(_currentSwfInfo.createInstance) {
					try {
						tempClass = _swfDomain.getDefinition(dNames[i]) as Class;
						result.push({ instance:new tempClass(), name:dNames[i] });
					}
					catch(error:Error) {
						trace("[LoloToolbox][SwfUtil] 不能创建 " + dNames[i] + " 的实例！可能实例类型为BitmapData，或者实例的构造函数有错误的引用！");
					}
				}
				else {
					result.push(dNames[i]);
				}
			}
			
			if(_currentSwfInfo.callback != null) {
				_currentSwfInfo.callback(result);
			}
			_swfLoader.unloadAndStop();
			
			_running = false;
			parseNextSwf();
		}
		//
	}
}