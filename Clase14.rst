.. -*- coding: utf-8 -*-

.. _rcs_subversion:

Clase 14 - PIII 2020
====================
(Fecha: 14 de octubre)


Programación de filtros
^^^^^^^^^^^^^^^^^^^^^^^	
	
**Función de transferencia**

- Relación entre la entrada y la salida al pasar por el proceso
- Para simplificar, se manipulan en términos de la frecuencia compleja y no del tiempo continuo 
- Las funciones de transferencia en tiempo discreto se hace en término de la variable compleja z
- Se recurre a la transformada Z que representa la frecuencia compleja para tiempo discreto

.. figure:: images/clase08/filtros_1.png

- Para el tratamiento real en término del tiempo discreto se realiza la transformada inversa de z
- La transformación inversa de la ecuación anterior queda en función del tiempo discreto:

.. figure:: images/clase08/filtros_2.png

- Esto es una convolución
- El número máximo que asume n es M
- M determina el orden de la función de transferencia

- FIR (Finite Impulse Response): Convolución con muestras pasadas y actuales.
- IIR (Infinite Impulse Response): Filtros recursivos (poseen realimentación). Convolución con muestras pasadas, actuales y también salidas pasadas


**Convolución en C - Filtro FIR**

.. figure:: images/clase08/filtros_3.png

**El código puede ser:**

.. code-block:: c

	#define M 17
	float x[ M ];
	float h[ M ];

	float yn = 0;
	short k;
	
	for ( k = M - 1 ; k >= 1 ; k-- )
	    x[ k ] = x[ k-1 ];
		
	x[ 0 ] = x0;  // x0 es la muestra actual
	
	for ( k = 0 ; k < M ; k++ )
	    yn += h[ k ] * x[ k ];



**Función de transferencia: Filtro pasa bajos**

.. figure:: images/clase08/filtros_4.png

- Lo podemos calcular con el Excel

.. figure:: images/clase08/filtros_5.png

.. figure:: images/clase08/filtros_6.png

**Ejemplo Filtro FIR**

- Fs = 4000
- Fc = 150Hz

.. code-block:: c

	#define M 17
	float x[ M ];
	float h[ M ] = 
	    { 0.037841336, 0.045332663, 0.052398494, 0.058815998, 0.064379527,
	      0.068908578, 0.072254832, 0.074307967, 0.075,       0.074307967, 
	      0.072254832, 0.068908578, 0.064379527, 0.058815998, 0.052398494, 
	      0.045332663, 0.037841336 };

	float yn = 0;

	unsigned int i;
	short k;
	float valorActual = 0;

	void  detectarIntADC()  org 0x002E  {
	    IFS0bits.AD1IF = 0;

	    for ( k = M-1 ; k >= 1 ; k-- )  {
	        x[ k ] = x[ k-1 ];
	    }

	    //Se guarda la última muestra.
	    x[ 0 ] = ( ( float )ADC1BUF0 - 2048 );

	    yn = 0;

	    for ( k = 0 ; k < M ; k++ )  {
	        yn += h[ k ] * x[ k ];
	    }

	    valorActual = yn + 2048;

	    LATBbits.LATB2 =  ( (unsigned int) valorActual & 0b0000100000000000 ) >> 11;
	    LATBbits.LATB3 =  ( (unsigned int) valorActual & 0b0000010000000000 ) >> 10;
	    LATBbits.LATB4 =  ( (unsigned int) valorActual & 0b0000001000000000 ) >> 9;
	    LATBbits.LATB5 =  ( (unsigned int) valorActual & 0b0000000100000000 ) >> 8;
	    LATBbits.LATB6 =  ( (unsigned int) valorActual & 0b0000000010000000 ) >> 7;
	    LATBbits.LATB7 =  ( (unsigned int) valorActual & 0b0000000001000000 ) >> 6;
	    LATBbits.LATB8 =  ( (unsigned int) valorActual & 0b0000000000100000 ) >> 5;
	    LATBbits.LATB9 =  ( (unsigned int) valorActual & 0b0000000000010000 ) >> 4;
	    LATBbits.LATB10 = ( (unsigned int) valorActual & 0b0000000000001000 ) >> 3;
	    LATBbits.LATB11 = ( (unsigned int) valorActual & 0b0000000000000100 ) >> 2;
	    LATBbits.LATB12 = ( (unsigned int) valorActual & 0b0000000000000010 ) >> 1;
	    LATBbits.LATB13 = ( (unsigned int) valorActual & 0b0000000000000001 ) >> 0;
	}

	void detectarIntT2() org 0x0022  {

	    IFS0bits.T2IF = 0;  //borra bandera de interrupcion de TIMER2

	    LATBbits.LATB15 = ~LATBbits.LATB15;

	    AD1CON1bits.SAMP = 1;  //pedimos muestras
	    asm nop;               //ciclo instruccion sin operacion
	    AD1CON1bits.SAMP = 0;  //retener muestra e inicia conversion
	}

	void configADC()  {
	    AD1PCFGL = 0b111011;       // elegimos AN2 como entrada para muestras
	    AD1CHS0 = 0b0010;          // usamos AN2 para recibir las muestras en el ADC
	    AD1CON1bits.SSRC = 0b000;  // muestreo manual
	    AD1CON1bits.ADON = 0;      // apagamos ADC
	    AD1CON1bits.AD12B = 1;     // 12bits S&H ADC1
	    AD1CON2bits.VCFG = 0b011;  // tension de referencia externa Vref+ Vref-
	    IEC0bits.AD1IE = 1;        // habilitamos interrupcion del ADC
	}

	void configTIMER2()  {
	    T2CON=0x0000;   //registro de control de TIMER2 a cero
	    T2CONbits.TCKPS=0b00;// prescaler = 1
	    TMR2=0;  //desde donde va a arrancar la cuenta
	    PR2=1250;   //hasta donde cuenta segun calculo para disparo de TIMER2
	    IEC0bits.T2IE=1; //habilitamos interrupciones para TIMER2
	}

	void configPuertos()  {
	    TRISBbits.TRISB2 = 0;
	    TRISBbits.TRISB3 = 0;
	    TRISBbits.TRISB4 = 0;
	    TRISBbits.TRISB5 = 0;
	    TRISBbits.TRISB6 = 0;
	    TRISBbits.TRISB7 = 0;
	    TRISBbits.TRISB8 = 0;
	    TRISBbits.TRISB9 = 0;
	    TRISBbits.TRISB10 = 0;
	    TRISBbits.TRISB11 = 0;
	    TRISBbits.TRISB12 = 0;
	    TRISBbits.TRISB13 = 0;

	    TRISBbits.TRISB15 = 0;  // Debug T2
	}

	void main()  {
	    configPuertos();
	    configTIMER2();
	    configADC();

	    AD1CON1bits.ADON = 1;

	    T2CONbits.TON = 1;

	    while( 1 )  {  }
	}



Algunos ejemplos:
=================

- **Ejemplo 1:** Filtro pasa bajos calculando coeficientes en una función y aplicando filtro con bucle for

- **Ejemplo 2:** Ejemplo anterior modificado para aplicar distintos procesamientos con un pulsador

- **Ejemplo 3:** Filtro pasa bajos calculando coeficientes con Filter Designer Tool y aplicando con librería


Ejemplo 1:
==========

.. code-block:: c

	// dsPIC33FJ32MC202

	// Filtro FIR pasa bajos

	// ADC
	//      10 bits / AN0 / AVdd y AVss / Muestreado con Timer 2

	#define FRECUENCIA_MUESTREO 4000
	#define FRECUENCIA_CORTE 150
	#define M 17

	int index_array = 0;
	int muestra_adc = 0;
	int tremolo = 0;
	float h[ M ];
	float x[ M ];

	float valor_filtrado = 0;

	void calcularCoeficientes()  {
	    int n;

	    for ( n = - ( M - 1 ) / 2 ; n <= ( ( M - 1 ) / 2 ) ; n++ )  {
	        if ( n == 0 )  {
	            h[ n ] = 2 * FRECUENCIA_CORTE / FRECUENCIA_MUESTREO;
	        }
	        else  {
	            h[ n ] = sin( 2 * 3.14159 * FRECUENCIA_CORTE * n / FRECUENCIA_MUESTREO ) / ( 3.14159 * n );
	        }
	    }
	}

	void config_puertos()  {

	    TRISAbits.TRISA0 = 1;  // Entrada AN0

	    TRISBbits.TRISB9 = 0;  // Mas significativo
	    TRISBbits.TRISB8 = 0;
	    TRISBbits.TRISB7 = 0;
	    TRISBbits.TRISB6 = 0;
	    TRISBbits.TRISB5 = 0;
	    TRISBbits.TRISB4 = 0;
	    TRISBbits.TRISB3 = 0;
	    TRISBbits.TRISB2 = 0;
	    TRISBbits.TRISB1 = 0;
	    TRISBbits.TRISB0 = 0;  // Menos significativo

	    TRISBbits.TRISB14 = 0;  // debug_timer
	    TRISBbits.TRISB15 = 0;  // debug_adc
	}

	void config_timer2()  {
	    PR2 = 1 / ( FRECUENCIA_MUESTREO * 0.0000002 );
	}

	void config_adc()  {
	    ADPCFG = 0xFFFE;  // AN0 como entrada analogica

	    // Muestreo la entrada analogica AN0
	    AD1CHS0 = 0b0000;

	    AD1CON1bits.AD12B = 0;  // ADC de 10 bits
	    AD1CON1bits.FORM = 0b00;  // Formato de salida entero
	}

	void interrupcion_timer2() org 0x0022  {
	    IFS0bits.T2IF = 0;

	    LATBbits.LATB14 = ~LATBbits.LATB14;  // debug_timer

	    AD1CON1bits.DONE = 0;  // Antes de pedir una muestra ponemos en cero
	    AD1CON1bits.SAMP = 1;  // Pedimos una muestra

	    asm nop;  // Tiempo que debemos esperar para que tome una muestra

	    AD1CON1bits.SAMP = 0;  // Pedimos que retenga la muestra
	}

	void interrupcion_adc() org 0x002e  {
	    int k;
	    float yn;

	    IFS0bits.AD1IF = 0;

	    LATBbits.LATB15 = ~LATBbits.LATB15;  // debug_adc
	    
	    for ( k = ( M - 1 ) ; k >= 1 ; k-- )  {
	        x[ k ] = x[ k - 1 ];
	    }

	    x[ 0 ] = ( ( float )ADC1BUF0 );
	    
	    yn = 0;

	    for ( k = 0 ; k < M ; k++ )  {
	        yn += h[ k ] * x[ k ];
	    }
	    
	    valor_filtrado = yn;
	    
	    LATBbits.LATB9 = ( (unsigned int)valor_filtrado & 0b0000001000000000 ) >> 9;
	    LATBbits.LATB8 = ( (unsigned int)valor_filtrado & 0b0000000100000000 ) >> 8;
	    LATBbits.LATB7 = ( (unsigned int)valor_filtrado & 0b0000000010000000 ) >> 7;
	    LATBbits.LATB6 = ( (unsigned int)valor_filtrado & 0b0000000001000000 ) >> 6;
	    LATBbits.LATB5 = ( (unsigned int)valor_filtrado & 0b0000000000100000 ) >> 5;
	    LATBbits.LATB4 = ( (unsigned int)valor_filtrado & 0b0000000000010000 ) >> 4;
	    LATBbits.LATB3 = ( (unsigned int)valor_filtrado & 0b0000000000001000 ) >> 3;
	    LATBbits.LATB2 = ( (unsigned int)valor_filtrado & 0b0000000000000100 ) >> 2;
	    LATBbits.LATB1 = ( (unsigned int)valor_filtrado & 0b0000000000000010 ) >> 1;
	    LATBbits.LATB0 = ( (unsigned int)valor_filtrado & 0b0000000000000001 ) >> 0;

	}

	void main()  {

	    calcularCoeficientes();
	    
	    config_puertos();
	    config_timer2();
	    config_adc();

	    IEC0bits.AD1IE = 1;
	    IEC0bits.T2IE = 1;

	    AD1CON1bits.ADON = 1;
	    T2CONbits.TON = 1;

	    while( 1 )  {  }
	}

.. figure:: images/clase14/Filtro_a_mano.BMP


Ejemplo 2:
==========

.. code-block:: c

	// dsPIC33FJ32MC202

	// Filtro FIR pasa bajos

	// ADC
	//      10 bits / AN0 / AVdd y AVss / Muestreado con Timer 2

	#define FRECUENCIA_MUESTREO 3000
	#define FRECUENCIA_CORTE 150
	#define M 17

	int estado;  // 0 - sin filtro / 1 - con / 2 - cresta positiva / vuelve a 0

	float h[ M ];
	float x[ M ];

	void calcularCoeficientes()  {
	    int n;

	    for ( n = - ( M - 1 ) / 2 ; n <= ( ( M - 1 ) / 2 ) ; n++ )  {
	        if ( n == 0 )  {
	            h[ n ] = 2 * FRECUENCIA_CORTE / FRECUENCIA_MUESTREO;
	        }
	        else  {
	            h[ n ] = sin( 2 * 3.14159 * FRECUENCIA_CORTE * n / FRECUENCIA_MUESTREO ) / ( 3.14159 * n );
	        }
	    }
	}

	void config_puertos()  {

	    TRISAbits.TRISA0 = 1;  // Entrada AN0
	    
	    TRISBbits.TRISB7 = 1;  // Pulsador en INT0

	    TRISBbits.TRISB9 = 0;  // Mas significativo
	    TRISBbits.TRISB8 = 0;
	    TRISBbits.TRISB10 = 0;
	    TRISBbits.TRISB6 = 0;
	    TRISBbits.TRISB5 = 0;
	    TRISBbits.TRISB4 = 0;
	    TRISBbits.TRISB3 = 0;
	    TRISBbits.TRISB2 = 0;
	    TRISBbits.TRISB1 = 0;
	    TRISBbits.TRISB0 = 0;  // Menos significativo

	    TRISBbits.TRISB14 = 0;  // debug_timer
	    TRISBbits.TRISB12 = 0;  // debug_adc
	    
	    TRISBbits.TRISB15 = 0;
	}

	void config_timer2()  {
	    PR2 = 1 / ( FRECUENCIA_MUESTREO * 0.0000002 );
	}

	void config_adc()  {

	    ADPCFG = 0xFFFE; // AN0 como entrada analogica

	    // Muestreo la entrada analogica AN0
	    AD1CHS0 = 0b0000;

	    AD1CON1bits.AD12B = 0;  // ADC de 10 bits
	    AD1CON1bits.FORM = 0b00;  // Formato de salida entero
	}

	void interrupcion_timer2() org 0x0022  {
	    IFS0bits.T2IF = 0;

	    LATBbits.LATB14 = ~LATBbits.LATB14;  // debug_timer

	    AD1CON1bits.DONE = 0;  // Antes de pedir una muestra ponemos en cero
	    AD1CON1bits.SAMP = 1;  // Pedimos una muestra

	    asm nop;  // Tiempo que debemos esperar para que tome una muestra

	    AD1CON1bits.SAMP = 0;  // Pedimos que retenga la muestra
	}

	// Con un pulsador en INT0 hacer:
	// ni bien enciende: Salida sin filtro
	// pulsando una vez: Con el filtro
	// pulsando otra vez: Solo cresta positiva (sin filtro)
	// pulsando otra vez: Vuelve al estado sin filtro

	void interrupcion_adc() org 0x002e  {
	    int k;
	    float yn;
	    float valor_filtrado;
	    int valor_adc;

	    IFS0bits.AD1IF = 0;

	    LATBbits.LATB12 = ~LATBbits.LATB12;  // debug_adc
	    
	    if ( estado == 0 )  {
	        valor_adc = ADC1BUF0;
	        
	        LATBbits.LATB15 = 1;
	        
	        LATBbits.LATB9 = ( valor_adc & 0b0000001000000000 ) >> 9;
	        LATBbits.LATB8 = ( valor_adc & 0b0000000100000000 ) >> 8;
	        LATBbits.LATB10 =( valor_adc & 0b0000000010000000 ) >> 7;
	        LATBbits.LATB6 = ( valor_adc & 0b0000000001000000 ) >> 6;
	        LATBbits.LATB5 = ( valor_adc & 0b0000000000100000 ) >> 5;
	        LATBbits.LATB4 = ( valor_adc & 0b0000000000010000 ) >> 4;
	        LATBbits.LATB3 = ( valor_adc & 0b0000000000001000 ) >> 3;
	        LATBbits.LATB2 = ( valor_adc & 0b0000000000000100 ) >> 2;
	        LATBbits.LATB1 = ( valor_adc & 0b0000000000000010 ) >> 1;
	        LATBbits.LATB0 = ( valor_adc & 0b0000000000000001 ) >> 0;
	    }
	    else if( estado == 1 )  {
	    
	        for ( k = ( M - 1 ) ; k >= 1 ; k-- )  {
	            x[ k ] = x[ k - 1 ];
	        }

	        x[ 0 ] = ( ( float )ADC1BUF0 );

	        yn = 0;

	        for ( k = 0 ; k < M ; k++ )  {
	            yn += h[ k ] * x[ k ];  // yn = yn + h[ k ] * x[ k ];
	        }

	        valor_filtrado = yn;
	    
	        LATBbits.LATB9 = ( (unsigned int)valor_filtrado & 0b0000001000000000 ) >> 9;
	        LATBbits.LATB8 = ( (unsigned int)valor_filtrado & 0b0000000100000000 ) >> 8;
	        LATBbits.LATB10 = ( (unsigned int)valor_filtrado & 0b0000000010000000 ) >> 7;
	        LATBbits.LATB6 = ( (unsigned int)valor_filtrado & 0b0000000001000000 ) >> 6;
	        LATBbits.LATB5 = ( (unsigned int)valor_filtrado & 0b0000000000100000 ) >> 5;
	        LATBbits.LATB4 = ( (unsigned int)valor_filtrado & 0b0000000000010000 ) >> 4;
	        LATBbits.LATB3 = ( (unsigned int)valor_filtrado & 0b0000000000001000 ) >> 3;
	        LATBbits.LATB2 = ( (unsigned int)valor_filtrado & 0b0000000000000100 ) >> 2;
	        LATBbits.LATB1 = ( (unsigned int)valor_filtrado & 0b0000000000000010 ) >> 1;
	        LATBbits.LATB0 = ( (unsigned int)valor_filtrado & 0b0000000000000001 ) >> 0;
	    }
	    else if( estado == 2 )  {
	    
	        valor_adc = ADC1BUF0 - 512;

	        if ( valor_adc <= 0 )  {
	            valor_adc = 0;
	        }

	        LATBbits.LATB9 = ( valor_adc & 0b0000001000000000 ) >> 9;
	        LATBbits.LATB8 = ( valor_adc & 0b0000000100000000 ) >> 8;
	        LATBbits.LATB10 =( valor_adc & 0b0000000010000000 ) >> 7;
	        LATBbits.LATB6 = ( valor_adc & 0b0000000001000000 ) >> 6;
	        LATBbits.LATB5 = ( valor_adc & 0b0000000000100000 ) >> 5;
	        LATBbits.LATB4 = ( valor_adc & 0b0000000000010000 ) >> 4;
	        LATBbits.LATB3 = ( valor_adc & 0b0000000000001000 ) >> 3;
	        LATBbits.LATB2 = ( valor_adc & 0b0000000000000100 ) >> 2;
	        LATBbits.LATB1 = ( valor_adc & 0b0000000000000010 ) >> 1;
	        LATBbits.LATB0 = ( valor_adc & 0b0000000000000001 ) >> 0;
	    
	    }
	    else  {

	    }
	}

	void interrupcion_int0() org 0x0014  {

	    IFS0bits.INT0IF = 0;

	    estado += 1;
	    
	    if ( estado > 2 )  {
	        estado = 0;
	    }
	}

	void main()  {

	    calcularCoeficientes();
	    
	    config_puertos();
	    config_timer2();
	    config_adc();
	    
	    estado = 0;

	    IEC0bits.AD1IE = 1;
	    IEC0bits.T2IE = 1;
	    IEC0bits.INT0IE = 1;

	    AD1CON1bits.ADON = 1;
	    T2CONbits.TON = 1;

	    while( 1 )  {  }
	}



.. figure:: images/clase14/Filtro_a_manopla.BMP



Ejemplo 3:
==========

.. code-block:: c

	const unsigned BUFFFER_SIZE  = 32;
	const unsigned FILTER_ORDER  = 30;

	const unsigned COEFF_PB30Hz_1kHz[ FILTER_ORDER + 1 ] = {
	    0x0022, 0x0041, 0x007B, 0x00E1, 0x0182, 0x0267,
	    0x0393, 0x0500, 0x06A1, 0x0862, 0x0A27, 0x0BD3,
	    0x0D47, 0x0E67, 0x0F1E, 0x0F5C, 0x0F1E, 0x0E67,
	    0x0D47, 0x0BD3, 0x0A27, 0x0862, 0x06A1, 0x0500,
	    0x0393, 0x0267, 0x0182, 0x00E1, 0x007B, 0x0041,
	    0x0022 };

	const unsigned COEFF_PA80Hz_1kHz[ FILTER_ORDER + 1 ] = {
	      0xFFCB, 0xFFD2, 0xFFE8, 0x0024, 0x0097, 0x0134,
	      0x01C5, 0x01EE, 0x0143, 0xFF6B, 0xFC50, 0xF830,
	      0xF3A3, 0xEF7C, 0xEC92, 0x6B85, 0xEC92, 0xEF7C,
	      0xF3A3, 0xF830, 0xFC50, 0xFF6B, 0x0143, 0x01EE,
	      0x01C5, 0x0134, 0x0097, 0x0024, 0xFFE8, 0xFFD2,
	      0xFFCB};

	unsigned inext;                       // Input buffer index
	ydata unsigned input[ BUFFFER_SIZE ];   // Input buffer, must be in Y data space

	#define FRECUENCIA_MUESTREO 1000

	void config_puertos()  {

	    TRISAbits.TRISA0 = 1;  // Entrada AN0
	    
	    TRISBbits.TRISB12 = 1;  // Para aplicar o no algun filtro
	    TRISBbits.TRISB15 = 1;  // HIGH para Pasa bajos y LOW para Pasa altos

	    TRISBbits.TRISB9 = 0;  // Mas significativo
	    TRISBbits.TRISB8 = 0;
	    TRISBbits.TRISB7 = 0;
	    TRISBbits.TRISB6 = 0;
	    TRISBbits.TRISB5 = 0;
	    TRISBbits.TRISB4 = 0;
	    TRISBbits.TRISB3 = 0;
	    TRISBbits.TRISB2 = 0;
	    TRISBbits.TRISB1 = 0;
	    TRISBbits.TRISB0 = 0;  // Menos significativo

	    TRISBbits.TRISB14 = 0;  // debug_timer
	    TRISBbits.TRISB15 = 0;  // debug_adc
	}

	void config_timer2()  {
	    PR2 = 1 / ( FRECUENCIA_MUESTREO * 0.0000002 );
	}

	void config_adc()  {
	    ADPCFG = 0xFFFE; // AN0 como entrada analogica

	    // Muestreo la entrada analogica AN0
	    AD1CHS0 = 0b0000;

	    AD1CON1bits.AD12B = 0;  // ADC de 10 bits
	    AD1CON1bits.FORM = 0b00;  // Formato de salida entero

	    IEC0bits.AD1IE = 1;
	}

	void interrupcion_timer2() org 0x0022  {
	    IFS0bits.T2IF = 0;

	    LATBbits.LATB14 = ~LATBbits.LATB14;  // debug_timer

	    AD1CON1bits.DONE = 0;  // Antes de pedir una muestra ponemos en cero
	    AD1CON1bits.SAMP = 1;  // Pedimos una muestra

	    asm nop;  // Tiempo que debemos esperar para que tome una muestra

	    AD1CON1bits.SAMP = 0;  // Pedimos que retenga la muestra
	}

	void interrupcion_adc() org 0x002e  {
	    unsigned valor_filtrado;

	    IFS0bits.AD1IF = 0;

	    LATBbits.LATB15 = ~LATBbits.LATB15;  // debug_adc
	    
	    //RB12 para habilitar filtros
	    if( PORTBbits.RB12 == 1 )  {
	    
	        input[ inext ] = ADCBUF0;                 // Fetch sample
	        
	        if( PORTBbits.RB15 == 1 )  {
	            valor_filtrado = FIR_Radix( FILTER_ORDER + 1,  // Filter order
	                                        COEFF_PB30Hz_1kHz, // b coefficients of the filter
	                                        BUFFFER_SIZE,      // Input buffer length
	                                        input,             // Input buffer
	                                        inext );           // Current sample
	        }
	        else  {
	            valor_filtrado = FIR_Radix( FILTER_ORDER + 1,  // Filter order
	                                        COEFF_PA80Hz_1kHz, // b coefficients of the filter
	                                        BUFFFER_SIZE,      // Input buffer length
	                                        input,             // Input buffer
	                                        inext );           // Current sample
	        }

	        inext = ( inext + 1 ) & ( BUFFFER_SIZE - 1 );  // inext = (inext + 1) mod BUFFFER_SIZE;
	        
	        valor_filtrado = valor_filtrado;

	        LATBbits.LATB9 = ( (unsigned int)valor_filtrado & 0b0000001000000000 ) >> 9;
	        LATBbits.LATB8 = ( (unsigned int)valor_filtrado & 0b0000000100000000 ) >> 8;
	        LATBbits.LATB7 = ( (unsigned int)valor_filtrado & 0b0000000010000000 ) >> 7;
	        LATBbits.LATB6 = ( (unsigned int)valor_filtrado & 0b0000000001000000 ) >> 6;
	        LATBbits.LATB5 = ( (unsigned int)valor_filtrado & 0b0000000000100000 ) >> 5;
	        LATBbits.LATB4 = ( (unsigned int)valor_filtrado & 0b0000000000010000 ) >> 4;
	        LATBbits.LATB3 = ( (unsigned int)valor_filtrado & 0b0000000000001000 ) >> 3;
	        LATBbits.LATB2 = ( (unsigned int)valor_filtrado & 0b0000000000000100 ) >> 2;
	        LATBbits.LATB1 = ( (unsigned int)valor_filtrado & 0b0000000000000010 ) >> 1;
	        LATBbits.LATB0 = ( (unsigned int)valor_filtrado & 0b0000000000000001 ) >> 0;
	    }
	    else  {
	        LATBbits.LATB9 = ADCBUF0.B9;
	        LATBbits.LATB8 = ADCBUF0.B8;
	        LATBbits.LATB7 = ADCBUF0.B7;
	        LATBbits.LATB6 = ADCBUF0.B6;
	        LATBbits.LATB5 = ADCBUF0.B5;
	        LATBbits.LATB4 = ADCBUF0.B4;
	        LATBbits.LATB3 = ADCBUF0.B3;
	        LATBbits.LATB2 = ADCBUF0.B2;
	        LATBbits.LATB1 = ADCBUF0.B1;
	        LATBbits.LATB0 = ADCBUF0.B0;
	    }

	}

	void main()  {

	    config_puertos();
	    config_timer2();
	    config_adc();

	    IEC0bits.AD1IE = 1;
	    IEC0bits.T2IE = 1;

	    AD1CON1bits.ADON = 1;
	    T2CONbits.TON = 1;

	    while( 1 )  {  }
	}