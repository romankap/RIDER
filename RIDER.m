classdef RIDER < handle

    properties
        ECP_corrected_errors_array;

        
        paired_blocks_list;

        first_order_spare_block;        
        second_order_spare_block;
        %SECOND_ORDER_SPARE_BLOCK_QUEUE_LEN;
        %second_order_spare_block_queue;
    end
    
    methods
        function obj = RIDER()
            obj.first_order_spare_block = 0;
            obj.second_order_spare_block = 0;
            %obj.SECOND_ORDER_SPARE_BLOCK_QUEUE_LEN = second_order_spares_len;
            %obj.second_order_spare_block_queue = 0;
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
        


    end
end

