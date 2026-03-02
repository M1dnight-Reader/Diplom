function [K_Ha, K_Fa] = get_K_Ha_K_Fa(V, accuracy_grade)
% getLoadDistributionBetweenTeeth - Коэффициенты K_Ha и K_Fa
% (неравномерность распределения нагрузки между зубьями)
%
% Вход:
%   V              - окружная скорость, м/с
%   accuracy_grade - степень точности (7 или 8, редко 9)
%
% Выход:
%   K_Ha - коэффициент для контактных напряжений
%   K_Fa - коэффициент для изгибных напряжений
%
% Примеры:
%   [KHa, KFa] = getLoadDistributionBetweenTeeth(3.06, 8)  % KHa=1.0, KFa=1.0
%   [KHa, KFa] = getLoadDistributionBetweenTeeth(8, 7)     % KHa=1.25, KFa=1.25

    %% Проверка входных данных
    valid_grades = [7, 8, 9];
    if ~ismember(accuracy_grade, valid_grades)
        error('Степень точности должна быть 7, 8 или 9');
    end
    
    if V < 0
        error('Скорость V должна быть положительной');
    end
    
    %% Таблица значений K_Ha и K_Fa (Приложение 7 методики)
    % Структура: скоростной диапазон -> [K_Ha, K_Fa]
    
    % === 7-я степень точности ===
    K_data(7).V_max = [5, 10, 15];  % верхние границы диапазонов
    K_data(7).K_Ha  = [1.03, 1.05, 1.08];
    K_data(7).K_Fa  = [1.07, 1.20, 1.25];
    
    % === 8-я степень точности ===
    K_data(8).V_max = [5, 10];      % для V > 10 нет данных, экстраполируем
    K_data(8).K_Ha  = [1.07, 1.10];
    K_data(8).K_Fa  = [1.22, 1.30];
    
    % === 9-я степень точности ===
    K_data(9).V_max = [5, 10];
    K_data(9).K_Ha  = [1.13, 1.15];  % приближенно
    K_data(9).K_Fa  = [1.35, 1.40];  % приближенно
    
    %% Выбор данных для заданной степени точности
    V_max = K_data(accuracy_grade).V_max;
    K_Ha_array = K_data(accuracy_grade).K_Ha;
    K_Fa_array = K_data(accuracy_grade).K_Fa;
    
    %% Определение коэффициентов
    % Находим подходящий диапазон скорости
    if V <= V_max(1)
        % Ниже первой границы - берем первое значение
        K_Ha = K_Ha_array(1);
        K_Fa = K_Fa_array(1);
        
    elseif V > V_max(end)
        % Выше последней границы - экстраполируем или берем последнее
        % Для безопасности берем последнее табличное значение
        K_Ha = K_Ha_array(end);
        K_Fa = K_Fa_array(end);
        
        % Или линейная экстраполяция (раскомментировать при необходимости)
        % K_Ha = interp1(V_max, K_Ha_array, V, 'linear', 'extrap');
        % K_Fa = interp1(V_max, K_Fa_array, V, 'linear', 'extrap');
        
    else
        % Внутри диапазона - линейная интерполяция
        K_Ha = interp1(V_max, K_Ha_array, V, 'linear');
        K_Fa = interp1(V_max, K_Fa_array, V, 'linear');
    end
    
    %% Округление
    K_Ha = round(K_Ha, 2);
    K_Fa = round(K_Fa, 2);
    
end