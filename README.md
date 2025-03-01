# pgPartitions

This is a primitive approach to generating table partition sql statements for PostgreSQL partitioning. There is plenty of room for improvements but as it stands, it is useful and works well especially when there are many partitions to create.

The tool is used to generate partitions and sub-partitions using **list**, **range** or **hash** method. 

## Here are some simple examples.

Lets assume you created the table foobar and you decided to partition it by range.

### Simple partitioning by range

    ./genPartitions.sh -t foobar -o range  

Would generate the following.  Notice by default it generates 1 year's worth of partitions from today.

    CREATE TABLE public.foobar_202502 PARTITION OF public.foobar FOR VALUES FROM ('2025-02-01') TO ('2025-03-01') ;  
    CREATE TABLE public.foobar_202503 PARTITION OF public.foobar FOR VALUES FROM ('2025-03-01') TO ('2025-04-01') ;  
    CREATE TABLE public.foobar_202504 PARTITION OF public.foobar FOR VALUES FROM ('2025-04-01') TO ('2025-05-01') ;  
    CREATE TABLE public.foobar_202505 PARTITION OF public.foobar FOR VALUES FROM ('2025-05-01') TO ('2025-06-01') ;  
    CREATE TABLE public.foobar_202506 PARTITION OF public.foobar FOR VALUES FROM ('2025-06-01') TO ('2025-07-01') ;  
    CREATE TABLE public.foobar_202507 PARTITION OF public.foobar FOR VALUES FROM ('2025-07-01') TO ('2025-08-01') ;  
    CREATE TABLE public.foobar_202508 PARTITION OF public.foobar FOR VALUES FROM ('2025-08-01') TO ('2025-09-01') ;  
    CREATE TABLE public.foobar_202509 PARTITION OF public.foobar FOR VALUES FROM ('2025-09-01') TO ('2025-10-01') ;  
    CREATE TABLE public.foobar_202510 PARTITION OF public.foobar FOR VALUES FROM ('2025-10-01') TO ('2025-11-01') ;  
    CREATE TABLE public.foobar_202511 PARTITION OF public.foobar FOR VALUES FROM ('2025-11-01') TO ('2025-12-01') ;  
    CREATE TABLE public.foobar_202512 PARTITION OF public.foobar FOR VALUES FROM ('2025-12-01') TO ('2026-01-01') ;  
    CREATE TABLE public.foobar_202601 PARTITION OF public.foobar FOR VALUES FROM ('2026-01-01') TO ('2026-02-01') ;


### To generate partitions in the past as well run it with the -Y option

    ./genPartitions.sh -t foobar -o range -Y 1  

As you can see, we now have partitons starting 1 year back from today.

    CREATE TABLE public.foobar_202402 PARTITION OF public.foobar FOR VALUES FROM ('2024-02-01') TO ('2024-03-01') ;  
    CREATE TABLE public.foobar_202403 PARTITION OF public.foobar FOR VALUES FROM ('2024-03-01') TO ('2024-04-01') ;  
    CREATE TABLE public.foobar_202404 PARTITION OF public.foobar FOR VALUES FROM ('2024-04-01') TO ('2024-05-01') ;  
    CREATE TABLE public.foobar_202405 PARTITION OF public.foobar FOR VALUES FROM ('2024-05-01') TO ('2024-06-01') ;  
    CREATE TABLE public.foobar_202406 PARTITION OF public.foobar FOR VALUES FROM ('2024-06-01') TO ('2024-07-01') ;  
    CREATE TABLE public.foobar_202407 PARTITION OF public.foobar FOR VALUES FROM ('2024-07-01') TO ('2024-08-01') ;  
    CREATE TABLE public.foobar_202408 PARTITION OF public.foobar FOR VALUES FROM ('2024-08-01') TO ('2024-09-01') ;  
    CREATE TABLE public.foobar_202409 PARTITION OF public.foobar FOR VALUES FROM ('2024-09-01') TO ('2024-10-01') ;  
    CREATE TABLE public.foobar_202410 PARTITION OF public.foobar FOR VALUES FROM ('2024-10-01') TO ('2024-11-01') ;  
    CREATE TABLE public.foobar_202411 PARTITION OF public.foobar FOR VALUES FROM ('2024-11-01') TO ('2024-12-01') ;  
    CREATE TABLE public.foobar_202412 PARTITION OF public.foobar FOR VALUES FROM ('2024-12-01') TO ('2025-01-01') ;  
    CREATE TABLE public.foobar_202501 PARTITION OF public.foobar FOR VALUES FROM ('2025-01-01') TO ('2025-02-01') ;  
    CREATE TABLE public.foobar_202502 PARTITION OF public.foobar FOR VALUES FROM ('2025-02-01') TO ('2025-03-01') ;  
    CREATE TABLE public.foobar_202503 PARTITION OF public.foobar FOR VALUES FROM ('2025-03-01') TO ('2025-04-01') ;  
    CREATE TABLE public.foobar_202504 PARTITION OF public.foobar FOR VALUES FROM ('2025-04-01') TO ('2025-05-01') ;  
    CREATE TABLE public.foobar_202505 PARTITION OF public.foobar FOR VALUES FROM ('2025-05-01') TO ('2025-06-01') ;  
    CREATE TABLE public.foobar_202506 PARTITION OF public.foobar FOR VALUES FROM ('2025-06-01') TO ('2025-07-01') ;  
    CREATE TABLE public.foobar_202507 PARTITION OF public.foobar FOR VALUES FROM ('2025-07-01') TO ('2025-08-01') ;  
    CREATE TABLE public.foobar_202508 PARTITION OF public.foobar FOR VALUES FROM ('2025-08-01') TO ('2025-09-01') ;  
    CREATE TABLE public.foobar_202509 PARTITION OF public.foobar FOR VALUES FROM ('2025-09-01') TO ('2025-10-01') ;  
    CREATE TABLE public.foobar_202510 PARTITION OF public.foobar FOR VALUES FROM ('2025-10-01') TO ('2025-11-01') ;  
    CREATE TABLE public.foobar_202511 PARTITION OF public.foobar FOR VALUES FROM ('2025-11-01') TO ('2025-12-01') ;  
    CREATE TABLE public.foobar_202512 PARTITION OF public.foobar FOR VALUES FROM ('2025-12-01') TO ('2026-01-01') ;  
    CREATE TABLE public.foobar_202601 PARTITION OF public.foobar FOR VALUES FROM ('2026-01-01') TO ('2026-02-01') ;


### Generate partitions by list.

To generate partitions by list, have a file with line separated list of values.  For example the file `values.txt` has the values in it that will be used for the partitions.

    RED  
    WHITE  
    BLUE  
    GREEN

Assuming we created the foobar table and are partitioning it by list we could simply run

    ./genPartitions.sh -t foobar -o list -l values.txt

Which would read the values.txt file and generates the following

    CREATE TABLE public.foobar_red PARTITION OF public.foobar FOR VALUES IN ('RED') ;  
    CREATE TABLE public.foobar_white PARTITION OF public.foobar FOR VALUES IN ('WHITE') ;  
    CREATE TABLE public.foobar_blue PARTITION OF public.foobar FOR VALUES IN ('BLUE') ;  
    CREATE TABLE public.foobar_green PARTITION OF public.foobar FOR VALUES IN ('GREEN') ;


### Generate partitions by hash

Assuming we created the foobar table and are partitioning it by hash  we could simply run

    ./genPartitions.sh -t foobar -o hash -n 5

Which generates the following

    CREATE TABLE public.foobar_1 PARTITION OF public.foobar FOR VALUES WITH (MODULUS 5, REMAINDER 0) ;  
    CREATE TABLE public.foobar_2 PARTITION OF public.foobar FOR VALUES WITH (MODULUS 5, REMAINDER 1) ;  
    CREATE TABLE public.foobar_3 PARTITION OF public.foobar FOR VALUES WITH (MODULUS 5, REMAINDER 2) ;  
    CREATE TABLE public.foobar_4 PARTITION OF public.foobar FOR VALUES WITH (MODULUS 5, REMAINDER 3) ;  
    CREATE TABLE public.foobar_5 PARTITION OF public.foobar FOR VALUES WITH (MODULUS 5, REMAINDER 4) ;


### Sub partitioning 

Assuming we created the foobar table and it is partitioned by list and we want to partition those partitions by hash on the column userid.


    ./genPartitions.sh -t foobar -o list -l values.txt -p -O hash -C userid -f

Would generate the following

    CREATE TABLE public.foobar_red PARTITION OF public.foobar FOR VALUES IN ('RED') PARTITION BY hash (userid) ;  
    CREATE TABLE public.foobar_white PARTITION OF public.foobar FOR VALUES IN ('WHITE') PARTITION BY hash (userid) ;  
    CREATE TABLE public.foobar_blue PARTITION OF public.foobar FOR VALUES IN ('BLUE') PARTITION BY hash (userid) ;  
    CREATE TABLE public.foobar_green PARTITION OF public.foobar FOR VALUES IN ('GREEN') PARTITION BY hash (userid) ;

The options `-p` specifiies create sub partition `-O hash` specifies partition by hash and the -`C userid` specifies userid as the column to use, the `-f` options creates a text file containing a list of partitions.


Now you could create the sub partitions like this

If you wanted to create on just 1 of the partitions for the table with white for value

    ./genPartitions.sh -t foobar_white -o hash -n 3

Would generate the following

    CREATE TABLE public.foobar_white_1 PARTITION OF public.foobar_white FOR VALUES WITH (MODULUS 5, REMAINDER 0) ;  
    CREATE TABLE public.foobar_white_2 PARTITION OF public.foobar_white FOR VALUES WITH (MODULUS 5, REMAINDER 1) ;  
    CREATE TABLE public.foobar_white_3 PARTITION OF public.foobar_white FOR VALUES WITH (MODULUS 5, REMAINDER 2) ;  
    


### Using a list of tables for source

Or if you wanted to do them all


    while read tablename; do ./genPartitions.sh -t $tablename -o hash -n 3; done < partitons.txt

The trick here is that  we are reading a list of tables to partition from the file `partitins.txt.`   How did we get that file ?
With the `-f` option when we created original partitions


    CREATE TABLE public.foobar_red_1 PARTITION OF public.foobar_red FOR VALUES WITH (MODULUS 3, REMAINDER 0) ;  
    CREATE TABLE public.foobar_red_2 PARTITION OF public.foobar_red FOR VALUES WITH (MODULUS 3, REMAINDER 1) ;  
    CREATE TABLE public.foobar_red_3 PARTITION OF public.foobar_red FOR VALUES WITH (MODULUS 3, REMAINDER 2) ;  
    CREATE TABLE public.foobar_white_1 PARTITION OF public.foobar_white FOR VALUES WITH (MODULUS 3, REMAINDER 0) ;  
    CREATE TABLE public.foobar_white_2 PARTITION OF public.foobar_white FOR VALUES WITH (MODULUS 3, REMAINDER 1) ;  
    CREATE TABLE public.foobar_white_3 PARTITION OF public.foobar_white FOR VALUES WITH (MODULUS 3, REMAINDER 2) ;  
    CREATE TABLE public.foobar_blue_1 PARTITION OF public.foobar_blue FOR VALUES WITH (MODULUS 3, REMAINDER 0) ;  
    CREATE TABLE public.foobar_blue_2 PARTITION OF public.foobar_blue FOR VALUES WITH (MODULUS 3, REMAINDER 1) ;  
    CREATE TABLE public.foobar_blue_3 PARTITION OF public.foobar_blue FOR VALUES WITH (MODULUS 3, REMAINDER 2) ;  
    CREATE TABLE public.foobar_green_1 PARTITION OF public.foobar_green FOR VALUES WITH (MODULUS 3, REMAINDER 0) ;  
    CREATE TABLE public.foobar_green_2 PARTITION OF public.foobar_green FOR VALUES WITH (MODULUS 3, REMAINDER 1) ;  
    CREATE TABLE public.foobar_green_3 PARTITION OF public.foobar_green FOR VALUES WITH (MODULUS 3, REMAINDER 2) ;


### Multi column partition

You can simply place your column names inside double quotes to generate a multi column partition statement.

   ./genPartitions.sh -t foobar -o list -l values.txt -p -O hash -C "userid, dob" -f

Which generates the following ...

   CREATE TABLE  public.foobar_red PARTITION OF public.foobar FOR VALUES IN ('RED')  PARTITION BY hash (userid, dob) ;
   CREATE TABLE  public.foobar_white PARTITION OF public.foobar FOR VALUES IN ('WHITE')  PARTITION BY hash (userid, dob) ;
   CREATE TABLE  public.foobar_blue PARTITION OF public.foobar FOR VALUES IN ('BLUE')  PARTITION BY hash (userid, dob) ;
   CREATE TABLE  public.foobar_green PARTITION OF public.foobar FOR VALUES IN ('GREEN')  PARTITION BY hash (userid, dob) ;



This is still work in progress so I am open to suggestions and improvements.


