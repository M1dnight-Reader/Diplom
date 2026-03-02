%% Проверка функции - построение графиков
figure('Name', 'Проверка функции getLoadDistributionCoeff', 'Position', [100 100 1200 500]);

psi_test = 0:0.05:1.6;
schemes = {'Ia', 'Ib', 'II', 'III', 'IV', 'V', 'VI'};
colors = lines(length(schemes));

% K_Hβ, HB <= 350
subplot(1, 2, 1);
hold on; grid on;
for i = 1:length(schemes)
    K_vals = arrayfun(@(p) get_Khbetta_Kfbetta(p, 290, 270, schemes{i}, 'KH'), psi_test);
    plot(psi_test, K_vals, 'Color', colors(i,:), 'LineWidth', 1.5, 'DisplayName', schemes{i});
end
xlabel('\psi_{bd}'); ylabel('K_{H\beta}');
title('K_{H\beta}, HB \leq 350');
legend('Location', 'best');
axis([0 1.6 1 1.6]);

% K_Fβ, HB <= 350
subplot(1, 2, 2);
hold on; grid on;
for i = 1:length(schemes)
    K_vals = arrayfun(@(p) get_Khbetta_Kfbetta(p, 290, 270, schemes{i}, 'KF'), psi_test);
    plot(psi_test, K_vals, 'Color', colors(i,:), 'LineWidth', 1.5, 'DisplayName', schemes{i});
end
xlabel('\psi_{bd}'); ylabel('K_{F\beta}');
title('K_{F\beta}, HB \leq 350');
legend('Location', 'best');
axis([0 1.6 1 1.8]);