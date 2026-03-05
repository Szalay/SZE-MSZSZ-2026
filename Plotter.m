classdef Plotter < handle
	%PLOTTER Rajzoló osztály
	%	- az ábrázolandó tartomány megadható
	%	- akárhány függvény ábrázolható
	%		- függvénymutató, betűjel, stílus
	%	- feltételezések:
	%		- a függvények korlátosak
	%		- a függvényeket hozzáadjuk a megjelenítés előtt
	
	% Tulajdonságai
	properties
		Interval;
		PointCount;
		
		Functions = {};
		Notations = {};
		LineStyles = {};
		
		Window;
	end
	
	% Tagfüggvények (dinamikus)
	methods
		
		% Konstruktor (építő)
		% Egy példányt hoz létre az osztályból, amit objektumnak nevezünk
		function this = Plotter(Settings)
			arguments
				Settings.Interval(1, 2) double = [0, 1];
				Settings.PointCount(1, 1) double = 100;
			end
			
			this.Interval = Settings.Interval;
			this.PointCount = Settings.PointCount;
		end
		
		% Dinamikus tagfüggvény, a this a kötelező első bemenete
		function AddFunction(this, f, notation, lineStyle)
			% p.AddFunction(@(x)x.^2, "f", "k-")
			this.Functions{end+1, 1} = f;
			this.Notations{end+1, 1} = notation;
			this.LineStyles{end+1, 1} = lineStyle;
			
			% Ha már van ablak, akkor be kell zárni
			if ishandle(this.Window)
				close(this.Window);
				
				this.Show();
			end
		end
		
		function DeleteFunctionByIndex(this, i)
			this.Functions(i) = [];
			this.Notations(i) = [];
			this.LineStyles(i) = [];
			
			% Ha már van ablak, akkor be kell zárni
			if ishandle(this.Window)
				close(this.Window);
				
				this.Show();
			end
		end
		
		function Show(this)
			this.Window = Tools.Figure();
			
			xlim(this.Interval);
			
			title("Függvények", FontSize=18);
			xlabel("Független változó, {\itx}", FontSize=16);
			ylabel("Függvényérték", FontSize=16);
			
			lines = zeros(length(this.Functions), 1);
			notations = "";
			for i = 1:length(this.Functions)
				x = linspace(this.Interval(1), this.Interval(2), this.PointCount);
				
				f = this.Functions{i};
				lines(i) = plot(x, f(x), this.LineStyles{i}, LineWidth=3);
				
				notations(i) = "{\it" + this.Notations{i} + "}({\itx})";
			end
			
			legend(lines, notations, FontSize=14);
		end
		
	end
	
	methods (Static)
		
		function p = Run()
			p = Plotter(Interval=[-5, 5], PointCount=1000);
			
			p.AddFunction(@(x)x.^2, "f", "k-");
			p.AddFunction(@(x)x.^3, "g", "b-");
			
			p.Show();
		end
		
	end
	
end