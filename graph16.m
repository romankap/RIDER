clear;clc

HPrct=90;
MPrct=50;
LPrct=25;

ROMAN_DECIMATE=100;

% baseline is 113.1% (reflects the highest overhead - AEGIS 9x61)
sfct = 113.1 ./ (100 + [3.9 11.9 10.7 6.6 12.5 3.5 12.5 11.3 3.5 11.3 12.5 13.1 10.1]);


% ECP-2 is the baseline
% load ecp2_1
load ecp1_0
survmp0 = 100*survm/(Pages*M);
ex0=(rstp*wstp/Pages)*(1:length(survmp0));
ESurPages0=survmp0;

nc90=ex0(find(ESurPages0<=HPrct,1));
nc50=ex0(find(ESurPages0<=MPrct,1));
nc25=ex0(find(ESurPages0<=LPrct,1));


% ECP6
load ecp6_2
survmp = 100*survm/(Pages*M);
ex2=(rstp*wstp/Pages)*(1:length(survmp));
ESurPages2=survmp;

ecp90=ex2(find(ESurPages2<=HPrct,1));
ecp50=ex2(find(ESurPages2<=MPrct,1));
ecp25=ex2(find(ESurPages2<=LPrct,1));
% ECP6 over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
ecp2nc90=100*(ecp90-nc90)/nc90;
ecp2nc50=100*(ecp50-nc50)/nc50;
ecp2nc25=100*(ecp25-nc25)/nc25;



% Placeholder for SAFER 
ex2_safer = ex2 * 1.05;     %1.147;


sfr90=ex2_safer(find(ESurPages2<=HPrct,1));
sfr50=ex2_safer(find(ESurPages2<=MPrct,1));
sfr25=ex2_safer(find(ESurPages2<=LPrct,1));
% SAFER over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
sfr2nc90=100*(sfr90-nc90)/nc90;
sfr2nc50=100*(sfr50-nc50)/nc50;
sfr2nc25=100*(sfr25-nc25)/nc25;


% PAYG
load payg1
ypg = sfct(4)*100*survm/(Pages*M);
xpg=(rstp*wstp/Pages)*(1:length(ypg));

ypg90=xpg(find(ypg<=HPrct,1));
ypg50=xpg(find(ypg<=MPrct,1));
ypg25=xpg(find(ypg<=LPrct,1));
% PAYG over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
ypg2nc90=100*(ypg90-nc90)/nc90;
ypg2nc50=100*(ypg50-nc50)/nc50;
ypg2nc25=100*(ypg25-nc25)/nc25;


% RIDER
load d55
survmp = sfct(6)*100*survm/(Pages*M);
rx=(rstp*wstp/Pages)*(1:length(survmp));

rider90=rx(find(survmp<=HPrct,1));
rider50=rx(find(survmp<=MPrct,1));
rider25=rx(find(survmp<=LPrct,1));
% RIDER over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rider2nc90=100*(rider90-nc90)/nc90;
rider2nc50=100*(rider50-nc50)/nc50;
rider2nc25=100*(rider25-nc25)/nc25;



%FREE-p
load f11
fsurvmp = sfct(5)*100*survm/(Pages*M);
fx=(rstp*wstp/Pages)*(1:length(fsurvmp));

freep90=fx(find(fsurvmp<=HPrct,1));
freep50=fx(find(fsurvmp<=MPrct,1));
freep25=fx(find(fsurvmp<=LPrct,1));
% FREE-p over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
freep2nc90=100*(freep90-nc90)/nc90;
freep2nc50=100*(freep50-nc50)/nc50;
freep2nc25=100*(freep25-nc25)/nc25;


% RIDER-ECP4
% load d62
load re101
r4survmp = sfct(8)*100*survm/(Pages*M);
r4x=(rstp*wstp/Pages)*(1:length(r4survmp));

rdrecp90=r4x(find(r4survmp<=HPrct,1));
rdrecp50=r4x(find(r4survmp<=MPrct,1));
rdrecp25=r4x(find(r4survmp<=LPrct,1));
% RIDER+ECP4 over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrecp2nc90=100*(rdrecp90-nc90)/nc90;
rdrecp2nc50=100*(rdrecp50-nc50)/nc50;
rdrecp2nc25=100*(rdrecp25-nc25)/nc25;


% RIDER-Free-p
load rf10
rfsurvmp = sfct(7)*100*survm/(Pages*M);
rfx=(rstp*wstp/Pages)*(1:length(rfsurvmp));

rdrfrp90=rfx(find(rfsurvmp<=HPrct,1));
rdrfrp50=rfx(find(rfsurvmp<=MPrct,1));
rdrfrp25=rfx(find(rfsurvmp<=LPrct,1));
% RIDER+FREE-p over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrfrp2nc90=100*(rdrfrp90-nc90)/nc90;
rdrfrp2nc50=100*(rdrfrp50-nc50)/nc50;
rdrfrp2nc25=100*(rdrfrp25-nc25)/nc25;

% ZombieXOR
load Zombie_ecp6
zx=decimate(writes_num_vs_iteration, ROMAN_DECIMATE)/PAGES_NUM;
zy=sfct(11)*decimate(active_pages_vs_writes_num,ROMAN_DECIMATE)*100/PAGES_NUM;

zy90=zx(find(zy<=HPrct,1));
zy50=zx(find(zy<=MPrct,1));
zy25=zx(find(zy<=LPrct,1));
% ZombieXOR over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
zy2nc90=100*(zy90-nc90)/nc90;
zy2nc50=100*(zy50-nc50)/nc50;
zy2nc25=100*(zy25-nc25)/nc25;


% RIDER-XOR with ECP4
load RIDER_XOR_ecp4
riderx=decimate(writes_num_vs_iteration, ROMAN_DECIMATE)/PAGES_NUM;
ridery=sfct(10)*decimate(active_pages_vs_writes_num,ROMAN_DECIMATE)*100/PAGES_NUM;

rxe90=riderx(find(ridery<=HPrct,1));
rxe50=riderx(find(ridery<=MPrct,1));
rxe25=riderx(find(ridery<=LPrct,1));
% ZombieXOR over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rxe2nc90=100*(rxe90-nc90)/nc90;
rxe2nc50=100*(rxe50-nc50)/nc50;
rxe2nc25=100*(rxe25-nc25)/nc25;


% RIDER-XOR
load RIDER_XOR
riderxorx=decimate(writes_num_vs_iteration,ROMAN_DECIMATE)/PAGES_NUM;    % ?????
riderxory=sfct(9)*decimate(active_pages_vs_writes_num,ROMAN_DECIMATE)*100/PAGES_NUM;


rxx90=riderxorx(find(riderxory<=HPrct,1));
rxx50=riderxorx(find(riderxory<=MPrct,1));
rxx25=riderxorx(find(riderxory<=LPrct,1));
% ZombieXOR over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rxx2nc90=100*(rxx90-nc90)/nc90;
rxx2nc50=100*(rxx50-nc50)/nc50;
rxx2nc25=100*(rxx25-nc25)/nc25;

% Aegis
load AEGIS_9_61
% load AEGIS_WO_RIDER
survmp_aegis = 100*active_pages_vs_writes_num/PAGES_NUM;
xx_zombie = writes_num_vs_iteration/PAGES_NUM;    
ax=decimate(xx_zombie, ROMAN_DECIMATE);
ay=sfct(12)*decimate(survmp_aegis,ROMAN_DECIMATE);

ay90=ax(find(ay<=HPrct,1));
ay50=ax(find(ay<=MPrct,1));
ay25=ax(find(ay<=LPrct,1));
% AEGIS over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
ay2nc90=100*(ay90-nc90)/nc90;
ay2nc50=100*(ay50-nc50)/nc50;
ay2nc25=100*(ay25-nc25)/nc25;


% RIDER+Aegis 17x31
load RIDER_AEGIS_17_31
survmp_RIDER = 100*active_pages_vs_writes_num/PAGES_NUM;
xx = writes_num_vs_iteration/PAGES_NUM;    
arx=decimate(xx, ROMAN_DECIMATE);
ary=sfct(13)*decimate(survmp_RIDER,ROMAN_DECIMATE);

ary90=arx(find(ary<=HPrct,1));
ary50=arx(find(ary<=MPrct,1));
ary25=arx(find(ary<=LPrct,1));
% AEGIS+RIDER over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
ary2nc90=100*(ary90-nc90)/nc90;
ary2nc50=100*(ary50-nc50)/nc50;
ary2nc25=100*(ary25-nc25)/nc25;



fprintf('Memory lifetime improvement of error recovery schemes vs. ECP2 (%%), at %d%%, %d%% and %d%% memory capacity\n', ...
    HPrct, MPrct, LPrct)
fprintf('%%\tECP6\tSAFER32\tPAYG\tFREE-p\tZombieXOR\tAEGIS_9x61\tRIDER\tRIDER+ECP4\tRIDER+FREE-p\tRIDER-XOR\tRIDER-XOR+ECP4\tRIDER-AEGIS_17x31\n')
fprintf('%d%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', HPrct, ecp2nc90, sfr2nc90, ypg2nc90, freep2nc90, zy2nc90, ...
    ay2nc90, rider2nc90, rdrecp2nc90, rdrfrp2nc90, rxx2nc90, rxe2nc90, ary2nc90)
fprintf('%d%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', MPrct, ecp2nc50, sfr2nc50, ypg2nc50, freep2nc50, zy2nc50, ...
    ay2nc50, rider2nc50, rdrecp2nc50, rdrfrp2nc50, rxx2nc50, rxe2nc50, ary2nc50)
fprintf('%d%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', LPrct, ecp2nc25, sfr2nc25, ypg2nc25, freep2nc25, zy2nc25, ...
    ay2nc25, rider2nc25, rdrecp2nc25, rdrfrp2nc25, rxx2nc25, rxe2nc25, ary2nc25)


oh = [11.9 10.7 12.5 12.5 3.5 11.7 12.5 3.5 11.7 6.6 13.1 10.1]; % memory overhead, %

fprintf('\nContribution of a single percent of overhead to lifetime improvement vs. ECP2 (%%), at %d%%, %d%% and %d%% memory capacity\n', ...
    HPrct, MPrct, LPrct)
fprintf('%%\tECP6\tSAFER32\tPAYG\tFREE-p\tZombieXOR\tAEGIS_9x61\tRIDER\tRIDER+ECP4\tRIDER+FREE-p\tRIDER-XOR\tRIDER-XOR+ECP4\tRIDER-AEGIS_17x31\n')
fprintf('%d%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', HPrct, ecp2nc90/oh(1), ...
    sfr2nc90/oh(2), ypg2nc90/oh(10), freep2nc90/oh(3), zy2nc90/oh(4), ay2nc90/oh(11), rider2nc90/oh(5), ...
    rdrecp2nc90/oh(6), rdrfrp2nc90/oh(7), rxx2nc90/oh(8), rxe2nc90/oh(9), ary2nc90/oh(12))
fprintf('%d%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', MPrct, ecp2nc50/oh(1), ... 
sfr2nc50/oh(2), ypg2nc50/oh(10), freep2nc50/oh(3), zy2nc50/oh(4), ay2nc50/oh(11), rider2nc50/oh(5), ...
rdrecp2nc50/oh(6), rdrfrp2nc50/oh(7), rxx2nc50/oh(8), rxe2nc50/oh(9), ary2nc50/oh(12))
fprintf('%d%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', LPrct, ecp2nc25/oh(1), ... 
sfr2nc25/oh(2), ypg2nc25/oh(10), freep2nc25/oh(3), zy2nc25/oh(4), ay2nc25/oh(11), rider2nc25/oh(5), ...
rdrecp2nc25/oh(6), rdrfrp2nc25/oh(7), rxx2nc25/oh(8), rxe2nc25/oh(9), ary2nc25/oh(12))




no_correction_x = .5e9*(1:227)/227;
no_correction_y = 113.1:-.5:0;
ecp2_x = ex0;
ecp2_y = movmean(sfct(1)*ESurPages0,8);
ecp6_x = ex2;
ecp6_y = movmean(sfct(2)*ESurPages2,8);
safer_x = ex2_safer;
safer_y = movmean(sfct(3)*ESurPages2,8);



figure(174)
set(gca, 'FontName', 'Helvetica')
set(gca,'FontSize',12,'FontUnits','points');
afFigureBackgroundColor = [1, 1, 1];
set(gcf, 'color', afFigureBackgroundColor);
set(gcf, 'InvertHardCopy', 'off');    

plot(no_correction_x,no_correction_y,'b:')
hold

plot(ecp2_x,ecp2_y,'c--')

plot(ecp6_x, ecp6_y,'g')

plot(safer_x,safer_y,'m-.')

plot(xpg,ypg,'b')

plot(fx,fsurvmp,'k')

plot(ax,ay,'k-.')

plot(zx,zy,'b-.')


plot(rx,survmp,'r')

plot(rfx,rfsurvmp,'k--')

plot(r4x,r4survmp,'r')

plot(riderxorx, riderxory, 'r--')

plot(riderx,ridery,'r-.')


plot(arx,ary,'m--')


hold

set(findall(gca, 'Type', 'Line'),'LineWidth',1.2);

set(gca,'FontSize',16,'FontUnits','points');

xlabel('Writes/page (B), Coefficient of variation = 25%')
ylabel('Memory Capacity (%)')

set(gca,'FontSize',16,'FontUnits','points');

legend('No correction', 'ECP2', 'ECP_6', 'SAFER_3_2', 'PAYG', 'FREE-p', 'AEGIS_9_x_6_1','ZombieXOR', 'RIDER', 'RIDER+Free-p', ...
        'RIDER+ECP_4', 'RIDER-XOR', 'RIDER+ECP_4-XOR', 'RIDER+AEGIS_1_7_x_3_1', 'Location','NE')    


    
csvwrite('10.csv',no_correction_x);
csvwrite('11.csv',no_correction_y);
csvwrite('20.csv',ecp2_x);
csvwrite('21.csv',ecp2_y);
csvwrite('30.csv',ecp6_x);
csvwrite('31.csv',ecp6_y);
csvwrite('40.csv',safer_x);
csvwrite('41.csv',safer_y);
csvwrite('50.csv',xpg);
csvwrite('51.csv',ypg);
csvwrite('60.csv',fx);
csvwrite('61.csv',fsurvmp);
csvwrite('70.csv',ax);
csvwrite('71.csv',ay);
csvwrite('80.csv',zx);
csvwrite('81.csv',zy);
csvwrite('90.csv',rx);
csvwrite('91.csv',survmp);
csvwrite('100.csv',rfx);
csvwrite('101.csv',rfsurvmp);
csvwrite('110.csv',r4x);
csvwrite('111.csv',r4survmp);
csvwrite('120.csv',riderxorx);
csvwrite('121.csv',riderxory);
csvwrite('130.csv',riderx);
csvwrite('131.csv',ridery);
csvwrite('140.csv',arx);
csvwrite('141.csv',ary);





    
    