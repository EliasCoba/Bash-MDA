#!/bin/bash

echo "Hello, this is a shell script to count atoms and molecules in MDS files" ;
echo "start by knowing which is the filename to analyze (write its name):" ;
read orifile;

echo "okay" ;

if [ -e $orifile ]
then
	echo "Nice, I find your file!";
	cp $orifile 0.gro ;
	fin=0.gro;
	fout=1.gro;
	ans=y ;
	Ntypemole=0 ;
	ntmole1=0 ;
	ntmole2=0 ;
	ntatom=0 ;
	echo "Hello, this is a Shell Script to count atoms and molecules in MDS files" ;
	echo "a) Automatic searching and counting" ;
	echo "b) User guided searching" ;
	read answer ;
	while [ $answer != a ] && [ $answer != b ]
        do
        echo "Answer again a  or b" ;
	read ans ;
	done
	if [ $answer = a ]
	then
		echo "Automatic search has started... "
		echo " _________________________RESULTS________________ " ;
		echo " Mole|Atom1|Atom2|natom1|natom2|nmole|div1|div2  "
		echo " TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT " ;
		lline=$( tail -n 1 $fin ) ;
		ref1=$( echo $lline | cut -d " " -f 1 );
		ref2=hola ;
		while [ $ref1 != $ref2 ]
		do
		a=$( sed '3!d' $fin ) ;
		b=$( echo $a | cut -d " " -f 1 )  ;
		Mole=$(printf '%s' "$b" | tr -d '0123456789') ;
			if [ "$Mole" = ION ]
			then
				b=$( echo $a | cut -d " " -f 2 ) ;
				Atom1=$(printf '%s' "$b" | tr -d '0123456789') ;
				Atom2=$( echo $Atom1 ) ;
			else
				Atom1=$( echo $a | cut -d " " -f 2 ) ;
				if [ ${#Atom1} -gt 3 ]
				then
					Atom1=$(printf '%s' "$Atom1" | tr -d '0123456789') ;
				fi
				c=$( sed '4q;d' $fin ) ;
				Atom2=$( echo $c | cut -d " " -f 2 ) ;
				if [ ${#Atom2} -gt 3 ]
				then
					Atom2=$(printf '%s' "$Atom2" | tr -d '0123456789')  ;
				fi
			fi
			natom1=$( cat $fin | grep "$Mole" | grep "$Atom1" | wc -l  ) ;
			natom2=$( cat $fin | grep "$Mole" | grep "$Atom2" | wc -l  ) ;
			if [ "$Mole" = ION ]
			then
				nmole=$( echo $natom1 ) ;		
			else
				nmole=$( cat $fin | grep "$Mole" | wc -l ) ;
			fi
			div1=$( echo $(( nmole / natom1 )) | tee /dev/stderr ) ;
			div2=$( echo $(( nmole / natom2 )) | tee /dev/stderr ) ;
			echo " $Mole , $Atom1 , $Atom2 , $natom1 , $natom2 , $nmole , $div1 , $div2 , " | tee -a results.csv ;
			if [ "$Mole" = ION ]		
			then
				cat $fin | grep "$Mole" | grep "$Atom1" -v >  $fout ;
			else
				cat $fin | grep "$Mole" -v >  $fout ;
			fi
			cp $fout $fin ;
			Ntypemole=$( echo $(( Ntypemole + 1 )) | tee /dev/stderr ) ;
                	ntmole1=$( echo $(( ntmole1 + natom1 )) | tee /dev/stderr ) ;
			ntmole2=$( echo $(( ntmole2 + natom2 )) | tee /dev/stderr ) ;
                	ntatom=$( echo $(( ntatom + nmole )) | tee /dev/stderr ) ;
			f=$( sed '3q;d' $fin )			
			ref2=$( echo $f | cut -d " " -f 1 );
		done
		echo " ______________________________________________________________ " ;
	else
		while [ $ans = y ]
		do
			head $fin ;
			echo " " ;
			echo " You are seeing first ten lines from your file. Which is the" ; 
			echo " molecular identifier or molecule to identify? Write it:" ; 
			read Mole ;
			echo " " ;
			echo " Name a first caracteristic atom from this molecule: "  ; 
			read Atom1 ;
			echo " " ;
			echo " Name a second caracteristic atom from this molecule: " ; 
			read Atom2 ;
			echo " Searching started... " ;
			natom1=$( cat $fin | grep $Mole | grep $Atom1 | wc -l  ) ;
			natom2=$( cat $fin | grep $Mole | grep $Atom2 | wc -l  ) ;
			nmole=$( cat $fin | grep $Mole | wc -l ) ;
			if [ $natom1 -eq 0 ] ||  [ $natom2  -eq 0 ] || [ $nmole -eq 0 ]
			then 
				echo " ";
				echo " X.X " ;
				echo "Something was not fine, we have a  division by zero or zero molecules" ;
				echo "introduce data again" ;
			else
				div1=$( echo $(( nmole / natom1 )) | tee /dev/stderr ) ;
				div2=$( echo $(( nmole / natom2 )) | tee /dev/stderr ) ;
				echo " _________________________RESULTS_____________________________ " ;
				echo " $Mole , $Atom1 , $Atom2 , $natom1 , $natom2 , $nmole , $div1 , $div2 , " | tee -a results.csv ;
				cat $fin | grep $Mole -v >  $fout ;
				cp $fout $fin ;
				Ntypemole=$( echo $(( Ntypemole + 1 )) | tee /dev/stderr ) ;
                        	ntmole1=$( echo $(( ntmole1 + natom1 )) | tee /dev/stderr ) ;
				ntmole2=$( echo $(( ntmole2 + natom2 )) | tee /dev/stderr ) ;
                        	ntatom=$( echo $(( ntatom + nmole )) | tee /dev/stderr ) ;
				echo " Molecules types:  $Ntypemole , Number of atoms: $ntatom " ;
				echo " ____________________________________________________________ " ;
				echo " Next Molecule: " ;
				echo | sed -n '3'p $fin ;			
				echo "Are you looking for new molecules? answer y or n" ;
				read ans ;
				while [ $ans != y ] && [ $ans != n ]
		        	do
				echo "Answer again y or n" ;
				read ans ;
				done
			fi	
		done
	fi
rm $fin ; rm $fout;

echo " Molecules types:,  $Ntypemole , Number of atoms:,  $ntatom , Possible number of molecules:, $ntmole1 or $ntmole2 "  >> results.csv ;
echo " Molecules types:  $Ntypemole , Number of atoms: $ntatom , Possible number of molecules: $ntmole1 or $ntmole2 " ;

echo "Thanks for count with molecular airlines!" ;


else
        echo " wHOops! your file doesnt exist in this directory " ;
        echo " sstarting program again " ;
        ./mcgro.sh ;
fi


