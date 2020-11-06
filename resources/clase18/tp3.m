clearvars;
close all;

% Se graficarán estas figuras  1 2 3 4 5 
graficas_ploteadas =         [ 1 1 1 1 1 ];

%====================%
% Generación de g[n] %
%====================%
fB = 32e9;    % Velocidad de simbolos (baud rate)
% Es la frecuencia de los simbolos, 32 GBaudios

T = 1 / fB;   % Tiempo entre símbolos
M = 8;        % Factor de sobremuestreo
fs = fB * M;  % Sample rate

alpha = 0.100001;  % Factor de roll-off
L = 20;       % ( 2 * L * M + 1 ) es el largo del filtro sobremuestreado

lim_x_derecha_calculo = L * T / 4; 
lim_x_izquierda_calculo = -L * T / 4;

t = ( -L : 1 / M : L ) * T; 

% Impulso muestreado
gn = sinc( t / T ) .* cos( pi * alpha * t / T ) ./ ( 1 - 4 * alpha^2 * t.^2 / T^2 );
% Multiplicación por elementos .* https://la.mathworks.com/help/matlab/ref/times.html


if graficas_ploteadas( 1 ) == 1 
    figure( 1 );
    stem( t, gn, 'Color', [ 0.074 0.313 0.705 ], 'MarkerFaceColor', [ 0.156 0.450 0.921 ] ); 
    
    % Límites de la gráfica
    lim_y_abajo_grafica = -0.3;
    lim_y_arriba_grafica = 1.6;
    lim_x_izquierda_grafica = lim_x_izquierda_calculo;
    lim_x_derecha_grafica = lim_x_derecha_calculo;
    ylim( [ lim_y_abajo_grafica, lim_y_arriba_grafica ] );
    xlim( [ lim_x_izquierda_grafica, lim_x_derecha_grafica ] );

    % Línea vertical
    line( [ 0 0 ], [ 0 ( 1 / 1.15 * lim_y_arriba_grafica ) ], 'Color', [ 0 0 0 ] );
    
    % Flechas
    line( [ 0 ( ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 100 ) ], ...
                  [ ( 1 / 1.15 * lim_y_arriba_grafica ) ( 1 / 1.2 * lim_y_arriba_grafica ) ], ...
                  'Color', [ 0 0 0 ] );               
    line( [ 0 ( - ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 100 ) ], ...
                  [ ( 1 / 1.15 * lim_y_arriba_grafica ) ( 1 / 1.2 * lim_y_arriba_grafica ) ], ...
                  'Color', [ 0 0 0 ] );  
              
    text( 2*T, 0.8, [ '$M=$' num2str( M ) ], 'FontSize', 14, 'Interpreter', 'latex', ...
          'Color', [ 0.152 0.325 0.2 ] );
    text( 2*T, 0.6, [ '$\alpha=$' num2str( alpha ) ], 'FontSize', 14, 'Interpreter', 'latex', ...
          'Color', [ 0.152 0.325 0.2 ] );

    set( gcf, 'Position', [ 250 200 800 300 ] );               
    set( gca, 'FontSize', 12 );
    set( gca, 'TickLabelInterpreter', 'latex' );

    % Textos para el eje y
    set( gca, 'YTick', ( [ 0 1 ] ) );
    set( gca, 'yticklabel', ( { '$0$', '$1$' } ) );

    % Textos para el eje x
    set( gca, 'XTick', [ -5*T -4*T -3*T -2*T -T 0 T 2*T 3*T 4*T 5*T ] );
    set( gca, 'xticklabel', ( { '$5T$', '$-4T$', '$-3T$', '$-2T$', '$-T$', '$0$', '$T$', ...
                                '$2T$', '$3T$', '$4T$', '$5T$' } ) );

    xlabel( '$n$', 'FontSize', 22, 'Interpreter', 'latex', 'Position', [ lim_x_derecha_grafica + ...
            ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 25,  0.1 * lim_y_arriba_grafica ] );
    ylabel( '$g[n]$', 'Rotation', 0, 'FontSize', 22, 'Interpreter', 'latex', 'Position', [ ...
            ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 17, 0.78 * lim_y_arriba_grafica ] );

end

%=======================================%
% Calculo de la respuesta en frecuencia %
%=======================================%

% true para graficar más de 2 pi. 
% false para graficar entre 0 y pi/2
graficar_varios_periodos = true;

if graficar_varios_periodos
    lim_x_izquierda_calculo = -5 * pi / 2;  % x menor para calculo
    lim_x_derecha_calculo = 5 * pi / 2;  % x mayor para calculo
else
    lim_x_izquierda_calculo = - pi / 100;  % x menor para calculo
    lim_x_derecha_calculo = 7 * pi / 10;  % x mayor para calculo
end

cantidad_n = 1000;  % Cuantos valores en x para graficar

% Genera cantidad de valores equidistantes
Omega = linspace( lim_x_izquierda_calculo, lim_x_derecha_calculo, cantidad_n );  
G_Mag = zeros( 1, length( Omega ) );

n = 0 : cantidad_n;  
index = 1;

for index_Omega = Omega
    xn = exp( 1i * index_Omega * n );  
    yn = conv( xn, gn );
    G_Mag( index ) = abs( yn( cantidad_n / 2 ) );
    index = index + 1;
end

if graficas_ploteadas( 2 ) == 1 
    figure( 2 );

    plot( Omega, G_Mag, 'LineWidth', 1.8, 'Color', [ 0.043 0.474 0.160 ] ); 

    lim_y_abajo_grafica = 0;
    lim_y_arriba_grafica = M * 1.5;
    ylim( [ lim_y_abajo_grafica, lim_y_arriba_grafica ] );
    lim_x_izquierda_grafica = lim_x_izquierda_calculo;
    lim_x_derecha_grafica = lim_x_derecha_calculo;
    xlim( [ lim_x_izquierda_grafica, lim_x_derecha_grafica ] );

    line( [ 0 0 ], [ 0 ( 1 / 1.15 * lim_y_arriba_grafica ) ], 'Color', [ 0 0 0 ] );
    line( [ 0 ( ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 100 ) ], ...
                  [ ( 1 / 1.15 * lim_y_arriba_grafica ) ( 1 / 1.2 * lim_y_arriba_grafica ) ], ...
                  'Color', [ 0 0 0 ] ); 
    line( [ 0 ( - ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 100 ) ], ...
                  [ ( 1 / 1.15 * lim_y_arriba_grafica ) ( 1 / 1.2 * lim_y_arriba_grafica ) ], ...
                  'Color', [ 0 0 0 ] );  

    xlabel( '$\Omega$', 'FontSize', 22, 'Interpreter', 'latex', 'Position', [ lim_x_derecha_grafica + ...
            ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 25,  0.1 * lim_y_arriba_grafica ] );
    ylabel( '$G(e^{j \Omega})$', 'Rotation', 0, 'FontSize', 22, 'Interpreter', 'latex', 'Position', [ ...
            ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 13, 0.78 * lim_y_arriba_grafica ] );
                   
    set( gca, 'YTick', ( [ 0 M ] ) );
    set( gca, 'yticklabel', ( { '$0$', '$M$' } ) );
    
    set( gca, 'XTick', [ -2*pi -pi -pi/2 0 pi/2 pi 2*pi ] );
    set( gca, 'xticklabel', ( { '$-2 \pi$', '$-\pi$', '$-\frac{\pi}{2}$', '$0$', '$\frac{\pi}{2}$', '$\pi$', '$2 \pi$' } ) );

    set( gcf, 'Position', [ 250 200 800 300 ] );               
    set( gca, 'FontSize', 18 );
    set( gca, 'TickLabelInterpreter', 'latex' );
end

%========================%
% Generación de símbolos %
%========================%
n_symbols = 1000;
ak = 2 * randi( [ 0, 1 ], 1, n_symbols ) - 1;

xn = zeros( 1, n_symbols * M );
xn( 1 : M : end ) = ak;  % Esta es la secuencia extendida

if graficas_ploteadas( 3 ) == 1 
    figure( 3 )
    
    lim_x_izquierda_calculo = - 3;
    lim_x_derecha_calculo = 35; 
    
    stem( 0 : lim_x_derecha_calculo-1, xn( 1 : lim_x_derecha_calculo ), ...
          'Color', [ 0.074 0.313 0.705 ], 'MarkerFaceColor', [ 0.156 0.450 0.921 ]  );
        
    lim_y_abajo_grafica = -1.6;
    lim_y_arriba_grafica = 1.6;
    lim_x_izquierda_grafica = lim_x_izquierda_calculo;
    lim_x_derecha_grafica = lim_x_derecha_calculo;
    ylim( [ lim_y_abajo_grafica, lim_y_arriba_grafica ] );
    xlim( [ lim_x_izquierda_grafica, lim_x_derecha_grafica ] );

    line( [ 0 0 ], [ 0 ( 1 / 1.15 * lim_y_arriba_grafica ) ], 'Color', [ 0 0 0 ] );
    line( [ 0 ( ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 100 ) ], ...
                  [ ( 1 / 1.15 * lim_y_arriba_grafica ) ( 1 / 1.2 * lim_y_arriba_grafica ) ], ...
                  'Color', [ 0 0 0 ] ); 
    line( [ 0 ( - ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 100 ) ], ...
                  [ ( 1 / 1.15 * lim_y_arriba_grafica ) ( 1 / 1.2 * lim_y_arriba_grafica ) ], ...
                  'Color', [ 0 0 0 ] );  

    set( gcf, 'Position', [ 250 200 800 300 ] );               
    set( gca, 'FontSize', 12 );
    set( gca, 'TickLabelInterpreter', 'latex' );

    set( gca, 'YTick', ( [ -1 0 1 ] ) );
    set( gca, 'yticklabel', ( { '$bit \ 1 \rightarrow -1$', '$0$', '$bit \ 0 \rightarrow 1$' } ) );

    set( gca, 'XTick', [ 0 M 2*M 3*M 4*M 5*M] );
    set( gca, 'xticklabel', ( { '$0$', '$2 M$', '$3 M$', '$4 M$', '$5 M$', '$6 M$' } ) );

    xlabel( '$n$', 'FontSize', 22, 'Interpreter', 'latex', 'Position', [ lim_x_derecha_grafica + ...
            ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 25,  0.1 * lim_y_arriba_grafica ] );
    ylabel( '$x_{e}[n]$', 'Rotation', 0, 'FontSize', 22, 'Interpreter', 'latex', 'Position', [ ...
            ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 12, 0.65 * lim_y_arriba_grafica ] );
     
end

%===================%
% Señal transmitida %
%===================%

sn = conv( xn, gn );

if graficas_ploteadas( 4 ) == 1 
    
    figure( 4 )
    plot( sn( ( 2 * L * M + 1 ) : ( 2 * L * M + 1 ) * 10 ), '.-' );
    
    ver_escala_ampliada = false;
    
    if ver_escala_ampliada
        lim_x_izquierda_calculo = 300;
        lim_x_derecha_calculo = 390; 
        grid
        for i = 1 : 100
            line( [ (i*M)+1 (i*M)+1 ], [ 2 -2 ], 'Color', [ 0 1 0 ] );
        end
    else
        lim_x_izquierda_calculo = 300;
        lim_x_derecha_calculo = 900;         
    end
           
    lim_y_abajo_grafica = -2;
    lim_y_arriba_grafica = 2;
    lim_x_izquierda_grafica = lim_x_izquierda_calculo;
    lim_x_derecha_grafica = lim_x_derecha_calculo;
    ylim( [ lim_y_abajo_grafica, lim_y_arriba_grafica ] );
    xlim( [ lim_x_izquierda_grafica, lim_x_derecha_grafica ] );
    
    line( [ 0 ( ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 100 ) ], ...
                  [ ( 1 / 1.15 * lim_y_arriba_grafica ) ( 1 / 1.2 * lim_y_arriba_grafica ) ], ...
                  'Color', [ 0 0 0 ] ); 
    line( [ 0 ( - ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 100 ) ], ...
                  [ ( 1 / 1.15 * lim_y_arriba_grafica ) ( 1 / 1.2 * lim_y_arriba_grafica ) ], ...
                  'Color', [ 0 0 0 ] );  

    set( gcf, 'Position', [ 250 200 800 300 ] );               
    set( gca, 'FontSize', 12 );
    set( gca, 'TickLabelInterpreter', 'latex' );

    set( gca, 'YTick', ( [ -1 0 1 ] ) );
    set( gca, 'yticklabel', ( { '$bit \ 1 \rightarrow -1$', '$0$', '$bit \ 0 \rightarrow 1$' } ) );

    set( gca, 'XTick', [ 0 M 2*M 3*M 4*M 5*M] );
    set( gca, 'xticklabel', ( { '$0$', '$2 M$', '$3 M$', '$4 M$', '$5 M$', '$6 M$' } ) );

    xlabel( '$t$', 'FontSize', 22, 'Interpreter', 'latex', 'Position', [ lim_x_derecha_grafica + ...
            ( lim_x_derecha_grafica - lim_x_izquierda_grafica ) / 25,  0.1 * lim_y_arriba_grafica ] );

end

%============================%
% Generación de diagrama ojo %
%============================%

if graficas_ploteadas( 5 ) == 1 
    figure( 5 )
    
    d = 5;  % Delay para centrar el ojo
    
    for m = 2 * L + 1 : n_symbols - ( 2 * L + 1 )
        sn_p = sn( m * M + d : m * M + d + M );
        plot( -M / 2 : 1 : M / 2, sn_p ); 
        hold on
    end
    grid
   
    set( gcf, 'Position', [ 250 200 450 300 ] );               
    set( gca, 'FontSize', 12 );
    set( gca, 'TickLabelInterpreter', 'latex' );
    
    lim_y_abajo_grafica = -2.5;
    lim_y_arriba_grafica = 2.5;
    ylim( [ lim_y_abajo_grafica, lim_y_arriba_grafica ] );
          
    set( gca, 'YTick', ( [ -2 -1 0 1 2 ] ) );
    set( gca, 'yticklabel', ...
         ( { '$-2$', '$ \ bit \ 1 \rightarrow -1$', '$$', '$bit \ 0 \rightarrow 1$', '$2$' } ) );

    set( gca, 'XTick', [ 0 ] );
    set( gca, 'xticklabel', ( { '$0$' } ) );
    
    text( 2*T+0.2, 2.1, [ '$\alpha=$' num2str( alpha ) ], 'FontSize', 14, 'Interpreter', 'latex', ...
          'Color', [ 0.152 0.325 0.8 ] );

end

return;
 


