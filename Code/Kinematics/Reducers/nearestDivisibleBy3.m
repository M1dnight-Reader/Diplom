function [n1, n2] = nearestDivisibleBy3(x)
    % Находит два ближайших числа, делящихся на 3
    
    if mod(x, 3) == 0
        % Если само делится на 3
        n1 = x;
        n2 = x + 3;
    else
        % Округляем вниз и вверх до ближайших кратных 3
        n1 = floor(x / 3) * 3;
        n2 = ceil(x / 3) * 3;
    end
end
