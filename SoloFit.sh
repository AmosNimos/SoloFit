# a game where you add the total exercise you do in a day to gain level

data_dir="./data/"
level_file="level.txt"
history_file="history.txt"

xp_file="xp.txt"
pt_file="pt.txt"

push_file="pushup.txt"
squat_file="squat.txt"
situp_file="sithup.txt"
time_file="date.txt" # to see if it's a new day


# dayly files
goal_file="goal.txt"
xp_dfile="xp_dayly.txt"
push_dfile="pushup_dayly.txt"
squat_dfile="squat_dayly.txt"
situp_dfile="sithup_dayly.txt"

# prepare storage

reset_dayly(){
    echo "0" > "${data_dir}${xp_dfile}"
    echo "0" > "${data_dir}${push_dfile}"
    echo "0" > "${data_dir}${squat_dfile}"
    echo "0" > "${data_dir}${situp_dfile}"
}

if [[ ! -d $data_dir ]]; then
    mkdir $data_dir
    echo "100" > "${data_dir}${goal_file}"
    echo "0" > "${data_dir}${level_file}"
    echo "0" > "${data_dir}${time_file}"
    echo "0" > "${data_dir}${xp_file}"
    echo "0" > "${data_dir}${pt_file}"
    echo "0" > "${data_dir}${push_file}"
    echo "0" > "${data_dir}${squat_file}"
    echo "0" > "${data_dir}${situp_file}"
    reset_dayly
else
    level=$(cat "${data_dir}${level_file}")
    pt=$(cat "${data_dir}${pt_file}")
    goal=$(cat "${data_dir}${goal_file}")
    echo "Message: Dayly challange gain ${goal}XP"
fi

push=0
push_total=$(cat "${data_dir}${push_file}")
situp_total=$(cat "${data_dir}$situp_file")
squat_total=$(cat "${data_dir}$squat_file")

message=""

if [[ -f "${data_dir}${time_file}" ]]; then
    saved_day=$(cat "${data_dir}${time_file}")
    current_day="$(date +%D)"
    if [[ $saved_day != $current_day ]]; then
        echo "$current_day" > "${data_dir}${time_file}"
        goal=100
        xp=$(cat "${data_dir}${xp_dfile}")
        xpd=$((xp*5/$goal)) # point gained
        if [[ $xp -lt $goal ]]; then
            message="Failed dayly challange of $(cat ${data_dir}${time_file}) Penality: -1pt"
            echo -e "Message:\033[0;32m ${message}\033[0m"
            echo "$(date +%D): ${message}\033[0m" >> "${data_dir}${history_file}"
            pt=$((pt-1))
        else
            #xpd should be rounded
            message="Completed dayly challange of $(cat ${data_dir}${time_file}) Reward: +${xpd}pt"
            echo "$(date +%D): ${message}\033[0m" >> "${data_dir}${history_file}"
            echo -e "Message:\033[0;32m ${message}\033[0m"
            pt=$((pt+xpd))
        fi
        push=$(cat "${data_dir}${push_dfile}")
        squat=$(cat "${data_dir}${squat_dfile}")
        situp=$(cat "${data_dir}${situp_dfile}")
        # add past dayly to total
        push_total=$((push_total+push))
        echo "$push_total" > ${data_dir}$push_file
        squat_total=$((squat_total+squat))
        echo "$squat_total" > ${data_dir}$squat_file
        situp_total=$((situp_total+situp))
        echo "$situp_total" > "${data_dir}${situp_file}"

        xp=0
        push=0
        squat=0
        situp=0
        reset_dayly
    else
        xp=$(cat "${data_dir}${xp_dfile}")
        push=$(cat "${data_dir}${push_dfile}")
        squat=$(cat "${data_dir}${squat_dfile}")
        situp=$(cat "${data_dir}${situp_dfile}")
        if [[ $xp -ge $goal ]]; then
            message="Dayly challange completed! [${xp}/${goal}]XP"
            echo -e "Message:\033[0;32m ${message}\033[0m"
        fi

    fi
fi

read -p "Press Enter key to continue.."

choice=$(echo -e "PUSH-UP\nSIT-UP\nSQUAT\nSTATS\nLOG" | fzf)

if [[ $choice == "PUSH-UP" ]]; then
    push=$(cat "${data_dir}${push_dfile}")
    echo "PUSH-UP TODAY: $push"
    echo "PUSH-UP TOTAL: $push_total"
    read -p "ADD PUSH-UP:" add
    push=$((push+add))
    xp=$((xp+add))
fi
if [[ $choice == "SIT-UP" ]]; then
    echo "SIT-UP TODAY: $situp"
    echo "SIT-UP TOTAL: $situp_total"
    read -p "SIT-UP:" add
    situp=$((situp+add))
    xp=$((xp+add))
fi
if [[ $choice == "SQUAT" ]]; then
    echo "SQUAT TODAY: $squat"
    echo "SQUAT TOTAL: $squat_total"
    read -p "SQUAT:" add
    squat=$((squat+add))
    xp=$((xp+add))
fi

# check for level up
if [[ $pt -gt $level*2 ]]; then
    level=$((level+1))
    ngoa$((goal+5))
    #update the goal
    echo "$goal" > "${data_dir}${goal_file}"
    echo "NOTIFICATION: Level UP! you are now Level: $level"
    echo "$(date +%D): Level UP! you are now Level: $level" >> "${data_dir}${history_file}"
fi

# This should all be in a function update files
echo "$pt" > "${data_dir}${pt_file}"
echo "$level" > "${data_dir}${level_file}"
# save dayly
echo "$xp" > "${data_dir}${xp_dfile}"
echo "$push" > "${data_dir}${push_dfile}"
echo "$squat" > "${data_dir}${squat_dfile}"
echo "$situp" > "${data_dir}${situp_dfile}"

# stats and log come after status updates
if [[ $choice == "STATS" ]]; then
    echo "NAME: $USER"
    echo "LVL: $level"
    if [[ $xp -ge $goal ]]; then
        echo -e "XP: [\033[0;32m${xp}\033[0m/${goal}]"
    else
        echo -e "XP: [\033[0;31m${xp}\033[0m/${goal}]"
    fi

    echo "PUSH-UP TODAY: $push"
    push_total=$(cat "${data_dir}${push_file}")
    echo "PUSH-UP TOTAL: $push_total"

    echo "SIT-UP TODAY: $situp"
    situp_total=$(cat "${data_dir}${situp_file}")
    echo "SIT-UP TOTAL: $situp_total"

    echo "SQUAT TODAY: $squat"
    squat_total=$(cat ${data_dir}$squat_file)
    echo "SQUAT TOTAL: $squat_total"
fi
if [[ $choice == "LOG" ]]; then
    echo "LOG:"
    cat "${data_dir}${history_file}"
fi
