classdef PSO
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        PosMin, PosMax
        VelMin, VelMax
        
        IteracionesMax = 3000;
        
        Posicion_Actual                     % Posiciones random de todas las part�culas. Distribuci�n uniforme entre PosMin y PosMax.
        Posicion_LocalBest                  % Posiciones que generaron los mejores costos en las part�culas     
        Posicion_GlobalBest                 % Posici�n que genera el costo m�s peque�o de entre todas las part�culas               
        
        Velocidad                           % Velocidad de todas las part�culas. Inicialmente 0.                    
        
        Costo_Local                         % Evaluaci�n del costo en la posici�n actual de la part�cula.           
        Costo_LocalBest                     % El mejor costo conseguido por la part�cula en toda su historia.
        Costo_GlobalBest                    % El costo m�s peque�o del vector "CostoLocal" o de entre todas las part�culas
        
        Costo_History                       % Historial de todos los "Costo_Global" o global best de cada iteraci�n
    end
    
    methods
        function obj = PSO(PosMin, PosMax, NoParticulas, VarDims, CostFunction)
            
            % INICIALIZACI�N DE VELOCIDADES M�XIMAS
            
            obj.VelMax = 0.2*(obj.PosMax - obj.PosMin);
            obj.VelMin = -obj.VelMax;
            
            
            
            % INICIALIZACI�N DE VELOCIDADES, COSTOS Y POSICIONES
            
            obj.Posicion_Actual = unifrnd(PosMin, PosMax, [NoParticulas VarDims]);      % Dims: NoParticulas X VarDims
            obj.Posicion_LocalBest = obj.Posicion_Actual;                               % Dims: NoParticulas X VarDims
            obj.Velocidad = zeros([NoParticulas VarDims]);                              % Dims: NoParticulas X VarDims
            
            obj.Costo_Local = CostFunction(obj.Posicion_Actual);                        % Dims: NoPart�culas X 1 (Vector Columna)
            obj.Costo_LocalBest = obj.Costo_Local;                                      % Dims: NoPart�culas X 1 (Vector Columna)
            obj.Costo_GlobalBest, Fila = min(obj.Costo_LocalBest);                      % Dims: Escalar
            obj.Posicion_GlobalBest = obj.Posicion_Actual(Fila, :);                     % Dims: 1 X VarDims

            obj.Costo_History = zeros([IteracionesMax 1]);                              % 
            obj.Costo_History(1) = obj.Costo_GlobalBest;                                % La primera posici�n del vector es el primer "Global Best"
        end
        
        function RunSim(obj, ModoVisualizacion)                                         % Modo de visualizaci�n: 2D, 3D o None. Si se ingresa algo no v�lido se toma una visualizaci�n 3D como default
            
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

                % Actualizaci�n de Velocidad
                obj.Velocidad = W * obj.Velocidad ...                                                   % T�rmino inercial
                    + C1 * R1 .* (obj.Posicion_LocalBest - obj.Posicion_Actual) ...                     % Componente cognitivo
                    + C2 * R2 .* (obj.Posicion_GlobalBest - obj.Posicion_Actual);                       % Componente social

                obj.Velocidad = max(obj.Velocidad, obj.VelMin);                                         % Se truncan los valores de velocidad en el valor m�nimo y m�ximo
                obj.Velocidad = min(obj.Velocidad, obj.VelMax);

                % Actualizaci�n de Posici�n
                obj.Posicion_Actual = obj.Posicion_Actual + obj.Velocidad;
                obj.Posicion_Actual = max(obj.Posicion_Actual, obj.PosMin);                             % Se truncan los valores de posici�n en el valor m�nimo y m�ximo
                obj.Posicion_Actual = min(obj.Posicion_Actual, obj.PosMax);

                % Actualizaci�n de Local y Global Best
                obj.Costo_Local = CostFunction(obj.Posicion_Actual);                                    % Actualizaci�n de los valores del costo
                obj.Costo_LocalBest = min(obj.Costo_LocalBest, obj.Costo_Local);                        % Se sustituyen los costos que son menores al "Local Best" previo
                Costo_Change = (obj.Costo_Local < obj.Costo_LocalBest);                                 % Vector binario que indica con un 0 cuales son las filas de "Costo_Local" que son menores que las filas de "Costo_LocalBest"
                obj.Posicion_LocalBest = obj.Posicion_LocalBest .* Costo_Change + obj.Posicion_Actual;  % Se sustituyen las posiciones correspondientes a los costos a cambiar en la linea previa

                [obj.Costo_Global, Fila] = min(obj.Costo_LocalBest);                                    % Valor m�nimo de entre los valores de "Costo_Local"

                if obj.Costo_Global < obj.Costo_GlobalBest                                              % Si el nuevo costo global es menor al "Global Best" entonces
                    obj.Costo_GlobalBest = obj.Costo_Global;                                            % Se actualiza el valor del "Global Best"
                    obj.Posicion_GlobalBest = obj.Posicion_Actual(Fila, :);                             % Y la posici�n correspondiente al "Global Best"
                end

                % Actualizaci�n del historial de "Best Costs"
                obj.Costo_History(i) = obj.Costo_GlobalBest;                                            

                % Actualizaci�n del coeficiente inercial
                W = W * WDamp;

                % Actualizar el n�mero de iteraciones
                Iteraciones = Iteraciones + 1;

                if strcmp(ModoVisualizacion, "None") == 0

                    % Graficaci�n de part�culas
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
                    title({"Part�culas"; strcat("Radio Convergencia: ", num2str(RadioConvergencia), " (", num2str(Porcentaje_AreaTotal), "%)")});
                    hold on;

                    % Graficaci�n de funci�n de costo
                    subplot(1, 2, 1); cla;
                    plot(obj.Costo_History(1:i), 'LineWidth', 2);
                    title({"Minimizaci�n de Funci�n de Costo" ; strcat("Iteraciones Actuales: ", num2str(i))})
                    xlabel('Iteraci�n');
                    ylabel('Costo �ptimo');

                end

                % Criterio de finalizaci�n
                Distancia_ParticulaMasLejana = max(sqrt(sum((obj.Posicion_Actual - Coords_Min).^2, 2)));

                if Distancia_ParticulaMasLejana < RadioConvergencia
                    Iteraciones = i;

                    if strcmp(ModoVisualizacion, "None") == 0
                        title({"Minimizaci�n de Funci�n de Costo" ; strcat("Iteraciones para Converger: ", num2str(Iteraciones))});
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

