script_dir="$(dirname "$(realpath "$0")")"

python3 $script_dir/parserTasks/generateTasksList.py -c -t

