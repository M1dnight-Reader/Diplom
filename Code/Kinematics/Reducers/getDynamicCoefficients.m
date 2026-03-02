function [K_HV, K_FV] = getDynamicCoefficients(V, accuracy_grade, HB_type, gear_type)
% getDynamicCoefficients - Определение коэффициентов K_Hv и K_Fv
%
% Вход:
%   V              - окружная скорость, м/с
%   accuracy_grade - степень точности (6, 7, 8, 9)
%   HB_type        - 'a' (HB <= 350 или HRC >= 45 с HB <= 350)
%                    'b' (HB > 350 или HRC >= 45 с HB > 350)
%   gear_type      - 'straight' (прямозубые, по умолчанию)
%                     'helical'  (косозубые)
%
% Выход:
%   K_HV - коэффициент динамической нагрузки для контактных напряжений
%   K_FV - коэффициент динамической нагрузки для изгибных напряжений
%
% Примеры:
%   [Kh, Kf] = getDynamicCoefficients(3.06, 8, 'b', 'straight')  % Kh=1.20, Kf=1.30
%   [Kh, Kf] = getDynamicCoefficients(5, 7, 'a', 'helical')      % интерполяция

    %% Проверка входных данных
    if nargin < 4
        gear_type = 'straight';
    end
    
    valid_grades = [6, 7, 8, 9];
    if ~ismember(accuracy_grade, valid_grades)
        error('Степень точности должна быть 6, 7, 8 или 9');
    end
    
    if ~ismember(HB_type, {'a', 'b'})
        error('HB_type должен быть "a" или "b"');
    end
    
    %% Скоростные узлы для интерполяции (из таблицы)
    V_nodes = [1, 3, 5, 8, 10];  % м/с
    
    %% Таблица коэффициентов [степень][тип HB][тип зубьев][скорость]
    % Структура: K_HV_straight, K_HV_helical, K_FV_straight, K_FV_helical
    
    % === 6-я степень точности ===
    K_data(6).a.straight.K_HV = [1.03, 1.09, 1.16, 1.25, 1.32];
    K_data(6).a.helical.K_HV  = [1.01, 1.03, 1.06, 1.09, 1.13];
    K_data(6).a.straight.K_FV = [1.06, 1.18, 1.32, 1.50, 1.64];
    K_data(6).a.helical.K_FV  = [1.03, 1.09, 1.13, 1.20, 1.26];
    
    K_data(6).b.straight.K_HV = [1.03, 1.06, 1.10, 1.16, 1.20];
    K_data(6).b.helical.K_HV  = [1.01, 1.03, 1.04, 1.06, 1.08];
    K_data(6).b.straight.K_FV = [1.02, 1.06, 1.10, 1.16, 1.20];
    K_data(6).b.helical.K_FV  = [1.01, 1.03, 1.04, 1.06, 1.08];
    
    % === 7-я степень точности ===
    K_data(7).a.straight.K_HV = [1.04, 1.12, 1.20, 1.32, 1.40];
    K_data(7).a.helical.K_HV  = [1.02, 1.06, 1.08, 1.13, 1.16];
    K_data(7).a.straight.K_FV = [1.08, 1.24, 1.40, 1.64, 1.80];
    K_data(7).a.helical.K_FV  = [1.03, 1.09, 1.16, 1.25, 1.32];
        
    K_data(7).b.straight.K_HV = [1.02, 1.06, 1.12, 1.19, 1.25];
    K_data(7).b.helical.K_HV  = [1.01, 1.03, 1.05, 1.08, 1.10];
    K_data(7).b.straight.K_FV = [1.02, 1.06, 1.12, 1.19, 1.25];
    K_data(7).b.helical.K_FV  = [1.01, 1.03, 1.05, 1.08, 1.10];
    
    % === 8-я степень точности ===
    K_data(8).a.straight.K_HV = [1.05, 1.15, 1.24, 1.38, 1.48];
    K_data(8).a.helical.K_HV  = [1.02, 1.06, 1.10, 1.15, 1.19];
    K_data(8).a.straight.K_FV = [1.10, 1.30, 1.48, 1.77, 1.96];
    K_data(8).a.helical.K_FV  = [1.04, 1.12, 1.19, 1.30, 1.38];
    
    K_data(8).b.straight.K_HV = [1.03, 1.09, 1.15, 1.24, 1.30];
    K_data(8).b.helical.K_HV  = [1.01, 1.03, 1.06, 1.09, 1.12];
    K_data(8).b.straight.K_FV = [1.03, 1.09, 1.15, 1.24, 1.30];
    K_data(8).b.helical.K_FV  = [1.01, 1.03, 1.06, 1.09, 1.12];
    
    % === 9-я степень точности ===
    K_data(9).a.straight.K_HV = [1.06, 1.12, 1.28, 1.45, 1.56];
    K_data(9).a.helical.K_HV  = [1.02, 1.06, 1.11, 1.18, 1.22];
    K_data(9).a.straight.K_FV = [1.11, 1.33, 1.56, 1.90, 2.25];
    K_data(9).a.helical.K_FV  = [1.04, 1.12, 1.22, 1.36, 1.45];
    
    K_data(9).b.straight.K_HV = [1.03, 1.09, 1.17, 1.28, 1.35];
    K_data(9).b.helical.K_HV  = [1.01, 1.03, 1.07, 1.11, 1.14];
    K_data(9).b.straight.K_FV = [1.03, 1.09, 1.17, 1.28, 1.35];
    K_data(9).b.helical.K_FV  = [1.01, 1.03, 1.07, 1.11, 1.14];
    
    %% Выбор данных
    gear = lower(gear_type);
    if strcmp(gear, 'helical') || strcmp(gear, 'косые') || strcmp(gear, 'косозубые')
        gear_field = 'helical';
    else
        gear_field = 'straight';
    end
    
    % Извлечение массивов для интерполяции
    K_HV_array = K_data(accuracy_grade).(HB_type).(gear_field).K_HV;
    K_FV_array = K_data(accuracy_grade).(HB_type).(gear_field).K_FV;
    
    %% Интерполяция по скорости
    % Ограничение скорости разумными пределами
    V_clamped = max(V_nodes(1), min(V, V_nodes(end)));
    
    K_HV = interp1(V_nodes, K_HV_array, V_clamped, 'linear', 'extrap');
    K_FV = interp1(V_nodes, K_FV_array, V_clamped, 'linear', 'extrap');
    
    %% Округление до 2 знаков (как в таблице)
    K_HV = round(K_HV, 2);
    K_FV = round(K_FV, 2);
    
end