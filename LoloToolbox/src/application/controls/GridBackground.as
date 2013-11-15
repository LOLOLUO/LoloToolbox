package application.controls
{
	import mx.core.UIComponent;
	
	/**
	 * 格子样式的舞台背景
	 * @author LOLO
	 */
	public class GridBackground extends UIComponent
	{
		private static const GRID_WIDTH:int = 8;
		private static const GRID_HEIGHT:int = 8;
		
		
		
		public function GridBackground(width:int=0, height:int=0)
		{
			this.cacheAsBitmap = true;
			if(width > 0 && height > 0) show(width, height);
		}
		
		
		public function show(width:int, height:int):void
		{
			this.graphics.clear();
			this.graphics.beginFill(0x666666);
			this.graphics.drawRect(0, 0, width, height);
			
			var h:int = Math.ceil((width - 2) / GRID_WIDTH);	
			var v:int = Math.ceil((height - 2) / GRID_HEIGHT);
			var x:int, y:int;
			var gx:int, gy:int, gw:int, gh:int;
			for(y = 0; y < v; y++) {
				for(x = 0; x < h; x++) {
					if(y % 2 == 0) {
						this.graphics.beginFill((x % 2 == 0) ? 0xFFFFFF : 0xDFDFDF);
					}
					else {
						this.graphics.beginFill((x % 2 == 1) ? 0xFFFFFF : 0xDFDFDF);
					}
					gx = x * GRID_WIDTH + 1;
					gy = y * GRID_HEIGHT + 1;
					gw = (x == h-1) ? (width - GRID_WIDTH * x - 2) : GRID_WIDTH;
					gh = (y == v-1) ? (height - GRID_HEIGHT * y - 2) : GRID_HEIGHT;
					this.graphics.drawRect(gx, gy, gw, gh);
				}
			}
			this.graphics.endFill();
		}
		//
	}
}