%zadanie 1
% wczytanie danych
T = readtable('archiwum_tab_a_2025.csv', 'Delimiter', ';');
T(1, :) = [];
surowe_daty = T{:, 1};
surowe_USD  = T{:, 3};
surowe_JPY  = T{:, 14};
daty = datetime(string(surowe_daty), 'InputFormat', 'yyyyMMdd');
kursA = str2double(strrep(string(surowe_USD), ',', '.'));
kursB = str2double(strrep(string(surowe_JPY), ',', '.'));

puste_daty = isnat(daty);
daty(puste_daty) = [];
kursA(puste_daty) = [];
kursB(puste_daty) = [];
kursy = table(daty, kursA, kursB, 'VariableNames', {'Data', 'USD', 'JPY'});
head(kursy)

% zgodność dat
indeks_tylko_jeden = (isnan(kursA) & ~isnan(kursB)) | (~isnan(kursA) & isnan(kursB));
daty_tylko_w_jednym = daty(indeks_tylko_jeden);

liczba_dat = length(daty_tylko_w_jednym);
fprintf('Liczba dat obecnych tylko w jednym szeregu: %d\n', liczba_dat);

if liczba_dat > 0
    disp('Pierwsze 5 takich dat:');
    disp(daty_tylko_w_jednym(1:min(5, liczba_dat)));
end

% uspójnienie osi
%metoda A interskecja dat
indeksy_wspolne = ~isnan(kursA) & ~isnan(kursB);
daty_intersekcja = daty(indeksy_wspolne);
kursA_intersekcja = kursA(indeksy_wspolne);
kursB_intersekcja = kursB(indeksy_wspolne);
Tabela_Intersekcja = table(daty_intersekcja, kursA_intersekcja, kursB_intersekcja, 'VariableNames', {'Data', 'USD', 'JPY'});

%metoda B interpolacja liniowa
kursA_interpolowany = fillmissing(kursA, 'linear', 'SamplePoints', daty);
kursB_interpolowany = fillmissing(kursB, 'linear', 'SamplePoints', daty);
Tabela_Interpolacja = table(daty, kursA_interpolowany, kursB_interpolowany, 'VariableNames', {'Data', 'USD', 'JPY'});

% przyrosty
usd = Tabela_Interpolacja.USD;
jpy = Tabela_Interpolacja.JPY;

usd_bezwzgl = diff(usd);
usd_wzgl    = diff(usd) ./ usd(1:end-1);
usd_log     = diff(log(usd));

jpy_bezwzgl = diff(jpy);
jpy_wzgl    = diff(jpy) ./ jpy(1:end-1);
jpy_log     = diff(log(jpy));

m_usd_bezwzgl = mean(usd_bezwzgl); 
std_usd_bezwzgl = std(usd_bezwzgl);
m_usd_wzgl = mean(usd_wzgl);    
std_usd_wzgl = std(usd_wzgl);
m_usd_log = mean(usd_log);     
std_usd_log = std(usd_log);

m_jpy_bezwzgl = mean(jpy_bezwzgl); 
std_jpy_bezwzgl = std(jpy_bezwzgl);
m_jpy_wzgl = mean(jpy_wzgl);    
std_jpy_wzgl = std(jpy_wzgl);
m_jpy_log = mean(jpy_log);     
std_jpy_log = std(jpy_log);

Typ_Przyrostu = {'Bezwzględne'; 'Względne'; 'Logarytmiczne'};
Srednia_USD   = [m_usd_bezwzgl; m_usd_wzgl; m_usd_log];
STD_USD       = [std_usd_bezwzgl; std_usd_wzgl; std_usd_log];
Srednia_JPY   = [m_jpy_bezwzgl; m_jpy_wzgl; m_jpy_log];
STD_JPY       = [std_jpy_bezwzgl; std_jpy_wzgl; std_jpy_log];

Tabela_Statystyk = table(Typ_Przyrostu, Srednia_USD, STD_USD, Srednia_JPY, STD_JPY);
disp(Tabela_Statystyk);

% Odpowiedz na pytania do zadania 1:
% W datach kursów USD i JPY nie ma rozbieżności.
% USD charakteryzuje się większą zmiennością niż JPY, ponieważ odchylenie
% standardowe przyrostów
% każdego rodzaju jest
% większe dla USD (np. dla przyrostów względnych 0.00594 > 0.00586). 
% Nie, wniosek nie zależy od wyboru między przyrostem względnym a logarytmicznym. 
% W obu przypadkach USD wykazuje wyższą zmienność. Warto jednak zauważyć,
% że obliczone odchylenia standardowe są do siebie bardzo zbliżone (różnią
% się dopiero 4 miejscem po
% przecinku) co oznacza, że ich zmienność jest podobna.
% Porównywanie
% zmienności róznych walut na podstawie ich przyrostów bezwzględnych jest
% błędne, ponieważ
% przyrosty bezwzględne zależą od nominalnych poziomów cen. USD jest droższ
% y niż JPY, więc naturalnie generuje większe wartości bezwzględnych różnic,
% co sztucznie zawyża odchylenie standardowe.

% zadanie 2
usd = Tabela_Interpolacja.USD;
daty_wykres = Tabela_Interpolacja.Data;
x = (1:length(usd))';
p = polyfit(x, usd, 1);
usd_trend = polyval(p, x);
bledy = usd - usd_trend;
rmse_usd = sqrt(mean(bledy.^2));
fprintf('Równanie trendu liniowego: y = %.4fx + %.4f\n', p(1), p(2));
fprintf('Błąd RMSE: %.4f PLN\n', rmse_usd);

figure;
plot(daty_wykres, usd, 'b-');
hold on;
plot(daty_wykres, usd_trend, 'r-');
title('Kurs USD z dopasowanym trendem liniowym');
xlabel('Data');
ylabel('Kurs USD (PLN)');
legend('Kurs rzeczywisty NBP', 'Trend liniowy', 'Location', 'best');
grid on;

% szereg podzielony na połowy 
usd = Tabela_Interpolacja.USD;
N = length(usd);
polowa = floor(N / 2);

% pierwsza polowa
x1 = (1:polowa)';
y1 = usd(1:polowa);

p1 = polyfit(x1, y1, 1);
y1_trend = polyval(p1, x1);
rmse1 = sqrt(mean((y1 - y1_trend).^2));
% druga polowa
x2 = (polowa+1:N)';
y2 = usd(polowa+1:N);

p2 = polyfit(x2, y2, 1);
y2_trend = polyval(p2, x2);
rmse2 = sqrt(mean((y2 - y2_trend).^2));

fprintf('pierwsza połowa szeregu: (dni 1 do %d):\n', polowa);
fprintf('  Wzór trendu: y = %.6fx + %.4f\n', p1(1), p1(2));
fprintf('  Błąd RMSE:    %.4f PLN\n\n', rmse1);

fprintf('druga połowa szeregu: (dni %d do %d):\n', polowa+1, N);
fprintf('  Wzór trendu: y = %.6fx + %.4f\n', p2(1), p2(2));
fprintf('  Błąd RMSE:    %.4f PLN\n', rmse2);

% wielomian 5 stopnia
usd = Tabela_Interpolacja.USD;
daty_wykres = Tabela_Interpolacja.Data;
x = (1:length(usd))';
p5 = polyfit(x, usd, 5);
usd_wielomian = polyval(p5, x);
reszty = usd - usd_wielomian;

figure;
% reszty = dane - wielomian
subplot(2, 1, 1);
plot(daty_wykres, reszty, 'b-');
hold on;
plot(daty_wykres, zeros(size(reszty)), 'r--');
title('Wykres reszt w czasie');
xlabel('Data');
ylabel('Błąd resztowy (PLN)');
grid on;

% histogram reszt
subplot(2, 1, 2);
histogram(reszty, 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'w');
title('Histogram reszt');
xlabel('Wartość błędu (PLN)');
ylabel('Liczba wystąpień');
grid on;


rmse_wielomian5 = sqrt(mean(reszty.^2));
fprintf('Błąd RMSE (wielomian 5. stopnia): %.4f PLN\n', rmse_wielomian5);

% wykres dopasowania 
figure;
plot(Tabela_Interpolacja.Data, Tabela_Interpolacja.USD, 'b-');
hold on;

plot(Tabela_Interpolacja.Data, usd_wielomian, 'r-');
title('Kurs USD wraz z dopasowanym wielomianem 5. stopnia');
xlabel('Data');
ylabel('Kurs USD (PLN)');
legend('Kurs rzeczywisty NBP', 'Wielomian 5. stopnia (polyfit)', 'Location', 'best');
grid on;

% wykres dane +3 trendy
figure;
plot(Tabela_Interpolacja.Data, Tabela_Interpolacja.USD, 'b-');
hold on;
plot(Tabela_Interpolacja.Data, usd_trend, 'r--');

daty_polowa1 = Tabela_Interpolacja.Data(1:polowa);
plot(daty_polowa1, y1_trend, 'g-.');
daty_polowa2 = Tabela_Interpolacja.Data(polowa+1:end);
plot(daty_polowa2, y2_trend, 'm-.');

title('Porównanie trendu globalnego z trendami cząstkowymi dla USD');
xlabel('Data');
ylabel('Kurs USD (PLN)');

legend('Kurs rzeczywisty NBP', 'Trend globalny (całość)', ...
    'Trend cząstkowy (I połowa)', 'Trend cząstkowy (II połowa)','Location', 'best');

grid on;

% odpowiedz na pytania:
% nachylenia połówek różnią się bardzo
% istotnie co widać na wykresie oraz porównując
% współczynniki kierunkowe dopasowanych prostyych (-0.003888 dla I połowy
% i -0.000194 dla II połowy. Przez piewszą połowę roku 2025 cena USD
% zdecydowanie spadała a od lipca miała jedynie delikatne wahania.
% Reszty są symetyczne wokół
% zera co widać i na histogramie reszt i na wykresie reszt. Błąd RMSE jest
% zdecydoanie niższy
% dla wielomianu 5 stopnia niż dopasowania liniowego (0.0338), a reszty są
% symetryczne więc moim
% zdaniem 5 stopień jest odpowiedni dla mojej waluty.