clear;clc

load ec26


% % % % ECP2
% % % load nc2
% % % survmp0 = 100*survm/(Pages*M);
% % % ex0=(rstp*wstp/Pages)*(1:length(survmp0));
% % % ESurPages0=survmp0;

% ECP-2 is the baseline
load ecp2_1
survmp0 = 100*survm/(Pages*M);
ex0=(rstp*wstp/Pages)*(1:length(survmp0));
ESurPages0=survmp0;

nc90=ex0(find(ESurPages0<=90,1));
nc50=ex0(find(ESurPages0<=50,1));
nc25=ex0(find(ESurPages0<=25,1));


% ECP6
load ec201
survmp = 100*survm/(Pages*M);
ex2=(rstp*wstp/Pages)*(1:length(survmp));
ESurPages2=survmp;

ecp90=ex2(find(ESurPages2<=90,1));
ecp50=ex2(find(ESurPages2<=50,1));
ecp25=ex2(find(ESurPages2<=25,1));
% ECP6 over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
ecp2nc90=100*(ecp90-nc90)/nc90;
ecp2nc50=100*(ecp50-nc50)/nc50;
ecp2nc25=100*(ecp25-nc25)/nc25;



% Placeholder for SAFER and PAYG
ex2_safer = ex2 * 1.05;     %1.147;
% ex2_payg = ex2 * 1.13;

sfr90=ex2_safer(find(ESurPages2<=90,1));
sfr50=ex2_safer(find(ESurPages2<=50,1));
sfr25=ex2_safer(find(ESurPages2<=25,1));
% SAFER over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
sfr2nc90=100*(sfr90-nc90)/nc90;
sfr2nc50=100*(sfr50-nc50)/nc50;
sfr2nc25=100*(sfr25-nc25)/nc25;



% RIDER-1
load d55
survmp = 100*survm/(Pages*M);
rx=(rstp*wstp/Pages)*(1:length(survmp));

rider90=rx(find(survmp<=90,1));
rider50=rx(find(survmp<=50,1));
rider25=rx(find(survmp<=25,1));
% RIDER over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rider2nc90=100*(rider90-nc90)/nc90;
rider2nc50=100*(rider50-nc50)/nc50;
rider2nc25=100*(rider25-nc25)/nc25;



%FREE-p
load f11
fsurvmp = 100*survm/(Pages*M);
fx=(rstp*wstp/Pages)*(1:length(fsurvmp));

freep90=fx(find(fsurvmp<=90,1));
freep50=fx(find(fsurvmp<=50,1));
freep25=fx(find(fsurvmp<=25,1));
% FREE-p over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
freep2nc90=100*(freep90-nc90)/nc90;
freep2nc50=100*(freep50-nc50)/nc50;
freep2nc25=100*(freep25-nc25)/nc25;


% RIDER-ECP4
% load d62
load re101
r4survmp = 100*survm/(Pages*M);
r4x=(rstp*wstp/Pages)*(1:length(r4survmp));

rdrecp90=r4x(find(r4survmp<=90,1));
rdrecp50=r4x(find(r4survmp<=50,1));
rdrecp25=r4x(find(r4survmp<=25,1));
% RIDER+ECP4 over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrecp2nc90=100*(rdrecp90-nc90)/nc90;
rdrecp2nc50=100*(rdrecp50-nc50)/nc50;
rdrecp2nc25=100*(rdrecp25-nc25)/nc25;


% RIDER-Free-p
load rf10
rfsurvmp = 100*survm/(Pages*M);
rfx=(rstp*wstp/Pages)*(1:length(rfsurvmp));

rdrfrp90=rfx(find(rfsurvmp<=90,1));
rdrfrp50=rfx(find(rfsurvmp<=50,1));
rdrfrp25=rfx(find(rfsurvmp<=25,1));
% RIDER+FREE-p over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrfrp2nc90=100*(rdrfrp90-nc90)/nc90;
rdrfrp2nc50=100*(rdrfrp50-nc50)/nc50;
rdrfrp2nc25=100*(rdrfrp25-nc25)/nc25;


% RIDER-Zombie
load d104
rzsurvmp = 100*survm/(M);
rzx=(rstp*wstp/8)*(1:length(rzsurvmp));     % 8 is 512 / Page size (64)

rdrzmb90=rzx(find(rzsurvmp<=90,1));
rdrzmb50=rzx(find(rzsurvmp<=50,1));
rdrzmb25=rzx(find(rzsurvmp<=25,1));
% RIDER+Zombie over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrzmb2nc90=100*(rdrzmb90-nc90)/nc90;
rdrzmb2nc50=100*(rdrzmb50-nc50)/nc50;
rdrzmb2nc25=100*(rdrzmb25-nc25)/nc25;


% RIDER-Zombie-ECP
load rze10
rzesurvmp = 100*survm/(M);
rze=(rstp*wstp/8)*(1:length(rzesurvmp));     % 8 is 512 / Page size (64)

rdrzmbecp90=rze(find(rzesurvmp<=90,1));
rdrzmbecp50=rze(find(rzesurvmp<=50,1));
rdrzmbecp25=rze(find(rzesurvmp<=25,1));
% RIDER+Zombie+ECP4 over ECP2 lifetime improvement (%) at 90% and 50% mem
% capacity
rdrzmbecp2nc90=100*(rdrzmbecp90-nc90)/nc90;
rdrzmbecp2nc50=100*(rdrzmbecp50-nc50)/nc50;
rdrzmbecp2nc25=100*(rdrzmbecp25-nc25)/nc25;

fprintf('Memory lifetime improvement of error recovery schemes vs. ECP2 (%%), at 90%% and 50%% memory capacity\n')
fprintf('%%\tECP6\tSAFER32\tFREE-p\tRIDER\tRIDER+ECP4\tRIDER+FREE-p\tRIDER+ZombieXOR\tRIDER+ZombieXOR+ECP4\n')
fprintf('90%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc90, sfr2nc90, freep2nc90, ...
    rider2nc90, rdrecp2nc90, rdrfrp2nc90, rdrzmb2nc90, rdrzmbecp2nc90)
fprintf('50%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc50, sfr2nc50, freep2nc50, ...
    rider2nc50, rdrecp2nc50, rdrfrp2nc50, rdrzmb2nc50, rdrzmbecp2nc50)
fprintf('25%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc25, sfr2nc25, freep2nc25, ...
    rider2nc25, rdrecp2nc25, rdrfrp2nc25, rdrzmb2nc25, rdrzmbecp2nc25)

oh = [11.9 10.7 12.5 3.5 11.7 16 3.5 11.7]; % memory overhead, %

fprintf('\nContribution fo each overhead percent to lifetime improvement vs. ECP2 (%%), at 90%% and 50%% memory capacity\n')
fprintf('%%\tECP6\tSAFER32\tFREE-p\tRIDER\tRIDER+ECP4\tRIDER+FREE-p\tRIDER+ZombieXOR\tRIDER+ZombieXOR+ECP4\n')
fprintf('90%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc90/oh(1), ...
    sfr2nc90/oh(2), freep2nc90/oh(3), rider2nc90/oh(4), ...
    rdrecp2nc90/oh(5), rdrfrp2nc90/oh(6), rdrzmb2nc90/oh(7), rdrzmbecp2nc90/oh(8))
fprintf('50%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc50/oh(1), ... 
sfr2nc50/oh(2), freep2nc50/oh(3), rider2nc50/oh(4), ...
rdrecp2nc50/oh(5), rdrfrp2nc50/oh(6), rdrzmb2nc50/oh(7), rdrzmbecp2nc50/oh(8))
fprintf('25%%\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', ecp2nc25/oh(1), ... 
sfr2nc25/oh(2), freep2nc25/oh(3), rider2nc25/oh(4), ...
rdrecp2nc25/oh(5), rdrfrp2nc25/oh(6), rdrzmb2nc25/oh(7), rdrzmbecp2nc25/oh(8))


load Zombie_ecp6
zx=decimate(writes_num_vs_iteration, 100)/100;
zy=decimate(active_pages_vs_writes_num,100);

load RIDER_XOR_ecp4
riderx=decimate(writes_num_vs_iteration, 100)/100;
ridery=decimate(active_pages_vs_writes_num,100);


% RIDER-Zombie
load RIDER_XOR
riderxorx=decimate(writes_num_vs_iteration, 100)/100;
riderxory=decimate(active_pages_vs_writes_num,100);


figure(171)
set(gca, 'FontName', 'Helvetica')
set(gca,'FontSize',16,'FontUnits','points');
afFigureBackgroundColor = [1, 1, 1];
set(gcf, 'color', afFigureBackgroundColor);
set(gcf, 'InvertHardCopy', 'off');    

plot(ex0,movmean(ESurPages0,8),'c')
hold

plot(rx,survmp,'r')

plot(ex2,movmean(ESurPages2,8),'g')
% plot(ex2,ESurPages2,'g')

plot(ex2_safer,movmean(ESurPages2,16),'m')
% plot(ex2_payg,movmean(ESurPages2,4),'y')


plot(fx,fsurvmp,'k')

plot(rfx,rfsurvmp,'k-x')

plot(r4x,r4survmp,'r')

% plot(rzx,rzsurvmp,'r-x')

% plot(rze,rzesurvmp,'r-o')

plot(riderxorx, riderxory, 'r--')

plot(riderx,ridery,'r--.')

plot(zx,zy,'b-.')

hold

set(findall(gca, 'Type', 'Line'),'LineWidth',3);

xlabel('Writes/page (B), \sigma=25%')
ylabel('Memory Capacity (%)')

legend('ECP2', 'RIDER', 'ECP_6', 'SAFER_3_2', 'FREE-p', 'RIDER+Free-p', ...
        'RIDER+ECP_4', 'RIDER-XOR', 'RIDER+ECP_4-XOR', 'ZombieXOR', 'Location','NE')    

% legend('ECP2', 'RIDER', 'ECP_6', 'SAFER_3_2', 'FREE-p', 'RIDER_1+Free-p', ...
%         'RIDER+ECP_4', 'RIDER+ECP_4-XOR', 'ZombieXOR', 'Location','NE')    

    
figure(73)
set(gca, 'FontName', 'Helvetica')
set(gca,'FontSize',16,'FontUnits','points');
afFigureBackgroundColor = [1, 1, 1];
set(gcf, 'color', afFigureBackgroundColor);
set(gcf, 'InvertHardCopy', 'off');    



plot(ecp50,     oh(1), '*')
hold
plot(sfr50,     oh(2), 's')
plot(freep50,   oh(3), 'd')
plot(rider50,   oh(4), '+')
plot(rdrecp50,  oh(5), 'o')
plot(rdrfrp50,  oh(6), '^')
plot(rdrzmb50,  oh(7), 'p')
plot(rdrzmbecp50, oh(8), 'v')
hold

    set(findall(gca, 'Type', 'Line'),'LineWidth',6);

xlabel('Writes/page (B), \sigma=25% bringing memory capacity to 50%')
ylabel('Memory Overhead (%)')

legend('ECP_6', 'SAFER_3_2', 'FREE-p', 'RIDER', 'RIDER+ECP_4',  ...
        'RIDER_1+Free-p', 'RIDER+ZombieXOR', 'RIDER+ECP_4+ZombieXOR', 'Location','SE')    

