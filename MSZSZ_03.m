% 1. Nyelvi alapok
%	Változók létrehozása, alapműveletek, parancssor
%	Függvényhívás
%	Tömbök (létrehozás, hozzáférés az elemekhez, műveletek)
%	Művelet végrehajtási sorrend
%	Adattípusok (szám, szöveg, struktúra, cellatömb)

% Összegzés
%	=, [], {}, (), ', '...', "...", ., .(), @(...)..., ;, ,, %, :

% 2. Vezérlési szerkezetek

% A kód végrehajtása alapvetően sorról sorra történik.
% A sorokon belül a műveleti sorrend szerint történik a végrahajtás.

% A vezérlési szerkezetekkel el tudunk térni a sorról sorra történő
% végrehajtástól. A végrehajtás a következő sor helyett valahova máshova
% "ugrik".

% 2.1 Elágazások
% Feltételes végrehajtás, csak bizonyos sorok hajtódnak végre.
% Az elágazásoknál mindig későbbi sorra ugrik a végrehajtás.

% 2.1.1 If(-(elseif-)else) szerkezet

%% 1. példa
b = true;
if b
	disp('A változó értéke igaz.');
else
	disp('A változó értéke hamis.');
end

%% 2. példa
n = rand;
if n < 0.25
	fprintf("Az n (%.3f) kicsi.\n", n)
elseif 0.25 <= n && n < 0.75
	fprintf("Az n (%.3f) közepes.\n", n)
else
	fprintf("Az n (%.3f) nagy.\n", n)
end

% 2.1.2 Switch-case-otherwise szerkezet

%% 3. példa
n = randn;

switch sign(n)
	case 1
		fprintf('Az n (%+.3f) pozitív.\n', n);
	case -1
		fprintf('Az n (%.3f) negatív.\n', n);
	otherwise
		disp('Az n nulla.');
end


% 2.2 Ciklusok
% A végrehajtás visszaugrik korábbi sorra.

% 2.2.1 For ciklus
% A for ciklus vektor elemeit járja be.
% A bejárás megszakítható, vagy elem átugorható

%% 4. példa

v = [1:3, 10, 2, 5];
for i = v
	% Az i a futóváltozó (nem feltétlenül index).
	% Az i sorban egyesével felveszi a v elemeinek értékeit.
	rand(1, i)
end

%% 5. példa
v = 1:10;
for i = v
	n = randn;
	
	switch sign(n)
		case 1
			fprintf('Az n (%+.3f) pozitív.\n', n);
		case -1
			fprintf('Az n (%.3f) negatív.\n', n);
		otherwise
			disp('Az n nulla.');
	end
end

%% 6. példa
clc
v = 1:10;
for i = v
	n = rand;
	
	if n < 0.25
		fprintf("Az n (%.3f) kicsi.\n", n)
		continue
	elseif 0.25 <= n && n < 0.75
		fprintf("Az n (%.3f) közepes.\n", n)
	else
		fprintf("Az n (%.3f) nagy. Megszakítás.\n", n)
		break
	end
	
	disp("Az elemhez tartozó végrahajtás végigfutott.");
end

% 2.2.2 While ciklus

%% 7. példa
a = 1;
while a < 5
	fprintf("Az a értéke %d\n", a);
	a = a + 1;
end

%% 8. példa
clc
a = 0;
n = 1;
while a < 10
	fprintf("%d: az a értéke %.3g\n", n, a);
	a = a + rand;
	n = n + 1;
end
fprintf("Az a utolsó értéke %.3g\n", a);

%% 9. példa
% Adott határszám eléréséhez szükséges lépések eloszlása

clc
N = 100000;			% A próbálkozások száma
M = 25;				% Határszám
S = zeros(N, 1);	% A lépések számai

for i = 1:N
	a = 0;
	n = 1;
	while a < M
		a = a + rand;
		n = n + 1;
	end
	
	S(i) = n;
end

% Átrendezés az oszlopdiagrmaként történő megjelenítéshez
x = unique(S);
y = zeros(size(x));
for i = 1:length(x)
	y(i) = sum(S == x(i));
end

figure();
bar(x, y);

% A histogram(S) beépített függvény ezt pont megcsinálja.

% 2.3 További vezérlési szerkezetek

% Do-while ciklus
% Parfor párhuzamosan futó for ciklus

% A kivételkezelés try-catch/throw

% 3. Kódszervezés

% 3.1 Parancsfájl (script)
% Sorról sorra futtatható kód.
% Szakaszolás (sectioning), külön futtatható szakaszok.

% 3.2 Függvények (function)
% A függvényt a vele megegyező nevű m-fájlba kell tenni.
