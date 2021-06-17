#!/bin/bash

echo "Hello, this is a shell script to count atoms and molecules in MDS files" ;
echo "start by knowing which is the filename to analyze (write its name):" ;
read orifile;

echo "okay" ;

if [ -e $orifile ]
then
	echo "Nice, I find your file!";
	cp $orifile 0.txt ;
	fin=0.txt ;
	fout=1.txt ;
	ans=y ;
	Ntypemole=0 ;
	ntmole1=0 ;
	ntmole2=0 ;
	ntatom=0 ;
	while [ $ans = y ]
	do
		head $fin ;
		echo " " ;
		echo " You are seeing first ten lines from your file. Which is the" 
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

rm $fin ; rm $fout;

echo " Molecules types:,  $Ntypemole , Number of atoms:,  $ntatom , Possible number of molecules:, $ntmole1 or $ntmole2 "  >> results.csv ;
echo " Molecules types:  $Ntypemole , Number of atoms: $ntatom , Possible number of molecules: $ntmole1 or $ntmole2 " ;

echo "Thanks for count with molecular airlines!" ;


else
        echo " wHOops! your file doesnt exist in this directory " ;
        echo " sstarting program again " ;
        ./smcsingle.sh ;
fi

