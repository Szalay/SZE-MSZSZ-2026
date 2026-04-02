classdef Tools
	
	methods (Static)
		
		function window = Figure(Settings)
			arguments
				Settings.Name(1, 1) string = ""
			end
			window = figure(Name=Settings.Name);
			window.Color = [1, 1, 1];
			hold on; box on; grid on;
		end
		
		function [x, y] = Circle(r)
			phi = deg2rad(0:5:360);
			x = r*cos(phi);
			y = r*sin(phi);
		end
		
		function [coefficient, prefix] = OrderOfMagnitude(v)
			if v >= 1
				coefficient = 1;
				prefix = "";
			elseif v >= 1e-3
				coefficient = 1000;
				prefix = "m";
			elseif v >= 1e-6
				coefficient = 1e6;
				prefix = "μ";
			else
				coefficient = 1e9;
				prefix = "n";
			end
		end
		
	end
	
end