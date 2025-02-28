function usage() {

   echo -e
   echo -e "partition.sh "
   echo -e
   echo -e "    Options:  -s schema "
   echo -e "              -t Parent table "
   echo -e "              -Y Create partitions starting x years in the past. "
   echo -e "              -y Create partitions for x number of years in the future. Default is 1 year (12 months)"
   echo -e "              -l File with list of values one per line"
   echo -e "              -n Number of partitions to create for hash partitioning"
   echo -e "              -p Create a sub partition partition"
   echo -e "              -o Partition by type ( list, range, hash )"
   echo -e "              -c Partition by column name"
   echo -e 

   if [ ! -z "$1" ]; then
      echo -e
      echo -e " ******* $1 *******"
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
      usage "Invalid number for past years ($pastYears). Defaults to 1 year if not specified."
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



function createRangePartitions() {
   while true; do
      partitionit=""
      if [ ! -z "$partitionColumn" ] && [ ! -z "$partitionBy" ]; then
         partitionit=" PARTITION BY $partitionBy ($partitionColumn) ";
      fi
      suffix=$(date -d $start +%Y%m)
      tabname="${partname}${suffix}"
      sql="CREATE TABLE ${schema}.${tabname} PARTITION OF ${schema}.${parentTable} FOR VALUES FROM ('$start') TO ('$next') $partitionit;"
      echo $sql
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
      echo "CREATE TABLE $childTable PARTITION OF $parentTable FOR VALUES IN ('$value');"
   done < $partitionList
}



function createHashPartition() {
   for (( i=0; i<$partitionCount; i++ )); 
   { 
      partnum=$(( $i + 1 ))
      childTable=$parentTable"_"$partnum
      echo "CREATE TABLE $childTable PARTITION OF $parentTable FOR VALUES WITH (MODULUS $partitionCount, REMAINDER $i);"
   }
}


# Getopts variables

partition=0
createList=0

pastYears=1
futureYears=1
fileName=""
parentTable=""
schema=""
partitionBy=""
partitionColumn=""
partitionList=""
partitionCount=0


while getopts f:t:s:y:Y:c:o:l:n:p? name
do
   case $name in
      f) fileName="$OPTARG";;
      t) parentTable="$OPTARG";;
      s) schema="$OPTARG";;
      y) futureYears="$OPTARG";;
      Y) pastYears="$OPTARG";;
      p) partition=1;;
      l) partitionList="$OPTARG";;
      n) partitionCount="$OPTARG";;
      o) partitionBy="$OPTARG";;
      c) partitionColumn="$OPTARG";;
      *) usage "Please use approopriate options";; 
      ?) usage "Please use approopriate options";; 
   esac
done
shift $(($OPTIND - 1))


if [ "$partition" -eq 1 ] && [ -z "$partitionColumn" ]; then
   usage "Missing column name to partition by"
fi

if [ "$partition" -eq 1 ] && [ -z "$partitionBy" ]; then
   usage "Missing declarative partition type. Must be: hash, list or range"
fi

if [ -z "$partitionBy" ]; then
   usage "Missing declarative partition type. Must be: hash, list or range"
else
   validatePartitionBy $partitionBy   
fi


if [ -z "$schema" ]; then
   schema="public"
fi

if [ -z "$parentTable" ]; then
   usage "Missing name of parent table to use for partitioning"
fi

if [ -z "$parentTable" ] && [ -z "$filename" ]; then
   usage "Missing name of parent table to use for partitioning"
fi

if [ -z "$partname" ] ; then
   partname="${parentTable}_"
fi


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
         usage "Partitioning by list. Missing filename containing values per line. Use < -l filename >"
      fi
      if [ ! -f "$partitionList" ]; then
         usage "The file $partitionList cannot be found."
      fi
      createListPartitions
      ;;
   "hash")
      if [ "$partitionCount" -eq 0 ] ; then
         usage "Partitioning by hash. Please specifify number of partitions wanted with < -n number >"
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

