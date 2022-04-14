function d = delta_triang(x, eps)
    % Triangular approximation of the Dirac delta function centred at 0
    %   eps - half-width of the base of the triangle
    d = (abs(x) <= eps).*(1 - abs(x)/eps)/eps;
end