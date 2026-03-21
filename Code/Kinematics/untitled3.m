clc

% Данные из таблицы
x = [0, 0.22, 0.44, 0.67, 0.9, 1.12];  % Значения по оси X

y_1500 = [1477, 1420, 1390, 1360, 1330, 1300];  % f = 1500 Гц
y_1000 = [990, 960, 930, 900, 860, 830];        % f = 1000 Гц
y_500  = [487, 460, 430, 400, 373, 345];        % f = 500 Гц

% Построение графика
figure;
plot(x, y_1500, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'f = 1500 Гц');
hold on;
plot(x, y_1000, '-s', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'f = 1000 Гц');
plot(x, y_500,  '-^', 'LineWidth', 2, 'MarkerSize', 8, 'DisplayName', 'f = 500 Гц');
hold off;

% Подпись осей
xlabel('М, Нм', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('w, об/мин', 'FontSize', 12, 'FontWeight', 'bold');
title('Зависимость w от М для разных частот', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
grid on;
set(gca, 'FontSize', 11);

% Получаем пределы осей для стрелок
xlim_vals = xlim;
ylim_vals = ylim;

% Добавление стрелок на концах осей (используем quiver - более надёжно)
hold on;
% Стрелка по оси X
quiver(xlim_vals(2), 0, 0.05, 0, 'k', 'LineWidth', 2, 'MaxHeadSize', 3, 'AutoScale', 'off');
% Стрелка по оси Y
quiver(0, ylim_vals(2), 0, 50, 'k', 'LineWidth', 2, 'MaxHeadSize', 3, 'AutoScale', 'off');
hold off;

% Улучшение отображения
set(gcf, 'Color', 'w');  % Белый фон фигуры