classdef Aegis < handle
    
    properties
        PAGE_BYTES;
        BLOCK_BYTES; 
        PAGE_ROWS;
        PAGES_NUM;
        BITS_PER_BLOCK;
        ROWS_IN_MEMORY;

        slope_k;
        A;
        B;
        groups_used_table;
        
        Memory;
    end
    
    methods
        function obj = Aegis(lifetime_mean, lifetime_sigma, page_bytes, block_bytes, pages_num, dim_X, dim_Y)
            obj.PAGE_BYTES = page_bytes;
            obj.BLOCK_BYTES = block_bytes; 
            obj.PAGES_NUM = pages_num; %1000;
            obj.PAGE_ROWS = obj.PAGE_BYTES/obj.BLOCK_BYTES;
            obj.BITS_PER_BLOCK = obj.BLOCK_BYTES*8;
            obj.ROWS_IN_MEMORY = obj.PAGES_NUM * obj.PAGE_ROWS;
            
            obj.slope_k = 0;
            obj.A = dim_X;
            obj.B = dim_Y;
            obj.groups_used_table = zeros(obj.PAGE_ROWS*obj.PAGES_NUM, obj.B);
            
            obj.Memory = MemoryArray(lifetime_mean, lifetime_sigma, page_bytes, block_bytes, pages_num);
        end
        
        
        function writeToRow(obj, row_to_write, writes_performed, write_width)
            obj.Memory.writeToRow(row_to_write, writes_performed, write_width);
            dead_bit_indices = find(obj.Memory.dead_bit_table(spare_block_num, :));
            
            %TODO:
            %1. Check if there is more than 1 error per group
            %2. If more than 1 -> repartition
            %3. 
        end
        
        
        function obj = repartition(errors_bit_indices)
            %1. Increment slope
            %2. Check if new partition works
        end
        
        
        function groups_error_vector = assignErrorsToGroups(errors_bit_indices)
            groups
        end
        
        function group_index = findGroupOfBit(obj, bit_index)
            a = floor(bit_index/obj.A);
            group_index = mod(bit_index - a*obj.slope_k, obj.B) + 1;
        end
    end
end

