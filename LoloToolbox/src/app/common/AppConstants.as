package app.common
{
	import flash.net.FileFilter;

	/**
	 * 项目中用到的常量集合
	 * @author LOLO
	 */
	public class AppConstants
	{
		/**后缀名 - 地图信息(MapInfo)*/
		public static var EXTENSION_LMI:String = "lmi";
		/**后缀名 - 纹理数据(TextureData)*/
		public static var EXTENSION_LTD:String = "ltd";
		
		
		/**文件类型 - swf*/
		public static var FILE_FILTER_SWF:FileFilter = new FileFilter("SWF 文件", "*.swf");
		/**文件类型 - 图像*/
		public static var FILE_FILTER_IMG:FileFilter = new FileFilter("图像文件", "*.jpg;*.gif;*.png");
		
		
		//
	}
}