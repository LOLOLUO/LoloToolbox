package lolo.data
{
	import flash.net.SharedObject;

	/**
	 * 共享数据
	 * @author LOLO
	 */
	public class SharedData
	{
		private static var _so:SharedObject = SharedObject.getLocal("LOLO_SHARED_OBJECT");
		
		
		
		
		/**
		 * 获取程序共享的SharedObject
		 * @return 
		 */
		public static function get so():SharedObject
		{
			return _so;
		}
		
		/**
		 * 获取程序共享的SharedObject的数据
		 * @return 
		 */
		public static function get soData():Object
		{
			return _so.data;
		}
		
		//
	}
}