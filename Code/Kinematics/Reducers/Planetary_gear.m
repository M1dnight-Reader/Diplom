clc

fprintf("Параметры выбранного %.0f двигателя:\n" + ...
            "Требуемая скорость: nreq = %.3f rpm\n" + ...
            "Номинальная скорость: nном = %.3f rpm\n" + ...
            "Номинальная мощность: P_max = %.3f Вт\n" + ...
            "\n", 1, motor(1).nreq, motor(1).nmot, motor(1).N);

%=======4.КИНЕМАТИЧЕСКИЙ_РАСЧЕТ_ПРИВОДА=======

% 4.1 Выбор двигателя и определение относительного передаточного числа

reducer(1).u = motor(1).nmot / motor(1).nreq; % передаточное отношение редуктора
reducer(1).k = reducer(1).u -1; % конструктивная характеристика
reducer(1).C = 3; % k = 3,64 => число сателитов 3
reducer(1).t = 5000; % время работы привода
reducer(1).na = motor(1).nmot; % ВОТ ТУТ НАДО ПЕРЕСМОТРЕТЬ

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

reducer(1).nah = motor(1).nmot - motor(1).nreq;
reducer(1).nbh = 0 - motor(1).nreq;
reducer(1).nch = -(motor(1).nmot - motor(1).nreq) * 2 / (reducer(1).k - 1);



% 4.4. Определение КПД редуктора

reducer(1).etarel = (1 + reducer(1).k * 0.99 * 0.97) / (1  + reducer(1).k);





%=======5.ОПРЕДЕЛЕНИЕ_МОМЕНТОВ_И_МОЩНОСТИ_НА_ВАЛАХ=======

reducer(1).etamuf = 0.99;
reducer(1).eta = reducer(1).etarel * reducer(1).etamuf; % с муфтой
reducer(1).Ndvig = motor(1).N / reducer(1).eta; % Реальная мощность на двигателе с учетом потерь
reducer(1).N1 = reducer(1).Ndvig * reducer(1).etamuf; % Мощность на ведущем валу
reducer(1).T1 = 9.550 * reducer(1).N1 / motor(1).nmot; % Момент на ведущем валу
reducer(1).Ta = reducer(1).T1;
reducer(1).N2 = reducer(1).Ndvig * reducer(1).etarel; % Мощность на выходном валу
reducer(1).T2 = 9.550 * reducer(1).N2 / motor(1).nreq; % Момент на выходном валу





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





%=======14.ВЫБОР_ПОДШИПНИКОВ_САТЕЛИТОВ=======



