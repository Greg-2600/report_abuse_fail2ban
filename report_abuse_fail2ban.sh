#!/bin/bash

my_ip="1.1.1.1"
log_file='/var/log/fail2ban.log'


get_abuse_email() {
# given an IP as an arg, lookup and return abuse email

	ip=$1               # assign arg as ip

	whois $ip|          # perform whois lookup	
	grep abuse-mailbox| # remove everything but abuse email line
	head -1|            # keep the first one
	awk {'print $2'}    # just email address
}


get_email_subject() {
# given date and time, build a email subject string

	date=$1 # assign arg as date
	time=$2 # assign arg as time

	subject="ABUSE: ssh brute force attack in progress $date $time"
	echo "$subject"
}


get_email_body() {
# given ip, date, and time as arg, build and email body

	ip=$1
	date=$2
	time=$3

	echo "Hello, I am a bot."
	echo "A host in your network with IP address: $ip performed a ssh brute force attack against my computer."
        echo "My IP is: ($my_ip) and the attack occured on $date at $time from $ip."
	echo ""
	echo "Summary:"
	echo "Attack Type: SSH brute force"
	echo "Attacking IP: $ip"
	echo "Attack Date Time: $date $time"
	echo ""
	echo "Thank you for looking into this issue, and I hope you have a great day."
}


main() {
# watch for changes in the fail2ban log file
# build an email each time an IP is banned

	tail -f --follow=name ${log_file}| # read the file as it is updated and follow log rotate
	grep --line-buffered "Ban"|        # only show Bans and use grep's line buffering mode 
	while read ban; do                 # enter loop
		date=$(echo "$ban"|awk {'print $1'}) # assign date
		time=$(echo "$ban"|awk {'print $2'}) # assign time
		ip=$(echo "$ban"|awk {'print $8'})   # assign IP

		abuse_email=$(get_abuse_email $ip)   # try to lookup abuse contact
		if [ "$abuse_email" ]; then          # if there is an abuse contact	

			# build subject and body of email
			email_subject=$(get_email_subject $date $time)
			email_body=$(get_email_body $ip $date $time)
		fi
	done
}


main
