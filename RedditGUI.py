import tkinter as tk    #Graphics class for GUI
import praw             #Reddit's officially endorsed python class
import configparser     #Class to parse configuration files (Reddit credentials are stored in an external file 'credentials.ini')
import webbrowser       #Class to open the newly created post in the default web browser when it's done
import re               #Regex to validate urls when making link posts

#Custom dialog class (accepts a tkinter root window, and reddit connection as input)
class redditGUI:

    #Constructor. Assembles the labels and buttons, and creates the 3 input fields in the class's main scope so that the functions can call them
    def __init__(self,root,reddit):
        #Customize main window
        root.geometry("400x150")
        root.winfo_toplevel().title("Reddit poster")

        #Main Label
        message = tk.Label(root,text="New Reddit Post")
        message.grid(row=0,column=2,sticky=tk.N)

        #Subreddit field
        slabel = tk.Label(root,text="Subreddit: ")
        slabel.grid(row=1,column=1,sticky=tk.W)
        self.sub = tk.Entry(root,width=50)
        self.sub.grid(row=1,column=2)

        #Title Field
        tlabel = tk.Label(root,text="Title: ")
        tlabel.grid(row=2,column=1,sticky=tk.W)
        self.title = tk.Entry(root,width=50)
        self.title.grid(row=2,column=2)

        #Text field
        tlabel = tk.Label(root,text="Text/URL: ")
        tlabel.grid(row=3,column=1,sticky=tk.W)
        self.text = tk.Entry(root,width=50)
        self.text.grid(row=3,column=2)

        #Frame to put buttons in that takes up 1 'cell'
        buttonFrame = tk.Frame(root)
        buttonFrame.grid(row=4,column=2)

        #self post button
        sbutton = tk.Button(buttonFrame,text="Self Post",width=20,command=self.selfpost)
        sbutton.grid(row=1,column=1)

        #link post button
        lbutton = tk.Button(buttonFrame,text="Link Post",width=20,command=self.linkpost)
        lbutton.grid(row=1,column=2)

        #Quit button
        ebutton = tk.Button(root,text="Exit",width=20,command=self.quit)
        ebutton.grid(row=5,column=2)

    #Create new self post using the input and the reddit object, and open it in the default web browser
    def selfpost(self):
        if self.sub.get() and self.title.get():
            #Make post
            post = r.subreddit(self.sub.get()).submit(self.title.get(),selftext=self.text.get())
            webbrowser.open(f'https://redd.it/{post}')
            
            #Clear the fields after successfully posting
            self.title.delete(0,'end')
            self.text.delete(0,'end')

    #Create new link post using the input and the reddit object, and open it in the default web browser
    def linkpost(self):
        if self.sub.get() and self.title.get() and re.match(r"^https?://[^ ]+$",self.text.get()):
            #Make post
            post = r.subreddit(self.sub.get()).submit(self.title.get(),url=self.text.get())
            webbrowser.open(f'https://redd.it/{post}')

            #Clear the fields after successfully posting
            self.title.delete(0,'end')
            self.text.delete(0,'end')

    #Exit the script
    def quit(self):
        exit()
    
#Create main window
root = tk.Tk()

#Read in credentials from the config file (so that they aren't in the script itself), Then sign in with them
config = configparser.ConfigParser()
config.read('credentials.ini')
c = config['reddit']
r = praw.Reddit(client_id=c['clientID'],client_secret=c['clientSecret'],user_agent=c['userAgent'],username=c['username'],password=c['password'])

#Apply the custom dialog box using main tkinter window, and the reddit connection
redditGUI(root,r)

#Run
root.mainloop()
