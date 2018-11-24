clc; clear;

% -------- Execution --------
%init
PAGE_BYTES = 2^12;
BLOCK_BYTES = 2^6; 
PAGE_ROWS = PAGE_BYTES / BLOCK_BYTES;
BLOCK_BITS = BLOCK_BYTES*2^3;
PAGES_NUM = 100; %1000;
BIT_MEAN_WRITES = 1e8;
BIT_VAR_WRITES = 0.25 * BIT_MEAN_WRITES;

% RIDER
IS_RIDER_USED = false;

% Aegis AxB
AEGIS_DIM_A = 17;
AEGIS_DIM_B = 31;
Aegis = AegisMetadata(BIT_MEAN_WRITES, BIT_VAR_WRITES, PAGE_BYTES, BLOCK_BYTES, PAGES_NUM, AEGIS_DIM_A, AEGIS_DIM_B, IS_RIDER_USED);


%writes
WRITES_STEP = 1e6; %Writes resolution
active_pages_vs_writes_num = zeros(1, 1);
writes_num_vs_iteration = zeros(1, 1);
WRITE_WIDTH = BLOCK_BITS;

% Additional insights
faults_num_vs_iteration = zeros(1,1);
average_faults_per_row = 0;

% perform "virtual" writes
iter_counter=1;
writes_performed = 0;
%for writes_performed = WRITES_START:WRITES_DELTA:MAX_WRITES
IS_SIMULATION_SKIPPED = false; %Load stored .mat files
while ~Aegis.Memory.isMemoryDead() && ~IS_SIMULATION_SKIPPED
    % iterate over all active pages
    Aegis.writeToRandomRows(WRITES_STEP, WRITE_WIDTH);
    active_rows_list = Aegis.Memory.getActiveRowsList();
    num_of_active_pages = length(active_rows_list)/PAGE_ROWS;
    
    if mod(writes_performed, 1e10) == 0
        fprintf('iteration %d: working pages = %d\n', writes_performed/1e8, num_of_active_pages);    
    end

    %if mod(iter_counter,10) == 0
        active_pages_vs_writes_num(iter_counter) = num_of_active_pages;
        writes_num_vs_iteration(iter_counter) = writes_performed;
        faults_num_vs_iteration(iter_counter) = mean(nonzeros(Aegis.faults_in_killer_rows(:)));
               
        iter_counter = iter_counter+1;
    %end
    

    writes_performed = writes_performed + WRITES_STEP;
    
end
if ~IS_SIMULATION_SKIPPED
    fprintf('iteration %d: working pages = %d\n', writes_performed/1e8, num_of_active_pages);
end

if IS_RIDER_USED
    if IS_SIMULATION_SKIPPED
        load AEGIS_RIDER
    else
        save AEGIS_RIDER
    end
else
    if IS_SIMULATION_SKIPPED
        load AEGIS_WO_RIDER
    else
        save AEGIS_WO_RIDER
    end
end

    for i=1:1:2
        
        figure(66)
        set(gca, 'FontName', 'Helvetica')
        set(gca,'FontSize',16,'FontUnits','points');
        afFigureBackgroundColor = [1, 1, 1];
        set(gcf, 'color', afFigureBackgroundColor);
        set(gcf, 'InvertHardCopy', 'off');   
        set(findall(gca, 'Type', 'Line'),'LineWidth',3);
        
        if i==1 
            if isfile("AEGIS_RIDER.mat")
                load AEGIS_RIDER
                survmp_RIDER = 100*active_pages_vs_writes_num/PAGES_NUM;
                xx = writes_num_vs_iteration/PAGES_NUM;    
                plot(xx,survmp_RIDER,'r')
                hold on
            else
                continue;
            end
        elseif i==2 
            if isfile("AEGIS_WO_RIDER.mat")
                load AEGIS_WO_RIDER
                survmp_aegis = 100*active_pages_vs_writes_num/PAGES_NUM;
                xx_zombie = writes_num_vs_iteration/PAGES_NUM;    
                plot(xx_zombie,survmp_aegis,'b')
                if isfile("AEGIS_RIDER.mat")
                    hold off
                end
            else
                continue;
            end
        end
    end
    
    ylabel('Average number of faults in all blocks')

