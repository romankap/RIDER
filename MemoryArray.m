classdef MemoryArray < handle
    %MEMORYARRAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SAT_ENTRIES = 2^17;
        GCT_ENTRIES = 2^16;
        PAGE_BYTES;
        BLOCK_BYTES; 
        PAGES_NUM; %1000;
        PAGE_ROWS;
        BITS_PER_BLOCK;
        ROWS_IN_MEMORY;

        BIT_MEAN_WRITES;
        BIT_VAR_WRITES;
      
        memory_lifetime_table;
        writes_performed_table;
        dead_bit_table;
        active_rows_array; 
    end
    
    methods
        function obj = MemoryArray(page_bytes, block_bytes, pages_num)
            obj.BIT_MEAN_WRITES = 1e8;
            obj.BIT_VAR_WRITES = 0.25 * obj.BIT_MEAN_WRITES;
            
            obj.PAGE_BYTES = page_bytes;
            obj.BLOCK_BYTES = block_bytes; 
            obj.PAGES_NUM = pages_num; %1000;
            obj.PAGE_ROWS = obj.PAGE_BYTES/obj.BLOCK_BYTES;
            obj.BITS_PER_BLOCK = obj.BLOCK_BYTES*8;
            obj.ROWS_IN_MEMORY = obj.PAGES_NUM * obj.PAGE_ROWS;
            
%             obj.memory_lifetime_table = zeros(obj.ROWS_IN_MEMORY, obj.BITS_PER_BLOCK);
%             for i = 1:obj.ROWS_IN_MEMORY
%                 obj.memory_lifetime_table(i, :) = round(normrnd(obj.BIT_MEAN_WRITES, obj.BIT_VAR_WRITES, 1, obj.BITS_PER_BLOCK));
%             end
            obj.memory_lifetime_table = normrnd(obj.BIT_MEAN_WRITES, obj.BIT_VAR_WRITES, obj.ROWS_IN_MEMORY, obj.BITS_PER_BLOCK);
            obj.active_rows_array = ones(obj.PAGES_NUM*obj.PAGE_ROWS,1); 
            obj.dead_bit_table = zeros(obj.PAGE_ROWS*obj.PAGES_NUM, obj.BITS_PER_BLOCK);
            obj.writes_performed_table = zeros(obj.PAGE_ROWS*obj.PAGES_NUM, obj.BITS_PER_BLOCK);
        end
        
        % Memory operations
        function obj = writeToRow(obj, row_to_write, writes_performed, write_width)
            obj.writes_performed_table(row_to_write,:) = obj.writes_performed_table(row_to_write,:) + writes_performed*(write_width/obj.BITS_PER_BLOCK)/2;
            obj.dead_bit_table(row_to_write,:) = obj.writes_performed_table(row_to_write,:) > obj.memory_lifetime_table(row_to_write, :);
        end

        % Memory getters
        function num_of_pages = numOfActivePages(obj)
            num_of_pages = sum(obj.active_rows_array(:))/obj.PAGE_ROWS;
        end
        
        function page_num = get_page_num_of_block(obj, block_num)
            page_num = ceil(block_num/obj.PAGE_ROWS);
        end
        
        function active_rows_list = getActiveRowsList(obj)
            active_rows_list = find(obj.active_rows_array > 0);
        end
        
        function is_dead = isMemoryDead(obj)
            is_dead = isempty(find(obj.active_rows_array, 1));
        end
        
        function num_of_active_rows = getNumOfActiveRows(obj)
            num_of_active_rows = length(find(obj.active_rows_array > 0));
        end
    end
end

