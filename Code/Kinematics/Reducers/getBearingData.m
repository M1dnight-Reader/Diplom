function val = getBearingData(idx, param)
    % Проверка входных данных
    if nargin < 2
        error('Необходимо указать номер подшипника и имя параметра.');
    end

    % Инициализация структуры данных (массив структур)
    % Всего 47 подшипников: 24 из легкой серии и 23 из средней
    
    bearings(1).code = '6001/1,5'; bearings(1).d = 1.5; bearings(1).D = 6;  bearings(1).B = 2.5; bearings(1).r = 0.15; bearings(1).C = 0;   bearings(1).C0 = 0;
bearings(2).code = '60012';    bearings(2).d = 2.0; bearings(2).D = 7;  bearings(2).B = 2.8; bearings(2).r = 0.15; bearings(2).C = 0;   bearings(2).C0 = 0;
bearings(3).code = '6001/2,5'; bearings(3).d = 2.5; bearings(3).D = 8;  bearings(3).B = 2.8; bearings(3).r = 0.15; bearings(3).C = 0;   bearings(3).C0 = 0;
bearings(4).code = '60023';    bearings(4).d = 3;   bearings(4).D = 10;  bearings(4).B = 4;   bearings(4).r = 0.3; bearings(4).C = 490;   bearings(4).C0 = 217;
bearings(5).code = '60014';    bearings(5).d = 4;   bearings(5).D = 12; bearings(5).B = 4;   bearings(5).r = 0.2;  bearings(5).C = 0;   bearings(5).C0 = 0;
bearings(6).code = '60015';    bearings(6).d = 5;   bearings(6).D = 14; bearings(6).B = 5;   bearings(6).r = 0.2;  bearings(6).C = 0;   bearings(6).C0 = 0;
bearings(7).code = '60016';    bearings(7).d = 6;   bearings(7).D = 17; bearings(7).B = 6;   bearings(7).r = 0.3;  bearings(7).C = 0;   bearings(7).C0 = 0;
bearings(8).code = '60017';    bearings(8).d = 7;   bearings(8).D = 19; bearings(8).B = 6;   bearings(8).r = 0.3;  bearings(8).C = 0;   bearings(8).C0 = 0;
bearings(9).code = '60018';    bearings(9).d = 8;   bearings(9).D = 22; bearings(9).B = 7;   bearings(9).r = 0.3;  bearings(9).C = 21600;   bearings(9).C0 = 13200;
bearings(10).code = '60019';   bearings(10).d = 9;  bearings(10).D = 24; bearings(10).B = 7;  bearings(10).r = 0.3; bearings(10).C = 0;  bearings(10).C0 = 0;

% Легкая серия (индексы сдвинуты на 10)
bearings(11).code = '200';   bearings(11).d = 10;  bearings(11).D = 30;  bearings(11).B = 9;  bearings(11).r = 1;   bearings(11).C = 5.9;  bearings(11).C0 = 2.65;
bearings(12).code = '201';   bearings(12).d = 12;  bearings(12).D = 32;  bearings(12).B = 10; bearings(12).r = 1;   bearings(12).C = 6.89; bearings(12).C0 = 3.1;
bearings(13).code = '202';   bearings(13).d = 15;  bearings(13).D = 35;  bearings(13).B = 11; bearings(13).r = 1;   bearings(13).C = 7.8;  bearings(13).C0 = 3.55;
bearings(14).code = '203';   bearings(14).d = 17;  bearings(14).D = 40;  bearings(14).B = 12; bearings(14).r = 1;   bearings(14).C = 9.56; bearings(14).C0 = 4.5;
bearings(15).code = '204';   bearings(15).d = 20;  bearings(15).D = 47;  bearings(15).B = 14; bearings(15).r = 1.5; bearings(15).C = 12.7; bearings(15).C0 = 6.2;
bearings(16).code = '205';   bearings(16).d = 25;  bearings(16).D = 52;  bearings(16).B = 15; bearings(16).r = 1.5; bearings(16).C = 14.0; bearings(16).C0 = 6.95;
bearings(17).code = '206';   bearings(17).d = 30;  bearings(17).D = 62;  bearings(17).B = 16; bearings(17).r = 1.5; bearings(17).C = 19.5; bearings(17).C0 = 10.0;
bearings(18).code = '207';   bearings(18).d = 35;  bearings(18).D = 72;  bearings(18).B = 17; bearings(18).r = 2;   bearings(18).C = 25.5; bearings(18).C0 = 13.7;
bearings(19).code = '208';   bearings(19).d = 40;  bearings(19).D = 80;  bearings(19).B = 18; bearings(19).r = 2;   bearings(19).C = 32.0; bearings(19).C0 = 17.8;
bearings(20).code = '209';  bearings(20).d = 45; bearings(20).D = 85; bearings(20).B = 19; bearings(20).r = 2;  bearings(20).C = 33.2; bearings(20).C0 = 18.6;
bearings(21).code = '209A'; bearings(21).d = 45; bearings(21).D = 85; bearings(21).B = 19; bearings(21).r = 2;  bearings(21).C = 36.4; bearings(21).C0 = 20.1;
bearings(22).code = '210';  bearings(22).d = 50; bearings(22).D = 90; bearings(22).B = 20; bearings(22).r = 2;  bearings(22).C = 35.1; bearings(22).C0 = 19.8;
bearings(23).code = '211';  bearings(23).d = 55; bearings(23).D = 100; bearings(23).B = 21; bearings(23).r = 2.5; bearings(23).C = 43.6; bearings(23).C0 = 25.0;
bearings(24).code = '212';  bearings(24).d = 60; bearings(24).D = 110; bearings(24).B = 22; bearings(24).r = 2.5; bearings(24).C = 52.0; bearings(24).C0 = 31.0;
bearings(25).code = '213';  bearings(25).d = 65; bearings(25).D = 120; bearings(25).B = 23; bearings(25).r = 2.5; bearings(25).C = 56.0; bearings(25).C0 = 34.0;
bearings(26).code = '214';  bearings(26).d = 70; bearings(26).D = 125; bearings(26).B = 24; bearings(26).r = 2.5; bearings(26).C = 61.8; bearings(26).C0 = 37.5;
bearings(27).code = '215';  bearings(27).d = 75; bearings(27).D = 130; bearings(27).B = 25; bearings(27).r = 2.5; bearings(27).C = 66.3; bearings(27).C0 = 41.0;
bearings(28).code = '216';  bearings(28).d = 80; bearings(28).D = 140; bearings(28).B = 26; bearings(28).r = 3;   bearings(28).C = 70.2; bearings(28).C0 = 45.0;
bearings(29).code = '217';  bearings(29).d = 85; bearings(29).D = 150; bearings(29).B = 28; bearings(29).r = 3;   bearings(29).C = 83.2; bearings(29).C0 = 53.0;
bearings(30).code = '217A'; bearings(30).d = 85; bearings(30).D = 150; bearings(30).B = 28; bearings(30).r = 3;   bearings(30).C = 89.5; bearings(30).C0 = 56.5;
bearings(31).code = '218';  bearings(31).d = 90; bearings(31).D = 160; bearings(31).B = 30; bearings(31).r = 3;   bearings(31).C = 95.6; bearings(31).C0 = 62.0;
bearings(32).code = '219';  bearings(32).d = 95; bearings(32).D = 170; bearings(32).B = 32; bearings(32).r = 3.5; bearings(32).C = 108.0; bearings(32).C0 = 69.5;
bearings(33).code = '219A'; bearings(33).d = 95; bearings(33).D = 170; bearings(33).B = 32; bearings(33).r = 3.5; bearings(33).C = 115.0; bearings(33).C0 = 74.0;
bearings(34).code = '220';  bearings(34).d = 100; bearings(34).D = 180; bearings(34).B = 34; bearings(34).r = 3.5; bearings(34).C = 124.0; bearings(34).C0 = 79.0;

% Средняя серия (индексы сдвинуты на 10)
bearings(35).code = '300';   bearings(35).d = 10;  bearings(35).D = 35;  bearings(35).B = 11; bearings(35).r = 1;   bearings(35).C = 8.06; bearings(35).C0 = 3.75;
bearings(36).code = '301';   bearings(36).d = 12;  bearings(36).D = 37;  bearings(36).B = 12; bearings(36).r = 1.5; bearings(36).C = 9.75; bearings(36).C0 = 4.65;
bearings(37).code = '302';   bearings(37).d = 15;  bearings(37).D = 42;  bearings(37).B = 13; bearings(37).r = 1.5; bearings(37).C = 11.4; bearings(37).C0 = 5.4;
bearings(38).code = '303';   bearings(38).d = 17;  bearings(38).D = 47;  bearings(38).B = 14; bearings(38).r = 1.5; bearings(38).C = 13.5; bearings(38).C0 = 6.65;
bearings(39).code = '304';   bearings(39).d = 20;  bearings(39).D = 52;  bearings(39).B = 15; bearings(39).r = 2;   bearings(39).C = 15.9; bearings(39).C0 = 7.8;
bearings(40).code = '305';   bearings(40).d = 25;  bearings(40).D = 62;  bearings(40).B = 17; bearings(40).r = 2;   bearings(40).C = 22.5; bearings(40).C0 = 11.4;
bearings(41).code = '306';   bearings(41).d = 30;  bearings(41).D = 72;  bearings(41).B = 19; bearings(41).r = 2;   bearings(41).C = 28.1; bearings(41).C0 = 14.6;
bearings(42).code = '307';   bearings(42).d = 35;  bearings(42).D = 80;  bearings(42).B = 21; bearings(42).r = 2.5; bearings(42).C = 33.2; bearings(42).C0 = 18.0;
bearings(43).code = '308';   bearings(43).d = 40;  bearings(43).D = 90;  bearings(43).B = 23; bearings(43).r = 2.5; bearings(43).C = 41.0; bearings(43).C0 = 22.4;
bearings(44).code = '309';   bearings(44).d = 45;  bearings(44).D = 100; bearings(44).B = 25; bearings(44).r = 2.5; bearings(44).C = 52.7; bearings(44).C0 = 30.0;
bearings(45).code = '310';   bearings(45).d = 50;  bearings(45).D = 110; bearings(45).B = 27; bearings(45).r = 3;   bearings(45).C = 65.8; bearings(45).C0 = 36.0;
bearings(46).code = '311';   bearings(46).d = 55;  bearings(46).D = 120; bearings(46).B = 29; bearings(46).r = 3;   bearings(46).C = 71.5; bearings(46).C0 = 41.5;
bearings(47).code = '312';   bearings(47).d = 60;  bearings(47).D = 130; bearings(47).B = 31; bearings(47).r = 3.5; bearings(47).C = 81.9; bearings(47).C0 = 48.0;
bearings(48).code = '313';   bearings(48).d = 65;  bearings(48).D = 140; bearings(48).B = 33; bearings(48).r = 3.5; bearings(48).C = 92.3; bearings(48).C0 = 56.0;
bearings(49).code = '314';   bearings(49).d = 70;  bearings(49).D = 150; bearings(49).B = 35; bearings(49).r = 3.5; bearings(49).C = 104.0; bearings(49).C0 = 63.0;
bearings(50).code = '315';   bearings(50).d = 75;  bearings(50).D = 160; bearings(50).B = 37; bearings(50).r = 3.5; bearings(50).C = 112.0; bearings(50).C0 = 72.5;
bearings(51).code = '316';   bearings(51).d = 80;  bearings(51).D = 170; bearings(51).B = 39; bearings(51).r = 3.5; bearings(51).C = 124.0; bearings(51).C0 = 80.0;
bearings(52).code = '316K5'; bearings(52).d = 80;  bearings(52).D = 170; bearings(52).B = 39; bearings(52).r = 3.5; bearings(52).C = 130.0; bearings(52).C0 = 89.0;
bearings(53).code = '317';   bearings(53).d = 85;  bearings(53).D = 180; bearings(53).B = 41; bearings(53).r = 4;   bearings(53).C = 133.0; bearings(53).C0 = 90.0;
bearings(54).code = '318';   bearings(54).d = 90;  bearings(54).D = 190; bearings(54).B = 43; bearings(54).r = 4;   bearings(54).C = 143.0; bearings(54).C0 = 99.0;
bearings(55).code = '319';   bearings(55).d = 95;  bearings(55).D = 200; bearings(55).B = 45; bearings(55).r = 4;   bearings(55).C = 153.0; bearings(55).C0 = 110.0;
bearings(56).code = '319K5'; bearings(56).d = 95;  bearings(56).D = 200; bearings(56).B = 45; bearings(56).r = 4;   bearings(56).C = 161.0; bearings(56).C0 = 120.0;
bearings(57).code = '320';   bearings(57).d = 100; bearings(57).D = 215; bearings(57).B = 47; bearings(57).r = 4;   bearings(57).C = 174.0; bearings(57).C0 = 132.0;

    % Проверка индекса
    if idx < 1 || idx > length(bearings)
        error('Неверный номер подшипника. Доступен диапазон от 1 до %d.', length(bearings));
    end

    % Выбор параметра
    % param = lower(param); % Приводим к нижнему регистру для удобства
    
    switch param
        case 'd'
            val = bearings(idx).d;
        case 'D'
            val = bearings(idx).D;    
        case 'B'
            val = bearings(idx).B;
        case 'r'
            val = bearings(idx).r;
        case 'C'
            val = bearings(idx).C;
        case 'C0'
            val = bearings(idx).C0;
        case 'code'
            val = bearings(idx).code;
        otherwise
            error('Неизвестный параметр. Используйте: d, D, De, B, r, C, C0, code');
    end
end