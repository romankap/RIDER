classdef ZombieMetadata < handle
    %ZOMBIEMETADATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PAGE_BYTES;
        BLOCK_BYTES; 
        PAGE_ROWS;
        PAGES_NUM;
        BITS_PER_BLOCK;
        ROWS_IN_MEMORY;
        ECP_MAX_ERRORS_CORRECTED;
        BIT_MEAN_WRITES;
        BIT_VAR_WRITES;

        Memory;
        
        spare_blocks_queue;
        paired_blocks_list;
        block_pairing_table;
        
        ECP_corrected_errors_array;
        is_ECP_exhausted_array;
    end
    
    methods
        function obj = ZombieMetadata(lifetime_mean, lifetime_sigma, page_bytes, block_bytes, pages_num, ecp_max_errors_corrected)
            obj.PAGE_BYTES = page_bytes;
            obj.BLOCK_BYTES = block_bytes; 
            obj.PAGES_NUM = pages_num; %1000;
            obj.PAGE_ROWS = obj.PAGE_BYTES/obj.BLOCK_BYTES;
            obj.BITS_PER_BLOCK = obj.BLOCK_BYTES*8;
            obj.ROWS_IN_MEMORY = obj.PAGES_NUM * obj.PAGE_ROWS;
            obj.ECP_MAX_ERRORS_CORRECTED = ecp_max_errors_corrected;
            obj.BIT_MEAN_WRITES = lifetime_mean;
            obj.BIT_VAR_WRITES = lifetime_sigma;
            
            obj.Memory = MemoryArray(lifetime_mean, lifetime_sigma, page_bytes, block_bytes, pages_num);
            
            % -- Zombie
            obj.paired_blocks_list = zeros(obj.PAGE_ROWS*obj.PAGES_NUM, 1);
            obj.spare_blocks_queue = [];
            obj.block_pairing_table = zeros(obj.PAGE_ROWS*obj.PAGES_NUM, 1);
            obj.ECP_corrected_errors_array = zeros(obj.PAGES_NUM*obj.PAGE_ROWS,1); 
            obj.is_ECP_exhausted_array = zeros(obj.PAGES_NUM*obj.PAGE_ROWS,1); 
        end
        
                
        function obj = writeToRandomRows(obj, writes_performed, write_width)
            num_of_active_rows = obj.Memory.getNumOfActiveRows();
            if num_of_active_rows > 0
                random_active_block = randi([1 num_of_active_rows]);
                active_rows_list = obj.Memory.getActiveRowsList();
                block_to_write=active_rows_list(random_active_block);

                obj.writeToRow(block_to_write, writes_performed, write_width);    
            end
        end
        
        
        function writeToRow(obj, row_to_write, writes_performed, write_width)
            spare_block_num = obj.block_pairing_table(row_to_write);
            if spare_block_num > 0 % The block is paired
                if ~obj.is_ECP_exhausted_array(row_to_write) %The block uses its ECP
                    obj.Memory.writeToRow(row_to_write, writes_performed, write_width);
                    obj.updateECPArray(row_to_write);
                else
                    obj.Memory.writeToRow(spare_block_num, writes_performed, write_width);
                    obj.updateECPArray(spare_block_num);
                    
                    if obj.is_ECP_exhausted_array(spare_block_num)    
                        spare_block_dead_bits = obj.Memory.dead_bit_table(spare_block_num, :);
                        spare_block_dead_bit_indices = obj.Memory.dead_bit_table(spare_block_num, :) ~= 0;
                        obj.Memory.writeToBitsOfRow(row_to_write, spare_block_dead_bit_indices, writes_performed, write_width);
                        
                        primary_block_dead_bits = obj.Memory.dead_bit_table(row_to_write, :);
                        dead_bits_on_both_blocks = and(primary_block_dead_bits, spare_block_dead_bits);
                        if ~isempty(find(dead_bits_on_both_blocks, 1))
                            %replace the spare block
                            obj.pairBlock(row_to_write);
                            %obj.pairPage(row_to_write);
                        end    
                    end
                end
            else
                obj.Memory.writeToRow(row_to_write, writes_performed, write_width);
                obj.updateECPArray(row_to_write);
                if obj.is_ECP_exhausted_array(row_to_write)
                    obj.pairBlock(row_to_write);
                    %obj.pairPage(row_to_write);
                end
            end
        end
        
        
        function obj = pairBlock(obj, bad_block_num)
            if ~isempty(obj.spare_blocks_queue) % Pair the bad block
                obj.block_pairing_table(bad_block_num) = obj.DequeueSpareBlock();
            else
                makeAllPageBlocksSpare(obj, bad_block_num);
            end
        end
        
        
        function obj = pairPage(obj, bad_block_num)
            spare_page_num = obj.Memory.get_page_num_of_block(bad_block_num);
            if ~isempty(obj.spare_blocks_queue) % Pair the entire page of bad block with a spare page
                for i = obj.spare_blocks_queue
                    obj.block_pairing_table((spare_page_num-1)*obj.PAGE_ROWS+i) = obj.DequeueSpareBlock();    
                end
            else
                obj.makeAllPageBlocksSpare(bad_block_num);
            end
        end
        
        
        function updateECPArray(obj, row_to_update)
            if ~obj.is_ECP_exhausted_array(row_to_update)
                obj.ECP_corrected_errors_array(row_to_update) = length(find(obj.Memory.dead_bit_table(row_to_update,:)));
                
                if obj.ECP_corrected_errors_array(row_to_update) > obj.ECP_MAX_ERRORS_CORRECTED
                    obj.is_ECP_exhausted_array(row_to_update) = true;
                    % 0. Out of the dead bits: find cells that were corrected with ECP with small lifetime
                    dead_bit_indices = find(obj.Memory.dead_bit_table(row_to_update,:));
                    dead_bit_lifetimes = obj.Memory.memory_lifetime_table(row_to_update, dead_bit_indices);
                    [~, bits_to_fix_indices] = mink(dead_bit_lifetimes, obj.ECP_MAX_ERRORS_CORRECTED);
                    %bits_to_correct = obj.Memory.memory_lifetime_table(row_to_update, dead_bit_indices);
                    % Reset number of writes to bad bits
                    for bit_to_fix_relative_index=bits_to_fix_indices
                        bit_to_fix = dead_bit_indices(bit_to_fix_relative_index);
                        obj.Memory.memory_lifetime_table(row_to_update, bit_to_fix) = normrnd(obj.BIT_MEAN_WRITES, obj.BIT_VAR_WRITES);
                        obj.Memory.writes_performed_table(row_to_update, bit_to_fix) = 0;
                        obj.Memory.dead_bit_table(row_to_update, bit_to_fix) = 0;
                    end
                    % 2. Reset dead bits array
                end
            end
        end
        
        
        function obj = makeAllPageBlocksSpare(obj, bad_block_num)
            page_num = obj.Memory.get_page_num_of_block(bad_block_num);
            obj.Memory.active_rows_array((page_num-1)*obj.PAGE_ROWS+1 : page_num*obj.PAGE_ROWS) = 0;
            for i=1:1:obj.PAGE_ROWS
                spare_block_index = (page_num-1)*obj.PAGE_ROWS+i;
                obj.EnqueueSpareBlock(spare_block_index);
            end
        end
             
        % Queue operations
        function obj = EnqueueSpareBlock(obj, elem)
            obj.spare_blocks_queue = [obj.spare_blocks_queue elem];
        end
        
        function elem = DequeueSpareBlock(obj)
            num_of_spare_blocks = length(obj.spare_blocks_queue);
            if num_of_spare_blocks == 0
                elem = 0;
            else
                elem = obj.spare_blocks_queue(1);
                obj.spare_blocks_queue(1) = [];
            end
        end
        
        % General memory operations
        function is_dead = isMemoryDead(obj)
            is_dead = obj.Memory.isMemoryDead();
        end
        
        function active_rows_list = getActiveRowsList(obj)
            active_rows_list = obj.Memory.getActiveRowsList();
        end
    end
end

