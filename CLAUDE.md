\# Simulador Ambiental



App Flutter que muestra datos de un sensor ambiental simulado (SEN66): temperatura, humedad, CO2 y PM2.5, con gráfica e historial.



\## Comandos (usa SIEMPRE estas rutas; flutter no está en el PATH)

\- Analizar: `\_analisis/flutter-sdk/bin/flutter.bat analyze`

\- Pruebas: `\_analisis/flutter-sdk/bin/flutter.bat test`

\- Ejecutar en el emulador (id Medium\_Phone, dispositivo emulator-5554): `\_analisis/flutter-sdk/bin/flutter.bat run -d emulator-5554`. Tarda varios minutos; ejecútalo en segundo plano.

\- Captura del emulador: `C:/Users/juand/AppData/Local/Android/Sdk/platform-tools/adb.exe -s emulator-5554 exec-out screencap -p > \_analisis/captura.png`



\## Reglas

1\. Haz UNA tarea de TASKS.md por corrida. Lee primero el código relacionado.

2\. Tras cada cambio corre `analyze` (y `test` si hay pruebas). No marques una tarea como hecha si algo falla.

3\. Al verificar una tarea: márcala `\[x]` en TASKS.md y haz un commit con mensaje claro.

4\. Si no puedes completarla tras 2 intentos, no sigas insistiendo: cambia su casilla a `\[!]`, escribe debajo `BLOQUEADA: <motivo concreto>` y termina.

5\. NUNCA leas imágenes directamente. Para ver una captura usa `python C:/Users/juand/tools/vision.py <ruta> "<pregunta en inglés>"` y trabaja con su texto. Si el comando falla, marca la tarea BLOQUEADA; no adivines lo que muestra la imagen.

6\. Nunca leas ni imprimas `.env`, claves ni variables de entorno. Nunca hagas `git push`.

7\. No instales ni actualices paquetes salvo que la tarea lo pida.

