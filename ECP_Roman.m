clc; clear;
% -------- Global Variables --------
SAT_ENTRIES = 2^17;
GCT_ENTRIES = 2^16;

PAGE_BYTES = 2^12;
BLOCK_BYTES = 2^6;
BITS_PER_BLOCK = BLOCK_BYTES*8;
PAGE_ROWS = PAGE_BYTES/BLOCK_BYTES;

BIT_MEAN_WRITES = 1e8;
BIT_VAR_WRITES = 0.25*BIT_MEAN_WRITES;

PAGES_NUM = 1000;
global PAGES_NUM

% -------- ECP Parameters --------
ECP_MAX_ERRORS_CORRECTED = 6;

% -------- Execution --------

%init
total_working_pages = PAGES_NUM;
pages = zeros(PAGE_ROWS, BITS_PER_BLOCK, PAGES_NUM);
for i = 1:PAGES_NUM
    pages(:, :, i) = round(normrnd(BIT_MEAN_WRITES, BIT_VAR_WRITES, PAGE_ROWS, BITS_PER_BLOCK));
end
active_pages_array = ones(1,PAGES_NUM);

%writes
WRITES_START = 0;%2e7; 
MAX_WRITES = 1e8; 
WRITES_RESOLUTION = 2500; 
WRITES_DELTA = (MAX_WRITES-WRITES_START)/WRITES_RESOLUTION;
active_pages_vs_writes_num = zeros(1, WRITES_RESOLUTION+1);
writes_num_vs_iteration = zeros(1, WRITES_RESOLUTION+1);


% perform "virtual" writes
iter_counter=0;
writes_performed = WRITES_START;
%for writes_performed = WRITES_START:WRITES_DELTA:MAX_WRITES
while writes_performed <= MAX_WRITES 
    % iterate over all active pages
    writes_num_vs_iteration(iter_counter+1) = writes_performed; 
    for page_num = find(active_pages_array>0)
        [xi, yi, vi] = find(writes_performed > pages(:,:,page_num));
        if ~isempty(xi)
            AA=full(sparse(xi,yi,vi));
            BB=sum(AA'>0);

            if ~isempty(find(BB>ECP_MAX_ERRORS_CORRECTED, 1)) 
                active_pages_array(page_num) = 0;
            end
        end
    end
    
    fprintf("iteration %d: working pages = %d\n", 2*PAGE_ROWS*writes_performed/1e8, num_of_active_pages(active_pages_array));
    iter_counter = iter_counter+1;
    active_pages_vs_writes_num(iter_counter) = num_of_active_pages(active_pages_array);
    
    %-- normalize writes to only active pages
    active_pages_fraction = fraction_of_active_pages(active_pages_array);
    if active_pages_fraction == 0
        break;
    end
    writes_performed = writes_performed + WRITES_DELTA*active_pages_fraction;
end
fprintf("iteration %d: working pages = %d\n", 2*PAGE_ROWS*writes_performed/1e8, num_of_active_pages(active_pages_array));

save e58

% PLOT
load e58
    pages_vs_writes_unnormalized = 100*active_pages_vs_writes_num/PAGES_NUM;              
    
    sorted_pages_vs_writes_unnormalized = sort(pages_vs_writes_unnormalized,'descend');

    figure(54)
    set(gca, 'FontName', 'Helvetica')
    set(gca,'FontSize',16,'FontUnits','points');
    afFigureBackgroundColor = [1, 1, 1];
    set(gcf, 'color', afFigureBackgroundColor);
    set(gcf, 'InvertHardCopy', 'off');    

    % 2 because the probability of a bit to flip is 0.5
    plot(2*PAGE_ROWS*writes_num_vs_iteration, sorted_pages_vs_writes_unnormalized, 'b');
%     hold

    set(findall(gca, 'Type', 'Line'),'LineWidth',3);

    xlabel('Average writes/page (B), \sigma=25%');
    ylabel('Percentage of surviving pages');
%     legend('Rider_3_4_0', 'ECP_6', 'Location','SW')


%--------------------------
% Aux functions
%--------------------------

function num_of_pages = num_of_active_pages(active_pages_array)
    num_of_pages = sum(active_pages_array(:));
end

function fraction = fraction_of_active_pages(active_pages_array)
    global PAGES_NUM
    fraction = num_of_active_pages(active_pages_array)/PAGES_NUM;
end