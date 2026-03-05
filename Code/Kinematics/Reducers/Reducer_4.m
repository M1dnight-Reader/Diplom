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

reducer(10).bb = reducer(10).psibd * reducer(10).da;
reducer(10).ba = reducer(10).bb + 4;
reducer(10).bc = reducer(10).bb + 4;

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
reducer(10).d1 = 40;
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
reducer(10).l = 33;
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
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(11).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(11).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(11).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(11).u = semimotor(11).nmot / semimotor(11).nreq;
reducer(11).k = reducer(11).u - 1;
reducer(11).C = 3;
reducer(11).t = 5000;
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
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(11).etarel);

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

reducer(11).t1 = 0.3 * reducer(11).t;
reducer(11).t2 = 0.3 * reducer(11).t;
reducer(11).t3 = 0.4 * reducer(11).t;
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
reducer(11).psibd = 0.6;
reducer(11).uHaC = (reducer(11).k - 1)/2;
reducer(11).uHcb = abs(reducer(11).nch / reducer(11).nbh);
reducer(11).Kc = 1.1;

reducer(11).Khbetta = get_Khbetta_Kfbetta(reducer(11).psibd, reducer(11).HBg, reducer(11).HBw, 'VI', 'KH');
reducer(11).Tap = reducer(11).Ta * reducer(11).Khbetta * reducer(11).Kc / reducer(11).C;
reducer(11).da = reducer(11).Kd * ((reducer(11).Tap * (reducer(11).uHaC + 1)) / ...
    (reducer(11).psibd * (reducer(11).sigmaH ^ 2) * reducer(11).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(11).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(11).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(11).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(11).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(11).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(11).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(11).Tap);
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

reducer(11).za = T2{1, the_chosen_m_ind};
reducer(11).m = T2{3, the_chosen_m_ind};
reducer(11).da = reducer(11).m * reducer(11).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(11).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(11).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(11).da);

% Параметры остальных колес
reducer(11).zb = col3(the_chosen_m_ind);
reducer(11).zc = col7(the_chosen_m_ind);
reducer(11).db = reducer(11).m * reducer(11).zb;
reducer(11).dc = reducer(11).m * reducer(11).zc;

reducer(11).bb = reducer(11).psibd * reducer(11).da;
reducer(11).ba = reducer(11).bb + 4;
reducer(11).bc = reducer(11).bb + 4;

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
reducer(11).aw = (reducer(11).da + reducer(11).dc) / 2;
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
reducer(11).d1 = 40;
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
reducer(11).l = 33;
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
reducer(12).u = semimotor(12).nmot / semimotor(12).nreq;
reducer(12).k = reducer(12).u - 1;
reducer(12).C = 3;
reducer(12).t = 5000;
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
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(12).etarel);

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

reducer(12).t1 = 0.3 * reducer(12).t;
reducer(12).t2 = 0.3 * reducer(12).t;
reducer(12).t3 = 0.4 * reducer(12).t;
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
reducer(12).psibd = 0.6;
reducer(12).uHaC = (reducer(12).k - 1)/2;
reducer(12).uHcb = abs(reducer(12).nch / reducer(12).nbh);
reducer(12).Kc = 1.1;

reducer(12).Khbetta = get_Khbetta_Kfbetta(reducer(12).psibd, reducer(12).HBg, reducer(12).HBw, 'VI', 'KH');
reducer(12).Tap = reducer(12).Ta * reducer(12).Khbetta * reducer(12).Kc / reducer(12).C;
reducer(12).da = reducer(12).Kd * ((reducer(12).Tap * (reducer(12).uHaC + 1)) / ...
    (reducer(12).psibd * (reducer(12).sigmaH ^ 2) * reducer(12).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(12).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(12).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(12).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(12).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(12).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(12).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(12).Tap);
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

reducer(12).za = T2{1, the_chosen_m_ind};
reducer(12).m = T2{3, the_chosen_m_ind};
reducer(12).da = reducer(12).m * reducer(12).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(12).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(12).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(12).da);

% Параметры остальных колес
reducer(12).zb = col3(the_chosen_m_ind);
reducer(12).zc = col7(the_chosen_m_ind);
reducer(12).db = reducer(12).m * reducer(12).zb;
reducer(12).dc = reducer(12).m * reducer(12).zc;

reducer(12).bb = reducer(12).psibd * reducer(12).da;
reducer(12).ba = reducer(12).bb + 4;
reducer(12).bc = reducer(12).bb + 4;

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
reducer(12).aw = (reducer(12).da + reducer(12).dc) / 2;
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
reducer(12).d1 = 40;
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
reducer(12).l = 33;
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