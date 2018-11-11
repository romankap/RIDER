clc; clear;
test = zeros(1, 7);
test(2) = 4;
test(3) = 2;
test(4) = 0;
disp(find(~test));
disp(test);


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