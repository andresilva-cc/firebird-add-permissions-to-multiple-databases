# The user which will be granted permission on the databases
user=myusername

# If tables directory doesn't exist, create it
if [ ! -d "./tables" ]
then
    echo "Tables folder missing, creating it..."
    mkdir tables
fi

# If sql directory doesn't exist, create it
if [ ! -d "./sql" ]
then
    echo "SQL folder missing, creating it..."
    mkdir sql
fi

# If logs directory doesn't exist, create it
if [ ! -d "./logs" ]
then
    echo "Logs folder missing, creating it..."
    mkdir logs
fi

# Read every database path from database.list
{ while IFS= read path
do
    echo -e "\nDatabase $path"

    # Get the filename
    name=$(echo $path | grep -oP '[ \w-]+?(?=\.)')
    
    echo "Getting table list from database $name"
    # Get tables and save to file
    isql-fb $path -i show_tables.sql -o ./tables/$name

    echo "Adjusting table list from database $name"
    # Transform table list from two columns to one column using regex
    # Remove spaces from the beginning
    sed -i -E "s/^(\s){7}//g" ./tables/$name
    # Replace multiple spaces by a single space
    sed -i -E "s/\s+/ /g" ./tables/$name
    # Remove the single space from the end of the line
    sed -i -E "s/\s$//g" ./tables/$name
    # Replace the space between the two columns by a new line
    sed -i -E "s/\s/\n/g" ./tables/$name
    # Finally, remove any blank lines
    sed -i '/^$/d' ./tables/$name

    echo "Generating SQL file to set permissions to all tables of database $name"
    # Create the file
    touch ./sql/$name.sql

    # Read every table from the current database
    { while IFS= read table
    do
        echo "Table $table"

        # Append the current table to the SQL file
        echo "GRANT ALL ON $table TO $user WITH GRANT OPTION;" >> ./sql/$name.sql
    done
    } < ./tables/$name

    echo "Executing generated SQL file in database $name"
    # Execute the SQL file
    isql-fb $path -i ./sql/$name.sql -o ./logs/$name.log
done
} < ./database.list
