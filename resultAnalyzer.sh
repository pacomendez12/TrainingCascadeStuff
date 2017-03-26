#!/bin/zsh

OPENCV_BIN_FOLDER="/home/pacomendez/Git_projects/opencv/build/bin"
#This cascade is made spetial for the analysis
CASCADE_BIN_FOLDER="/home/pacomendez/Cascade"
TRAININGS_FOLDER="trainings"

GOOD_RESULT="results/GOOD"
BAD_RESULT="results/BAD"
NEED_MORE_TESTING_RESULT="results/MORE_TESTING"
LOGFILE="results/log.log"

threshold=35
training_number=0

# Script starting
if [ -f $LOGFILE ]
then
	rm $LOGFILE
fi 

if [ -d "results" ]
then
	rm -rf results
fi

mkdir results
mkdir $GOOD_RESULT
mkdir $BAD_RESULT
mkdir $NEED_MORE_TESTING_RESULT

echo "Cascade traning training analyzer by Paco" 2>&1 | tee -a $LOGFILE
echo "Starting analysis" 2>&1 | tee -a $LOGFILE


function validate
{
	reach_points=0
	#goal_values=(60 145 531 333)
	in="$1"
	test_img="$2"
	goal_values=($3 $4 $5 $6)
	#echo $test_img
	res_test=$("$CASCADE_BIN_FOLDER"/cascade "trainings/"$in"/cascade.xml" $test_img)
	cars_detected=$(echo $res_test | grep "faces detected" | cut -d "|" -f 2)
	#"$CASCADE_BIN_FOLDER"/cascade "trainings/"$in"/cascade.xml" ~/Pictures/testimg1.jpg |grep "faces detected" |cut -d "|" -f 2)

	if [ "$cars_detected" -eq "0" ]
	then
		#bad
		echo 3
		return
	fi
	#echo "$cars_detected cars"
	for i in {0..$(($cars_detected - 1))}
	do
		coor=$(echo $res_test | grep "RECT_SIZE "$i",")
		#echo -n "coor $coor i = $i \n"
		x1=$(echo $coor |cut -d "," -f 2)
		y1=$(echo $coor |cut -d "," -f 3)
		x2=$(echo $coor |cut -d "," -f 4)
		y2=$(echo $coor |cut -d "," -f 5)
		unset img_values
		img_values=($x1 $y1 $x2 $y2)
		#echo "goal = "${goal_values}
		#echo "img = "${img_values}
		#
		rp=1
		for j in {1..4}
		do
			#echo "val = " $img_values[$j]
			if [ $img_values[$j] -gt $(($goal_values[$j] + threshold)) ];
			then
				rp=0
				break
			fi

			if [ $img_values[$j] -lt $(($goal_values[$j] - threshold)) ];
			then
				rp=0
				break
			fi

		done

		# at least one rect is from expected size
		if [ $rp -eq 1 ]
		then
			reach_points=1
			break
		fi
	done

	if [ $reach_points -eq 1 ]
	then
		if [ $cars_detected -eq 1 ];
		then
			#good
			echo 1
		else
			#need more 
			echo 2
		fi
	else
		#bad
		echo 3
	fi
}



ls -1 $TRAININGS_FOLDER > .tmp_trainings

#For testing specific training
#cd $TRAININGS_FOLDER
#ls -1 -d "data_11_25x10_stage10_pos200_neg500_mode_CORE_BAD" > ../.tmp_trainings
#cd ..

while read in;
do
	echo "" 2>&1 | tee -a $LOGFILE
	echo "Testing training: "$in 2>&1 | tee -a $LOGFILE
	gvalues=(60 145 531 333)
	img="/home/pacomendez/Pictures/testimg1.jpg"
	res=$(validate $in $img $gvalues)
	echo $res
	#validate $in $img $gvalues
	
	if [ $res -eq 1 ]; then
		echo "Copying $in to GOOD folder" 2>&1 | tee -a $LOGFILE
		cp -r "trainings/"$in $GOOD_RESULT
	else
		if [ $res -eq 2 ]; then
			echo "Copying $in to NEED MORE TESTING folder" 2>&1 | tee -a $LOGFILE
			cp -r "trainings/"$in $NEED_MORE_TESTING_RESULT
		else
			echo "Copying $in to BAD folder" 2>&1 | tee -a $LOGFILE
			cp -r "trainings/"$in $BAD_RESULT
		fi
	fi
done < .tmp_trainings

#rm .tmp_trainings

#while read line; do chmod 755 "$line"; done <file.txt
