.. -*- coding: utf-8 -*-

.. _rcs_subversion:

Clase 10 - PIII 2019
====================
(Fecha: 25 de septiembre)



Ejercicio:
==========

- Generar una señal de 4Hz pensado para aplicar un efecto trémolo (variación periódica del volumen) a una señal de audio que está siendo muestreada a 4kHz.
- Si el array tiene demasiados valores, pensar en cómo se podría resolver sabiendo que una senoidal tiene simetría.

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


**Ejercicio:** Probar cada una de estas afirmaciones (tomamos como ejemplo el Timer2):

- El Timer2 puede acumular pulsos tanto externos (TCS=1) a través del pin T1CK, como internos (TCS=0) al ritmo de la Frecuencia de instrucciones (Tcy).
- Acumulador de pulsos altos en TGate: puede contar los pulsos internos (Tcy) sólo cuando el pin externo T2CK esté a nivel alto, lo que permite contar la duración acumulada de una señal a nivel alto. Para seleccionar este modo hay que poner a 1 los bits TCS y TGATE.
- El interruptor que nos permite encender y apagar el Timer2 es el bit TON. 
- Los impulsos atraviesan el prescaler donde es dividido a razón de 1:1, 1:8, 1:64 y 1:256 en función de la combinación seleccionada en los bits TCKPS<1:0>.
- Se incrementa en una unidad el registro TMR2. En función del bit de configuración TSYNC, si su valor es 1 el incremento de dicho registro será sincronizado con una señal externa. Cada vez que se incrementa el registro TMR2, se compara con el registro PR2 y en caso de igualdad se pone a 0 el TMR2 y se señala el bit de interrupción T2IF. El registro PR2 por defecto vale 0xFFFF con lo que el periodo del Timer2 será ese, pero podemos ajustarlo al valor que queramos, lo que nos permite seleccionar una frecuencia de interrupción programable muy útil.
- Para hacerlos trabajar a 32 bits hay que poner a 1 el bit T32. En este caso, los bits de configuración del Timer de 32 bits serán los del Timer par; es decir, si queremos trabajar con la pareja Timer 2/3 hay que setear los bits del Timer2, incluyendo el bit T32=1.
- El bit de señalización de fin de periodo será el del Timer impar, en nuestro ejemplo se activará el bit T3IF. En el modo de trabajo a 32 bits, la palabra alta la forma el registro TMR impar y la palabra baja el TMR par.


Ejercicio:
==========

- Generar una señal de 5Hz pensado para aplicar un efecto trémolo (variación periódica del volumen) a una señal de audio que está siendo muestreada a 1kHz.


Ejercicio:
==========

- Aplicar el trémolo de 5Hz a la señal generada de 100Hz.

.. figure:: images/clase07/captura_tremolo.png

Ejercicio:
==========

- Muestrear una señal de audio y aplicar el trémolo anterior.

Ejercicio:
==========

Muestrear una señal analógica (100 Hz, offset de 2 V y 4 Vpp), aplicarle un trémolo y mostrar la resultante luego de un DAC R-2R.

**Especificaciones:**

- Entrada por AN2
- Utilizar Vref+ y Vref- con valores óptimos
- Entíendase el trémolo como una señal modulante con la que se logra un índice de modulación particular
- Frecuencia de muestreo: 1 kHz
- ADC de 12 bits
- Frecuencia del trémolo: 8 Hz
- Hacer parecer a un índice de modulación del 50%


**Ejemplo que sirve de guía:** 

- `Solución de un ejercicio parecido en Proteus <https://github.com/cosimani/Curso-PIII-2016/blob/master/resources/clase06/Ej1.rar?raw=true>`_

.. figure:: images/clase06/Ej1-Esquema.png

.. figure:: images/clase06/Ej1-Osciloscopio.png


