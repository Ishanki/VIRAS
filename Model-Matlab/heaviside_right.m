function h = heaviside_right(x, eps)
    % Approximation of the Heaviside step function defined as:
    %       |0,      t < 0
    %   h = |x/eps,  0 <= t <= eps
    %       |1,      t > eps
    % The approximation is deliberately made non-symmetrical w.r.t. 0 to enable
    % starting from zero time
    h = heavisidecustom(x).*heavisidecustom(eps - x).*x/eps + heavisidecustom(x - eps);
end