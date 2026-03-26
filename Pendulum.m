classdef Pendulum < handle
	%PENDULUM Inga
	
	properties
		% Az inga méretei
		m;
		L;
		D;
		
		% A veszteségek jellemzői
		B;			% Forgási súrlódási együttható, Nms/rad
		c_W;
		
		% Kezdeti értékek
		omega_0;
		phi_0;
		
		% Megoldás
		t;
		x;
	end
	
	% Függő tulajdonságok
	properties (Dependent)
		J;
		A;
		x_0;
	end
	
	% Állandó tulajdonságok
	properties (Constant)
		g = 9.81;		% N/kg
		rho_L = 1.2;	% kg/m^3
	end
	
	methods
		
		function this = Pendulum(Settings)
			arguments
				Settings.m(1, 1) {mustBePositive}
				Settings.L(1, 1) {mustBePositive} = 1;
				Settings.D(1, 1) {mustBePositive} = 0.1;
				Settings.B(1, 1) {mustBeNonnegative} = 0;
				Settings.c_W(1, 1) {mustBeNonnegative} = 0.47;
				Settings.omega_0(1, 1) = 0;
				Settings.phi_0(1, 1) = 0;
				Settings.t(:, 1)
			end
			
			this.m = Settings.m;
			this.L = Settings.L;
			this.D = Settings.D;
			this.B = Settings.B;
			this.c_W = Settings.c_W;
			
			this.omega_0 = Settings.omega_0;
			this.phi_0 = Settings.phi_0;
			
			this.t = Settings.t;
		end
		
		function J = get.J(this)
			J = this.m*this.L^2;
		end
		
		function A = get.A(this)
			A = this.D^2*pi/4;
		end
		
		function x_0 = get.x_0(this)
			x_0 = [this.omega_0; this.phi_0];
		end
		
		% Az ingamodell leképezése
		function dxdt = Model(this, ~, x)
			% x = [omega(t); phi(t)]
			omega = x(1);
			phi = x(2);
			
			domegadt = 1/this.J*( ...
				-this.m*Pendulum.g*this.L*sin(phi) ... % M_G
				-this.B*omega ... % M_S
				-1/2*this.c_W*Pendulum.rho_L*this.A*this.L^2*omega^2*sign(omega) ... % M_L
				);
			dphidt = omega;
			
			dxdt = [domegadt; dphidt];
		end
		
		% Szimuláció
		function Simulate(this)
			[this.t, this.x] = ode45(@this.Model, this.t, this.x_0);
		end
		
		% Ábrázolás
		function Plot(this)
			Tools.Figure(Name="Ingamozgás szimulációja");
			
			subplot(2, 1, 1);
			hold on; grid on; box on;
			title("Az inga szögsebessége", FontSize=18);
			xlabel("Idő, {\itt} (s)", FontSize=16);
			ylabel("Szögsebesség, {\it\omega} (rad/s)", FontSize=16);
			
			plot(this.t, this.x(:, 1), LineWidth=3);
			
			subplot(2, 1, 2);
			hold on; grid on; box on;
			title("Az inga szöghelyzete", FontSize=18);
			xlabel("Idő, {\itt} (s)", FontSize=16);
			ylabel("Szöghelyzet, {\itφ} (°)", FontSize=16);
			
			plot(this.t, rad2deg(this.x(:, 2)), LineWidth=3);
		end
		
		% Animáció
		function Animate(this)
			Window = Tools.Figure(Name="Az ingamozgás animációja");
			
			Title = title("Az ingamozgás animációja", FontSize=18);
			
			xlabel("Vízszintes hely, {\itx} (m)", FontSize=16);
			ylabel("Függőleges hely, {\ity} (m)", FontSize=16);
			
			% Az ábrázolt síkrész
			axis equal;
			xlim(1.5*this.L*[-1, 1]);
			ylim(this.L*[-1.75, 0.25]);
			
			% Fal
			Wall = plot(1.25*this.L*[-1, 1], [0, 0], "k-", LineWidth=3);
			
			% Az inga szára
			x_R = this.L*sin(this.phi_0);
			y_R = -this.L*cos(this.phi_0);
			Rod = plot( ...
				[0, x_R], [0, y_R], ...
				"k-", LineWidth=2 ...
				);
			
			% Csukló
			[x_J, y_J] = Tools.Circle(0.015);
			Joint = patch( ...
				XData=x_J, YData=y_J, ...
				FaceColor=[1, 1, 1], EdgeColor=[0, 0, 0], ...
				LineWidth=1 ...
				);
			
			% Az inga feje
			[x_H0, y_H0] = Tools.Circle(this.D/2);
			x_H = x_H0 + x_R;
			y_H = y_H0 + y_R;
			Head = patch( ...
				XData=x_H, YData=y_H, ...
				FaceColor=[0.25, 0.5, 0.75], EdgeColor=[0, 0, 0], ...
				LineWidth=1 ...
				);
			
			% Súly
			forceScale = 1/40;
			Weight = Vector2D( ...
				Label="$$m \vec{g}$$", Color="r", Scale=forceScale, ...
				A=[x_R; y_R], B=[0; -this.m*Pendulum.g] ...
				);
			
			% Sebesség, \vec{v} = \vec{omega} × \vec{r}
			velocityScale = 1/5;
			v_x0 = this.omega_0*this.L*cos(this.phi_0);
			v_y0 = this.omega_0*this.L*sin(this.phi_0);
			Velocity = Vector2D( ...
				Label="$$\vec{v}$$", Color="b", Scale=velocityScale, ...
				A=[x_R; y_R], B=[v_x0; v_y0] ...
				);
			
			% Gyorsulás, \vec{a} = \vec{\beta} × \vec{r} + \vec{omega} × \vec{v}
			accelerationScale = 0.1;
			dxdt_0 = this.Model(0, this.x_0);
			beta = dxdt_0(1);
			a_x0 = beta*this.L*cos(this.phi_0) - v_y0*this.omega_0;
			a_y0 = beta*this.L*sin(this.phi_0) + v_x0*this.omega_0;
			Acceleration = Vector2D( ...
				Label="$$\vec{a}$$", Color="g", Scale=accelerationScale, ...
				A=[x_R; y_R], B=[a_x0; a_y0] ...
				);
			
			for i = 1:length(this.t)
				if ~ishandle(Window)
					break;
				end
				
				Title.String = strrep(sprintf( ...
					"Az ingamozgás animációja, t = %.1f s", this.t(i) ...
					), ".", ",");
				
				omega = this.x(i, 1);
				phi = this.x(i, 2);
				
				x_R = this.L*sin(phi);
				y_R = -this.L*cos(phi);
				
				Rod.XData = [0, x_R];
				Rod.YData = [0, y_R];
				
				x_H = x_H0 + x_R;
				y_H = y_H0 + y_R;
				
				Head.XData = x_H;
				Head.YData = y_H;
				
				% Súlyvektor
				Weight.Update(A=[x_R; y_R]);
				% WeightLabel.Position = [ ...
				% 	x_R + 0.05*forceScale*this.m*Pendulum.g, ...
				% 	y_R - 0.5*forceScale*this.m*Pendulum.g ...
				% 	];
				
				% Sebességvektor
				v_x = this.L*omega*cos(phi);
				v_y = this.L*omega*sin(phi);
				Velocity.Update(A=[x_R; y_R], B=[v_x; v_y]);
				
				% Gyorsulásvektor
				dxdt = this.Model(0, this.x(i, :)');
				beta = dxdt(1);
				a_x = beta*this.L*cos(phi) - v_y*omega;
				a_y = beta*this.L*sin(phi) + v_x*omega;
				Acceleration.Update(A=[x_R; y_R], B=[a_x; a_y]);
				
				drawnow;
				pause(20e-3);
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
			%inga.Plot();
			inga.Animate();
		end
		
	end
	
end