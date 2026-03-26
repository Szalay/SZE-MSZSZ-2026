classdef CoilSimulator < handle
	
	properties
		Window matlab.ui.Figure;
		Root matlab.ui.container.GridLayout;
	end
	
	methods
		
		function this = CoilSimulator()
			
		end
		
		function Show(this)
			this.Window = uifigure( ...
				Name="Tekercsszimulátor", WindowState="maximized" ...
				);
			this.Root = uigridlayout(Parent=this.Window);
			this.Root.ColumnWidth = {"1x"};
			this.Root.RowHeight = {"1x", "fit"};
			this.Root.Padding = [0, 0, 0, 0];
			
			% Tengelykeresztek
			ChartPanel = uipanel(Parent=this.Root);
			TiledLayout = tiledlayout(2, 1, Parent=ChartPanel);
			
			nexttile(TiledLayout);
			nexttile(TiledLayout);
			
			ControlGrid = uigridlayout(Parent=this.Root);
			ControlGrid.BackgroundColor = [0, 0.5, 1];
			ControlGrid.RowHeight = {15, 25};
			ControlGrid.RowSpacing = 2;
			ControlGrid.ColumnWidth = repmat({"1x"}, 1, 10);
			
			rl = uilabel(Parent=ControlGrid, Text="R");
			uilabel(Parent=ControlGrid, Text="L");
			uilabel(Parent=ControlGrid, Text="i_0");
			uilabel(Parent=ControlGrid, Text="T_S");
			uilabel(Parent=ControlGrid, Text="T_0");
			uilabel(Parent=ControlGrid, Text="A");
			uilabel(Parent=ControlGrid, Text="f");
			uilabel(Parent=ControlGrid, Text="\phi");
			uilabel(Parent=ControlGrid, Text="B");
			
			Resistor = uitextarea(Parent=ControlGrid);
			Resistor.Layout.Row = 2;
			Resistor.Layout.Column = 1;
			
			Inductance = uitextarea(Parent=ControlGrid);
			InitialCurrent = uitextarea(Parent=ControlGrid);
			TimeStep = uitextarea(Parent=ControlGrid);
			TimeSpan = uitextarea(Parent=ControlGrid);
			Amplitude = uitextarea(Parent=ControlGrid);
			Frequency = uitextarea(Parent=ControlGrid);
			Phase = uitextarea(Parent=ControlGrid);
			Offset = uitextarea(Parent=ControlGrid);
			
			RunButton = uibutton(ControlGrid, Text="Futtatás");
		end
		
	end
	
	methods (Static)
		
		function Run()
			cs = CoilSimulator();
			cs.Show();
		end
		
	end
	
end