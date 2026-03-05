function histogram_example(Settings)
	arguments
		Settings.LimitNumber(1, 1) = 10		% a határszám
		Settings.AttemptCount(1, 1) = 100	% a próbálkozások száma
	end
	
	S = zeros(Settings.AttemptCount, 1);	% A lépések számai
	
	for i = 1:Settings.AttemptCount
		a = 0;
		n = 1;
		while a < Settings.LimitNumber
			a = a + rand;
			n = n + 1;
		end
		
		S(i) = n;
	end
	
	histogram_plot(Settings.AttemptCount, Settings.LimitNumber, S);
end

function histogram_plot(N, M, S)
	% Ábrázolás
	Tools.Figure();
	
	titleFormatString = "Hány véletlenszám összege szükséges %d eléréséhez?";
	title(sprintf(titleFormatString, M), FontSize=18);
	
	xlabel("A véletlenszámok darabszáma", FontSize=16);
	ylabel(sprintf("Előfordulás %d próbálkozásban", N), FontSize=16);
	
	h = histogram(S);
	
	% Felirat
	x_L = max(S);
	y_L = max(h.Values);
	text( ...
		x_L, y_L, "{\itN} = " + N, ...
		FontSize=16, HorizontalAlignment="right", VerticalAlignment="top" ...
		);
	
	% Haranggörbe
	% 1/sqrt(2 pi sigma^2) exp(-(x-mu)^2/(2 sigma^2))
	mu = mean(S);
	sigma = std(S);
	x = h.BinLimits(1):0.1:h.BinLimits(2);
	
	n = @(x) 1/sqrt(2*pi*sigma^2) * exp(-(x-mu).^2/(2*sigma^2));
	p = plot(x, N*n(x), "k-", LineWidth=3);
	
	legend([h, p], {"Hisztogram", "Illesztés"}, FontSize=14, Location="NorthWest");
end