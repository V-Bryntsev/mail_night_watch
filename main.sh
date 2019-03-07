#!/bin/bash
#exec 2>$0.err
#set -x


ABSOLUTE_FILENAME=`realpath "$0"`
HOME_DIR=`dirname "$ABSOLUTE_FILENAME"`
MAIL_DIR='/mnt/mail'
cd $MAIL_DIR
SPAM_LEARN_DIR='./_spam'
HAM_LEARN_DIR='./_ham'
mkdir -p _trash _spam

#Lern spamassassin by spam of last week and view different
sa-learn --dump magic  --dbpath /var/spool/amavisd/.spamassassin/   
sa-learn --no-sync --spam $SPAM_LEARN_DIR --dbpath /var/spool/amavisd/.spamassassin/
sa-learn --dump magic  --dbpath /var/spool/amavisd/.spamassassin/   
chown -R amavis:amavis /var/spool/amavisd/.spamassassin/


systemctl restart spamassassin.service 
systemctl restart amavisd

#Delete spam and trash of last week
rm -rf ./_spam/*
rm -rf ./_trash/*


#echo "Spam size of this week:"
#du -shc ./*/.maildir/.Junk | sed 's/\t\.\// /g ; s/\/\..*//g'
#SUM_JUNK=$(du -shc ./*/.maildir/.Junk | sed 's/\t\.\// /g ; s/\/\..*//g' | grep "итого")
#SUM_JUNK=$(du -shc ./*/.maildir/.Junk| grep "итого" | cut -f1)
#echo "$SUM_JUNK"


#echo "Trash size of this week:"
#SUM_TRASH=$(du -shc ./*/.maildir/.Trash  | grep "итого" | cut -f1)
#echo "$SUM_TRASH"

#Read exclude users from file
EXCLUDE=""
while read LINE
    do EXCLUDE="$EXCLUDE^$LINE$|"
done < $HOME_DIR/exclude_users
EXCLUDE=${EXCLUDE::-1}

#Read all maildir except exclude
USERS=`ls | tr "\t" "\n" | grep -v -E "$EXCLUDE"`

#Move spam and trash mails from users maildirs
for USER in $USERS; do
    find ./$USER/.maildir/.Junk*/cur/* ./$USER/.maildir/.Junk*/new/* -exec mkdir -p ./_spam/$USER \; -exec mv {} ./_spam/$USER \;
    find ./$USER/.maildir/.Trash*/cur/* ./$USER/.maildir/.Trash*/new/* -exec mkdir -p ./_trash/$USER \; -exec mv {} ./_trash/$USER \;
    rm -R ./$USER/.maildir/.Trash.*
done

#Collect ham mails from good staff
LIST=""
EXCLUDE=""

cd $MAIL_DIR
mkdir ./_ham
#Read exclude folsers and files from file 
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    EXCLUDE="$EXCLUDE$LINE|"
done < $HOME_DIR/exclude_folders_ham
EXCLUDE=${EXCLUDE::-1}

#Colleсt ham mails newer 7 days
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    echo $LINE
    HAMS=`find ./$LINE/ -type f -mtime -7  | grep -v -E "$EXCLUDE"`
    echo "$HAMS" | wc -l
    for HAM in $HAMS
	#copy ham files
	do cp -p $HAM ./_ham/
    done
done < $HOME_DIR/good_staff

#Lern spamassassin by ham of last week and view different
sa-learn --dump magic  --dbpath /var/spool/amavisd/.spamassassin/
sa-learn --no-sync --ham $HAM_LEARN_DIR --dbpath /var/spool/amavisd/.spamassassin/
sa-learn --dump magic  --dbpath /var/spool/amavisd/.spamassassin/
chown -R amavis:amavis /var/spool/amavisd/.spamassassin/

systemctl restart spamassassin.service
systemctl restart amavisd

rm -rf ./_ham/*

