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

global PAGES_NUM
PAGES_NUM = 100; %1000;


% -------- ECP Parameters --------
ECP_MAX_ERRORS_CORRECTED = 6;

% -------- Execution --------

%init
total_working_pages = PAGES_NUM;
pages = zeros(PAGE_ROWS, BITS_PER_BLOCK, PAGES_NUM);
for i = 1:PAGES_NUM
    pages(:, :, i) = round(normrnd(BIT_MEAN_WRITES, BIT_VAR_WRITES, PAGE_ROWS, BITS_PER_BLOCK));
end
active_rows_array = ones(PAGE_ROWS+1, PAGES_NUM); 
dead_bit_table = zeros(PAGE_ROWS, BITS_PER_BLOCK, PAGES_NUM);
writes_performed_table = zeros(PAGE_ROWS, PAGES_NUM);
%active_rows_array(some_page, PAGE_ROWS+1) marks whether the entire page is active

%writes
WRITES_START = 2e7; 
MAX_WRITES = 1e8; 
WRITES_RESOLUTION = 100; 
WRITES_DELTA = (MAX_WRITES-WRITES_START)/WRITES_RESOLUTION;
active_pages_vs_writes_num = zeros(1, WRITES_RESOLUTION+1);
writes_num_vs_iteration = zeros(1, WRITES_RESOLUTION+1);

% -- Zombie
paired_blocks_pool = zeros(PAGE_ROWS, PAGES_NUM);
spare_blocks_page_num_queue = [];
spare_blocks_row_num_queue = [];
block_pairing_table_page_num = zeros(PAGE_ROWS, PAGES_NUM);
block_pairing_table_block_num = zeros(PAGE_ROWS, PAGES_NUM);

%-- Zombie
pair_block_flag = false;

% perform "virtual" writes
iter_counter=0;
writes_performed = WRITES_START;
%for writes_performed = WRITES_START:WRITES_DELTA:MAX_WRITES
while writes_performed <= MAX_WRITES 
    % iterate over all active pages
    writes_num_vs_iteration(iter_counter+1) = writes_performed; 
    
    for page_num = find(active_rows_array(PAGE_ROWS+1,:) > 0)
        [xi, yi, vi] = find(writes_performed > pages(:,:,page_num));
        if ~isempty(xi)
            AA=full(sparse(xi,yi,vi));
            BB=sum(AA'>0);

            for bad_block_num = find(BB>ECP_MAX_ERRORS_CORRECTED) 
                % Uncorrectable block: allocate spare block, if exists.
                % Otherwise, put page in spare blocks pool.
                
                %-- Zombie
                % Case: a primary block is already paired with another block --> write to spare block
                if block_pairing_table_page_num(bad_block_num, page_num) ~= 0
                    spare_block_page_num = block_pairing_table_page_num(bad_block_num, page_num);
                    spare_block_block_num = block_pairing_table_block_num(bad_block_num, page_num);
                    dead_bit_table(bad_block_num, :, page_num) = pages(bad_block_num, :, page_num) < writes_performed;
                    
                    bad_bits_on_both_pages = and(dead_bit_table(spare_block_block_num, :, spare_block_page_num), ...
                                                dead_bit_table(bad_block_num, :, page_num));
                    if ~isempty(find(bad_bits_on_both_pages == true, 1))
                        pair_block_flag = true;
                        fprintf("\n!!! Found a dead spare block\n");
                    end
                end
                if pair_block_flag || block_pairing_table_page_num(bad_block_num, page_num) == 0
                    % Case: replace spare block a primary block is NOT paired with another block
                    [dontcare, spare_blocks] = size(spare_blocks_page_num_queue);
                    if spare_blocks > 0 % Pair the bad block
                        block_pairing_table_page_num(bad_block_num, page_num) = spare_blocks_page_num_queue(1);
                        block_pairing_table_block_num(bad_block_num, page_num) = spare_blocks_row_num_queue(1);
                        % Dequeue
                        spare_blocks_page_num_queue(1) = [];
                        spare_blocks_row_num_queue(1) = [];

                    else % All page blocks become spare-blocks
                        active_rows_array(:, page_num) = 0;
                        paired_blocks_pool(:, page_num) = 1; % add bad block to spare blocks pool
                        for i=1:1:PAGE_ROWS
                            spare_blocks_page_num_queue = Enqueue(spare_blocks_page_num_queue, page_num);
                            spare_blocks_row_num_queue = Enqueue(spare_blocks_row_num_queue, i);
                        end

                        dead_bit_table(:, :, page_num) = pages(:, :, page_num) < writes_performed;
                    end
                    
                end
                
            end
        end
    end
    
    fprintf("iteration %d: working pages = %d\n", 2*PAGE_ROWS*writes_performed/1e8, num_of_active_pages(active_rows_array(PAGE_ROWS+1, :)));
    iter_counter = iter_counter+1;
    active_pages_vs_writes_num(iter_counter) = num_of_active_pages(active_rows_array(PAGE_ROWS+1, :));
    pair_block_flag = false;
    
    %-- normalize writes to only active pages
    active_pages_fraction = fraction_of_active_pages(active_rows_array(PAGE_ROWS+1, :));
    if active_pages_fraction == 0
        break;
    end
    writes_performed = writes_performed + WRITES_DELTA;%*active_pages_fraction;
end
fprintf("iteration %d: working pages = %d\n", 2*PAGE_ROWS*writes_performed/1e8, num_of_active_pages(active_rows_array(PAGE_ROWS+1, :)));

save e58


%--------------------------
% PLOT
%--------------------------
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


function array = Enqueue(array, elem)
    array = [array elem];
end

function array = Dequeue(array)
    [m, array_elements] = size(array);
    if array_elements < 1
       return;
    end
    array(1) = [];
end