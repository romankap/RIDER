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
        num_of_groups_used_list;
        slopes_list;
        MAX_NUM_OF_REPARTITIONS;
        
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
            
            obj.A = dim_X;
            obj.B = dim_Y;
            obj.num_of_groups_used_list = zeros(obj.PAGE_ROWS*obj.PAGES_NUM, 1);
            obj.slopes_list= zeros(obj.PAGE_ROWS*obj.PAGES_NUM, 1);
            obj.MAX_NUM_OF_REPARTITIONS = obj.B;
            
            obj.Memory = MemoryArray(lifetime_mean, lifetime_sigma, page_bytes, block_bytes, pages_num);
        end
        
        
        function is_page_dead = writeToRow(obj, row_to_write, writes_performed, write_width)
            obj.Memory.writeToRow(row_to_write, writes_performed, write_width);
            dead_bit_indices = find(obj.Memory.dead_bit_table(spare_block_num, :));
            
            %1. Check if number of errors equals what is stored in partition vector
            num_of_dead_bits = length(find(dead_bit_indices)); 
            if obj.groups_used_table(row_to_write) >= num_of_dead_bits
                is_page_dead = false;
                return;
            end
            
            %2. Check if there is more than 1 error per group
            slope_of_row = obj.slopes_list(row_to_write);
            is_curr_partition_works = obj.isPartitionWorks(dead_bit_indices, slope_of_row);
            if ~is_curr_partition_works
                obj.groups_used_table(row_to_write) = num_of_dead_bits;
                is_page_dead = false;
                return
            end
            
            %3. More than 1 error in current partition -> repartition
            is_repartition_worked = repartition(dead_bit_indices, row_to_write);
            if ~is_repartition_worked
                is_page_dead = true;
            else
                is_page_dead = false;
            end
        end
        
        
        function is_success = repartition(obj, errors_bit_indices, destination_row)
            curr_slope = obj.slopes_list(destination_row);
            repartitions_counter = 0;
            while repartitions_counter < obj.MAX_NUM_OF_REPARTITIONS
                is_partition_works = obj.isPartitionWorks(errors_bit_indices, curr_slope);
                if is_partition_works
                    obj.slope_k = curr_slope;
                    is_success = true;
                    return;
                end
                
                repartitions_counter = repartitions_counter + 1;
                curr_slope = curr_slope + 1;
            end
            is_success = false;
        end
        
        
        function is_partition_works = isPartitionWorks(obj, errors_bit_indices, slope)
            errors_num_vector = zeros(1, obj.B);
            for bit_index = errors_bit_indices
                group_index = obj.findGroupOfBit(bit_index, slope);
                errors_num_vector(group_index) = errors_num_vector(group_index) + 1;
            end
            is_partition_works = ISEMPTY(find(groups_error_vector > 1));
        end
        
        
        function group_index = findGroupOfBit(obj, bit_index, slope)
            a = floor(bit_index/obj.A);
            group_index = mod(bit_index - a*slope, obj.B) + 1;
        end
    end
end

