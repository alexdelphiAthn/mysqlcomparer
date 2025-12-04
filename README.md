Este es un generador de script por diferencias estructurales para MySQL / MariaDB usando UniDAC. 
El uso es muy sencillo. 

 DBComparer servidor1:puerto1\database1 usuario1\password1 servidor2:puerto2\database2 usuario2\password2 > script.sql

 Donde el servidor1.... es el origen de la comparación, donde están los datos más actuales y servidor2... es el destino. 
 Se genera el script, en el caso del ejemplo el script.sql donde estarán todos los cambios a integrar por database1. 
 He optado por recompilar todas las vistas y los procedimientos almacenados dada la dificultad que puede entrañar generar vistas o procedimientos por diferencias.

 Para integrar en un programa de gestión es verdaderamente útil, pues los scripts de actualización pueden llegar a convertirse en una verdadera pesadilla. 

 Mi nombre es Alejandro Laorden alejandro.laorden@gmail.com y agradezco vuestros comentarios y aportes.
