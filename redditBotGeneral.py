import praw             #Connection to reddit
import requests         #Getting webpages
import re               #Cleaning comments
import sqlite3          #For storing records of comments
import datetime         #For getting the current time

#Connect to reddit using stored credentials in file
##Credential File Format:
# APIID
# APISecret
# UserAgent
# Username
# Password
secret = open('creds.txt','r')
creds = secret.readlines()
secret.close()
r = praw.Reddit(client_id=creds[0].strip(),client_secret=creds[1].strip(),user_agent=creds[2].strip(),username=creds[3].strip(),password=creds[4].strip())
creds = None

#Script variables
subreddits = ['testingground4bots']                             #Target subreddits
droptime = datetime.datetime.utcnow().timestamp() - 5184000     #Current UTC time - 2 months (drop date for comments in database)
suffix = "\n\n---\n^I'm ^a ^bot!"                               #Message to append after comment replies made by this bot

#Connect to local database of comments
db = sqlite3.connect('commentdb.sqlite')
c = db.cursor()
c.execute("""
        CREATE TABLE IF NOT EXISTS comments (
            ID Varchar(7) PRIMARY KEY,
            created FLOAT,
            postText Varchar (20),
            subreddit Varchar (20),
            repliedTo BIT
        )""")

#Updates the database of comments from the target subreddit
def getComments(subreddit):
    #Get 100 most recent comments
    comments = list()
    for thing in r.subreddit(subreddit).comments():
        comments.append(thing)

    #For each of those, append them into the table if they aren't in there
    for comment in comments:
        c.execute(f"SELECT * FROM comments WHERE ID='{comment.id}'")
        res = c.fetchall()
        if not res:
            cleanText = re.sub(r'[^!a-zA-Z0-9_\-\. ]','', comment.body).strip()
            c.execute(f"INSERT INTO comments VALUES ('{comment.id}',{comment.created_utc},'{cleanText}','{subreddit}',0)")

    #Save database
    db.commit()

#Accepts regex to match, and the reply message
def replyToComments(criteria,message):
    #Get all comments from the database
    c.execute("SELECT * FROM comments")
    for comment in c.fetchall():

        #If comment meets the criteria and hasn't been replied to, reply to it and mark it as replied to
        if comment[4] == 0 and re.match(criteria,comment[2]):
            commentObj = r.comment(id=comment[0])
            commentObj.reply(message)
            c.execute(f"UPDATE comments SET repliedTo = 1 WHERE ID='{comment[0]}'")
            db.commit()

#Run the program!
def main():
    #Retrieve most recent comments from target subreddits
    for sub in subreddits:
        getComments(sub)

    #Erase all comments more than 2 months old, to keep file from growing indefinitely
    c.execute(f"DELETE FROM comments WHERE created < {droptime}")
    
    #Run the reply routine for each case
    replyToComments(r"^!test$",f"Hello world!{suffix}")
    replyToComments(r"^!never gonna give you up$",f"Never gonna let you down{suffix}")

    #Close the comment database
    db.close()

main()