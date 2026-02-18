%% Универсальный расчет моментов для n-звенного манипулятора
% Рекурсивный метод Ньютона-Эйлера (RNE)
% Применимо для любого числа звеньев (в примере: 5 звеньев)

clear; clc; close all;

%% ===== ПАРАМЕТРЫ МАНИПУЛЯТОРА =====

n = 5;  % число звеньев (измените на нужное)

% Инициализация структуры данных звеньев
links = struct('m', {}, 'L', {}, 'r', {}, 'J', {}, 'a', {}, 'b', {}, 'c', {});

% Звено 1
links(1).m = 3.5;       links(1).L = 0.4;
links(1).a = 0.4;       links(1).b = 0.15;      links(1).c = 0.15;
links(1).r = links(1).L/2;  % ЦМ в середине
links(1).J = parallelepiped_inertia(links(1).m, links(1).a, links(1).b, links(1).c, links(1).r);

% Звено 2
links(2).m = 3.0;       links(2).L = 0.35;
links(2).a = 0.35;      links(2).b = 0.12;      links(2).c = 0.12;
links(2).r = links(2).L/2;
links(2).J = parallelepiped_inertia(links(2).m, links(2).a, links(2).b, links(2).c, links(2).r);

% Звено 3
links(3).m = 2.5;       links(3).L = 0.3;
links(3).a = 0.3;       links(3).b = 0.1;       links(3).c = 0.1;
links(3).r = links(3).L/2;
links(3).J = parallelepiped_inertia(links(3).m, links(3).a, links(3).b, links(3).c, links(3).r);

% Звено 4
links(4).m = 2.0;       links(4).L = 0.25;
links(4).a = 0.25;      links(4).b = 0.08;      links(4).c = 0.08;
links(4).r = links(4).L/2;
links(4).J = parallelepiped_inertia(links(4).m, links(4).a, links(4).b, links(4).c, links(4).r);

% Звено 5
links(5).m = 1.5;       links(5).L = 0.2;
links(5).a = 0.2;       links(5).b = 0.06;      links(5).c = 0.06;
links(5).r = links(5).L/2;
links(5).J = parallelepiped_inertia(links(5).m, links(5).a, links(5).b, links(5).c, links(5).r);

% Вывод параметров
fprintf('=== Параметры %d-звенного манипулятора ===\n\n', n);
for i = 1:n
    fprintf('Звено %d: m=%.2f кг, L=%.3f м, J=%.5f кг·м²\n', ...
        i, links(i).m, links(i).L, links(i).J);
end

%% ===== КИНЕМАТИЧЕСКИЕ ПАРАМЕТРЫ =====

% Текущие углы (рад)
theta = [pi/6; pi/8; -pi/6; pi/4; -pi/8];

% Угловые скорости (рад/с)
omega = [0.5; 0.3; 0.2; 0.1; 0.05];

% Угловые ускорения (рад/с²) — ЗАДАННЫЕ
epsilon = [1.0; 0.8; 0.6; 0.4; 0.2];

% Ускорение основания (обычно нулевое, но можно задать)
a0 = [0; -9.81; 0];  % [ax; ay; az] — включает гравитацию как ускорение основания

fprintf('\n=== Кинематические параметры ===\n');
for i = 1:n
    fprintf('Звено %d: θ=%.2f°, ω=%.3f, ε=%.3f\n', ...
        i, theta(i)*180/pi, omega(i), epsilon(i));
end

%% ===== РЕКУРСИВНЫЙ АЛГОРИТМ НЬЮТОНА-ЭЙЛЕРА =====

% Инициализация векторов (в плоскости XY, вращение вокруг Z)
z = [0; 0; 1];  % ось вращения

% Прямой проход: вычисление скоростей и ускорений
w = zeros(3, n+1);      % угловые скорости (векторы)
wdot = zeros(3, n+1);   % угловые ускорения
a = zeros(3, n+1);      % линейные ускорения
ac = zeros(3, n);       % ускорения центров масс

% Начальные условия (основание)
w(:,1) = [0; 0; 0];
wdot(:,1) = [0; 0; 0];
a(:,1) = a0;

fprintf('\n=== Прямой проход (кинематика) ===\n');

for i = 1:n
    % Ось вращения текущего звена (перпендикулярна плоскости)
    Ri = [cos(theta(i)), -sin(theta(i)), 0;
          sin(theta(i)),  cos(theta(i)), 0;
          0,              0,             1];
    
    % Положение оси i+1 относительно оси i
    p = [links(i).L; 0; 0];  % в системе координат звена i
    
    % Угловая скорость и ускорение
    w(:,i+1) = w(:,i) + omega(i) * z;
    wdot(:,i+1) = wdot(:,i) + epsilon(i) * z + cross(w(:,i), omega(i)*z);
    
    % Линейное ускорение
    a(:,i+1) = Ri' * a(:,i) + cross(wdot(:,i+1), p) + ...
               cross(w(:,i+1), cross(w(:,i+1), p));
    
    % Ускорение центра масс (смещено на r от начала звена)
    pc = [links(i).r; 0; 0];
    ac(:,i) = Ri' * a(:,i) + cross(wdot(:,i+1), pc) + ...
              cross(w(:,i+1), cross(w(:,i+1), pc));
    
    fprintf('Звено %d: |ac| = %.4f м/с²\n', i, norm(ac(:,i)));
end

%% ===== ОБРАТНЫЙ ПРОХОД: РАСЧЕТ МОМЕНТОВ =====

f = zeros(3, n+1);      % силы в шарнирах
n_moment = zeros(3, n+1);  % моменты в шарнирах
tau = zeros(n, 1);      % обобщенные силы (моменты приводов)

fprintf('\n=== Обратный проход (динамика) ===\n');

for i = n:-1:1
    % Положение следующего шарнира
    if i < n
        p_next = [links(i).L; 0; 0];
    else
        p_next = [links(i).L; 0; 0];  % конец последнего звена
    end
    
    % Положение центра масс
    pc = [links(i).r; 0; 0];
    
    % Сила тяжести и инерционная сила
    F = links(i).m * ac(:,i) - [0; -links(i).m*9.81; 0];  % F = ma - mg
    
    % Момент относительно центра масс
    N = links(i).J * wdot(3,i+1) * z;  % J * альфа (упрощенно для плоского случая)
    
    % Сила в шарнире i (рекурсия)
    f(:,i) = f(:,i+1) + F;
    
    % Момент в шарнире i
    n_moment(:,i) = n_moment(:,i+1) + cross(pc, F) + ...
                    cross(p_next - pc, f(:,i+1)) + N;
    
    % Обобщенная сила (проекция на ось вращения)
    tau(i) = n_moment(3,i);  % z-компонента для плоского случая
    
    fprintf('Звено %d: F=%.3f Н, Момент=%.4f Н·м\n', i, norm(F), tau(i));
end

%% ===== РЕЗУЛЬТАТЫ =====

fprintf('\n');
fprintf('========================================\n');
fprintf('     МОМЕНТЫ НА ПРИВОДАХ\n');
fprintf('========================================\n');
for i = 1:n
    fprintf('Привод %d: τ = %8.4f Н·м\n', i, tau(i));
end
fprintf('========================================\n');
fprintf('Суммарный момент: %.4f Н·м\n', sum(abs(tau)));

%% ===== ВИЗУАЛИЗАЦИЯ =====

figure('Color', 'w', 'Position', [100 100 800 600]);
hold on; axis equal; grid on;
xlabel('X, м'); ylabel('Y, м');
title(sprintf('%d-звенный манипулятор (RNE алгоритм)', n));
colors = lines(n);

% Вычисление положений шарниров для визуализации
joints = zeros(2, n+1);
joints(:,1) = [0; 0];
angle_sum = 0;

for i = 1:n
    angle_sum = angle_sum + theta(i);
    joints(:,i+1) = joints(:,i) + links(i).L * [cos(angle_sum); sin(angle_sum)];
end

% Отрисовка звеньев
for i = 1:n
    plot([joints(1,i), joints(1,i+1)], [joints(2,i), joints(2,i+1)], ...
         '-', 'Color', colors(i,:), 'LineWidth', 6);
    
    % Центр масс
    cm_angle = angle_sum - theta(i)/2;  % приближенно
    cm_pos = joints(:,i) + links(i).r * [cos(angle_sum - theta(i) + theta(i)/2); 
                                          sin(angle_sum - theta(i) + theta(i)/2)];
    plot(cm_pos(1), cm_pos(2), 'o', 'Color', colors(i,:), ...
         'MarkerSize', 10, 'MarkerFaceColor', colors(i,:));
    
    % Подпись
    mid = (joints(:,i) + joints(:,i+1)) / 2;
    text(mid(1), mid(2)+0.02, sprintf('%d', i), ...
         'HorizontalAlignment', 'center', 'Color', colors(i,:), 'FontWeight', 'bold');
end

% Шарниры
plot(joints(1,:), joints(2,:), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
plot(0, 0, 'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'r');

legend('Звенья', 'ЦМ', 'Шарниры', 'Основание');
xlim([min(joints(1,:))-0.1, max(joints(1,:))+0.1]);
ylim([min(joints(2,:))-0.1, max(joints(2,:))+0.1]);

%% ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====

function J = parallelepiped_inertia(m, a, b, c, r)
    % Момент инерции параллелепипеда относительно оси вращения
    % m - масса, a,b,c - размеры, r - расстояние от оси до ЦМ
    
    % Собственный момент относительно ЦМ (ось перпендикулярна плоскости ab)
    J_cm = m * (a^2 + b^2) / 12;
    
    % По теореме Штейнера
    J = J_cm + m * r^2;
end