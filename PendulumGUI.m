classdef PendulumGUI < handle
	
	properties
		Pendulum;
		
		Window matlab.ui.Figure;
		Root matlab.ui.container.GridLayout;
		ChartPanel matlab.ui.container.Panel;
		TiledLayout matlab.graphics.layout.TiledChartLayout;
		
		ControlGrid matlab.ui.container.GridLayout;
		Button matlab.ui.control.Button;
		Slider matlab.ui.control.Slider;
		
		Title;
		Axes matlab.graphics.axis.Axes;
		
		Wall;
		Rod;
		Joint;
		Head;
		
		Weight;
		Velocity;
		Acceleration;
		
		IsPlayed(1, 1) logical = false;
	end
	
	methods
		
		function this = PendulumGUI(pendulum)
			this.Pendulum = pendulum;
		end
		
		function Show(this)
			this.Window = uifigure(Name="Inga");
			this.Window.Color = [1, 1, 1];
			
			this.Root = uigridlayout(Parent=this.Window);
			this.Root.RowHeight = {'1x', "fit"};
			this.Root.ColumnWidth = {'1x'};
			this.Root.Padding = [0, 0, 0, 0];
			
			this.ChartPanel = uipanel(Parent=this.Root);
			this.ChartPanel.BorderWidth = 0;
			
			this.TiledLayout = tiledlayout(1, 1, Parent=this.ChartPanel);
			this.TiledLayout.Padding = "tight";
			this.TiledLayout.TileSpacing = "tight";
			
			this.Axes = nexttile(this.TiledLayout);
			hold(this.Axes, "on");
			box(this.Axes, "on");
			grid(this.Axes, "on");
			
			% Az animáció akadozásának megszünetése
			this.Axes.PickableParts = "none";
			
			% Vezérlők
			this.ControlGrid = uigridlayout(Parent=this.Root);
			this.ControlGrid.RowHeight = {"fit"};
			this.ControlGrid.ColumnWidth = {"fit", "1x"};
			this.ControlGrid.Padding = [5, 5, 5, 0];
			
			this.Button = uibutton(Parent=this.ControlGrid);
			this.Button.Text = "Lejátszás";
			this.Button.ButtonPushedFcn = @this.OnButtonPress;
			
			this.Slider = uislider(Parent=this.ControlGrid);
			this.Slider.Limits = [this.Pendulum.t(1), this.Pendulum.t(end)];
			
			this.Title = title(this.Axes, "Az ingamozgás animációja", FontSize=18);
			
			xlabel(this.Axes, "Vízszintes hely, {\itx} (m)", FontSize=16);
			ylabel(this.Axes, "Függőleges hely, {\ity} (m)", FontSize=16);
			
			% Az ábrázolt síkrész
			axis(this.Axes, "equal");
			xlim(this.Axes, 1.5*this.Pendulum.L*[-1, 1]);
			ylim(this.Axes, this.Pendulum.L*[-1.75, 0.25]);
			
			this.Build();
		end
		
		function Build(this)
			if ~ishandle(this.Window)
				% Ha nincs ablak, akkor lértehozunk egy újat.
				this.Show();
				return;
			end
			
			% Fal
			this.Wall = plot(this.Axes, 1.25*this.Pendulum.L*[-1, 1], [0, 0], "k-", LineWidth=3);
			
			% Az inga szára
			x_R = this.Pendulum.L*sin(this.Pendulum.phi_0);
			y_R = -this.Pendulum.L*cos(this.Pendulum.phi_0);
			this.Rod = plot(this.Axes, ...
				[0, x_R], [0, y_R], ...
				"k-", LineWidth=2 ...
				);
			
			% Csukló
			[x_J, y_J] = Tools.Circle(0.015);
			this.Joint = patch(this.Axes, ...
				XData=x_J, YData=y_J, ...
				FaceColor=[1, 1, 1], EdgeColor=[0, 0, 0], ...
				LineWidth=1 ...
				);
			
			% Az inga feje
			[x_H0, y_H0] = Tools.Circle(this.Pendulum.D/2);
			x_H = x_H0 + x_R;
			y_H = y_H0 + y_R;
			this.Head = patch(this.Axes, ...
				XData=x_H, YData=y_H, ...
				FaceColor=[0.25, 0.5, 0.75], EdgeColor=[0, 0, 0], ...
				LineWidth=1 ...
				);
			
			% Súly
			forceScale = 1/40;
			this.Weight = Vector2D(Axes=this.Axes, ...
				Label="$$m \vec{g}$$", Color="r", Scale=forceScale, ...
				A=[x_R; y_R], B=[0; -this.Pendulum.m*Pendulum.g] ...
				);
			
			% Sebesség, \vec{v} = \vec{omega} × \vec{r}
			velocityScale = 1/5;
			v_x0 = this.Pendulum.omega_0*this.Pendulum.L*cos(this.Pendulum.phi_0);
			v_y0 = this.Pendulum.omega_0*this.Pendulum.L*sin(this.Pendulum.phi_0);
			this.Velocity = Vector2D(Axes=this.Axes, ...
				Label="$$\vec{v}$$", Color="b", Scale=velocityScale, ...
				A=[x_R; y_R], B=[v_x0; v_y0] ...
				);
			
			% Gyorsulás, \vec{a} = \vec{\beta} × \vec{r} + \vec{omega} × \vec{v}
			accelerationScale = 0.1;
			dxdt_0 = this.Pendulum.Model(0, this.Pendulum.x_0);
			beta = dxdt_0(1);
			a_x0 = beta*this.Pendulum.L*cos(this.Pendulum.phi_0) - v_y0*this.Pendulum.omega_0;
			a_y0 = beta*this.Pendulum.L*sin(this.Pendulum.phi_0) + v_x0*this.Pendulum.omega_0;
			this.Acceleration = Vector2D(Axes=this.Axes, ...
				Label="$$\vec{a}$$", Color="g", Scale=accelerationScale, ...
				A=[x_R; y_R], B=[a_x0; a_y0] ...
				);
			
			pause(1);
		end
		
		function Animate(this)
			if ~ishandle(this.Window)
				% Ha nincs ablak, akkor lértehozunk egy újat.
				this.Show();
				return;
			end
			
			t = this.Pendulum.t;
			L = this.Pendulum.L;
			
			% Az inga feje
			[x_H0, y_H0] = Tools.Circle(this.Pendulum.D/2);
			
			for i = 1:length(t)
				if ~ishandle(this.Window) || ~this.IsPlayed
					break;
				end
				
				this.Title.String = strrep(sprintf( ...
					"Az ingamozgás animációja, t = %.1f s", t(i) ...
					), ".", ",");
				
				omega = this.Pendulum.x(i, 1);
				phi = this.Pendulum.x(i, 2);
				
				x_R = L*sin(phi);
				y_R = -L*cos(phi);
				
				this.Rod.XData = [0, x_R];
				this.Rod.YData = [0, y_R];
				
				x_H = x_H0 + x_R;
				y_H = y_H0 + y_R;
				
				this.Head.XData = x_H;
				this.Head.YData = y_H;
				
				% Súlyvektor
				this.Weight.Update(A=[x_R; y_R]);
				% WeightLabel.Position = [ ...
				% 	x_R + 0.05*forceScale*this.m*Pendulum.g, ...
				% 	y_R - 0.5*forceScale*this.m*Pendulum.g ...
				% 	];
				
				% Sebességvektor
				v_x = L*omega*cos(phi);
				v_y = L*omega*sin(phi);
				this.Velocity.Update(A=[x_R; y_R], B=[v_x; v_y]);
				
				% Gyorsulásvektor
				dxdt = this.Pendulum.Model(0, this.Pendulum.x(i, :)');
				beta = dxdt(1);
				a_x = beta*L*cos(phi) - v_y*omega;
				a_y = beta*L*sin(phi) + v_x*omega;
				this.Acceleration.Update(A=[x_R; y_R], B=[a_x; a_y]);
				
				this.Slider.Value = t(i);
				
				pause(20e-3);
			end
			
			if ishandle(this.Window)
				this.IsPlayed = false;
				this.Button.Text = "Lejátszás";
				this.Slider.Enable = "on";
			end
		end
		
		function OnButtonPress(this, source, event)
			if this.IsPlayed
				% Leállítás
				this.IsPlayed = false;
				this.Button.Text = "Lejátszás";
			else
				% Indítás
				this.IsPlayed = true;
				this.Button.Text = "Leállítás";
				this.Slider.Enable = "off";
				this.Animate();
			end
			
		end
	end
	
	methods (Static)
		
		function Run()
			inga = Pendulum( ...
				L=1, m=2, B=0.5, ...
				phi_0=deg2rad(45), ...
				omega_0=2, ...
				t=0:20e-3:25 ...
				);
			inga.Simulate();
			
			gui = PendulumGUI(inga);
			gui.Show();
		end
		
	end
	
end