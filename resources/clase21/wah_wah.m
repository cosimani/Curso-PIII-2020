% Basado en: https://github.com/andregri/Wah-Wah/blob/master/wah_wah.m

%url = 'http://diagnosticocordoba4-0.com.ar/cosillas/sucia_maquina_genesis.mp3';
%filename = 'sucia_maquina_genesis.mp3';
%outfilename = websave( filename, url );
%disp( outfilename ) 

outfilename = 'hendrix.wav';
%outfilename = 'hendrix_fender.wav';

[ x, Fs ] = audioread( outfilename );

aInfo = audioinfo( outfilename );
duracion = aInfo.Duration;


disp( Fs );

% Si el archivo de audio tiene demasiadas muestras, puede demorar mucho en procesar.
% Con la siguiente linea sólo tomamos entre estas muestras.
%x = x( 250000 : 350000 );

%%%%%%% EFFECT COEFFICIENTS %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% damping factor
% lower the damping factor the smaller the pass band
damp = 0.3;

% min and m
% min and max centre cutoff frequency of variable bandpass filter
minf = 500;
maxf = 3000;

% wah frequency, how many Hz per second are cycled through
Fw = 13000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change in centre frequency per sample (Hz)
delta = Fw / Fs;

% create triangle wave of centre frequency values
Fc = minf : delta : maxf;
while( length( Fc ) < length( x ) )
    Fc = [ Fc ( maxf : -delta : minf ) ];
    Fc = [ Fc ( minf :  delta : maxf ) ];
end

% trim tri wave to size of input
Fc = Fc( 1 : length( x ) );

%difference equation coefficients
% must be recalculated each time Fc changes
F1 = 2 * sin( ( pi * Fc( 1 ) ) / Fs );

% this dictates size of the pass bands
Q1 = 2 * damp;

%yh=zeros(size(x));          % create emptly out vectors
yb = zeros( size( x ) );

%yl=zeros(size(x));
% first sample, to avoid referencing of negative signals
%yh(1) = x(1);
yb( 1 ) = F1 * x( 1 );

%yl(1) = F1*yb(1);
% apply difference equation to the sample
fc = minf; % inicializacion de fc

for n = 2 : length( x )
    %yh(n) = x(n) - yl(n-1) - Q1*yb(n-1);
    yb( n ) = F1 * x( n ) - F1 * Q1 * yb( n - 1 ) + yb( n - 1 ) - F1 * F1 * sum( yb( 1 : n - 1 ) );
    %yl(n) = F1*yb(n) + yl(n-1);
    if fc + delta > maxf || fc + delta < minf 
        delta = -delta;
    end
    
    fc = fc + delta;
    F1 = 2 * sin( ( pi * fc ) / Fs );
end

%normalise
maxyb = max( abs( yb ) );
yb = yb / maxyb;

%write output wav files
%wavwrite(yb, Fs, N, 'out_wah.wav');
audiowrite( 'out_wah.wav', yb, Fs );
%audiowrite( 'hendrix_wah.wav', yb, Fs );
%audiowrite( 'hendrix_fender_wah.wav', yb, Fs );

figure( 1 )
hold on
plot( x, 'r' );
plot( yb, 'b' );
title( 'Señal con wah-wah y original' );

sound( x, Fs );

pause( duracion + 0.5 );

sound( yb, Fs );


