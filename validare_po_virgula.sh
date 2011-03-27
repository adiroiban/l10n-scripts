#!/bin/bash

echo "* Se verifica fisier: $1"
    echo "  - Se efectuează conversia..."
    sed -i "s/ş/ș/g" $1
    sed -i "s/Ş/Ș/g" $1
    sed -i "s/Ţ/Ț/g" $1
    sed -i "s/ţ/ț/g" $1

#la final verific validitatea fisierului si acceleratorii
echo "  - Se verifică validitatea fișierului... "
msgfmt -v -o /dev/null -c --check-accelerators=_ $1

