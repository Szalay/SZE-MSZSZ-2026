classdef Pendulum < handle
	%PENDULUM Inga
	
	properties
		% Az inga méretei
		m;
		L;
		
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
		x_0;
	end
	
	% Állandó tulajdonságok
	properties (Constant)
		g = 9.81;	% N/kg
	end
	
	methods
		
		function this = Pendulum(Settings)
			arguments
				Settings.m(1, 1) {mustBePositive}
				Settings.L(1, 1) {mustBePositive}
				Settings.omega_0(1, 1) = 0;
				Settings.phi_0(1, 1) = 0;
				Settings.t(:, 1)
			end
			
			this.m = Settings.m;
			this.L = Settings.L;
			this.omega_0 = Settings.omega_0;
			this.phi_0 = Settings.phi_0;
			
			this.t = Settings.t;
		end
		
		function J = get.J(this)
			J = this.m*this.L^2;
		end
		
		function x_0 = get.x_0(this)
			x_0 = [this.omega_0; this.phi_0];
		end
		
		% Az ingamodell leképezése
		function dxdt = Model(this, ~, x)
			% x = [omega(t); phi(t)]
			omega = x(1);
			phi = x(2);
			
			domegadt = 1/this.J*(-this.m*Pendulum.g*this.L*sin(phi));
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
			inga = Pendulum(L=1, m=2, phi_0=deg2rad(45), t=0:20e-3:10);
			inga.Simulate();
			inga.Plot();
		end
		
	end
	
end