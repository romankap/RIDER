classdef AegisMetadata < handle
    
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
        
        faults_in_killer_rows;
    end
    
    methods
        function obj = AegisMetadata(lifetime_mean, lifetime_sigma, page_bytes, block_bytes, pages_num, dim_X, dim_Y)
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
            
            obj.faults_in_killer_rows = zeros(obj.PAGES_NUM, 1);
        end
        
        
        function obj = writeToRandomRows(obj, writes_performed, write_width)
            num_of_active_rows = obj.Memory.getNumOfActiveRows();
            if num_of_active_rows > 0
                random_active_block = randi([1 num_of_active_rows]);
                active_rows_list = obj.Memory.getActiveRowsList();
                block_to_write=active_rows_list(random_active_block);

                is_write_successful = obj.writeToRow(block_to_write, writes_performed, write_width);
                if ~is_write_successful
                    obj.killAllPageBlocks(block_to_write);
                end
            end
        end
        
        
        function is_write_successful = writeToRow(obj, row_to_write, writes_performed, write_width)
            obj.Memory.writeToRow(row_to_write, writes_performed, write_width);
            dead_bit_indices = find(obj.Memory.dead_bit_table(row_to_write, :));
            
            %1. Check if number of errors equals what is stored in partition vector
            num_of_dead_bits = length(find(dead_bit_indices)); 
            if obj.num_of_groups_used_list(row_to_write) >= num_of_dead_bits
                is_write_successful = true;
                return;
            end
            
            %2. Check if there is more than 1 error per group
            slope_of_row = obj.slopes_list(row_to_write);
            is_curr_partition_works = obj.isPartitionWorks(dead_bit_indices, slope_of_row);
            if is_curr_partition_works
                obj.num_of_groups_used_list(row_to_write) = num_of_dead_bits;
                is_write_successful = true;
                return
            end
            
            %3. More than 1 error in current partition -> repartition
            is_repartition_worked = obj.repartition(dead_bit_indices, row_to_write);
            if ~is_repartition_worked
                is_write_successful = false;
            else
                is_write_successful = true;
            end
        end
        
        
        function is_success = repartition(obj, errors_bit_indices, destination_row)
            curr_slope = obj.slopes_list(destination_row);
            repartitions_counter = 0;
            while repartitions_counter < obj.MAX_NUM_OF_REPARTITIONS
                is_partition_works = obj.isPartitionWorks(errors_bit_indices, curr_slope);
                if is_partition_works
                    obj.slopes_list(destination_row) = curr_slope;
                    is_success = true;
                    return;
                end
                
                repartitions_counter = repartitions_counter + 1;
                curr_slope = mod(curr_slope + 1, obj.B);
            end
            is_success = false;
        end
        
        
        function is_partition_works = isPartitionWorks(obj, errors_bit_indices, slope)
            errors_num_vector = zeros(1, obj.B);
            for bit_index = errors_bit_indices
                group_index = obj.findGroupOfBit(bit_index, slope);
                errors_num_vector(group_index) = errors_num_vector(group_index) + 1;
            end
            is_partition_works = isempty(find(errors_num_vector > 1));
        end
        
        
        function average_faults = getAverageFaultsInAllRows(obj)
            average_faults = mean(nonzeros(obj.num_of_groups_used_list()));
        end
        
        
        function obj = killAllPageBlocks(obj, bad_row_num)
            page_num = obj.Memory.get_page_num_of_block(bad_row_num);
            obj.Memory.active_rows_array((page_num-1)*obj.PAGE_ROWS+1 : page_num*obj.PAGE_ROWS) = 0;    
            obj.faults_in_killer_rows(page_num) = length(find(obj.Memory.dead_bit_table(bad_row_num, :)));
        end
        
        
        function group_index = findGroupOfBit(obj, bit_index, slope)
            a = mod(bit_index, obj.A);
            b = floor(bit_index/obj.A);
            group_index = mod(b - a*slope, obj.B) + 1;
        end
    end
end

