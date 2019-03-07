# mail_night_watch
This is weekly script for spamassassin lern by spam and ham messages
## Algorithm:
1. Lern spamassassin by spam of last week
2. Delete spam and trash of last week
3. Read exclude users from file
4. Move spam and trash mails from users maildirs
5. Read exclude folsers and files for ham massages from file
6. Colleсt ham mails newer 7 days
7. Lern spamassassin by ham of last week and view different
## Files:
1. exclude_folders_ham - list of folsers and files, which will not enter to ham messages list  
2. exclude_users - list of users, which not enter to spam messages list  
3. good_staff.example - example of list users for collect ham messages  
4. main.sh - main script
