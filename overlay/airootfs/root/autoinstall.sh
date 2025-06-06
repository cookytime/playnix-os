#!/bin/bash
# Ejecutar archinstall con JSON preconfigurado
archinstall --config /root/my-archinstall.json --no-block --yes

# Tareas adicionales tras la instalación
# Ejemplo: copiar archivos de configuración a la nueva instalación montada en /mnt
cp /root/extra-configs/*.service /mnt/etc/systemd/system/
# Otros comandos según necesidades...

# Finalizar (opcional: reiniciar o apagar)
# reboot
