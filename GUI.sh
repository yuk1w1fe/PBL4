#!/bin/bash   
CheckGUI=$(sed -n '4p' ./PBL4/important.txt)
if [ "$CheckGUI" -eq 0 ]; then
CheckGUI=1
sed -i "4s/.*/$CheckGUI/" ./PBL4/important.txt
 screen -S 10758.my_session -d -m ./PBL4/MusicStart.sh
    python3 - <<END
import tkinter as tk
from tkinter import ttk
from tkinter import *
from tkinter.ttk import Progressbar
from PIL import Image, ImageTk
import subprocess
import os
from tkinter import filedialog
from tkinter import font
import mutagen 
from mutagen.mp3 import MP3 
from mutagen.id3 import ID3
from PIL import Image, ImageTk
from io import BytesIO

lengths = []
current_songs = []

co1 = "#ffffff"
co2 = "#3C1DC6"
co3 = "#111166"
co4 = "#CFC7F8" 
co5 = "#00FFFF"
co6 = "#FEF65B"

bg_co = "#030816"
yellow_co = "#FFEE08"
yellow2_co = "#6D680F"
blue_co = "#48C1C3"

window = tk.Tk()
window.title("My Music Player")
window.geometry('1250x700')
window.configure(background=co1)
window.resizable(width=False, height=False)


bold_font = font.Font(weight='bold')
italic_font = font.Font(size=30, slant='italic', weight = 'bold')
artist_font = font.Font(size=18)
counter_font = font.Font(size=16,slant='italic')
metadata_font = font.Font(size = 14)
left_frame_font = font.Font(weight = 'bold', size = 14)

#frames
left_frame = Frame(window, width=1050, height=439, bg=bg_co, highlightbackground=yellow_co, highlightthickness=2)
left_frame.grid(row=0, column=0)

right_frame = Frame(window, width=200, height=430, bg=co3)
right_frame.grid(row=0, column=1, sticky='nsew')

#create the notebook (tab manager) inside the right frame
notebook = ttk.Notebook(right_frame)
#notebook.pack(fill='both', expand=True)
notebook.grid(sticky='nsew')

# Create frames for each tab
frame1 = ttk.Frame(notebook)
frame2 = ttk.Frame(notebook)

# Add the frames to the notebook
notebook.add(frame1, text='Song List')
notebook.add(frame2, text='Favourites')

bar_frame=Frame(window, width=1250, height=30,highlightbackground=yellow_co, highlightthickness=2)
bar_frame.grid(row=1, column=0, columnspan=2, sticky='nsew')

down_frame = Frame(window, width=1250, height=300,bg=bg_co,highlightbackground=yellow_co)
down_frame.grid(row=2, column=0, columnspan=2, sticky='nsew')

listbox = Listbox(frame1,selectmode=SINGLE,font=("Arial 12 bold"),width=22,height=20,bg=bg_co,fg=co1, highlightbackground=yellow_co, highlightthickness=2, highlightcolor=yellow_co)
listbox.grid(row=0,column=0)

fav_listbox = Listbox(frame2,selectmode=SINGLE,font=("Arial 12 bold"),width=22,height=20,bg=bg_co,fg=co1, highlightbackground=yellow_co, highlightthickness=2, highlightcolor=yellow_co)
fav_listbox.grid(row=0,column=0)

style = ttk.Style()
# Change progressbar's color
style.configure("TProgressbar", troughcolor=bg_co,background=blue_co)

# For notebook's tabs
style.configure('TNotebook', background=bg_co)

# Change the background of the tab when it's not selected
style.configure('TNotebook.Tab', background=blue_co)
style.configure('TNotebook.Tab', foreground=yellow_co)
style.configure('TNotebook.Tab', font=('Arial', '15'))

# Change the background of the tab when it's selected
style.map('TNotebook.Tab', background=[('selected', yellow_co)])
style.map('TNotebook.Tab', foreground=[('selected', blue_co)])

progress = Progressbar(bar_frame, orient=HORIZONTAL, length=1250, mode='determinate') 
progress.grid(row=0,column=0,columnspan=2)

#tooltip
def create_tooltip(widget, text):
    def enter(event=None):
        x, y, _, _ = widget.bbox("insert")
        x += widget.winfo_rootx() + 60
        y += widget.winfo_rooty() + 25
        tooltip_window = tk.Toplevel(widget)
        tooltip_window.wm_overrideredirect(True)
        tooltip_window.wm_geometry(f"+{x}+{y}")
        label = tk.Label(tooltip_window, text=text, background="#ffffff", relief="solid", borderwidth=1)
        label.pack(ipadx=1)
        widget.tooltip_window = tooltip_window
    def leave(event=None):
        widget.tooltip_window.destroy()
    widget.bind("<Enter>", enter)
    widget.bind("<Leave>", leave)
    
def create_fav_tooltip(widget, text):
    def enter(event=None):
        x, y, _, _ = widget.bbox("insert")
        x += widget.winfo_rootx() + -110
        y += widget.winfo_rooty() + 60
        tooltip_window = tk.Toplevel(widget)
        tooltip_window.wm_overrideredirect(True)
        tooltip_window.wm_geometry(f"+{x}+{y}")
        label = tk.Label(tooltip_window, text=text, background="#ffffff", relief="solid", borderwidth=1)
        label.pack(ipadx=1)
        widget.tooltip_window = tooltip_window
    def leave(event=None):
        widget.tooltip_window.destroy()
    widget.bind("<Enter>", enter)
    widget.bind("<Leave>", leave)

#these variables are used for the counter
hour = 0
minute = 0
second = 0
hours = 0
mins = 0
seconds = 0


#these variables are used for metadata
song_name = ""
artists_name = ""
album_name = ""
album_cover = None
genre = ""
release_date = ""

#this variable is used for favourites
is_in_fav = False

#create labels
song_name_label = Label(down_frame, text="No song found", bg=bg_co,fg=yellow_co, font=italic_font)
song_name_label.place(x=585-3*75, y=10)
artists_name_label = Label(down_frame, text="Please choose one (or more) ＼(٥⁀▽⁀ )／", bg=bg_co,fg=yellow2_co, font=artist_font)
artists_name_label.place(x=585-3*75, y=85)
length_label = Label(down_frame, text=f'-  {hour:02d}:{minute:02d}:{second:02d}', bg=bg_co,fg=yellow_co, font=counter_font)
length_label.place(x=170, y=185)
count_label = Label(down_frame, text=f'{hour:02d}:{minute:02d}:{second:02d}', bg=bg_co,fg=yellow_co, font=counter_font)
count_label.place(x=60, y=185)
 
#label on left frame
lf_song_name_label = Label(left_frame, text = "", bg = bg_co,fg=blue_co, font = metadata_font)
lf_song_name_label.place(x = 600, y = 30)
lf_artists_name_label = Label(left_frame, text = "", bg = bg_co,fg=blue_co, font = metadata_font)
lf_artists_name_label.place(x = 600, y = 80)
lf_album_name_label = Label(left_frame, text = "", bg = bg_co,fg=blue_co, font = metadata_font)
lf_album_name_label.place(x = 600, y = 130)
lf_genre_label = Label(left_frame, text = "", bg = bg_co,fg=blue_co, font = metadata_font)
lf_genre_label.place(x = 600, y = 180)
lf_release_date_label = Label(left_frame, text = "", bg = bg_co,fg=blue_co, font = metadata_font)
lf_release_date_label.place(x = 600, y = 230)
img_label = Label(left_frame, highlightbackground=yellow_co,bg = bg_co)
img_label.place(x = 10, y = 10)

lf_1_label = Label(left_frame, text="", bg=bg_co,fg=yellow_co, font=left_frame_font)
lf_1_label.place(x=440, y=30)
lf_2_label = Label(left_frame, text="", bg=bg_co,fg=yellow_co, font=left_frame_font)
lf_2_label.place(x=440, y=80)
lf_3_label = Label(left_frame, text="", bg=bg_co,fg=yellow_co, font=left_frame_font)
lf_3_label.place(x=440, y=130)
lf_4_label = Label(left_frame, text="", bg=bg_co,fg=yellow_co, font=left_frame_font)
lf_4_label.place(x=440, y=180)
lf_5_label = Label(left_frame, text="", bg=bg_co,fg=yellow_co, font=left_frame_font)
lf_5_label.place(x=440, y=230)

def reset_label():
    global hour, minute, second
    second = 0
    minute = 0
    hour = 0
    count_label.config(text=f'{hour:02d}:{minute:02d}:{second:02d}')

#convert time
def audio_duration(length): 
    hours = length // 3600  # calculate in hours 
    length %= 3600
    mins = length // 60  # calculate in minutes 
    length %= 60
    seconds = length  # calculate in seconds 
  
    return hours, mins, seconds  # returns the duration 

def add_to_fav():
    global is_in_fav
    is_in_fav = True
    check_fav_state()
    #Open the file in append mode ('a')
    with open('./PBL4/fav.txt', 'a') as f:
        # Write the string to the file
        f.write(current_songs[index] + '\n')
        
    show_fav()
    
def remove_from_fav():
    global is_in_fav
    is_in_fav = False
    check_fav_state()
    with open('./PBL4/fav.txt', 'r') as f:
        lines = f.readlines()
    # Open the file in write mode and write back all lines except the one to remove
    with open('./PBL4/fav.txt', 'w') as f:
        for line in lines:
            if line.strip("\n") != current_songs[index]:
                f.write(line)
                
    show_fav()
    
def check_if_add_or_remove():
    global is_in_fav
    #neu chua co trong favourites thi them vao
    if is_in_fav == False:
        add_to_fav()
    else:
        remove_from_fav()
        
    show_fav()

def show_fav():
    with open('./PBL4/fav.txt', 'r') as f:
        lines = f.readlines()
    fav_listbox.delete(0, tk.END)  
    for line in lines:          
        last_slash_index = line.rfind("/")
        if last_slash_index != -1:
            cut_string = line[last_slash_index + 1:]
            fav_listbox.insert(tk.END, cut_string.strip())
            fav_listbox.itemconfig(tk.END, {'fg': yellow_co})
            
    #kiem tra xem co can doi mau ban nhac nao khong
    if is_in_fav == True:
        fav_index = 0
        with open('./PBL4/fav.txt', 'r') as f:
            lines = f.readlines()
   
        for line in lines:
            if current_songs[index] == line.strip():
                break
            else:
                fav_index = fav_index + 1
              
        fav_listbox.itemconfig(fav_index, {'fg': blue_co})
        

            
window.bind('<Visibility>', show_fav())

def check_fav_state():
    global is_in_fav
    if is_in_fav == True:
        favourite_button.config(image = img_10)
        create_fav_tooltip(favourite_button, "Remove from Favourites")
    else:
        favourite_button.config(image = img_11)
        create_fav_tooltip(favourite_button, "Add to Favourites")
        
def check_if_already_in_fav():
    global is_in_fav
    with open('./PBL4/fav.txt', 'r') as f:
        lines = f.readlines()
    is_in_fav = False
    for line in lines:    
        #neu da co trong favourites   
        if(current_songs[index] == line.strip()):
            is_in_fav = True
            break
        #neu chua co trong favourites
        else:
            is_in_fav = False
    check_fav_state()
    show_fav()
        

def set_metadata():
    global song_name, artists_name, album_name, genre, release_date, album_cover, hours, mins, seconds, index
    song_name = ID3(current_songs[index]).get('TIT2')
    artists_name = ID3(current_songs[index]).get('TPE1')
    album_name = ID3(current_songs[index]).get('TALB')
    genre = ID3(current_songs[index]).get('TCON')
    release_date = ID3(current_songs[index]).get('TDRC')
    
    #set to labels
    song_name_label.config(text=song_name if song_name else "Unknown song")
    artists_name_label.config(text=artists_name if artists_name else "Unknown artist")

    #set to left frame labels
    lf_1_label.config(text="Title:")
    lf_2_label.config(text="Artist:")
    lf_3_label.config(text="Album:")
    lf_4_label.config(text="Genre:")
    lf_5_label.config(text="Release Date:")


    lf_song_name_label.config(text=song_name if song_name else "Unknown song")
    lf_artists_name_label.config(text=artists_name if artists_name else "Unknown artist")
    lf_album_name_label.config(text=album_name if album_name else "unknown album")
    lf_genre_label.config(text=genre if genre else "Unknown genre")
    lf_release_date_label.config(text=release_date if release_date else "Unknown release date")
    
    
    #put song's length and reset the counter
    hours, mins, seconds = audio_duration(int(MP3(current_songs[index]).info.length)) 
    #reset_label()
    length_label.config(text='-  {:02d}:{:02d}:{:02d}'.format(hours, mins, seconds))
    
    #album image
    # Open an image file
    album_cover = ID3(current_songs[index]).get('APIC:')
    #check if there is album cover
    if album_cover is not None:
        image_data = BytesIO(album_cover.data)
        img = Image.open(image_data)
    else:
        img = Image.open("./PBL4/Icons/bocc.jpg") 
    
    width, height = img.size
    new_size = (380, 380)
    img = img.resize(new_size)

    #desired_size = (100, 100)
    #img = img.resize(desired_size)

    # Convert the Image object to a PhotoImage object (Tkinter-compatible)
    photo = ImageTk.PhotoImage(img)

    # Create a Label widget for the image
    img_label.config(image = photo)
    img_label.config(highlightthickness=2)
    img_label.image = photo  # keep a reference to the image to prevent it from being garbage collected
    #end here

is_playing = False
update_running = False
is_next = False
is_prev = False
index = 0
loop = False
update_counter_running = False

def seek_forward_label():
    global hour, minute, second, hours, mins, seconds, update_counter_running
    #neu +10.127s se vuot qua thoi gian cua bai hat
    if is_next and not is_prev:
        if hour*3600 + minute*60 + second + 10.127 >= int(MP3(current_songs[index]).info.length):
            second = seconds
            minute = mins
            hour = hours
        #neu +10.127s se khong vuot qua thoi gian cua bai hat, tuc la seek forward binh thuong
        else: 
            if second+10.127 >= 60:
                minute += 1
                second = second + 10.127 - 60
            else:
                second += 10.127
        count_label.config(text=f'{hour:02d}:{minute:02d}:{int(second):02d}')
        if not update_counter_running:
            down_frame.after(100, update_counter)
    
def seek_backward_label():
    global hour, minute, second, update_counter_running
    #neu -9.93s se dua thoi gian ve < 0
    if second <= 9.93 and minute == 0 and hour == 0:
        second = 0
    #neu -9.93s se khong dua thoi gian ve < 0, tuc la seek backward binh thuong
    if second >= 9.93:
        second -= 9.93
    elif second < 9.93:
        if minute > 0:
            minute -= 1
            second = 60 - (9.93 - second)
        elif minute == 0 and hour > 0:
            minute = 59
            hour -= 1
    
    count_label.config(text=f'{hour:02d}:{minute:02d}:{int(second):02d}') 
    if not update_counter_running:
         down_frame.after(100, update_counter)
    
def run_normal():
    global hour, minute, second,is_playing,progress
    if second >= 60:
        minute += 1
        #second = second - 60
        second = 0
    if minute == 60:
        hour += 1
        minute = 0
    second += 0.1
    count_label.config(text=f'{hour:02d}:{minute:02d}:{int(second):02d}')
    
def check_exceed():
    global hour, minute, second
    if second >= 60:
        minute += 1
        #second = second - 60
        second = 0
    if minute == 60:
        hour += 1
        minute = 0

def update_counter():
    global is_playing,progress,update_running,lengths,is_next,is_prev,index, update_counter_running
    update_counter_running = True
    if hour*3600 + minute*60 + second <= int(MP3(current_songs[index]).info.length) and update_running:
        run_normal()
        down_frame.after(100, update_counter)  # Schedule next update after 0.1s (100ms)
    elif hour*3600 + minute*60 + second > int(MP3(current_songs[index]).info.length):
        reset_label()
        update_counter_running = False
    
    

def update_progress():
        global is_playing,progress,update_running,lengths,is_next,is_prev,index
        if progress['value'] < 100 and progress['value'] >=0 and update_running:
            if is_next and not is_prev:
            	progress['value'] +=1020.0/lengths[index]
            	seek_forward_label()
            	is_next = False
            elif is_prev and not is_next:
                progress['value'] -=980.0/lengths[index]
                seek_backward_label()
                is_prev = False
            else:
            	progress['value'] +=10.0/lengths[index]
            bar_frame.after(100,update_progress) 
        elif progress['value'] >= 100:
            subprocess.call(["./PBL4/next_song.sh"])
            with open('./PBL4/important.txt', 'r') as link_file:
                lines = link_file.readlines()
            index = int(lines[1])-1;
            progress['value']=0
            reset_label()
            play_button.config(image=img_1)
            is_playing = False
            update_running = False
            if loop:
               toggle_play()
        elif progress['value'] < 0:
            progress['value'] = 0
            bar_frame.after(100,update_progress) 

def update_counter_and_progress():
    update_progress()
    update_counter()

def toggle_play():
    with open('./PBL4/LinkAudio.m3u','r') as file:
       content = file.read()
    if content:
       global is_playing,progress, update_running,lengths,is_next,is_prev
       if not is_playing:
          play_button.config(image=img_4)
          create_tooltip(play_button, "Pause")
          is_playing = True 
       else:
          play_button.config(image=img_1)
          create_tooltip(play_button, "Play")
          is_playing = False    
       if update_running:            
          update_running = False
       else:
          update_running = True
       set_metadata()
       check_if_already_in_fav()
       mark_playing_song()
       update_counter_and_progress()
    subprocess.call(["./PBL4/play_pause.sh"])

def toggle_ChooseFile():
    global is_playing,progress,index
    if is_playing:      
       toggle_play()
    subprocess.call(["./PBL4/ChooseFile.sh"])
    with open('./PBL4/important.txt') as link_file:
        chosen = link_file.readlines()    
    if chosen[2].strip() == 'true':    
       progress['value'] = 0
       reset_label() 
       index = 0    
       lengths.clear()
       current_songs.clear()
       with open('./PBL4/LinkAudio.m3u', 'r') as link_file:
           lines = link_file.readlines()
       listbox.delete(0, tk.END)  
       for line in lines:          
           lengths.append(int(MP3(line.strip()).info.length)) 
           current_songs.append(line.strip())
           
           check_if_already_in_fav()
           set_metadata()
           mark_playing_song()
 
def mark_playing_song():
    global index
    with open('./PBL4/LinkAudio.m3u', 'r') as link_file:
        lines = link_file.readlines()
    listbox.delete(0, tk.END)  
    for line in lines:          
        last_slash_index = line.rfind("/")
        if last_slash_index != -1:
            cut_string = line[last_slash_index + 1:]
            listbox.insert(tk.END, cut_string.strip())
            listbox.itemconfig(tk.END, {'fg': yellow2_co})
        
    # Get the current value of the item at index 0
    current_value = listbox.get(index)

    # Add the "►" prefix to the current value
    new_value = "► " + current_value

    # Update the item at index 0 with the new value
    listbox.delete(index)
    listbox.insert(index, new_value)
    listbox.itemconfig(index, {'fg': yellow_co})  


def toggle_next():
    global is_next
    if not is_playing:
       toggle_play()
    with open('./PBL4/LinkAudio.m3u','r') as file:
       content = file.read()   
    if content:   
       is_next = True
       subprocess.call(["./PBL4/Jump_next.sh"])
    
def toggle_prev():
    global is_prev
    if not is_playing:
       toggle_play()
    with open('./PBL4/LinkAudio.m3u','r') as file:
       content = file.read()
    if content:      
       is_prev = True
       subprocess.call(["./PBL4/Jump_prev.sh"])

def toggle_previous_song():   
    global progress,index,is_playing,update_running
    progress['value']=0
    reset_label()
    play_button.config(image=img_1)
    is_playing = False
    update_running = False
    subprocess.call(["./PBL4/previous_song.sh"])
    with open('./PBL4/important.txt', 'r') as link_file:
        lines = link_file.readlines()
    index = int(lines[1])-1;
    set_metadata()
    check_if_already_in_fav()
    mark_playing_song()
    
def toggle_next_song():
    global progress,index,is_playing,update_running
    progress['value']=0
    reset_label()
    play_button.config(image=img_1)
    is_playing = False
    update_running = False
    subprocess.call(["./PBL4/next_song.sh"])
    with open('./PBL4/important.txt', 'r') as link_file:
        lines = link_file.readlines()
    index = int(lines[1])-1;
    set_metadata()
    check_if_already_in_fav()
    mark_playing_song()

def toggle_loop():
    global loop
    if loop:
      loop_button.config(image=img_8)
      create_tooltip(loop_button, "Loop")
      loop = False
    else:
      loop_button.config(image=img_9)
      create_tooltip(loop_button, "No loop")
      loop = True
def change_volume(value):
    if int(value) == 0:
       volumn_label.config(image=img_13)
       volumn_label.place(x=971,y=168)
    else:
       volumn_label.config(image=img_12)   
       volumn_label.place(x=965,y=168)
    subprocess.call(["./PBL4/change_volume.sh", str(value)])
def close_window():
    global is_playing
    if is_playing:
       toggle_play()  
    with open('./PBL4/LinkAudio.m3u', 'r+') as file:
       file.truncate(0)
    with open('./PBL4/important.txt', 'r+') as file:
       lines = file.readlines()
       if len(lines) == 4:        
          lines[3]="0"
          file.seek(0)
          file.writelines(lines)
    window.destroy()   
img_1= Image.open('./PBL4/Icons/play_h.png')
img_1=img_1.resize((60, 60))
img_1=ImageTk.PhotoImage(img_1)
play_button = Button(down_frame,width=70,height=70,borderwidth=0, highlightthickness=0,image=img_1,padx=10,bg=bg_co,activebackground=bg_co,font="Ivy 10", command=toggle_play)
create_tooltip(play_button, "Play")
play_button.place(x=585, y=160)

img_2= Image.open('./PBL4/Icons/next_h.png')
img_2=img_2.resize((60, 60))
img_2=ImageTk.PhotoImage(img_2)
next_button = Button(down_frame,width=70,height=70,borderwidth=0, highlightthickness=0,image=img_2,padx=10,bg=bg_co,activebackground=bg_co,font="Ivy 10",command=toggle_next)
create_tooltip(next_button, "Seek 10s")
next_button.place(x=585+80, y=160)

img_3= Image.open('./PBL4/Icons/prev_h.png')
img_3=img_3.resize((60, 60))
img_3=ImageTk.PhotoImage(img_3)
prev_button = Button(down_frame,width=70,height=70,borderwidth=0, highlightthickness=0,image=img_3,padx=10,bg=bg_co,activebackground=bg_co,font="Ivy 10",command=toggle_prev)
create_tooltip(prev_button, "Seek -10s")
prev_button.place(x=585-80, y=160)

img_4= Image.open('./PBL4/Icons/pause_h.png')
img_4=img_4.resize((74, 74))
img_4=ImageTk.PhotoImage(img_4)

img_5= Image.open('./PBL4/Icons/ChooseFile.png')
img_5=img_5.resize((75, 75));
img_5=ImageTk.PhotoImage(img_5)
ChooseFile_button = Button(down_frame,width=70,height=70,borderwidth=0, highlightthickness=0,image=img_5,padx=10,bg=bg_co,activebackground=bg_co,font="Ivy 10",command=toggle_ChooseFile)
create_tooltip(ChooseFile_button, "Choose file")
ChooseFile_button.place(x=585-3*80, y=160)

img_6= Image.open('./PBL4/Icons/previous_song.png')
img_6=img_6.resize((60, 60))
img_6=ImageTk.PhotoImage(img_6)
previous_button = Button(down_frame,width=70,height=70,borderwidth=0, highlightthickness=0,image=img_6,padx=10,bg=bg_co,activebackground=bg_co,font="Ivy 10",command=toggle_previous_song)
create_tooltip(previous_button, "Previous song")
previous_button.place(x=585-2*80, y=160)

img_7= Image.open('./PBL4/Icons/next_song.png')
img_7=img_7.resize((60, 60))
img_7=ImageTk.PhotoImage(img_7)
next_button = Button(down_frame,width=70,height=70,borderwidth=0, highlightthickness=0,image=img_7,padx=10,bg=bg_co,activebackground=bg_co,font="Ivy 10",command=toggle_next_song)
create_tooltip(next_button, "Next song")
next_button.place(x=585+2*80, y=160)

img_8= Image.open('./PBL4/Icons/looped.png')
img_8=img_8.resize((60, 37));
img_8=ImageTk.PhotoImage(img_8)
loop_button = Button(down_frame,width=70,height=70,borderwidth=0, highlightthickness=0,image=img_8,padx=10,bg=bg_co,activebackground=bg_co,font="Ivy 10",command=toggle_loop)
create_tooltip(loop_button, "Loop")
loop_button.place(x=585+3*80, y=160)

img_9= Image.open('./PBL4/Icons/loop.png')
img_9=img_9.resize((60, 37))
img_9=ImageTk.PhotoImage(img_9)

img_10 = Image.open('./PBL4/Icons/in.png')
img_10 = img_10.resize((80, 80))
img_10 = ImageTk.PhotoImage(img_10)

img_11 = Image.open('./PBL4/Icons/not_in.png')
img_11 = img_11.resize((80, 80))
img_11 = ImageTk.PhotoImage(img_11)

favourite_button = Button(down_frame,width=60,height=60,borderwidth=0, highlightthickness=0,image=img_11,padx=0,bg=bg_co,activebackground=bg_co,font="Ivy 10",command=check_if_add_or_remove)
create_fav_tooltip(favourite_button, "Add to favourites")
favourite_button.place(x=585-4*75, y=-5)

img_12=Image.open('./PBL4/Icons/volumn.png')
img_12=img_12.resize((60,60))
img_12=ImageTk.PhotoImage(img_12)

img_13=Image.open('./PBL4/Icons/mutevolumn.png')
img_13=img_13.resize((60,60))
img_13=ImageTk.PhotoImage(img_13)

volumn_label = Label(down_frame,image=img_12,bg=bg_co)
volume_slider = tk.Scale(down_frame, from_=0, to=100,width=10, orient=tk.HORIZONTAL, showvalue=0,command=lambda value: change_volume(value))
volume_slider.set(50)
create_tooltip(volume_slider, "Change volume")
volume_slider.place(x=585+6*75,y=190)

window.protocol("WM_DELETE_WINDOW", close_window)

window.mainloop()
END
fi

