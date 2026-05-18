% wczytanie danych
T = readtable('archiwum_tab_a_2025.csv', 'Delimiter', ';');
T(1, :) = [];
surowe_daty = T{:, 1};
surowe_USD  = T{:, 3};
daty = datetime(string(surowe_daty), 'InputFormat', 'yyyyMMdd');
kursA = str2double(strrep(string(surowe_USD), ',', '.'));
puste_daty = isnat(daty);
% usuniecie pierwszej pustej linijki
daty(puste_daty) = [];
kursA(puste_daty) = [];
kursy = table(daty, kursA, 'VariableNames', {'Data', 'USD'});
head(kursy)
fprintf('KURS USD: \n')
% zadanie 1
srednia_globalna = mean(kursy.USD);
prog = 1.12 * srednia_globalna;
indeksy_powyzej = kursy.USD > prog;
probki_powyzej = kursy(indeksy_powyzej, :);

liczba_probek = height(probki_powyzej);
calkowita_dlugosc = height(kursy);
stosunek = (liczba_probek / calkowita_dlugosc) * 100;

fprintf('Średnia globalna kursu USD: %.2f\n', srednia_globalna);
fprintf('Wartość progowa (112%%): %.2f\n', prog);
fprintf('Liczba próbek powyżej progu: %d\n', liczba_probek);
fprintf('Procentowy udział w całym szeregu: %.2f%%\n', stosunek);

% zadanie 2
Yd = diff(kursy.USD);
Md = mean(Yd);

L1 = 7;
licznik = 0;
i = 1;

while i <= length(Yd) - L1 + 1
    if mean(Yd(i : i+L1-1)) > Md
        j = i + L1;
        while j <= length(Yd) && mean(Yd(i:j)) > Md
            j = j + 1;
        end
        licznik = licznik + 1;
        i = j;
    else
        i = i + 1;
    end
end

fprintf('\nŚrednia przyrostów: %.6f\n', Md);
fprintf('Liczba maksymalnych podciągów (długość >= 7): %d\n', licznik);

% zadanie 3
Y = kursy.USD;
D = kursy.Data;
N = length(Y);

indeksy_wzorca = [];

for t = 1:(N - 4)
    
    warunek_1 = (Y(t) - Y(t+1)) > (1.5 / 100) * Y(t);
    warunek_2 = Y(t+2) > Y(t+1);
    warunek_3 = Y(t+3) < Y(t+2);
    warunek_4 = Y(t+4) > Y(t+3);
    
    if warunek_1 && warunek_2 && warunek_3 && warunek_4
        indeksy_wzorca = [indeksy_wzorca; t];
    end
end

liczba_wystapien = length(indeksy_wzorca);

fprintf('\nLiczba wystąpień wzorca: %d\n', liczba_wystapien);
ilosc_do_wyswietlenia = min(3, liczba_wystapien);

if ilosc_do_wyswietlenia > 0

    fprintf('Pierwsze 3 daty wystąpienia wzorca (początek wzorca):\n');
    for k = 1:ilosc_do_wyswietlenia
        disp(D(indeksy_wzorca(k)));
    end
else
    fprintf('Nie znaleziono żadnych wystąpień tego wzorca.\n');
end

% zadanie 4
Y = kursy.USD;
N = length(Y);
mi = mean(Y);
sigma = std(Y);

szereg3 = mi + sigma * randn(N, 1);

% wizualizacja
figure; 
plot(kursy.Data, kursy.USD, 'b-');
hold on; 
plot(kursy.Data, szereg3, 'r-');
hold off;
title('Kurs USD i wygenerowany szereg3');
xlabel('Data');
ylabel('Wartość');
legend('Oryginalny kurs USD', 'szereg3', 'Location', 'best');
grid on;

fprintf('\n WYGENEROWANY SZEREG: \n')

Y_3 = szereg3;
D = kursy.Data;
N_3 = length(Y_3);


srednia_globalna_3 = mean(Y_3);
prog_3 = 1.12 * srednia_globalna_3;

indeksy_powyzej_3 = Y_3 > prog_3;
liczba_probek_3 = sum(indeksy_powyzej_3); 
procent_udzialu_3 = (liczba_probek_3 / N_3) * 100;

fprintf('Liczba próbek powyżej progu: %d\n', liczba_probek_3);
fprintf('Procentowy udział: %.2f%%\n\n', procent_udzialu_3);


Yd_3 = diff(Y_3);
Md_3 = mean(Yd_3);
L1 = 7;
licznik_3 = 0;
i = 1;

while i <= length(Yd_3) - L1 + 1
    if mean(Yd_3(i : i+L1-1)) > Md_3
        j = i + L1;
        while j <= length(Yd_3) && mean(Yd_3(i:j)) > Md_3
            j = j + 1;
        end
        licznik_3 = licznik_3 + 1;
        i = j;
    else
        i = i + 1;
    end
end

fprintf('Średnia przyrostów: %.6f\n', Md_3);
fprintf('Liczba maksymalnych podciągów (długość >= %d): %d\n\n', L1, licznik_3);

indeksy_wzorca_3 = [];

for t = 1:(N_3 - 4)
    warunek_1 = (Y_3(t) - Y_3(t+1)) > (1.5 / 100) * Y_3(t);
    warunek_2 = Y_3(t+2) > Y_3(t+1);
    warunek_3 = Y_3(t+3) < Y_3(t+2);
    warunek_4 = Y_3(t+4) > Y_3(t+3);
    
    if warunek_1 && warunek_2 && warunek_3 && warunek_4
        indeksy_wzorca_3 = [indeksy_wzorca_3; t];
    end
end

liczba_wystapien_3 = length(indeksy_wzorca_3);

fprintf('Liczba wystąpień wzorca: %d\n', liczba_wystapien_3);

if liczba_wystapien_3 > 0
    fprintf('Pierwsze 3 daty wystąpienia wzorca (początek wzorca):\n');
    ilosc_do_wyswietlenia_3 = min(3, liczba_wystapien_3);
    for k = 1:ilosc_do_wyswietlenia_3
        disp(D(indeksy_wzorca_3(k)));
    end
else
    fprintf('Nie znaleziono żadnych wystąpień wzorca.\n');
end

% w kursie prawdziwej waluty nie ma ani próbek, których wartość przekracza
% próg 112% średniej globalnej, ani wzorca z zadania 3. Znaleziono 6
% podciągów spełniających założenia z zadania 2. W wygenerowanym
% losowo szeregu 3, 2 próbki mają wartość większą niż 112% średniej
% globalnej, istnieje 14 podciągów spełniających założenia z zadania 2 oraz
% 27 wystąpień wzorca z zadania 3.