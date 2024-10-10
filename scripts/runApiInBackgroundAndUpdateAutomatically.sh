# git clone -b 'v2.0' --single-branch --depth 1 https://github.com/git/git.git

cd ./RPGTableHelper

cd /Users/peteresser/tmp/RPGTableHelper && dotnet restore . && dotnet build . && dotnet run --project applications/RPGTableHelper.WebApi &
DOTNET_PID=$!

same_commit(){
    set -- $(git show-ref --hash --verify "$@")
    [ "$1" = "$2" ]
}

# run forever
while :
do
    # sleep 10 seconds
    sleep 10

    # get the changes if any, but don't merge them yet
    git fetch origin

    # See if there are any changes
    OUTPUT="$(git rev-list --count main..origin/main)"
    echo "Remote is following number of commits ahead:"
    echo $OUTPUT
    if ((OUTPUT == 0))
    then
        echo "Everything up to date"
        continue
    fi

    if (( $DOTNET_PID > 0 )); then
        echo "Killing subprocess"
        # kill $DOTNET_PID
        # pkill -P $$


        list_descendants ()
        {
            GREP='^[0-9]+\s*'
            GREP+=$1
            GREP+='$'

            local children=$(ps -o pid,ppid | grep -Ei $GREP | cut -d" " -f1)

            for pid in $children
            do
                list_descendants "$pid"
            done

            echo "$children"
        }

        kill $(list_descendants $$)

        sleep 5
    fi

    # Now merge the remote changes
    git pull origin

    cd /Users/peteresser/tmp/RPGTableHelper && dotnet restore . && dotnet build . && dotnet run --project applications/RPGTableHelper.WebApi &
    DOTNET_PID=$!
    # loop infinitely
done