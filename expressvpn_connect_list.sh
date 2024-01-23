is_integer() {
    [ "$1" -eq "$1" ] 2>/dev/null
}

echo "Custom start point (Smart by default if no user input given. Type Return/Enter to use default value): "
read user_input
if is_integer "$user_input"; then
	true
else
	user_input=2
	printf "No custom start.\n"
fi

echo -e "\e[1;32;49mTrying all nodes one by one...\n\e[30;1m"
readarray -t alias_array <<< "$(expressvpn list all | awk '{print $1}')"
counter=0
for i in "${alias_array[@]}"; do
	if [ "$counter" -ge "$user_input" ]; then
		expressvpn connect "$i"
		status="$(expressvpn status | awk 'NR==1 {print $1}' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g' | tr -d '\n' | tail -c 9)"
		if [ "$status" == "Connected" ]; then
			echo "$i"
			exit 0

			#echo "#$status" >> output_log.txt
			#exit 1
		else
			expressvpn disconnect
		fi
	fi
	((counter++))
done

echo "No successful connection to any node."
exit 1
