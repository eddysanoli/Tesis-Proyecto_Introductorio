function Costo = CostFunction(x, FunctionSelection)
% Costo de una función con forma de paraboloide.

switch FunctionSelection
    % Paraboloide
    case "Paraboloide"                      
        Costo = sum(x.^2, 2);                                   
    
    % Ackley Function
    case "Ackley"                      
        a = 20; b = 0.2; c = 2*pi; d = size(x,2);              
        Sum1 = -b * sqrt((1/d) * sum(x.^2, 2));
        Sum2 = (1/d) * sum(cos(c*x), 2);
        Costo = -a*exp(Sum1) - exp(Sum2) + a + exp(1);
    
    % Rastrigin Function
    case "Rastrigin"
        d = size(x,2);                                          
        Costo = 10*d + sum(x.^2 - 10*cos(2*pi*x), 2);
    
    % Levy Function N.13
    case "Levy"
        Costo = sin(3*pi*x(:,1)).^2 ...                        
                + (x(:,1)-1).^2 .* (1 + sin(3*pi*x(:,2)).^2) ...
                + (x(:,2) - 1).^2 .* (1 + sin(2*pi*x(:,2)).^2);
    
    % Drop Wave Function        
    case "Dropwave"
        Waves = 2;                                             
        Costo = -(1 + cos(Waves * sqrt(sum(x.^2, 2)))) ./ (0.5 * sqrt(sum(x.^2, 2)) + 2);
end

    
end

