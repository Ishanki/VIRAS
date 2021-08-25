function ind = indicator_cont(x, a, b, eps)
    % Continuous indicator function of interval [a, b]. As it has a trapezoidal
    % shape beginning to rise linearly at x = a, the decreasing part part
    % starts at x = b dropping to zero at x = b + eps to ensure that the
    % integral of the function = (b-a).
    ind = heaviside_right(x-a, eps).*heaviside_right(b+eps-x, eps);
end