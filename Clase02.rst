.. -*- coding: utf-8 -*-

.. _rcs_subversion:

Clase 02 - PIII 2019
====================
(Fecha: 16 de agosto)


**Ejercicio:** 

- Crear un programa "Hola mundo" para el dsPIC30F4013.
- Escribir una función void configuracionInicial() para configurar el puerto RB0 como salida
- En la función main encender y apagar un LED en RB0 cada 1 segundo
- Tener en cuenta que por defecto un nuevo proyecto en mikroC para el dsPIC30F4013 viene con XT w/PLL 8x
	

*Resolución*

.. code-block::

	void configuracionInicial()  {
	    TRISBbits.TRISB0 = 0;
	    LATBbits.LATB0 = 0;
	}

	void main()  {
	    configuracionInicial();

	    while (1)  {
	        LATBbits.LATB0 = ~PORTBbits.RB0;
	        Delay_ms(1000);
	    }
	}


