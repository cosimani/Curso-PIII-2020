.. -*- coding: utf-8 -*-

.. _rcs_subversion:

Clase 11 - PIII 2020
====================
(Fecha: 2 de octubre)

Revisión de los trabajos prácticos
==================================


ADC controlando los momentos de muestreo con el Timer2	
======================================================

.. figure:: images/clase04/ejemplo_adc1.png

.. figure:: images/clase04/ejemplo_adc2.png

**Código fuente**

.. code-block::

	void initADC()  {
	    ADPCFG = 0xFFFE; // Elije la entrada analógica a convertir en este caso AN0.
	    // Con cero se indica entrada analógica y con 1 sigue siendo entrada digital.

	    ADCON1bits.ADON = 0;  // ADC Apagado por ahora
	    ADCON1bits.ADSIDL = 1;  // No trabaja en modo idle
	    ADCON1bits.FORM = 0b00;  // Formato de salida entero
	    // Para tomar muestras en forma manual. Porque lo vamos a controlar con timer2
	    ADCON1bits.SSRC = 0b000;  
	    // Adquiere muestra cuando el SAMP se pone en 1. SAMP lo controlamos desde el Timer2.
	    ADCON1bits.ASAM = 0;  

	    ADCON2bits.VCFG = 0b000;  // Referencia con AVdd y AVss
	    ADCON2bits.SMPI = 0b0000;  // Lanza interrupción luego de tomar n muestras.
	    // Con SMPI=0b0 -> 1 muestra ; Con SMPI=0b1 -> 2 muestras ; Con SMPI=0b10 -> 3 muestras ; etc.

	    // AD1CON3 no se usa ya que tenemos deshabilitado el cálculo del muestreo con ADCS etc.

	    // Muestreo la entrada analógica AN0 contra el nivel de AVss (AN0 es S/H+ y AVss es S/H-)
	    ADCHS = 0b0000;  

	    ADCON1bits.ADON = 1;// Habilitamos el A/D
	}

	void detectarIntT2() org 0x0020  {
	    IFS0bits.T2IF=0;  // Borramos la bandera de interrupción T2

	    ADCON1bits.DONE = 0;  // Antes de pedir una muestra ponemos en cero
	    ADCON1bits.SAMP = 1;  // Pedimos una muestra

	    asm nop;

	    ADCON1bits.SAMP = 0;  // Pedimos que retenga la muestra
	}

	void interrupcionADC() org 0x002a  {

	    LATCbits.LATC14 = !LATCbits.LATC14;  // Para debug y ver si ingresa acá

	    // Almacenamos los 8 bits más significativos
	    LATBbits.LATB1 = ADCBUF0.B2;
	    LATBbits.LATB2 = ADCBUF0.B3;
	    LATBbits.LATB3 = ADCBUF0.B4;
	    LATBbits.LATB4 = ADCBUF0.B5;
	    LATBbits.LATB5 = ADCBUF0.B6;
	    LATEbits.LATE0 = ADCBUF0.B7;
	    LATEbits.LATE1 = ADCBUF0.B8;
	    LATEbits.LATE2 = ADCBUF0.B9;

	    IFS0bits.ADIF = 0; // Borramos el flag de interrupciones
	}

	int main()  {

	    // Elegimos el puerto B y E para la salida digital.
	    // Ya que no alcanzan los pines para que todo salga por un único puerto
	    TRISB = 0;
	    TRISE = 0;

	    TRISCbits.TRISC14 = 0;  // Para debug nomás

	    // Configuramos el módulo ADC
	    initADC();

	    IEC0bits.ADIE = 1;  // Habilitamos interrupción del A/D

	    // Modo de operación Timer2 - Con el clock interno
	    T2CON = 0x0000;

	    // Prescaler para timer
	    // 00 -> 1:1 - 01 -> 1:8 - 10 -> 1:64 - 11 -> 1:256
	    T2CONbits.TCKPS = 0b01;

	    TMR2 = 0;
	    PR2 = 7;

	    IEC0bits.T2IE = 1;  // Habilita interrupciones timer2

	    // Arrancamos el timer2
	    T2CONbits.TON = 1;

	    while( 1 )  {  }

	    return 0;
	}
	
Ejemplo
^^^^^^^

.. figure:: images/clase06/primer_parcial_1.png
   :target: images/clase06/primer_parcial_1.pdf
   
**Resolución**

.. figure:: images/clase06/primer_parcial_1_proteus.png
   :target: resources/clase06/parcial_1_v1.rar
   
.. code-block:: c
   
	void config_adc()  {
		ADPCFG = 0xFFF7; // La entrada analogica es el AN3 (pin 5)
		// Con cero se indica entrada analogica y con 1 sigue siendo entrada digital.

		AD1CON1bits.ADON = 0;  // ADC apagado por ahora
		AD1CON1bits.AD12B = 0;  // ADC de 10 bits
		AD1CON1bits.FORM = 0b00;  // Formato de salida entero

		// Tomar muestras en forma manual, porque lo vamos a controlar con el Timer 2
		AD1CON1bits.SSRC = 0b000;

		// Adquiere muestra cuando el SAMP se pone en 1. SAMP lo controlamos desde el Timer 2
		AD1CON1bits.ASAM = 0;

		AD1CON2bits.VCFG = 0b011;  // Referencia con fuente externa VRef+ y VRef-
		AD1CON2bits.SMPI = 0b0000;  // Lanza interrupción luego de tomar n muestras.
		// Con SMPI=0b0000 -> 1 muestra ; Con SMPI=0b0001 -> 2 muestras ; SMPI=0b0010 -> 3 ; etc.

		// AD1CON3 no se usa ya que usamos muestreo manual

		// Muestreo la entrada analogica AN3 contra el nivel de VRef+ y VRef-
		AD1CHS0 = 0b00011;
	}

	void config_timer2()  {
		// Prescaler 1:1   -> TCKPS = 0b00 -> Incrementa 1 en un ciclo de instruccion
		// Prescaler 1:8   -> TCKPS = 0b01 -> Incrementa 1 en 8 ciclos de instruccion
		// Prescaler 1:64  -> TCKPS = 0b10 -> Incrementa 1 en 64 ciclos de instruccion
		// Prescaler 1:256 -> TCKPS = 0b11 -> Incrementa 1 en 256 ciclos de instruccion
		T2CONbits.TCKPS = 0b00;

		// Empieza cuenta en 0
		TMR2=0;

		// Cuenta hasta 5000 ciclos y dispara interrupcion
		PR2=5000;  // 5000 * 200 nseg = 1 mseg   ->  1 / 1mseg = 1000Hz
	}

	void config_ports()  {
		TRISAbits.TRISA3 = 1;  // Entrada para muestrear = AN3

		// Elegimos los puertos RB2-RB11 para la salida digital
		TRISBbits.TRISB2 = 0;  // Menos significativo
		TRISBbits.TRISB3 = 0;
		TRISBbits.TRISB4 = 0;
		TRISBbits.TRISB5 = 0;
		TRISBbits.TRISB6 = 0;
		TRISBbits.TRISB7 = 0;
		TRISBbits.TRISB8 = 0;
		TRISBbits.TRISB9 = 0;
		TRISBbits.TRISB10 = 0;
		TRISBbits.TRISB11 = 0;  // Mas significativo

		TRISBbits.TRISB13 = 0;  // Para debug Timer 2
		TRISBbits.TRISB14 = 0;  // Para debug ADC
	}

	void detect_timer2() org 0x0022  {
		IFS0bits.T2IF=0;  // Borramos la bandera de interrupción Timer 2

		LATBbits.LATB13 = !LATBbits.LATB13;  // Para debug de la interrupcion Timer 2

		AD1CON1bits.DONE = 0;  // Antes de pedir una muestra ponemos en cero
		AD1CON1bits.SAMP = 1;  // Pedimos una muestra

		asm nop;  // Tiempo que debemos esperar para que tome una muestra

		AD1CON1bits.SAMP = 0;  // Pedimos que retenga la muestra
	}

	void detect_adc() org 0x002e  {
		IFS0bits.AD1IF = 0; // Borramos el flag de interrupciones del ADC

		LATBbits.LATB14 = !LATBbits.LATB14;  // Para debug de la interrupcion ADC

		// Almacenamos los 10 bits del ADC
		LATBbits.LATB2 = ADCBUF0.B0;
		LATBbits.LATB3 = ADCBUF0.B1;
		LATBbits.LATB4 = ADCBUF0.B2;
		LATBbits.LATB5 = ADCBUF0.B3;
		LATBbits.LATB6 = ADCBUF0.B4;
		LATBbits.LATB7 = ADCBUF0.B5;
		LATBbits.LATB8 = ADCBUF0.B6;
		LATBbits.LATB9 = ADCBUF0.B7;
		LATBbits.LATB10 = ADCBUF0.B8;
		LATBbits.LATB11 = ADCBUF0.B9;
	}

	int main()  {
		config_ports();
		config_timer2();
		config_adc();

		// Habilitamos interrupción del ADC y lo encendemos
		IEC0bits.AD1IE = 1;
		AD1CON1bits.ADON = 1;

		// Habilita interrupción del Timer 2 y lo iniciamos para que comience a contar
		IEC0bits.T2IE=1;
		T2CONbits.TON=1;

		while(1)  {  }

		return 0;
	}

