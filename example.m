test_array = [1 2 3];
test_array = [test_array 1];
test_array = Enqueue(test_array, 7);
disp(test_array);

test_array = Dequeue(test_array);
disp(test_array);



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