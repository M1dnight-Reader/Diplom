clc

fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(13).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(13).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(13).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
semimotor(13).N = semimotor(13).N;
reducer(13).u = semimotor(13).nmot / semimotor(13).nreq;
reducer(13).k = reducer(13).u - 1;
reducer(13).C = 3;
reducer(13).t = 5000;
reducer(13).na = semimotor(13).nmot;
reducer(13).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(13).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(13).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(13).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(13).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(13).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(13).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(13).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(13).k);
    if mod(zb1 + za, 2) == 0
        zb = zb1;
    else
        zb = zb2;
    end
    col3(i) = zb;
    col4(i) = zb/za;
    col5(i) = 1 + zb/za;
    col6(i) = (zb + za)/2;
    col7(i) = (zb - za)/2;
    za = za + 3;
end

T = table(col1, col2, col3, col4, col5, col6, col7, 'VariableNames', ...
    {'za', 'zb_za_k', 'zb_kratno_C', 'k_star', 'u_calc', 'gamma', 'zc'});

fprintf('4.2. Варианты подбора числа зубьев колес:\n');
disp(T);

% 4.3. Определение относительной частоты вращения колес
reducer(13).nah = semimotor(13).nmot - semimotor(13).nreq;
reducer(13).nbh = 0 - semimotor(13).nreq;
reducer(13).nch = -(semimotor(13).nmot - semimotor(13).nreq) * 2 / (reducer(13).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(13).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(13).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(13).nch);

% 4.4. Определение КПД редуктора
reducer(13).etarel = (1 + reducer(13).k * 0.99 * 0.97) / (1 + reducer(13).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(13).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(13).etamuf = 0.99;
reducer(13).eta = reducer(13).etarel * reducer(13).etamuf;
reducer(13).Ndvig = semimotor(13).N / reducer(13).eta;
reducer(13).N1 = reducer(13).Ndvig * reducer(13).etamuf;
reducer(13).T1 = 9.550 * reducer(13).N1 / semimotor(13).nmot;
reducer(13).Ta = reducer(13).T1;
reducer(13).N2 = reducer(13).Ndvig * reducer(13).etarel;
reducer(13).T2 = 9.550 * reducer(13).N2 / semimotor(13).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(13).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(13).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(13).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(13).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(13).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(13).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(13).HBg = 290;
reducer(13).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(13).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(13).HBw);

% 6.2. Определение допускаемых напряжений
reducer(13).NHO1 = 24 * 10^6;
reducer(13).NHO2 = 21 * 10^6;
reducer(13).NFO1 = 4 * 10^6;
reducer(13).NFO2 = 4 * 10^6;

reducer(13).t1 = 0.3 * reducer(13).t;
reducer(13).t2 = 0.3 * reducer(13).t;
reducer(13).t3 = 0.4 * reducer(13).t;
reducer(13).mode = [1, 0.6, 0.3];
reducer(13).tHE = 0;

for i = 1:3
    reducer(13).tHE = reducer(13).tHE + reducer(13).t1 * reducer(13).mode(i)^3;
end

reducer(13).NHE2 = abs(60 * reducer(13).nch * reducer(13).tHE);
reducer(13).NHE1 = 60 * reducer(13).nah * reducer(13).C * reducer(13).tHE;

reducer(13).KHL1 = (reducer(13).NHO1 / reducer(13).NHE1)^(1/6);
if reducer(13).KHL1 < 1
    reducer(13).KHL1 = 1;
end
reducer(13).KHL2 = (reducer(13).NHO2 / reducer(13).NHE2)^(1/6);
if reducer(13).KHL2 < 1
    reducer(13).KHL2 = 1;
end

reducer(13).KFL1 = 1;
reducer(13).KFL2 = 1;

reducer(13).sigmaHO1 = 2 * reducer(13).HBg + 70;
reducer(13).sigmaHO2 = 2 * reducer(13).HBw + 70;
reducer(13).sigmaFO1 = 1.8 * reducer(13).HBg;
reducer(13).sigmaFO2 = 1.8 * reducer(13).HBw;

reducer(13).SH1 = 1.1;
reducer(13).SH2 = 1.1;
reducer(13).SF1 = 1.75;
reducer(13).SF2 = 1.75;
reducer(13).sigmaH1 = reducer(13).sigmaHO1 / reducer(13).SH1 * reducer(13).KHL1;
reducer(13).sigmaH2 = reducer(13).sigmaHO2 / reducer(13).SH2 * reducer(13).KHL2;
reducer(13).sigmaF1 = reducer(13).sigmaFO1 / reducer(13).SF1 * reducer(13).KFL1;
reducer(13).sigmaF2 = reducer(13).sigmaFO2 / reducer(13).SF2 * reducer(13).KFL2;
reducer(13).sigmaH = min(reducer(13).sigmaH1, reducer(13).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(13).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(13).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(13).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(13).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(13).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(13).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(13).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(13).KHL1, reducer(13).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(13).KFL1, reducer(13).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(13).sigmaHO1, reducer(13).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(13).sigmaFO1, reducer(13).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(13).SH1, reducer(13).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(13).SF1, reducer(13).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(13).sigmaH1, reducer(13).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(13).sigmaF1, reducer(13).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(13).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(13).Kd = 780;
reducer(13).psibd = 0.6;
reducer(13).uHaC = (reducer(13).k - 1)/2;
reducer(13).uHcb = abs(reducer(13).nch / reducer(13).nbh);
reducer(13).Kc = 0.6;

reducer(13).Khbetta = get_Khbetta_Kfbetta(reducer(13).psibd, reducer(13).HBg, reducer(13).HBw, 'VI', 'KH');
reducer(13).Tap = reducer(13).Ta * reducer(13).Khbetta * reducer(13).Kc / reducer(13).C;
reducer(13).da = reducer(13).Kd * ((reducer(13).Tap * (reducer(13).uHaC + 1)) / ...
    (reducer(13).psibd * (reducer(13).sigmaH ^ 2) * reducer(13).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(13).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(13).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(13).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(13).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(13).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(13).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(13).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(13).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(13).za;
arrraay_of_m = zeros(1, 5);
reducer(13).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(13).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(13).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(13).m > arrraay_of_m(i)
        reducer(13).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(13).za = T2{1, the_chosen_m_ind};
reducer(13).m = T2{3, the_chosen_m_ind};
reducer(13).da = reducer(13).m * reducer(13).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(13).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(13).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(13).da);

% Параметры остальных колес
reducer(13).zb = col3(the_chosen_m_ind);
reducer(13).zc = col7(the_chosen_m_ind);
reducer(13).db = reducer(13).m * reducer(13).zb;
reducer(13).dc = reducer(13).m * reducer(13).zc;

reducer(13).bc = reducer(13).psibd * reducer(13).da;
reducer(13).ba = reducer(13).bc + 2;
reducer(13).bb = reducer(13).bc + 2;

reducer(13).V = pi * reducer(13).da * reducer(13).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(13).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(13).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(13).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(13).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(13).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(13).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(13).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(13).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(13).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(13).V);
reducer(13).aw = (reducer(13).da + reducer(13).dc) / 2;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(13).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(13).Zm = 275;
reducer(13).Zh = 1.76;
reducer(13).epsilona = 1.88 - 3.2 * (1 / reducer(13).za + 1 / reducer(13).zc);
reducer(13).Ze = sqrt((4 - reducer(13).epsilona) / 3);

[reducer(13).grade, desc] = getAccuracyGrade(reducer(13).V, 'cylindrical');
[reducer(13).Kha, reducer(13).Kfa] = get_K_Ha_K_Fa(reducer(13).V, reducer(13).grade);
[reducer(13).Khv, reducer(13).Kfv] = getDynamicCoefficients(reducer(13).V, reducer(13).grade, 'a', 'straight');
reducer(13).Khc = 1.1;

reducer(13).sigmah = reducer(13).Zm * reducer(13).Zh * reducer(13).Ze * ...
    sqrt((2 * reducer(13).Tap * reducer(13).Khbetta * reducer(13).Khv * reducer(13).Kha * ...
    (reducer(13).uHaC + 1) * 1000) / (reducer(13).bb * reducer(13).da ^ 2 * ...
    reducer(13).uHaC * reducer(13).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(13).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(13).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(13).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(13).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(13).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(13).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(13).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(13).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(13).sigmaH);

if reducer(13).sigmah <= reducer(13).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(13).Kfbetta = get_Khbetta_Kfbetta(reducer(13).psibd, reducer(13).HBg, reducer(13).HBw, 'V', 'KF');
reducer(13).YF1 = get_YF(reducer(13).za, 0);
reducer(13).YF2 = get_YF(reducer(13).zc, 0);
reducer(13).Ke = 0.92;
reducer(13).mt = reducer(13).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(13).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(13).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(13).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(13).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(13).mt);

if reducer(13).sigmaF1 / reducer(13).YF1 > reducer(13).sigmaF2 / reducer(13).YF2
    reducer(13).sigmaFC = reducer(13).YF2 * (2 * reducer(13).Tap * reducer(13).Kfbetta * ...
        reducer(13).Kfv * reducer(13).Kfa * reducer(13).Kc * 1000) / ...
        (reducer(13).C * reducer(13).Ke * reducer(13).ba * reducer(13).epsilona * ...
        reducer(13).da * reducer(13).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(13).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(13).sigmaF2);
    
    if reducer(13).sigmaFC <= reducer(13).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(13).sigmaFC = reducer(13).YF1 * (2 * reducer(13).Tap * reducer(13).Kfbetta * ...
        reducer(13).Kfv * reducer(13).Kfa * reducer(13).Kc * 1000) / ...
        (reducer(13).C * reducer(13).Ke * reducer(13).ba * reducer(13).epsilona * ...
        reducer(13).da * reducer(13).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(13).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(13).sigmaF1);
    
    if reducer(13).sigmaFC <= reducer(13).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(13).Vc = abs(pi * reducer(13).dc * reducer(13).nch / 60000);
reducer(13).epsilona_e = 1.88 - 3.2 * (1 / reducer(13).zc - 1 / reducer(13).zb);
reducer(13).Ze_e = sqrt((4 - reducer(13).epsilona_e) / 3);
reducer(13).Tb = 2 * reducer(13).T2 * reducer(13).Khbetta * reducer(13).Kc / reducer(13).C;

[reducer(13).grade_e, desc_e] = getAccuracyGrade(reducer(13).Vc, 'cylindrical');
[reducer(13).Kha_e, reducer(13).Kfa_e] = get_K_Ha_K_Fa(reducer(13).Vc, reducer(13).grade_e);
[reducer(13).Khv_e, reducer(13).Kfv_e] = getDynamicCoefficients(reducer(13).Vc, reducer(13).grade_e, 'a', 'straight');
reducer(13).uCb = reducer(13).zb / reducer(13).zc;

reducer(13).sigmah_e = reducer(13).Zm * reducer(13).Zh * reducer(13).Ze_e * ...
    sqrt((2 * reducer(13).Tb * reducer(13).Khbetta * reducer(13).Khv_e * reducer(13).Kha * ...
    reducer(13).Kc * (reducer(13).uHcb - 1) * 1000) / (reducer(13).C * reducer(13).bb * ...
    reducer(13).dc * reducer(13).db * reducer(13).uCb));

reducer(13).sigmah0_e = reducer(13).sigmah_e / reducer(13).KHL2 * reducer(13).SH2;
reducer(13).HB_e = (reducer(13).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(13).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(13).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(13).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(13).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(13).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(13).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(13).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(13).overload = 2;
reducer(13).sigmah_max = 2 * reducer(13).sigmah * sqrt(reducer(13).overload);
reducer(13).sigmaf_max = 2 * reducer(13).sigmaFC * reducer(13).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(13).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(13).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(13).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(13).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(13).sigmaHO2);

if (reducer(13).sigmah_max <= 2.8 * reducer(13).sigmaHO1) && ...
   (reducer(13).sigmaf_max <= 0.8 * reducer(13).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(13).tau = 150/2;
reducer(13).d1 = ((reducer(13).T1 * 1000) / (0.2 * reducer(13).tau)) ^ (1/3);
reducer(13).d1 = floor(reducer(13).d1);
%reducer(13).d1 = 40;
reducer(13).d2 = ((reducer(13).T2 * 1000) / (0.2 * reducer(13).tau)) ^ (1/3);
reducer(13).d2 = floor(reducer(13).d2);
reducer(13).aw = (reducer(13).da + reducer(13).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(13).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(13).T1 * 1000) / (0.2 * reducer(13).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(13).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(13).T2 * 1000) / (0.2 * reducer(13).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(13).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(13).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(13).Fa = (2 * reducer(13).T1 * 1000 * reducer(13).Kc) / (reducer(13).da * reducer(13).C);
reducer(13).Fn = 2 * reducer(13).Fa;
reducer(13).l = 15;
reducer(13).q = reducer(13).Fn / reducer(13).l;
reducer(13).M_bend = reducer(13).q * reducer(13).l ^ 2 / 8;
reducer(13).sigma_axis = 120;
reducer(13).d_axis = 0.5 * floor(2 * ((32 * reducer(13).M_bend) / (pi * reducer(13).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(13).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(13).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(13).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(13).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(13).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(13).d_axis);

%=======15.ВЫБОР_ПОДШИПНИКОВ_САТЕЛИТОВ=======

% Подшипники воспринимают только радиальную нагрузку
reducer(13).Frmax = reducer(13).Fn;
reducer(13).V_podsh = 1.2; %  коэффициент вращения кольца (вращение наружного кольца подшипника)
reducer(13).Ksigma_podsh = 1.3; % оэффициент безопасности
reducer(13).KT_podsh = 1; % 1 – температурный коэффициент в случае, когда температура деталей t = 70÷125°C
reducer(13).KN_podsh = 1; % коэффициент режима работы, учитывающий переменность нагрузки
% !!! ЧЕКНУТЬ ГОСТ
reducer(13).Pe_podsh = reducer(13).V_podsh * reducer(13).Frmax * reducer(13).Ksigma_podsh * ...
    reducer(13).KT_podsh * reducer(13).KN_podsh; % эквивалентная нагрузка на подшипник

reducer(13).Lh_podsh = 0;
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(13).Lh_podsh <= reducer(13).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "B") <= reducer(13).bc
        reducer(13).Lh_podsh = (getBearingData(ind, "C") * 1000 / reducer(13).Pe_podsh)^3 * ...
            1000000 / (60 * abs(reducer(13).nch));
        fprintf("%.d, %.3f, %.3f, %.d \n", ind, reducer(13).Lh_podsh, reducer(13).bc, reducer(13).t);
        if reducer(13).Lh_podsh >= reducer(13).t
            
            if ind <= 34                
                ind1 = ind;
                ind = 35;
            else
                ind2 = ind;
                break
            end
        end
    end
    ind = ind + 1;    
end
reducer(13).c_podsh_ind = 0;
if getBearingData(ind1, "B") < getBearingData(ind2, "B")
    reducer(13).c_podsh_ind = ind1;
else
    reducer(13).c_podsh_ind = ind2;
end

% Выбранный подшипник
fprintf(getBearingData(reducer(13).c_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(13).c_podsh_ind, "C") * 1000 /...
    reducer(13).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(13).nch)));
fprintf("Диаметр оси сателлита: %.3f\n", getBearingData(reducer(13).c_podsh_ind, "d"))

%=======16.ПРОВЕРОЧНЫЙ_РАСЧЕТ_ВАЛОВ=======

% 16.1. Расчет ведущего вала (Быстроходный вал)
% Примечание: Размеры a, b, c берутся из эскизного проекта (п. 13).
% В данном коде используем значения из примера методички для демонстрации расчета.

fprintf('\n======= 16. ПРОВЕРОЧНЫЙ РАСЧЕТ ВАЛОВ =======\n');
fprintf('16.1. Расчет ведущего вала:\n');

% Геометрические размеры участков вала (из эскиза, пример методички)
reducer(13).a_shaft = 14; % мм
reducer(13).b_shaft = 17; % мм (расстояние между опорами)
reducer(13).c_shaft = 60; % мм (консольный участок под муфту)

% Силы, действующие на вал
% FM - консольная нагрузка от муфты
reducer(13).FM = 125 * (reducer(13).Ta)^(1/2); % Н
fprintf('  Консольная нагрузка от муфты: %.2f Нм\n', reducer(13).FM);
fprintf('  Радиальная нагрузка: %.2f Нм\n', reducer(13).Fn);

% Реакции опор (схема: две опоры, консольная нагрузка)
reducer(13).Rbx = (reducer(13).Fn * (reducer(13).b_shaft + reducer(13).a_shaft) +...
    reducer(13).FM * reducer(13).c_shaft) / reducer(13).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(13).Rbx);
reducer(13).Rcx = (reducer(13).Fn * reducer(13).a_shaft  +...
    reducer(13).FM * (reducer(13).b_shaft + reducer(13).c_shaft)) / reducer(13).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(13).Rcx);

% Изгибающие моменты в опасных сечениях
reducer(13).Mbx = reducer(13).Fn * reducer(13).a_shaft * 1e-3; % Нм (в сечении B)
reducer(13).Mcx = reducer(13).FM * reducer(13).c_shaft * 1e-3; % Нм (в сечении C, от муфты)
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(13).Mbx);
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(13).Mcx);

% Выбор подшипников ведущего вала (по конструктивным соображениям и диаметру)
reducer(13).d1_verif = reducer(13).d1 + 1; % мм (диаметр в опасном сечении)
fprintf('  Диаметр вала: %.2f мм\n', reducer(13).d1_verif);
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(13).Lh_podsh <= reducer(13).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "d") == reducer(13).d1_verif
        fprintf('Подшипник: %s \n', getBearingData(ind, "code"));
        if ind <= 34                
            ind1 = ind;
            ind = 34;
        else
            ind2 = ind;
            break
        end
    end
    ind = ind + 1;    
end
reducer(13).a_podsh_ind = 0;
if getBearingData(ind1, "B") <= getBearingData(ind2, "B")
    reducer(13).a_podsh_ind = ind1;
else
    reducer(13).a_podsh_ind = ind2;
end


fprintf(getBearingData(reducer(13).a_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(13).a_podsh_ind, "C") * 1000 /...
    reducer(13).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(13).nch)));
fprintf("Диаметр оси ведущего вала: %.3f\n", getBearingData(reducer(13).a_podsh_ind, "d"))

% Геометрические характеристики сечения
reducer(13).W_shaft = (pi * reducer(13).d1_verif^3) / 32; % мм^3 (момент сопротивления изгибу)
reducer(13).Wp_shaft = (pi * reducer(13).d1_verif^3) / 16; % мм^3 (момент сопротивления кручению)

% Напряжения (амплитудные), МПа
% tau_a = T / (2 * Wp)
%Амплитуда τa и среднее τm напряжение отнулевого цикла касательных напряжений от действия крутящего момента
reducer(13).tau_a = (reducer(13).Ta * 1000) / (2 * reducer(13).Wp_shaft); % МПа
reducer(13).tau_m = reducer(13).tau_a;
% sigma_a = M / W
% Амплитуда нормальных напряжений изгиба
reducer(13).sigma_a = (reducer(13).Mbx * 1000) / reducer(13).W_shaft; % МПа

% Коэффициенты концентрации напряжений и запаса прочности (из методички для стали 40Х)
% Пределы выносливости
reducer(13).sigma_minus1 = 410; % МПа (для изгиба)
reducer(13).tau_minus1 = 240; % МПа (для кручения)

reducer(13).K_sigma_D = 4.45; 
reducer(13).K_tau_D = 3.15;

% Пределы выносливости
reducer(13).sigma_D = reducer(13).sigma_minus1 / (reducer(13).K_sigma_D);
reducer(13).tau_D = reducer(13).tau_minus1 / (reducer(13).K_tau_D);

% Запасы прочности по нормальным и касательным напряжениям
reducer(13).S_sigma = reducer(13).sigma_minus1 / (reducer(13).K_sigma_D * reducer(13).sigma_a);
reducer(13).S_tau = reducer(13).tau_minus1 / (reducer(13).K_tau_D * reducer(13).tau_a);

% Общий запас прочности
reducer(13).S_shaft1 = (reducer(13).S_sigma * reducer(13).S_tau) / sqrt(reducer(13).S_sigma^2 + reducer(13).S_tau^2);
fprintf('  Общиц запас прочности: %.2f Нм\n', reducer(13).S_shaft1);

if reducer(13).S_shaft1 >= 2.5
    fprintf('  -> Прочность ведущего вала обеспечена (S >= 2.5)\n');
else
    fprintf('  -> Прочность ведущего вала НЕ обеспечена (S < 2.5)\n');
end

% Выбор подшипников ведущего вала (пример методички №210)
% Ищем подшипник с внутренним диаметром >= d1_verif
reducer(13).bear1_code = getBearingData(reducer(13).a_podsh_ind, "code");
reducer(13).bear1_d = getBearingData(reducer(13).a_podsh_ind, "d");
reducer(13).bear1_D = getBearingData(reducer(13).a_podsh_ind, "D");
reducer(13).bear1_B = getBearingData(reducer(13).a_podsh_ind, "B");
reducer(13).bear1_C = getBearingData(reducer(13).a_podsh_ind, "C"); % кН
fprintf('  Выбран подшипник ведущего вала: %s (d=%d, D=%d, B=%d, C=%.1f кН)\n', ...
    reducer(13).bear1_code, reducer(13).bear1_d, reducer(13).bear1_D, reducer(13).bear1_B, reducer(13).bear1_C);



% ========================================================================
% 16.2. Расчет ведомого вала (Тихоходный вал / Водило)
% ========================================================================
fprintf('\n--------------------------------------------------\n');
fprintf('16.2. РАСЧЕТ ВЕДОМОГО ВАЛА (ТИХОХОДНЫЙ ВАЛ)\n');
fprintf('--------------------------------------------------\n');

% 1. Исходные данные из предыдущих расчетов
reducer(13).d2_nom = reducer(13).d2; % Диаметр выходного конца вала (из п.12), обычно ~55 мм
reducer(13).T2_val = reducer(13).T2; % Крутящий момент на ведомом валу, Н*м

% 2. Определение нагрузок
% Консольная нагрузка Fr приложена в середине шейки выходного конца вала.
% По методичке (стр. 34): Fr = (125...200) * sqrt(T2). 
% Принимаем коэффициент 200 для более жестких условий (как в примере методички).
k_consol = 200; 
reducer(13).Fr_out = k_consol * sqrt(reducer(13).T2_val); % Н

fprintf('  Крутящий момент на валу (T2):      %.2f Н*м\n', reducer(13).T2_val);
fprintf('  Консольная радиальная сила (Fr):   %.2f Н (коэфф. %d)\n', reducer(13).Fr_out, k_consol);

% 3. Геометрические параметры (из эскизного проекта)
% Расстояние от середины шейки вала (точка приложения Fr) до опасного сечения
% (место перехода диаметра или установка подшипника в водиле).
% В методичке принято c = 110 мм.
reducer(13).c_out_shaft = 25; % мм 

fprintf('  Плечо консоли (c):                 %d мм\n', reducer(13).c_out_shaft);

% 4. Расчет внутренних усилий в опасном сечении
% Изгибающий момент: Mизг = Fr * c
reducer(13).M_bend_out = reducer(13).Fr_out * reducer(13).c_out_shaft * 1e-3; % Перевод в Н*м

% Крутящий момент постоянный по длине вала
reducer(13).T_out_check = reducer(13).T2_val;

% Приведенный момент (по теории наибольших касательных напряжений):
% Mпр = sqrt(Mизг^2 + T^2)
reducer(13).M_eq_out = sqrt(reducer(13).M_bend_out^2 + reducer(13).T_out_check^2);

fprintf('  Изгибающий момент (Mизг):          %.2f Н*м\n', reducer(13).M_bend_out);
fprintf('  Приведенный момент (Mпр):          %.2f Н*м\n', reducer(13).M_eq_out);

% 5. Проверка прочности вала
% Допускаемое напряжение на изгиб [σ]изг.
% В методичке (стр. 35) для стали 40Х с учетом коэффициентов концентрации, 
% масштаба и запаса прочности (S=1.8) принято [σ] = 89 МПа.
reducer(13).sigma_allow_out = 89; % МПа

% Эквивалентное напряжение в валу: σпр = Mпр / (0.1 * d^3)
% Проверяем для диаметра, принятого в п.12 (reducer(13).d2_nom)
d_check = reducer(13).d2_nom; 
if d_check == 0
    d_check = 55; % Защита от деления на ноль, если p.12 не отработал
end

reducer(13).sigma_eq_out = (reducer(13).M_eq_out * 1000) / (0.1 * d_check^3); % МПа (момент в Н*м -> Н*мм)

fprintf('  Расчетный диаметр вала (d2):       %.1f мм\n', d_check);
fprintf('  Эквивалентное напряжение (σпр):    %.2f МПа\n', reducer(13).sigma_eq_out);
fprintf('  Допускаемое напряжение ([σ]):      %.2f МПа\n', reducer(13).sigma_allow_out);

if reducer(13).sigma_eq_out <= reducer(13).sigma_allow_out
    fprintf('  >>> ПРОЧНОСТЬ ВЕДОМОГО ВАЛА ОБЕСПЕЧЕНА <<<\n');
    reducer(13).shaft2_ok = true;
else
    fprintf('  >>> ПРОЧНОСТЬ ВЕДОМОГО ВАЛА НЕ ОБЕСПЕЧЕНА <<<\n');
    fprintf('  Требуется увеличить диаметр вала.\n');
    reducer(13).shaft2_ok = false;
    
    % Расчет требуемого диаметра (опционально)
    d_req = ((reducer(13).M_eq_out * 1000) / (0.1 * reducer(13).sigma_allow_out))^(1/3);
    fprintf('  Рекомендуемый минимальный диаметр: %.1f мм\n', d_req);
end

% 6. Выбор подшипников ведомого вала
% В планетарных редукторах ведомый вал (водило) часто имеет увеличенные посадочные места
% под подшипники внутри корпуса водила, даже если выходной конец вала тоньше.
% Однако, если вал цельный и подшипники стоят на выходных шейках, подбираем под d2.
% В методичке (стр. 36) для d2=55мм выбран подшипник с большим посадочным (d=105), 
% т.к. он стоит внутри водила. 
% Здесь реализуем универсальный поиск: ищем подшипник под диаметр d2 (или чуть больше, если это посадка в водило).

fprintf('\n  Подбор подшипников ведомого вала:\n');

% Для примера будем искать подшипник под диаметр d2_nom (если это выходная опора)
% Или можно задать фиктивный диаметр посадки в водиле, если он известен из эскиза.
% Пусть пока ищем под диаметр вала d2_nom, но с запасом по грузоподъемности.
target_d = reducer(13).d2_nom; 

% Если диаметр маленький (например, < 30), а момент большой, возможно потребуется серия тяжелее.
% Используем ту же функцию поиска, что и в п. 15 и 16.1
reducer(13).Lh_podsh2 = 0;
ind = 1;
ind1 = 1; % Индекс легкой серии
ind2 = 35; % Индекс средней серии (начало второй части массива bearings)

% Перебор базы подшипников
while ind < 57 % Предполагаем, что в базе 57 записей (настройте под вашу функцию getBearingData)
    if ind == 58
        break;
    end
    
    % Ищем подшипник, внутренний диаметр которого >= target_d
    % В реальном проекте тут может быть условие: d_podsh >= d_waterilo (который > d2)
    if getBearingData(ind, "d") >= target_d
        
        % Расчет долговечности
        % Нагрузка на подшипники ведомого вала складывается из реакции от Fr и веса водила.
        % Упрощенно примем радиальную нагрузку равной Fr (консервативно) или реакции опор.
        % В методичке сказано, что нагрузки незначительны, выбор по конструктивным соображениям.
        % Но проверим долговечность от Fr, распределенной на 2 опоры (примерно Fr/2 на опору, но с плечами)
        % Для простоты примем Radial Load = Fr_out (худший случай - вся нагрузка на одну опору при пуске)
        Fr_bear = reducer(13).Fr_out; 
        
        Pe2 = 1.2 * Fr_bear * 1.3; % V=1.2 (кольцо вращается?), Ksigma=1.3. Уточните V для водила.
        % Для водила наружное кольцо подшипника вращается вместе с водилом относительно нагрузки? 
        % Нет, нагрузка от корпуса неподвижна, водило вращается -> вращается внутреннее кольцо (если оно на валу)
        % В планетарке водило - это вал. Подшипник стоит в корпусе. 
        %-> Вращается внутреннее кольцо (посажен на водило). Значит V=1.
        
        Pe2 = 1.0 * Fr_bear * 1.3; % V=1, Ksigma=1.3
        
        C_val = getBearingData(ind, "C") * 1000; % Перевод кН в Н
        
        % Обороты ведомого вала
        n_out = semimotor(13).nreq; 
        
        if n_out > 0
            Lh_temp = (C_val / Pe2)^3 * 1000000 / (60 * n_out);
        else
            Lh_temp = 0;
        end
        
        if Lh_temp >= reducer(13).t
            if ind <= 34                
                ind1 = ind; % Запоминаем последний подходящий из легкой
            else
                ind2 = ind; % Запоминаем первый подходящий из средней (или тяжелой)
                break; % Нашли подходящий в средней серии, дальше нет смысла (будут громоздкие)
            end
        end
    end
    ind = ind + 1;    
end

% Выбор окончательного индекса (предпочитаем компактный, если проходит, иначе надежный)
% Логика: если легкий подходит по габаритам (ширина B) и влезает в конструкцию - берем его.
% Но для тихоходного вала с большим моментом часто сразу берут среднюю серию.
% Возьмем тот, у которого больше ресурс, но разумный габарит.
if reducer(13).Lh_podsh2 == 0 % Если цикл не заполнил переменную глобально, посчитаем для выбранных
     % Просто выберем ind2 (средняя серия) как более надежный для выходного вала, 
     % если он был найден, иначе ind1.
     if ind2 > 34 
         reducer(13).b_podsh_ind = ind2;
     else
         reducer(13).b_podsh_ind = ind1;
     end
else
     reducer(13).b_podsh_ind = ind2; % По умолчанию берем среднюю серию для надежности
end

% Вывод результатов по подшипнику
bear_code = getBearingData(reducer(13).b_podsh_ind, "code");
bear_d = getBearingData(reducer(13).b_podsh_ind, "d");
bear_D = getBearingData(reducer(13).b_podsh_ind, "D");
bear_B = getBearingData(reducer(13).b_podsh_ind, "B");
bear_C = getBearingData(reducer(13).b_podsh_ind, "C");

% Пересчет точной долговечности для выбранного
C_sel = bear_C * 1000;
Pe_sel = 1.0 * reducer(13).Fr_out * 1.3;
n_out = semimotor(11).nreq;
Lh_final = (C_sel / Pe_sel)^3 * 1000000 / (60 * n_out);

fprintf('  Выбран подшипник: %s\n', bear_code);
fprintf('  Размеры (d x D x B): %d x %d x %d мм\n', bear_d, bear_D, bear_B);
fprintf('  Динамическая грузоподъемность (C): %.1f кН\n', bear_C);
fprintf('  Расчетная долговечность (Lh): %.0f часов (требуется %d)\n', Lh_final, reducer(13).t);

if Lh_final >= reducer(13).t
    fprintf('  >>> ДОЛГОВЕЧНОСТЬ ПОДШИПНИКОВ ВЕДОМОГО ВАЛА ОБЕСПЕЧЕНА <<<\n');
else
    fprintf('  >>> ВНИМАНИЕ: Долговечность ниже требуемой. Рассмотрите подшипник большей серии. <<<\n');
end


fprintf('\n======= КОНЕЦ РАСЧЕТА ВАЛОВ =======\n');


% ======= ИТОГОВАЯ СВОДКА =======
fprintf('================================================================================\n');
fprintf('                           ИТОГОВАЯ СВОДКА ПАРАМЕТРОВ                          \n');
fprintf('================================================================================\n\n');

fprintf('Основные параметры редуктора:\n');
fprintf('  ┌─────────────────────────────────────────────────────────────────────────┐\n');
fprintf('  │ Параметр                          │ Значение          │ Ед. изм.      │\n');
fprintf('  ├─────────────────────────────────────────────────────────────────────────┤\n');
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(13).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(13).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(13).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(13).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(13).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(13).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(13).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(13).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(13).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(13).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(13).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(13).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(13).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(13).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(13).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(13).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(13).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(13).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(13).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(13).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(13).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(13).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(13).d_axis);
fprintf('  └─────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');



fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(12).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(12).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(12).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(12).u = reducer(13).u;
reducer(12).k = reducer(13).k;
reducer(12).C = 3;
reducer(12).t = reducer(13).t;
reducer(12).na = semimotor(12).nmot;
reducer(12).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(12).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(12).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(12).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(12).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(12).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(12).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(12).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(12).k);
    if mod(zb1 + za, 2) == 0
        zb = zb1;
    else
        zb = zb2;
    end
    col3(i) = zb;
    col4(i) = zb/za;
    col5(i) = 1 + zb/za;
    col6(i) = (zb + za)/2;
    col7(i) = (zb - za)/2;
    za = za + 3;
end

T = table(col1, col2, col3, col4, col5, col6, col7, 'VariableNames', ...
    {'za', 'zb_za_k', 'zb_kratno_C', 'k_star', 'u_calc', 'gamma', 'zc'});

fprintf('4.2. Варианты подбора числа зубьев колес:\n');
disp(T);

% 4.3. Определение относительной частоты вращения колес
reducer(12).nah = semimotor(12).nmot - semimotor(12).nreq;
reducer(12).nbh = 0 - semimotor(12).nreq;
reducer(12).nch = -(semimotor(12).nmot - semimotor(12).nreq) * 2 / (reducer(12).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(12).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(12).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(12).nch);

% 4.4. Определение КПД редуктора
reducer(12).etarel = (1 + reducer(12).k * 0.99 * 0.97) / (1 + reducer(12).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(13).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(12).etamuf = 0.99;
reducer(12).eta = reducer(12).etarel * reducer(12).etamuf;
reducer(12).Ndvig = semimotor(12).N / reducer(12).eta;
reducer(12).N1 = reducer(12).Ndvig * reducer(12).etamuf;
reducer(12).T1 = 9.550 * reducer(12).N1 / semimotor(12).nmot;
reducer(12).Ta = reducer(12).T1;
reducer(12).N2 = reducer(12).Ndvig * reducer(12).etarel;
reducer(12).T2 = 9.550 * reducer(12).N2 / semimotor(12).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(12).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(12).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(12).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(12).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(12).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(12).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(12).HBg = 290;
reducer(12).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(12).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(12).HBw);

% 6.2. Определение допускаемых напряжений
reducer(12).NHO1 = 24 * 10^6;
reducer(12).NHO2 = 21 * 10^6;
reducer(12).NFO1 = 4 * 10^6;
reducer(12).NFO2 = 4 * 10^6;

reducer(12).t1 = 0.3 * reducer(13).t;
reducer(12).t2 = 0.3 * reducer(13).t;
reducer(12).t3 = 0.4 * reducer(13).t;
reducer(12).mode = [1, 0.6, 0.3];
reducer(12).tHE = 0;

for i = 1:3
    reducer(12).tHE = reducer(12).tHE + reducer(12).t1 * reducer(12).mode(i)^3;
end

reducer(12).NHE2 = abs(60 * reducer(12).nch * reducer(12).tHE);
reducer(12).NHE1 = 60 * reducer(12).nah * reducer(12).C * reducer(12).tHE;

reducer(12).KHL1 = (reducer(12).NHO1 / reducer(12).NHE1)^(1/6);
if reducer(12).KHL1 < 1
    reducer(12).KHL1 = 1;
end
reducer(12).KHL2 = (reducer(12).NHO2 / reducer(12).NHE2)^(1/6);
if reducer(12).KHL2 < 1
    reducer(12).KHL2 = 1;
end

reducer(12).KFL1 = 1;
reducer(12).KFL2 = 1;

reducer(12).sigmaHO1 = 2 * reducer(12).HBg + 70;
reducer(12).sigmaHO2 = 2 * reducer(12).HBw + 70;
reducer(12).sigmaFO1 = 1.8 * reducer(12).HBg;
reducer(12).sigmaFO2 = 1.8 * reducer(12).HBw;

reducer(12).SH1 = 1.1;
reducer(12).SH2 = 1.1;
reducer(12).SF1 = 1.75;
reducer(12).SF2 = 1.75;
reducer(12).sigmaH1 = reducer(12).sigmaHO1 / reducer(12).SH1 * reducer(12).KHL1;
reducer(12).sigmaH2 = reducer(12).sigmaHO2 / reducer(12).SH2 * reducer(12).KHL2;
reducer(12).sigmaF1 = reducer(12).sigmaFO1 / reducer(12).SF1 * reducer(12).KFL1;
reducer(12).sigmaF2 = reducer(12).sigmaFO2 / reducer(12).SF2 * reducer(12).KFL2;
reducer(12).sigmaH = min(reducer(12).sigmaH1, reducer(12).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(12).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(12).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(12).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(12).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(12).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(12).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(12).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(12).KHL1, reducer(12).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(12).KFL1, reducer(12).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(12).sigmaHO1, reducer(12).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(12).sigmaFO1, reducer(12).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(12).SH1, reducer(12).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(12).SF1, reducer(12).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(12).sigmaH1, reducer(12).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(12).sigmaF1, reducer(12).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(12).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(12).Kd = 780;
reducer(12).psibd = reducer(13).psibd;
reducer(12).uHaC = (reducer(13).k - 1)/2;
reducer(12).uHcb = abs(reducer(12).nch / reducer(12).nbh);
reducer(12).Kc = 1.1;

reducer(12).Khbetta = get_Khbetta_Kfbetta(reducer(13).psibd, reducer(13).HBg, reducer(13).HBw, 'VI', 'KH');
reducer(12).Tap = reducer(13).Ta * reducer(13).Khbetta * reducer(13).Kc / reducer(13).C;
reducer(12).da = reducer(13).da;

fprintf('7.1. Предварительные параметры:\n');
%fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(12).Kd);
%fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(12).psibd);
%fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(12).uHaC);
%fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(12).uHcb);
%fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(12).Kc);
%fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(12).Khbetta);
%fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(12).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(12).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(12).za;
arrraay_of_m = zeros(1, 5);
reducer(12).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(12).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(12).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(12).m > arrraay_of_m(i)
        reducer(12).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(12).za = reducer(13).za;
reducer(12).m = reducer(13).m;
reducer(12).da = reducer(13).da;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
%disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(13).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(13).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(13).da);

% Параметры остальных колес
reducer(12).zb = reducer(13).zb;
reducer(12).zc = reducer(13).zc;
reducer(12).db = reducer(12).m * reducer(12).zb;
reducer(12).dc = reducer(12).m * reducer(12).zc;

reducer(12).bc = reducer(12).psibd * reducer(12).da;
reducer(12).ba = reducer(12).bc + 2;
reducer(12).bb = reducer(12).bc + 2;

reducer(12).V = pi * reducer(12).da * reducer(12).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(12).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(12).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(12).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(12).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(12).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(12).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(12).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(12).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(12).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(12).V);
reducer(12).aw = reducer(13).aw;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(12).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(12).Zm = 275;
reducer(12).Zh = 1.76;
reducer(12).epsilona = 1.88 - 3.2 * (1 / reducer(12).za + 1 / reducer(12).zc);
reducer(12).Ze = sqrt((4 - reducer(12).epsilona) / 3);

[reducer(12).grade, desc] = getAccuracyGrade(reducer(12).V, 'cylindrical');
[reducer(12).Kha, reducer(12).Kfa] = get_K_Ha_K_Fa(reducer(12).V, reducer(12).grade);
[reducer(12).Khv, reducer(12).Kfv] = getDynamicCoefficients(reducer(12).V, reducer(12).grade, 'a', 'straight');
reducer(12).Khc = 1.1;

reducer(12).sigmah = reducer(12).Zm * reducer(12).Zh * reducer(12).Ze * ...
    sqrt((2 * reducer(12).Tap * reducer(12).Khbetta * reducer(12).Khv * reducer(12).Kha * ...
    (reducer(12).uHaC + 1) * 1000) / (reducer(12).bb * reducer(12).da ^ 2 * ...
    reducer(12).uHaC * reducer(12).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(12).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(12).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(12).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(12).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(12).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(12).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(12).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(12).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(12).sigmaH);

if reducer(12).sigmah <= reducer(12).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(12).Kfbetta = get_Khbetta_Kfbetta(reducer(12).psibd, reducer(12).HBg, reducer(12).HBw, 'V', 'KF');
reducer(12).YF1 = get_YF(reducer(12).za, 0);
reducer(12).YF2 = get_YF(reducer(12).zc, 0);
reducer(12).Ke = 0.92;
reducer(12).mt = reducer(12).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(12).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(12).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(12).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(12).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(12).mt);

if reducer(12).sigmaF1 / reducer(12).YF1 > reducer(12).sigmaF2 / reducer(12).YF2
    reducer(12).sigmaFC = reducer(12).YF2 * (2 * reducer(12).Tap * reducer(12).Kfbetta * ...
        reducer(12).Kfv * reducer(12).Kfa * reducer(12).Kc * 1000) / ...
        (reducer(12).C * reducer(12).Ke * reducer(12).ba * reducer(12).epsilona * ...
        reducer(12).da * reducer(12).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(12).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(12).sigmaF2);
    
    if reducer(12).sigmaFC <= reducer(12).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(12).sigmaFC = reducer(12).YF1 * (2 * reducer(12).Tap * reducer(12).Kfbetta * ...
        reducer(12).Kfv * reducer(12).Kfa * reducer(12).Kc * 1000) / ...
        (reducer(12).C * reducer(12).Ke * reducer(12).ba * reducer(12).epsilona * ...
        reducer(12).da * reducer(12).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(12).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(12).sigmaF1);
    
    if reducer(12).sigmaFC <= reducer(12).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(12).Vc = abs(pi * reducer(12).dc * reducer(12).nch / 60000);
reducer(12).epsilona_e = 1.88 - 3.2 * (1 / reducer(12).zc - 1 / reducer(12).zb);
reducer(12).Ze_e = sqrt((4 - reducer(12).epsilona_e) / 3);
reducer(12).Tb = 2 * reducer(12).T2 * reducer(12).Khbetta * reducer(12).Kc / reducer(12).C;

[reducer(12).grade_e, desc_e] = getAccuracyGrade(reducer(12).Vc, 'cylindrical');
[reducer(12).Kha_e, reducer(12).Kfa_e] = get_K_Ha_K_Fa(reducer(12).Vc, reducer(12).grade_e);
[reducer(12).Khv_e, reducer(12).Kfv_e] = getDynamicCoefficients(reducer(12).Vc, reducer(12).grade_e, 'a', 'straight');
reducer(12).uCb = reducer(12).zb / reducer(12).zc;

reducer(12).sigmah_e = reducer(12).Zm * reducer(12).Zh * reducer(12).Ze_e * ...
    sqrt((2 * reducer(12).Tb * reducer(12).Khbetta * reducer(12).Khv_e * reducer(12).Kha * ...
    reducer(12).Kc * (reducer(12).uHcb - 1) * 1000) / (reducer(12).C * reducer(12).bb * ...
    reducer(12).dc * reducer(12).db * reducer(12).uCb));

reducer(12).sigmah0_e = reducer(12).sigmah_e / reducer(12).KHL2 * reducer(12).SH2;
reducer(12).HB_e = (reducer(12).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(12).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(12).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(12).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(12).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(12).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(12).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(12).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(12).overload = 2;
reducer(12).sigmah_max = 2 * reducer(12).sigmah * sqrt(reducer(12).overload);
reducer(12).sigmaf_max = 2 * reducer(12).sigmaFC * reducer(12).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(12).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(12).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(12).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(12).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(12).sigmaHO2);

if (reducer(12).sigmah_max <= 2.8 * reducer(12).sigmaHO1) && ...
   (reducer(12).sigmaf_max <= 0.8 * reducer(12).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(12).tau = 15;
reducer(12).d1 = ((reducer(12).T1 * 1000) / (0.2 * reducer(12).tau)) ^ (1/3);
reducer(12).d1 = floor(reducer(12).d1);
%reducer(12).d1 = 40;
reducer(12).d2 = ((reducer(12).T2 * 1000) / (0.2 * reducer(12).tau)) ^ (1/3);
reducer(12).d2 = floor(reducer(12).d2);
reducer(12).aw = (reducer(12).da + reducer(12).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(12).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(12).T1 * 1000) / (0.2 * reducer(12).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(12).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(12).T2 * 1000) / (0.2 * reducer(12).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(12).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(12).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(12).Fa = (2 * reducer(12).T1 * 1000 * reducer(12).Kc) / (reducer(12).da * reducer(12).C);
reducer(12).Fn = 2 * reducer(12).Fa;
reducer(12).l = 15;
reducer(12).q = reducer(12).Fn / reducer(12).l;
reducer(12).M_bend = reducer(12).q * reducer(12).l ^ 2 / 8;
reducer(12).sigma_axis = 120;
reducer(12).d_axis = 0.5 * floor(2 * ((32 * reducer(12).M_bend) / (pi * reducer(12).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(12).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(12).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(12).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(12).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(12).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(12).d_axis);

% ======= ИТОГОВАЯ СВОДКА =======
fprintf('================================================================================\n');
fprintf('                           ИТОГОВАЯ СВОДКА ПАРАМЕТРОВ                          \n');
fprintf('================================================================================\n\n');

fprintf('Основные параметры редуктора:\n');
fprintf('  ┌─────────────────────────────────────────────────────────────────────────┐\n');
fprintf('  │ Параметр                          │ Значение          │ Ед. изм.      │\n');
fprintf('  ├─────────────────────────────────────────────────────────────────────────┤\n');
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(12).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(12).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(12).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(12).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(12).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(12).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(12).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(12).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(12).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(12).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(12).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(12).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(12).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(12).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(12).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(12).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(12).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(12).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(12).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(12).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(12).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(12).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(12).d_axis);
fprintf('  └─────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');



fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(11).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(11).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(11).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(11).u = reducer(13).u;
reducer(11).k = reducer(13).k;
reducer(11).C = 3;
reducer(11).t = reducer(13).t;
reducer(11).na = semimotor(11).nmot;
reducer(11).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(11).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(11).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(11).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(11).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(11).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(11).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(11).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(11).k);
    if mod(zb1 + za, 2) == 0
        zb = zb1;
    else
        zb = zb2;
    end
    col3(i) = zb;
    col4(i) = zb/za;
    col5(i) = 1 + zb/za;
    col6(i) = (zb + za)/2;
    col7(i) = (zb - za)/2;
    za = za + 3;
end

T = table(col1, col2, col3, col4, col5, col6, col7, 'VariableNames', ...
    {'za', 'zb_za_k', 'zb_kratno_C', 'k_star', 'u_calc', 'gamma', 'zc'});

fprintf('4.2. Варианты подбора числа зубьев колес:\n');
disp(T);

% 4.3. Определение относительной частоты вращения колес
reducer(11).nah = semimotor(11).nmot - semimotor(11).nreq;
reducer(11).nbh = 0 - semimotor(11).nreq;
reducer(11).nch = -(semimotor(11).nmot - semimotor(11).nreq) * 2 / (reducer(11).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(11).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(11).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(11).nch);

% 4.4. Определение КПД редуктора
reducer(11).etarel = (1 + reducer(11).k * 0.99 * 0.97) / (1 + reducer(11).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(13).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(11).etamuf = 0.99;
reducer(11).eta = reducer(11).etarel * reducer(11).etamuf;
reducer(11).Ndvig = semimotor(11).N / reducer(11).eta;
reducer(11).N1 = reducer(11).Ndvig * reducer(11).etamuf;
reducer(11).T1 = 9.550 * reducer(11).N1 / semimotor(11).nmot;
reducer(11).Ta = reducer(11).T1;
reducer(11).N2 = reducer(11).Ndvig * reducer(11).etarel;
reducer(11).T2 = 9.550 * reducer(11).N2 / semimotor(11).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(11).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(11).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(11).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(11).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(11).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(11).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(11).HBg = 290;
reducer(11).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(11).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(11).HBw);

% 6.2. Определение допускаемых напряжений
reducer(11).NHO1 = 24 * 10^6;
reducer(11).NHO2 = 21 * 10^6;
reducer(11).NFO1 = 4 * 10^6;
reducer(11).NFO2 = 4 * 10^6;

reducer(11).t1 = 0.3 * reducer(13).t;
reducer(11).t2 = 0.3 * reducer(13).t;
reducer(11).t3 = 0.4 * reducer(13).t;
reducer(11).mode = [1, 0.6, 0.3];
reducer(11).tHE = 0;

for i = 1:3
    reducer(11).tHE = reducer(11).tHE + reducer(11).t1 * reducer(11).mode(i)^3;
end

reducer(11).NHE2 = abs(60 * reducer(11).nch * reducer(11).tHE);
reducer(11).NHE1 = 60 * reducer(11).nah * reducer(11).C * reducer(11).tHE;

reducer(11).KHL1 = (reducer(11).NHO1 / reducer(11).NHE1)^(1/6);
if reducer(11).KHL1 < 1
    reducer(11).KHL1 = 1;
end
reducer(11).KHL2 = (reducer(11).NHO2 / reducer(11).NHE2)^(1/6);
if reducer(11).KHL2 < 1
    reducer(11).KHL2 = 1;
end

reducer(11).KFL1 = 1;
reducer(11).KFL2 = 1;

reducer(11).sigmaHO1 = 2 * reducer(11).HBg + 70;
reducer(11).sigmaHO2 = 2 * reducer(11).HBw + 70;
reducer(11).sigmaFO1 = 1.8 * reducer(11).HBg;
reducer(11).sigmaFO2 = 1.8 * reducer(11).HBw;

reducer(11).SH1 = 1.1;
reducer(11).SH2 = 1.1;
reducer(11).SF1 = 1.75;
reducer(11).SF2 = 1.75;
reducer(11).sigmaH1 = reducer(11).sigmaHO1 / reducer(11).SH1 * reducer(11).KHL1;
reducer(11).sigmaH2 = reducer(11).sigmaHO2 / reducer(11).SH2 * reducer(11).KHL2;
reducer(11).sigmaF1 = reducer(11).sigmaFO1 / reducer(11).SF1 * reducer(11).KFL1;
reducer(11).sigmaF2 = reducer(11).sigmaFO2 / reducer(11).SF2 * reducer(11).KFL2;
reducer(11).sigmaH = min(reducer(11).sigmaH1, reducer(11).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(11).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(11).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(11).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(11).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(11).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(11).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(11).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(11).KHL1, reducer(11).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(11).KFL1, reducer(11).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(11).sigmaHO1, reducer(11).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(11).sigmaFO1, reducer(11).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(11).SH1, reducer(11).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(11).SF1, reducer(11).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(11).sigmaH1, reducer(11).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(11).sigmaF1, reducer(11).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(11).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(11).Kd = 780;
reducer(11).psibd = reducer(13).psibd;
reducer(11).uHaC = (reducer(13).k - 1)/2;
reducer(11).uHcb = abs(reducer(11).nch / reducer(11).nbh);
reducer(11).Kc = 1.1;

reducer(11).Khbetta = get_Khbetta_Kfbetta(reducer(13).psibd, reducer(13).HBg, reducer(13).HBw, 'VI', 'KH');
reducer(11).Tap = reducer(13).Ta * reducer(13).Khbetta * reducer(13).Kc / reducer(13).C;
reducer(11).da = reducer(13).da;

fprintf('7.1. Предварительные параметры:\n');
%fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(11).Kd);
%fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(11).psibd);
%fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(11).uHaC);
%fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(11).uHcb);
%fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(11).Kc);
%fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(11).Khbetta);
%fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(11).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(11).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(11).za;
arrraay_of_m = zeros(1, 5);
reducer(11).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(11).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(11).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(11).m > arrraay_of_m(i)
        reducer(11).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(11).za = reducer(13).za;
reducer(11).m = reducer(13).m;
reducer(11).da = reducer(13).da;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
%disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(13).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(13).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(13).da);

% Параметры остальных колес
reducer(11).zb = reducer(13).zb;
reducer(11).zc = reducer(13).zc;
reducer(11).db = reducer(11).m * reducer(11).zb;
reducer(11).dc = reducer(11).m * reducer(11).zc;

reducer(11).bc = reducer(11).psibd * reducer(11).da;
reducer(11).ba = reducer(11).bc + 2;
reducer(11).bb = reducer(11).bc + 2;

reducer(11).V = pi * reducer(11).da * reducer(11).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(11).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(11).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(11).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(11).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(11).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(11).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(11).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(11).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(11).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(11).V);
reducer(11).aw = reducer(13).aw;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(11).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(11).Zm = 275;
reducer(11).Zh = 1.76;
reducer(11).epsilona = 1.88 - 3.2 * (1 / reducer(11).za + 1 / reducer(11).zc);
reducer(11).Ze = sqrt((4 - reducer(11).epsilona) / 3);

[reducer(11).grade, desc] = getAccuracyGrade(reducer(11).V, 'cylindrical');
[reducer(11).Kha, reducer(11).Kfa] = get_K_Ha_K_Fa(reducer(11).V, reducer(11).grade);
[reducer(11).Khv, reducer(11).Kfv] = getDynamicCoefficients(reducer(11).V, reducer(11).grade, 'a', 'straight');
reducer(11).Khc = 1.1;

reducer(11).sigmah = reducer(11).Zm * reducer(11).Zh * reducer(11).Ze * ...
    sqrt((2 * reducer(11).Tap * reducer(11).Khbetta * reducer(11).Khv * reducer(11).Kha * ...
    (reducer(11).uHaC + 1) * 1000) / (reducer(11).bb * reducer(11).da ^ 2 * ...
    reducer(11).uHaC * reducer(11).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(11).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(11).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(11).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(11).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(11).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(11).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(11).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(11).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(11).sigmaH);

if reducer(11).sigmah <= reducer(11).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(11).Kfbetta = get_Khbetta_Kfbetta(reducer(11).psibd, reducer(11).HBg, reducer(11).HBw, 'V', 'KF');
reducer(11).YF1 = get_YF(reducer(11).za, 0);
reducer(11).YF2 = get_YF(reducer(11).zc, 0);
reducer(11).Ke = 0.92;
reducer(11).mt = reducer(11).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(11).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(11).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(11).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(11).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(11).mt);

if reducer(11).sigmaF1 / reducer(11).YF1 > reducer(11).sigmaF2 / reducer(11).YF2
    reducer(11).sigmaFC = reducer(11).YF2 * (2 * reducer(11).Tap * reducer(11).Kfbetta * ...
        reducer(11).Kfv * reducer(11).Kfa * reducer(11).Kc * 1000) / ...
        (reducer(11).C * reducer(11).Ke * reducer(11).ba * reducer(11).epsilona * ...
        reducer(11).da * reducer(11).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(11).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(11).sigmaF2);
    
    if reducer(11).sigmaFC <= reducer(11).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(11).sigmaFC = reducer(11).YF1 * (2 * reducer(11).Tap * reducer(11).Kfbetta * ...
        reducer(11).Kfv * reducer(11).Kfa * reducer(11).Kc * 1000) / ...
        (reducer(11).C * reducer(11).Ke * reducer(11).ba * reducer(11).epsilona * ...
        reducer(11).da * reducer(11).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(11).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(11).sigmaF1);
    
    if reducer(11).sigmaFC <= reducer(11).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(11).Vc = abs(pi * reducer(11).dc * reducer(11).nch / 60000);
reducer(11).epsilona_e = 1.88 - 3.2 * (1 / reducer(11).zc - 1 / reducer(11).zb);
reducer(11).Ze_e = sqrt((4 - reducer(11).epsilona_e) / 3);
reducer(11).Tb = 2 * reducer(11).T2 * reducer(11).Khbetta * reducer(11).Kc / reducer(11).C;

[reducer(11).grade_e, desc_e] = getAccuracyGrade(reducer(11).Vc, 'cylindrical');
[reducer(11).Kha_e, reducer(11).Kfa_e] = get_K_Ha_K_Fa(reducer(11).Vc, reducer(11).grade_e);
[reducer(11).Khv_e, reducer(11).Kfv_e] = getDynamicCoefficients(reducer(11).Vc, reducer(11).grade_e, 'a', 'straight');
reducer(11).uCb = reducer(11).zb / reducer(11).zc;

reducer(11).sigmah_e = reducer(11).Zm * reducer(11).Zh * reducer(11).Ze_e * ...
    sqrt((2 * reducer(11).Tb * reducer(11).Khbetta * reducer(11).Khv_e * reducer(11).Kha * ...
    reducer(11).Kc * (reducer(11).uHcb - 1) * 1000) / (reducer(11).C * reducer(11).bb * ...
    reducer(11).dc * reducer(11).db * reducer(11).uCb));

reducer(11).sigmah0_e = reducer(11).sigmah_e / reducer(11).KHL2 * reducer(11).SH2;
reducer(11).HB_e = (reducer(11).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(11).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(11).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(11).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(11).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(11).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(11).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(11).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(11).overload = 2;
reducer(11).sigmah_max = 2 * reducer(11).sigmah * sqrt(reducer(11).overload);
reducer(11).sigmaf_max = 2 * reducer(11).sigmaFC * reducer(11).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(11).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(11).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(11).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(11).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(11).sigmaHO2);

if (reducer(11).sigmah_max <= 2.8 * reducer(11).sigmaHO1) && ...
   (reducer(11).sigmaf_max <= 0.8 * reducer(11).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(11).tau = 15;
reducer(11).d1 = ((reducer(11).T1 * 1000) / (0.2 * reducer(11).tau)) ^ (1/3);
reducer(11).d1 = floor(reducer(11).d1);
%reducer(11).d1 = 40;
reducer(11).d2 = ((reducer(11).T2 * 1000) / (0.2 * reducer(11).tau)) ^ (1/3);
reducer(11).d2 = floor(reducer(11).d2);
reducer(11).aw = (reducer(11).da + reducer(11).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(11).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(11).T1 * 1000) / (0.2 * reducer(11).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(11).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(11).T2 * 1000) / (0.2 * reducer(11).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(11).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(11).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(11).Fa = (2 * reducer(11).T1 * 1000 * reducer(11).Kc) / (reducer(11).da * reducer(11).C);
reducer(11).Fn = 2 * reducer(11).Fa;
reducer(11).l = 15;
reducer(11).q = reducer(11).Fn / reducer(11).l;
reducer(11).M_bend = reducer(11).q * reducer(11).l ^ 2 / 8;
reducer(11).sigma_axis = 120;
reducer(11).d_axis = 0.5 * floor(2 * ((32 * reducer(11).M_bend) / (pi * reducer(11).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(11).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(11).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(11).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(11).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(11).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(11).d_axis);

%=======15.ВЫБОР_ПОДШИПНИКОВ_САТЕЛИТОВ=======

% Подшипники воспринимают только радиальную нагрузку
reducer(11).Frmax = reducer(11).Fn;
reducer(11).V_podsh = 1.2; %  коэффициент вращения кольца (вращение наружного кольца подшипника)
reducer(11).Ksigma_podsh = 1.3; % оэффициент безопасности
reducer(11).KT_podsh = 1; % 1 – температурный коэффициент в случае, когда температура деталей t = 70÷125°C
reducer(11).KN_podsh = 1; % коэффициент режима работы, учитывающий переменность нагрузки
% !!! ЧЕКНУТЬ ГОСТ
reducer(11).Pe_podsh = reducer(11).V_podsh * reducer(11).Frmax * reducer(11).Ksigma_podsh * ...
    reducer(11).KT_podsh * reducer(11).KN_podsh; % эквивалентная нагрузка на подшипник

reducer(11).Lh_podsh = 0;
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(11).Lh_podsh <= reducer(11).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "B") <= reducer(11).bc
        reducer(11).Lh_podsh = (getBearingData(ind, "C") * 1000 / reducer(11).Pe_podsh)^3 * ...
            1000000 / (60 * abs(reducer(11).nch));
        fprintf("%.d, %.3f, %.3f, %.d \n", ind, reducer(11).Lh_podsh, reducer(11).bc, reducer(11).t);
        if reducer(11).Lh_podsh >= reducer(11).t
            
            if ind <= 34                
                ind1 = ind;
                ind = 35;
            else
                ind2 = ind;
                break
            end
        end
    end
    ind = ind + 1;    
end
reducer(11).c_podsh_ind = 0;
if getBearingData(ind1, "B") < getBearingData(ind2, "B")
    reducer(11).c_podsh_ind = ind1;
else
    reducer(11).c_podsh_ind = ind2;
end

% Выбранный подшипник
fprintf(getBearingData(reducer(11).c_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(11).c_podsh_ind, "C") * 1000 /...
    reducer(11).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(11).nch)));
fprintf("Диаметр оси сателлита: %.3f\n", getBearingData(reducer(11).c_podsh_ind, "d"))

%=======16.ПРОВЕРОЧНЫЙ_РАСЧЕТ_ВАЛОВ=======

% 16.1. Расчет ведущего вала (Быстроходный вал)
% Примечание: Размеры a, b, c берутся из эскизного проекта (п. 13).
% В данном коде используем значения из примера методички для демонстрации расчета.

fprintf('\n======= 16. ПРОВЕРОЧНЫЙ РАСЧЕТ ВАЛОВ =======\n');
fprintf('16.1. Расчет ведущего вала:\n');

% Геометрические размеры участков вала (из эскиза, пример методички)
reducer(11).a_shaft = 14; % мм
reducer(11).b_shaft = 17; % мм (расстояние между опорами)
reducer(11).c_shaft = 60; % мм (консольный участок под муфту)

% Силы, действующие на вал
% FM - консольная нагрузка от муфты
reducer(11).FM = 125 * (reducer(11).Ta)^(1/2); % Н
fprintf('  Консольная нагрузка от муфты: %.2f Нм\n', reducer(11).FM);
fprintf('  Радиальная нагрузка: %.2f Нм\n', reducer(11).Fn);

% Реакции опор (схема: две опоры, консольная нагрузка)
reducer(11).Rbx = (reducer(11).Fn * (reducer(11).b_shaft + reducer(11).a_shaft) +...
    reducer(11).FM * reducer(11).c_shaft) / reducer(11).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(11).Rbx);
reducer(11).Rcx = (reducer(11).Fn * reducer(11).a_shaft  +...
    reducer(11).FM * (reducer(11).b_shaft + reducer(11).c_shaft)) / reducer(11).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(11).Rcx);

% Изгибающие моменты в опасных сечениях
reducer(11).Mbx = reducer(11).Fn * reducer(11).a_shaft * 1e-3; % Нм (в сечении B)
reducer(11).Mcx = reducer(11).FM * reducer(11).c_shaft * 1e-3; % Нм (в сечении C, от муфты)
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(11).Mbx);
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(11).Mcx);

% Выбор подшипников ведущего вала (по конструктивным соображениям и диаметру)
reducer(11).d1_verif = reducer(11).d1 + 1; % мм (диаметр в опасном сечении)
fprintf('  Диаметр вала: %.2f мм\n', reducer(11).d1_verif);
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(11).Lh_podsh <= reducer(11).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "d") == reducer(11).d1_verif
        fprintf('Подшипник: %s \n', getBearingData(ind, "code"));
        if ind <= 34                
            ind1 = ind;
            ind = 34;
        else
            ind2 = ind;
            break
        end
    end
    ind = ind + 1;    
end
reducer(11).a_podsh_ind = 0;
if getBearingData(ind1, "B") <= getBearingData(ind2, "B")
    reducer(11).a_podsh_ind = ind1;
else
    reducer(11).a_podsh_ind = ind2;
end


fprintf(getBearingData(reducer(11).a_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(11).a_podsh_ind, "C") * 1000 /...
    reducer(11).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(11).nch)));
fprintf("Диаметр оси ведущего вала: %.3f\n", getBearingData(reducer(11).a_podsh_ind, "d"))

% Геометрические характеристики сечения
reducer(11).W_shaft = (pi * reducer(11).d1_verif^3) / 32; % мм^3 (момент сопротивления изгибу)
reducer(11).Wp_shaft = (pi * reducer(11).d1_verif^3) / 16; % мм^3 (момент сопротивления кручению)

% Напряжения (амплитудные), МПа
% tau_a = T / (2 * Wp)
%Амплитуда τa и среднее τm напряжение отнулевого цикла касательных напряжений от действия крутящего момента
reducer(11).tau_a = (reducer(11).Ta * 1000) / (2 * reducer(11).Wp_shaft); % МПа
reducer(11).tau_m = reducer(11).tau_a;
% sigma_a = M / W
% Амплитуда нормальных напряжений изгиба
reducer(11).sigma_a = (reducer(11).Mbx * 1000) / reducer(11).W_shaft; % МПа

% Коэффициенты концентрации напряжений и запаса прочности (из методички для стали 40Х)
% Пределы выносливости
reducer(11).sigma_minus1 = 410; % МПа (для изгиба)
reducer(11).tau_minus1 = 240; % МПа (для кручения)

reducer(11).K_sigma_D = 4.45; 
reducer(11).K_tau_D = 3.15;

% Пределы выносливости
reducer(11).sigma_D = reducer(11).sigma_minus1 / (reducer(11).K_sigma_D);
reducer(11).tau_D = reducer(11).tau_minus1 / (reducer(11).K_tau_D);

% Запасы прочности по нормальным и касательным напряжениям
reducer(11).S_sigma = reducer(11).sigma_minus1 / (reducer(11).K_sigma_D * reducer(11).sigma_a);
reducer(11).S_tau = reducer(11).tau_minus1 / (reducer(11).K_tau_D * reducer(11).tau_a);

% Общий запас прочности
reducer(11).S_shaft1 = (reducer(11).S_sigma * reducer(11).S_tau) / sqrt(reducer(11).S_sigma^2 + reducer(11).S_tau^2);
fprintf('  Общиц запас прочности: %.2f Нм\n', reducer(11).S_shaft1);

if reducer(11).S_shaft1 >= 2.5
    fprintf('  -> Прочность ведущего вала обеспечена (S >= 2.5)\n');
else
    fprintf('  -> Прочность ведущего вала НЕ обеспечена (S < 2.5)\n');
end

% Выбор подшипников ведущего вала (пример методички №210)
% Ищем подшипник с внутренним диаметром >= d1_verif
reducer(11).bear1_code = getBearingData(reducer(11).a_podsh_ind, "code");
reducer(11).bear1_d = getBearingData(reducer(11).a_podsh_ind, "d");
reducer(11).bear1_D = getBearingData(reducer(11).a_podsh_ind, "D");
reducer(11).bear1_B = getBearingData(reducer(11).a_podsh_ind, "B");
reducer(11).bear1_C = getBearingData(reducer(11).a_podsh_ind, "C"); % кН
fprintf('  Выбран подшипник ведущего вала: %s (d=%d, D=%d, B=%d, C=%.1f кН)\n', ...
    reducer(11).bear1_code, reducer(11).bear1_d, reducer(11).bear1_D, reducer(11).bear1_B, reducer(11).bear1_C);



% ========================================================================
% 16.2. Расчет ведомого вала (Тихоходный вал / Водило)
% ========================================================================
fprintf('\n--------------------------------------------------\n');
fprintf('16.2. РАСЧЕТ ВЕДОМОГО ВАЛА (ТИХОХОДНЫЙ ВАЛ)\n');
fprintf('--------------------------------------------------\n');

% 1. Исходные данные из предыдущих расчетов
reducer(11).d2_nom = reducer(11).d2; % Диаметр выходного конца вала (из п.12), обычно ~55 мм
reducer(11).T2_val = reducer(11).T2; % Крутящий момент на ведомом валу, Н*м

% 2. Определение нагрузок
% Консольная нагрузка Fr приложена в середине шейки выходного конца вала.
% По методичке (стр. 34): Fr = (125...200) * sqrt(T2). 
% Принимаем коэффициент 200 для более жестких условий (как в примере методички).
k_consol = 200; 
reducer(11).Fr_out = k_consol * sqrt(reducer(11).T2_val); % Н

fprintf('  Крутящий момент на валу (T2):      %.2f Н*м\n', reducer(11).T2_val);
fprintf('  Консольная радиальная сила (Fr):   %.2f Н (коэфф. %d)\n', reducer(11).Fr_out, k_consol);

% 3. Геометрические параметры (из эскизного проекта)
% Расстояние от середины шейки вала (точка приложения Fr) до опасного сечения
% (место перехода диаметра или установка подшипника в водиле).
% В методичке принято c = 110 мм.
reducer(11).c_out_shaft = 25; % мм 

fprintf('  Плечо консоли (c):                 %d мм\n', reducer(11).c_out_shaft);

% 4. Расчет внутренних усилий в опасном сечении
% Изгибающий момент: Mизг = Fr * c
reducer(11).M_bend_out = reducer(11).Fr_out * reducer(11).c_out_shaft * 1e-3; % Перевод в Н*м

% Крутящий момент постоянный по длине вала
reducer(11).T_out_check = reducer(11).T2_val;

% Приведенный момент (по теории наибольших касательных напряжений):
% Mпр = sqrt(Mизг^2 + T^2)
reducer(11).M_eq_out = sqrt(reducer(11).M_bend_out^2 + reducer(11).T_out_check^2);

fprintf('  Изгибающий момент (Mизг):          %.2f Н*м\n', reducer(11).M_bend_out);
fprintf('  Приведенный момент (Mпр):          %.2f Н*м\n', reducer(11).M_eq_out);

% 5. Проверка прочности вала
% Допускаемое напряжение на изгиб [σ]изг.
% В методичке (стр. 35) для стали 40Х с учетом коэффициентов концентрации, 
% масштаба и запаса прочности (S=1.8) принято [σ] = 89 МПа.
reducer(11).sigma_allow_out = 89; % МПа

% Эквивалентное напряжение в валу: σпр = Mпр / (0.1 * d^3)
% Проверяем для диаметра, принятого в п.12 (reducer(11).d2_nom)
d_check = reducer(11).d2_nom; 
if d_check == 0
    d_check = 55; % Защита от деления на ноль, если p.12 не отработал
end

reducer(11).sigma_eq_out = (reducer(11).M_eq_out * 1000) / (0.1 * d_check^3); % МПа (момент в Н*м -> Н*мм)

fprintf('  Расчетный диаметр вала (d2):       %.1f мм\n', d_check);
fprintf('  Эквивалентное напряжение (σпр):    %.2f МПа\n', reducer(11).sigma_eq_out);
fprintf('  Допускаемое напряжение ([σ]):      %.2f МПа\n', reducer(11).sigma_allow_out);

if reducer(11).sigma_eq_out <= reducer(11).sigma_allow_out
    fprintf('  >>> ПРОЧНОСТЬ ВЕДОМОГО ВАЛА ОБЕСПЕЧЕНА <<<\n');
    reducer(11).shaft2_ok = true;
else
    fprintf('  >>> ПРОЧНОСТЬ ВЕДОМОГО ВАЛА НЕ ОБЕСПЕЧЕНА <<<\n');
    fprintf('  Требуется увеличить диаметр вала.\n');
    reducer(11).shaft2_ok = false;
    
    % Расчет требуемого диаметра (опционально)
    d_req = ((reducer(11).M_eq_out * 1000) / (0.1 * reducer(11).sigma_allow_out))^(1/3);
    fprintf('  Рекомендуемый минимальный диаметр: %.1f мм\n', d_req);
end

% 6. Выбор подшипников ведомого вала
% В планетарных редукторах ведомый вал (водило) часто имеет увеличенные посадочные места
% под подшипники внутри корпуса водила, даже если выходной конец вала тоньше.
% Однако, если вал цельный и подшипники стоят на выходных шейках, подбираем под d2.
% В методичке (стр. 36) для d2=55мм выбран подшипник с большим посадочным (d=105), 
% т.к. он стоит внутри водила. 
% Здесь реализуем универсальный поиск: ищем подшипник под диаметр d2 (или чуть больше, если это посадка в водило).

fprintf('\n  Подбор подшипников ведомого вала:\n');

% Для примера будем искать подшипник под диаметр d2_nom (если это выходная опора)
% Или можно задать фиктивный диаметр посадки в водиле, если он известен из эскиза.
% Пусть пока ищем под диаметр вала d2_nom, но с запасом по грузоподъемности.
target_d = reducer(11).d2_nom; 

% Если диаметр маленький (например, < 30), а момент большой, возможно потребуется серия тяжелее.
% Используем ту же функцию поиска, что и в п. 15 и 16.1
reducer(11).Lh_podsh2 = 0;
ind = 1;
ind1 = 1; % Индекс легкой серии
ind2 = 35; % Индекс средней серии (начало второй части массива bearings)

% Перебор базы подшипников
while ind < 57 % Предполагаем, что в базе 57 записей (настройте под вашу функцию getBearingData)
    if ind == 58
        break;
    end
    
    % Ищем подшипник, внутренний диаметр которого >= target_d
    % В реальном проекте тут может быть условие: d_podsh >= d_waterilo (который > d2)
    if getBearingData(ind, "d") >= target_d
        
        % Расчет долговечности
        % Нагрузка на подшипники ведомого вала складывается из реакции от Fr и веса водила.
        % Упрощенно примем радиальную нагрузку равной Fr (консервативно) или реакции опор.
        % В методичке сказано, что нагрузки незначительны, выбор по конструктивным соображениям.
        % Но проверим долговечность от Fr, распределенной на 2 опоры (примерно Fr/2 на опору, но с плечами)
        % Для простоты примем Radial Load = Fr_out (худший случай - вся нагрузка на одну опору при пуске)
        Fr_bear = reducer(11).Fr_out; 
        
        Pe2 = 1.2 * Fr_bear * 1.3; % V=1.2 (кольцо вращается?), Ksigma=1.3. Уточните V для водила.
        % Для водила наружное кольцо подшипника вращается вместе с водилом относительно нагрузки? 
        % Нет, нагрузка от корпуса неподвижна, водило вращается -> вращается внутреннее кольцо (если оно на валу)
        % В планетарке водило - это вал. Подшипник стоит в корпусе. 
        %-> Вращается внутреннее кольцо (посажен на водило). Значит V=1.
        
        Pe2 = 1.0 * Fr_bear * 1.3; % V=1, Ksigma=1.3
        
        C_val = getBearingData(ind, "C") * 1000; % Перевод кН в Н
        
        % Обороты ведомого вала
        n_out = semimotor(11).nreq; 
        
        if n_out > 0
            Lh_temp = (C_val / Pe2)^3 * 1000000 / (60 * n_out);
        else
            Lh_temp = 0;
        end
        
        if Lh_temp >= reducer(11).t
            if ind <= 34                
                ind1 = ind; % Запоминаем последний подходящий из легкой
            else
                ind2 = ind; % Запоминаем первый подходящий из средней (или тяжелой)
                break; % Нашли подходящий в средней серии, дальше нет смысла (будут громоздкие)
            end
        end
    end
    ind = ind + 1;    
end

% Выбор окончательного индекса (предпочитаем компактный, если проходит, иначе надежный)
% Логика: если легкий подходит по габаритам (ширина B) и влезает в конструкцию - берем его.
% Но для тихоходного вала с большим моментом часто сразу берут среднюю серию.
% Возьмем тот, у которого больше ресурс, но разумный габарит.
if reducer(11).Lh_podsh2 == 0 % Если цикл не заполнил переменную глобально, посчитаем для выбранных
     % Просто выберем ind2 (средняя серия) как более надежный для выходного вала, 
     % если он был найден, иначе ind1.
     if ind2 > 34 
         reducer(11).b_podsh_ind = ind2;
     else
         reducer(11).b_podsh_ind = ind1;
     end
else
     reducer(11).b_podsh_ind = ind2; % По умолчанию берем среднюю серию для надежности
end

% Вывод результатов по подшипнику
bear_code = getBearingData(reducer(11).b_podsh_ind, "code");
bear_d = getBearingData(reducer(11).b_podsh_ind, "d");
bear_D = getBearingData(reducer(11).b_podsh_ind, "D");
bear_B = getBearingData(reducer(11).b_podsh_ind, "B");
bear_C = getBearingData(reducer(11).b_podsh_ind, "C");

% Пересчет точной долговечности для выбранного
C_sel = bear_C * 1000;
Pe_sel = 1.0 * reducer(11).Fr_out * 1.3;
n_out = semimotor(11).nreq;
Lh_final = (C_sel / Pe_sel)^3 * 1000000 / (60 * n_out);

fprintf('  Выбран подшипник: %s\n', bear_code);
fprintf('  Размеры (d x D x B): %d x %d x %d мм\n', bear_d, bear_D, bear_B);
fprintf('  Динамическая грузоподъемность (C): %.1f кН\n', bear_C);
fprintf('  Расчетная долговечность (Lh): %.0f часов (требуется %d)\n', Lh_final, reducer(11).t);

if Lh_final >= reducer(11).t
    fprintf('  >>> ДОЛГОВЕЧНОСТЬ ПОДШИПНИКОВ ВЕДОМОГО ВАЛА ОБЕСПЕЧЕНА <<<\n');
else
    fprintf('  >>> ВНИМАНИЕ: Долговечность ниже требуемой. Рассмотрите подшипник большей серии. <<<\n');
end


fprintf('\n======= КОНЕЦ РАСЧЕТА ВАЛОВ =======\n');



% ======= ИТОГОВАЯ СВОДКА =======
fprintf('================================================================================\n');
fprintf('                           ИТОГОВАЯ СВОДКА ПАРАМЕТРОВ                          \n');
fprintf('================================================================================\n\n');

fprintf('Основные параметры редуктора:\n');
fprintf('  ┌─────────────────────────────────────────────────────────────────────────┐\n');
fprintf('  │ Параметр                          │ Значение          │ Ед. изм.      │\n');
fprintf('  ├─────────────────────────────────────────────────────────────────────────┤\n');
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(11).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(11).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(11).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(11).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(11).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(11).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(11).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(11).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(11).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(11).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(11).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(11).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(11).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(11).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(11).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(11).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(11).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(11).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(11).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(11).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(11).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(11).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(11).d_axis);
fprintf('  └─────────────────────────────────────────────────────────────────────────┘\n\n');

%% Расчет массы всего редктора

reducer2_ro = 7.8 * 10^3;
gear2_mass = (3 * reducer2_ro * pi / 4 * (0.3 * reducer(11).ba *  reducer(11).da^2 + ...
    0.25 * reducer(11).C * reducer(11).bc * reducer(11).dc^2)/ 10^9);
reducer2_mass = (1.5 + 1) * gear2_mass;
total2_mass = (0.35 + 1) * reducer2_mass;

fprintf('  │ Массы шестерен (gear_mass)        │ %15.3f │ кг            │\n', gear2_mass);
fprintf('  │ Массы редуктора (reducer_mass)    │ %15.3f │ кг            │\n', reducer2_mass);
fprintf('  │ Общее передаточное отношение      │ %15.3f │               │\n',  (reducer(13).db /  reducer(13).da + 1) ^ 3);
fprintf('  │ Общая масса привода (total2_mass) │ %15.3f │ кг            │\n',  total2_mass);

fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');