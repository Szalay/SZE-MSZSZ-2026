% Függvényábrázolási példa
%
%	y = f(x) = A cos(2 pi f_0 t + phi) + B
%

% A függvény paraméterei változókként létrehozva
A = 5;
f_0 = 2;
phi = deg2rad(45);
B = 1;

t_0 = 0;
t_1 = 1;
N = 1000;

% A függvényt függvénymutatóként valósítjuk meg
f = @(t) A*cos(2*pi*f_0*t + phi) + B;

% Az ábrázolandó adat
%t = t_0:((t_1-t_0)/(N-1)):t_1;
t = linspace(t_0, t_1, N);
y = f(t);

% Ábrázolás
window = figure();
window.Color = [1, 1, 1];

hold on;
box on;
grid on;

% Feliratozás
title("Függvényábrázolás", "FontSize", 18);
xlabel("Idő, t, (s)", FontSize=16);
ylabel("Függvényérték, y", FontSize=16);

% Az ábrázolt tartomány beállítása
xlim([t_0, t_1]);
ylim(B + 1.25*[-A, A]);

% Az adat megjelenítése
plot(t, y, "b-", LineWidth=3);
