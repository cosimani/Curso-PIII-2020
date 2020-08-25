.. -*- coding: utf-8 -*-

.. _rcs_subversion:

Clase 08 - PIII 2019
====================
(Fecha: 13 de septiembre)



Ejemplo: ADC controlando los momentos de muestreo con señal cuadrada externa
========

- Para dsPIC33FJ32MC202
- Con flanco descendente de la señal cuadrada en el pin INT0
- Cristal de 10MHz
- ADC de 10 bits
- Entrada analógica en AN0

.. code-block::

	void config_adc()  {
	    ADPCFG = 0xFFFE; // Elije la entrada analogica a convertir en este caso AN0.
	    // Con cero se indica entrada analogica y con 1 sigue siendo entrada digital.

	    AD1CON1bits.ADON = 0;  // ADC apagado por ahora
	    AD1CON1bits.AD12B = 0;  // ADC de 10 bits
	    AD1CON1bits.FORM = 0b00;  // Formato de salida entero

	    // Para tomar muestras en forma manual. Porque lo vamos a controlar con senal externa en INT0
	    AD1CON1bits.SSRC = 0b000;

	    // Adquiere muestra cuando el SAMP se pone en 1. SAMP lo controlamos desde INT0
	    AD1CON1bits.ASAM = 0;

	    AD1CON2bits.VCFG = 0b000;  // Referencia con AVdd y AVss
	    AD1CON2bits.SMPI = 0b0000;  // Lanza interrupción luego de tomar n muestras.
	    // Con SMPI=0b0000 -> 1 muestra ; Con SMPI=0b0001 -> 2 muestras ; SMPI=0b0010 -> 3 ; etc.

	    // AD1CON3 no se usa ya que usamos muestreo manual

	    // Muestreo la entrada analogica AN0 contra el nivel de AVss (AN0 es S/H+ y AVss es S/H-)
	    AD1CHS0 = 0b0000;
	}

	void config_int0()  {
	    INTCON2bits.INT0EP = 1;  // 0 para Ascendente y 1 para Descendente
	}

	void config_ports()  {

	    TRISAbits.TRISA0 = 1;  // Entrada analogica para muestrear / AN0

	    // Elegimos los puertos RB0-RB6 y RB8-RB10
	    TRISBbits.TRISB0 = 0;  // Menos significativo
	    TRISBbits.TRISB1 = 0;
	    TRISBbits.TRISB2 = 0;
	    TRISBbits.TRISB3 = 0;
	    TRISBbits.TRISB4 = 0;
	    TRISBbits.TRISB5 = 0;
	    TRISBbits.TRISB6 = 0;
	    TRISBbits.TRISB8 = 0;
	    TRISBbits.TRISB9 = 0;
	    TRISBbits.TRISB10 = 0;  // Mas significativo

	    TRISBbits.TRISB7 = 1;  // Es el pin de la INT0

	    TRISBbits.TRISB11 = 0;  // Para debug ADC
	    TRISBbits.TRISB12 = 0;  // Para debug INT0
	}

	void detect_int0() org 0x0014  {
	    IFS0bits.INT0IF=0;  // Borramos la bandera de interrupción INT0

	    LATBbits.LATB12 = !LATBbits.LATB12;  // Para debug de la interrupcion INT0

	    AD1CON1bits.DONE = 0;  // Antes de pedir una muestra ponemos en cero
	    AD1CON1bits.SAMP = 1;  // Pedimos una muestra

	    asm nop;  // Tiempo que debemos esperar para que tome una muestra

	    AD1CON1bits.SAMP = 0;  // Pedimos que retenga la muestra
	}

	void detect_adc() org 0x002e  {

	    IFS0bits.AD1IF = 0; // Borramos el flag de interrupciones del ADC

	    LATBbits.LATB11 = !LATBbits.LATB11;  // Para debug de la interrupcion ADC

	    // Almacenamos los 8 bits más significativos
	    LATBbits.LATB0 = ADCBUF0.B0;
	    LATBbits.LATB1 = ADCBUF0.B1;
	    LATBbits.LATB2 = ADCBUF0.B2;
	    LATBbits.LATB3 = ADCBUF0.B3;
	    LATBbits.LATB4 = ADCBUF0.B4;
	    LATBbits.LATB5 = ADCBUF0.B5;
	    LATBbits.LATB6 = ADCBUF0.B6;
	    LATBbits.LATB8 = ADCBUF0.B7;
	    LATBbits.LATB9 = ADCBUF0.B8;
	    LATBbits.LATB10 = ADCBUF0.B9;
	}

	int main()  {
	    config_ports();
	    config_int0();
	    config_adc();

	    IEC0bits.INT0IE = 1;  // Habilitamos la interrupcion INT0

	    IEC0bits.AD1IE = 1;  // Habilitamos interrupción del ADC

	    AD1CON1bits.ADON = 1;  // Encendemos el ADC

	    while(1)  {  }

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


Ejercicio:
==========

- Adaptarlo para llevarlo a la placa Easy dsPIC con el dsPIC30F4013



Recomendaciones para crear un proyecto
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- Crear carpeta en disco ( C:/UBP/PIII/NombreProyecto )
- Nomenclatura de ejemplo para NombreProyecto
	- P30F_Ej05
	- P33F_Ej12
	- P33F_Generador100Hz
	- P33F_AlgunaDescripcion
- Dentro de esta carpeta crear las carpetas Proteus y MikroC para los 33F o sólo la carpeta MikroC para los 30F.
- Abrir mikroC -- New Porject -- Standard project -- Next
- Project Name: P33F_Ej12 (Notar que estamos colocando el mismo nombre que la carpeta)
- Project folder: C:/UBP/PIII/P33F_Ej12/MikroC
- Device Name: P33FJ32MC202
- Next -- Include None -- Finish
- Al guardar y compilar este proyecto, entre todos los archivos que se generan, los siguientes son los más importantes:
	- P33F_Ej12.mcdps - Archivo de configuración del proyecto. 
	- P33F_Ej12.c - Código fuente en C (Es el código escrito por nosotros)
	- P33F_Ej12.asm - Código fuente en assembler (se autogenera al compilar el proyecto)
	- P33F_Ej12.hex - Usado para programar el dsPIC (se autogenera al compilar el proyecto)
- Escribir el programa. No olvidar lo siguiente:
	- Edit Project ( para ajustar el PLL )
	- Estilo de indentación: Ubicación de llaves, sangría adecuada, espacios, etc..
	- Elección apropiada para nombres de variables y funciones.

- Abrir Proteus ( sólo para los 33F )
- Al guardar el diseño, almacenarlo con el mismo nombre del proyecto ( por ejemplo: P33F_Ej12.DSN )
- En Proteus 7.9, el archivo P33F_Ej12.DSN contiene todo lo referido al proyecto
- En la carpeta C:/UBP/PIII/P33F_Ej12/Proteus

