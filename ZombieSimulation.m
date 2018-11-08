clc; clear;

% -------- ECP Parameters --------
ECP_MAX_ERRORS_CORRECTED = 6;

% -------- Execution --------
%init
PAGE_BYTES = 2^12;
BLOCK_BYTES = 2^6; 
BLOCK_BITS = BLOCK_BYTES*2^3;
PAGES_NUM = 100; %1000;
BIT_MEAN_WRITES = 1e8;
BIT_VAR_WRITES = 0.25 * BIT_MEAN_WRITES;

IS_RIDER_USED = false;

Zombie = ZombieMetadata(BIT_MEAN_WRITES, BIT_VAR_WRITES, PAGE_BYTES, BLOCK_BYTES, PAGES_NUM, ECP_MAX_ERRORS_CORRECTED, IS_RIDER_USED);

%writes
WRITES_START = 0; 
MAX_WRITES = 10e8; 
WRITES_RESOLUTION = 100; 
WRITES_DELTA = (MAX_WRITES-WRITES_START)/WRITES_RESOLUTION;
WRITES_STEP = 2e6;
active_pages_vs_writes_num = zeros(1, WRITES_RESOLUTION+1);
writes_num_vs_iteration = zeros(1, WRITES_RESOLUTION+1);
WRITE_WIDTH = BLOCK_BITS;

%-- Zombie
pair_block_flag = false;

% perform "virtual" writes
iter_counter=0;
writes_performed = WRITES_START;
%for writes_performed = WRITES_START:WRITES_DELTA:MAX_WRITES
while ~Zombie.isMemoryDead()
    % iterate over all active pages
    writes_num_vs_iteration(iter_counter+1) = writes_performed; 
    
    Zombie.writeToRandomRows(WRITES_STEP, WRITE_WIDTH);
    active_rows_list = Zombie.getActiveRowsList();
    num_of_active_pages = length(active_rows_list)/Zombie.PAGE_ROWS;
    
    if mod(writes_performed, 1e10) == 0
        fprintf("iteration %d: working pages = %d\n", writes_performed/1e8, num_of_active_pages);    
    end
    
    iter_counter = iter_counter+1;
    active_pages_vs_writes_num(iter_counter) = num_of_active_pages;
    writes_performed = writes_performed + WRITES_STEP;
    
end
fprintf("iteration %d: working pages = %d\n", writes_performed/1e8, num_of_active_pages);

save ZombieW_WO_RIDER


%--------------------------
% PLOT
%--------------------------
load ZombieW_WO_RIDER
    survmp = 100*active_pages_vs_writes_num/PAGES_NUM;
    %xx=(WRITES_STEP/PAGES_NUM)*(1:length(survmp));
    xx = writes_num_vs_iteration/PAGES_NUM;

    figure(66)
    set(gca, 'FontName', 'Helvetica')
    set(gca,'FontSize',16,'FontUnits','points');
    afFigureBackgroundColor = [1, 1, 1];
    set(gcf, 'color', afFigureBackgroundColor);
    set(gcf, 'InvertHardCopy', 'off');    

    plot(xx,survmp,'r')
%     hold
%     plot(2*M*kk,ESurPages1,'b')
%     hold

    set(findall(gca, 'Type', 'Line'),'LineWidth',3);

    xlabel('Average writes/page (B), \sigma=25%')
    ylabel('Percentage of surviving rows')
%     legend('Rider_3_4_0', 'ECP_6', 'Location','SW')


    s90=xx(find(survmp<90,1));
    s50=xx(find(survmp<50,1));
    
    p90=100*(s90-2.87e9)/2.87e9;
    p50=100*(s50-5.36e9)/5.36e9;
    
    fprintf('90%% mem capacity after %2.2fB writes, 50%% mem capacity after %2.2fB writes\n',...
        s90*1e-9,s50*1e-9) 
    fprintf('%2.2f%% and %2.2f%% above "no replacement" scheme, respectively\n', p90, p50) 


%--------------------------
% Aux functions
%--------------------------

function fraction = fraction_of_active_pages(active_pages_array)
    global PAGES_NUM
    fraction = num_of_active_pages(active_pages_array)/PAGES_NUM;
end
