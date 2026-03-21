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