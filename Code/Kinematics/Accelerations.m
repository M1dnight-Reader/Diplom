clc

g = 9.81; %ускорение свободного падения, м/с^2 

number = 1; %номер рассчитываемого звена
T = 2.5;              % время, с
theta = pi/2;       % угол, рад (90°)
[alpha1, omega_max1, t1] = angular_motion_profile(T, theta, number); % Получившиеся параметры

number = 2; %номер рассчитываемого звена
T = 1.25;              % время, с
theta = pi/6;       % угол, рад (90°)
[alpha2, omega_max2, t2] = angular_motion_profile(T, theta, number); % Получившиеся параметры

number = 3; %номер рассчитываемого звена
T = 2.25;              % время, с
theta = pi/4;       % угол, рад (90°)
[alpha3, omega_max3, t3] = angular_motion_profile(T, theta, number); % Получившиеся параметры

number = 4; %номер рассчитываемого звена
T = 1.25;              % время, с
theta = pi/3;       % угол, рад (90°)
[alpha4, omega_max4, t4] = angular_motion_profile(T, theta, number); % Получившиеся параметры

number = 5; %номер рассчитываемого звена
T = 3;              % время, с
theta = pi;       % угол, рад (90°)
[alpha5, omega_max5, t5] = angular_motion_profile(T, theta, number); % Получившиеся параметры

alpha = [alpha1, alpha2, alpha3, alpha4, alpha5]
omega_max = [omega_max1, omega_max2, omega_max3, omega_max4, omega_max5]

