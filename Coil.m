classdef Coil < handle
	%COIL Tekercsmodell
	%   Lineáris mágnesezésű tekercsmodell
	%   u_BE(t) = R i(t) + L di/dt
	%   P(t) = u_BE(t) i(t)
	%   P_R(t) = u_R(t) i_R(t) = R i^2(t)
	%   P_L(t) = u_L(t) i_L(t) = L i(t) di/dt
	%   P(t) ?= P_R(t) + P_L(t)
	
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
		
		% Teljesítmények
		P(:, 1);		% A felvett/bejövő villamos teljesítmény
		P_R(:, 1);		% Az ellenállás teljesítményvesztesége
		P_L(:, 1);		% Az induktivitás teljesítményfelvétele
	end
	
	% Tagfüggvények
	methods
		
		% Konstruktor
		function this = Coil(Settings)
			arguments
				Settings.R(1, 1) {mustBePositive}
				Settings.L(1, 1) {mustBePositive}
				Settings.i_0(1, 1) = 0
				Settings.u_BE(1, 1) function_handle = @(t)zeros(size(t));
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
		
		% Utófeldolgozás
		function PostProcessing(this, Settings)
			arguments
				this
				Settings.checkPowerEquality(1, 1) logical = false;
			end
			this.P = this.u_BE(this.t) .* this.i;
			this.P_R = this.R * this.i.^2; % this.i .* this.i
			
			didt = this.Model(this.t, this.i);
			this.P_L = this.L * this.i .* didt;
			
			if Settings.checkPowerEquality
				D = this.P - (this.P_R + this.P_L);
				S = sum(D.^2);
				disp("A teljesítményszámítás hibanégyzetösszege: " + S);
			end
		end
		
		% Ábrázolás
		function Plot(this)
			Tools.Figure(Name="Tekercs válaszárama");
			
			% Feszültség
			s_u = subplot(3, 1, 1);
			hold on; box on; grid on;
			
			title("Bemeneti feszültség", FontSize=18);
			xlabel("Idő, {\itt}, (s)", FontSize=16);
			ylabel("Feszültség, {\itu_{BE}}, (V)", FontSize=16);
			
			p_u = plot(this.t, this.u_BE(this.t), "b", LineWidth=3);
			
			legend(p_u, "{\itu}_{BE}({\itt})", FontSize=14);
			
			% Áramerősség
			s_i = subplot(3, 1, 2);
			hold on; box on; grid on;
			
			title("Kimeneti áramerősség", FontSize=18);
			xlabel("Idő, {\itt}, (s)", FontSize=16);
			ylabel("Áramerősség, {\iti}, (A)", FontSize=16);
			
			p_i = plot(this.t, this.i, "r", LineWidth=3);
			
			legend(p_i, "{\iti}({\itt})", FontSize=14);
			
			% Teljesítmények
			s_p = subplot(3, 1, 3);
			hold on; box on; grid on;
			
			title("A tekercshez kapcsolódó teljesítmények", FontSize=18);
			xlabel("Idő, {\itt}, (s)", FontSize=16);
			ylabel("Teljesítmény, {\itP}, (W)", FontSize=16);
			
			a_rl = area(this.t, [this.P_R, this.P_L]);
			
			a_rl(1).FaceColor = "y";
			a_rl(2).FaceColor = "c";
			a_rl(2).FaceAlpha = 0.5;
			
			p_p = plot(this.t, this.P, "k", LineWidth=3);
			%p_pr = plot(this.t, this.P_R, "y", LineWidth=3);
			%p_pl = plot(this.t, this.P_L, "m", LineWidth=3);
			
			legend( ...
				[p_p, a_rl(1), a_rl(2)], ...
				["{\itP}({\itt})", "{\itP_R}({\itt})", "{\itP_L}({\itt})"], ...
				FontSize=14 ...
				);
			
			% A vízszintes nagyítás összekapcsolása
			linkaxes([s_u, s_i, s_p], "x");
		end
		
	end
	
	% Statikus tagfüggvények
	methods (Static)
		
		function Run()
			tekercs = Coil( ...
				R=5, L=10e-3, i_0=-200e-3, ...
				u_BE=@(t)5*cos(2*pi*250*t), ...
				t=0:20e-6:20e-3 ...
				);
			tekercs.Simulate();
			tekercs.PostProcessing(checkPowerEquality=true);
			tekercs.Plot();
		end
		
	end
	
end