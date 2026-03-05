clc

fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(7).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(7).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(7).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(7).u = semimotor(7).nmot / semimotor(7).nreq;
reducer(7).k = reducer(7).u - 1;
reducer(7).C = 3;
reducer(7).t = 5000;
reducer(7).na = semimotor(7).nmot;
reducer(7).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(7).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(7).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(7).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(7).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(7).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(7).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(7).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(7).k);
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
reducer(7).nah = semimotor(7).nmot - semimotor(7).nreq;
reducer(7).nbh = 0 - semimotor(7).nreq;
reducer(7).nch = -(semimotor(7).nmot - semimotor(7).nreq) * 2 / (reducer(7).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(7).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(7).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(7).nch);

% 4.4. Определение КПД редуктора
reducer(7).etarel = (1 + reducer(7).k * 0.99 * 0.97) / (1 + reducer(7).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(7).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(7).etamuf = 0.99;
reducer(7).eta = reducer(7).etarel * reducer(7).etamuf;
reducer(7).Ndvig = semimotor(7).N / reducer(7).eta;
reducer(7).N1 = reducer(7).Ndvig * reducer(7).etamuf;
reducer(7).T1 = 9.550 * reducer(7).N1 / semimotor(7).nmot;
reducer(7).Ta = reducer(7).T1;
reducer(7).N2 = reducer(7).Ndvig * reducer(7).etarel;
reducer(7).T2 = 9.550 * reducer(7).N2 / semimotor(7).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(7).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(7).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(7).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(7).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(7).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(7).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(7).HBg = 290;
reducer(7).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(7).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(7).HBw);

% 6.2. Определение допускаемых напряжений
reducer(7).NHO1 = 24 * 10^6;
reducer(7).NHO2 = 21 * 10^6;
reducer(7).NFO1 = 4 * 10^6;
reducer(7).NFO2 = 4 * 10^6;

reducer(7).t1 = 0.3 * reducer(7).t;
reducer(7).t2 = 0.3 * reducer(7).t;
reducer(7).t3 = 0.4 * reducer(7).t;
reducer(7).mode = [1, 0.6, 0.3];
reducer(7).tHE = 0;

for i = 1:3
    reducer(7).tHE = reducer(7).tHE + reducer(7).t1 * reducer(7).mode(i)^3;
end

reducer(7).NHE2 = abs(60 * reducer(7).nch * reducer(7).tHE);
reducer(7).NHE1 = 60 * reducer(7).nah * reducer(7).C * reducer(7).tHE;

reducer(7).KHL1 = (reducer(7).NHO1 / reducer(7).NHE1)^(1/6);
if reducer(7).KHL1 < 1
    reducer(7).KHL1 = 1;
end
reducer(7).KHL2 = (reducer(7).NHO2 / reducer(7).NHE2)^(1/6);
if reducer(7).KHL2 < 1
    reducer(7).KHL2 = 1;
end

reducer(7).KFL1 = 1;
reducer(7).KFL2 = 1;

reducer(7).sigmaHO1 = 2 * reducer(7).HBg + 70;
reducer(7).sigmaHO2 = 2 * reducer(7).HBw + 70;
reducer(7).sigmaFO1 = 1.8 * reducer(7).HBg;
reducer(7).sigmaFO2 = 1.8 * reducer(7).HBw;

reducer(7).SH1 = 1.1;
reducer(7).SH2 = 1.1;
reducer(7).SF1 = 1.75;
reducer(7).SF2 = 1.75;
reducer(7).sigmaH1 = reducer(7).sigmaHO1 / reducer(7).SH1 * reducer(7).KHL1;
reducer(7).sigmaH2 = reducer(7).sigmaHO2 / reducer(7).SH2 * reducer(7).KHL2;
reducer(7).sigmaF1 = reducer(7).sigmaFO1 / reducer(7).SF1 * reducer(7).KFL1;
reducer(7).sigmaF2 = reducer(7).sigmaFO2 / reducer(7).SF2 * reducer(7).KFL2;
reducer(7).sigmaH = min(reducer(7).sigmaH1, reducer(7).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(7).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(7).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(7).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(7).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(7).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(7).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(7).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(7).KHL1, reducer(7).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(7).KFL1, reducer(7).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(7).sigmaHO1, reducer(7).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(7).sigmaFO1, reducer(7).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(7).SH1, reducer(7).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(7).SF1, reducer(7).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(7).sigmaH1, reducer(7).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(7).sigmaF1, reducer(7).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(7).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(7).Kd = 780;
reducer(7).psibd = 0.6;
reducer(7).uHaC = (reducer(7).k - 1)/2;
reducer(7).uHcb = abs(reducer(7).nch / reducer(7).nbh);
reducer(7).Kc = 1.1;

reducer(7).Khbetta = get_Khbetta_Kfbetta(reducer(7).psibd, reducer(7).HBg, reducer(7).HBw, 'VI', 'KH');
reducer(7).Tap = reducer(7).Ta * reducer(7).Khbetta * reducer(7).Kc / reducer(7).C;
reducer(7).da = reducer(7).Kd * ((reducer(7).Tap * (reducer(7).uHaC + 1)) / ...
    (reducer(7).psibd * (reducer(7).sigmaH ^ 2) * reducer(7).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(7).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(7).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(7).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(7).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(7).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(7).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(7).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(7).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(7).za;
arrraay_of_m = zeros(1, 5);
reducer(7).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(7).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(7).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(7).m > arrraay_of_m(i)
        reducer(7).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(7).za = T2{1, the_chosen_m_ind};
reducer(7).m = T2{3, the_chosen_m_ind};
reducer(7).da = reducer(7).m * reducer(7).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(7).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(7).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(7).da);

% Параметры остальных колес
reducer(7).zb = col3(the_chosen_m_ind);
reducer(7).zc = col7(the_chosen_m_ind);
reducer(7).db = reducer(7).m * reducer(7).zb;
reducer(7).dc = reducer(7).m * reducer(7).zc;

reducer(7).bb = reducer(7).psibd * reducer(7).da;
reducer(7).ba = reducer(7).bb + 4;
reducer(7).bc = reducer(7).bb + 4;

reducer(7).V = pi * reducer(7).da * reducer(7).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(7).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(7).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(7).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(7).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(7).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(7).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(7).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(7).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(7).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(7).V);
reducer(7).aw = (reducer(7).da + reducer(7).dc) / 2;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(7).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(7).Zm = 275;
reducer(7).Zh = 1.76;
reducer(7).epsilona = 1.88 - 3.2 * (1 / reducer(7).za + 1 / reducer(7).zc);
reducer(7).Ze = sqrt((4 - reducer(7).epsilona) / 3);

[reducer(7).grade, desc] = getAccuracyGrade(reducer(7).V, 'cylindrical');
[reducer(7).Kha, reducer(7).Kfa] = get_K_Ha_K_Fa(reducer(7).V, reducer(7).grade);
[reducer(7).Khv, reducer(7).Kfv] = getDynamicCoefficients(reducer(7).V, reducer(7).grade, 'a', 'straight');
reducer(7).Khc = 1.1;

reducer(7).sigmah = reducer(7).Zm * reducer(7).Zh * reducer(7).Ze * ...
    sqrt((2 * reducer(7).Tap * reducer(7).Khbetta * reducer(7).Khv * reducer(7).Kha * ...
    (reducer(7).uHaC + 1) * 1000) / (reducer(7).bb * reducer(7).da ^ 2 * ...
    reducer(7).uHaC * reducer(7).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(7).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(7).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(7).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(7).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(7).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(7).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(7).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(7).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(7).sigmaH);

if reducer(7).sigmah <= reducer(7).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(7).Kfbetta = get_Khbetta_Kfbetta(reducer(7).psibd, reducer(7).HBg, reducer(7).HBw, 'V', 'KF');
reducer(7).YF1 = get_YF(reducer(7).za, 0);
reducer(7).YF2 = get_YF(reducer(7).zc, 0);
reducer(7).Ke = 0.92;
reducer(7).mt = reducer(7).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(7).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(7).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(7).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(7).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(7).mt);

if reducer(7).sigmaF1 / reducer(7).YF1 > reducer(7).sigmaF2 / reducer(7).YF2
    reducer(7).sigmaFC = reducer(7).YF2 * (2 * reducer(7).Tap * reducer(7).Kfbetta * ...
        reducer(7).Kfv * reducer(7).Kfa * reducer(7).Kc * 1000) / ...
        (reducer(7).C * reducer(7).Ke * reducer(7).ba * reducer(7).epsilona * ...
        reducer(7).da * reducer(7).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(7).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(7).sigmaF2);
    
    if reducer(7).sigmaFC <= reducer(7).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(7).sigmaFC = reducer(7).YF1 * (2 * reducer(7).Tap * reducer(7).Kfbetta * ...
        reducer(7).Kfv * reducer(7).Kfa * reducer(7).Kc * 1000) / ...
        (reducer(7).C * reducer(7).Ke * reducer(7).ba * reducer(7).epsilona * ...
        reducer(7).da * reducer(7).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(7).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(7).sigmaF1);
    
    if reducer(7).sigmaFC <= reducer(7).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(7).Vc = abs(pi * reducer(7).dc * reducer(7).nch / 60000);
reducer(7).epsilona_e = 1.88 - 3.2 * (1 / reducer(7).zc - 1 / reducer(7).zb);
reducer(7).Ze_e = sqrt((4 - reducer(7).epsilona_e) / 3);
reducer(7).Tb = 2 * reducer(7).T2 * reducer(7).Khbetta * reducer(7).Kc / reducer(7).C;

[reducer(7).grade_e, desc_e] = getAccuracyGrade(reducer(7).Vc, 'cylindrical');
[reducer(7).Kha_e, reducer(7).Kfa_e] = get_K_Ha_K_Fa(reducer(7).Vc, reducer(7).grade_e);
[reducer(7).Khv_e, reducer(7).Kfv_e] = getDynamicCoefficients(reducer(7).Vc, reducer(7).grade_e, 'a', 'straight');
reducer(7).uCb = reducer(7).zb / reducer(7).zc;

reducer(7).sigmah_e = reducer(7).Zm * reducer(7).Zh * reducer(7).Ze_e * ...
    sqrt((2 * reducer(7).Tb * reducer(7).Khbetta * reducer(7).Khv_e * reducer(7).Kha * ...
    reducer(7).Kc * (reducer(7).uHcb - 1) * 1000) / (reducer(7).C * reducer(7).bb * ...
    reducer(7).dc * reducer(7).db * reducer(7).uCb));

reducer(7).sigmah0_e = reducer(7).sigmah_e / reducer(7).KHL2 * reducer(7).SH2;
reducer(7).HB_e = (reducer(7).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(7).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(7).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(7).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(7).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(7).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(7).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(7).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(7).overload = 2;
reducer(7).sigmah_max = 2 * reducer(7).sigmah * sqrt(reducer(7).overload);
reducer(7).sigmaf_max = 2 * reducer(7).sigmaFC * reducer(7).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(7).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(7).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(7).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(7).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(7).sigmaHO2);

if (reducer(7).sigmah_max <= 2.8 * reducer(7).sigmaHO1) && ...
   (reducer(7).sigmaf_max <= 0.8 * reducer(7).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(7).tau = 15;
reducer(7).d1 = ((reducer(7).T1 * 1000) / (0.2 * reducer(7).tau)) ^ (1/3);
reducer(7).d1 = floor(reducer(7).d1);
reducer(7).d1 = 40;
reducer(7).d2 = ((reducer(7).T2 * 1000) / (0.2 * reducer(7).tau)) ^ (1/3);
reducer(7).d2 = floor(reducer(7).d2);
reducer(7).aw = (reducer(7).da + reducer(7).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(7).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(7).T1 * 1000) / (0.2 * reducer(7).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(7).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(7).T2 * 1000) / (0.2 * reducer(7).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(7).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(7).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(7).Fa = (2 * reducer(7).T1 * 1000 * reducer(7).Kc) / (reducer(7).da * reducer(7).C);
reducer(7).Fn = 2 * reducer(7).Fa;
reducer(7).l = 33;
reducer(7).q = reducer(7).Fn / reducer(7).l;
reducer(7).M_bend = reducer(7).q * reducer(7).l ^ 2 / 8;
reducer(7).sigma_axis = 120;
reducer(7).d_axis = 0.5 * floor(2 * ((32 * reducer(7).M_bend) / (pi * reducer(7).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(7).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(7).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(7).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(7).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(7).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(7).d_axis);

% ======= ИТОГОВАЯ СВОДКА =======
fprintf('================================================================================\n');
fprintf('                           ИТОГОВАЯ СВОДКА ПАРАМЕТРОВ                          \n');
fprintf('================================================================================\n\n');

fprintf('Основные параметры редуктора:\n');
fprintf('  ┌─────────────────────────────────────────────────────────────────────────┐\n');
fprintf('  │ Параметр                          │ Значение          │ Ед. изм.      │\n');
fprintf('  ├─────────────────────────────────────────────────────────────────────────┤\n');
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(7).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(7).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(7).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(7).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(7).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(7).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(7).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(7).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(7).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(7).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(7).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(7).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(7).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(7).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(7).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(7).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(7).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(7).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(7).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(7).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(7).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(7).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(7).d_axis);
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

reducer(8).bb = reducer(8).psibd * reducer(8).da;
reducer(8).ba = reducer(8).bb + 4;
reducer(8).bc = reducer(8).bb + 4;

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
reducer(8).d1 = 40;
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

reducer(9).bb = reducer(9).psibd * reducer(9).da;
reducer(9).ba = reducer(9).bb + 4;
reducer(9).bc = reducer(9).bb + 4;

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
reducer(9).d1 = 40;
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
reducer(9).l = 33;
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