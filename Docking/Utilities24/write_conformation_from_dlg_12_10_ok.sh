#!/bin/bash

csplit -z *.dlg /'DOCKED: MODEL'/ {*}
rm xx00 #
for a in xx*; do echo $a;
   mv $a ${a%.dlg}_conformation_t.pdbqt
b=`cat -n ${a%.dlg}_conformation_t.pdbqt | grep "DOCKED: TER" | awk '{print $1}'`; echo $b; cat ${a%.dlg}_conformation_t.pdbqt | grep -A $b "DOCKED: MODEL" > ${a%.dlg}_conformation.pdbqt  
cut -c '9-' ${a%.dlg}_conformation.pdbqt > ${a%.dlg}_conformation_ok.pdbqt
done
rm -r *_conformation_t.pdbqt 
rm -r *_conformation.pdbqt 

#Debo hacer que todos se parseen en DOCKED: ENDMDL, CORRER cada uno hasta ENDMDL y guardarlos en el fichro con el nombre final...aclarar que si no aparece ENDMDL no se guarde el fichro
#get ... contar hasta grep -a el # de l'inea (contar hasta que aparece ENDMODEL y borrar el resto)
# Debo abrir la 'ultima conformaci'on y editarla.
 
#
#
#
#
#
#


