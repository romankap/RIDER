clear;clc

load ec26


% % % % ECP1
% % % load nc2
% % % survmp0 = 100*survm/(Pages*M);
% % % ex0=(rstp*wstp/Pages)*(1:length(survmp0));
% % % ESurPages0=survmp0;

% ECP-1 is the baseline
load ecp1_0
survmp0 = 100*survm/(Pages*M);
ex0=(rstp*wstp/Pages)*(1:length(survmp0));
ESurPages0=survmp0;

nc90=ex0(find(ESurPages0<=90,1));
nc50=ex0(find(ESurPages0<=50,1));


% ECP6
load ec201
survmp = 100*survm/(Pages*M);
ex2=(rstp*wstp/Pages)*(1:length(survmp));
ESurPages2=survmp;

ecp90=ex2(find(ESurPages2<=90,1));
ecp50=ex2(find(ESurPages2<=50,1));
% ECP6 over ECP1 lifetime improvement (%) at 90% and 50% mem
% capacity
ecp2nc90=100*(ecp90-nc90)/nc90;
ecp2nc50=100*(ecp50-nc50)/nc50;



% Placeholder for SAFER and PAYG
ex2_safer = ex2 * 1.05;     %1.147;
% ex2_payg = ex2 * 1.13;

sfr90=ex2_safer(find(ESurPages2<=90,1));
sfr50=ex2_safer(find(ESurPages2<=50,1));
% SAFER over ECP1 lifetime improvement (%) at 90% and 50% mem
% capacity
sfr2nc90=100*(sfr90-nc90)/nc90;
sfr2nc50=100*(sfr50-nc50)/nc50;



% RIDER-1
load d55
survmp = 100*survm/(Pages*M);
rx=(rstp*wstp/Pages)*(1:length(survmp));

rider90=rx(find(survmp<=90,1));
rider50=rx(find(survmp<=50,1));
% RIDER over ECP1 lifetime improvement (%) at 90% and 50% mem
% capacity
rider2nc90=100*(rider90-nc90)/nc90;
rider2nc50=100*(rider50-nc50)/nc50;



%FREE-p
load f11
fsurvmp = 100*survm/(Pages*M);
fx=(rstp*wstp/Pages)*(1:length(fsurvmp));

freep90=fx(find(fsurvmp<=90,1));
freep50=fx(find(fsurvmp<=50,1));
% FREE-p over ECP1 lifetime improvement (%) at 90% and 50% mem
% capacity
freep2nc90=100*(freep90-nc90)/nc90;
freep2nc50=100*(freep50-nc50)/nc50;


% RIDER-ECP5
% load d62
load re100
r4survmp = 100*survm/(Pages*M);
r4x=(rstp*wstp/Pages)*(1:length(r4survmp));

rdrecp90=r4x(find(r4survmp<=90,1));
rdrecp50=r4x(find(r4survmp<=50,1));
% RIDER+ECP5 over ECP1 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrecp2nc90=100*(rdrecp90-nc90)/nc90;
rdrecp2nc50=100*(rdrecp50-nc50)/nc50;


% RIDER-Free-p
load rf10
rfsurvmp = 100*survm/(Pages*M);
rfx=(rstp*wstp/Pages)*(1:length(rfsurvmp));

rdrfrp90=rfx(find(rfsurvmp<=90,1));
rdrfrp50=rfx(find(rfsurvmp<=50,1));
% RIDER+FREE-p over ECP1 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrfrp2nc90=100*(rdrfrp90-nc90)/nc90;
rdrfrp2nc50=100*(rdrfrp50-nc50)/nc50;


% RIDER-Zombie
load d104
rzsurvmp = 100*survm/(M);
rzx=(rstp*wstp/8)*(1:length(rzsurvmp));     % 8 is 512 / Page size (64)

rdrzmb90=rzx(find(rzsurvmp<=90,1));
rdrzmb50=rzx(find(rzsurvmp<=50,1));
% RIDER+Zombie over ECP1 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrzmb2nc90=100*(rdrzmb90-nc90)/nc90;
rdrzmb2nc50=100*(rdrzmb50-nc50)/nc50;


% RIDER-Zombie-ECP
load rze10
rzesurvmp = 100*survm/(M);
rze=(rstp*wstp/8)*(1:length(rzesurvmp));     % 8 is 512 / Page size (64)

rdrzmbecp90=rze(find(rzesurvmp<=90,1));
rdrzmbecp50=rze(find(rzesurvmp<=50,1));
% RIDER+Zombie+ECP5 over ECP1 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrzmbecp2nc90=100*(rdrzmbecp90-nc90)/nc90;
rdrzmbecp2nc50=100*(rdrzmbecp50-nc50)/nc50;

fprintf('Memory lifetime improvement of error recovery schemes vs. ECP1 (%%), at 90%% and 50%% memory capacity\n')
fprintf('%%\tECP6\tSAFER32\tFREE-p\tRIDER\tRIDER+ECP5\tRIDER+FREE-p\tRIDER+ZombieXOR\tRIDER+ZombieXOR+ECP5\n')
fprintf('90%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc90, sfr2nc90, freep2nc90, ...
    rider2nc90, rdrecp2nc90, rdrfrp2nc90, rdrzmb2nc90, rdrzmbecp2nc90)
fprintf('50%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc50, sfr2nc50, freep2nc50, ...
    rider2nc50, rdrecp2nc50, rdrfrp2nc50, rdrzmb2nc50, rdrzmbecp2nc50)


oh = [11.9 10.7 12.5 3.5 13.4 16 3.5 13.4]; % memory overhead, %

fprintf('\nContribution fo each overhead percent to lifetime improvement vs. ECP1 (%%), at 90%% and 50%% memory capacity\n')
fprintf('%%\tECP6\tSAFER32\tFREE-p\tRIDER\tRIDER+ECP5\tRIDER+FREE-p\tRIDER+ZombieXOR\tRIDER+ZombieXOR+ECP5\n')
fprintf('90%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc90/oh(1), ...
    sfr2nc90/oh(2), freep2nc90/oh(3), rider2nc90/oh(4), ...
    rdrecp2nc90/oh(5), rdrfrp2nc90/oh(6), rdrzmb2nc90/oh(7), rdrzmbecp2nc90/oh(8))
fprintf('50%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc50/oh(1), ... 
sfr2nc50/oh(2), freep2nc50/oh(3), rider2nc50/oh(4), ...
rdrecp2nc50/oh(5), rdrfrp2nc50/oh(6), rdrzmb2nc50/oh(7), rdrzmbecp2nc50/oh(8))



figure(71)
set(gca, 'FontName', 'Helvetica')
set(gca,'FontSize',16,'FontUnits','points');
afFigureBackgroundColor = [1, 1, 1];
set(gcf, 'color', afFigureBackgroundColor);
set(gcf, 'InvertHardCopy', 'off');    

plot(ex0,ESurPages0,'c')
hold

plot(rx,survmp,'r')

plot(ex2,movmean(ESurPages2,4),'g')
% plot(ex2,ESurPages2,'g')

plot(ex2_safer,movmean(ESurPages2,16),'b')
% plot(ex2_payg,movmean(ESurPages2,4),'y')


plot(fx,fsurvmp,'k')

plot(rfx,rfsurvmp,'k-x')

plot(r4x,r4survmp,'m')

plot(rzx,rzsurvmp,'r-x')

plot(rze,rzesurvmp,'r-o')


% plot(px,psurvmp,'m')

hold

set(findall(gca, 'Type', 'Line'),'LineWidth',3);

xlabel('Writes/page (B), \sigma=25%')
ylabel('Memory Capacity (%)')

legend('ECP1', 'RIDER_1', 'ECP_6', 'SAFER_3_2', 'FREE-p', 'RIDER_1+Free-p', ...
        'RIDER_1+ECP_5', 'RIDER+ZombieXOR', 'RIDER+ECP_5+ZombieXOR', 'Location','NE')    



