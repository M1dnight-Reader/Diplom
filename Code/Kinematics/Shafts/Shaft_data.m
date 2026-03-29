clc

% Длина 2й оси (расстояние между центрами подщипников)
shaft = struct("length", {});
length2 = 150 / 1000; %м
length3 = 150 / 1000; %м
fprintf("Длина вала : %.3f м\n", length2);
Mk2 = moments(2).M_max;
fprintf("Крутящий момент : %.3f Нм\n", Mk2);
Mg2 = moments(2).F;
fprintf("Вес звеньев : %.3f Н\n", Mg2);
Mb2 = Mg2 * length2/ 2 / 2;
fprintf("Изгибающий момент : %.3f Нм\n", Mb2);
d2_2min = ((Mb2^2 + 0.75 * Mk2^2)^0.5 * 1000 / (0.1 * 125))^(1/3);
fprintf("Диаметр ведомого вала : %.3f мм\n", d2_2min);

% Определение мест приложения сил
shaft2_l2 = 500;
shaft2_l3 = 750;

% Определение действующих сил
shaft2_F2 = - moments(2).F * shaft2_l3 / (shaft2_l3 - shaft2_l2);
shaft2_F3 = moments(2).F * shaft2_l2 / (shaft2_l3 - shaft2_l2);

