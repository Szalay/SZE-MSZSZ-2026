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
		
	end
	
end