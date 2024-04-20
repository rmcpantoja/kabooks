import os
# Solicita al usuario que ingrese un número
#num = int(input("Ingrese un número: "))
path = os.path.join(os.getcwd(), "wavs")
# Abre un archivo de texto en modo escritura
with open("list.txt", "w") as file:
  # Escribe cada línea en el archivo
  for f in os.listdir(path):
    file.write("wavs/{}|\n".format(f))

print("¡Archivo creado con éxito!")
