#!/bin/bash
# Aleksander Szulc 09.06
# Laboratorium ARKO
# Tester programu Z-bufor w assemblerze INTEL

echo 'Testowanie programu zbuf.cpp'

# Test 1 - 10
for i in `seq 1 10`
do
	echo "------- Test $i:"
	mv tests/test$i.txt opis.txt 2>/dev/null	# przekierowanie stderr na potrzeby testu 14
	./test <opis.txt
	mv opis.txt tests/test$i.txt 2>/dev/null
	mv scena.bmp tests/scena$i.bmp 2>/dev/null
	mv zbufor.bmp tests/zbufor$i.bmp 2>/dev/null
	echo "------- Test $i zakonczono." $'\n'
done

