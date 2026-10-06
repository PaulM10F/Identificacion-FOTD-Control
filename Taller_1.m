% Taller 1 - Identificacion_FOTD
data = readtable('datos_motor.csv');
t = data{:,2};
u = data{:,3};
y = data{:,4};
    
% Grafica inicial
figure;
plot(t, u, 'b', t, y, 'r', 'LineWidth', 1.5);
xlabel('Tiempo [s]');
ylabel('Amplitud');
title('Respuesta del sistema');
legend('u(t)', 'y(t)');
grid on;

% Linea base y 100%
hold on;
y_base = y(1);
y_final = mean(y(end-50:end));
yline(y_base, '--k', 'Linea base', 'DisplayName', 'Linea Base');
yline(y_final, '--k', 'Linea 100%', 'DisplayName', 'Linea 100%');

% Seleccion de dos puntos (t = tiempo, a = amplitud)
disp('Seleccionar dos puntos con mayor tramo empinado')
[tp, ap] = ginput(2);

% Puntos obtenidos
fprintf('Punto 1: t1 = %.4f, a1 = %.4f\n', tp(1), ap(1));
fprintf('Punto 2: t2 = %.4f, a2 = %.4f\n', tp(2), ap(2));

% Calculamos la pendiente
m = (ap(2) - ap(1))/(tp(2) - tp(1));
fprintf('La pendiente m es: %.4f\n', m);

% Encontramos los puntos de corte
punto_b = (y_base - ap(1))/m + tp(1); % Punto de corte base
punto_f = (y_final - ap(1))/m + tp(1); % Punto de corte final

% Graficamos la recta tangente
plot([punto_b, punto_f], [y_base, y_final], '--k', 'LineWidth', 1.5, 'DisplayName', 'Tangente');
hold off;

% Calculamos la ganancia K
u_base = u(1);
u_final = mean(u(end-50:end));
delta_y = y_final - y_base;
delta_u = u_final - u_base;
K = delta_y/delta_u;
fprintf('La ganancia K es: %.4f\n', K);

% Buscamos el instante exacto que ocurre el escalon u(t)
idx_escalon = find(u > u_base + 0.1, 1);
t_escalon = t(idx_escalon);

% Aplicamos el Metodo 1: Ziegler & Nichols
theta_zn = punto_b - t_escalon;
tau_zn = punto_f - punto_b;
fprintf('Dado el metodo de Ziegler & Nichols:\nK = %.3f, Theta = %.3f y Tau = %.3f\n', K, theta_zn, tau_zn);
G_zn = tf(K, [tau_zn 1], 'InputDelay', theta_zn); % Encotramos la funcion de transferencia
fprintf('La funcion de transferencia es:');
G_zn

% Aplicamos el Metodo 2: Miller
y_632 = y_base + 0.632 * delta_y; % Encontramos el punto donde cruza en 63.2%
idx_632 = find(y >= y_632, 1);
t_632 = t(idx_632) - t_escalon; % Tomamos el valor fijo

theta_m = theta_zn;
tau_m = t_632 - theta_m;
fprintf('Dado el metodo de Miller:\nK = %.3f, Theta = %.3f y Tau = %.3f\n', K, theta_m, tau_m);
G_m = tf(K, [tau_m 1], 'InputDelay', theta_m); % Encotramos la funcion de transferencia
fprintf('La funcion de transferencia es:');
G_m

% Aplicamos el Metodo 3: Analitico
y_283 = y_base + 0.283 * delta_y; % Encontramos el punto donde cruza en 28.3%
idx_283 = find(y >= y_283, 1);
t_283 = t(idx_283) - t_escalon; % Tomamos el valor fijo

tau_a = 1.5 * (t_632 - t_283);
theta_a = t_632 - tau_a;
fprintf('Dado el metodo Analitico:\nK = %.3f, Theta = %.3f y Tau = %.3f\n', K, theta_a, tau_a);
G_a = tf(K, [tau_a 1], 'InputDelay', theta_a); % Encotramos la funcion de transferencia
fprintf('La funcion de transferencia es:');
G_a

% Simulamos para el mismo valor de u y graficamos
y_zn = lsim(G_zn, u, t);
y_m = lsim(G_m, u, t);
y_a = lsim(G_a, u, t);

figure;
plot(t, y, 'b', 'LineWidth', 1.5, 'DisplayName', 'y(t)');
hold on;
plot(t, u, 'r', 'LineWidth', 1.5, 'DisplayName', 'u(t)');
plot([punto_b, punto_f], [y_base, y_final], '--k', 'LineWidth', 1.5, 'DisplayName', 'Tangente');
plot(t, y_zn, 'LineWidth', 1.1, 'DisplayName', 'Ziegler & Nichols');
plot(t, y_m, 'LineWidth', 1.1, 'DisplayName', 'Miller');
plot(t, y_a, 'LineWidth', 1.1, 'DisplayName', 'Analitico');
yline(y_base, '--k', 'Línea base', 'HandleVisibility', 'off');
yline(y_final, '--k', 'Línea 100%', 'HandleVisibility', 'off');
xlabel('Tiempo [s]');
ylabel('Amplitud');
title('Identificación gráfica de Sistemas FOTD');
legend('Location', 'best');
grid on;
hold off;

% Calculamos el error de cada metodo
ecm_zn = mean((y-y_zn).^2);
ecm_m = mean((y-y_m).^2);
ecm_a = mean((y-y_a).^2);

fprintf('El ECM del metodo de Ziegler & Nichols es: %.6f\n', ecm_zn);
fprintf('El ECM del metodo de Miller es: %.6f\n', ecm_m);
fprintf('El ECM del metodo Analitico es: %.6f\n', ecm_a);