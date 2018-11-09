clear;clc

% RIDER with ECP6
load RIDER
survmp0 = 100*num_of_active_pages/(PAGES_NUM*(PAGE_BYTES/BLOCK_BYTES));
ex0=(writes_num_vs_iteration/PAGES_NUM)*(1:length(survmp0));
ESurPages0=survmp0;


% Zombie with ECP6
load Zombie
survmp = 100*num_of_active_pages/(PAGES_NUM*(PAGE_BYTES/BLOCK_BYTES));
ex2=(writes_num_vs_iteration/PAGES_NUM)*(1:length(survmp));
ESurPages2=survmp;


figure(71)
set(gca, 'FontName', 'Helvetica')
set(gca,'FontSize',16,'FontUnits','points');
afFigureBackgroundColor = [1, 1, 1];
set(gcf, 'color', afFigureBackgroundColor);
set(gcf, 'InvertHardCopy', 'off');    

plot(ex0,ESurPages0,'c')

%plot(rx,survmp,'r')

plot(ex2,movmean(ESurPages2,4),'g')
% plot(ex2,ESurPages2,'g')


set(findall(gca, 'Type', 'Line'),'LineWidth',3);

xlabel('Writes/page (B), \sigma=25%')
ylabel('Memory Capacity (%)')

legend('ECP1')    



