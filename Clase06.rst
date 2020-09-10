.. -*- coding: utf-8 -*-

.. _rcs_subversion:

Clase 06 - PIII 2020
====================
(Fecha: 11 de septiembre)


**Pinout de los dsPIC que utilizaremos**

.. figure:: images/clase05/dspic33fj32mc202.png
   :target: http://ww1.microchip.com/downloads/en/DeviceDoc/70283K.pdf

.. figure:: images/clase05/dspic30f4013.png
   :target: http://ww1.microchip.com/downloads/en/devicedoc/70138c.pdf
   
.. figure:: images/clase05/dspic30f3010.png
   :target: http://ww1.microchip.com/downloads/en/DeviceDoc/70141F.pdf

.. figure:: images/clase05/dspic30f4011.jpg
   :target: http://ww1.microchip.com/downloads/en/devicedoc/70135C.pdf



Ejercicio 4
===========

- Crear un programa con lo siguiente:
- Usar el dsPIC33FJ32MC202 
- Interrupción externa INT1
- Flanco descendente
- Pulsador en INT1 con resistencia en Pull up.
- Resolver el problema de no tener un pin para la INT1
- Ver el siguiente `Link <http://download.mikroe.com/documents/compilers/mikroc/dspic/help/peripheral_pin_select_library.htm>`_


Ejercicio 5
===========

- Regulador de tensión para los dsPIC33F.
- Alimentación desde un conector USB.
- Utilizar herramientas de medición para asegurarse de los voltajes obtenidos.


Ejercicio 6
===========

- Alimentar el dsPIC33FJ32MC202.
- Conectar el Master Clear
- Utilizar capacitores de desacoplo
- Conectar un cristal de cuarzo
- Grabarle un programa creado anteriormente

**Deseñar en Proteus**

- New Design
- Component mode (panel izquierdo)
- P (Pick Device) - permite seleccionar los componentes a utilizar en este proyecto
	- DSPIC33FJ32MC202
	- USBCONN
	- LM317L
	- A700 (es el prefijo de capacitores electrolíticos de alto valor)
	- CAP-ELEC - Capacitores electrolíticos generales
	- POT-HG - Potenciómetro
	- RES - Resistencia
	- LED-RED
	- CRYSTAL
- Terminals Mode - Permite agregar tierra, entrada, salida, etc.
	- GROUND

**Regulador de tensión 3.3v (esto para los dsPIC33F)**

.. figure:: images/clase01/regulador.png




.. figure:: images/clase04/manejo_timers.png

**Ejercicio:** Probar cada una de estas afirmaciones (tomamos como ejemplo el Timer2):

- El Timer2 puede acumular pulsos tanto externos (TCS=1) a través del pin T1CK, como internos (TCS=0) al ritmo de la Frecuencia de instrucciones (Tcy).
- Acumulador de pulsos altos en TGate: puede contar los pulsos internos (Tcy) sólo cuando el pin externo T2CK esté a nivel alto, lo que permite contar la duración acumulada de una señal a nivel alto. Para seleccionar este modo hay que poner a 1 los bits TCS y TGATE.
- El interruptor que nos permite encender y apagar el Timer2 es el bit TON. 
- Los impulsos atraviesan el prescaler donde es dividido a razón de 1:1, 1:8, 1:64 y 1:256 en función de la combinación seleccionada en los bits TCKPS<1:0>.
- Se incrementa en una unidad el registro TMR2. En función del bit de configuración TSYNC, si su valor es 1 el incremento de dicho registro será sincronizado con una señal externa. Cada vez que se incrementa el registro TMR2, se compara con el registro PR2 y en caso de igualdad se pone a 0 el TMR2 y se señala el bit de interrupción T2IF. El registro PR2 por defecto vale 0xFFFF con lo que el periodo del Timer2 será ese, pero podemos ajustarlo al valor que queramos, lo que nos permite seleccionar una frecuencia de interrupción programable muy útil.
- Para hacerlos trabajar a 32 bits hay que poner a 1 el bit T32. En este caso, los bits de configuración del Timer de 32 bits serán los del Timer par; es decir, si queremos trabajar con la pareja Timer 2/3 hay que setear los bits del Timer2, incluyendo el bit T32=1.
- El bit de señalización de fin de periodo será el del Timer impar, en nuestro ejemplo se activará el bit T3IF. En el modo de trabajo a 32 bits, la palabra alta la forma el registro TMR impar y la palabra baja el TMR par.



.. figure:: images/clase04/map_timer1.png
   :target: http://ww1.microchip.com/downloads/en/devicedoc/70138c.pdf

.. figure:: images/clase04/map_timer23.png
   :target: http://ww1.microchip.com/downloads/en/devicedoc/70138c.pdf

.. figure:: images/clase04/map_timer45.png
   :target: http://ww1.microchip.com/downloads/en/devicedoc/70138c.pdf

.. figure:: images/clase04/ejemplo.png

.. code-block::

	void detectarIntT1() org 0x001a  {
	    LATBbits.LATB0 = !LATBbits.LATB0;
	    IFS0bits.T1IF = 0;  // Borramos la bandera de interrupción T1
	}

	void main()  {
	    TRISBbits.TRISB0 = 0;
	    LATBbits.LATB0 = 0;

	    // Modo de operación Timer1
	    T1CON = 0x0000;

	    // Modo operación Timer1: reloj interno, escala 1:1, empieza cuenta en 0
	    TMR1 = 0;

	    // Cuenta 500 ciclos
	    PR1 = 500;

	    // Interrupciones Timer1, borra Bandera de interrupción
	    IFS0bits.T1IF = 0;

	    // Habilita interrupción
	    IEC0bits.T1IE = 1;

	    // Arranca Timer1
	    T1CONbits.TON = 1;

	    while( 1 )
	       asm nop;
	}

**Ejercicio:** 

- Mejorar la solución para el ejercicio de los leds encendiendo a 250 us y 133 us.





