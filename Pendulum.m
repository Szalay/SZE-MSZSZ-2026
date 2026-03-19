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
			title("Szögsebesség");
			plot(this.t, this.x(:, 1), LineWidth=3);
			
			subplot(2, 1, 2);
			hold on; grid on; box on;
			title("Szöghelyzet");
			plot(this.t, this.x(:, 2), LineWidth=3);
		end
		
	end
	
	methods (Static)
		
		function Run()
			inga = Pendulum( ...
				L=1, m=2, B=0.5, ...
				phi_0=deg2rad(45), ...
				t=0:20e-3:25 ...
				);
			inga.Simulate();
			inga.Plot();
		end
		
	end
	
end