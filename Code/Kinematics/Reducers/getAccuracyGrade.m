function [accuracy_grade, accuracy_desc] = getAccuracyGrade(V, gear_type)
% getAccuracyGrade - Определение степени точности по окружной скорости

    if nargin < 2
        gear_type = 'cylindrical';
    end
    
    if V < 0
        error('Скорость V должна быть положительной');
    end
    
    %% Таблица допустимых скоростей (Приложение 9 методики)
    % Степень точности: 6    7    8    9
    % Для цилиндрических прямозубых: 15, 10, 6, 2 м/с
    
    switch lower(gear_type)
        case {'cylindrical', 'cyl', 'прямозубая', 'цилиндрическая'}
            limits = [15, 10, 6, 2];  % макс. скорость для 6,7,8,9 степени
            
        case {'bevel', 'коническая'}
            limits = [12, 8, 4, 1.5];
            
        case {'helical', 'helic', 'косозубая'}
            limits = [30, 15, 10, 4];
            
        otherwise
            error('Неизвестный тип передачи: %s', gear_type);
    end
    
    grades = [6, 7, 8, 9];
    
    %% Определение степени точности
    % Ищем ПОСЛЕДНЮЮ степень, для которой V не превышает предел
    % (т.е. самую "грубую" подходящую)
    
    accuracy_grade = 9;  % по умолчанию
    
    for i = length(limits):-1:1  % идем с конца (от 9 к 6)
        if V <= limits(i)
            accuracy_grade = grades(i);
            break;
        end
    end
    
    %% Формирование описания
    descriptions = {
        '6-я (высокая точность)'
        '7-я (повышенная точность)'
        '8-я (нормальная точность)'
        '9-я (пониженная точность)'
    };
    
    idx = find(grades == accuracy_grade);
    accuracy_desc = descriptions{idx};
    
end