classdef Vector2D < handle
	
	properties
		Axes;
		Label;
		Arrow;
		Scale(1, 1) double = 1;
	end
	
	methods
		
		function this = Vector2D(Settings)
			arguments
				Settings.Axes(1, 1) = gca
				Settings.Label(1, 1) string = ""
				Settings.Scale(1, 1) double = 1
				Settings.Color = "k"
				Settings.A(2, 1) = [0; 0]
				Settings.B(2, 1) = [1; 1]
			end
			
			this.Axes = Settings.Axes;
			this.Scale = Settings.Scale;
			
			x = Settings.A(1);
			y = Settings.A(2);
			
			u = this.Scale*Settings.B(1);
			v = this.Scale*Settings.B(2);
			
			this.Arrow = quiver(this.Axes, ...
				x, y, u, v, ...
				"off", Color=Settings.Color, LineWidth=2, MaxHeadSize=0.3 ...
				);
			this.Label = text(this.Axes, ...
				x + 0.5*u, y + 0.5*v, Settings.Label, ...
				Interpreter="latex", FontSize=16, Color=Settings.Color ...
				);
		end
		
		function Update(this, Settings)
			arguments
				this(1, 1) Vector2D
				Settings.A = []
				Settings.B = []
			end
			
			if ~isempty(Settings.A)
				this.Arrow.XData = Settings.A(1);
				this.Arrow.YData = Settings.A(2);
			end
			
			if ~isempty(Settings.B)
				this.Arrow.UData = this.Scale*Settings.B(1);
				this.Arrow.VData = this.Scale*Settings.B(2);
			end
			
			if ~isempty(Settings.A) || ~isempty(Settings.B)
				this.Label.Position = [ ...
					this.Arrow.XData + 0.5*this.Arrow.UData, ...
					this.Arrow.YData + 0.5*this.Arrow.VData ...
					];
			end
		end
		
	end
	
end