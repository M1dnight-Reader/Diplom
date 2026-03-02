function [m_std, row_num] = getStandardModuleCeil(m_input)
% getStandardModuleCeil - Выбор стандартного модуля (ближайший сверху)
%
% Вход:
%   m_input - требуемое значение модуля, мм
%
% Выход:
%   m_std   - ближайший стандартный модуль СВЕРХУ (>= m_input)
%   row_num - номер ряда (1 или 2)
%
% Примеры:
%   [m, row] = getStandardModuleCeil(2.3)   % m = 2.5, row = 1
%   [m, row] = getStandardModuleCeil(2.5)   % m = 2.5, row = 1 (точное)
%   [m, row] = getStandardModuleCeil(2.6)   % m = 2.75, row = 2
%   [m, row] = getStandardModuleCeil(3.0)   % m = 3.0, row = 1

    %% Стандартные ряды модулей (ГОСТ 9563-60)
    row1 = [1.0, 1.25, 2, 2.5, 3, 4, 5, 6, 8, 10, 12];      % 1-й ряд
    row2 = [1.125, 1.375, 1.75, 2.25, 2.75, 3.5, 4.5, 5.5, 7, 9, 11];  % 2-й ряд
    
    %% Объединение и сортировка всех модулей
    all_modules = sort([row1, row2]);
    all_rows = zeros(1, length(all_modules));
    
    % Определение ряда для каждого модуля
    for i = 1:length(all_modules)
        if ismember(all_modules(i), row1)
            all_rows(i) = 1;
        else
            all_rows(i) = 2;
        end
    end
    
    %% Поиск ближайшего сверху (ceil)
    % Индексы модулей, которые >= m_input
    valid_idx = find(all_modules >= m_input);
    
    if isempty(valid_idx)
        % Если m_input больше всех стандартных - берем максимум
        m_std = all_modules(end);
        row_num = all_rows(end);
        warning('m_input (%.3f) больше максимального стандартного модуля (%.3f)', ...
            m_input, m_std);
    else
        % Ближайший сверху - первый из подходящих
        idx = valid_idx(1);
        m_std = all_modules(idx);
        row_num = all_rows(idx);
    end
    
end