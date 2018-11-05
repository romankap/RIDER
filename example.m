clc; clear;
vecA = [0 0 1 1 0];
vecB = [1 0 1 0 1];
res = and(vecA, vecB);
disp(res);


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