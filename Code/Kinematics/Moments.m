clc

% Здесь сначала распишем размеры зввеньев, после чего распишем их моменты
% инерции относительно осей вращения, после чего, используя ранее
% полученные ускорения, найдем необходимые моменты, которые должны
% выдаваться каждым приводом

% Представим привода и звенья в качестве параллелепипедов, а для
% наглядности вынесем важные параметры отдельно

%=======ПАРАМЕТРЫ_ОБЪЕКТОВ=======

% массы приводов, кг
motor1_mass = 3.5;
motor2_mass = 5;
motor3_mass = 3;
motor4_mass = 1.5;
motor5_mass = 1.5;
motor_masses = [3.5, 5, 3, 1.5, 1.5];

% массы звеньев, кг
link1_mass = 7;
link2_mass = 6;
link3_mass = 5;
link4_mass = 1;
link5_mass = 1.2;
link6_mass = 1.2;
link_masses = [7, 6, 5, 1, 1.2, 1.2];

% масса коробки (самой большой)
box_mass = 5;

% размеры звеньев

% в данном коде будем считать, что расстояние между осями звеньев равно
% длине звена
link1_dims = [250, 200, 200] / 1000;
link2_dims = [450, 160, 160] / 1000;
link3_dims = [400, 160, 160] / 1000;
link4_dims = [120, 160, 160] / 1000;
link5_dims = [250, 160, 160] / 1000;
link6_dims = [150, 160, 160] / 1000;
box_dims = [150, 300, 300] / 1000;
links_dims = {link1_dims, link2_dims, link3_dims, link4_dims, link5_dims, link6_dims};



%=======ИНИЦИАЛИЗАЦИЯ_ОБЪЕКТОВ=======

links = struct('m', {}, 'L', {}, 'r', {}, 'Jx', {}, 'Jy', {}, 'Jz', {}, 'a', {}, 'b', {}, 'c', {});
box = struct('m', {}, 'L', {}, 'r', {}, 'Jx', {}, 'Jy', {}, 'Jz', {}, 'a', {}, 'b', {}, 'c', {});
moments = struct('sum', {}, 'din', {}, 'stat', {});
motor = struct('m', {}, 'L', {}, 'r', {}, 'Jx', {}, 'Jy', {}, 'Jz', {}, 'a', {}, 'b', {}, 'c', {});

% Звенья

for i = 1:6
    links(i).m = link_masses(i);
    links(i).L = links_dims{i}(1);
    links(i).a = links_dims{i}(1);
    links(i).b = links_dims{i}(2);
    links(i).c = links_dims{i}(3);
    links(i).r = links(i).L/2;
    links(i).Jx = parallelepiped_inertia(links(i).m, links(i).a, links(i).b, links(i).r);
    links(i).Jy = parallelepiped_inertia(links(i).m, links(i).c, links(i).b, links(i).r);
    links(i).Jz = parallelepiped_inertia(links(i).m, links(i).a, links(i).c, links(i).r);
end

% Моторы

% Коробка
box(1).m = box_mass;
box(1).L = box_dims(1);
box(1).a = box_dims(1);
box(1).b = box_dims(2);
box(1).c = box_dims(3);
box(1).r = box(1).L/2;  % ЦМ в середине
box(1).Jx = parallelepiped_inertia(box(1).m, box(1).a, box(1).b, box(1).r);
box(1).Jy = parallelepiped_inertia(box(1).m, box(1).c, box(1).b, box(1).r);
box(1).Jz = parallelepiped_inertia(box(1).m, box(1).a, box(1).c, box(1).r);



%=======РАСЧЕТ_МОМЕНТОВ=======

% moments(i).din - момент, вызванный вращением только одного звена
% moments(i).sum - cуммарный момент на звене при вращении всех последующих
% (худший случай)

moments(5).din = (links(5).Jy + links(6).Jy + box(1).Jy) * alpha(5); % вращение вокруг Y (горизонталь)
moments(5).sum = moments(5).din;

moments(4).din = (links(4).Jx + links(4).m * (links(4).r ^ 2) + ...
                  links(5).Jx + links(5).m * ((links(4).L + links(5).r) ^ 2) + ...
                  links(6).Jx + links(6).m * ((links(4).L + links(5).L + links(6).r) ^ 2) +...
                  box(1).Jx + box(1).m * ((links(4).L + links(5).L + links(6).L + box(1).r) ^ 2))...
                  * alpha(4);
moments(4).stat = (links(4).m * links(4).r + ...
                   links(5).m * (links(4).L + links(5).r) + ...
                   links(6).m * (links(4).L + links(5).L + links(6).r) +...
                   box(1).m * (links(4).L + links(5).L + links(6).L + box(1).r))...
                   * g;
moments(4).sum = moments(4).din + moments(4).stat;

moments(3).din = (links(3).Jx + links(3).m * (links(3).r ^ 2) + ...
                  links(4).Jx + links(4).m * ((links(3).L + links(4).r) ^ 2) + ...
                  links(5).Jx + links(5).m * ((links(3).L + links(4).L + links(5).r) ^ 2) +...
                  links(6).Jx + links(6).m * ((links(3).L + links(4).L + links(5).L  + links(6).r) ^ 2) +...
                  box(1).Jx + box(1).m * ((links(3).L + links(4).L + links(5).L + links(6).L + box(1).r) ^ 2))...
                  * alpha(3);
moments(3).stat = (links(3).m * links(3).r + ...
                   links(4).m * (links(3).L + links(4).r) + ...
                   links(5).m * (links(3).L + links(4).L + links(5).r) + ...
                   links(6).m * (links(3).L + links(4).L + links(5).L + links(6).r) + ...
                   box(1).m * (links(3).L + links(4).L + links(5).L + links(6).L + box(1).r)) ...
                   * g;
moments(3).sum = moments(3).din + moments(4).din + moments(3).stat;

moments(2).din = (links(2).Jx + links(2).m * (links(2).r ^ 2) + ...
                  links(3).Jx + links(3).m * ((links(2).L + links(3).r) ^ 2) + ...
                  links(4).Jx + links(4).m * ((links(2).L + links(3).L + links(4).r) ^ 2) + ...
                  links(5).Jx + links(5).m * ((links(2).L + links(3).L + links(4).L + links(5).r) ^ 2) + ...
                  links(6).Jx + links(6).m * ((links(2).L + links(3).L + links(4).L + links(5).L + links(6).r) ^ 2) + ...
                  box(1).Jx + box(1).m * ((links(2).L + links(3).L + links(4).L + links(5).L + links(6).L + box(1).r) ^ 2)) ...
                  * alpha(2);
moments(2).stat = (links(2).m * links(2).r + ...
                   links(3).m * (links(2).L + links(3).r) + ...
                   links(4).m * (links(2).L + links(3).L + links(4).r) + ...
                   links(5).m * (links(2).L + links(3).L + links(4).L + links(5).r) + ...
                   links(6).m * (links(2).L + links(3).L + links(4).L + links(5).L + links(6).r) + ...
                   box(1).m * (links(2).L + links(3).L + links(4).L + links(5).L + links(6).L + box(1).r)) ...
                   * g;
moments(2).sum = moments(2).din + moments(3).din + moments(4).din + moments(2).stat;

moments(1).din = (links(1).Jz + links(1).m * (links(1).r ^ 2) + ...  % вращение вокруг Z (вертикаль)
                  links(2).Jz + links(2).m * ((links(1).L + links(2).r) ^ 2) + ...
                  links(3).Jz + links(3).m * ((links(1).L + links(2).L + links(3).r) ^ 2) + ...
                  links(4).Jz + links(4).m * ((links(1).L + links(2).L + links(3).L + links(4).r) ^ 2) + ...
                  links(5).Jz + links(5).m * ((links(1).L + links(2).L + links(3).L + links(4).L + links(5).r) ^ 2) + ...
                  links(6).Jz + links(6).m * ((links(1).L + links(2).L + links(3).L + links(4).L + links(5).L + links(6).r) ^ 2) + ...
                  box(1).Jz + box(1).m * ((links(1).L + links(2).L + links(3).L + links(4).L + links(5).L + links(6).L + box(1).r) ^ 2)) ...
                  * alpha(1);

moments(1).sum = moments(1).din;
solved_moments = [0, 0, 0, 0, 0];

fprintf("===Момент и ускорение, необходимое для каждого звена===\n");
for i = 1:5
    solved_moments(i) = moments(i).sum;
    fprintf("Звено %.0f: ускорение e = %.3f; момент M = %.3f\n", i, alpha(i), moments(i).sum);
end

%=======СОХРАНЕНИЕ_ПОЛУЧЕННЫХ_РЕЗУЛЬТАТОВ=======

save('..\kinematics_data.mat', 'solved_moments');

