classdef CoilSimulator < handle
	
	properties
		Window matlab.ui.Figure;
		Root matlab.ui.container.GridLayout;
		RunButton matlab.ui.control.Button;
		
		CoilModel Coil;
		
		VoltageAxes;
		CurrentAxes;
		
		Parameters;
		
		Coefficient = 1;
	end
	
	methods
		
		function this = CoilSimulator()
			this.Parameters = { ...
				{"\itR", 1}, ...
				{"\itL", 1e-3}, ...
				{"{\iti}_0", 0}, ...
				{"\itT_S", 1e-6}, ...
				{"{\itT}_0", 10e-3}, ...
				{"\itA", 1}, ...
				{"\itf", 500}, ...
				{"\it\phi", 0}, ...
				{"\itB", 0} ...
			};
		end
		
		function Show(this)
			this.Window = uifigure(Name="Tekercsszimulátor");
			this.Window.Position = [1340, 180, 560, 860];
			%this.Window.WindowState="maximized";
			
			this.Root = uigridlayout(Parent=this.Window);
			this.Root.ColumnWidth = {"1x"};
			this.Root.RowHeight = {"1x", "fit"};
			this.Root.Padding = [0, 0, 0, 0];
			
			% Tengelykeresztek
			ChartPanel = uipanel(Parent=this.Root);
			ChartPanel.BorderWidth = 0;
			TiledLayout = tiledlayout(2, 1, Parent=ChartPanel);
			TiledLayout.Padding = "tight";
			TiledLayout.TileSpacing = "tight";
			
			% Feszültség
			this.VoltageAxes = nexttile(TiledLayout);
			hold(this.VoltageAxes, "on");
			box(this.VoltageAxes, "on");
			grid(this.VoltageAxes, "on");
			title(this.VoltageAxes, "Bemeneti feszültség", FontSize=18);
			xlabel(this.VoltageAxes, "Idő, {\itt}, (s)", FontSize=16);
			ylabel(this.VoltageAxes, "Feszültség, {\itu_{BE}}, (V)", FontSize=16);
			
			% Áramerősség
			this.CurrentAxes = nexttile(TiledLayout);
			hold(this.CurrentAxes, "on");
			box(this.CurrentAxes, "on");
			grid(this.CurrentAxes, "on");
			title(this.CurrentAxes, "Kimeneti áramerősség", FontSize=18);
			xlabel(this.CurrentAxes, "Idő, {\itt}, (s)", FontSize=16);
			ylabel(this.CurrentAxes, "Áramerősség, {\iti}, (A)", FontSize=16);
			
			linkaxes([this.VoltageAxes, this.CurrentAxes], "x");
			
			% Vezérlőelemek
			ControlGrid = uigridlayout(Parent=this.Root);
			%ControlGrid.BackgroundColor = [0, 0.5, 1];
			ControlGrid.RowHeight = {15, 25};
			ControlGrid.RowSpacing = 2;
			ControlGrid.ColumnWidth = repmat({"1x"}, 1, length(this.Parameters) + 1);
			
			for k = 1:length(this.Parameters)
				l = uilabel(Parent=ControlGrid, Text=this.Parameters{k}{1});
				l.Interpreter = "tex";
				l.Layout.Row = 1;
				l.Layout.Column = k;
				
				t = uitextarea(Parent=ControlGrid);
				t.Layout.Row = 2;
				t.Layout.Column = k;
				t.Value = num2str(this.Parameters{k}{2});
				
				this.Parameters{k}{3} = t;
			end
			
			this.RunButton = uibutton( ...
				ControlGrid, Text="Futtatás", ButtonPushedFcn=@this.OnRun ...
				);
		end
		
		function OnRun(this, source, event)
			this.RunButton.Enable = "off";
			
			p = this.Parse();
			
			this.CoilModel = Coil( ...
				R=p(1), L=p(2), i_0=p(3), ...
				t=0:p(4):p(5), ...
				u_BE=@(t)p(6)*cos(2*pi*p(7)*t + p(8)) + p(9) ...
				);
			this.CoilModel.Simulate();
			
			this.Plot();
			
			this.RunButton.Enable = "on";
		end
		
		function p = Parse(this)
			p = zeros(length(this.Parameters), 1);
			for k = 1:length(this.Parameters)
				t = this.Parameters{k}{3};
				p(k) = str2double(t.Value);
			end
		end
		
		function Plot(this)
			t = this.CoilModel.t;
			u = this.CoilModel.u_BE(t);
			i = this.CoilModel.i;
			
			delete(this.VoltageAxes.Children(2:end));
			delete(this.CurrentAxes.Children(2:end));
			
			[coefficient, prefix] = Tools.OrderOfMagnitude(t(end));
			t = coefficient * t;
			
			if ~isempty(this.VoltageAxes.Children)
				p_u_0 = this.VoltageAxes.Children;
				p_u_0.XData = p_u_0.XData/this.Coefficient * coefficient;
				p_u_0.Color = [0.5, 0.75, 1];
				
				p_i_0 = this.CurrentAxes.Children;
				p_i_0.XData = p_i_0.XData/this.Coefficient * coefficient;
				p_i_0.Color = [1, 0.75, 0.5];
			end
			
			this.Coefficient = coefficient;
			
			p_u = plot(this.VoltageAxes, t, u, "b", LineWidth=3);
			p_i = plot(this.CurrentAxes, t, i, "r", LineWidth=3);
			
			xlim(this.VoltageAxes, [t(1), t(end)]);
			xlim(this.CurrentAxes, [t(1), t(end)]);
			
			xlabel(this.VoltageAxes, "Idő, {\itt}, (" + prefix + "s)", FontSize=16);
			xlabel(this.CurrentAxes, "Idő, {\itt}, (" + prefix + "s)", FontSize=16);
			
			legend(this.VoltageAxes, p_u, "{\itu}_{BE}({\itt})", FontSize=14);
			legend(this.CurrentAxes, p_i, "{\iti}({\itt})", FontSize=14);
		end
		
	end
	
	methods (Static)
		
		function Run()
			cs = CoilSimulator();
			cs.Show();
		end
		
	end
	
end