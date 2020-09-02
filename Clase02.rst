.. -*- coding: utf-8 -*-

.. _rcs_subversion:

Clase 02 - PIII 2020
====================
(Fecha: 28 de agosto)


Familias de microcontroladores Microchip
----------------------------------------

*MCU (MicroController Unit)*
	- Microcontroladores clásicos
	- Las operaciones complejas las realiza en varios ciclos
	
*DSP (Digital Signal Processor)*
	- Microcontroladores para procesamiento de señales
	- Las operaciones complejas las realiza en un sólo ciclo.

*DSC (Digital Signal Controller)*
	- Híbrido MCU/DSP
	- Controlador digital de señales
	
.. figure:: images/clase01/precio_rendimiento.png

*dsPIC (Nombre que utiliza Microchip para referirse a sus DSC)*
	- Registros de 16 bits
	- Familias dsPIC30F y dsPIC33F
	- Es accesible conseguir los siguientes: 
	#. dsPIC30F4013 (40 pines)
 	#. dsPIC30F2010 (28 pines)
	#. dsPIC33FJ32MC202 (28 pines)

Softwares
---------
- Proteus
- mikroC para dsPIC
- MATLAB

*Proteus*
	- Conjunto de programas para diseño y simulación
	- Desarrollado por Labcenter Electronics (http://www.labcenter.com)
	- Versión actual: 8.7
	- Versión 8.1 para compartir. Algunos problemas con Windows 10
	- Versión 7.9 para compartir. Estable para Windows 10
	- Herramientas principales: ISIS y ARES

*ISIS (Intelligent Schematic Input System - Sistema de Enrutado de Esquemas Inteligente)*
	- Permite diseñar el circuito con los componentes.
	- Permite el uso de microcontroladores grabados con nuestro propio programa.
	- Contiene herramientas de medición, fuentes de alimentación y generadores de señales.
	- Puede simular en tiempo real mediante VSM (Virtual System Modeling -Sistema Virtual de Modelado).

*ARES (Advanced Routing and Editing Software - Software de Edición y Ruteo Avanzado)*
	- Permite ubicar los componentes y rutea automáticamente para obtener el PCB (Printed Circuit Board).
	- Permite ver una visualización 3D de la placa con sus componentes.

*mikroC para dsPIC*
	- Compilador C para dsPIC
	- Incluye bibliotecas de programación
	- Última versión 7.1.0 (mayo de 2018)
	- Desarrollado por MikroElektronika ( https://www.mikroe.com/mikroc/#dspic )
	- MikroElektronika también dispone de placas de desarrollo como la Easy dsPIC que disponemos en el Lab
	
*MATLAB*
	- IDE con un lenguaje de programación propio.
	- Simulación, matrices, algoritmos, GUI, DSP, ...
	- Última versión R2020a (marzo de 2020).


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

	    while ( 1 )  {
	        LATBbits.LATB0 = ~LATBbits.LATB0;
	        Delay_ms( 1000 );
	    }
	}


