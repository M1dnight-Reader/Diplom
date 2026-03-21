clc

fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(10).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(10).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(10).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(10).u = semimotor(10).nmot / semimotor(10).nreq;
reducer(10).k = reducer(10).u - 1;
reducer(10).C = 3;
reducer(10).t = 5000;
reducer(10).na = semimotor(10).nmot;
reducer(10).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(10).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(10).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(10).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(10).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(10).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(10).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(10).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(10).k);
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
reducer(10).nah = semimotor(10).nmot - semimotor(10).nreq;
reducer(10).nbh = 0 - semimotor(10).nreq;
reducer(10).nch = -(semimotor(10).nmot - semimotor(10).nreq) * 2 / (reducer(10).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(10).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(10).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(10).nch);

% 4.4. Определение КПД редуктора
reducer(10).etarel = (1 + reducer(10).k * 0.99 * 0.97) / (1 + reducer(10).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(10).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(10).etamuf = 0.99;
reducer(10).eta = reducer(10).etarel * reducer(10).etamuf;
reducer(10).Ndvig = semimotor(10).N / reducer(10).eta;
reducer(10).N1 = reducer(10).Ndvig * reducer(10).etamuf;
reducer(10).T1 = 9.550 * reducer(10).N1 / semimotor(10).nmot;
reducer(10).Ta = reducer(10).T1;
reducer(10).N2 = reducer(10).Ndvig * reducer(10).etarel;
reducer(10).T2 = 9.550 * reducer(10).N2 / semimotor(10).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(10).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(10).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(10).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(10).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(10).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(10).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(10).HBg = 290;
reducer(10).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(10).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(10).HBw);

% 6.2. Определение допускаемых напряжений
reducer(10).NHO1 = 24 * 10^6;
reducer(10).NHO2 = 21 * 10^6;
reducer(10).NFO1 = 4 * 10^6;
reducer(10).NFO2 = 4 * 10^6;

reducer(10).t1 = 0.3 * reducer(10).t;
reducer(10).t2 = 0.3 * reducer(10).t;
reducer(10).t3 = 0.4 * reducer(10).t;
reducer(10).mode = [1, 0.6, 0.3];
reducer(10).tHE = 0;

for i = 1:3
    reducer(10).tHE = reducer(10).tHE + reducer(10).t1 * reducer(10).mode(i)^3;
end

reducer(10).NHE2 = abs(60 * reducer(10).nch * reducer(10).tHE);
reducer(10).NHE1 = 60 * reducer(10).nah * reducer(10).C * reducer(10).tHE;

reducer(10).KHL1 = (reducer(10).NHO1 / reducer(10).NHE1)^(1/6);
if reducer(10).KHL1 < 1
    reducer(10).KHL1 = 1;
end
reducer(10).KHL2 = (reducer(10).NHO2 / reducer(10).NHE2)^(1/6);
if reducer(10).KHL2 < 1
    reducer(10).KHL2 = 1;
end

reducer(10).KFL1 = 1;
reducer(10).KFL2 = 1;

reducer(10).sigmaHO1 = 2 * reducer(10).HBg + 70;
reducer(10).sigmaHO2 = 2 * reducer(10).HBw + 70;
reducer(10).sigmaFO1 = 1.8 * reducer(10).HBg;
reducer(10).sigmaFO2 = 1.8 * reducer(10).HBw;

reducer(10).SH1 = 1.1;
reducer(10).SH2 = 1.1;
reducer(10).SF1 = 1.75;
reducer(10).SF2 = 1.75;
reducer(10).sigmaH1 = reducer(10).sigmaHO1 / reducer(10).SH1 * reducer(10).KHL1;
reducer(10).sigmaH2 = reducer(10).sigmaHO2 / reducer(10).SH2 * reducer(10).KHL2;
reducer(10).sigmaF1 = reducer(10).sigmaFO1 / reducer(10).SF1 * reducer(10).KFL1;
reducer(10).sigmaF2 = reducer(10).sigmaFO2 / reducer(10).SF2 * reducer(10).KFL2;
reducer(10).sigmaH = min(reducer(10).sigmaH1, reducer(10).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(10).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(10).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(10).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(10).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(10).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(10).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(10).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(10).KHL1, reducer(10).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(10).KFL1, reducer(10).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(10).sigmaHO1, reducer(10).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(10).sigmaFO1, reducer(10).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(10).SH1, reducer(10).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(10).SF1, reducer(10).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(10).sigmaH1, reducer(10).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(10).sigmaF1, reducer(10).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(10).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(10).Kd = 780;
reducer(10).psibd = 0.6;
reducer(10).uHaC = (reducer(10).k - 1)/2;
reducer(10).uHcb = abs(reducer(10).nch / reducer(10).nbh);
reducer(10).Kc = 1.1;

reducer(10).Khbetta = get_Khbetta_Kfbetta(reducer(10).psibd, reducer(10).HBg, reducer(10).HBw, 'VI', 'KH');
reducer(10).Tap = reducer(10).Ta * reducer(10).Khbetta * reducer(10).Kc / reducer(10).C;
reducer(10).da = reducer(10).Kd * ((reducer(10).Tap * (reducer(10).uHaC + 1)) / ...
    (reducer(10).psibd * (reducer(10).sigmaH ^ 2) * reducer(10).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(10).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(10).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(10).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(10).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(10).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(10).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(10).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(10).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(10).za;
arrraay_of_m = zeros(1, 5);
reducer(10).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(10).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(10).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(10).m > arrraay_of_m(i)
        reducer(10).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(10).za = T2{1, the_chosen_m_ind};
reducer(10).m = T2{3, the_chosen_m_ind};
reducer(10).da = reducer(10).m * reducer(10).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(10).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(10).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(10).da);

% Параметры остальных колес
reducer(10).zb = col3(the_chosen_m_ind);
reducer(10).zc = col7(the_chosen_m_ind);
reducer(10).db = reducer(10).m * reducer(10).zb;
reducer(10).dc = reducer(10).m * reducer(10).zc;

reducer(10).bc = reducer(10).psibd * reducer(10).da;
reducer(10).ba = reducer(10).bc + 4;
reducer(10).bb = reducer(10).bc + 4;

reducer(10).V = pi * reducer(10).da * reducer(10).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(10).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(10).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(10).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(10).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(10).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(10).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(10).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(10).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(10).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(10).V);
reducer(10).aw = (reducer(10).da + reducer(10).dc) / 2;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(10).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(10).Zm = 275;
reducer(10).Zh = 1.76;
reducer(10).epsilona = 1.88 - 3.2 * (1 / reducer(10).za + 1 / reducer(10).zc);
reducer(10).Ze = sqrt((4 - reducer(10).epsilona) / 3);

[reducer(10).grade, desc] = getAccuracyGrade(reducer(10).V, 'cylindrical');
[reducer(10).Kha, reducer(10).Kfa] = get_K_Ha_K_Fa(reducer(10).V, reducer(10).grade);
[reducer(10).Khv, reducer(10).Kfv] = getDynamicCoefficients(reducer(10).V, reducer(10).grade, 'a', 'straight');
reducer(10).Khc = 1.1;

reducer(10).sigmah = reducer(10).Zm * reducer(10).Zh * reducer(10).Ze * ...
    sqrt((2 * reducer(10).Tap * reducer(10).Khbetta * reducer(10).Khv * reducer(10).Kha * ...
    (reducer(10).uHaC + 1) * 1000) / (reducer(10).bb * reducer(10).da ^ 2 * ...
    reducer(10).uHaC * reducer(10).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(10).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(10).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(10).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(10).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(10).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(10).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(10).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(10).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(10).sigmaH);

if reducer(10).sigmah <= reducer(10).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(10).Kfbetta = get_Khbetta_Kfbetta(reducer(10).psibd, reducer(10).HBg, reducer(10).HBw, 'V', 'KF');
reducer(10).YF1 = get_YF(reducer(10).za, 0);
reducer(10).YF2 = get_YF(reducer(10).zc, 0);
reducer(10).Ke = 0.92;
reducer(10).mt = reducer(10).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(10).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(10).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(10).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(10).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(10).mt);

if reducer(10).sigmaF1 / reducer(10).YF1 > reducer(10).sigmaF2 / reducer(10).YF2
    reducer(10).sigmaFC = reducer(10).YF2 * (2 * reducer(10).Tap * reducer(10).Kfbetta * ...
        reducer(10).Kfv * reducer(10).Kfa * reducer(10).Kc * 1000) / ...
        (reducer(10).C * reducer(10).Ke * reducer(10).ba * reducer(10).epsilona * ...
        reducer(10).da * reducer(10).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(10).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(10).sigmaF2);
    
    if reducer(10).sigmaFC <= reducer(10).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(10).sigmaFC = reducer(10).YF1 * (2 * reducer(10).Tap * reducer(10).Kfbetta * ...
        reducer(10).Kfv * reducer(10).Kfa * reducer(10).Kc * 1000) / ...
        (reducer(10).C * reducer(10).Ke * reducer(10).ba * reducer(10).epsilona * ...
        reducer(10).da * reducer(10).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(10).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(10).sigmaF1);
    
    if reducer(10).sigmaFC <= reducer(10).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(10).Vc = abs(pi * reducer(10).dc * reducer(10).nch / 60000);
reducer(10).epsilona_e = 1.88 - 3.2 * (1 / reducer(10).zc - 1 / reducer(10).zb);
reducer(10).Ze_e = sqrt((4 - reducer(10).epsilona_e) / 3);
reducer(10).Tb = 2 * reducer(10).T2 * reducer(10).Khbetta * reducer(10).Kc / reducer(10).C;

[reducer(10).grade_e, desc_e] = getAccuracyGrade(reducer(10).Vc, 'cylindrical');
[reducer(10).Kha_e, reducer(10).Kfa_e] = get_K_Ha_K_Fa(reducer(10).Vc, reducer(10).grade_e);
[reducer(10).Khv_e, reducer(10).Kfv_e] = getDynamicCoefficients(reducer(10).Vc, reducer(10).grade_e, 'a', 'straight');
reducer(10).uCb = reducer(10).zb / reducer(10).zc;

reducer(10).sigmah_e = reducer(10).Zm * reducer(10).Zh * reducer(10).Ze_e * ...
    sqrt((2 * reducer(10).Tb * reducer(10).Khbetta * reducer(10).Khv_e * reducer(10).Kha * ...
    reducer(10).Kc * (reducer(10).uHcb - 1) * 1000) / (reducer(10).C * reducer(10).bb * ...
    reducer(10).dc * reducer(10).db * reducer(10).uCb));

reducer(10).sigmah0_e = reducer(10).sigmah_e / reducer(10).KHL2 * reducer(10).SH2;
reducer(10).HB_e = (reducer(10).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(10).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(10).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(10).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(10).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(10).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(10).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(10).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(10).overload = 2;
reducer(10).sigmah_max = 2 * reducer(10).sigmah * sqrt(reducer(10).overload);
reducer(10).sigmaf_max = 2 * reducer(10).sigmaFC * reducer(10).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(10).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(10).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(10).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(10).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(10).sigmaHO2);

if (reducer(10).sigmah_max <= 2.8 * reducer(10).sigmaHO1) && ...
   (reducer(10).sigmaf_max <= 0.8 * reducer(10).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(10).tau = 15;
reducer(10).d1 = ((reducer(10).T1 * 1000) / (0.2 * reducer(10).tau)) ^ (1/3);
reducer(10).d1 = floor(reducer(10).d1);
%reducer(10).d1 = 40;
reducer(10).d2 = ((reducer(10).T2 * 1000) / (0.2 * reducer(10).tau)) ^ (1/3);
reducer(10).d2 = floor(reducer(10).d2);
reducer(10).aw = (reducer(10).da + reducer(10).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(10).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(10).T1 * 1000) / (0.2 * reducer(10).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(10).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(10).T2 * 1000) / (0.2 * reducer(10).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(10).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(10).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(10).Fa = (2 * reducer(10).T1 * 1000 * reducer(10).Kc) / (reducer(10).da * reducer(10).C);
reducer(10).Fn = 2 * reducer(10).Fa;
reducer(10).l = 40;
reducer(10).q = reducer(10).Fn / reducer(10).l;
reducer(10).M_bend = reducer(10).q * reducer(10).l ^ 2 / 8;
reducer(10).sigma_axis = 120;
reducer(10).d_axis = 0.5 * floor(2 * ((32 * reducer(10).M_bend) / (pi * reducer(10).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(10).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(10).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(10).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(10).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(10).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(10).d_axis);

%=======15.ВЫБОР_ПОДШИПНИКОВ_САТЕЛИТОВ=======

% Подшипники воспринимают только радиальную нагрузку
reducer(10).Frmax = reducer(10).Fn;
reducer(10).V_podsh = 1.2; %  коэффициент вращения кольца (вращение наружного кольца подшипника)
reducer(10).Ksigma_podsh = 1.3; % оэффициент безопасности
reducer(10).KT_podsh = 1; % 1 – температурный коэффициент в случае, когда температура деталей t = 70÷125°C
reducer(10).KN_podsh = 1; % коэффициент режима работы, учитывающий переменность нагрузки
% !!! ЧЕКНУТЬ ГОСТ
reducer(10).Pe_podsh = reducer(10).V_podsh * reducer(10).Frmax * reducer(10).Ksigma_podsh * ...
    reducer(10).KT_podsh * reducer(10).KN_podsh; % эквивалентная нагрузка на подшипник

reducer(10).Lh_podsh = 0;
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(10).Lh_podsh <= reducer(10).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "B") <= reducer(10).bc
        reducer(10).Lh_podsh = (getBearingData(ind, "C") * 1000 / reducer(10).Pe_podsh)^3 * ...
            1000000 / (60 * abs(reducer(10).nch));        
        if reducer(10).Lh_podsh >= reducer(10).t
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
reducer(10).c_podsh_ind = 0;
if getBearingData(ind1, "B") < getBearingData(ind2, "B")
    reducer(10).c_podsh_ind = ind1;
else
    reducer(10).c_podsh_ind = ind2;
end

% Выбранный подшипник
fprintf(getBearingData(reducer(10).c_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(10).c_podsh_ind, "C") * 1000 /...
    reducer(10).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(10).nch)));
fprintf("Диаметр оси сателлита: %.3f\n", getBearingData(reducer(10).c_podsh_ind, "d"))

%=======16.ПРОВЕРОЧНЫЙ_РАСЧЕТ_ВАЛОВ=======

% 16.1. Расчет ведущего вала (Быстроходный вал)
% Примечание: Размеры a, b, c берутся из эскизного проекта (п. 13).
% В данном коде используем значения из примера методички для демонстрации расчета.

fprintf('\n======= 16. ПРОВЕРОЧНЫЙ РАСЧЕТ ВАЛОВ =======\n');
fprintf('16.1. Расчет ведущего вала:\n');

% Геометрические размеры участков вала (из эскиза, пример методички)
reducer(10).a_shaft = 65; % мм
reducer(10).b_shaft = 55; % мм (расстояние между опорами)
reducer(10).c_shaft = 108; % мм (консольный участок под муфту)

% Силы, действующие на вал
% FM - консольная нагрузка от муфты
reducer(10).FM = 125 * (reducer(10).Ta)^(1/2); % Н
fprintf('  Консольная нагрузка от муфты: %.2f Нм\n', reducer(10).FM);
fprintf('  Радиальная нагрузка: %.2f Нм\n', reducer(10).Fn);

% Реакции опор (схема: две опоры, консольная нагрузка)
reducer(10).Rbx = (reducer(10).Fn * (reducer(10).b_shaft + reducer(10).a_shaft) +...
    reducer(10).FM * reducer(10).c_shaft) / reducer(10).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(10).Rbx);
reducer(10).Rcx = (reducer(10).Fn * reducer(10).a_shaft  +...
    reducer(10).FM * (reducer(10).b_shaft + reducer(10).c_shaft)) / reducer(10).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(10).Rcx);

% Изгибающие моменты в опасных сечениях
reducer(10).Mbx = reducer(10).Fn * reducer(10).a_shaft * 1e-3; % Нм (в сечении B)
reducer(10).Mcx = reducer(10).FM * reducer(10).c_shaft * 1e-3; % Нм (в сечении C, от муфты)
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(10).Mbx);
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(10).Mcx);

% Выбор подшипников ведущего вала (по конструктивным соображениям и диаметру)
reducer(10).d1_verif = reducer(10).d1 + 9; % мм (диаметр в опасном сечении)
fprintf('  Диаметр вала: %.2f Нм\n', reducer(10).d1_verif);
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(10).Lh_podsh <= reducer(10).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "d") == reducer(10).d1_verif     
        if ind <= 34                
            ind1 = ind;
            ind = 35;
        else
            ind2 = ind;
            break
        end
    end
    ind = ind + 1;    
end
reducer(10).a_podsh_ind = 0;
if getBearingData(ind1, "B") < getBearingData(ind2, "B")
    reducer(10).a_podsh_ind = ind1;
else
    reducer(10).a_podsh_ind = ind2;
end

fprintf(getBearingData(reducer(10).a_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(10).a_podsh_ind, "C") * 1000 /...
    reducer(10).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(10).nch)));
fprintf("Диаметр оси ведущего вала: %.3f\n", getBearingData(reducer(10).a_podsh_ind, "d"))

% Геометрические характеристики сечения
reducer(10).W_shaft = (pi * reducer(10).d1_verif^3) / 32; % мм^3 (момент сопротивления изгибу)
reducer(10).Wp_shaft = (pi * reducer(10).d1_verif^3) / 16; % мм^3 (момент сопротивления кручению)

% Напряжения (амплитудные), МПа
% tau_a = T / (2 * Wp)
%Амплитуда τa и среднее τm напряжение отнулевого цикла касательных напряжений от действия крутящего момента
reducer(10).tau_a = (reducer(10).Ta * 1000) / (2 * reducer(10).Wp_shaft); % МПа
reducer(10).tau_m = reducer(10).tau_a;
% sigma_a = M / W
% Амплитуда нормальных напряжений изгиба
reducer(10).sigma_a = (reducer(10).Mbx * 1000) / reducer(10).W_shaft; % МПа

% Коэффициенты концентрации напряжений и запаса прочности (из методички для стали 40Х)
% Пределы выносливости
reducer(10).sigma_minus1 = 410; % МПа (для изгиба)
reducer(10).tau_minus1 = 240; % МПа (для кручения)

reducer(10).K_sigma_D = 4.45; 
reducer(10).K_tau_D = 3.15;

% Пределы выносливости
reducer(10).sigma_D = reducer(10).sigma_minus1 / (reducer(10).K_sigma_D);
reducer(10).tau_D = reducer(10).tau_minus1 / (reducer(10).K_tau_D);

% Запасы прочности по нормальным и касательным напряжениям
reducer(10).S_sigma = reducer(10).sigma_minus1 / (reducer(10).K_sigma_D * reducer(10).sigma_a);
reducer(10).S_tau = reducer(10).tau_minus1 / (reducer(10).K_tau_D * reducer(10).tau_a);

% Общий запас прочности
reducer(10).S_shaft1 = (reducer(10).S_sigma * reducer(10).S_tau) / sqrt(reducer(10).S_sigma^2 + reducer(10).S_tau^2);
fprintf('  Общиц запас прочности: %.2f Нм\n', reducer(10).S_shaft1);

if reducer(10).S_shaft1 >= 2.5
    fprintf('  -> Прочность ведущего вала обеспечена (S >= 2.5)\n');
else
    fprintf('  -> Прочность ведущего вала НЕ обеспечена (S < 2.5)\n');
end

% Выбор подшипников ведущего вала (пример методички №210)
% Ищем подшипник с внутренним диаметром >= d1_verif
reducer(10).bear1_code = getBearingData(reducer(10).a_podsh_ind, "code");
reducer(10).bear1_d = getBearingData(reducer(10).a_podsh_ind, "d");
reducer(10).bear1_D = getBearingData(reducer(10).a_podsh_ind, "D");
reducer(10).bear1_B = getBearingData(reducer(10).a_podsh_ind, "B");
reducer(10).bear1_C = getBearingData(reducer(10).a_podsh_ind, "C"); % кН
fprintf('  Выбран подшипник ведущего вала: %s (d=%d, D=%d, B=%d, C=%.1f кН)\n', ...
    reducer(10).bear1_code, reducer(10).bear1_d, reducer(10).bear1_D, reducer(10).bear1_B, reducer(10).bear1_C);


% 16.2. Расчет ведомого вала (Тихоходный вал)
fprintf('\n16.2. Расчет ведомого вала:\n');

% Диаметр выходного участка (из п. 12)
reducer(8).d2_verif = reducer(8).d2; % мм (обычно 55 мм в примере)

% Нагрузки
reducer(8).T2_check = reducer(8).T2; % Нм
% Консольная нагрузка Fr (по ГОСТ 16162-78 или методичке)
% В методичке принято Fr = 4500 Н для большего диапазона использования
reducer(8).Fr_out = 200 * (reducer(8).T2_check)^(1/2); % Н; % Н
% Расстояние от середины шейки до опасного сечения (из эскиза)
reducer(8).c_out = 110; % мм

% Расчетные усилия в опасном сечении
reducer(8).M_bend_out = reducer(8).Fr_out * reducer(8).c_out * 1e-3; % Нм
reducer(8).M_eq_out = sqrt(reducer(8).M_bend_out^2 + reducer(8).T2_check^2); % Приведенный момент, Нм

% Проверка по статической прочности (упрощенно)
% sigma_eq = M_eq / (0.1 * d^3)
reducer(8).sigma_eq_out = (reducer(8).M_eq_out * 1000) / (0.1 * reducer(8).d2_verif^3); % МПа

% Допускаемое напряжение (предел усталостной прочности с учетом коэффициентов)
% В методичке рассчитано [sigma] = 89 МПа для стали 40Х
reducer(8).sigma_allow_out = 89; % МПа

fprintf('  Диаметр ведомого вала: %.1f мм\n', reducer(8).d2_verif);
fprintf('  Изгибающий момент: %.2f Нм\n', reducer(8).M_bend_out);
fprintf('  Крутящий момент: %.2f Нм\n', reducer(8).T2_check);
fprintf('  Приведенный момент: %.2f Нм\n', reducer(8).M_eq_out);
fprintf('  Эквивалентное напряжение: %.2f МПа\n', reducer(8).sigma_eq_out);
fprintf('  Допускаемое напряжение: %.2f МПа\n', reducer(8).sigma_allow_out);

if reducer(8).sigma_eq_out <= reducer(8).sigma_allow_out
    fprintf('  -> Прочность ведомого вала обеспечена\n');
else
    fprintf('  -> Прочность ведомого вала НЕ обеспечена\n');
end

% Выбор подшипников ведомого вала
% В методичке для d2=55 мм (посадочное отверстие подшипника может быть больше) 
% выбран подшипник №7000124 (d=105, D=160, B=18) - сверхлегкая серия, т.к. вал планетарный короткий и жесткий.
% Однако стандартный подбор обычно идет под диаметр вала. 
% Для примера методички запишем данные из текста.
reducer(8).bear2_code = '7000124';
reducer(8).bear2_d = 105; % мм (посадочный диаметр в корпусе водила/вала)
reducer(8).bear2_D = 160; % мм
reducer(8).bear2_B = 18; % мм
reducer(8).bear2_C = 52.0; % кН

fprintf('  Выбран подшипник ведомого вала: %s (d=%d, D=%d, B=%d, C=%.1f кН)\n', ...
    reducer(8).bear2_code, reducer(8).bear2_d, reducer(8).bear2_D, reducer(8).bear2_B, reducer(8).bear2_C);

fprintf('\n======= КОНЕЦ РАСЧЕТА ВАЛОВ =======\n');

% ======= ИТОГОВАЯ СВОДКА =======
fprintf('================================================================================\n');
fprintf('                           ИТОГОВАЯ СВОДКА ПАРАМЕТРОВ                          \n');
fprintf('================================================================================\n\n');

fprintf('Основные параметры редуктора:\n');
fprintf('  ┌─────────────────────────────────────────────────────────────────────────┐\n');
fprintf('  │ Параметр                          │ Значение          │ Ед. изм.      │\n');
fprintf('  ├─────────────────────────────────────────────────────────────────────────┤\n');
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(10).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(10).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(10).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(10).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(10).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(10).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(10).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(10).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(10).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(10).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(10).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(10).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(10).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(10).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(10).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(10).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(10).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(10).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(10).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(10).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(10).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(10).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(10).d_axis);
fprintf('  └─────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');



fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(9).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(9).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(9).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(9).u = semimotor(9).nmot / semimotor(9).nreq;
reducer(9).k = reducer(9).u - 1;
reducer(9).C = 3;
reducer(9).t = 5000;
reducer(9).na = semimotor(9).nmot;
reducer(9).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(9).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(9).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(9).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(9).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(9).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(9).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(9).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(9).k);
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
reducer(9).nah = semimotor(9).nmot - semimotor(9).nreq;
reducer(9).nbh = 0 - semimotor(9).nreq;
reducer(9).nch = -(semimotor(9).nmot - semimotor(9).nreq) * 2 / (reducer(9).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(9).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(9).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(9).nch);

% 4.4. Определение КПД редуктора
reducer(9).etarel = (1 + reducer(9).k * 0.99 * 0.97) / (1 + reducer(9).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(9).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(9).etamuf = 0.99;
reducer(9).eta = reducer(9).etarel * reducer(9).etamuf;
reducer(9).Ndvig = semimotor(9).N / reducer(9).eta;
reducer(9).N1 = reducer(9).Ndvig * reducer(9).etamuf;
reducer(9).T1 = 9.550 * reducer(9).N1 / semimotor(9).nmot;
reducer(9).Ta = reducer(9).T1;
reducer(9).N2 = reducer(9).Ndvig * reducer(9).etarel;
reducer(9).T2 = 9.550 * reducer(9).N2 / semimotor(9).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(9).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(9).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(9).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(9).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(9).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(9).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(9).HBg = 290;
reducer(9).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(9).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(9).HBw);

% 6.2. Определение допускаемых напряжений
reducer(9).NHO1 = 24 * 10^6;
reducer(9).NHO2 = 21 * 10^6;
reducer(9).NFO1 = 4 * 10^6;
reducer(9).NFO2 = 4 * 10^6;

reducer(9).t1 = 0.3 * reducer(9).t;
reducer(9).t2 = 0.3 * reducer(9).t;
reducer(9).t3 = 0.4 * reducer(9).t;
reducer(9).mode = [1, 0.6, 0.3];
reducer(9).tHE = 0;

for i = 1:3
    reducer(9).tHE = reducer(9).tHE + reducer(9).t1 * reducer(9).mode(i)^3;
end

reducer(9).NHE2 = abs(60 * reducer(9).nch * reducer(9).tHE);
reducer(9).NHE1 = 60 * reducer(9).nah * reducer(9).C * reducer(9).tHE;

reducer(9).KHL1 = (reducer(9).NHO1 / reducer(9).NHE1)^(1/6);
if reducer(9).KHL1 < 1
    reducer(9).KHL1 = 1;
end
reducer(9).KHL2 = (reducer(9).NHO2 / reducer(9).NHE2)^(1/6);
if reducer(9).KHL2 < 1
    reducer(9).KHL2 = 1;
end

reducer(9).KFL1 = 1;
reducer(9).KFL2 = 1;

reducer(9).sigmaHO1 = 2 * reducer(9).HBg + 70;
reducer(9).sigmaHO2 = 2 * reducer(9).HBw + 70;
reducer(9).sigmaFO1 = 1.8 * reducer(9).HBg;
reducer(9).sigmaFO2 = 1.8 * reducer(9).HBw;

reducer(9).SH1 = 1.1;
reducer(9).SH2 = 1.1;
reducer(9).SF1 = 1.75;
reducer(9).SF2 = 1.75;
reducer(9).sigmaH1 = reducer(9).sigmaHO1 / reducer(9).SH1 * reducer(9).KHL1;
reducer(9).sigmaH2 = reducer(9).sigmaHO2 / reducer(9).SH2 * reducer(9).KHL2;
reducer(9).sigmaF1 = reducer(9).sigmaFO1 / reducer(9).SF1 * reducer(9).KFL1;
reducer(9).sigmaF2 = reducer(9).sigmaFO2 / reducer(9).SF2 * reducer(9).KFL2;
reducer(9).sigmaH = min(reducer(9).sigmaH1, reducer(9).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(9).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(9).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(9).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(9).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(9).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(9).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(9).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(9).KHL1, reducer(9).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(9).KFL1, reducer(9).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(9).sigmaHO1, reducer(9).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(9).sigmaFO1, reducer(9).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(9).SH1, reducer(9).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(9).SF1, reducer(9).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(9).sigmaH1, reducer(9).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(9).sigmaF1, reducer(9).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(9).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(9).Kd = 780;
reducer(9).psibd = 0.6;
reducer(9).uHaC = (reducer(9).k - 1)/2;
reducer(9).uHcb = abs(reducer(9).nch / reducer(9).nbh);
reducer(9).Kc = 1.1;

reducer(9).Khbetta = get_Khbetta_Kfbetta(reducer(9).psibd, reducer(9).HBg, reducer(9).HBw, 'VI', 'KH');
reducer(9).Tap = reducer(9).Ta * reducer(9).Khbetta * reducer(9).Kc / reducer(9).C;
reducer(9).da = reducer(9).Kd * ((reducer(9).Tap * (reducer(9).uHaC + 1)) / ...
    (reducer(9).psibd * (reducer(9).sigmaH ^ 2) * reducer(9).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(9).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(9).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(9).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(9).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(9).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(9).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(9).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(9).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(9).za;
arrraay_of_m = zeros(1, 5);
reducer(9).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(9).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(9).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(9).m > arrraay_of_m(i)
        reducer(9).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(9).za = T2{1, the_chosen_m_ind};
reducer(9).m = T2{3, the_chosen_m_ind};
reducer(9).da = reducer(9).m * reducer(9).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(9).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(9).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(9).da);

% Параметры остальных колес
reducer(9).zb = col3(the_chosen_m_ind);
reducer(9).zc = col7(the_chosen_m_ind);
reducer(9).db = reducer(9).m * reducer(9).zb;
reducer(9).dc = reducer(9).m * reducer(9).zc;

reducer(9).bc = reducer(9).psibd * reducer(9).da;
reducer(9).ba = reducer(9).bc + 4;
reducer(9).bb = reducer(9).bc + 4;

reducer(9).V = pi * reducer(9).da * reducer(9).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(9).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(9).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(9).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(9).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(9).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(9).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(9).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(9).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(9).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(9).V);
reducer(9).aw = (reducer(9).da + reducer(9).dc) / 2;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(9).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(9).Zm = 275;
reducer(9).Zh = 1.76;
reducer(9).epsilona = 1.88 - 3.2 * (1 / reducer(9).za + 1 / reducer(9).zc);
reducer(9).Ze = sqrt((4 - reducer(9).epsilona) / 3);

[reducer(9).grade, desc] = getAccuracyGrade(reducer(9).V, 'cylindrical');
[reducer(9).Kha, reducer(9).Kfa] = get_K_Ha_K_Fa(reducer(9).V, reducer(9).grade);
[reducer(9).Khv, reducer(9).Kfv] = getDynamicCoefficients(reducer(9).V, reducer(9).grade, 'a', 'straight');
reducer(9).Khc = 1.1;

reducer(9).sigmah = reducer(9).Zm * reducer(9).Zh * reducer(9).Ze * ...
    sqrt((2 * reducer(9).Tap * reducer(9).Khbetta * reducer(9).Khv * reducer(9).Kha * ...
    (reducer(9).uHaC + 1) * 1000) / (reducer(9).bb * reducer(9).da ^ 2 * ...
    reducer(9).uHaC * reducer(9).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(9).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(9).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(9).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(9).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(9).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(9).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(9).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(9).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(9).sigmaH);

if reducer(9).sigmah <= reducer(9).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(9).Kfbetta = get_Khbetta_Kfbetta(reducer(9).psibd, reducer(9).HBg, reducer(9).HBw, 'V', 'KF');
reducer(9).YF1 = get_YF(reducer(9).za, 0);
reducer(9).YF2 = get_YF(reducer(9).zc, 0);
reducer(9).Ke = 0.92;
reducer(9).mt = reducer(9).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(9).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(9).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(9).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(9).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(9).mt);

if reducer(9).sigmaF1 / reducer(9).YF1 > reducer(9).sigmaF2 / reducer(9).YF2
    reducer(9).sigmaFC = reducer(9).YF2 * (2 * reducer(9).Tap * reducer(9).Kfbetta * ...
        reducer(9).Kfv * reducer(9).Kfa * reducer(9).Kc * 1000) / ...
        (reducer(9).C * reducer(9).Ke * reducer(9).ba * reducer(9).epsilona * ...
        reducer(9).da * reducer(9).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(9).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(9).sigmaF2);
    
    if reducer(9).sigmaFC <= reducer(9).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(9).sigmaFC = reducer(9).YF1 * (2 * reducer(9).Tap * reducer(9).Kfbetta * ...
        reducer(9).Kfv * reducer(9).Kfa * reducer(9).Kc * 1000) / ...
        (reducer(9).C * reducer(9).Ke * reducer(9).ba * reducer(9).epsilona * ...
        reducer(9).da * reducer(9).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(9).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(9).sigmaF1);
    
    if reducer(9).sigmaFC <= reducer(9).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(9).Vc = abs(pi * reducer(9).dc * reducer(9).nch / 60000);
reducer(9).epsilona_e = 1.88 - 3.2 * (1 / reducer(9).zc - 1 / reducer(9).zb);
reducer(9).Ze_e = sqrt((4 - reducer(9).epsilona_e) / 3);
reducer(9).Tb = 2 * reducer(9).T2 * reducer(9).Khbetta * reducer(9).Kc / reducer(9).C;

[reducer(9).grade_e, desc_e] = getAccuracyGrade(reducer(9).Vc, 'cylindrical');
[reducer(9).Kha_e, reducer(9).Kfa_e] = get_K_Ha_K_Fa(reducer(9).Vc, reducer(9).grade_e);
[reducer(9).Khv_e, reducer(9).Kfv_e] = getDynamicCoefficients(reducer(9).Vc, reducer(9).grade_e, 'a', 'straight');
reducer(9).uCb = reducer(9).zb / reducer(9).zc;

reducer(9).sigmah_e = reducer(9).Zm * reducer(9).Zh * reducer(9).Ze_e * ...
    sqrt((2 * reducer(9).Tb * reducer(9).Khbetta * reducer(9).Khv_e * reducer(9).Kha * ...
    reducer(9).Kc * (reducer(9).uHcb - 1) * 1000) / (reducer(9).C * reducer(9).bb * ...
    reducer(9).dc * reducer(9).db * reducer(9).uCb));

reducer(9).sigmah0_e = reducer(9).sigmah_e / reducer(9).KHL2 * reducer(9).SH2;
reducer(9).HB_e = (reducer(9).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(9).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(9).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(9).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(9).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(9).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(9).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(9).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(9).overload = 2;
reducer(9).sigmah_max = 2 * reducer(9).sigmah * sqrt(reducer(9).overload);
reducer(9).sigmaf_max = 2 * reducer(9).sigmaFC * reducer(9).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(9).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(9).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(9).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(9).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(9).sigmaHO2);

if (reducer(9).sigmah_max <= 2.8 * reducer(9).sigmaHO1) && ...
   (reducer(9).sigmaf_max <= 0.8 * reducer(9).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(9).tau = 15;
reducer(9).d1 = ((reducer(9).T1 * 1000) / (0.2 * reducer(9).tau)) ^ (1/3);
reducer(9).d1 = floor(reducer(9).d1);
%reducer(9).d1 = 40;
reducer(9).d2 = ((reducer(9).T2 * 1000) / (0.2 * reducer(9).tau)) ^ (1/3);
reducer(9).d2 = floor(reducer(9).d2);
reducer(9).aw = (reducer(9).da + reducer(9).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(9).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(9).T1 * 1000) / (0.2 * reducer(9).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(9).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(9).T2 * 1000) / (0.2 * reducer(9).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(9).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(9).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(9).Fa = (2 * reducer(9).T1 * 1000 * reducer(9).Kc) / (reducer(9).da * reducer(9).C);
reducer(9).Fn = 2 * reducer(9).Fa;
reducer(9).l = 30;
reducer(9).q = reducer(9).Fn / reducer(9).l;
reducer(9).M_bend = reducer(9).q * reducer(9).l ^ 2 / 8;
reducer(9).sigma_axis = 120;
reducer(9).d_axis = 0.5 * floor(2 * ((32 * reducer(9).M_bend) / (pi * reducer(9).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(9).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(9).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(9).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(9).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(9).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(9).d_axis);

%=======15.ВЫБОР_ПОДШИПНИКОВ_САТЕЛИТОВ=======

% Подшипники воспринимают только радиальную нагрузку
reducer(9).Frmax = reducer(9).Fn;
reducer(9).V_podsh = 1.2; %  коэффициент вращения кольца (вращение наружного кольца подшипника)
reducer(9).Ksigma_podsh = 1.3; % оэффициент безопасности
reducer(9).KT_podsh = 1; % 1 – температурный коэффициент в случае, когда температура деталей t = 70÷125°C
reducer(9).KN_podsh = 1; % коэффициент режима работы, учитывающий переменность нагрузки
% !!! ЧЕКНУТЬ ГОСТ
reducer(9).Pe_podsh = reducer(9).V_podsh * reducer(9).Frmax * reducer(9).Ksigma_podsh * ...
    reducer(9).KT_podsh * reducer(9).KN_podsh; % эквивалентная нагрузка на подшипник

reducer(9).Lh_podsh = 0;
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(9).Lh_podsh <= reducer(9).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "B") <= reducer(9).bc
        fprintf("%.3f", ind);
        reducer(9).Lh_podsh = (getBearingData(ind, "C") * 1000 / reducer(9).Pe_podsh)^3 * ...
            1000000 / (60 * abs(reducer(9).nch));        
        if reducer(9).Lh_podsh >= reducer(9).t
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
reducer(9).c_podsh_ind = 0;
if getBearingData(ind1, "B") < getBearingData(ind2, "B")
    reducer(9).c_podsh_ind = ind1;
else
    reducer(9).c_podsh_ind = ind2;
end

% Выбранный подшипник
fprintf(getBearingData(reducer(9).c_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(9).c_podsh_ind, "C") * 1000 /...
    reducer(9).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(9).nch)));
fprintf("Диаметр оси сателлита: %.3f\n", getBearingData(reducer(9).c_podsh_ind, "d"))

%=======16.ПРОВЕРОЧНЫЙ_РАСЧЕТ_ВАЛОВ=======

% 16.1. Расчет ведущего вала (Быстроходный вал)
% Примечание: Размеры a, b, c берутся из эскизного проекта (п. 13).
% В данном коде используем значения из примера методички для демонстрации расчета.

fprintf('\n======= 16. ПРОВЕРОЧНЫЙ РАСЧЕТ ВАЛОВ =======\n');
fprintf('16.1. Расчет ведущего вала:\n');

% Геометрические размеры участков вала (из эскиза, пример методички)
reducer(9).a_shaft = 65; % мм
reducer(9).b_shaft = 55; % мм (расстояние между опорами)
reducer(9).c_shaft = 108; % мм (консольный участок под муфту)

% Силы, действующие на вал
% FM - консольная нагрузка от муфты
reducer(9).FM = 125 * (reducer(9).Ta)^(1/2); % Н
fprintf('  Консольная нагрузка от муфты: %.2f Нм\n', reducer(9).FM);
fprintf('  Радиальная нагрузка: %.2f Нм\n', reducer(9).Fn);

% Реакции опор (схема: две опоры, консольная нагрузка)
reducer(9).Rbx = (reducer(9).Fn * (reducer(9).b_shaft + reducer(9).a_shaft) +...
    reducer(9).FM * reducer(9).c_shaft) / reducer(9).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(9).Rbx);
reducer(9).Rcx = (reducer(9).Fn * reducer(9).a_shaft  +...
    reducer(9).FM * (reducer(9).b_shaft + reducer(9).c_shaft)) / reducer(9).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(9).Rcx);

% Изгибающие моменты в опасных сечениях
reducer(9).Mbx = reducer(9).Fn * reducer(9).a_shaft * 1e-3; % Нм (в сечении B)
reducer(9).Mcx = reducer(9).FM * reducer(9).c_shaft * 1e-3; % Нм (в сечении C, от муфты)
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(9).Mbx);
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(9).Mcx);

% Выбор подшипников ведущего вала (по конструктивным соображениям и диаметру)
reducer(9).d1_verif = reducer(9).d1 + 9; % мм (диаметр в опасном сечении)
fprintf('  Диаметр вала: %.2f Нм\n', reducer(9).d1_verif);
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(9).Lh_podsh <= reducer(9).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "d") == reducer(9).d1_verif     
        if ind <= 34                
            ind1 = ind;
            ind = 35;
        else
            ind2 = ind;
            break
        end
    end
    ind = ind + 1;    
end
reducer(9).a_podsh_ind = 0;
if getBearingData(ind1, "B") < getBearingData(ind2, "B")
    reducer(9).a_podsh_ind = ind1;
else
    reducer(9).a_podsh_ind = ind2;
end

fprintf(getBearingData(reducer(9).a_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(9).a_podsh_ind, "C") * 1000 /...
    reducer(9).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(9).nch)));
fprintf("Диаметр оси ведущего вала: %.3f\n", getBearingData(reducer(9).a_podsh_ind, "d"))

% Геометрические характеристики сечения
reducer(9).W_shaft = (pi * reducer(9).d1_verif^3) / 32; % мм^3 (момент сопротивления изгибу)
reducer(9).Wp_shaft = (pi * reducer(9).d1_verif^3) / 16; % мм^3 (момент сопротивления кручению)

% Напряжения (амплитудные), МПа
% tau_a = T / (2 * Wp)
%Амплитуда τa и среднее τm напряжение отнулевого цикла касательных напряжений от действия крутящего момента
reducer(9).tau_a = (reducer(9).Ta * 1000) / (2 * reducer(9).Wp_shaft); % МПа
reducer(9).tau_m = reducer(9).tau_a;
% sigma_a = M / W
% Амплитуда нормальных напряжений изгиба
reducer(9).sigma_a = (reducer(9).Mbx * 1000) / reducer(9).W_shaft; % МПа

% Коэффициенты концентрации напряжений и запаса прочности (из методички для стали 40Х)
% Пределы выносливости
reducer(9).sigma_minus1 = 410; % МПа (для изгиба)
reducer(9).tau_minus1 = 240; % МПа (для кручения)

reducer(9).K_sigma_D = 4.45; 
reducer(9).K_tau_D = 3.15;

% Пределы выносливости
reducer(9).sigma_D = reducer(9).sigma_minus1 / (reducer(9).K_sigma_D);
reducer(9).tau_D = reducer(9).tau_minus1 / (reducer(9).K_tau_D);

% Запасы прочности по нормальным и касательным напряжениям
reducer(9).S_sigma = reducer(9).sigma_minus1 / (reducer(9).K_sigma_D * reducer(9).sigma_a);
reducer(9).S_tau = reducer(9).tau_minus1 / (reducer(9).K_tau_D * reducer(9).tau_a);

% Общий запас прочности
reducer(9).S_shaft1 = (reducer(9).S_sigma * reducer(9).S_tau) / sqrt(reducer(9).S_sigma^2 + reducer(9).S_tau^2);
fprintf('  Общиц запас прочности: %.2f Нм\n', reducer(9).S_shaft1);

if reducer(9).S_shaft1 >= 2.5
    fprintf('  -> Прочность ведущего вала обеспечена (S >= 2.5)\n');
else
    fprintf('  -> Прочность ведущего вала НЕ обеспечена (S < 2.5)\n');
end

% Выбор подшипников ведущего вала (пример методички №210)
% Ищем подшипник с внутренним диаметром >= d1_verif
reducer(9).bear1_code = getBearingData(reducer(9).a_podsh_ind, "code");
reducer(9).bear1_d = getBearingData(reducer(9).a_podsh_ind, "d");
reducer(9).bear1_D = getBearingData(reducer(9).a_podsh_ind, "D");
reducer(9).bear1_B = getBearingData(reducer(9).a_podsh_ind, "B");
reducer(9).bear1_C = getBearingData(reducer(9).a_podsh_ind, "C"); % кН
fprintf('  Выбран подшипник ведущего вала: %s (d=%d, D=%d, B=%d, C=%.1f кН)\n', ...
    reducer(9).bear1_code, reducer(9).bear1_d, reducer(9).bear1_D, reducer(9).bear1_B, reducer(9).bear1_C);


% 16.2. Расчет ведомого вала (Тихоходный вал)
fprintf('\n16.2. Расчет ведомого вала:\n');

% Диаметр выходного участка (из п. 12)
reducer(8).d2_verif = reducer(8).d2; % мм (обычно 55 мм в примере)

% Нагрузки
reducer(8).T2_check = reducer(8).T2; % Нм
% Консольная нагрузка Fr (по ГОСТ 16162-78 или методичке)
% В методичке принято Fr = 4500 Н для большего диапазона использования
reducer(8).Fr_out = 200 * (reducer(8).T2_check)^(1/2); % Н; % Н
% Расстояние от середины шейки до опасного сечения (из эскиза)
reducer(8).c_out = 110; % мм

% Расчетные усилия в опасном сечении
reducer(8).M_bend_out = reducer(8).Fr_out * reducer(8).c_out * 1e-3; % Нм
reducer(8).M_eq_out = sqrt(reducer(8).M_bend_out^2 + reducer(8).T2_check^2); % Приведенный момент, Нм

% Проверка по статической прочности (упрощенно)
% sigma_eq = M_eq / (0.1 * d^3)
reducer(8).sigma_eq_out = (reducer(8).M_eq_out * 1000) / (0.1 * reducer(8).d2_verif^3); % МПа

% Допускаемое напряжение (предел усталостной прочности с учетом коэффициентов)
% В методичке рассчитано [sigma] = 89 МПа для стали 40Х
reducer(8).sigma_allow_out = 89; % МПа

fprintf('  Диаметр ведомого вала: %.1f мм\n', reducer(8).d2_verif);
fprintf('  Изгибающий момент: %.2f Нм\n', reducer(8).M_bend_out);
fprintf('  Крутящий момент: %.2f Нм\n', reducer(8).T2_check);
fprintf('  Приведенный момент: %.2f Нм\n', reducer(8).M_eq_out);
fprintf('  Эквивалентное напряжение: %.2f МПа\n', reducer(8).sigma_eq_out);
fprintf('  Допускаемое напряжение: %.2f МПа\n', reducer(8).sigma_allow_out);

if reducer(8).sigma_eq_out <= reducer(8).sigma_allow_out
    fprintf('  -> Прочность ведомого вала обеспечена\n');
else
    fprintf('  -> Прочность ведомого вала НЕ обеспечена\n');
end

% Выбор подшипников ведомого вала
% В методичке для d2=55 мм (посадочное отверстие подшипника может быть больше) 
% выбран подшипник №7000124 (d=105, D=160, B=18) - сверхлегкая серия, т.к. вал планетарный короткий и жесткий.
% Однако стандартный подбор обычно идет под диаметр вала. 
% Для примера методички запишем данные из текста.
reducer(8).bear2_code = '7000124';
reducer(8).bear2_d = 105; % мм (посадочный диаметр в корпусе водила/вала)
reducer(8).bear2_D = 160; % мм
reducer(8).bear2_B = 18; % мм
reducer(8).bear2_C = 52.0; % кН

fprintf('  Выбран подшипник ведомого вала: %s (d=%d, D=%d, B=%d, C=%.1f кН)\n', ...
    reducer(8).bear2_code, reducer(8).bear2_d, reducer(8).bear2_D, reducer(8).bear2_B, reducer(8).bear2_C);

fprintf('\n======= КОНЕЦ РАСЧЕТА ВАЛОВ =======\n');

% ======= ИТОГОВАЯ СВОДКА =======
fprintf('================================================================================\n');
fprintf('                           ИТОГОВАЯ СВОДКА ПАРАМЕТРОВ                          \n');
fprintf('================================================================================\n\n');

fprintf('Основные параметры редуктора:\n');
fprintf('  ┌─────────────────────────────────────────────────────────────────────────┐\n');
fprintf('  │ Параметр                          │ Значение          │ Ед. изм.      │\n');
fprintf('  ├─────────────────────────────────────────────────────────────────────────┤\n');
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(9).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(9).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(9).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(9).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(9).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(9).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(9).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(9).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(9).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(9).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(9).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(9).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(9).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(9).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(9).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(9).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(9).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(9).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(9).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(9).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(9).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(9).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(9).d_axis);
fprintf('  └─────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');



fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(8).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(8).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(8).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(8).u = semimotor(8).nmot / semimotor(8).nreq;
reducer(8).k = reducer(8).u - 1;
reducer(8).C = 3;
reducer(8).t = 5000;
reducer(8).na = semimotor(8).nmot;
reducer(8).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(8).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(8).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(8).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(8).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(8).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(8).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(8).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(8).k);
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
reducer(8).nah = semimotor(8).nmot - semimotor(8).nreq;
reducer(8).nbh = 0 - semimotor(8).nreq;
reducer(8).nch = -(semimotor(8).nmot - semimotor(8).nreq) * 2 / (reducer(8).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(8).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(8).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(8).nch);

% 4.4. Определение КПД редуктора
reducer(8).etarel = (1 + reducer(8).k * 0.99 * 0.97) / (1 + reducer(8).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(8).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(8).etamuf = 0.99;
reducer(8).eta = reducer(8).etarel * reducer(8).etamuf;
reducer(8).Ndvig = semimotor(8).N / reducer(8).eta;
reducer(8).N1 = reducer(8).Ndvig * reducer(8).etamuf;
reducer(8).T1 = 9.550 * reducer(8).N1 / semimotor(8).nmot;
reducer(8).Ta = reducer(8).T1;
reducer(8).N2 = reducer(8).Ndvig * reducer(8).etarel;
reducer(8).T2 = 9.550 * reducer(8).N2 / semimotor(8).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(8).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(8).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(8).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(8).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(8).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(8).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(8).HBg = 290;
reducer(8).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(8).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(8).HBw);

% 6.2. Определение допускаемых напряжений
reducer(8).NHO1 = 24 * 10^6;
reducer(8).NHO2 = 21 * 10^6;
reducer(8).NFO1 = 4 * 10^6;
reducer(8).NFO2 = 4 * 10^6;

reducer(8).t1 = 0.3 * reducer(8).t;
reducer(8).t2 = 0.3 * reducer(8).t;
reducer(8).t3 = 0.4 * reducer(8).t;
reducer(8).mode = [1, 0.6, 0.3];
reducer(8).tHE = 0;

for i = 1:3
    reducer(8).tHE = reducer(8).tHE + reducer(8).t1 * reducer(8).mode(i)^3;
end

reducer(8).NHE2 = abs(60 * reducer(8).nch * reducer(8).tHE);
reducer(8).NHE1 = 60 * reducer(8).nah * reducer(8).C * reducer(8).tHE;

reducer(8).KHL1 = (reducer(8).NHO1 / reducer(8).NHE1)^(1/6);
if reducer(8).KHL1 < 1
    reducer(8).KHL1 = 1;
end
reducer(8).KHL2 = (reducer(8).NHO2 / reducer(8).NHE2)^(1/6);
if reducer(8).KHL2 < 1
    reducer(8).KHL2 = 1;
end

reducer(8).KFL1 = 1;
reducer(8).KFL2 = 1;

reducer(8).sigmaHO1 = 2 * reducer(8).HBg + 70;
reducer(8).sigmaHO2 = 2 * reducer(8).HBw + 70;
reducer(8).sigmaFO1 = 1.8 * reducer(8).HBg;
reducer(8).sigmaFO2 = 1.8 * reducer(8).HBw;

reducer(8).SH1 = 1.1;
reducer(8).SH2 = 1.1;
reducer(8).SF1 = 1.75;
reducer(8).SF2 = 1.75;
reducer(8).sigmaH1 = reducer(8).sigmaHO1 / reducer(8).SH1 * reducer(8).KHL1;
reducer(8).sigmaH2 = reducer(8).sigmaHO2 / reducer(8).SH2 * reducer(8).KHL2;
reducer(8).sigmaF1 = reducer(8).sigmaFO1 / reducer(8).SF1 * reducer(8).KFL1;
reducer(8).sigmaF2 = reducer(8).sigmaFO2 / reducer(8).SF2 * reducer(8).KFL2;
reducer(8).sigmaH = min(reducer(8).sigmaH1, reducer(8).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(8).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(8).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(8).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(8).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(8).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(8).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(8).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(8).KHL1, reducer(8).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(8).KFL1, reducer(8).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(8).sigmaHO1, reducer(8).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(8).sigmaFO1, reducer(8).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(8).SH1, reducer(8).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(8).SF1, reducer(8).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(8).sigmaH1, reducer(8).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(8).sigmaF1, reducer(8).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(8).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(8).Kd = 780;
reducer(8).psibd = 0.6;
reducer(8).uHaC = (reducer(8).k - 1)/2;
reducer(8).uHcb = abs(reducer(8).nch / reducer(8).nbh);
reducer(8).Kc = 1.1;

reducer(8).Khbetta = get_Khbetta_Kfbetta(reducer(8).psibd, reducer(8).HBg, reducer(8).HBw, 'VI', 'KH');
reducer(8).Tap = reducer(8).Ta * reducer(8).Khbetta * reducer(8).Kc / reducer(8).C;
reducer(8).da = reducer(8).Kd * ((reducer(8).Tap * (reducer(8).uHaC + 1)) / ...
    (reducer(8).psibd * (reducer(8).sigmaH ^ 2) * reducer(8).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(8).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(8).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(8).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(8).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(8).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(8).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(8).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(8).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(8).za;
arrraay_of_m = zeros(1, 5);
reducer(8).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(8).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(8).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(8).m > arrraay_of_m(i)
        reducer(8).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(8).za = T2{1, the_chosen_m_ind};
reducer(8).m = T2{3, the_chosen_m_ind};
reducer(8).da = reducer(8).m * reducer(8).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(8).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(8).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(8).da);

% Параметры остальных колес
reducer(8).zb = col3(the_chosen_m_ind);
reducer(8).zc = col7(the_chosen_m_ind);
reducer(8).db = reducer(8).m * reducer(8).zb;
reducer(8).dc = reducer(8).m * reducer(8).zc;

reducer(8).bc = reducer(8).psibd * reducer(8).da;
reducer(8).ba = reducer(8).bc + 4;
reducer(8).bb = reducer(8).bc + 4;

reducer(8).V = pi * reducer(8).da * reducer(8).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(8).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(8).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(8).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(8).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(8).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(8).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(8).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(8).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(8).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(8).V);
reducer(8).aw = (reducer(8).da + reducer(8).dc) / 2;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(8).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(8).Zm = 275;
reducer(8).Zh = 1.76;
reducer(8).epsilona = 1.88 - 3.2 * (1 / reducer(8).za + 1 / reducer(8).zc);
reducer(8).Ze = sqrt((4 - reducer(8).epsilona) / 3);

[reducer(8).grade, desc] = getAccuracyGrade(reducer(8).V, 'cylindrical');
[reducer(8).Kha, reducer(8).Kfa] = get_K_Ha_K_Fa(reducer(8).V, reducer(8).grade);
[reducer(8).Khv, reducer(8).Kfv] = getDynamicCoefficients(reducer(8).V, reducer(8).grade, 'a', 'straight');
reducer(8).Khc = 1.1;

reducer(8).sigmah = reducer(8).Zm * reducer(8).Zh * reducer(8).Ze * ...
    sqrt((2 * reducer(8).Tap * reducer(8).Khbetta * reducer(8).Khv * reducer(8).Kha * ...
    (reducer(8).uHaC + 1) * 1000) / (reducer(8).bb * reducer(8).da ^ 2 * ...
    reducer(8).uHaC * reducer(8).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(8).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(8).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(8).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(8).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(8).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(8).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(8).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(8).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(8).sigmaH);

if reducer(8).sigmah <= reducer(8).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(8).Kfbetta = get_Khbetta_Kfbetta(reducer(8).psibd, reducer(8).HBg, reducer(8).HBw, 'V', 'KF');
reducer(8).YF1 = get_YF(reducer(8).za, 0);
reducer(8).YF2 = get_YF(reducer(8).zc, 0);
reducer(8).Ke = 0.92;
reducer(8).mt = reducer(8).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(8).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(8).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(8).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(8).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(8).mt);

if reducer(8).sigmaF1 / reducer(8).YF1 > reducer(8).sigmaF2 / reducer(8).YF2
    reducer(8).sigmaFC = reducer(8).YF2 * (2 * reducer(8).Tap * reducer(8).Kfbetta * ...
        reducer(8).Kfv * reducer(8).Kfa * reducer(8).Kc * 1000) / ...
        (reducer(8).C * reducer(8).Ke * reducer(8).ba * reducer(8).epsilona * ...
        reducer(8).da * reducer(8).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(8).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(8).sigmaF2);
    
    if reducer(8).sigmaFC <= reducer(8).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(8).sigmaFC = reducer(8).YF1 * (2 * reducer(8).Tap * reducer(8).Kfbetta * ...
        reducer(8).Kfv * reducer(8).Kfa * reducer(8).Kc * 1000) / ...
        (reducer(8).C * reducer(8).Ke * reducer(8).ba * reducer(8).epsilona * ...
        reducer(8).da * reducer(8).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(8).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(8).sigmaF1);
    
    if reducer(8).sigmaFC <= reducer(8).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(8).Vc = abs(pi * reducer(8).dc * reducer(8).nch / 60000);
reducer(8).epsilona_e = 1.88 - 3.2 * (1 / reducer(8).zc - 1 / reducer(8).zb);
reducer(8).Ze_e = sqrt((4 - reducer(8).epsilona_e) / 3);
reducer(8).Tb = 2 * reducer(8).T2 * reducer(8).Khbetta * reducer(8).Kc / reducer(8).C;

[reducer(8).grade_e, desc_e] = getAccuracyGrade(reducer(8).Vc, 'cylindrical');
[reducer(8).Kha_e, reducer(8).Kfa_e] = get_K_Ha_K_Fa(reducer(8).Vc, reducer(8).grade_e);
[reducer(8).Khv_e, reducer(8).Kfv_e] = getDynamicCoefficients(reducer(8).Vc, reducer(8).grade_e, 'a', 'straight');
reducer(8).uCb = reducer(8).zb / reducer(8).zc;

reducer(8).sigmah_e = reducer(8).Zm * reducer(8).Zh * reducer(8).Ze_e * ...
    sqrt((2 * reducer(8).Tb * reducer(8).Khbetta * reducer(8).Khv_e * reducer(8).Kha * ...
    reducer(8).Kc * (reducer(8).uHcb - 1) * 1000) / (reducer(8).C * reducer(8).bb * ...
    reducer(8).dc * reducer(8).db * reducer(8).uCb));

reducer(8).sigmah0_e = reducer(8).sigmah_e / reducer(8).KHL2 * reducer(8).SH2;
reducer(8).HB_e = (reducer(8).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(8).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(8).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(8).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(8).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(8).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(8).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(8).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(8).overload = 2;
reducer(8).sigmah_max = 2 * reducer(8).sigmah * sqrt(reducer(8).overload);
reducer(8).sigmaf_max = 2 * reducer(8).sigmaFC * reducer(8).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(8).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(8).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(8).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(8).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(8).sigmaHO2);

if (reducer(8).sigmah_max <= 2.8 * reducer(8).sigmaHO1) && ...
   (reducer(8).sigmaf_max <= 0.8 * reducer(8).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(8).tau = 15;
reducer(8).d1 = ((reducer(8).T1 * 1000) / (0.2 * reducer(8).tau)) ^ (1/3);
reducer(8).d1 = floor(reducer(8).d1);
%reducer(8).d1 = 40;
reducer(8).d2 = ((reducer(8).T2 * 1000) / (0.2 * reducer(8).tau)) ^ (1/3);
reducer(8).d2 = floor(reducer(8).d2);
reducer(8).aw = (reducer(8).da + reducer(8).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(8).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(8).T1 * 1000) / (0.2 * reducer(8).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(8).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(8).T2 * 1000) / (0.2 * reducer(8).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(8).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(8).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(8).Fa = (2 * reducer(8).T1 * 1000 * reducer(8).Kc) / (reducer(8).da * reducer(8).C);
reducer(8).Fn = 2 * reducer(8).Fa;
reducer(8).l = 33;
reducer(8).q = reducer(8).Fn / reducer(8).l;
reducer(8).M_bend = reducer(8).q * reducer(8).l ^ 2 / 8;
reducer(8).sigma_axis = 120;
reducer(8).d_axis = 0.5 * floor(2 * ((32 * reducer(8).M_bend) / (pi * reducer(8).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(8).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(8).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(8).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(8).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(8).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(8).d_axis);

%=======15.ВЫБОР_ПОДШИПНИКОВ_САТЕЛИТОВ=======

% Подшипники воспринимают только радиальную нагрузку
reducer(8).Frmax = reducer(8).Fn;
reducer(8).V_podsh = 1.2; %  коэффициент вращения кольца (вращение наружного кольца подшипника)
reducer(8).Ksigma_podsh = 1.3; % оэффициент безопасности
reducer(8).KT_podsh = 1; % 1 – температурный коэффициент в случае, когда температура деталей t = 70÷125°C
reducer(8).KN_podsh = 1; % коэффициент режима работы, учитывающий переменность нагрузки
% !!! ЧЕКНУТЬ ГОСТ
reducer(8).Pe_podsh = reducer(8).V_podsh * reducer(8).Frmax * reducer(8).Ksigma_podsh * ...
    reducer(8).KT_podsh * reducer(8).KN_podsh; % эквивалентная нагрузка на подшипник

reducer(8).Lh_podsh = 0;
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(8).Lh_podsh <= reducer(8).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "B") <= reducer(8).bc
        reducer(8).Lh_podsh = (getBearingData(ind, "C") * 1000 / reducer(8).Pe_podsh)^3 * ...
            1000000 / (60 * abs(reducer(8).nch));        
        if reducer(8).Lh_podsh >= reducer(8).t
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
reducer(8).c_podsh_ind = 0;
if getBearingData(ind1, "B") < getBearingData(ind2, "B")
    reducer(8).c_podsh_ind = ind1;
else
    reducer(8).c_podsh_ind = ind2;
end

% Выбранный подшипник
fprintf(getBearingData(reducer(8).c_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(8).c_podsh_ind, "C") * 1000 /...
    reducer(8).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(8).nch)));
fprintf("Диаметр оси сателлита: %.3f\n", getBearingData(reducer(8).c_podsh_ind, "d"))

%=======16.ПРОВЕРОЧНЫЙ_РАСЧЕТ_ВАЛОВ=======

% 16.1. Расчет ведущего вала (Быстроходный вал)
% Примечание: Размеры a, b, c берутся из эскизного проекта (п. 13).
% В данном коде используем значения из примера методички для демонстрации расчета.

fprintf('\n======= 16. ПРОВЕРОЧНЫЙ РАСЧЕТ ВАЛОВ =======\n');
fprintf('16.1. Расчет ведущего вала:\n');

% Геометрические размеры участков вала (из эскиза, пример методички)
reducer(8).a_shaft = 14; % мм
reducer(8).b_shaft = 17; % мм (расстояние между опорами)
reducer(8).c_shaft = 60; % мм (консольный участок под муфту)

% Силы, действующие на вал
% FM - консольная нагрузка от муфты
reducer(8).FM = 125 * (reducer(8).Ta)^(1/2); % Н
fprintf('  Консольная нагрузка от муфты: %.2f Нм\n', reducer(8).FM);
fprintf('  Радиальная нагрузка: %.2f Нм\n', reducer(8).Fn);

% Реакции опор (схема: две опоры, консольная нагрузка)
reducer(8).Rbx = (reducer(8).Fn * (reducer(8).b_shaft + reducer(8).a_shaft) +...
    reducer(8).FM * reducer(8).c_shaft) / reducer(8).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(8).Rbx);
reducer(8).Rcx = (reducer(8).Fn * reducer(8).a_shaft  +...
    reducer(8).FM * (reducer(8).b_shaft + reducer(8).c_shaft)) / reducer(8).b_shaft; % Н (из примера методички)
fprintf('  Реакции опор: %.2f Нм\n', reducer(8).Rcx);

% Изгибающие моменты в опасных сечениях
reducer(8).Mbx = reducer(8).Fn * reducer(8).a_shaft * 1e-3; % Нм (в сечении B)
reducer(8).Mcx = reducer(8).FM * reducer(8).c_shaft * 1e-3; % Нм (в сечении C, от муфты)
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(8).Mbx);
fprintf('  Изгибающие моменты в опасных сечениях: %.2f Нм\n', reducer(8).Mcx);

% Выбор подшипников ведущего вала (по конструктивным соображениям и диаметру)
reducer(8).d1_verif = reducer(8).d1 + 3; % мм (диаметр в опасном сечении)
fprintf('  Диаметр вала: %.2f мм\n', reducer(8).d1_verif);
ind = 1;
ind1 = 1;
ind2 = 35;
% reducer(8).Lh_podsh <= reducer(8).t
while ind < 57
    if ind == 58
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "d") == reducer(8).d1_verif
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
reducer(8).a_podsh_ind = 0;
if getBearingData(ind1, "B") <= getBearingData(ind2, "B")
    reducer(8).a_podsh_ind = ind1;
else
    reducer(8).a_podsh_ind = ind2;
end


fprintf(getBearingData(reducer(8).a_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(8).a_podsh_ind, "C") * 1000 /...
    reducer(8).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(8).nch)));
fprintf("Диаметр оси ведущего вала: %.3f\n", getBearingData(reducer(8).a_podsh_ind, "d"))

% Геометрические характеристики сечения
reducer(8).W_shaft = (pi * reducer(8).d1_verif^3) / 32; % мм^3 (момент сопротивления изгибу)
reducer(8).Wp_shaft = (pi * reducer(8).d1_verif^3) / 16; % мм^3 (момент сопротивления кручению)

% Напряжения (амплитудные), МПа
% tau_a = T / (2 * Wp)
%Амплитуда τa и среднее τm напряжение отнулевого цикла касательных напряжений от действия крутящего момента
reducer(8).tau_a = (reducer(8).Ta * 1000) / (2 * reducer(8).Wp_shaft); % МПа
reducer(8).tau_m = reducer(8).tau_a;
% sigma_a = M / W
% Амплитуда нормальных напряжений изгиба
reducer(8).sigma_a = (reducer(8).Mbx * 1000) / reducer(8).W_shaft; % МПа

% Коэффициенты концентрации напряжений и запаса прочности (из методички для стали 40Х)
% Пределы выносливости
reducer(8).sigma_minus1 = 410; % МПа (для изгиба)
reducer(8).tau_minus1 = 240; % МПа (для кручения)

reducer(8).K_sigma_D = 4.45; 
reducer(8).K_tau_D = 3.15;

% Пределы выносливости
reducer(8).sigma_D = reducer(8).sigma_minus1 / (reducer(8).K_sigma_D);
reducer(8).tau_D = reducer(8).tau_minus1 / (reducer(8).K_tau_D);

% Запасы прочности по нормальным и касательным напряжениям
reducer(8).S_sigma = reducer(8).sigma_minus1 / (reducer(8).K_sigma_D * reducer(8).sigma_a);
reducer(8).S_tau = reducer(8).tau_minus1 / (reducer(8).K_tau_D * reducer(8).tau_a);

% Общий запас прочности
reducer(8).S_shaft1 = (reducer(8).S_sigma * reducer(8).S_tau) / sqrt(reducer(8).S_sigma^2 + reducer(8).S_tau^2);
fprintf('  Общиц запас прочности: %.2f Нм\n', reducer(8).S_shaft1);

if reducer(8).S_shaft1 >= 2.5
    fprintf('  -> Прочность ведущего вала обеспечена (S >= 2.5)\n');
else
    fprintf('  -> Прочность ведущего вала НЕ обеспечена (S < 2.5)\n');
end

% Выбор подшипников ведущего вала (пример методички №210)
% Ищем подшипник с внутренним диаметром >= d1_verif
reducer(8).bear1_code = getBearingData(reducer(8).a_podsh_ind, "code");
reducer(8).bear1_d = getBearingData(reducer(8).a_podsh_ind, "d");
reducer(8).bear1_D = getBearingData(reducer(8).a_podsh_ind, "D");
reducer(8).bear1_B = getBearingData(reducer(8).a_podsh_ind, "B");
reducer(8).bear1_C = getBearingData(reducer(8).a_podsh_ind, "C"); % кН
fprintf('  Выбран подшипник ведущего вала: %s (d=%d, D=%d, B=%d, C=%.1f кН)\n', ...
    reducer(8).bear1_code, reducer(8).bear1_d, reducer(8).bear1_D, reducer(8).bear1_B, reducer(8).bear1_C);



% ========================================================================
% 16.2. Расчет ведомого вала (Тихоходный вал / Водило)
% ========================================================================
fprintf('\n--------------------------------------------------\n');
fprintf('16.2. РАСЧЕТ ВЕДОМОГО ВАЛА (ТИХОХОДНЫЙ ВАЛ)\n');
fprintf('--------------------------------------------------\n');

% 1. Исходные данные из предыдущих расчетов
reducer(8).d2_nom = reducer(8).d2; % Диаметр выходного конца вала (из п.12), обычно ~55 мм
reducer(8).T2_val = reducer(8).T2; % Крутящий момент на ведомом валу, Н*м

% 2. Определение нагрузок
% Консольная нагрузка Fr приложена в середине шейки выходного конца вала.
% По методичке (стр. 34): Fr = (125...200) * sqrt(T2). 
% Принимаем коэффициент 200 для более жестких условий (как в примере методички).
k_consol = 200; 
reducer(8).Fr_out = k_consol * sqrt(reducer(8).T2_val); % Н

fprintf('  Крутящий момент на валу (T2):      %.2f Н*м\n', reducer(8).T2_val);
fprintf('  Консольная радиальная сила (Fr):   %.2f Н (коэфф. %d)\n', reducer(8).Fr_out, k_consol);

% 3. Геометрические параметры (из эскизного проекта)
% Расстояние от середины шейки вала (точка приложения Fr) до опасного сечения
% (место перехода диаметра или установка подшипника в водиле).
% В методичке принято c = 110 мм.
reducer(8).c_out_shaft = 25; % мм 

fprintf('  Плечо консоли (c):                 %d мм\n', reducer(8).c_out_shaft);

% 4. Расчет внутренних усилий в опасном сечении
% Изгибающий момент: Mизг = Fr * c
reducer(8).M_bend_out = reducer(8).Fr_out * reducer(8).c_out_shaft * 1e-3; % Перевод в Н*м

% Крутящий момент постоянный по длине вала
reducer(8).T_out_check = reducer(8).T2_val;

% Приведенный момент (по теории наибольших касательных напряжений):
% Mпр = sqrt(Mизг^2 + T^2)
reducer(8).M_eq_out = sqrt(reducer(8).M_bend_out^2 + reducer(8).T_out_check^2);

fprintf('  Изгибающий момент (Mизг):          %.2f Н*м\n', reducer(8).M_bend_out);
fprintf('  Приведенный момент (Mпр):          %.2f Н*м\n', reducer(8).M_eq_out);

% 5. Проверка прочности вала
% Допускаемое напряжение на изгиб [σ]изг.
% В методичке (стр. 35) для стали 40Х с учетом коэффициентов концентрации, 
% масштаба и запаса прочности (S=1.8) принято [σ] = 89 МПа.
reducer(8).sigma_allow_out = 89; % МПа

% Эквивалентное напряжение в валу: σпр = Mпр / (0.1 * d^3)
% Проверяем для диаметра, принятого в п.12 (reducer(8).d2_nom)
d_check = reducer(8).d2_nom; 
if d_check == 0
    d_check = 55; % Защита от деления на ноль, если p.12 не отработал
end

reducer(8).sigma_eq_out = (reducer(8).M_eq_out * 1000) / (0.1 * d_check^3); % МПа (момент в Н*м -> Н*мм)

fprintf('  Расчетный диаметр вала (d2):       %.1f мм\n', d_check);
fprintf('  Эквивалентное напряжение (σпр):    %.2f МПа\n', reducer(8).sigma_eq_out);
fprintf('  Допускаемое напряжение ([σ]):      %.2f МПа\n', reducer(8).sigma_allow_out);

if reducer(8).sigma_eq_out <= reducer(8).sigma_allow_out
    fprintf('  >>> ПРОЧНОСТЬ ВЕДОМОГО ВАЛА ОБЕСПЕЧЕНА <<<\n');
    reducer(8).shaft2_ok = true;
else
    fprintf('  >>> ПРОЧНОСТЬ ВЕДОМОГО ВАЛА НЕ ОБЕСПЕЧЕНА <<<\n');
    fprintf('  Требуется увеличить диаметр вала.\n');
    reducer(8).shaft2_ok = false;
    
    % Расчет требуемого диаметра (опционально)
    d_req = ((reducer(8).M_eq_out * 1000) / (0.1 * reducer(8).sigma_allow_out))^(1/3);
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
target_d = reducer(8).d2_nom; 

% Если диаметр маленький (например, < 30), а момент большой, возможно потребуется серия тяжелее.
% Используем ту же функцию поиска, что и в п. 15 и 16.1
reducer(8).Lh_podsh2 = 0;
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
        Fr_bear = reducer(8).Fr_out; 
        
        Pe2 = 1.2 * Fr_bear * 1.3; % V=1.2 (кольцо вращается?), Ksigma=1.3. Уточните V для водила.
        % Для водила наружное кольцо подшипника вращается вместе с водилом относительно нагрузки? 
        % Нет, нагрузка от корпуса неподвижна, водило вращается -> вращается внутреннее кольцо (если оно на валу)
        % В планетарке водило - это вал. Подшипник стоит в корпусе. 
        %-> Вращается внутреннее кольцо (посажен на водило). Значит V=1.
        
        Pe2 = 1.0 * Fr_bear * 1.3; % V=1, Ksigma=1.3
        
        C_val = getBearingData(ind, "C") * 1000; % Перевод кН в Н
        
        % Обороты ведомого вала
        n_out = semimotor(9).nreq; 
        
        if n_out > 0
            Lh_temp = (C_val / Pe2)^3 * 1000000 / (60 * n_out);
        else
            Lh_temp = 0;
        end
        
        if Lh_temp >= reducer(8).t
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
if reducer(8).Lh_podsh2 == 0 % Если цикл не заполнил переменную глобально, посчитаем для выбранных
     % Просто выберем ind2 (средняя серия) как более надежный для выходного вала, 
     % если он был найден, иначе ind1.
     if ind2 > 34 
         reducer(8).b_podsh_ind = ind2;
     else
         reducer(8).b_podsh_ind = ind1;
     end
else
     reducer(8).b_podsh_ind = ind2; % По умолчанию берем среднюю серию для надежности
end

% Вывод результатов по подшипнику
bear_code = getBearingData(reducer(8).b_podsh_ind, "code");
bear_d = getBearingData(reducer(8).b_podsh_ind, "d");
bear_D = getBearingData(reducer(8).b_podsh_ind, "D");
bear_B = getBearingData(reducer(8).b_podsh_ind, "B");
bear_C = getBearingData(reducer(8).b_podsh_ind, "C");

% Пересчет точной долговечности для выбранного
C_sel = bear_C * 1000;
Pe_sel = 1.0 * reducer(8).Fr_out * 1.3;
n_out = semimotor(9).nreq;
Lh_final = (C_sel / Pe_sel)^3 * 1000000 / (60 * n_out);

fprintf('  Выбран подшипник: %s\n', bear_code);
fprintf('  Размеры (d x D x B): %d x %d x %d мм\n', bear_d, bear_D, bear_B);
fprintf('  Динамическая грузоподъемность (C): %.1f кН\n', bear_C);
fprintf('  Расчетная долговечность (Lh): %.0f часов (требуется %d)\n', Lh_final, reducer(8).t);

if Lh_final >= reducer(8).t
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
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(8).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(8).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(8).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(8).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(8).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(8).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(8).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(8).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(8).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(8).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(8).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(8).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(8).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(8).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(8).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(8).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(8).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(8).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(8).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(8).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(8).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(8).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(8).d_axis);
fprintf('  └─────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');


%% Расчет массы всего редктора

reducer2_ro = 7.8 * 10^3;
gear2_mass = (reducer2_ro * pi / 4 * (0.3 * reducer(8).ba *  reducer(8).da^2 + ...
              0.5 * reducer(8).C * reducer(8).bc * reducer(8).dc^2)/ 10^9) + ...
              (reducer2_ro * pi / 4 * (0.3 * reducer(9).ba *  reducer(9).da^2 + ...
              0.5 * reducer(9).C * reducer(9).bc * reducer(9).dc^2)/ 10^9) + ...
              (reducer2_ro * pi / 4 * (0.3 * reducer(10).ba *  reducer(10).da^2 + ...
              0.5 * reducer(10).C * reducer(10).bc * reducer(10).dc^2)/ 10^9);
reducer2_mass = (1.5 + 1) * gear2_mass;
total2_mass = (0.35 + 1) * reducer2_mass;

fprintf('  │ Массы шестерен (gear_mass)        │ %15.3f │ кг            │\n', gear2_mass);
fprintf('  │ Массы редуктора (reducer_mass)    │ %15.3f │ кг            │\n', reducer2_mass);
fprintf('  │ Общее передаточное отношение      │ %15.3f │               │\n',  (reducer(8).db /  reducer(8).da + 1) ^ 3);
fprintf('  │ Общая масса привода (total2_mass) │ %15.3f │ кг            │\n',  total2_mass);



fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');