load Iteraciones.mat
IteracionesMax = 3000;

Iteraciones_HistoryNorm = 1 - (Iteraciones_History/IteracionesMax);

figure(); clf;
axis equal; grid on;
axis([min(MatPhi1) max(MatPhi1) min(MatPhi2) max(MatPhi2) min(MatKappa) max(MatKappa)])
hold on;

for i = 1:size(Iteraciones_HistoryNorm,1)
    
    if Iteraciones_HistoryNorm(i) > 0.4
        scatter3(MatPhi1(i), MatPhi2(i), MatKappa(i), 'blue', 'filled', 'MarkerFaceAlpha',Iteraciones_HistoryNorm(i));
    end
    
    if mod(i, Porcentaje) == 0
        disp(strcat("Puntos graficados: ", num2str(i)))
    end
    
    drawnow
end

xlabel("\phi_1");
ylabel("\phi_2");
zlabel("\kappa");
Porcentaje = size(Iteraciones_History,1)/10;
%title("Iteraciones Requeridas para Converger según parámetros Kappa, Phi1 y Phi2");

