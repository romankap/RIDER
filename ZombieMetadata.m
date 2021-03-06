classdef ZombieMetadata < handle
   
    properties
        PAGE_BYTES;
        BLOCK_BYTES; 
        PAGE_ROWS;
        PAGES_NUM;
        BITS_PER_BLOCK;
        ROWS_IN_MEMORY;
        ECP_MAX_ERRORS_CORRECTED;
        ECP_CORRECTIONS_FACTOR; %To be used with RIDER
        BIT_MEAN_WRITES;
        BIT_VAR_WRITES;

        Memory;
        
        spare_blocks_queue;
        block_pairing_table;
        current_primary_blocks;
        
        ECP_corrected_errors_array;
        is_ECP_exhausted_array;
        
        IS_RIDER_USED;
        RIDER_first_order_spare_block;        
        RIDER_second_order_spare_block;
    end
    
    methods
        function obj = ZombieMetadata(lifetime_mean, lifetime_sigma, page_bytes, block_bytes, pages_num, ecp_max_errors_corrected, is_RIDER_used)
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
            obj.spare_blocks_queue = [];
            obj.block_pairing_table = zeros(obj.PAGE_ROWS*obj.PAGES_NUM, 1);
            obj.ECP_corrected_errors_array = zeros(obj.PAGES_NUM*obj.PAGE_ROWS,1); 
            obj.is_ECP_exhausted_array = zeros(obj.PAGES_NUM*obj.PAGE_ROWS,1);
            
            % -- Analytics
            obj.current_primary_blocks = 0;
            
            obj.IS_RIDER_USED = is_RIDER_used;
            if obj.IS_RIDER_USED
                obj.ECP_CORRECTIONS_FACTOR = 2;
            else
                obj.ECP_CORRECTIONS_FACTOR = 1;
            end
            
            
            obj.RIDER_first_order_spare_block = 0;
            obj.RIDER_second_order_spare_block = 0;
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
                % Write to spare. No page-pairing, only block-pairing
                obj.Memory.writeToRow(spare_block_num, writes_performed, write_width);
                spare_block_dead_bits = obj.Memory.dead_bit_table(spare_block_num, :);
                spare_block_dead_bit_indices = find(obj.Memory.dead_bit_table(spare_block_num, :));
                obj.Memory.writeToBitsOfRow(row_to_write, spare_block_dead_bit_indices, writes_performed, write_width);

                primary_block_dead_bits = obj.Memory.dead_bit_table(row_to_write, :);
                dead_bits_on_both_blocks = and(primary_block_dead_bits, spare_block_dead_bits);
                
                ECP_correctable_blocks = obj.ECP_CORRECTIONS_FACTOR * obj.ECP_MAX_ERRORS_CORRECTED;
                num_of_dead_bits_on_both_blocks = size(find(dead_bits_on_both_blocks));
                if num_of_dead_bits_on_both_blocks(2) > ECP_correctable_blocks
                    obj.pairBlock(row_to_write);
                end
            else % Case: a regular block utilized all his ECP. Corrected bit with ECP become dead.
                obj.Memory.writeToRow(row_to_write, writes_performed, write_width);
                %obj.updateECPArray(row_to_write);
                if length(find(obj.Memory.dead_bit_table(row_to_write, :))) > obj.ECP_MAX_ERRORS_CORRECTED
                    obj.pairBlock(row_to_write);
                end
            end
        end
        
                
        function obj = pairBlock(obj, bad_block_num)
            if obj.IS_RIDER_USED
                obj.pairBlockWithRIDER(bad_block_num);
            else % Zombie Scheme
                if ~isempty(obj.spare_blocks_queue) 
                    obj.block_pairing_table(bad_block_num) = obj.DequeueSpareBlock();
                else
                    obj.makeAllPageBlocksSpare(bad_block_num);
                end    
            end
        end
        
        
        %%%%%%%%%%%%%%% RIDER
        
        function obj = pairBlockWithRIDER(obj, primary_block_num)
            spare_block_num = obj.block_pairing_table(primary_block_num);
            if spare_block_num == 0
                %First time primary block dies
                if obj.RIDER_first_order_spare_block ~= 0 % If a spare exists, pair the block
                    obj.block_pairing_table(primary_block_num) = obj.RIDER_first_order_spare_block;
                    obj.block_pairing_table(obj.RIDER_first_order_spare_block) = 0;
                    obj.RIDER_first_order_spare_block = 0;
                else % If a spare DOES NOT exist, make it a spare block
                    obj.RIDER_first_order_spare_block = primary_block_num;
                    obj.Memory.inactivateMemoryRow(primary_block_num);
                end
            else
                %Paired primary block that died --> put in second order spare block
                if obj.RIDER_second_order_spare_block ~= 0
                    obj.block_pairing_table(primary_block_num) = obj.RIDER_second_order_spare_block;
                    obj.block_pairing_table(obj.RIDER_second_order_spare_block) = 0;
                    obj.RIDER_second_order_spare_block = 0;
                else 
                    obj.RIDER_second_order_spare_block = primary_block_num;
                    obj.block_pairing_table(primary_block_num) = 0;
                    obj.Memory.inactivateMemoryRow(primary_block_num);
                end
            end
        end
        
        %%%%%%%%%%%%%%%
        
        
        function obj = makeAllPageBlocksSpare(obj, bad_block_num)
            page_num = obj.Memory.get_page_num_of_block(bad_block_num);
            obj.Memory.active_rows_array((page_num-1)*obj.PAGE_ROWS+1 : page_num*obj.PAGE_ROWS) = 0;
            for i=1:1:obj.PAGE_ROWS
                new_spare_block_index = (page_num-1)*obj.PAGE_ROWS+i;
                obj.EnqueueSpareBlock(new_spare_block_index);
                
                spare_of_spare_block_index = obj.block_pairing_table(new_spare_block_index);
                if spare_of_spare_block_index ~= 0
                    obj.EnqueueSpareBlock(spare_of_spare_block_index);
                    obj.block_pairing_table(new_spare_block_index) = 0;
                end
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
        
        % Defunct functions
                
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
        
        
        function obj = updateECPArray(obj, row_to_update)
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
        
        
        function isFixWorked = fixSingleBitWithECP(obj, row_to_update, bit_to_fix)    
            %%%% Leonid
            if obj.IS_RIDER_USED     
                fct=2;
            else
                fct=1;
            end
                
            if obj.ECP_corrected_errors_array(row_to_update) < fct * obj.ECP_MAX_ERRORS_CORRECTED             %%%%%%%%
                obj.Memory.memory_lifetime_table(row_to_update, bit_to_fix) = normrnd(obj.BIT_MEAN_WRITES, obj.BIT_VAR_WRITES);
                obj.Memory.writes_performed_table(row_to_update, bit_to_fix) = 0;
                obj.Memory.dead_bit_table(row_to_update, bit_to_fix) = 0;
                obj.ECP_corrected_errors_array(row_to_update) = obj.ECP_corrected_errors_array(row_to_update) + 1;
                isFixWorked = true;
            else
                isFixWorked = false;
            end
        end
        
                
        function isFixWorked = fixBitsWithECP(obj, row_to_update, bits_to_fix_list) %Should be called on spare block bits
            if ~obj.is_ECP_exhausted_array(row_to_update)
                for bit_to_fix = bits_to_fix_list
                    isFixWorked = obj.fixSingleBitWithECP(row_to_update, bit_to_fix);
                    if ~isFixWorked
                        obj.is_ECP_exhausted_array(row_to_update) = true;
                        isFixWorked = false;
                        return;
                    end
                end
                isFixWorked = true;
            else
                isFixWorked = false;
            end
        end
        
    end
end

