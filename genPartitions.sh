# Jorge Torralba

function usage() {

   echo -e
   echo -e "genPartitions.sh "
   echo -e
   echo -e "    Options:  -s schema "
   echo -e "              -t Parent table.  "
   echo -e "              -Y Create partitions going back x number of years. Default is 0. In other words, range starts with today" 
   echo -e "              -y Create partitions going forward x number of years. Default is 1 year (12 months)"
   echo -e "              -l File containing line separated values to be used in partitioning by list."
   echo -e "              -n Number of partitions to create for hash partitioning"
   echo -e "              -o Partition type ( list, range, hash )"
   echo -e "              -c Partition column name"
   echo -e "              -p Create a sub-partition partition"
   echo -e "              -O Partition type for sub-partition ( list, range, hash )"
   echo -e "              -C Partition column name for sub-partition"
   echo -e "              -f Create a file containing the partitions"
   echo -e 

   if [ ! -z "$1" ]; then
      echo -e
      echo -e " ERROR: ********* $1 *********"
      echo
   fi

   exit 1
}

function validateNumber() {
   acceptable='^[0-9]+$'

   if ! [[ $futureYears =~ $acceptable ]]; then
      usage "Invalid number for future years ($futureYears). Defaults to 1 year if not specified."
   fi

   if ! [[ $pastYears =~ $acceptable ]]; then
      usage "Invalid number for past years ($pastYears). "
   fi

   if ! [[ $partitionCount =~ $acceptable ]]; then
      usage "Invalid number ($partitionCount) for number of partitions."
   fi

}


function validatePartitionBy() {
   validList="list range hash"
   x=$(echo $validList | grep -w $1 | wc -l)
   if [ "$x" -eq 0 ]; then
      usage "Declarative partition type ($1) is invalid. Options are list, range or hash"
   fi
}


function checkOpt() {
   checkThis=$1
   arg=$2
   if [ -z "$checkThis" -o "${checkThis:0:1}" = "-" ] ; then
      usage "Missing value after {$arg}. Check options."
   fi
}



function createRangePartitions() {
   while true; do
      suffix=$(date -d $start +%Y%m)
      tabname="${parentTable}_${suffix}"
      sql="CREATE TABLE ${schema}.${tabname} PARTITION OF ${schema}.${parentTable} FOR VALUES FROM ('$start') TO ('$next') $subPartitionIt;"
      echo $sql
      if [ "$createFile" -eq 1 ]; then
         echo "${tabname}" >> $partitionFileList
      fi
      start=$(date -d "$start 1 month" +%Y-%m-%d)
      next=$(date -d "$start 1 month" +%Y-%m-%d)
      if [ "$start" == "$end" ]; then
         break;
      fi
   done
}



function createListPartitions() {
   while read value;
   do
      lowerValue=$(echo $value | tr '[:upper:]' '[:lower:]' )
      childTable=$parentTable"_"$lowerValue
      echo "CREATE TABLE  ${schema}.${childTable} PARTITION OF ${schema}.${parentTable} FOR VALUES IN ('$value') $subPartitionIt;"
      if [ "$createFile" -eq 1 ]; then
         echo "${childTable}" >> $partitionFileList
      fi
   done < $partitionList
}



function createHashPartition() {
   for (( i=0; i<$partitionCount; i++ )); 
   { 
      partnum=$(( $i + 1 ))
      childTable=$parentTable"_"$partnum
      echo "CREATE TABLE ${schema}.${childTable} PARTITION OF ${schema}.${parentTable} FOR VALUES WITH (MODULUS $partitionCount, REMAINDER $i) $subPartitionIt;"
      if [ "$createFile" -eq 1 ]; then
         echo "${childTable}" >> $partitionFileList
      fi
   }
}


# Getopts variables

partition=0

pastYears=0
futureYears=1
parentTable=""
schema=""
partitionBy=""
partitionColumn=""
partitionList=""
partitionCount=0
subPartitionIt=""
subPartitionColumn=""
subPartitionBy=""
createFile=0
partitionFileList='partitons.txt'


while getopts t:s:y:Y:c:C:o:O:l:n:pf? name
do
   case $name in

      t) 
         checkOpt "$OPTARG" "-t" 
         parentTable="$OPTARG";;

      s) 
         checkOpt "$OPTARG" "-s" 
         schema="$OPTARG";;

      y) 
         checkOpt "$OPTARG" "-y" 
         futureYears="$OPTARG";;

      Y) 
         checkOpt "$OPTARG" "-Y" 
         pastYears="$OPTARG";;

      p) partition=1;;

      l) 
         checkOpt "$OPTARG" "-l" 
         partitionList="$OPTARG";;

      n) 
         checkOpt "$OPTARG" "-n" 
         partitionCount="$OPTARG";;

      O) 
         checkOpt "$OPTARG" "-O" 
         subPartitionBy="$OPTARG";;

      o) 
         checkOpt "$OPTARG" "-o" 
         partitionBy="$OPTARG";;

      c) 
         checkOpt "$OPTARG" "-c" 
         partitionColumn="$OPTARG";;

      C) 
         checkOpt "$OPTARG" "-C" 
         subPartitionColumn="$OPTARG";;

      f) 
         createFile=1;;

      *) usage "Please use appropriate options";; 

      ?) usage "Please use appropriate options";; 
   esac
done
shift $(($OPTIND - 1))

# Some checks. 
if [ "$createFile" -eq 1 ]; then
   cat /dev/null > $partitionFileList
fi

if [ -z "$parentTable" ]; then
   usage "Missing name of parent table to use for partitioning"
fi

if [ -z "$parentTable" ] && [ -z "$filename" ]; then
   usage "Missing name of parent table to use for partitioning"
fi



# Some checks for subpartitioning
if [ "$partition" -eq 1 ] && [ -z "$subPartitionColumn" ]; then
   usage "Missing column name to partition by for sub-partitions"
fi

if [ "$partition" -eq 1 ] && [ -z "$subPartitionBy" ]; then
   usage "Missing declarative partition type for sub-partitions. Must be: hash, list or range"
fi


# Passed all sub-partition checks above so we can build our string
if [ "$partition" -eq 1 ]; then
   subPartitionIt=" PARTITION BY $subPartitionBy ($subPartitionColumn) ";
fi


# Checks for non sub-partitions. 
if [ -z "$partitionBy" ]; then
   usage "Missing declarative partition type. Must be: hash, list or range"
else
   # make sure partition type is a valid option
   validatePartitionBy $partitionBy   
fi


# If no schema is set, use public
if [ -z "$schema" ]; then
   schema="public"
fi


# Set range start and end based on years back and years forward entered.
if [ ! -z "$futureYears" ]; then
   validateNumber $futureYears
   addthis="+${futureYears} years"
else
   addthis="+1 years"
fi

if [ ! -z "$pastYears" ]; then
   validateNumber $pastYears
fi


start=$(date +%Y-%m-01 -d "-${pastYears} year")
end=$(date +%Y-%m-01 -d "$addthis")
next=$(date -d "$start 1 month" +%Y-%m-%d )


case "$partitionBy" in
   "list")
      if [ -z "$partitionList" ]; then
         usage "Partitioning by list. Missing filename containing values per line. Use \"-l filename\" "
      fi
      if [ ! -f "$partitionList" ]; then
         usage "The file $partitionList cannot be found."
      fi
      createListPartitions
      ;;
   "hash")
      if [ "$partitionCount" -eq 0 ] ; then
         usage "Partitioning by hash. Please specifify number of partitions wanted with \"-n number\" "
      fi
      if [ "$partitionCount" -gt 0 ] ; then
         validateNumber $partitionCount
      fi
      createHashPartition
      ;;
   "range")
      createRangePartitions
      ;;
esac

