clc; clear;
arr = zeros(4, 6);

arr(2,1) = 7;
arr(2,4) = 4;
find_res = find(arr(2,:));

found_vals = arr(2,find_res);

len = length(find_res);

find_res = find(arr(2,:) ~= 0);
len = length(find_res);

find_res = find(arr(2,:) > 0);
len = length(find_res);

arr(1) = [];
emp = isempty(arr);
len = length(find(arr > 0));
disp(len);

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