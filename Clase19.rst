.. -*- coding: utf-8 -*-

.. _rcs_subversion:

Clase 19 - PIII 2019
====================
(Fecha: 25 de octubre)


**Problema con el Ejemplo del filtro paso bajos aplicado "a mano"**

- Utilizando el código que hace la sumatoria del producto de los valores de los vectores, se consume demasiado tiempo.
- Tanto tiempo que no se puede mantener la frecuencia de muestreo.
- Una opción es usar PLL.
- El siguiente código resuelve el caso con PLL x8, para el dsPIC30F4013 con cristal de 10MHz

.. code-block:: c

	#define M 17
	float x[ M ];
	float h[ M ] =  {
	    0.037841336, 0.045332663, 0.052398494, 0.058815998, 0.064379527, 
	    0.068908578, 0.072254832, 0.074307967, 0.075000000, 0.074307967, 
	    0.072254832, 0.068908578, 0.064379527, 0.058815998, 0.052398494, 
	    0.045332663, 0.037841336
	};

	float yn = 0;

	unsigned int i;
	short k;
	float valorActual = 0;

	void  detectarIntADC()  org 0x002A  {

	    IFS0bits.ADIF=0;

	    for ( k = M-1 ; k >= 1 ; k-- )  {
	        x[ k ] = x[ k - 1 ];
	    }

	    //Se guarda la última muestra.
	    x[ 0 ] = ( ( float )ADCBUF0 - 2048 );

	    yn = 0;

	    for ( k = 0 ; k < M ; k++ )  {
	        yn += h[ k ] * x[ k ];
	    }

	    valorActual = yn + 2048;


	    LATCbits.LATC14 = ( (unsigned int) valorActual & 0b0000100000000000) >> 11;
	    LATBbits.LATB2 =  ( (unsigned int) valorActual & 0b0000010000000000) >> 10;
	    LATBbits.LATB3 =  ( (unsigned int) valorActual & 0b0000001000000000) >> 9;
	    LATBbits.LATB4 =  ( (unsigned int) valorActual & 0b0000000100000000) >> 8;
	    LATBbits.LATB5 =  ( (unsigned int) valorActual & 0b0000000010000000) >> 7;
	    LATBbits.LATB6 =  ( (unsigned int) valorActual & 0b0000000001000000) >> 6;
	    LATBbits.LATB8 =  ( (unsigned int) valorActual & 0b0000000000100000) >> 5;
	    LATBbits.LATB9 =  ( (unsigned int) valorActual & 0b0000000000010000) >> 4;
	    LATBbits.LATB10 = ( (unsigned int) valorActual & 0b0000000000001000) >> 3;
	    LATBbits.LATB11 = ( (unsigned int) valorActual & 0b0000000000000100) >> 2;
	    LATBbits.LATB12 = ( (unsigned int) valorActual & 0b0000000000000010) >> 1;
	    LATCbits.LATC13 = ( (unsigned int) valorActual & 0b0000000000000001) >> 0;

	    LATDbits.LATD1 = ~LATDbits.LATD1;

	}

	void detectarIntT2() org 0x0020  {

	    IFS0bits.T2IF = 0;  // borra bandera de interrupcion de T2

	    ADCON1bits.SAMP = 1; // pedimos muestras
	    asm nop;  //ciclo de instruccion sin operacion
	    ADCON1bits.SAMP = 0;  // retener muestra e iniciar conversion
	}

	void configADC()  {
	    ADPCFG = 0b111110;  // elegimos AN0 como entrada para muestras
	    ADCHS = 0b0000;  // usamos AN0 para recibir las muestras en el ADC
	    ADCON1bits.SSRC = 0b000; // muestreo manual
	    ADCON2bits.VCFG = 0b000;  //tension de referencia externa Vref+ Vref-

	    IEC0bits.ADIE = 1;  //habilitamos interrupcion del ADC
	}

	void configT2()  {
	    T2CONbits.TCKPS = 0b00;  // prescaler = 1
	    PR2 = 5000;   // PLLx8 - cristal 10MHz - Tcy=50ns - Entonces fs=4kHz

	    IEC0bits.T2IE = 1; // habilitamos interrupciones para T2
	}

	void configPuertos()  {
	    TRISCbits.TRISC14 = 0;  // Bit mas significativo de la senal generada
	    TRISBbits.TRISB2  = 0;
	    TRISBbits.TRISB3  = 0;
	    TRISBbits.TRISB4  = 0;
	    TRISBbits.TRISB5  = 0;
	    TRISBbits.TRISB6  = 0;
	    TRISBbits.TRISB8  = 0;
	    TRISBbits.TRISB9  = 0;
	    TRISBbits.TRISB10 = 0;
	    TRISBbits.TRISB11 = 0;
	    TRISBbits.TRISB12 = 0;
	    TRISCbits.TRISC13 = 0;  // Bit menos significativo de la senal generada

	    TRISDbits.TRISD1=0;  // Debug
	}

	void main()  {
	    configPuertos();
	    configT2();
	    configADC();

	    ADCON1bits.ADON = 1;

	    T2CONbits.TON = 1;

	    while(1)  {  }
	}




Probando filtros en placa
=========================


- Video sobre cómo utilizar el generador de señal (https://www.youtube.com/watch?v=qCRcNYbqBxs)



**Ejemplo para dsPIC30F4013 para Placa**

.. code-block:: c

	// Device setup:
	//     Device name: P30F4013
	//     Device clock: 010.000000 MHz
	//     Dev. board: EasydsPic4A
	//     Sampling Frequency: 4000 Hz
	// Filter setup:
	//     Filter kind: FIR
	//     Filter type: Lowpass filter
	//     Filter order: 30
	//     Filter window: Hamming
	//     Filter borders:
	//       Wpass:150 Hz
	const unsigned BUFFFER_SIZE  = 32;
	const unsigned FILTER_ORDER  = 30;

	const unsigned COEFF_B[ FILTER_ORDER + 1 ] = {
	    0xFFD5, 0xFFEB, 0x000F, 0x005A, 0x00E6, 0x01C9,
	    0x0312, 0x04C4, 0x06D3, 0x0926, 0x0B98, 0x0DF9,
	    0x1017, 0x11C3, 0x12D5, 0x1333, 0x12D5, 0x11C3,
	    0x1017, 0x0DF9, 0x0B98, 0x0926, 0x06D3, 0x04C4,
	    0x0312, 0x01C9, 0x00E6, 0x005A, 0x000F, 0xFFEB,
	    0xFFD5
	};

	unsigned inext;                       // Input buffer index
	ydata unsigned input[ BUFFFER_SIZE ];   // Input buffer, must be in Y data space

	void  detectarIntADC()  org 0x002a  {
	    unsigned CurrentValue;

	    IFS0bits.ADIF = 0; // Borramos el flag de interrupciones del ADC
	    LATFbits.LATF1 = !LATFbits.LATF1;  // Para debug de la interrupcion ADC

	    if( PORTFbits.RF4 == 0 )  {
	        LATFbits.LATF5 = 1;  // Filtro no aplicado

	        input[ inext ] = ADCBUF0;  // Fetch sample

	        CurrentValue = FIR_Radix( FILTER_ORDER + 1,  // Filter order
	                                  COEFF_B,           // b coefficients of the filter
	                                  BUFFFER_SIZE,      // Input buffer length
	                                  input,             // Input buffer
	                                  inext );           // Current sample

	        inext = ( inext + 1 ) & ( BUFFFER_SIZE - 1 );  // inext = ( inext + 1 ) mod BUFFFER_SIZE;

	        LATCbits.LATC14 = ( ( unsigned int )CurrentValue & 0b0000100000000000) >> 11;
	        LATBbits.LATB2 =  ( ( unsigned int )CurrentValue & 0b0000010000000000) >> 10;
	        LATBbits.LATB3 =  ( ( unsigned int )CurrentValue & 0b0000001000000000) >> 9;
	        LATBbits.LATB4 =  ( ( unsigned int )CurrentValue & 0b0000000100000000) >> 8;
	        LATBbits.LATB5 =  ( ( unsigned int )CurrentValue & 0b0000000010000000) >> 7;
	        LATBbits.LATB6 =  ( ( unsigned int )CurrentValue & 0b0000000001000000) >> 6;
	        LATBbits.LATB8 =  ( ( unsigned int )CurrentValue & 0b0000000000100000) >> 5;
	        LATBbits.LATB9 =  ( ( unsigned int )CurrentValue & 0b0000000000010000) >> 4;
	        LATBbits.LATB10 = ( ( unsigned int )CurrentValue & 0b0000000000001000) >> 3;
	        LATBbits.LATB11 = ( ( unsigned int )CurrentValue & 0b0000000000000100) >> 2;
	        LATBbits.LATB12 = ( ( unsigned int )CurrentValue & 0b0000000000000010) >> 1;
	        LATCbits.LATC13 = ( ( unsigned int )CurrentValue & 0b0000000000000001) >> 0;

	    }
	    else  {
	        LATFbits.LATF5 = 0;  // Filtro no aplicado

	        LATCbits.LATC14 = ADCBUF0.B11;
	        LATBbits.LATB2 = ADCBUF0.B10;
	        LATBbits.LATB3 = ADCBUF0.B9;
	        LATBbits.LATB4 = ADCBUF0.B8;
	        LATBbits.LATB5 = ADCBUF0.B7;
	        LATBbits.LATB6 = ADCBUF0.B6;
	        LATBbits.LATB8 = ADCBUF0.B5;
	        LATBbits.LATB9 = ADCBUF0.B4;
	        LATBbits.LATB10 = ADCBUF0.B3;
	        LATBbits.LATB11 = ADCBUF0.B2;
	        LATBbits.LATB12 = ADCBUF0.B1;
	        LATCbits.LATC13 = ADCBUF0.B0;
	    }

	    LATDbits.LATD1 = ~LATDbits.LATD1;
	}

	void detectarIntT2() org 0x0020  {
	    IFS0bits.T2IF = 0;  //borra bandera de interrupcion de T2

	    LATFbits.LATF0 = !LATFbits.LATF0;

	    ADCON1bits.SAMP = 1; // pedimos muestras
	    asm nop;  // ciclo instruccion sin operacion
	    ADCON1bits.SAMP = 0;  // etener muestra e inicia conversion
	}

	void configADC()  {
	    ADPCFG = 0b111110;  // elegimos AN0 como entrada para muestras
	    ADCHS = 0b0000; // usamos AN0 para recibir las muestras en el ADC
	    ADCON1bits.SSRC = 0b000; // muestreo manual
	    ADCON1bits.ADON = 0;  // apagamos ADC
	    ADCON2bits.VCFG = 0b000;  // tension de referencia 0 y 5
	    IEC0bits.ADIE = 1;  // habilitamos interrupcion del ADC
	}

	void configT2()  {
	    PR2 = 5000;  
	    IEC0bits.T2IE = 1; // habilitamos interrupciones para T2
	}

	void configPuertos()  {

	    TRISCbits.TRISC14 = 0;  // Bit mas significativo de la senal generada
	    TRISBbits.TRISB2  = 0;
	    TRISBbits.TRISB3  = 0;
	    TRISBbits.TRISB4  = 0;
	    TRISBbits.TRISB5  = 0;
	    TRISBbits.TRISB6  = 0;
	    TRISBbits.TRISB8  = 0;
	    TRISBbits.TRISB9  = 0;
	    TRISBbits.TRISB10 = 0;
	    TRISBbits.TRISB11 = 0;
	    TRISBbits.TRISB12 = 0;
	    TRISCbits.TRISC13 = 0;  // Bit menos significativo de la senal generada

	    TRISDbits.TRISD1 = 0;  // Debug

	    TRISBbits.TRISB0 = 1;  // AN0

	    TRISFbits.TRISF0 = 0;  // Debug 
	    TRISFbits.TRISF1 = 0;  // Debug 

	    TRISFbits.TRISF4 = 1;  // Filtro y no filtro

	    TRISFbits.TRISF5 = 0;  // Led indicador de filtro aplicado
	}

	void main()  {
	    configPuertos();
	    configT2();
	    configADC();

	    ADCON1bits.ADON = 1;

	    T2CONbits.TON = 1;

	    while(1)  {  }
	}



Ejercicio:
==========

- Usar la placa con el dsPIC30F4013 y defina los parámetros que considere para lograr lo siguiente:
	- Filtro pasa bajos con frecuencia de corte 200 Hz
	- ADC Automático 
	- DAC R-2R
	- Usar el generador de señales del laboratorio
	- Elegir un pulsador para intercambiar entre:
		- Default: Señal sin procesar
		- 1- Pasa bajos con frecuencia de corte 200 Hz
		- 2- Pasa bajos con frecuencia de corte según se indica para cada alumno

- Entregar:
	- Video de aproximadamente 10 segundos mostrando cómo se atenúa la señal de entrada
	- Código fuente con comentarios en el código y organizado en funciones


**Variaciones por alumno:**

:Juan:
    Frecuencia de corte para el segundo pasa bajos: 800 Hz
	
    Frecuencia de muestreo: 5 kHz

:Pablo:
    Frecuencia de corte para el segundo pasa bajos: 500 Hz
	
    Frecuencia de muestreo: 7 kHz

:Conrado:
    Frecuencia de corte para el segundo pasa bajos: 700 Hz
	
    Frecuencia de muestreo: 4 kHz

:Facundo:
    Frecuencia de corte para el segundo pasa bajos: 600 Hz
	
    Frecuencia de muestreo: 6 kHz


Ejemplo:
========

- Colocar un pulsador en INT0 para conmutar entre señal sin procesar, filtro pasa bajos y filtro pasa altos.
- Utilizar la placa de desarrollo y el dsPIC30F4013

- `Programa realizado en clase - Clase19_dos_filtros.zip <https://github.com/cosimani/Curso-PIII-2019/blob/master/resources/clase19/Clase19_dos_filtros.zip?raw=true>`_
