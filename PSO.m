classdef PSO
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PosMin, PosMax
        VelMin, VelMax
        
        IteracionesMax = 3000;
        
        Posicion_Actual                     % Posiciones random de todas las partículas. Distribución uniforme entre PosMin y PosMax.
        Posicion_LocalBest                  % Posiciones que generaron los mejores costos en las partículas     
        Posicion_GlobalBest                 % Posición que genera el costo más pequeño de entre todas las partículas               
        
        Velocidad                           % Velocidad de todas las partículas. Inicialmente 0.                    
        
        Costo_Local                         % Evaluación del costo en la posición actual de la partícula.           
        Costo_LocalBest                     % El mejor costo conseguido por la partícula en toda su historia.
        Costo_GlobalBest                    % El costo más pequeño del vector "CostoLocal" o de entre todas las partículas
        
        Costo_History                       % Historial de todos los "Costo_Global" o global best de cada iteración
    end
    
    methods
        function obj = PSO(PosMin, PosMax, NoParticulas, VarDims, CostFunction)
            
            % INICIALIZACIÓN DE VELOCIDADES MÁXIMAS
            
            obj.VelMax = 0.2*(obj.PosMax - obj.PosMin);
            obj.VelMin = -obj.VelMax;
            
            
            
            % INICIALIZACIÓN DE VELOCIDADES, COSTOS Y POSICIONES
            
            obj.Posicion_Actual = unifrnd(PosMin, PosMax, [NoParticulas VarDims]);      % Dims: NoParticulas X VarDims
            obj.Posicion_LocalBest = obj.Posicion_Actual;                               % Dims: NoParticulas X VarDims
            obj.Velocidad = zeros([NoParticulas VarDims]);                              % Dims: NoParticulas X VarDims
            
            obj.Costo_Local = CostFunction(obj.Posicion_Actual);                        % Dims: NoPartículas X 1 (Vector Columna)
            obj.Costo_LocalBest = obj.Costo_Local;                                      % Dims: NoPartículas X 1 (Vector Columna)
            obj.Costo_GlobalBest, Fila = min(obj.Costo_LocalBest);                      % Dims: Escalar
            obj.Posicion_GlobalBest = obj.Posicion_Actual(Fila, :);                     % Dims: 1 X VarDims

            obj.Costo_History = zeros([IteracionesMax 1]);                              % 
            obj.Costo_History(1) = obj.Costo_GlobalBest;                                % La primera posición del vector es el primer "Global Best"
        end
        
        function RunSim(obj, ModoVisualizacion)                                         % Modo de visualización: 2D, 3D o None. Si se ingresa algo no válido se toma una visualización 3D como default
            
            Iteraciones = 0;

            if strcmp(ModoVisualizacion, "None") == 0
                figure(1); clf;
                figure('visible','on');
                axis equal; grid on; 

                FigureWidth = 900;
                FigureHeight = 400;
                ScreenSize = get(0,'ScreenSize');
                set(gcf, 'Position',  [ScreenSize(3)/2 - FigureWidth/2, ScreenSize(4)/2 - FigureHeight/2, FigureWidth, FigureHeight])
            end

            for i = 2:obj.IteracionesMax

                R1 = rand([NoParticulas VarDims]);
                R2 = rand([NoParticulas VarDims]);

                % Actualización de Velocidad
                obj.Velocidad = W * obj.Velocidad ...                                                   % Término inercial
                    + C1 * R1 .* (obj.Posicion_LocalBest - obj.Posicion_Actual) ...                     % Componente cognitivo
                    + C2 * R2 .* (obj.Posicion_GlobalBest - obj.Posicion_Actual);                       % Componente social

                obj.Velocidad = max(obj.Velocidad, obj.VelMin);                                         % Se truncan los valores de velocidad en el valor mínimo y máximo
                obj.Velocidad = min(obj.Velocidad, obj.VelMax);

                % Actualización de Posición
                obj.Posicion_Actual = obj.Posicion_Actual + obj.Velocidad;
                obj.Posicion_Actual = max(obj.Posicion_Actual, obj.PosMin);                             % Se truncan los valores de posición en el valor mínimo y máximo
                obj.Posicion_Actual = min(obj.Posicion_Actual, obj.PosMax);

                % Actualización de Local y Global Best
                obj.Costo_Local = CostFunction(obj.Posicion_Actual);                                    % Actualización de los valores del costo
                obj.Costo_LocalBest = min(obj.Costo_LocalBest, obj.Costo_Local);                        % Se sustituyen los costos que son menores al "Local Best" previo
                Costo_Change = (obj.Costo_Local < obj.Costo_LocalBest);                                 % Vector binario que indica con un 0 cuales son las filas de "Costo_Local" que son menores que las filas de "Costo_LocalBest"
                obj.Posicion_LocalBest = obj.Posicion_LocalBest .* Costo_Change + obj.Posicion_Actual;  % Se sustituyen las posiciones correspondientes a los costos a cambiar en la linea previa

                [obj.Costo_Global, Fila] = min(obj.Costo_LocalBest);                                    % Valor mínimo de entre los valores de "Costo_Local"

                if obj.Costo_Global < obj.Costo_GlobalBest                                              % Si el nuevo costo global es menor al "Global Best" entonces
                    obj.Costo_GlobalBest = obj.Costo_Global;                                            % Se actualiza el valor del "Global Best"
                    obj.Posicion_GlobalBest = obj.Posicion_Actual(Fila, :);                             % Y la posición correspondiente al "Global Best"
                end

                % Actualización del historial de "Best Costs"
                obj.Costo_History(i) = obj.Costo_GlobalBest;                                            

                % Actualización del coeficiente inercial
                W = W * WDamp;

                % Actualizar el número de iteraciones
                Iteraciones = Iteraciones + 1;

                if strcmp(ModoVisualizacion, "None") == 0

                    % Graficación de partículas
                    subplot(1, 2, 2); cla;

                    if strcmp(ModoVisualizacion, "2D")
                        axis([obj.PosMin obj.PosMax obj.PosMin obj.PosMax]);
                        contour(MeshX, MeshY, Altura);
                        alpha 0.5;
                        scatter(obj.Posicion_Actual(:,1), obj.Posicion_Actual(:,2), 10, Colores, 'filled');
                        scatter(X1_min, X2_min, 'red', 'x');
                        viscircles([X1_min X2_min], RadioConvergencia);
                    else
                        axis([obj.PosMin obj.PosMax obj.PosMin obj.PosMax 0 MaxAltura]);
                        surf(MeshX, MeshY, Altura);
                        shading interp
                        alpha 0.5;
                        scatter3(obj.Posicion_Actual(:,1), obj.Posicion_Actual(:,2), obj.Costo_Local, [], Colores, 'filled');
                    end
                    title({"Partículas"; strcat("Radio Convergencia: ", num2str(RadioConvergencia), " (", num2str(Porcentaje_AreaTotal), "%)")});
                    hold on;

                    % Graficación de función de costo
                    subplot(1, 2, 1); cla;
                    plot(obj.Costo_History(1:i), 'LineWidth', 2);
                    title({"Minimización de Función de Costo" ; strcat("Iteraciones Actuales: ", num2str(i))})
                    xlabel('Iteración');
                    ylabel('Costo Óptimo');

                end

                % Criterio de finalización
                Distancia_ParticulaMasLejana = max(sqrt(sum((obj.Posicion_Actual - Coords_Min).^2, 2)));

                if Distancia_ParticulaMasLejana < RadioConvergencia
                    Iteraciones = i;

                    if strcmp(ModoVisualizacion, "None") == 0
                        title({"Minimización de Función de Costo" ; strcat("Iteraciones para Converger: ", num2str(Iteraciones))});
                    else
                        disp("Proceso Finalizado")
                    end

                    break
                end

                drawnow

            end
        end
    end
end

