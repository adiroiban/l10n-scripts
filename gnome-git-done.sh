#!/bin/sh
/home/adi/dev/scripts/l10n/validare_po_virgula.sh po/ro.po

grep ro po/LINGUAS
if [ $? = 1 ]; then
echo "ATENTIE: ro nu este trecut in po/LINGUAS"
fi

echo "Comit modificările? [D/n]"
read rasp_conv
if [ "x$rasp_conv" = "xn" ]; then
exit
fi

#in case we forget to add the new file
git add po/ro.po

#module=`pwd`; module=${module##*/};
#git diff > ../$module.diff 
#echo `date +%F` "Adi Roiban <adi@roiban.ro>\n\
#\n\
#	* ro.po: Updated Romanian translation\n\
#" > po/ChangeLog.adiroiban
#cat po/ChangeLog >> po/ChangeLog.adiroiban
#mv po/ChangeLog.adiroiban po/ChangeLog

git commit -a -m 'Update Romanian translation'

echo "Trimit modificările? [D/n]"
read rasp_conv
if [ "x$rasp_conv" = "xn" ]; then
exit
fi

git push
