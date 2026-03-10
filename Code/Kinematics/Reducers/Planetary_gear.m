clc

fprintf("Параметры выбранного %.0f двигателя:\n" + ...
            "Требуемая скорость: nreq = %.3f rpm\n" + ...
            "Номинальная скорость: nном = %.3f rpm\n" + ...
            "Номинальная мощность: P_max = %.3f Вт\n" + ...
            "\n", 1, semimotor(9).nreq, semimotor(9).nmot, semimotor(9).N);

%=======4.КИНЕМАТИЧЕСКИЙ_РАСЧЕТ_ПРИВОДА=======

% 4.1 Выбор двигателя и определение относительного передаточного числа

reducer(1).u = semimotor(9).nmot / semimotor(9).nreq; % передаточное отношение редуктора
reducer(1).k = reducer(1).u -1; % конструктивная характеристика
reducer(1).C = 3; % k = 3,64 => число сателитов 3
reducer(1).t = 5000; % время работы привода
reducer(1).na = semimotor(9).nmot; % ВОТ ТУТ НАДО ПЕРЕСМОТРЕТЬ

reducer(1).za = 18; % число зубьев на солнечной шестерне



%4.2. Подбор числа зубьев колес редуктора

% Создаем массивы для выбора зубьев колес
col1 = zeros(5, 1);  % Первый столбец
col2 = zeros(5, 1);  % Второй столбец
col3 = zeros(5, 1);  % Третий столбец
col4 = zeros(5, 1);  % Четвертый столбец
col5 = zeros(5, 1);  % Пятый столбец
col6 = zeros(5, 1);  % Шестой столбец
col7 = zeros(5, 1);  % Седьмой столбец

% Заполняем с помощью цикла
za = reducer(1).za;
for i = 1:5
    col1(i) = za;
    col2(i) = za * reducer(1).k;
    [zb1, zb2] = nearestDivisibleBy3(za * reducer(1).k);
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

% Создаем таблицу
T = table(col1, col2, col3, col4, col5, col6, col7, 'VariableNames', ...
    {'za', 'zb = za * k', 'zb (кратно С)', 'k* = zb/za', 'u = 1 + k*', 'gamma = (zb + za)/2', 'zc = (zb - za)/2'});
disp(T);

% Окончательно число зубьев солнечного колеса, а по нему и числа зубьев
% остальных колес, установим после определения диаметра солнечного колеса da
% и выбора величины модуля зацепления m. 



% 4.3. Определение относительной частоты вращения колес

reducer(1).nah = semimotor(9).nmot - semimotor(9).nreq;
reducer(1).nbh = 0 - semimotor(9).nreq;
reducer(1).nch = -(semimotor(9).nmot - semimotor(9).nreq) * 2 / (reducer(1).k - 1);



% 4.4. Определение КПД редуктора

reducer(1).etarel = (1 + reducer(1).k * 0.99 * 0.97) / (1  + reducer(1).k);





%=======5.ОПРЕДЕЛЕНИЕ_МОМЕНТОВ_И_МОЩНОСТИ_НА_ВАЛАХ=======

reducer(1).etamuf = 0.99;
reducer(1).eta = reducer(1).etarel * reducer(1).etamuf; % с муфтой
reducer(1).Ndvig = semimotor(9).N / reducer(1).eta; % Реальная мощность на двигателе с учетом потерь
reducer(1).N1 = reducer(1).Ndvig * reducer(1).etamuf; % Мощность на ведущем валу
reducer(1).T1 = 9.550 * reducer(1).N1 / semimotor(9).nmot; % Момент на ведущем валу
reducer(1).Ta = reducer(1).T1;
reducer(1).N2 = reducer(1).Ndvig * reducer(1).etarel; % Мощность на выходном валу
reducer(1).T2 = 9.550 * reducer(1).N2 / semimotor(9).nreq; % Момент на выходном валу





%=======6.ОПРЕДЕЛЕНИЕ_ОСНОВНЫХ_РАЗМЕРОВ_ПЛАНЕТАРНОЙ_ПЕРЕДАЧИ=======

% 6.1. Выбор материалов колес редуктора

reducer(1).HBg = 290; %сталь 40Х, термообработка – улучшение, твердость 280…300НВ
reducer(1).HBw = 270; %сталь 40Х, термообработка – улучшение, твердость 260…280НВ



% 6.2. Определение допускаемых напряжений

% 6.2.1. Базовые числа циклов перемены напряжений
% при расчете на контактную прочность (Приложение 3)
reducer(1).NHO1 = 24 * 10^6; % шестерня
reducer(1).NHO2 = 21 * 10^6; % колесо (сателит)
% при расчете на изгиб (Приложение 3)
reducer(1).NFO1 = 4 * 10^6; % шестерня
reducer(1).NFO2 = 4 * 10^6; % колесо (сателит)

% 6.2.2. Эквивалентные числа циклов перемены напряжений:
reducer(1).t1 = 0.3 * reducer(1).t; % время работы привода в различных режимах
reducer(1).t2 = 0.3 * reducer(1).t;
reducer(1).t3 = 0.4 * reducer(1).t;
reducer(1).mode = [1, 0.6, 0.3];
reducer(1).tHE = 0;

% эквивалентное время работы
for i = 1:3
    reducer(1).tHE = reducer(1).tHE + reducer(1).t1 * reducer(1).mode(i)^3;
end

reducer(1).NHE2 = abs(60 * reducer(1).nch * reducer(1).tHE);
reducer(1).NHE1 = 60 * reducer(1).nah * reducer(1).C * reducer(1).tHE;

% 6.2.3. Коэффициенты долговечности:
% пока пропустим

% 6.2.3. Пределы выносливости (Приложение 2, табл. 2):
% при расчете на контактную прочность
reducer(1).KHL1 = (reducer(1).NHO1 / reducer(1).NHE1)^(1/6);
if reducer(1).KHL1 < 1
    reducer(1).KHL1 = 1;
end
reducer(1).KHL2 = (reducer(1).NHO2 / reducer(1).NHE2)^(1/6);
if reducer(1).KHL2 < 1
    reducer(1).KHL2 = 1;
end
% ОПЕЧАТКА В МЕТОДЕ, НАДО УТОЧНИТЬ
reducer(1).KFL1 = 1;
reducer(1).KFL2 = 1;
% значения коэффициентов долговечности , KHL KFL , определяемые приведенными
% выше корнями 6-й степени, будут меньше единицы. В этом случае величины этих
% коэффициентов принимают равными единице
reducer(1).sigmaHO1 = 2 * reducer(1).HBg + 70;
reducer(1).sigmaHO2 = 2 * reducer(1).HBw + 70;
% при расчете на изгибную прочность
reducer(1).sigmaFO1 = 1.8 * reducer(1).HBg;
reducer(1).sigmaFO2 = 1.8 * reducer(1).HBw;

% 6.2.4. Допускаемые напряжения: 
% при расчете на контактную прочность

reducer(1).SH1 = 1.1; % Коэффициенты безопасности SH1 и SH2 для однородных материалов принимаются одинаковыми
reducer(1).SH2 = 1.1;
reducer(1).SF1 = 1.75; % Коэффициенты безопасности SF1 и SF2 для однородных материалов принимаются одинаковыми
reducer(1).SF2 = 1.75;
reducer(1).sigmaH1 = reducer(1).sigmaHO1 / reducer(1).SH1 * reducer(1).KHL1;
reducer(1).sigmaH2 = reducer(1).sigmaHO2 / reducer(1).SH2 * reducer(1).KHL2;
reducer(1).sigmaF1 = reducer(1).sigmaFO1 / reducer(1).SF1 * reducer(1).KFL1;
reducer(1).sigmaF2 = reducer(1).sigmaFO2 / reducer(1).SF2 * reducer(1).KFL2;
reducer(1).sigmaH = min(reducer(1).sigmaH1, reducer(1).sigmaH2); % расчетное значение допускаемого напряжения принимается равным наименьшему, т.е. для сателлита





%=======7.ОПРЕДЕЛЕНИЕ_РАЗМЕРОВ_КОЛЕС_РЕДУКТОРА=======

reducer(1).Kd = 780; % МПа1/3 – коэффициент, зависящий от механических характеристик,
% формы сопрягаемых поверхностей и длины контактной линии зацепления,
% принимаемый для стальных прямозубых колес равным указанной величине

reducer(1).psibd = 0.6; % принятая величина коэффициента ширины колеса по диаметру.
% Относительная ширина колес в планетарном редукторе ψ ≈ (0,2)0,3...0,4(0,6) bd
% выбирается в зависимости от точности изготовления и монтажа. Чем меньше ψbd,
% тем равномернее нагружается зуб по ширине колеса, но радиальные размеры колеса при этом увеличиваются.

reducer(1).uHaC = (reducer(1).k - 1)/2; % передаточное число от солнечного колеса к сателлиту в относительном движении
reducer(1).uHcb = abs(reducer(1).nch / reducer(1).nbh); % передаточное число от солнечного колеса к сателлиту в относительном движении

reducer(1).Kc = 1.1;% коэффициент, учитываающий неравномерность нагрузки сателлитов

reducer(1).Khbetta = get_Khbetta_Kfbetta(reducer(1).psibd, reducer(1).HBg, reducer(1).HBw, 'VI', 'KH'); % коэффициент концентрации нагрузки,
% т.е. коэффициент неравномерности распределения нагрузки по длине контактной линии

reducer(1).Tap =  reducer(1).Ta * reducer(1).Khbetta * reducer(1).Kc / reducer(1).C; %расчетный момент
% на солнечном колесе с учетом многопоточности между тремя сателлитами

reducer(1).da = reducer(1).Kd * ((reducer(1).Tap * (reducer(1).uHaC + 1)) /...
    (reducer(1).psibd * (reducer(1).sigmaH ^ 2) * reducer(1).uHaC))^(1/3); % диаметр солнечного колеса

% Создаем массивы для выбора модуля зацепления
row_names = {'za', 'mрасч = da/za', 'mстанд'};
col_names = {'1', '2', '3', '4', '5'};
data = [1, 2, 3; 2, 3, 4];

% Создаем пустую таблицу
T2 = table('Size', [3, 5], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', col_names, ...
    'RowNames', row_names);

% Заполнение через цикл
za = reducer(1).za;
arrraay_of_m = [0, 0, 0, 0, 0];
reducer(1).m = 10;
the_chosen_m_ind = 0;
for i = 1:5
    T2{1, i} = za;
    T2{2, i} = reducer(1).da / za;
    [T2{3, i}, modu] = getStandardModule(reducer(1).da / za);
    arrraay_of_m(i) = modu^3 * (T2{3, i} - T2{2, i})/T2{3, i} + 0.001 * i;
    if reducer(1).m > arrraay_of_m(i)
        reducer(1).m = arrraay_of_m(i);
        the_chosen_m_ind = i;
    end
    za = za + 3;
end

%  параметры солнечного колеса
reducer(1).za = T2{1, the_chosen_m_ind};
reducer(1).m = T2{3, the_chosen_m_ind};
reducer(1).da = reducer(1).m * reducer(1).za;
disp(T2);

% параметры остальных колес

% число зубьев эпицикла и сателитов соответственно
reducer(1).zb = col3(the_chosen_m_ind);
reducer(1).zc = col7(the_chosen_m_ind);

% диаметры эпицикла и сателитов соответственно
reducer(1).da = reducer(1).m * reducer(1).za;
reducer(1).db = reducer(1).m * reducer(1).zb;
reducer(1).dc = reducer(1).m * reducer(1).zc;

% ширины солнечного колеса, сателитов и эпицикла
reducer(1).bb = reducer(1).psibd * reducer(1).da;
reducer(1).ba = reducer(1).bb + 4;
reducer(1).bc = reducer(1).bb + 4;

% Окружная скорость V солнечного колеса, М*с^-1
reducer(1).V = pi * reducer(1).da * reducer(1).na / 60000;

fprintf("Число зубьев солнечного колеса: %.3f\n", reducer(1).za);
fprintf("Модуль солнечного колеса: %.3f\n", reducer(1).m);
fprintf("Диаметр делительной окружности солнечного колеса: %.3f\n", reducer(1).da);
fprintf("Толщина солнечного колеса: %.3f\n\n", reducer(1).ba);

fprintf("Число зубьев сателита: %.3f\n", reducer(1).zc);
fprintf("Модуль сателита: %.3f\n", reducer(1).m);
fprintf("Диаметр делительной окружности сателита: %.3f\n", reducer(1).dc);
fprintf("Толщина сателита: %.3f\n\n", reducer(1).bc);

fprintf("Число зубьев эпицикла: %.3f\n", reducer(1).zb);
fprintf("Модуль эпицикла: %.3f\n", reducer(1).m);
fprintf("Диаметр делительной окружности эпицикла: %.3f\n", reducer(1).db);
fprintf("Толщина эпицикла: %.3f\n\n", reducer(1).bb);

reducer(1).aw = (reducer(1).da + reducer(1).dc) / 2;

fprintf("Межосевое расстояние: %.3f\n\n", reducer(1).aw);





%=======8.ПРОВЕРОЧНЫЙ_РАСЧЕТ_ЗУБЬЕВ_КОЛЕС_ПО_КОНТАКТНЫМ_НАПРЯЖЕНИЯМ=======

reducer(1).Zm = 275; % МПа, коэффициент механических свойств материалов для стальных колес с μ = 0,3 и Е = 2,15·105 МПа
reducer(1).Zh = 1.76; % оэффициент формы сопряжения поверхностей для прямозубых колес (β = 0°) и углом зацепления α = 20°
reducer(1).epsilona = 1.88 - 3.2 * (1 / reducer(1).za + 1 / reducer(1).zc);
reducer(1).Ze = sqrt((4 - reducer(1).epsilona) / 3); % коэффициент учета длины линии зацепления

% Определение коэфов K
[reducer(1).grade, desc] = getAccuracyGrade(reducer(1).V, 'cylindrical');
[reducer(1).Kha, reducer(1).Kfa] = get_K_Ha_K_Fa(reducer(1).V, reducer(1).grade);
[reducer(1).Khv, reducer(1).Kfv] = getDynamicCoefficients(reducer(1).V, reducer(1).grade, 'a', 'straight');
% Тут получаем то значение, которое должны были бы получить при данной скорости
reducer(1).Khc = 1.1; %  при плавающем солнечном колесе и трех сателлитах (см. п. 7)

% Расчет действующих контактных напряжений в полюсе наружного зацепления (солнце – сателлит)  
reducer(1).sigmah = reducer(1).Zm * reducer(1).Zh * reducer(1).Ze * ...
    sqrt((2 * reducer(1).Tap * reducer(1).Khbetta * reducer(1).Khv * reducer(1).Kha * (reducer(1).uHaC + 1) * 1000) / ...
    (reducer(1).bb * reducer(1).da ^ 2 * reducer(1).uHaC * reducer(1).C));

if reducer(1).sigmah <= reducer(1).sigmaH
    fprintf("Допустимость принятых размеров колес редуктора подтверждается\n");
else
    fprintf("Допустимость принятых размеров колес редуктора НЕ подтверждается\n");
end






%=======9.ПРОВЕРОЧНЫЙ_РАСЧЕТ_КОЛЕС_ПО_ИЗГИБНЫМ_НАПРЯЖЕНИЯМ=======

% 9.1. Проверочный расчет солнечного колеса

reducer(1).Kfbetta = get_Khbetta_Kfbetta(reducer(1).psibd, reducer(1).HBg, reducer(1).HBw, 'V', 'KF'); % коэффициент концентрации нагрузки,
% т.е. коэффициент неравномерности распределения нагрузки по длине контактной линии
reducer(1).YF1 = get_YF(reducer(1).za, 0);
reducer(1).YF2 = get_YF(reducer(1).zc, 0);

reducer(1).Ke = 0.92; % Коэффициент точности взаимодействия зубчатых колес
% равен Kε ≈ 0,92…0,97(1,0) и увеличивается для зубьев, выполненных с
% более высокой точностью. Для 8-го класса точности можно принять Kε = 0,92

reducer(1).mt = reducer(1).m; % Торцевой модуль зацепления

% Расчет ведется для более слабого зуба (солнца или сателлита), который определяется путем сравнения отношений
if reducer(1).sigmaF1 / reducer(1).YF1 > reducer(1).sigmaF2 / reducer(1).YF2
    reducer(1).sigmaFC = reducer(1).YF2 * (2 * reducer(1).Tap * reducer(1).Kfbetta * reducer(1).Kfv * ...
        reducer(1).Kfa * reducer(1).Kc * 1000) / (reducer(1).C * reducer(1).Ke * reducer(1).ba * ...
        reducer(1).epsilona * reducer(1).da * reducer(1).mt);
    if reducer(1).sigmaFC <= reducer(1).sigmaF2
        fprintf("Проверка на изгибную прочность подтверждается\n");
    else
        fprintf("Проверка на изгибную прочность НЕ подтверждается\n");
    end
else
    reducer(1).sigmaFC = reducer(1).YF1 * (2 * reducer(1).Tap * reducer(1).Kfbetta * reducer(1).Kfv * ...
        reducer(1).Kfa * reducer(1).Kc * 1000) / (reducer(1).C * reducer(1).Ke * reducer(1).ba * ...
        reducer(1).epsilona * reducer(1).da * reducer(1).mt);
    if reducer(1).sigmaFC <= reducer(1).sigmaF1
        fprintf("Проверка на изгибную прочность подтверждается\n");
    else
        fprintf("Проверка на изгибную прочность НЕ подтверждается\n");
    end
end




% 9.2. Проверочный расчет, выбор материала и твердости эпициклического колеса

% Определяем окружную скорость vC (м/c) в зацеплении солнцесателлит по формуле
reducer(1).Vc = abs(pi * reducer(1).dc * reducer(1).nch / 60000);
reducer(1).epsilona_e = 1.88 - 3.2 * (1 / reducer(1).zc - 1 / reducer(1).zb); % Коэффициент торцового перекрытия
reducer(1).Ze_e = sqrt((4 - reducer(1).epsilona_e) / 3); % коэффициент учета длины линии зацепления
reducer(1).Tb =  2 * reducer(1).T2 * reducer(1).Khbetta * reducer(1).Kc / reducer(1).C; %расчетный момент
% на эпицикле с учетом многопоточности между тремя сателлитами 
%!!!ПРОВЕРИТЬ!!!

[reducer(1).grade_e, desc] = getAccuracyGrade(reducer(1).Vc, 'cylindrical');

[reducer(1).Kha_e, reducer(1).Kfa_e] = get_K_Ha_K_Fa(reducer(1).Vc, reducer(1).grade_e);
[reducer(1).Khv_e, reducer(1).Kfv_e] = getDynamicCoefficients(reducer(1).Vc, reducer(1).grade_e, 'a', 'straight');
reducer(1).uCb = reducer(1).zb / reducer(1).zc;

% Расчет проводится из условия контактной выносливости, при этом рассматривается полюс зацепления сателлит-эпицикл
reducer(1).sigmah_e = reducer(1).Zm * reducer(1).Zh * reducer(1).Ze_e * ...
    sqrt((2 * reducer(1).Tb * reducer(1).Khbetta * reducer(1).Khv_e * reducer(1).Kha * reducer(1).Kc ...
    *  (reducer(1).uHcb - 1) * 1000) / (reducer(1).C * reducer(1).bb * reducer(1).dc * reducer(1).db ...
    * reducer(1).uCb));

% предел контактной выносливости, соответствующий базовому числу перемены напряжений
reducer(1).sigmah0_e = reducer(1).sigmah_e / reducer(1).KHL2 * reducer(1).SH2;

% твердость поверхности зубьев эпицикла
reducer(1).HB_e = (reducer(1).sigmah_e - 70) / 2;

%!!!ДОБАВИТЬ ВЫВОД!!!
% Это позволяет сделать вывод о том, что термообработка эпициклического колеса не требуется





%=======10.ПРОВЕРКА_ПРОЧНОСТИ_КОЛЕС_ПРИ_ПЕРЕГРУЗКЕ=======

% коэффициент перегрузки
reducer(1).overload = 2;

% расчет по контактным напряжениям
%!!!ОТКУДА ЭТО ВЗЯЛОСЬ???!!!
reducer(1).sigmah_max = 2 * reducer(1).sigmah * sqrt(reducer(1).overload);
reducer(1).sigmaf_max = 2 * reducer(1).sigmaFC * reducer(1).overload;

%!!!ОТКУДА ЭТО ВЗЯЛОСЬ???!!!
if (reducer(1).sigmah_max <= 2.8 * reducer(1).sigmaHO1) && (reducer(1).sigmaf_max <= 0.8 * reducer(1).sigmaHO2)
    fprintf("Прочность конструкции при перегрузках обеспечена\n");
else
    fprintf("Прочность конструкции при перегрузках НЕ обеспеченая\n");
end





%=======11.РАСЧЕТ_ОТКРЫТОЙ_ПЕРЕДАЧИ=======

% пока пропустим





%=======12.ПРЕДВАРИТЕЛЬНЫЙ_РАСЧЕТ_ВАЛОВ_И_ОПРЕДЕЛЕНИЕ_МЕЖОСЕВОГО_РАССТОЯНИЯ_aw=======

% Пониженная величина допускаемого напряжения
reducer(1).tau = 15; % МПа

% Диаметр ведущего
reducer(1).d1 = ((reducer(1).T1 * 1000) / (0.2 * reducer(1).tau)) ^ (1/3);
reducer(1).d1 = floor(reducer(1).d1);

% С учетом вала выбранного нами электродвигателя d == 42 мм [5] и размеров стандартной муфты МУВП
reducer(1).d1 = 40; % мм - диаметр ведущего вала

% Диаметр ведомого вала
reducer(1).d2 = ((reducer(1).T2 * 1000) / (0.2 * reducer(1).tau)) ^ (1/3);
reducer(1).d2 = floor(reducer(1).d2);

% Межосевое расстояние передачи
reducer(1).aw = (reducer(1).da + reducer(1).dc) / 2;

fprintf("Диаметр ведущего вала: %.3f\n", reducer(1).d1);
fprintf("Диаметр ведомого вала: %.3f\n", reducer(1).d2);
fprintf("Межосевое расстояние: %.3f\n\n", reducer(1).aw);





%=======13.ЭСКИЗНОЕ_ПРОЕКТИРОВАНИЕ_РЕДУКТОРА=======

% ручками





%=======14.ОПОРЫ_САТЕЛИТОВ=======

% 14.1. Определение усилий, действующих на оси сателлитов

reducer(1).Fa = (2 * reducer(1).T1 * 1000 * reducer(1).Kc) / (reducer(1).da * reducer(1).C);
reducer(1).Fn = 2 * reducer(1).Fa ;

% 14.2. Расчет оси сателлита

reducer(1).l = 33; % Пролет оси (из эскиза)
reducer(1).q = reducer(1).Fn / reducer(1).l;
reducer(1).M_bend = reducer(1).q * reducer(1).l ^ 2 / 8; % Изгибающий момент в середине пролета (опасное сечение)
reducer(1).sigma_axis = 120; % Н/мм^2
% Требуемый диаметр оси
reducer(1).d_axis = 0.5 * floor(2 * ((32 * reducer(1).M_bend) / (pi * reducer(1).sigma_axis)) ^ (1 / 3));





%=======15.ВЫБОР_ПОДШИПНИКОВ_САТЕЛИТОВ=======

% Подшипники воспринимают только радиальную нагрузку
reducer(1).Frmax = reducer(1).Fn;
reducer(1).V_podsh = 1.2; %  коэффициент вращения кольца (вращение наружного кольца подшипника)
reducer(1).Ksigma_podsh = 1.3; % оэффициент безопасности
reducer(1).KT_podsh = 1; % 1 – температурный коэффициент в случае, когда температура деталей t = 70÷125°C
reducer(1).KN_podsh = 1; % коэффициент режима работы, учитывающий переменность нагрузки
% !!! ЧЕКНУТЬ ГОСТ
reducer(1).Pe_podsh = reducer(1).V_podsh * reducer(1).Frmax * reducer(1).Ksigma_podsh * ...
    reducer(1).KT_podsh * reducer(1).KN_podsh; % эквивалентная нагрузка на подшипник

reducer(1).Lh_podsh = 0;
ind = 1;
ind1 = 1;
ind2 = 25;
% reducer(1).Lh_podsh <= reducer(1).t
while ind < 47
    if ind == 48
        fprintf("Надо расширить библиотеку подшипников.\n");
        break
    end
    if getBearingData(ind, "B") <= reducer(1).bc
        reducer(1).Lh_podsh = (getBearingData(ind, "C") * 1000 / reducer(1).Pe_podsh)^3 * ...
            1000000 / (60 * abs(reducer(1).nch));        
        if reducer(1).Lh_podsh >= reducer(1).t
            if ind <= 24                
                ind1 = ind;
                ind = 25;
            else
                ind2 = ind;
                break
            end
        end
    end
    ind = ind + 1;    
end
reducer(1).c_podsh_ind = 0;
if getBearingData(ind1, "B") > getBearingData(ind2, "B")
    reducer(1).c_podsh_ind = ind1;
else
    reducer(1).c_podsh_ind = ind2;
end

% Выбранный подшипник
fprintf(getBearingData(reducer(1).c_podsh_ind, "code") + " %.3f\n", (getBearingData(reducer(1).c_podsh_ind, "C") * 1000 /...
    reducer(1).Pe_podsh)^3 * 1000000 / (60 * abs(reducer(1).nch)));
fprintf("Диаметр оси сателлита: %.3f\n", getBearingData(reducer(1).c_podsh_ind, "d"))






%=======16.ПРОВЕРОЧНЫЙ_РАСЧЕТ_ВАЛОВ=======

% 16.1. Расчет ведущего вала

reducer(1).Fa = (2 * reducer(1).T1 * 1000 * reducer(1).Kc) / (reducer(1).da * reducer(1).C);
reducer(1).Fn = 2 * reducer(1).Fa ;

% 16.2. Расчет ведомого вала

reducer(1).l = 33; % Пролет оси (из эскиза)
reducer(1).q = reducer(1).Fn / reducer(1).l;
reducer(1).M_bend = reducer(1).q * reducer(1).l ^ 2 / 8; % Изгибающий момент в середине пролета (опасное сечение)
reducer(1).sigma_axis = 120; % Н/мм^2

%=======16.ПРОВЕРОЧНЫЙ_РАСЧЕТ_ВАЛОВ=======

% 16.1. Расчет ведущего вала (Быстроходный вал)
% Примечание: Размеры a, b, c берутся из эскизного проекта (п. 13).
% В данном коде используем значения из примера методички для демонстрации расчета.

fprintf('\n======= 16. ПРОВЕРОЧНЫЙ РАСЧЕТ ВАЛОВ =======\n');
fprintf('16.1. Расчет ведущего вала:\n');

% Геометрические размеры участков вала (из эскиза, пример методички)
reducer(1).a_shaft = 65; % мм
reducer(1).b_shaft = 55; % мм (расстояние между опорами)
reducer(1).c_shaft = 108; % мм (консольный участок под муфту)

% Силы, действующие на вал
% FM - консольная нагрузка от муфты
reducer(1).FM = 125 * (reducer(1).Ta)^(1/2); % Н

% Реакции опор (схема: две опоры, консольная нагрузка)
reducer(1).Rbx = (reducer(1).Fn * (reducer(1).b_shaft + reducer(1).a_shaft) +...
    reducer(1).FM * reducer(1).c_shaft) / reducer(1).b_shaft; % Н (из примера методички)
reducer(1).Rcx = (reducer(1).Fn * reducer(1).a_shaft  +...
    reducer(1).FM * (reducer(1).b_shaft + reducer(1).c_shaft)) / reducer(1).b_shaft; % Н (из примера методички)

% Изгибающие моменты в опасных сечениях
reducer(1).Mbx = reducer(1).Fn * reducer(1).a_shaft * 1e-3; % Нм (в сечении B)
reducer(1).Mcx = reducer(1).FM * reducer(1).c_shaft * 1e-3; % Нм (в сечении C, от муфты)


% Выбор подшипников ведущего вала (по конструктивным соображениям и диаметру)
reducer(1).d1_verif = reducer(1).d1 + 10; % мм (диаметр в опасном сечении)

% ДОПИСАТЬ ВЫБОР ПОДШИПНИКА

% Геометрические характеристики сечения
reducer(1).W_shaft = (pi * reducer(1).d1_verif^3) / 32; % мм^3 (момент сопротивления изгибу)
reducer(1).Wp_shaft = (pi * reducer(1).d1_verif^3) / 16; % мм^3 (момент сопротивления кручению)

% Напряжения (амплитудные), МПа
% tau_a = T / (2 * Wp)
%Амплитуда τa и среднее τm напряжение отнулевого цикла касательных напряжений от действия крутящего момента
reducer(1).tau_a = (reducer(1).Ta * 1000) / (2 * reducer(1).Wp_shaft); % МПа
reducer(1).tau_m = reducer(1).tau_a;
% sigma_a = M / W
% Амплитуда нормальных напряжений изгиба
reducer(1).sigma_a = (reducer(1).Mbx * 1000) / reducer(1).W_shaft; % МПа

% Коэффициенты концентрации напряжений и запаса прочности (из методички для стали 40Х)
% Пределы выносливости
reducer(1).sigma_minus1 = 410; % МПа (для изгиба)
reducer(1).tau_minus1 = 240; % МПа (для кручения)

reducer(1).K_sigma_D = 4.45; 
reducer(1).K_tau_D = 3.15;

% Пределы выносливости
reducer(1).sigma_D = reducer(1).sigma_minus1 / (reducer(1).K_sigma_D);
reducer(1).tau_D = reducer(1).tau_minus1 / (reducer(1).K_tau_D);

% Запасы прочности по нормальным и касательным напряжениям
reducer(1).S_sigma = reducer(1).sigma_minus1 / (reducer(1).K_sigma_D * reducer(1).sigma_a);
reducer(1).S_tau = reducer(1).tau_minus1 / (reducer(1).K_tau_D * reducer(1).tau_a);

% Общий запас прочности
reducer(1).S_shaft1 = (reducer(1).S_sigma * reducer(1).S_tau) / sqrt(reducer(1).S_sigma^2 + reducer(1).S_tau^2);

if reducer(1).S_shaft1 >= 2.5
    fprintf('  -> Прочность ведущего вала обеспечена (S >= 2.5)\n');
else
    fprintf('  -> Прочность ведущего вала НЕ обеспечена (S < 2.5)\n');
end

% Выбор подшипников ведущего вала (пример методички №210)
% Ищем подшипник с внутренним диаметром >= d1_verif
reducer(1).bear1_code = '210';
reducer(1).bear1_d = 50;
reducer(1).bear1_D = 90;
reducer(1).bear1_B = 20;
reducer(1).bear1_C = 35.1; % кН
fprintf('  Выбран подшипник ведущего вала: %s (d=%d, D=%d, B=%d, C=%.1f кН)\n', ...
    reducer(1).bear1_code, reducer(1).bear1_d, reducer(1).bear1_D, reducer(1).bear1_B, reducer(1).bear1_C);


% 16.2. Расчет ведомого вала (Тихоходный вал)
fprintf('\n16.2. Расчет ведомого вала:\n');

% Диаметр выходного участка (из п. 12)
reducer(1).d2_verif = reducer(1).d2; % мм (обычно 55 мм в примере)

% Нагрузки
reducer(1).T2_check = reducer(1).T2; % Нм
% Консольная нагрузка Fr (по ГОСТ 16162-78 или методичке)
% В методичке принято Fr = 4500 Н для большего диапазона использования
reducer(1).Fr_out = 200 * (reducer(1).T2_check)^(1/2); % Н; % Н
% Расстояние от середины шейки до опасного сечения (из эскиза)
reducer(1).c_out = 110; % мм

% Расчетные усилия в опасном сечении
reducer(1).M_bend_out = reducer(1).Fr_out * reducer(1).c_out * 1e-3; % Нм
reducer(1).M_eq_out = sqrt(reducer(1).M_bend_out^2 + reducer(1).T2_check^2); % Приведенный момент, Нм

% Проверка по статической прочности (упрощенно)
% sigma_eq = M_eq / (0.1 * d^3)
reducer(1).sigma_eq_out = (reducer(1).M_eq_out * 1000) / (0.1 * reducer(1).d2_verif^3); % МПа

% Допускаемое напряжение (предел усталостной прочности с учетом коэффициентов)
% В методичке рассчитано [sigma] = 89 МПа для стали 40Х
reducer(1).sigma_allow_out = 89; % МПа

fprintf('  Диаметр ведомого вала: %.1f мм\n', reducer(1).d2_verif);
fprintf('  Изгибающий момент: %.2f Нм\n', reducer(1).M_bend_out);
fprintf('  Крутящий момент: %.2f Нм\n', reducer(1).T2_check);
fprintf('  Приведенный момент: %.2f Нм\n', reducer(1).M_eq_out);
fprintf('  Эквивалентное напряжение: %.2f МПа\n', reducer(1).sigma_eq_out);
fprintf('  Допускаемое напряжение: %.2f МПа\n', reducer(1).sigma_allow_out);

if reducer(1).sigma_eq_out <= reducer(1).sigma_allow_out
    fprintf('  -> Прочность ведомого вала обеспечена\n');
else
    fprintf('  -> Прочность ведомого вала НЕ обеспечена\n');
end

% Выбор подшипников ведомого вала
% В методичке для d2=55 мм (посадочное отверстие подшипника может быть больше) 
% выбран подшипник №7000124 (d=105, D=160, B=18) - сверхлегкая серия, т.к. вал планетарный короткий и жесткий.
% Однако стандартный подбор обычно идет под диаметр вала. 
% Для примера методички запишем данные из текста.
reducer(1).bear2_code = '7000124';
reducer(1).bear2_d = 105; % мм (посадочный диаметр в корпусе водила/вала)
reducer(1).bear2_D = 160; % мм
reducer(1).bear2_B = 18; % мм
reducer(1).bear2_C = 52.0; % кН

fprintf('  Выбран подшипник ведомого вала: %s (d=%d, D=%d, B=%d, C=%.1f кН)\n', ...
    reducer(1).bear2_code, reducer(1).bear2_d, reducer(1).bear2_D, reducer(1).bear2_B, reducer(1).bear2_C);

fprintf('\n======= КОНЕЦ РАСЧЕТА ВАЛОВ =======\n');

