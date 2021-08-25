function x = heavisidecustom(t)
    x = zeros(size(t));
    x(t>0) = 1; 
    x(t==0) = 0.5;  
end