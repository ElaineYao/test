#!/bin/bash
if [ $# -eq 0 ]
	then
		echo "No arguments supplied"
		exit 1
fi

echo "The number of drones is $1, the spoofing deviation is $2, the number of missions is $3."

rootFolder="$(pwd)"
droneFolder="$rootFolder/$1drones"
devFolder="$droneFolder/$2m_dev"
evalFolder="$droneFolder/eval"
repo_eval="https://github.com/ElaineYao/eval.git"

echo "Creating $devFolder"
mkdir -p $devFolder
echo "Done"

cd $droneFolder
# eval folder
if [ ! -d $evalFolder ]
then 
	git clone $repo_eval
else
	cd "./eval"
	git pull
fi

cd $devFolder
repo_swarm="https://github.com/ElaineYao/swarm_attack.git"
if [ ! -d "./m1" ]
then
    mkdir ./m1 && cd ./m1
    git clone $repo_swarm
else
    cd "m1/swarm_attack"
    git pull
fi

cd $devFolder
for ((i=2; i<=$3; i++));
do	
        mFolder="./m$i"
        if [ ! -d $mFolder ]
        then
                cp -r ./m1 $mFolder
                echo "Created $mFolder."
        else
        	cd "$mFolder/swarm_attack"
        	git pull
        	cd ../../
        fi
done

echo "Finished creating $3 mission folders."

seedFolder="$evalFolder/RQ1/$1drones/seedpools"
if [ ! -d $seedFolder ]
then
	echo "No seedpool for $1 drones."
	exit 1	
fi

cd $seedFolder
declare -i cnt=1
for fname in pool*
do 
	seed=`echo $fname | cut -c 5-7`
	tmp="$devFolder/m$cnt"
	if [ -d $tmp ]
	then	
		fuzzFolder="$tmp/swarm_attack/fuzz/fuzz"
		cd $fuzzFolder
		sbatch --job-name=$1d.$2m.m$cnt.$seed --export=seed_s=$seed,seed_e=$seed,dev=$2,nb=$1 matlab_slurm.sl 
	else
		echo "$tmp does not exist. Exit. "
		exit 1
	fi
	cnt=$cnt+1
done
