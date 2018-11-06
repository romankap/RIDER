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

        Memory;
        
        spare_blocks_queue;
        paired_blocks_list;
        block_pairing_table;
    end
    
    methods
        function obj = ZombieMetadata(page_bytes, block_bytes, pages_num, ecp_max_errors_corrected)
            obj.PAGE_BYTES = page_bytes;
            obj.BLOCK_BYTES = block_bytes; 
            obj.PAGES_NUM = pages_num; %1000;
            obj.PAGE_ROWS = obj.PAGE_BYTES/obj.BLOCK_BYTES;
            obj.BITS_PER_BLOCK = obj.BLOCK_BYTES*8;
            obj.ROWS_IN_MEMORY = obj.PAGES_NUM * obj.PAGE_ROWS;
            obj.ECP_MAX_ERRORS_CORRECTED = ecp_max_errors_corrected;
            
            obj.Memory = MemoryArray(page_bytes, block_bytes, pages_num);
            
            % -- Zombie
            obj.paired_blocks_list = zeros(obj.PAGE_ROWS*obj.PAGES_NUM, 1);
            obj.spare_blocks_queue = [];
            obj.block_pairing_table = zeros(obj.PAGE_ROWS*obj.PAGES_NUM, 1);
        end
        
                
        function obj = writeToRandomRows(obj, writes_performed)
            num_of_active_rows = obj.Memory.getNumOfActiveRows();
            if num_of_active_rows > 0
                random_active_block = randi([1 num_of_active_rows]);
                active_rows_list = obj.Memory.getActiveRowsList();
                block_to_write=active_rows_list(random_active_block);

                obj.writeToRow(block_to_write, writes_performed);    
            end
        end
        
        
        function writeToRow(obj, row_to_write, writes_performed)
            spare_block_num = obj.block_pairing_table(row_to_write);
            if spare_block_num > 0 % The block is paired
                %write to spare block
                obj.Memory.writeToRow(spare_block_num, writes_performed);
                spare_block_dead_bits = obj.Memory.dead_bit_table(spare_block_num, :);
                primary_block_dead_bits = obj.Memory.dead_bit_table(row_to_write, :);
                dead_bits_on_both_blocks = and(primary_block_dead_bits, spare_block_dead_bits);
                if ~isempty(find(dead_bits_on_both_blocks, 1))
                    %replace the spare block
                    pairBlock(obj, row_to_write)
                end
            else
                obj.Memory.writeToRow(row_to_write, writes_performed);
                num_of_dead_bits = length(find(obj.Memory.dead_bit_table(row_to_write, :) > 0));
                if num_of_dead_bits > obj.ECP_MAX_ERRORS_CORRECTED
                    pairBlock(obj, row_to_write)
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

