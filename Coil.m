classdef Coil < handle
	%COIL Tekercsmodell
	%   Lineáris mágnesezésű tekercsmodell
	%   u_BE(t) = R i(t) + L di/dt
	
	% Tulajdonságok
	properties
		% Modellparaméterek
		R;		% Ellenállás, Ohm
		L;		% Öninduktivitás, H
		
		% Kezdeti érték
		i_0;
		
		% Bemenet (?)
		u_BE;
		
		% Megoldás (oszlopvektorok)
		t(:, 1);		% Idővektor
		i(:, 1);		% Az áramerősség
	end
	
	% Tagfüggvények
	methods
		
		% Konstruktor
		function this = Coil(Settings)
			arguments
				Settings.R(1, 1) {mustBePositive}
				Settings.L(1, 1) {mustBePositive}
				Settings.i_0(1, 1) = 0
				Settings.u_BE(1, 1) function_handle = @(t)0;
				Settings.t(:, 1)
			end
			
			this.R = Settings.R;
			this.L = Settings.L;
			this.i_0 = Settings.i_0;
			this.u_BE = Settings.u_BE;
			this.t = Settings.t;
		end
		
		% A modell leképezése
		function didt = Model(this, t, i)
			% di/dt = 1/L (-R i + u_BE(t))
			didt = 1/this.L * (-this.R*i + this.u_BE(t));
		end
		
		% Szimuláció
		function Simulate(this)
			% [t, y] = solver(odefun, tspan, y0)
			% A "solver" a numerikus megoldó. 
			[this.t, this.i] = ode45(@this.Model, this.t, this.i_0);
		end
		
		% Ábrázolás
		function Plot(this)
			Tools.Figure(Name="Tekercs válaszárama");
			
			% Feszültség
			s_u = subplot(2, 1, 1);
			hold on; box on; grid on;
			
			title("Bemeneti feszültség", FontSize=18);
			xlabel("Idő, {\itt}, (s)", FontSize=16);
			ylabel("Feszültség, {\itu_{BE}}, (V)", FontSize=16);
			
			p_u = plot(this.t, this.u_BE(this.t), "b", LineWidth=3);
			
			legend(p_u, "{\itu}_{BE}({\itt})", FontSize=14);
			
			% Áramerősség
			s_i = subplot(2, 1, 2);
			hold on; box on; grid on;
			
			title("Kimeneti áramerősség", FontSize=18);
			xlabel("Idő, {\itt}, (s)", FontSize=16);
			ylabel("Áramerősség, {\iti}, (A)", FontSize=16);
			
			p_i = plot(this.t, this.i, "r", LineWidth=3);
			
			legend(p_i, "{\iti}({\itt})", FontSize=14);
			
			linkaxes([s_u, s_i], "x");
		end
		
	end
	
	% Statikus tagfüggvények
	methods (Static)
		
		function Run()
			tekercs = Coil( ...
				R=1, L=10e-3, i_0=-200e-3, ...
				u_BE=@(t)5*cos(2*pi*500*t), ...
				t=0:20e-6:50e-3 ...
				);
			tekercs.Simulate();
			tekercs.Plot();
		end
		
	end
	
end