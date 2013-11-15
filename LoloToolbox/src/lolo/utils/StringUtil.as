package lolo.utils
{
	/**
	 * 字符串工具
	 * @author LOLO
	 */
	public class StringUtil
	{
		
		/**
		 * 将指定字符串内的 "{n}" 标记替换成传入的参数
		 * @param str 要替换的字符串
		 * @param rest 参数列表
		 * @return 
		 */
		public static function substitute(str:String, ...rest):String
		{
			if(str == null) return "";
			
			var args:Array;
			if(rest.length == 1 && rest[0] is Array) {
				args = rest[0];
			}else {
				args = rest;
			}
			
			for(var i:int = 0; i < args.length; i++)
			{
				str = str.replace(new RegExp("\\{" + i + "\\}", "g"), args[i]);
			}
			return str;
		}
		
		
		
		/**
		 * 当number小于length指定的长度时，在number前面加上前导零
		 * @param number
		 * @param length
		 * @return 
		 */
		public static function leadingZero(number:int, length:int=2):String
		{
			var str:String = number.toString();
			while(str.length < length) str = "0" + str;
			return str;
		}
		
		
		
		/**
		 * 将目标字符串组合成html文本标签包含的字符串
		 * @param str 要组合的字符串
		 * @param color 颜色
		 * @param size 文本尺寸
		 * @return 
		 */		
		public static function toHtmlFont(str:String, color:String="", size:uint=0):String
		{
			var s:String = "<font";
			
			if(color != "") {
				if(color.charAt() != "#") color = "#" + color;
				s += " color='" + color + "'";
			}
			
			if(size != 0) {
				s += " size='" + size + "'";
			}
			
			s += ">" + str + "</font>";
			return s;
		}
		
		
		
		
		/**
		 * 千分位格式化数字
		 * @param value 要格式化的值
		 * @param decimals 保留小数的位数（小于0为保留所有）
		 * @param thousandsSep 千位分隔符
		 */
		public static function numberFormat(value:Number, decimals:int=2, thousandsSep:String=","):String
		{
			var str:String = "";
			var arr:Array = value.toString().split(".");
			
			var count:int = Math.ceil(arr[0].length / 3);
			for(var i:int=0; i < arr[0].length; i++) {
				if(i % 3 == 0 && str != "") str = thousandsSep + str;
				str = arr[0].charAt(arr[0].length - i - 1) + str;
			}
			
			if(arr[1] != null) {
				var d:int = arr[1].slice(0, (decimals > 0) ? decimals : arr[1].length);
				if(d > 0) str += "." + d.toString();
			}
			
			//负数
			if(str.charAt(0) == "-" && str.charAt(1) == thousandsSep) {
				str = "-" + str.slice(2, str.length);
			}
			return str;
		}
		
		
		
		
		/**
		 * 获取目录，为了显示好看，去掉前面的"file:///"字符串
		 * @param directory
		 * @return 
		 */
		public static function getDirectory(directory:String):String
		{
			if(directory.slice(0, 8) != "file:///") return directory;
			return directory.slice(8, directory.length);
		}
		
		/**
		 * 将字符串中的所有正斜杠转换成反斜杠
		 * @param str
		 * @return 
		 */
		public static function slashToBackslash(str:String):String
		{
			return str.replace(/\//g, "\\");
		}
		
		/**
		 * 将字符串中的所有反斜杠转换成正斜杠
		 * @param str
		 * @return 
		 */
		public static function backslashToSlash(str:String):String
		{
			return str.replace(/\\/g, "/");
		}
		//
	}
}