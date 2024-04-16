

% Simulación de interacción entre partículas electricamente cargadas
clc; clear; close all;

% Declaración de constantes
ke = 8.987551787e9; % Constante de Coulomb (Nm^2/C^2)
ladoEspacio = 20; % Lado del espacio cuadrado de confinamiento
r_min = 0.8; % Distancia mínima de acercamiento para evitar singularidades

% Propiedades de las partículas
masas = [35.0, 32.0]; % Masas
cargas = [-25.0e-6, 25.0e-6]; % Cargas

% Condiciones iniciales
posiciones = [1, 4; 19, 16]; % Posiciones iniciales (x, y) de cada partícula 
% IZQUIERDA AZUL % DERECHA ROJA

velocidades = [0.05, 0.05; -0.05, -0.05]; % Velocidades iniciales (vx, vy) de cada partícula
% [0.125, 0.175; -0.125, -0.175]

% Simulación
tiempoTotal = 100000; % Tiempo total de simulación (s)
dt = 0.52; % Paso de tiempo (s)
pasos = ceil(tiempoTotal / dt); % Número total de pasos de simulación

% Preparación de la animación
figure;
xlim([0, ladoEspacio]);
ylim([0, ladoEspacio]);
hold on;
grid on;
particula1 = plot(posiciones(1,1), posiciones(1,2), 'co', 'MarkerSize', 12, 'MarkerFaceColor', 'b');
particula2 = plot(posiciones(2,1), posiciones(2,2), 'mo', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
trayectoria1 = plot(posiciones(1,1), posiciones(1,2), 'b'); % Para la trayectoria de la partícula 1
trayectoria2 = plot(posiciones(2,1), posiciones(2,2), 'r'); % Para la trayectoria de la partícula 2
title('Simulación de interacción entre partículas cargadas con campo eléctrico');

% Preparación del campo eléctrico
[x, y] = meshgrid(0:0.5:ladoEspacio, 0:0.5:ladoEspacio);
campoE = quiver(x, y, zeros(size(x)), zeros(size(y)), 'k');

% Bucle de simulación
for paso = 1:pasos
    % Guardar posiciones antiguas para la trayectoria
    posAntiguas = posiciones;
    
    % Diferencias de posición y dirección
    dx = posiciones(2, 1) - posiciones(1, 1);
    dy = posiciones(2, 2) - posiciones(1, 2);
    distancia = max(sqrt(dx^2 + dy^2), r_min);
    direccion = [dx, dy] / distancia;
    signoFuerza = sign(cargas(1) * cargas(2));
    fuerzaMagnitud = ke * abs(cargas(1) * cargas(2)) / distancia^2;
    fuerza = direccion * fuerzaMagnitud * -signoFuerza;
    aceleraciones = [fuerza / masas(1); -fuerza / masas(2)];
    velocidades = velocidades + aceleraciones * dt;
    posiciones = posiciones + velocidades * dt;

    % Manejo del rebote contra las paredes
    for i = 1:2
        if posiciones(i,1) <= 0 || posiciones(i,1) >= ladoEspacio
            velocidades(i,1) = -velocidades(i,1);
        end
        if posiciones(i,2) <= 0 || posiciones(i,2) >= ladoEspacio
            velocidades(i,2) = -velocidades(i,2);
        end
    end

    % Cálculo del campo eléctrico en la malla de puntos
    Ex = zeros(size(x));
    Ey = zeros(size(y));
    for i = 1:2
        dx = x - posiciones(i, 1);
        dy = y - posiciones(i, 2);
        r2 = dx.^2 + dy.^2;
        r = sqrt(r2);
        r3 = r .* r2;
        r3(r < r_min) = r_min^3; % Prevenir división por cero con distancia mínima
        Ex = Ex + cargas(i) * dx ./ r3;
        Ey = Ey + cargas(i) * dy ./ r3;
    end
    Ex = Ex * ke;
    Ey = Ey * ke;

    % Actualizar la animación de partículas y campo eléctrico
    set(particula1, 'XData', posiciones(1,1), 'YData', posiciones(1,2));
    set(particula2, 'XData', posiciones(2,1), 'YData', posiciones(2,2));
    set(campoE, 'UData', Ex, 'VData', Ey);
    
    % Actualizar la trayectoria
    % set(trayectoria1, 'XData', [get(trayectoria1, 'XData'), posiciones(1,1)], 'YData', [get(trayectoria1, 'YData'), posiciones(1,2)]);
    % set(trayectoria2, 'XData', [get(trayectoria2, 'XData'), posiciones(2,1)], 'YData', [get(trayectoria2, 'YData'), posiciones(2,2)]);

    drawnow;
end

% Fin del script
