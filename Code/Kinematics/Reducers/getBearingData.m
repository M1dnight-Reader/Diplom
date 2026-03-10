function val = getBearingData(idx, param)
    % Проверка входных данных
    if nargin < 2
        error('Необходимо указать номер подшипника и имя параметра.');
    end

    % Инициализация структуры данных (массив структур)
    % Всего 47 подшипников: 24 из легкой серии и 23 из средней
    
    bearings(1).code = '200';   bearings(1).d = 10;  bearings(1).D = 30;  bearings(1).B = 9;  bearings(1).r = 1;   bearings(1).C = 5.9;  bearings(1).C0 = 2.65;
    bearings(2).code = '201';   bearings(2).d = 12;  bearings(2).D = 32;  bearings(2).B = 10; bearings(2).r = 1;   bearings(2).C = 6.89; bearings(2).C0 = 3.1;
    bearings(3).code = '202';   bearings(3).d = 15;  bearings(3).D = 35;  bearings(3).B = 11; bearings(3).r = 1;   bearings(3).C = 7.8;  bearings(3).C0 = 3.55;
    bearings(4).code = '203';   bearings(4).d = 17;  bearings(4).D = 40;  bearings(4).B = 12; bearings(4).r = 1;   bearings(4).C = 9.56; bearings(4).C0 = 4.5;
    bearings(5).code = '204';   bearings(5).d = 20;  bearings(5).D = 47;  bearings(5).B = 14; bearings(5).r = 1.5; bearings(5).C = 12.7; bearings(5).C0 = 6.2;
    bearings(6).code = '205';   bearings(6).d = 25;  bearings(6).D = 52;  bearings(6).B = 15; bearings(6).r = 1.5; bearings(6).C = 14.0; bearings(6).C0 = 6.95;
    bearings(7).code = '206';   bearings(7).d = 30;  bearings(7).D = 62;  bearings(7).B = 16; bearings(7).r = 1.5; bearings(7).C = 19.5; bearings(7).C0 = 10.0;
    bearings(8).code = '207';   bearings(8).d = 35;  bearings(8).D = 72;  bearings(8).B = 17; bearings(8).r = 2;   bearings(8).C = 25.5; bearings(8).C0 = 13.7;
    bearings(9).code = '208';   bearings(9).d = 40;  bearings(9).D = 80;  bearings(9).B = 18; bearings(9).r = 2;   bearings(9).C = 32.0; bearings(9).C0 = 17.8;
    bearings(10).code = '209';  bearings(10).d = 45; bearings(10).D = 85; bearings(10).B = 19; bearings(10).r = 2;  bearings(10).C = 33.2; bearings(10).C0 = 18.6;
    bearings(11).code = '209A'; bearings(11).d = 45; bearings(11).D = 85; bearings(11).B = 19; bearings(11).r = 2;  bearings(11).C = 36.4; bearings(11).C0 = 20.1;
    bearings(12).code = '210';  bearings(12).d = 50; bearings(12).D = 90; bearings(12).B = 20; bearings(12).r = 2;  bearings(12).C = 35.1; bearings(12).C0 = 19.8;
    bearings(13).code = '211';  bearings(13).d = 55; bearings(13).D = 100; bearings(13).B = 21; bearings(13).r = 2.5; bearings(13).C = 43.6; bearings(13).C0 = 25.0;
    bearings(14).code = '212';  bearings(14).d = 60; bearings(14).D = 110; bearings(14).B = 22; bearings(14).r = 2.5; bearings(14).C = 52.0; bearings(14).C0 = 31.0;
    bearings(15).code = '213';  bearings(15).d = 65; bearings(15).D = 120; bearings(15).B = 23; bearings(15).r = 2.5; bearings(15).C = 56.0; bearings(15).C0 = 34.0;
    bearings(16).code = '214';  bearings(16).d = 70; bearings(16).D = 125; bearings(16).B = 24; bearings(16).r = 2.5; bearings(16).C = 61.8; bearings(16).C0 = 37.5;
    bearings(17).code = '215';  bearings(17).d = 75; bearings(17).D = 130; bearings(17).B = 25; bearings(17).r = 2.5; bearings(17).C = 66.3; bearings(17).C0 = 41.0;
    bearings(18).code = '216';  bearings(18).d = 80; bearings(18).D = 140; bearings(18).B = 26; bearings(18).r = 3;   bearings(18).C = 70.2; bearings(18).C0 = 45.0;
    bearings(19).code = '217';  bearings(19).d = 85; bearings(19).D = 150; bearings(19).B = 28; bearings(19).r = 3;   bearings(19).C = 83.2; bearings(19).C0 = 53.0;
    bearings(20).code = '217A'; bearings(20).d = 85; bearings(20).D = 150; bearings(20).B = 28; bearings(20).r = 3;   bearings(20).C = 89.5; bearings(20).C0 = 56.5;
    bearings(21).code = '218';  bearings(21).d = 90; bearings(21).D = 160; bearings(21).B = 30; bearings(21).r = 3;   bearings(21).C = 95.6; bearings(21).C0 = 62.0;
    bearings(22).code = '219';  bearings(22).d = 95; bearings(22).D = 170; bearings(22).B = 32; bearings(22).r = 3.5; bearings(22).C = 108.0; bearings(22).C0 = 69.5;
    bearings(23).code = '219A'; bearings(23).d = 95; bearings(23).D = 170; bearings(23).B = 32; bearings(23).r = 3.5; bearings(23).C = 115.0; bearings(23).C0 = 74.0;
    bearings(24).code = '220';  bearings(24).d = 100; bearings(24).D = 180; bearings(24).B = 34; bearings(24).r = 3.5; bearings(24).C = 124.0; bearings(24).C0 = 79.0;

    % Средняя серия (продолжение нумерации с 25)
    bearings(25).code = '300';   bearings(25).d = 10;  bearings(25).D = 35;  bearings(25).B = 11; bearings(25).r = 1;   bearings(25).C = 8.06; bearings(25).C0 = 3.75;
    bearings(26).code = '301';   bearings(26).d = 12;  bearings(26).D = 37;  bearings(26).B = 12; bearings(26).r = 1.5; bearings(26).C = 9.75; bearings(26).C0 = 4.65;
    bearings(27).code = '302';   bearings(27).d = 15;  bearings(27).D = 42;  bearings(27).B = 13; bearings(27).r = 1.5; bearings(27).C = 11.4; bearings(27).C0 = 5.4;
    bearings(28).code = '303';   bearings(28).d = 17;  bearings(28).D = 47;  bearings(28).B = 14; bearings(28).r = 1.5; bearings(28).C = 13.5; bearings(28).C0 = 6.65;
    bearings(29).code = '304';   bearings(29).d = 20;  bearings(29).D = 52;  bearings(29).B = 15; bearings(29).r = 2;   bearings(29).C = 15.9; bearings(29).C0 = 7.8;
    bearings(30).code = '305';   bearings(30).d = 25;  bearings(30).D = 62;  bearings(30).B = 17; bearings(30).r = 2;   bearings(30).C = 22.5; bearings(30).C0 = 11.4;
    bearings(31).code = '306';   bearings(31).d = 30;  bearings(31).D = 72;  bearings(31).B = 19; bearings(31).r = 2;   bearings(31).C = 28.1; bearings(31).C0 = 14.6;
    bearings(32).code = '307';   bearings(32).d = 35;  bearings(32).D = 80;  bearings(32).B = 21; bearings(32).r = 2.5; bearings(32).C = 33.2; bearings(32).C0 = 18.0;
    bearings(33).code = '308';   bearings(33).d = 40;  bearings(33).D = 90;  bearings(33).B = 23; bearings(33).r = 2.5; bearings(33).C = 41.0; bearings(33).C0 = 22.4;
    bearings(34).code = '309';   bearings(34).d = 45;  bearings(34).D = 100; bearings(34).B = 25; bearings(34).r = 2.5; bearings(34).C = 52.7; bearings(34).C0 = 30.0;
    bearings(35).code = '310';   bearings(35).d = 50;  bearings(35).D = 110; bearings(35).B = 27; bearings(35).r = 3;   bearings(35).C = 65.8; bearings(35).C0 = 36.0;
    bearings(36).code = '311';   bearings(36).d = 55;  bearings(36).D = 120; bearings(36).B = 29; bearings(36).r = 3;   bearings(36).C = 71.5; bearings(36).C0 = 41.5;
    bearings(37).code = '312';   bearings(37).d = 60;  bearings(37).D = 130; bearings(37).B = 31; bearings(37).r = 3.5; bearings(37).C = 81.9; bearings(37).C0 = 48.0;
    bearings(38).code = '313';   bearings(38).d = 65;  bearings(38).D = 140; bearings(38).B = 33; bearings(38).r = 3.5; bearings(38).C = 92.3; bearings(38).C0 = 56.0;
    bearings(39).code = '314';   bearings(39).d = 70;  bearings(39).D = 150; bearings(39).B = 35; bearings(39).r = 3.5; bearings(39).C = 104.0; bearings(39).C0 = 63.0;
    bearings(40).code = '315';   bearings(40).d = 75;  bearings(40).D = 160; bearings(40).B = 37; bearings(40).r = 3.5; bearings(40).C = 112.0; bearings(40).C0 = 72.5;
    bearings(41).code = '316';   bearings(41).d = 80;  bearings(41).D = 170; bearings(41).B = 39; bearings(41).r = 3.5; bearings(41).C = 124.0; bearings(41).C0 = 80.0;
    bearings(42).code = '316K5'; bearings(42).d = 80;  bearings(42).D = 170; bearings(42).B = 39; bearings(42).r = 3.5; bearings(42).C = 130.0; bearings(42).C0 = 89.0;
    bearings(43).code = '317';   bearings(43).d = 85;  bearings(43).D = 180; bearings(43).B = 41; bearings(43).r = 4;   bearings(43).C = 133.0; bearings(43).C0 = 90.0;
    bearings(44).code = '318';   bearings(44).d = 90;  bearings(44).D = 190; bearings(44).B = 43; bearings(44).r = 4;   bearings(44).C = 143.0; bearings(44).C0 = 99.0;
    bearings(45).code = '319';   bearings(45).d = 95;  bearings(45).D = 200; bearings(45).B = 45; bearings(45).r = 4;   bearings(45).C = 153.0; bearings(45).C0 = 110.0;
    bearings(46).code = '319K5'; bearings(46).d = 95;  bearings(46).D = 200; bearings(46).B = 45; bearings(46).r = 4;   bearings(46).C = 161.0; bearings(46).C0 = 120.0;
    bearings(47).code = '320';   bearings(47).d = 100; bearings(47).D = 215; bearings(47).B = 47; bearings(47).r = 4;   bearings(47).C = 174.0; bearings(47).C0 = 132.0;

    % Проверка индекса
    if idx < 1 || idx > length(bearings)
        error('Неверный номер подшипника. Доступен диапазон от 1 до %d.', length(bearings));
    end

    % Выбор параметра
    param = lower(param); % Приводим к нижнему регистру для удобства
    
    switch param
        case 'd'
            val = bearings(idx).d;
        case 'D'
            val = bearings(idx).D;
        case 'b'
            val = bearings(idx).B;
        case 'r'
            val = bearings(idx).r;
        case 'c'
            val = bearings(idx).C;
        case 'c0'
            val = bearings(idx).C0;
        case 'code'
            val = bearings(idx).code;
        otherwise
            error('Неизвестный параметр. Используйте: d, D, B, r, C, C0, code');
    end
end