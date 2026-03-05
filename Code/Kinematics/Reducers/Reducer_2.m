clc

fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(4).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(4).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(4).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(4).u = semimotor(4).nmot / semimotor(4).nreq;
reducer(4).k = reducer(4).u - 1;
reducer(4).C = 3;
reducer(4).t = 5000;
reducer(4).na = semimotor(4).nmot;
reducer(4).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(4).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(4).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(4).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(4).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(4).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(4).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(4).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(4).k);
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
reducer(4).nah = semimotor(4).nmot - semimotor(4).nreq;
reducer(4).nbh = 0 - semimotor(4).nreq;
reducer(4).nch = -(semimotor(4).nmot - semimotor(4).nreq) * 2 / (reducer(4).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(4).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(4).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(4).nch);

% 4.4. Определение КПД редуктора
reducer(4).etarel = (1 + reducer(4).k * 0.99 * 0.97) / (1 + reducer(4).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(4).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(4).etamuf = 0.99;
reducer(4).eta = reducer(4).etarel * reducer(4).etamuf;
reducer(4).Ndvig = semimotor(4).N / reducer(4).eta;
reducer(4).N1 = reducer(4).Ndvig * reducer(4).etamuf;
reducer(4).T1 = 9.550 * reducer(4).N1 / semimotor(4).nmot;
reducer(4).Ta = reducer(4).T1;
reducer(4).N2 = reducer(4).Ndvig * reducer(4).etarel;
reducer(4).T2 = 9.550 * reducer(4).N2 / semimotor(4).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(4).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(4).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(4).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(4).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(4).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(4).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(4).HBg = 290;
reducer(4).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(4).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(4).HBw);

% 6.2. Определение допускаемых напряжений
reducer(4).NHO1 = 24 * 10^6;
reducer(4).NHO2 = 21 * 10^6;
reducer(4).NFO1 = 4 * 10^6;
reducer(4).NFO2 = 4 * 10^6;

reducer(4).t1 = 0.3 * reducer(4).t;
reducer(4).t2 = 0.3 * reducer(4).t;
reducer(4).t3 = 0.4 * reducer(4).t;
reducer(4).mode = [1, 0.6, 0.3];
reducer(4).tHE = 0;

for i = 1:3
    reducer(4).tHE = reducer(4).tHE + reducer(4).t1 * reducer(4).mode(i)^3;
end

reducer(4).NHE2 = abs(60 * reducer(4).nch * reducer(4).tHE);
reducer(4).NHE1 = 60 * reducer(4).nah * reducer(4).C * reducer(4).tHE;

reducer(4).KHL1 = (reducer(4).NHO1 / reducer(4).NHE1)^(1/6);
if reducer(4).KHL1 < 1
    reducer(4).KHL1 = 1;
end
reducer(4).KHL2 = (reducer(4).NHO2 / reducer(4).NHE2)^(1/6);
if reducer(4).KHL2 < 1
    reducer(4).KHL2 = 1;
end

reducer(4).KFL1 = 1;
reducer(4).KFL2 = 1;

reducer(4).sigmaHO1 = 2 * reducer(4).HBg + 70;
reducer(4).sigmaHO2 = 2 * reducer(4).HBw + 70;
reducer(4).sigmaFO1 = 1.8 * reducer(4).HBg;
reducer(4).sigmaFO2 = 1.8 * reducer(4).HBw;

reducer(4).SH1 = 1.1;
reducer(4).SH2 = 1.1;
reducer(4).SF1 = 1.75;
reducer(4).SF2 = 1.75;
reducer(4).sigmaH1 = reducer(4).sigmaHO1 / reducer(4).SH1 * reducer(4).KHL1;
reducer(4).sigmaH2 = reducer(4).sigmaHO2 / reducer(4).SH2 * reducer(4).KHL2;
reducer(4).sigmaF1 = reducer(4).sigmaFO1 / reducer(4).SF1 * reducer(4).KFL1;
reducer(4).sigmaF2 = reducer(4).sigmaFO2 / reducer(4).SF2 * reducer(4).KFL2;
reducer(4).sigmaH = min(reducer(4).sigmaH1, reducer(4).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(4).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(4).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(4).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(4).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(4).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(4).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(4).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(4).KHL1, reducer(4).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(4).KFL1, reducer(4).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(4).sigmaHO1, reducer(4).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(4).sigmaFO1, reducer(4).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(4).SH1, reducer(4).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(4).SF1, reducer(4).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(4).sigmaH1, reducer(4).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(4).sigmaF1, reducer(4).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(4).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(4).Kd = 780;
reducer(4).psibd = 0.3;
reducer(4).uHaC = (reducer(4).k - 1)/2;
reducer(4).uHcb = abs(reducer(4).nch / reducer(4).nbh);
reducer(4).Kc = 1.1;

reducer(4).Khbetta = get_Khbetta_Kfbetta(reducer(4).psibd, reducer(4).HBg, reducer(4).HBw, 'VI', 'KH');
reducer(4).Tap = reducer(4).Ta * reducer(4).Khbetta * reducer(4).Kc / reducer(4).C;
reducer(4).da = reducer(4).Kd * ((reducer(4).Tap * (reducer(4).uHaC + 1)) / ...
    (reducer(4).psibd * (reducer(4).sigmaH ^ 2) * reducer(4).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(4).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(4).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(4).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(4).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(4).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(4).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(4).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(4).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(4).za;
arrraay_of_m = zeros(1, 5);
reducer(4).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(4).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(4).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(4).m > arrraay_of_m(i)
        reducer(4).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(4).za = T2{1, the_chosen_m_ind};
reducer(4).m = T2{3, the_chosen_m_ind};
reducer(4).da = reducer(4).m * reducer(4).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(4).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(4).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(4).da);

% Параметры остальных колес
reducer(4).zb = col3(the_chosen_m_ind);
reducer(4).zc = col7(the_chosen_m_ind);
reducer(4).db = reducer(4).m * reducer(4).zb;
reducer(4).dc = reducer(4).m * reducer(4).zc;

reducer(4).bb = reducer(4).psibd * reducer(4).da;
reducer(4).ba = reducer(4).bb + 4;
reducer(4).bc = reducer(4).bb + 4;

reducer(4).V = pi * reducer(4).da * reducer(4).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(4).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(4).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(4).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(4).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(4).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(4).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(4).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(4).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(4).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(4).V);
reducer(4).aw = (reducer(4).da + reducer(4).dc) / 2;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(4).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(4).Zm = 275;
reducer(4).Zh = 1.76;
reducer(4).epsilona = 1.88 - 3.2 * (1 / reducer(4).za + 1 / reducer(4).zc);
reducer(4).Ze = sqrt((4 - reducer(4).epsilona) / 3);

[reducer(4).grade, desc] = getAccuracyGrade(reducer(4).V, 'cylindrical');
[reducer(4).Kha, reducer(4).Kfa] = get_K_Ha_K_Fa(reducer(4).V, reducer(4).grade);
[reducer(4).Khv, reducer(4).Kfv] = getDynamicCoefficients(reducer(4).V, reducer(4).grade, 'a', 'straight');
reducer(4).Khc = 1.1;

reducer(4).sigmah = reducer(4).Zm * reducer(4).Zh * reducer(4).Ze * ...
    sqrt((2 * reducer(4).Tap * reducer(4).Khbetta * reducer(4).Khv * reducer(4).Kha * ...
    (reducer(4).uHaC + 1) * 1000) / (reducer(4).bb * reducer(4).da ^ 2 * ...
    reducer(4).uHaC * reducer(4).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(4).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(4).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(4).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(4).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(4).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(4).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(4).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(4).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(4).sigmaH);

if reducer(4).sigmah <= reducer(4).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(4).Kfbetta = get_Khbetta_Kfbetta(reducer(4).psibd, reducer(4).HBg, reducer(4).HBw, 'V', 'KF');
reducer(4).YF1 = get_YF(reducer(4).za, 0);
reducer(4).YF2 = get_YF(reducer(4).zc, 0);
reducer(4).Ke = 0.92;
reducer(4).mt = reducer(4).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(4).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(4).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(4).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(4).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(4).mt);

if reducer(4).sigmaF1 / reducer(4).YF1 > reducer(4).sigmaF2 / reducer(4).YF2
    reducer(4).sigmaFC = reducer(4).YF2 * (2 * reducer(4).Tap * reducer(4).Kfbetta * ...
        reducer(4).Kfv * reducer(4).Kfa * reducer(4).Kc * 1000) / ...
        (reducer(4).C * reducer(4).Ke * reducer(4).ba * reducer(4).epsilona * ...
        reducer(4).da * reducer(4).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(4).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(4).sigmaF2);
    
    if reducer(4).sigmaFC <= reducer(4).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(4).sigmaFC = reducer(4).YF1 * (2 * reducer(4).Tap * reducer(4).Kfbetta * ...
        reducer(4).Kfv * reducer(4).Kfa * reducer(4).Kc * 1000) / ...
        (reducer(4).C * reducer(4).Ke * reducer(4).ba * reducer(4).epsilona * ...
        reducer(4).da * reducer(4).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(4).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(4).sigmaF1);
    
    if reducer(4).sigmaFC <= reducer(4).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(4).Vc = abs(pi * reducer(4).dc * reducer(4).nch / 60000);
reducer(4).epsilona_e = 1.88 - 3.2 * (1 / reducer(4).zc - 1 / reducer(4).zb);
reducer(4).Ze_e = sqrt((4 - reducer(4).epsilona_e) / 3);
reducer(4).Tb = 2 * reducer(4).T2 * reducer(4).Khbetta * reducer(4).Kc / reducer(4).C;

[reducer(4).grade_e, desc_e] = getAccuracyGrade(reducer(4).Vc, 'cylindrical');
[reducer(4).Kha_e, reducer(4).Kfa_e] = get_K_Ha_K_Fa(reducer(4).Vc, reducer(4).grade_e);
[reducer(4).Khv_e, reducer(4).Kfv_e] = getDynamicCoefficients(reducer(4).Vc, reducer(4).grade_e, 'a', 'straight');
reducer(4).uCb = reducer(4).zb / reducer(4).zc;

reducer(4).sigmah_e = reducer(4).Zm * reducer(4).Zh * reducer(4).Ze_e * ...
    sqrt((2 * reducer(4).Tb * reducer(4).Khbetta * reducer(4).Khv_e * reducer(4).Kha * ...
    reducer(4).Kc * (reducer(4).uHcb - 1) * 1000) / (reducer(4).C * reducer(4).bb * ...
    reducer(4).dc * reducer(4).db * reducer(4).uCb));

reducer(4).sigmah0_e = reducer(4).sigmah_e / reducer(4).KHL2 * reducer(4).SH2;
reducer(4).HB_e = (reducer(4).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(4).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(4).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(4).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(4).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(4).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(4).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(4).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(4).overload = 2;
reducer(4).sigmah_max = 2 * reducer(4).sigmah * sqrt(reducer(4).overload);
reducer(4).sigmaf_max = 2 * reducer(4).sigmaFC * reducer(4).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(4).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(4).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(4).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(4).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(4).sigmaHO2);

if (reducer(4).sigmah_max <= 2.8 * reducer(4).sigmaHO1) && ...
   (reducer(4).sigmaf_max <= 0.8 * reducer(4).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(4).tau = 15;
reducer(4).d1 = ((reducer(4).T1 * 1000) / (0.2 * reducer(4).tau)) ^ (1/3);
reducer(4).d1 = floor(reducer(4).d1);
reducer(4).d1 = 40;
reducer(4).d2 = ((reducer(4).T2 * 1000) / (0.2 * reducer(4).tau)) ^ (1/3);
reducer(4).d2 = floor(reducer(4).d2);
reducer(4).aw = (reducer(4).da + reducer(4).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(4).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(4).T1 * 1000) / (0.2 * reducer(4).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(4).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(4).T2 * 1000) / (0.2 * reducer(4).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(4).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(4).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(4).Fa = (2 * reducer(4).T1 * 1000 * reducer(4).Kc) / (reducer(4).da * reducer(4).C);
reducer(4).Fn = 2 * reducer(4).Fa;
reducer(4).l = 33;
reducer(4).q = reducer(4).Fn / reducer(4).l;
reducer(4).M_bend = reducer(4).q * reducer(4).l ^ 2 / 8;
reducer(4).sigma_axis = 120;
reducer(4).d_axis = 0.5 * floor(2 * ((32 * reducer(4).M_bend) / (pi * reducer(4).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(4).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(4).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(4).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(4).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(4).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(4).d_axis);

% ======= ИТОГОВАЯ СВОДКА =======
fprintf('================================================================================\n');
fprintf('                           ИТОГОВАЯ СВОДКА ПАРАМЕТРОВ                          \n');
fprintf('================================================================================\n\n');

fprintf('Основные параметры редуктора:\n');
fprintf('  ┌─────────────────────────────────────────────────────────────────────────┐\n');
fprintf('  │ Параметр                          │ Значение          │ Ед. изм.      │\n');
fprintf('  ├─────────────────────────────────────────────────────────────────────────┤\n');
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(4).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(4).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(4).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(4).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(4).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(4).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(4).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(4).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(4).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(4).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(4).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(4).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(4).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(4).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(4).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(4).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(4).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(4).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(4).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(4).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(4).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(4).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(4).d_axis);
fprintf('  └─────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');



fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(5).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(5).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(5).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(5).u = semimotor(5).nmot / semimotor(5).nreq;
reducer(5).k = reducer(5).u - 1;
reducer(5).C = 3;
reducer(5).t = 5000;
reducer(5).na = semimotor(5).nmot;
reducer(5).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(5).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(5).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(5).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(5).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(5).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(5).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(5).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(5).k);
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
reducer(5).nah = semimotor(5).nmot - semimotor(5).nreq;
reducer(5).nbh = 0 - semimotor(5).nreq;
reducer(5).nch = -(semimotor(5).nmot - semimotor(5).nreq) * 2 / (reducer(5).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(5).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(5).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(5).nch);

% 4.4. Определение КПД редуктора
reducer(5).etarel = (1 + reducer(5).k * 0.99 * 0.97) / (1 + reducer(5).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(5).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(5).etamuf = 0.99;
reducer(5).eta = reducer(5).etarel * reducer(5).etamuf;
reducer(5).Ndvig = semimotor(5).N / reducer(5).eta;
reducer(5).N1 = reducer(5).Ndvig * reducer(5).etamuf;
reducer(5).T1 = 9.550 * reducer(5).N1 / semimotor(5).nmot;
reducer(5).Ta = reducer(5).T1;
reducer(5).N2 = reducer(5).Ndvig * reducer(5).etarel;
reducer(5).T2 = 9.550 * reducer(5).N2 / semimotor(5).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(5).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(5).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(5).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(5).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(5).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(5).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(5).HBg = 290;
reducer(5).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(5).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(5).HBw);

% 6.2. Определение допускаемых напряжений
reducer(5).NHO1 = 24 * 10^6;
reducer(5).NHO2 = 21 * 10^6;
reducer(5).NFO1 = 4 * 10^6;
reducer(5).NFO2 = 4 * 10^6;

reducer(5).t1 = 0.3 * reducer(5).t;
reducer(5).t2 = 0.3 * reducer(5).t;
reducer(5).t3 = 0.4 * reducer(5).t;
reducer(5).mode = [1, 0.6, 0.3];
reducer(5).tHE = 0;

for i = 1:3
    reducer(5).tHE = reducer(5).tHE + reducer(5).t1 * reducer(5).mode(i)^3;
end

reducer(5).NHE2 = abs(60 * reducer(5).nch * reducer(5).tHE);
reducer(5).NHE1 = 60 * reducer(5).nah * reducer(5).C * reducer(5).tHE;

reducer(5).KHL1 = (reducer(5).NHO1 / reducer(5).NHE1)^(1/6);
if reducer(5).KHL1 < 1
    reducer(5).KHL1 = 1;
end
reducer(5).KHL2 = (reducer(5).NHO2 / reducer(5).NHE2)^(1/6);
if reducer(5).KHL2 < 1
    reducer(5).KHL2 = 1;
end

reducer(5).KFL1 = 1;
reducer(5).KFL2 = 1;

reducer(5).sigmaHO1 = 2 * reducer(5).HBg + 70;
reducer(5).sigmaHO2 = 2 * reducer(5).HBw + 70;
reducer(5).sigmaFO1 = 1.8 * reducer(5).HBg;
reducer(5).sigmaFO2 = 1.8 * reducer(5).HBw;

reducer(5).SH1 = 1.1;
reducer(5).SH2 = 1.1;
reducer(5).SF1 = 1.75;
reducer(5).SF2 = 1.75;
reducer(5).sigmaH1 = reducer(5).sigmaHO1 / reducer(5).SH1 * reducer(5).KHL1;
reducer(5).sigmaH2 = reducer(5).sigmaHO2 / reducer(5).SH2 * reducer(5).KHL2;
reducer(5).sigmaF1 = reducer(5).sigmaFO1 / reducer(5).SF1 * reducer(5).KFL1;
reducer(5).sigmaF2 = reducer(5).sigmaFO2 / reducer(5).SF2 * reducer(5).KFL2;
reducer(5).sigmaH = min(reducer(5).sigmaH1, reducer(5).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(5).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(5).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(5).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(5).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(5).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(5).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(5).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(5).KHL1, reducer(5).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(5).KFL1, reducer(5).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(5).sigmaHO1, reducer(5).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(5).sigmaFO1, reducer(5).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(5).SH1, reducer(5).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(5).SF1, reducer(5).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(5).sigmaH1, reducer(5).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(5).sigmaF1, reducer(5).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(5).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(5).Kd = 780;
reducer(5).psibd = 0.3;
reducer(5).uHaC = (reducer(5).k - 1)/2;
reducer(5).uHcb = abs(reducer(5).nch / reducer(5).nbh);
reducer(5).Kc = 1.1;

reducer(5).Khbetta = get_Khbetta_Kfbetta(reducer(5).psibd, reducer(5).HBg, reducer(5).HBw, 'VI', 'KH');
reducer(5).Tap = reducer(5).Ta * reducer(5).Khbetta * reducer(5).Kc / reducer(5).C;
reducer(5).da = reducer(5).Kd * ((reducer(5).Tap * (reducer(5).uHaC + 1)) / ...
    (reducer(5).psibd * (reducer(5).sigmaH ^ 2) * reducer(5).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(5).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(5).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(5).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(5).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(5).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(5).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(5).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(5).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(5).za;
arrraay_of_m = zeros(1, 5);
reducer(5).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(5).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(5).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(5).m > arrraay_of_m(i)
        reducer(5).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(5).za = T2{1, the_chosen_m_ind};
reducer(5).m = T2{3, the_chosen_m_ind};
reducer(5).da = reducer(5).m * reducer(5).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(5).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(5).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(5).da);

% Параметры остальных колес
reducer(5).zb = col3(the_chosen_m_ind);
reducer(5).zc = col7(the_chosen_m_ind);
reducer(5).db = reducer(5).m * reducer(5).zb;
reducer(5).dc = reducer(5).m * reducer(5).zc;

reducer(5).bb = reducer(5).psibd * reducer(5).da;
reducer(5).ba = reducer(5).bb + 4;
reducer(5).bc = reducer(5).bb + 4;

reducer(5).V = pi * reducer(5).da * reducer(5).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(5).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(5).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(5).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(5).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(5).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(5).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(5).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(5).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(5).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(5).V);
reducer(5).aw = (reducer(5).da + reducer(5).dc) / 2;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(5).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(5).Zm = 275;
reducer(5).Zh = 1.76;
reducer(5).epsilona = 1.88 - 3.2 * (1 / reducer(5).za + 1 / reducer(5).zc);
reducer(5).Ze = sqrt((4 - reducer(5).epsilona) / 3);

[reducer(5).grade, desc] = getAccuracyGrade(reducer(5).V, 'cylindrical');
[reducer(5).Kha, reducer(5).Kfa] = get_K_Ha_K_Fa(reducer(5).V, reducer(5).grade);
[reducer(5).Khv, reducer(5).Kfv] = getDynamicCoefficients(reducer(5).V, reducer(5).grade, 'a', 'straight');
reducer(5).Khc = 1.1;

reducer(5).sigmah = reducer(5).Zm * reducer(5).Zh * reducer(5).Ze * ...
    sqrt((2 * reducer(5).Tap * reducer(5).Khbetta * reducer(5).Khv * reducer(5).Kha * ...
    (reducer(5).uHaC + 1) * 1000) / (reducer(5).bb * reducer(5).da ^ 2 * ...
    reducer(5).uHaC * reducer(5).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(5).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(5).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(5).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(5).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(5).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(5).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(5).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(5).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(5).sigmaH);

if reducer(5).sigmah <= reducer(5).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(5).Kfbetta = get_Khbetta_Kfbetta(reducer(5).psibd, reducer(5).HBg, reducer(5).HBw, 'V', 'KF');
reducer(5).YF1 = get_YF(reducer(5).za, 0);
reducer(5).YF2 = get_YF(reducer(5).zc, 0);
reducer(5).Ke = 0.92;
reducer(5).mt = reducer(5).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(5).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(5).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(5).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(5).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(5).mt);

if reducer(5).sigmaF1 / reducer(5).YF1 > reducer(5).sigmaF2 / reducer(5).YF2
    reducer(5).sigmaFC = reducer(5).YF2 * (2 * reducer(5).Tap * reducer(5).Kfbetta * ...
        reducer(5).Kfv * reducer(5).Kfa * reducer(5).Kc * 1000) / ...
        (reducer(5).C * reducer(5).Ke * reducer(5).ba * reducer(5).epsilona * ...
        reducer(5).da * reducer(5).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(5).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(5).sigmaF2);
    
    if reducer(5).sigmaFC <= reducer(5).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(5).sigmaFC = reducer(5).YF1 * (2 * reducer(5).Tap * reducer(5).Kfbetta * ...
        reducer(5).Kfv * reducer(5).Kfa * reducer(5).Kc * 1000) / ...
        (reducer(5).C * reducer(5).Ke * reducer(5).ba * reducer(5).epsilona * ...
        reducer(5).da * reducer(5).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(5).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(5).sigmaF1);
    
    if reducer(5).sigmaFC <= reducer(5).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(5).Vc = abs(pi * reducer(5).dc * reducer(5).nch / 60000);
reducer(5).epsilona_e = 1.88 - 3.2 * (1 / reducer(5).zc - 1 / reducer(5).zb);
reducer(5).Ze_e = sqrt((4 - reducer(5).epsilona_e) / 3);
reducer(5).Tb = 2 * reducer(5).T2 * reducer(5).Khbetta * reducer(5).Kc / reducer(5).C;

[reducer(5).grade_e, desc_e] = getAccuracyGrade(reducer(5).Vc, 'cylindrical');
[reducer(5).Kha_e, reducer(5).Kfa_e] = get_K_Ha_K_Fa(reducer(5).Vc, reducer(5).grade_e);
[reducer(5).Khv_e, reducer(5).Kfv_e] = getDynamicCoefficients(reducer(5).Vc, reducer(5).grade_e, 'a', 'straight');
reducer(5).uCb = reducer(5).zb / reducer(5).zc;

reducer(5).sigmah_e = reducer(5).Zm * reducer(5).Zh * reducer(5).Ze_e * ...
    sqrt((2 * reducer(5).Tb * reducer(5).Khbetta * reducer(5).Khv_e * reducer(5).Kha * ...
    reducer(5).Kc * (reducer(5).uHcb - 1) * 1000) / (reducer(5).C * reducer(5).bb * ...
    reducer(5).dc * reducer(5).db * reducer(5).uCb));

reducer(5).sigmah0_e = reducer(5).sigmah_e / reducer(5).KHL2 * reducer(5).SH2;
reducer(5).HB_e = (reducer(5).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(5).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(5).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(5).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(5).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(5).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(5).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(5).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(5).overload = 2;
reducer(5).sigmah_max = 2 * reducer(5).sigmah * sqrt(reducer(5).overload);
reducer(5).sigmaf_max = 2 * reducer(5).sigmaFC * reducer(5).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(5).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(5).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(5).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(5).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(5).sigmaHO2);

if (reducer(5).sigmah_max <= 2.8 * reducer(5).sigmaHO1) && ...
   (reducer(5).sigmaf_max <= 0.8 * reducer(5).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(5).tau = 15;
reducer(5).d1 = ((reducer(5).T1 * 1000) / (0.2 * reducer(5).tau)) ^ (1/3);
reducer(5).d1 = floor(reducer(5).d1);
reducer(5).d1 = 40;
reducer(5).d2 = ((reducer(5).T2 * 1000) / (0.2 * reducer(5).tau)) ^ (1/3);
reducer(5).d2 = floor(reducer(5).d2);
reducer(5).aw = (reducer(5).da + reducer(5).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(5).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(5).T1 * 1000) / (0.2 * reducer(5).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(5).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(5).T2 * 1000) / (0.2 * reducer(5).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(5).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(5).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(5).Fa = (2 * reducer(5).T1 * 1000 * reducer(5).Kc) / (reducer(5).da * reducer(5).C);
reducer(5).Fn = 2 * reducer(5).Fa;
reducer(5).l = 33;
reducer(5).q = reducer(5).Fn / reducer(5).l;
reducer(5).M_bend = reducer(5).q * reducer(5).l ^ 2 / 8;
reducer(5).sigma_axis = 120;
reducer(5).d_axis = 0.5 * floor(2 * ((32 * reducer(5).M_bend) / (pi * reducer(5).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(5).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(5).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(5).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(5).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(5).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(5).d_axis);

% ======= ИТОГОВАЯ СВОДКА =======
fprintf('================================================================================\n');
fprintf('                           ИТОГОВАЯ СВОДКА ПАРАМЕТРОВ                          \n');
fprintf('================================================================================\n\n');

fprintf('Основные параметры редуктора:\n');
fprintf('  ┌─────────────────────────────────────────────────────────────────────────┐\n');
fprintf('  │ Параметр                          │ Значение          │ Ед. изм.      │\n');
fprintf('  ├─────────────────────────────────────────────────────────────────────────┤\n');
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(5).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(5).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(5).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(5).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(5).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(5).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(5).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(5).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(5).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(5).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(5).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(5).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(5).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(5).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(5).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(5).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(5).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(5).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(5).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(5).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(5).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(5).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(5).d_axis);
fprintf('  └─────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');



fprintf('================================================================================\n');
fprintf('                    РАСЧЁТ ПЛАНЕТАРНОГО ЗУБЧАТОГО РЕДУКТОРА                    \n');
fprintf('                         (по ГОСТ 6033-80)                                     \n');
fprintf('================================================================================\n\n');

fprintf("Параметры выбранного двигателя:\n");
fprintf("  Требуемая скорость:          nreq  = %.3f об/мин\n", semimotor(6).nreq);
fprintf("  Номинальная скорость:        nном  = %.3f об/мин\n", semimotor(6).nmot);
fprintf("  Номинальная мощность:        P_max = %.3f Вт\n\n", semimotor(6).N);

% ======= 4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА =======
fprintf('================================================================================\n');
fprintf('                    4. КИНЕМАТИЧЕСКИЙ РАСЧЁТ ПРИВОДА                           \n');
fprintf('================================================================================\n\n');

% 4.1 Выбор двигателя и определение относительного передаточного числа
reducer(6).u = semimotor(6).nmot / semimotor(6).nreq;
reducer(6).k = reducer(6).u - 1;
reducer(6).C = 3;
reducer(6).t = 5000;
reducer(6).na = semimotor(6).nmot;
reducer(6).za = 18;

fprintf('4.1. Передаточное отношение редуктора:\n');
fprintf("  Передаточное отношение:        u     = %.3f\n", reducer(6).u);
fprintf("  Конструктивная характеристика: k     = %.3f\n", reducer(6).k);
fprintf("  Число сателлитов:              C     = %d\n", reducer(6).C);
fprintf("  Время работы привода:          t     = %.0f час\n", reducer(6).t);
fprintf("  Частота вращения входного вала: na   = %.3f об/мин\n\n", reducer(6).na);

% 4.2. Подбор числа зубьев колес редуктора
col1 = zeros(5, 1);
col2 = zeros(5, 1);
col3 = zeros(5, 1);
col4 = zeros(5, 1);
col5 = zeros(5, 1);
col6 = zeros(5, 1);
col7 = zeros(5, 1);

za = reducer(6).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(6).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(6).k);
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
reducer(6).nah = semimotor(6).nmot - semimotor(6).nreq;
reducer(6).nbh = 0 - semimotor(6).nreq;
reducer(6).nch = -(semimotor(6).nmot - semimotor(6).nreq) * 2 / (reducer(6).k - 1);

fprintf('4.3. Относительные частоты вращения колес:\n');
fprintf("  Частота вращения солнечного колеса: nah = %.3f об/мин\n", reducer(6).nah);
fprintf("  Частота вращения эпицикла:          nbh = %.3f об/мин\n", reducer(6).nbh);
fprintf("  Частота вращения сателлита:         nch = %.3f об/мин\n\n", reducer(6).nch);

% 4.4. Определение КПД редуктора
reducer(6).etarel = (1 + reducer(6).k * 0.99 * 0.97) / (1 + reducer(6).k);

fprintf('4.4. КПД редуктора:\n');
fprintf("  КПД планетарной передачи: eta_rel = %.4f\n\n", reducer(6).etarel);

% ======= 5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ =======
fprintf('================================================================================\n');
fprintf('          5. ОПРЕДЕЛЕНИЕ МОМЕНТОВ И МОЩНОСТИ НА ВАЛАХ                          \n');
fprintf('================================================================================\n\n');

reducer(6).etamuf = 0.99;
reducer(6).eta = reducer(6).etarel * reducer(6).etamuf;
reducer(6).Ndvig = semimotor(6).N / reducer(6).eta;
reducer(6).N1 = reducer(6).Ndvig * reducer(6).etamuf;
reducer(6).T1 = 9.550 * reducer(6).N1 / semimotor(6).nmot;
reducer(6).Ta = reducer(6).T1;
reducer(6).N2 = reducer(6).Ndvig * reducer(6).etarel;
reducer(6).T2 = 9.550 * reducer(6).N2 / semimotor(6).nreq;

fprintf('5.1. Мощности на валах:\n');
fprintf("  Мощность на двигателе (с учётом потерь): N_dvig = %.3f Вт\n", reducer(6).Ndvig);
fprintf("  Мощность на ведущем валу:                N1     = %.3f Вт\n", reducer(6).N1);
fprintf("  Мощность на выходном валу:               N2     = %.3f Вт\n\n", reducer(6).N2);

fprintf('5.2. Вращающие моменты на валах:\n');
fprintf("  Момент на ведущем валу:    T1 = %.3f Н·м\n", reducer(6).T1);
fprintf("  Момент на солнечном колесе: Ta = %.3f Н·м\n", reducer(6).Ta);
fprintf("  Момент на выходном валу:   T2 = %.3f Н·м\n\n", reducer(6).T2);

% ======= 6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ =======
fprintf('================================================================================\n');
fprintf('     6. ОПРЕДЕЛЕНИЕ ОСНОВНЫХ РАЗМЕРОВ ПЛАНЕТАРНОЙ ПЕРЕДАЧИ                     \n');
fprintf('================================================================================\n\n');

% 6.1. Выбор материалов колес редуктора
reducer(6).HBg = 290;
reducer(6).HBw = 270;

fprintf('6.1. Материалы колес редуктора:\n');
fprintf("  Солнечное колесо: Сталь 40Х, термообработка – улучшение, HBg = %d\n", reducer(6).HBg);
fprintf("  Сателлит:         Сталь 40Х, термообработка – улучшение, HBw = %d\n\n", reducer(6).HBw);

% 6.2. Определение допускаемых напряжений
reducer(6).NHO1 = 24 * 10^6;
reducer(6).NHO2 = 21 * 10^6;
reducer(6).NFO1 = 4 * 10^6;
reducer(6).NFO2 = 4 * 10^6;

reducer(6).t1 = 0.3 * reducer(6).t;
reducer(6).t2 = 0.3 * reducer(6).t;
reducer(6).t3 = 0.4 * reducer(6).t;
reducer(6).mode = [1, 0.6, 0.3];
reducer(6).tHE = 0;

for i = 1:3
    reducer(6).tHE = reducer(6).tHE + reducer(6).t1 * reducer(6).mode(i)^3;
end

reducer(6).NHE2 = abs(60 * reducer(6).nch * reducer(6).tHE);
reducer(6).NHE1 = 60 * reducer(6).nah * reducer(6).C * reducer(6).tHE;

reducer(6).KHL1 = (reducer(6).NHO1 / reducer(6).NHE1)^(1/6);
if reducer(6).KHL1 < 1
    reducer(6).KHL1 = 1;
end
reducer(6).KHL2 = (reducer(6).NHO2 / reducer(6).NHE2)^(1/6);
if reducer(6).KHL2 < 1
    reducer(6).KHL2 = 1;
end

reducer(6).KFL1 = 1;
reducer(6).KFL2 = 1;

reducer(6).sigmaHO1 = 2 * reducer(6).HBg + 70;
reducer(6).sigmaHO2 = 2 * reducer(6).HBw + 70;
reducer(6).sigmaFO1 = 1.8 * reducer(6).HBg;
reducer(6).sigmaFO2 = 1.8 * reducer(6).HBw;

reducer(6).SH1 = 1.1;
reducer(6).SH2 = 1.1;
reducer(6).SF1 = 1.75;
reducer(6).SF2 = 1.75;
reducer(6).sigmaH1 = reducer(6).sigmaHO1 / reducer(6).SH1 * reducer(6).KHL1;
reducer(6).sigmaH2 = reducer(6).sigmaHO2 / reducer(6).SH2 * reducer(6).KHL2;
reducer(6).sigmaF1 = reducer(6).sigmaFO1 / reducer(6).SF1 * reducer(6).KFL1;
reducer(6).sigmaF2 = reducer(6).sigmaFO2 / reducer(6).SF2 * reducer(6).KFL2;
reducer(6).sigmaH = min(reducer(6).sigmaH1, reducer(6).sigmaH2);

fprintf('6.2. Допускаемые напряжения:\n');
fprintf("  Базовое число циклов (контактная прочность):\n");
fprintf("    Шестерня:  NHO1 = %.2e циклов\n", reducer(6).NHO1);
fprintf("    Колесо:    NHO2 = %.2e циклов\n", reducer(6).NHO2);
fprintf("  Базовое число циклов (изгибная прочность):\n");
fprintf("    Шестерня:  NFO1 = %.2e циклов\n", reducer(6).NFO1);
fprintf("    Колесо:    NFO2 = %.2e циклов\n\n", reducer(6).NFO2);

fprintf("  Эквивалентное время работы: tHE = %.2f час\n", reducer(6).tHE);
fprintf("  Эквивалентное число циклов:\n");
fprintf("    Шестерня:  NHE1 = %.2e циклов\n", reducer(6).NHE1);
fprintf("    Колесо:    NHE2 = %.2e циклов\n\n", reducer(6).NHE2);

fprintf("  Коэффициенты долговечности:\n");
fprintf("    KHL1 = %.3f, KHL2 = %.3f\n", reducer(6).KHL1, reducer(6).KHL2);
fprintf("    KFL1 = %.3f, KFL2 = %.3f\n\n", reducer(6).KFL1, reducer(6).KFL2);

fprintf("  Пределы выносливости:\n");
fprintf("    Контактная прочность: sigmaHO1 = %.2f МПа, sigmaHO2 = %.2f МПа\n", ...
    reducer(6).sigmaHO1, reducer(6).sigmaHO2);
fprintf("    Изгибная прочность:   sigmaFO1 = %.2f МПа, sigmaFO2 = %.2f МПа\n\n", ...
    reducer(6).sigmaFO1, reducer(6).sigmaFO2);

fprintf("  Коэффициенты безопасности:\n");
fprintf("    SH1 = %.2f, SH2 = %.2f\n", reducer(6).SH1, reducer(6).SH2);
fprintf("    SF1 = %.2f, SF2 = %.2f\n\n", reducer(6).SF1, reducer(6).SF2);

fprintf("  Допускаемые напряжения:\n");
fprintf("    Контактная прочность: sigmaH1 = %.2f МПа, sigmaH2 = %.2f МПа\n", ...
    reducer(6).sigmaH1, reducer(6).sigmaH2);
fprintf("    Изгибная прочность:   sigmaF1 = %.2f МПа, sigmaF2 = %.2f МПа\n", ...
    reducer(6).sigmaF1, reducer(6).sigmaF2);
fprintf("    Расчётное (минимальное): sigmaH = %.2f МПа\n\n", reducer(6).sigmaH);

% ======= 7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА =======
fprintf('================================================================================\n');
fprintf('              7. ОПРЕДЕЛЕНИЕ РАЗМЕРОВ КОЛЁС РЕДУКТОРА                          \n');
fprintf('================================================================================\n\n');

reducer(6).Kd = 780;
reducer(6).psibd = 0.3;
reducer(6).uHaC = (reducer(6).k - 1)/2;
reducer(6).uHcb = abs(reducer(6).nch / reducer(6).nbh);
reducer(6).Kc = 1.1;

reducer(6).Khbetta = get_Khbetta_Kfbetta(reducer(6).psibd, reducer(6).HBg, reducer(6).HBw, 'VI', 'KH');
reducer(6).Tap = reducer(6).Ta * reducer(6).Khbetta * reducer(6).Kc / reducer(6).C;
reducer(6).da = reducer(6).Kd * ((reducer(6).Tap * (reducer(6).uHaC + 1)) / ...
    (reducer(6).psibd * (reducer(6).sigmaH ^ 2) * reducer(6).uHaC))^(1/3);

fprintf('7.1. Предварительные параметры:\n');
fprintf("  Коэффициент Kd:           %.2f МПа^(1/3)\n", reducer(6).Kd);
fprintf("  Коэффициент ширины psi_bd: %.2f\n", reducer(6).psibd);
fprintf("  Передаточное число u_HaC:  %.3f\n", reducer(6).uHaC);
fprintf("  Передаточное число u_Hcb:  %.3f\n", reducer(6).uHcb);
fprintf("  Коэффициент неравномерности Kc: %.2f\n", reducer(6).Kc);
fprintf("  Коэффициент концентрации K_hbeta: %.3f\n", reducer(6).Khbetta);
fprintf("  Расчётный момент T_ap:      %.3f Н·м\n", reducer(6).Tap);
fprintf("  Предварительный диаметр d_a: %.3f мм\n\n", reducer(6).da);

% Выбор модуля
row_names = {'za', 'm_rasch', 'm_stand'};
col_names = {'1', '2', '3', '4', '5'};
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

za = reducer(6).za;
arrraay_of_m = zeros(1, 5);
reducer(6).m = 10;
the_chosen_m_ind = 0;

for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(6).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(6).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(6).m > arrraay_of_m(i)
        reducer(6).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

reducer(6).za = T2{1, the_chosen_m_ind};
reducer(6).m = T2{3, the_chosen_m_ind};
reducer(6).da = reducer(6).m * reducer(6).za;

fprintf('7.2. Таблица выбора модуля зацепления:\n');
disp(T2);

fprintf('7.3. Выбранные параметры солнечного колеса:\n');
fprintf("  Число зубьев:              za = %.0f\n", reducer(6).za);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(6).m);
fprintf("  Диаметр делительной окружности: da = %.3f мм\n", reducer(6).da);

% Параметры остальных колес
reducer(6).zb = col3(the_chosen_m_ind);
reducer(6).zc = col7(the_chosen_m_ind);
reducer(6).db = reducer(6).m * reducer(6).zb;
reducer(6).dc = reducer(6).m * reducer(6).zc;

reducer(6).bb = reducer(6).psibd * reducer(6).da;
reducer(6).ba = reducer(6).bb + 4;
reducer(6).bc = reducer(6).bb + 4;

reducer(6).V = pi * reducer(6).da * reducer(6).na / 60000;

fprintf('\n7.4. Параметры сателлита:\n');
fprintf("  Число зубьев:              zc = %.0f\n", reducer(6).zc);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(6).m);
fprintf("  Диаметр делительной окружности: dc = %.3f мм\n", reducer(6).dc);
fprintf("  Ширина колеса:             bc = %.3f мм\n", reducer(6).bc);

fprintf('\n7.5. Параметры эпицикла:\n');
fprintf("  Число зубьев:              zb = %.0f\n", reducer(6).zb);
fprintf("  Модуль зацепления:         m  = %.2f мм\n", reducer(6).m);
fprintf("  Диаметр делительной окружности: db = %.3f мм\n", reducer(6).db);
fprintf("  Ширина колеса:             bb = %.3f мм\n", reducer(6).bb);

fprintf('\n7.6. Дополнительные параметры:\n');
fprintf("  Ширина солнечного колеса:  ba = %.3f мм\n", reducer(6).ba);
fprintf("  Окружная скорость:         V  = %.3f м/с\n", reducer(6).V);
reducer(6).aw = (reducer(6).da + reducer(6).dc) / 2;
fprintf("  Межосевое расстояние:      aw = %.3f мм\n\n", reducer(6).aw);

% ======= 8. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('       8. ПРОВЕРОЧНЫЙ РАСЧЁТ ЗУБЬЕВ КОЛЁС ПО КОНТАКТНЫМ НАПРЯЖЕНИЯМ            \n');
fprintf('================================================================================\n\n');

reducer(6).Zm = 275;
reducer(6).Zh = 1.76;
reducer(6).epsilona = 1.88 - 3.2 * (1 / reducer(6).za + 1 / reducer(6).zc);
reducer(6).Ze = sqrt((4 - reducer(6).epsilona) / 3);

[reducer(6).grade, desc] = getAccuracyGrade(reducer(6).V, 'cylindrical');
[reducer(6).Kha, reducer(6).Kfa] = get_K_Ha_K_Fa(reducer(6).V, reducer(6).grade);
[reducer(6).Khv, reducer(6).Kfv] = getDynamicCoefficients(reducer(6).V, reducer(6).grade, 'a', 'straight');
reducer(6).Khc = 1.1;

reducer(6).sigmah = reducer(6).Zm * reducer(6).Zh * reducer(6).Ze * ...
    sqrt((2 * reducer(6).Tap * reducer(6).Khbetta * reducer(6).Khv * reducer(6).Kha * ...
    (reducer(6).uHaC + 1) * 1000) / (reducer(6).bb * reducer(6).da ^ 2 * ...
    reducer(6).uHaC * reducer(6).C));

fprintf('8.1. Коэффициенты для расчёта контактных напряжений:\n');
fprintf("  Коэффициент механических свойств: Zm = %.2f МПа\n", reducer(6).Zm);
fprintf("  Коэффициент формы сопряжения:     Zh = %.3f\n", reducer(6).Zh);
fprintf("  Коэффициент перекрытия:           Ze = %.3f\n", reducer(6).Ze);
fprintf("  Коэффициент перекрытия эпсилон:   epsilon_a = %.3f\n", reducer(6).epsilona);
fprintf("  Класс точности:                   %s\n", desc);
fprintf("  Коэффициент распределения нагрузки: K_halpha = %.3f\n", reducer(6).Kha);
fprintf("  Коэффициент динамической нагрузки: K_hv = %.3f\n", reducer(6).Khv);
fprintf("  Коэффициент неравномерности:      K_hc = %.3f\n\n", reducer(6).Khc);

fprintf('8.2. Результаты проверочного расчёта:\n');
fprintf("  Действующие контактные напряжения: sigma_H = %.2f МПа\n", reducer(6).sigmah);
fprintf("  Допускаемые контактные напряжения: [sigma_H] = %.2f МПа\n", reducer(6).sigmaH);

if reducer(6).sigmah <= reducer(6).sigmaH
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС ПОДТВЕРЖДАЕТСЯ <<<\n\n");
else
    fprintf("  >>> ДОПУСТИМОСТЬ ПРИНЯТЫХ РАЗМЕРОВ КОЛЁС НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
end

% ======= 9. ПРОВЕРОЧНЫЙ РАСЧЁТ ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ =======
fprintf('================================================================================\n');
fprintf('          9. ПРОВЕРОЧНЫЙ РАСЧЁТ КОЛЁС ПО ИЗГИБНЫМ НАПРЯЖЕНИЯМ                  \n');
fprintf('================================================================================\n\n');

reducer(6).Kfbetta = get_Khbetta_Kfbetta(reducer(6).psibd, reducer(6).HBg, reducer(6).HBw, 'V', 'KF');
reducer(6).YF1 = get_YF(reducer(6).za, 0);
reducer(6).YF2 = get_YF(reducer(6).zc, 0);
reducer(6).Ke = 0.92;
reducer(6).mt = reducer(6).m;

fprintf('9.1. Коэффициенты для расчёта изгибных напряжений:\n');
fprintf("  Коэффициент концентрации нагрузки: K_Fbeta = %.3f\n", reducer(6).Kfbetta);
fprintf("  Коэффициент формы зуба (солнце):   YF1 = %.3f\n", reducer(6).YF1);
fprintf("  Коэффициент формы зуба (сателлит): YF2 = %.3f\n", reducer(6).YF2);
fprintf("  Коэффициент точности:              Ke = %.3f\n", reducer(6).Ke);
fprintf("  Торцевой модуль:                   mt = %.3f мм\n\n", reducer(6).mt);

if reducer(6).sigmaF1 / reducer(6).YF1 > reducer(6).sigmaF2 / reducer(6).YF2
    reducer(6).sigmaFC = reducer(6).YF2 * (2 * reducer(6).Tap * reducer(6).Kfbetta * ...
        reducer(6).Kfv * reducer(6).Kfa * reducer(6).Kc * 1000) / ...
        (reducer(6).C * reducer(6).Ke * reducer(6).ba * reducer(6).epsilona * ...
        reducer(6).da * reducer(6).mt);
    
    fprintf('9.2. Расчёт для сателлита (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(6).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F2] = %.2f МПа\n", reducer(6).sigmaF2);
    
    if reducer(6).sigmaFC <= reducer(6).sigmaF2
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
else
    reducer(6).sigmaFC = reducer(6).YF1 * (2 * reducer(6).Tap * reducer(6).Kfbetta * ...
        reducer(6).Kfv * reducer(6).Kfa * reducer(6).Kc * 1000) / ...
        (reducer(6).C * reducer(6).Ke * reducer(6).ba * reducer(6).epsilona * ...
        reducer(6).da * reducer(6).mt);
    
    fprintf('9.2. Расчёт для солнечного колеса (более слабый зуб):\n');
    fprintf("  Действующие изгибные напряжения: sigma_F = %.2f МПа\n", reducer(6).sigmaFC);
    fprintf("  Допускаемые изгибные напряжения: [sigma_F1] = %.2f МПа\n", reducer(6).sigmaF1);
    
    if reducer(6).sigmaFC <= reducer(6).sigmaF1
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    else
        fprintf("  >>> ПРОВЕРКА НА ИЗГИБНУЮ ПРОЧНОСТЬ НЕ ПОДТВЕРЖДАЕТСЯ <<<\n\n");
    end
end

% 9.2. Эпициклическое колесо
reducer(6).Vc = abs(pi * reducer(6).dc * reducer(6).nch / 60000);
reducer(6).epsilona_e = 1.88 - 3.2 * (1 / reducer(6).zc - 1 / reducer(6).zb);
reducer(6).Ze_e = sqrt((4 - reducer(6).epsilona_e) / 3);
reducer(6).Tb = 2 * reducer(6).T2 * reducer(6).Khbetta * reducer(6).Kc / reducer(6).C;

[reducer(6).grade_e, desc_e] = getAccuracyGrade(reducer(6).Vc, 'cylindrical');
[reducer(6).Kha_e, reducer(6).Kfa_e] = get_K_Ha_K_Fa(reducer(6).Vc, reducer(6).grade_e);
[reducer(6).Khv_e, reducer(6).Kfv_e] = getDynamicCoefficients(reducer(6).Vc, reducer(6).grade_e, 'a', 'straight');
reducer(6).uCb = reducer(6).zb / reducer(6).zc;

reducer(6).sigmah_e = reducer(6).Zm * reducer(6).Zh * reducer(6).Ze_e * ...
    sqrt((2 * reducer(6).Tb * reducer(6).Khbetta * reducer(6).Khv_e * reducer(6).Kha * ...
    reducer(6).Kc * (reducer(6).uHcb - 1) * 1000) / (reducer(6).C * reducer(6).bb * ...
    reducer(6).dc * reducer(6).db * reducer(6).uCb));

reducer(6).sigmah0_e = reducer(6).sigmah_e / reducer(6).KHL2 * reducer(6).SH2;
reducer(6).HB_e = (reducer(6).sigmah_e - 70) / 2;

fprintf('9.3. Проверка эпициклического колеса:\n');
fprintf("  Окружная скорость в зацеплении сателлит-эпицикл: Vc = %.3f м/с\n", reducer(6).Vc);
fprintf("  Коэффициент перекрытия:           epsilon_a_e = %.3f\n", reducer(6).epsilona_e);
fprintf("  Коэффициент учёта длины зацепления: Ze_e = %.3f\n", reducer(6).Ze_e);
fprintf("  Расчётный момент на эпицикле:     Tb = %.3f Н·м\n", reducer(6).Tb);
fprintf("  Класс точности:                   %s\n", desc_e);
fprintf("  Действующие контактные напряжения: sigma_H_e = %.2f МПа\n", reducer(6).sigmah_e);
fprintf("  Требуемый предел контактной выносливости: sigma_H0_e = %.2f МПа\n", reducer(6).sigmah0_e);
fprintf("  Требуемая твёрдость поверхности:  HB_e = %.0f\n\n", reducer(6).HB_e);

% ======= 10. ПРОВЕРКА ПРОЧНОСТИ ПРИ ПЕРЕГРУЗКЕ =======
fprintf('================================================================================\n');
fprintf('              10. ПРОВЕРКА ПРОЧНОСТИ КОЛЁС ПРИ ПЕРЕГРУЗКЕ                      \n');
fprintf('================================================================================\n\n');

reducer(6).overload = 2;
reducer(6).sigmah_max = 2 * reducer(6).sigmah * sqrt(reducer(6).overload);
reducer(6).sigmaf_max = 2 * reducer(6).sigmaFC * reducer(6).overload;

fprintf('10.1. Параметры перегрузки:\n');
fprintf("  Коэффициент перегрузки: K_overload = %.2f\n\n", reducer(6).overload);

fprintf('10.2. Максимальные напряжения при перегрузке:\n');
fprintf("  Контактные напряжения: sigma_H_max = %.2f МПа\n", reducer(6).sigmah_max);
fprintf("  Допускаемые контактные (2.8*sigma_HO1): %.2f МПа\n", 2.8 * reducer(6).sigmaHO1);
fprintf("  Изгибные напряжения:   sigma_F_max = %.2f МПа\n", reducer(6).sigmaf_max);
fprintf("  Допускаемые изгибные (0.8*sigma_HO2): %.2f МПа\n\n", 0.8 * reducer(6).sigmaHO2);

if (reducer(6).sigmah_max <= 2.8 * reducer(6).sigmaHO1) && ...
   (reducer(6).sigmaf_max <= 0.8 * reducer(6).sigmaHO2)
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ ОБЕСПЕЧЕНА <<<\n\n");
else
    fprintf("  >>> ПРОЧНОСТЬ КОНСТРУКЦИИ ПРИ ПЕРЕГРУЗКАХ НЕ ОБЕСПЕЧЕНА <<<\n\n");
end

% ======= 12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ =======
fprintf('================================================================================\n');
fprintf('         12. ПРЕДВАРИТЕЛЬНЫЙ РАСЧЁТ ВАЛОВ И МЕЖОСЕВОЕ РАССТОЯНИЕ               \n');
fprintf('================================================================================\n\n');

reducer(6).tau = 15;
reducer(6).d1 = ((reducer(6).T1 * 1000) / (0.2 * reducer(6).tau)) ^ (1/3);
reducer(6).d1 = floor(reducer(6).d1);
reducer(6).d1 = 40;
reducer(6).d2 = ((reducer(6).T2 * 1000) / (0.2 * reducer(6).tau)) ^ (1/3);
reducer(6).d2 = floor(reducer(6).d2);
reducer(6).aw = (reducer(6).da + reducer(6).dc) / 2;

fprintf('12.1. Диаметры валов:\n');
fprintf("  Допускаемое касательное напряжение: [tau] = %.2f МПа\n", reducer(6).tau);
fprintf("  Расчётный диаметр ведущего вала:    d1_calc = %.3f мм\n", ((reducer(6).T1 * 1000) / (0.2 * reducer(6).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведущего вала:     d1 = %d мм\n", reducer(6).d1);
fprintf("  Расчётный диаметр ведомого вала:    d2_calc = %.3f мм\n", ((reducer(6).T2 * 1000) / (0.2 * reducer(6).tau)) ^ (1/3));
fprintf("  Принятый диаметр ведомого вала:     d2 = %d мм\n\n", reducer(6).d2);

fprintf("  Межосевое расстояние: aw = %.3f мм\n\n", reducer(6).aw);

% ======= 14. ОПОРЫ САТЕЛЛИТОВ =======
fprintf('================================================================================\n');
fprintf('                      14. ОПОРЫ САТЕЛЛИТОВ                                     \n');
fprintf('================================================================================\n\n');

reducer(6).Fa = (2 * reducer(6).T1 * 1000 * reducer(6).Kc) / (reducer(6).da * reducer(6).C);
reducer(6).Fn = 2 * reducer(6).Fa;
reducer(6).l = 33;
reducer(6).q = reducer(6).Fn / reducer(6).l;
reducer(6).M_bend = reducer(6).q * reducer(6).l ^ 2 / 8;
reducer(6).sigma_axis = 120;
reducer(6).d_axis = 0.5 * floor(2 * ((32 * reducer(6).M_bend) / (pi * reducer(6).sigma_axis)) ^ (1 / 3));

fprintf('14.1. Усилия на осях сателлитов:\n');
fprintf("  Окружная сила: Fa = %.3f Н\n", reducer(6).Fa);
fprintf("  Нормальная сила: Fn = %.3f Н\n", reducer(6).Fn);
fprintf("  Погонная нагрузка: q = %.3f Н/мм\n", reducer(6).q);
fprintf("  Изгибающий момент: M_bend = %.3f Н·мм\n", reducer(6).M_bend);
fprintf("  Допускаемое напряжение оси: [sigma_axis] = %.2f МПа\n", reducer(6).sigma_axis);
fprintf("  Требуемый диаметр оси: d_axis = %.3f мм\n\n", reducer(6).d_axis);

% ======= ИТОГОВАЯ СВОДКА =======
fprintf('================================================================================\n');
fprintf('                           ИТОГОВАЯ СВОДКА ПАРАМЕТРОВ                          \n');
fprintf('================================================================================\n\n');

fprintf('Основные параметры редуктора:\n');
fprintf('  ┌─────────────────────────────────────────────────────────────────────────┐\n');
fprintf('  │ Параметр                          │ Значение          │ Ед. изм.      │\n');
fprintf('  ├─────────────────────────────────────────────────────────────────────────┤\n');
fprintf('  │ Передаточное отношение (u)        │ %15.3f │               │\n', reducer(6).u);
fprintf('  │ Модуль зацепления (m)             │ %15.2f │ мм            │\n', reducer(6).m);
fprintf('  │ Число зубьев солнечного колеса (za)│ %15.0f │               │\n', reducer(6).za);
fprintf('  │ Число зубьев сателлита (zc)       │ %15.0f │               │\n', reducer(6).zc);
fprintf('  │ Число зубьев эпицикла (zb)        │ %15.0f │               │\n', reducer(6).zb);
fprintf('  │ Число сателлитов (C)              │ %15d │               │\n', reducer(6).C);
fprintf('  │ Диаметр солнечного колеса (da)    │ %15.3f │ мм            │\n', reducer(6).da);
fprintf('  │ Диаметр сателлита (dc)            │ %15.3f │ мм            │\n', reducer(6).dc);
fprintf('  │ Диаметр эпицикла (db)             │ %15.3f │ мм            │\n', reducer(6).db);
fprintf('  │ Межосевое расстояние (aw)         │ %15.3f │ мм            │\n', reducer(6).aw);
fprintf('  │ Ширина солнечного колеса (ba)     │ %15.3f │ мм            │\n', reducer(6).ba);
fprintf('  │ Ширина сателлита (bc)             │ %15.3f │ мм            │\n', reducer(6).bc);
fprintf('  │ Ширина эпицикла (bb)              │ %15.3f │ мм            │\n', reducer(6).bb);
fprintf('  │ Окружная скорость (V)             │ %15.3f │ м/с           │\n', reducer(6).V);
fprintf('  │ КПД редуктора (eta)               │ %15.4f │               │\n', reducer(6).eta);
fprintf('  │ Момент на ведущем валу (T1)       │ %15.3f │ Н·м           │\n', reducer(6).T1);
fprintf('  │ Момент на выходном валу (T2)      │ %15.3f │ Н·м           │\n', reducer(6).T2);
fprintf('  │ Контактные напряжения (sigma_H)   │ %15.2f │ МПа           │\n', reducer(6).sigmah);
fprintf('  │ Допускаемые контактные [sigma_H]  │ %15.2f │ МПа           │\n', reducer(6).sigmaH);
fprintf('  │ Изгибные напряжения (sigma_F)     │ %15.2f │ МПа           │\n', reducer(6).sigmaFC);
fprintf('  │ Диаметр ведущего вала (d1)        │ %15d │ мм            │\n', reducer(6).d1);
fprintf('  │ Диаметр ведомого вала (d2)        │ %15d │ мм            │\n', reducer(6).d2);
fprintf('  │ Диаметр оси сателлита (d_axis)    │ %15.3f │ мм            │\n', reducer(6).d_axis);
fprintf('  └─────────────────────────────────────────────────────────────────────────┘\n\n');

fprintf('================================================================================\n');
fprintf('                              РАСЧЁТ ЗАВЕРШЁН                                  \n');
fprintf('================================================================================\n');