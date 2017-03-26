#!/bin/zsh


OPENCV_BIN_FOLDER="/home/pacomendez/Git_projects/opencv/build/bin"
CASCADE_BIN_FOLDER="/home/pacomendez/Git_projects/Cascade"


LOGFILE="log.log"


function check_temp
{
	temp_max=0

	acpi -t | cut -d "," -f 2 | cut -d " " -f 2 > .temp
	while read temp; do
		exp=$(echo $temp'>'$temp_max | bc -l)
		if [ $exp -eq 1 ]
		then
			temp_max=$temp
		fi
	done < .temp
	rm .temp
	echo $temp_max

}

# Script starting
if [ -f $LOGFILE ]
then
	rm $LOGFILE
fi 

if [ -f "data" ]
then
	rm -rf data
fi

mkdir data


echo "Cascade traning script, it will try many configurations of training" 2>&1 | tee -a $LOGFILE
echo "Starting Script" 2>&1 | tee -a $LOGFILE



echo "Checking CPU temperature" 2>&1 | tee -a $LOGFILE
temperature=$(check_temp)
exp=$(echo $temperature'>65' | bc -l)
if [ $exp -eq 1 ]
then
	echo "WARNING:: Temperature is too high, $temperature C, Shuting down computer..." 2>&1 | tee -a $LOGFILE ;
	shutdown -h now
	exit 1
else
	echo "Temperature is lower than 65 C, current is $temperature" 2>&1 | tee -a $LOGFILE
fi


CS_W_MAX=100
cs_num=550
cs_w=25
cs_h=10
training_number=0

while true;
do
	echo "" 2>&1 | tee -a $LOGFILE
	echo "" 2>&1 | tee -a $LOGFILE
	echo "===========================" 2>&1 | tee -a $LOGFILE
	echo " createsamples parameters:" 2>&1 | tee -a $LOGFILE
	echo "===========================" 2>&1 | tee -a $LOGFILE
	echo " - Image Width  = $cs_w" 2>&1 | tee -a $LOGFILE
	echo " - Image Height = $cs_h" 2>&1 | tee -a $LOGFILE
	echo "" 2>&1 | tee -a $LOGFILE



	if [ -f "cars.vec" ]
	then
		rm cars.vec
	fi

	echo "Creating Vector file..." 2>&1 | tee -a $LOGFILE
	echo "$OPENCV_BIN_FOLDER"/opencv_createsamples -vec cars.vec -info cars.info -num $cs_num -w $cs_w -h $cs_h 2>&1 | tee -a $LOGFILE
	"$OPENCV_BIN_FOLDER"/opencv_createsamples -vec cars.vec -info ./cars.info -num $cs_num -w $cs_w -h $cs_h 2>&1 | tee -a $LOGFILE


	#initializing variables
	tc_stages=10

	while true;
	do
		tc_num_pos=200

		while true;
		do
			tc_num_neg=200

			while true;
			do
				tc_w=$cs_w
				tc_h=$cs_h
				tc_mode="BASIC"

				while true;
				do
					echo "" 2>&1 | tee -a $LOGFILE
					echo "" 2>&1 | tee -a $LOGFILE
					echo "" 2>&1 | tee -a $LOGFILE
					echo "" 2>&1 | tee -a $LOGFILE
					training_number=$(($training_number + 1))
					echo "				#############################" 2>&1 | tee -a $LOGFILE
					echo "				    Starting new training #$training_number" 2>&1 | tee -a $LOGFILE
					echo "				#############################" 2>&1 | tee -a $LOGFILE
					echo "" 2>&1 | tee -a $LOGFILE
					echo "	     Training parameters" 2>&1 | tee -a $LOGFILE
					echo "	=============================" 2>&1 | tee -a $LOGFILE
					echo "			- Stages	= $tc_stages" 2>&1 | tee -a $LOGFILE
					echo "			- Num Pos	= $tc_num_pos" 2>&1 | tee -a $LOGFILE
					echo "			- Num Neg	= $tc_num_neg" 2>&1 | tee -a $LOGFILE
					echo "			- W		= $tc_w" 2>&1 | tee -a $LOGFILE
					echo "			- H		= $tc_h" 2>&1 | tee -a $LOGFILE
					echo "			- Mode		= $tc_mode" 2>&1 | tee -a $LOGFILE
					echo "" 2>&1 | tee -a $LOGFILE
					echo "" 2>&1 | tee -a $LOGFILE

					echo "Removing data content" 2>&1 | tee -a $LOGFILE
					rm data/*
					echo "				Starting training..." 2>&1 | tee -a $LOGFILE

					echo "$OPENCV_BIN_FOLDER"/opencv_traincascade -data data -vec cars.vec -bg bg.txt -numPos $tc_num_pos -numNeg $tc_num_neg -numStages $tc_stages -numThreads 16 -featureType HAAR -w $tc_w -h $tc_h -mode "$tc_mode" 2>&1 | tee -a $LOGFILE
					"$OPENCV_BIN_FOLDER"/opencv_traincascade -data data -vec cars.vec -bg bg.txt -numPos $tc_num_pos -numNeg $tc_num_neg -numStages $tc_stages -numThreads 16 -featureType HAAR -w $tc_w -h $tc_h -mode "$tc_mode" 2>&1 | tee -a $LOGFILE

					echo "Copying vec file to data folder" 2>&1 | tee -a $LOGFILE
					cp cars.vec data
					if [ $tc_stages -lt 10 ]; then
						stage=$(printf "_stage0%d" $tc_stages)
					else
						stage=$(printf "_stage%d" $tc_stages)
					fi

					result_path="trainings/data_""$training_number""_""$cs_w""x""$cs_h"$stage"_pos$tc_num_pos""_neg""$tc_num_neg""_mode_$tc_mode"
					echo "Result_path=$result_path" 2>&1 | tee -a $LOGFILE

					echo "Testing training..."
					echo "$CASCADE_BIN_FOLDER"/cascade "data"/"cascade.xml" ~/Pictures/testimg1.jpg | grep "faces detected" | cut -d "|" -f 2 2>&1 | tee -a $LOGFILE
					objs1=$("$CASCADE_BIN_FOLDER"/cascade "data"/"cascade.xml" ~/Pictures/testimg1.jpg | grep "faces detected" | cut -d "|" -f 2)


					echo "$CASCADE_BIN_FOLDER"/cascade "data"/"cascade.xml" ~/Pictures/testimg2.jpg | grep "faces detected" | cut -d "|" -f 2 2>&1 | tee -a $LOGFILE
					objs2=$("$CASCADE_BIN_FOLDER"/cascade "data"/"cascade.xml" ~/Pictures/testimg2.jpg | grep "faces detected" | cut -d "|" -f 2)

					echo "$CASCADE_BIN_FOLDER"/cascade "data"/"cascade.xml" ~/Pictures/testimg3.jpg | grep "faces detected" | cut -d "|" -f 2 2>&1 | tee -a $LOGFILE
					objs3=$("$CASCADE_BIN_FOLDER"/cascade "data"/"cascade.xml" ~/Pictures/testimg3.jpg | grep "faces detected" | cut -d "|" -f 2)


					echo "OBJECTS, obj1="$objs1", objs2="$objs2", objs3="$objs3" : training number is $training_number" 2>&1 | tee -a $LOGFILE
					echo "Copying training to result folder" 2>&1 | tee -a $LOGFILE
					sum=$(($objs1 + $objs2 + $objs3))
					
					if [ $sum -le 5 ]
					then
						echo cp -r data $result_path"_GOOD" 2>&1 | tee -a $LOGFILE
						cp -r data $result_path"_GOOD"
					else
						echo cp -r data $result_path"_BAD" 2>&1 | tee -a $LOGFILE
						cp -r data $result_path"_BAD"
					fi
					
					
					#---


					if [ $tc_mode = ALL ];
					then
						break
					fi

					if [ $tc_mode = CORE ]
					then
						tc_mode="ALL"
					fi

					if [ $tc_mode = BASIC ]
					then
						tc_mode="CORE"
					fi

				done

				#breaking num neg
				if [ $tc_num_neg -ge 500 ]; then
					break
				fi
				tc_num_neg=$(($tc_num_neg + 100))
			done

			#breaking num pos
			if [ $tc_num_pos -ge 500 ]; then
				break
			fi
			tc_num_pos=$(($tc_num_pos + 100))

		done


		# breaking stages
		if [ $tc_stages -ge 22 ]; then
			break
		fi
		tc_stages=$(($tc_stages + 4))
	done

	# breaking width
	if [ $cs_w -ge $CS_W_MAX ]; then
		break
	fi
	cs_w=$(($cs_w*2))
	cs_h=$(($cs_h*2))

done
