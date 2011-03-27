#!/bin/bash
rasp_conv="d"

echo "----"
echo "Se verifica fisier: $1"
echo "----"


#verific Copy text ... here, cauzat de un copy/paste aiurea in LP
grep "Copy text  " $1 > /dev/null
if [ $? -eq 0  ]; then
echo "EROARE: Fișierul conșine 'Copy text' - eroare din LP"
echo ""
fi

#verific daca are sedila
#sed nu merge cu unicode... la perl sunt probleme cu locale

echo "Doriți să fie convertite la sedilă? [D/n]"
read rasp_conv
    if [ "x$rasp_conv" != "xn" ]; then

    echo "Se efectuează conversia..."
    sed -i "s/ș/ş/g" $1
    sed -i "s/Ș/Ş/g" $1
    sed -i "s/Ț/Ţ/g" $1
    sed -i "s/ț/ţ/g" $1
    echo "Conversie finalizată"
    fi

#la final verific validitatea fisierului si acceleratorii
echo "Se verifică validitatea fișierului... "
msgfmt -v -o /dev/null -c --check-accelerators=_ $1

echo "----"
echo "Finalizat"