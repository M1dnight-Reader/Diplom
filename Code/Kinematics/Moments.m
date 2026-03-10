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
motor2_mass = 7.7;
motor3_mass = 4.1;
motor4_mass = 1.5;
motor5_mass = 1.5;
motor_masses = [motor1_mass, motor2_mass, motor3_mass, motor4_mass, motor5_mass];
% зададим смещения моторов относительно осей, не забывая про конфигурацию

indent5 = 230 / 1000;
indent4 = 120 / 1000;
% манипулятора (моторы 4 и 5 на звене 3)

% массы звеньев, кг
link1_mass = 7;
link2_mass = 4.6;
link3_mass = 4.1;
link4_mass = 1.2;
link5_mass = 2;
link6_mass = 1.2;
link_masses = [link1_mass, link2_mass, link3_mass, link4_mass , link5_mass, link6_mass];

% масса коробки (самой большой)
box_mass = 5;

% размеры моторов
motor_dims = {[100, 80, 80]/1000,   % мотор 1: длина, диаметр/ширина, диаметр/высота
              [120, 100, 100]/1000,  % мотор 2
              [100, 80, 80]/1000,    % мотор 3
              [80, 60, 60]/1000,     % мотор 4
              [80, 60, 60]/1000};    % мотор 5

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
moments = struct('din', {}, 'stat', {}, 'react', {}, 'J', {}, 'e', {}, 'w', {}, 'i', {});
motor = struct('m', {}, 'L', {}, 'r', {}, 'Jx', {}, 'Jy', {}, 'Jz', {}, 'a', {}, 'b', {}, 'c', {}, 'N', {}, 'nmot', {}, 'nreq', {});

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

for i = 1:5
    motor(i).m = motor_masses(i);
    motor(i).L = motor_dims{i}(1);   % длина мотора
    motor(i).a = motor_dims{i}(1);   % для параллелепипеда
    motor(i).b = motor_dims{i}(2);
    motor(i).c = motor_dims{i}(3);
    motor(i).r = motor(i).L/2;       % ЦМ в середине
    
    % Моменты инерции мотора (как параллелепипед)
    motor(i).Jx = parallelepiped_inertia(motor(i).m, motor(i).a, motor(i).b, motor(i).r);
    motor(i).Jy = parallelepiped_inertia(motor(i).m, motor(i).c, motor(i).b, motor(i).r);
    motor(i).Jz = parallelepiped_inertia(motor(i).m, motor(i).a, motor(i).c, motor(i).r);
end

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

moments(5).J = (links(5).Jy + links(6).Jy + box(1).Jy); % вращение вокруг Y (горизонталь)
moments(5).e = alpha(5);
moments(5).w = omega_max(5);
moments(5).stat = 0.0;
moments(5).react = 0;

% моторов нет на этом сочленении 
moments(4).J = (links(4).Jx + links(4).m * (links(4).r ^ 2) + ...
                  links(5).Jx + links(5).m * ((links(4).L + links(5).r) ^ 2) + ...
                  links(6).Jx + links(6).m * ((links(4).L + links(5).L + links(6).r) ^ 2) +...
                  box(1).Jx + box(1).m * ((links(4).L + links(5).L + links(6).L + box(1).r) ^ 2));
moments(4).e = alpha(4);
moments(4).w = omega_max(4);
moments(4).stat = (links(4).m * links(4).r + ...
                   links(5).m * (links(4).L + links(5).r) + ...
                   links(6).m * (links(4).L + links(5).L + links(6).r) +...
                   box(1).m * (links(4).L + links(5).L + links(6).L + box(1).r))...
                   * g;
moments(4).react = 0;

% добавляются 2 мотора для вращения 4 и 5 осей
moments(3).J = (links(3).Jx + links(3).m * (links(3).r ^ 2) + ...
                  links(4).Jx + links(4).m * ((links(3).L + links(4).r) ^ 2) + ...
                  links(5).Jx + links(5).m * ((links(3).L + links(4).L + links(5).r) ^ 2) +...
                  links(6).Jx + links(6).m * ((links(3).L + links(4).L + links(5).L  + links(6).r) ^ 2) +...
                  box(1).Jx + box(1).m * ((links(3).L + links(4).L + links(5).L + links(6).L + box(1).r) ^ 2) + ...
                  motor(5).Jx + motor(5).m * (indent5 ^ 2) + ...
                  motor(4).Jx + motor(4).m * (indent4 ^ 2));
moments(3).e = alpha(3);
moments(3).w = omega_max(3);
moments(3).stat = (links(3).m * links(3).r + ...
                   links(4).m * (links(3).L + links(4).r) + ...
                   links(5).m * (links(3).L + links(4).L + links(5).r) + ...
                   links(6).m * (links(3).L + links(4).L + links(5).L + links(6).r) + ...
                   box(1).m * (links(3).L + links(4).L + links(5).L + links(6).L + box(1).r) + ...
                   motor(5).m * indent5 + ...
                   motor(4).m * indent4) ...
                   * g;
moments(3).react = moments(4).J * moments(4).e;

% добавляются 3 мотора для вращения 3, 4 и 5 осей
moments(2).J = (links(2).Jx + links(2).m * (links(2).r ^ 2) + ...
                  links(3).Jx + links(3).m * ((links(2).L + links(3).r) ^ 2) + ...
                  links(4).Jx + links(4).m * ((links(2).L + links(3).L + links(4).r) ^ 2) + ...
                  links(5).Jx + links(5).m * ((links(2).L + links(3).L + links(4).L + links(5).r) ^ 2) + ...
                  links(6).Jx + links(6).m * ((links(2).L + links(3).L + links(4).L + links(5).L + links(6).r) ^ 2) + ...
                  box(1).Jx + box(1).m * ((links(2).L + links(3).L + links(4).L + links(5).L + links(6).L + box(1).r) ^ 2) + ...
                  motor(5).Jx + motor(5).m * ((links(2).L + indent5) ^ 2) + ...
                  motor(4).Jx + motor(4).m * ((links(2).L + indent4) ^ 2) + ...
                  motor(3).Jx + motor(3).m * (links(2).L ^ 2));
moments(2).e = alpha(2);
moments(2).w = omega_max(2);
moments(2).stat = (links(2).m * links(2).r + ...
                   links(3).m * (links(2).L + links(3).r) + ...
                   links(4).m * (links(2).L + links(3).L + links(4).r) + ...
                   links(5).m * (links(2).L + links(3).L + links(4).L + links(5).r) + ...
                   links(6).m * (links(2).L + links(3).L + links(4).L + links(5).L + links(6).r) + ...
                   box(1).m * (links(2).L + links(3).L + links(4).L + links(5).L + links(6).L + box(1).r) + ...
                   motor(5).m * (links(2).L + indent5) + ...
                   motor(4).m * (links(2).L + indent4) + ...
                   motor(3).m * links(2).L) ...
                   * g;
moments(2).react = moments(3).J * moments(3).e + moments(4).J * moments(4).e;

% добавляются 4 мотора для вращения 2, 3, 4 и 5 осей
moments(1).J = (links(1).Jz + ...  % вращение вокруг Z (вертикаль)
                  links(2).Jz + links(2).m * ((links(2).r) ^ 2) + ...
                  links(3).Jz + links(3).m * ((links(2).L + links(3).r) ^ 2) + ...
                  links(4).Jz + links(4).m * ((links(2).L + links(3).L + links(4).r) ^ 2) + ...
                  links(5).Jz + links(5).m * ((links(2).L + links(3).L + links(4).L + links(5).r) ^ 2) + ...
                  links(6).Jz + links(6).m * ((links(2).L + links(3).L + links(4).L + links(5).L + links(6).r) ^ 2) + ...
                  box(1).Jz + box(1).m * ((links(1).L + links(2).L + links(3).L + links(4).L + links(5).L + links(6).L + box(1).r) ^ 2) + ...
                  motor(5).Jz + motor(5).m * ((links(2).L + indent5) ^ 2) + ...
                  motor(4).Jz + motor(4).m * ((links(2).L + indent4) ^ 2) + ...
                  motor(3).Jz + motor(3).m * (links(2).L ^ 2) + ...
                  motor(2).Jz);
moments(1).e = alpha(1);
moments(1).w = omega_max(1);
moments(1).stat = 0;
moments(1).react = 0;


