
# Obtener los entrenamientos que prometen buenos resultados
find -type d -name "*GOOD" | cut -d _ -f 2 | xargs  -I {} grep "training number is {}" ../log.log | grep "OBJECTS, obj1=1, objs2=1, objs3=1" | sort -n -k9 
