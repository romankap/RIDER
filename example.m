arr = ones(1,4);
arr(2) = 0;

fprintf("non-zeros = %d\n", sum(arr(:))); 
for i = find(arr>0)
   fprintf("i = %d\n", i); 
end
