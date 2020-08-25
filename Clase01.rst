.. -*- coding: utf-8 -*-

.. _rcs_subversion:

Clase 01 - PIII 2019
====================
(Fecha: 14 de agosto)

:Autor: César Osimani - Martín Salamero
:Correo: cesarosimani@gmail.com - martin.salamero@gmail.com
:Fecha: 14 de agosto de 2019
:Regularidad: 
	- 2 parciales (resolviendo ejercicios con Proteus y mikroC)

	- 3er nota (promedio de los prácticos con Martín)

	- No tiene promoción

	- Proyecto final: Individual o 2 alumnos 
	
	- El proyecto final se tiene que ir confeccionando durante el cursado de la materia.
	
:Final:
	- Entrega del proyecto final para la nota final de la materia
	- Cada alumno se evalúa individualmente por más que forme grupo con otro alumno.
:Temas principales: 
  	- Arquitectura de los DSP (Digital Signal Processor)
	- Programación en C de los dsPIC30F y dsPIC33F
	- Utilización de software para la programación y simulación
	- Utilización de placa de desarrollo
	- Puertos de entrada, Conversor A/D, muestreo
	- Puertos de salida, Conversor D/A
	- Generador de señales, FFT, Filtros
:Ideas para trabajo final:
	- Control a distancia por tonos DTMF  (Dual-Tone Multi-Frequency) 
	- Efectos para instrumentos musicales
	- Distorsión de la voz en tiempo real para hablar sin ser reconocido
	- dsPIC conectado a la PC por puerto serie USB
	- Afinador de instrumentos
	- Ecualizador y eliminador de ruidos
	- Desarrollo de placas de prueba

Introducción
============

- Brinda al estudiante herramientas de programación de microcontroladores para el procesamiento digital de señales.
- Conocimientos sobre programación de hardware específico para tratamiento de señales.
- Complementa lo desarrollado en "Teoría de Señales y Sistemas Lineales" y "Tratamiento Digital de Señales". 


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
	- PIC de 16 bits (registros de 16 bits)
	- Estudiaremos las familias dsPIC30F y dsPIC33F
	- Se pueden conseguir en Córdoba los siguientes: 
	#. dsPIC30F4013 (40 pines)
 	#. dsPIC30F2010 (28 pines)
	#. dsPIC33FJ32MC202 (28 pines)

Softwares
---------
- Proteus
- mikroC para dsPIC

*Proteus*
	- Conjunto de programas para diseño y simulación
	- Desarrollado por Labcenter Electronics (http://www.labcenter.com)
	- Versión actual: 8.7
	- Versión 8.1 para compartir. Algunos problemas con Windows 7
	- Versión 7.9 para compartir. Estable para XP, Windows 7 y Windows 8
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
	
