clear;clc

HPrct=90;
MPrct=50;
LPrct=25;

ROMAN_DECIMATE=100;

% baseline is 113.1% (reflects the highest overhead - AEGIS 9x61)
sfct = 113.1 ./ (100 + [3.9 11.9 10.7 6.6 12.5 3.5 12.5 11.3 3.5 11.3 12.5 13.1 10.1]);


% Aegis
%load AEGIS_9_61

load AEGIS_WO_RIDER
survmp_aegis = 100*active_pages_vs_writes_num/PAGES_NUM;
xx_zombie = writes_num_vs_iteration/PAGES_NUM;    
ax=decimate(xx_zombie, ROMAN_DECIMATE);
ay=sfct(12)*decimate(survmp_aegis,ROMAN_DECIMATE);

% RIDER+Aegis 17x31
load AEGIS_RIDER
survmp_RIDER = 100*active_pages_vs_writes_num/PAGES_NUM;
xx = writes_num_vs_iteration/PAGES_NUM;    
arx=decimate(xx, ROMAN_DECIMATE);
ary=sfct(13)*decimate(survmp_RIDER,ROMAN_DECIMATE);


csvwrite('70.csv',transpose(ax));
csvwrite('71.csv',transpose(ay));
csvwrite('140.csv',transpose(arx));
csvwrite('141.csv',transpose(ary));
fprintf("done\n");





    
    