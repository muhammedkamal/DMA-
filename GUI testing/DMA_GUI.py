'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
*	Project			: 		A GUI for a DMA simulator project
*	Author 			: 		Fares Salem
*	E-Mail 			: 		faressalem@pm.me
*	Organization 	: 		Faculty of Engineering - Ain Shams University
* 	Date 			:       12-Dec-19
*	Last-Mod		:       
*	
*	Notes			:		1) please adjust the tab size of the editor to 4
                            2) when I wrote this code just me and GOD knew what it meant,
                               now it's just GOD.
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
# Defining Python Source Code Encodings, DO NOT REMOVE.
# ! /usr/bin/env python
# -*- coding: utf-8 -*-

import tkinter as tk
import tkinter.ttk as ttk
import sys
import os
import subprocess

def create_window():            # no time to care about what's happening here
    global val, w, root
    root = tk.Tk()              # creating a tkinter window
    top = MainFrame(root)
    init(root, top)
    root.mainloop()             # infinite loop
 
def destroy_window():           # Function which closes the window.
    global top_level
    top_level.destroy()
    top_level = None

def init(top, gui, *args, **kwargs):    
    global w, top_level, root
    w = gui
    top_level = top
    root = top

####################   BUTTONS FUNCTIONS   ####################
def RUN_ME(b1):
    print("RUN ME CLICKED") 
    sys.stdout.flush()
    
    # save what's written in the GUI's editor to an external .txt
    save_binary()            
    save_io1()
    save_io2()
    
    # call Modelsim and start simulation, run x time steps
    # you may add a variable (x) feature to the GUI :) using .format()
    # the python environment is suspended until the simulation exits
    # so you can't interact with the GUI while the simulation is running :(
    subprocess.run(["vsim", "-c", "-do", "run 6000",  "work.processor_tb", "-c", "-do", "exit"])
    
    # after the simulation exits, import the memory contents to the GUI
    Import_Processor_Status()
    Import_DMA_Status()
    Import_Memory_Status()
    Import_IO1_Status()
    Import_IO2_Status()
    
def RUN_ONE_STEP(b1):                  
    print("RUN ONE STEP CLICKED")
    sys.stdout.flush()
    
    save_binary()             
    save_io1()
    save_io2()

# edit to run for one cycle and when clicked again to run additional
# cycles again on the previous cycle, not to restart the simulation 
# you may restart but run multiples of clock cycle each time using a counter to know how much
# 
# open new command prompt, run vsim and continue reading inputs from the gui at the same time

# setting up the simulation environment for the first time
    
    clock = 100
    # if (MainFrame.step_count == 0):      
    # MainFrame.step_count = 1        
    subprocess.run(["vsim", "-c", "-do", "run {}".format(MainFrame.step_count*clock),  "work.processor_tb", "-c", "-do", "exit"])
    MainFrame.step_count += 1
    # else:  
    
    # we want to call these after running each one clock cycle
    Import_Processor_Status()
    Import_DMA_Status()
    Import_Memory_Status()
    Import_IO1_Status()
    Import_IO2_Status()
    
    
def IO1_INT(b1):
    print("IO1_INT CLICKED")
    sys.stdout.flush()
    save_binary()             
    save_io1()
    save_io2()
    
    cwd = os.getcwd()
    file = open('{}/interrupt1.txt'.format(cwd), 'w')
    file.write("1")
    file.close()

  
    
def IO2_INT(b1):
    print("IO2_INT CLICKED")
    sys.stdout.flush()
    save_binary()             
    save_io1()
    save_io2()
    
    cwd = os.getcwd()
    file = open('{}/interrupt2.txt'.format(cwd), 'w')
    file.write("1")
    file.close()


    
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
def Import_Processor_Status():
     cwd = os.getcwd()
     file = open('{}/Memory.txt'.format(cwd))
     w.processor.configure(state='normal')
     w.processor.delete('1.0', 'end')
     w.processor.insert('1.0', file.read())
     w.processor.configure(state='disabled')
    
def Import_DMA_Status():
     cwd = os.getcwd()
     file = open('{}/DMA.txt'.format(cwd))
     w.dma.configure(state='normal')
     w.dma.delete('1.0', 'end')
     w.dma.insert('1.0', file.read())
     w.dma.configure(state='disabled') 
    
def Import_Memory_Status():
     cwd = os.getcwd()
     file = open('{}/RAM.txt'.format(cwd))
     w.ram.configure(state='normal')
     w.ram.delete('1.0', 'end')
     w.ram.insert('1.0', file.read())
     w.ram.configure(state='disabled') 

def Import_IO1_Status():
     cwd = os.getcwd()
     file = open('{}/IO1_status.txt'.format(cwd))
     w.io1.configure(state='normal')
     w.io1.delete('1.0', 'end')
     w.io1.insert('1.0', file.read())
     w.io1.configure(state='disabled')
     
     
def Import_IO2_Status():
     cwd = os.getcwd()
     file = open('{}/IO2_status.txt'.format(cwd))
     w.io2.configure(state='normal')
     w.io2.delete('1.0', 'end')
     w.io2.insert('1.0', file.read())
     w.io2.configure(state='disabled') 
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
def save_binary():
    cwd = os.getcwd()
    file = open('{}/binary.txt'.format(cwd), 'w')
    file.write(w.binary.get("1.0","end-1c"))


def save_io1():
    cwd = os.getcwd()
    file = open('{}/init_io1.txt'.format(cwd), 'w')
    file.write(w.init_io1.get("1.0","end-1c"))

 
def save_io2():
    cwd = os.getcwd()
    file = open('{}/init_io2.txt'.format(cwd), 'w')
    file.write(w.init_io2.get("1.0","end-1c"))

 
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
class MainFrame:
    cwd = os.getcwd()
    file = open('{}/interrupt1.txt'.format(cwd), 'w')
    file.write("0")
    file = open('{}/interrupt2.txt'.format(cwd), 'w')
    file.write("0")
    file.close()
    step_count = 1
    def __init__(self, top=None):
        '''This class configures and populates the toplevel window.
           top is the toplevel containing window.'''
        _bgcolor = '#d9d9d9'  # X11 color: 'gray85'
        _fgcolor = '#000000'  # X11 color: 'black'
        _compcolor = '#d9d9d9' # X11 color: 'gray85'
        _ana1color = '#d9d9d9' # X11 color: 'gray85'
        _ana2color = '#ececec' # Closest X11 color: 'gray92'
        self.style = ttk.Style()
        if sys.platform == "win32":
            self.style.theme_use('winnative')
        self.style.configure('.',background=_bgcolor)
        self.style.configure('.',foreground=_fgcolor)
        self.style.configure('.',font="TkDefaultFont")
        self.style.map('.',background=[('selected', _compcolor), ('active',_ana2color)])

        top.geometry("763x686+250+10")
        top.minsize(120, 1)
        top.maxsize(2970, 881)
        top.resizable(0, 0)
        top.title("A Bahlool DMA :D")
        top.configure(background="#292929")
        top.configure(cursor="top_left_arrow")
        top.configure(highlightbackground="#d9d9d9")
        top.configure(highlightcolor="black")
        cwd = os.getcwd()
        top.wm_iconbitmap(r'{}\icon.ico'.format(cwd))
        
        self.style.configure('TNotebook.Tab', background=_bgcolor)
        self.style.configure('TNotebook.Tab', foreground=_fgcolor)
        self.style.map('TNotebook.Tab', background=[('selected', _compcolor), ('active',_ana2color)])
        
        ####################   NOTE BOOKS   ####################
        
        self.TNotebook1 = ttk.Notebook(top)
        self.TNotebook1.place(relx=0.013, rely=0.015, relheight=0.49, relwidth=0.32)
        self.TNotebook1.configure(takefocus="")
        self.TNotebook1.configure(cursor="fleur")
        self.TNotebook1_t0 = tk.Frame(self.TNotebook1)
        self.TNotebook1.add(self.TNotebook1_t0, padding=3)
        self.TNotebook1.tab(0, text="binary",compound="left",underline="-1",)
        self.TNotebook1_t0.configure(background="#d9d9d9")
        self.TNotebook1_t0.configure(highlightbackground="#d9d9d9")
        self.TNotebook1_t0.configure(highlightcolor="black")
        self.TNotebook1_t1 = tk.Frame(self.TNotebook1)
        self.TNotebook1.add(self.TNotebook1_t1, padding=3)
        self.TNotebook1.tab(1, text="INIT I/O 1", compound="none", underline="-1",)
        self.TNotebook1_t1.configure(background="#d9d9d9")
        self.TNotebook1_t1.configure(highlightbackground="#d9d9d9")
        self.TNotebook1_t1.configure(highlightcolor="black")
        self.TNotebook1_t2 = tk.Frame(self.TNotebook1)
        self.TNotebook1.add(self.TNotebook1_t2, padding=3)
        self.TNotebook1.tab(2, text="INIT I/O 2", compound="none", underline="-1",)
        self.TNotebook1_t2.configure(background="#d9d9d9")
        self.TNotebook1_t2.configure(highlightbackground="#d9d9d9")
        self.TNotebook1_t2.configure(highlightcolor="black")
        
        self.TNotebook3 = ttk.Notebook(top)
        self.TNotebook3.place(relx=0.668, rely=0.015, relheight=0.49, relwidth=0.32)
        self.TNotebook3.configure(takefocus="")
        self.TNotebook3_t0 = tk.Frame(self.TNotebook3)
        self.TNotebook3.add(self.TNotebook3_t0, padding=3)
        self.TNotebook3.tab(0, text="I/O 1",compound="left",underline="-1",)
        self.TNotebook3_t0.configure(background="#d9d9d9")
        self.TNotebook3_t0.configure(highlightbackground="#d9d9d9")
        self.TNotebook3_t0.configure(highlightcolor="black")
        self.TNotebook3_t1 = tk.Frame(self.TNotebook3)
        self.TNotebook3.add(self.TNotebook3_t1, padding=3)
        self.TNotebook3.tab(1, text="I/O 2 ",compound="left",underline="-1",)
        self.TNotebook3_t1.configure(background="#d9d9d9")
        self.TNotebook3_t1.configure(highlightbackground="#d9d9d9")
        self.TNotebook3_t1.configure(highlightcolor="black")
       
        self.TNotebook2 = ttk.Notebook(top)
        self.TNotebook2.place(relx=0.341, rely=0.015, relheight=0.49, relwidth=0.32)
        self.TNotebook2.configure(takefocus="")
        self.TNotebook2_t0 = tk.Frame(self.TNotebook2)
        self.TNotebook2.add(self.TNotebook2_t0, padding=3)
        self.TNotebook2.tab(0, text="Processor Status", compound="left",underline="-1", )
        self.TNotebook2_t0.configure(background="#d9d9d9")
        self.TNotebook2_t0.configure(highlightbackground="#d9d9d9")
        self.TNotebook2_t0.configure(highlightcolor="black")

        self.TNotebook2_7 = ttk.Notebook(top)
        self.TNotebook2_7.place(relx=0.341, rely=0.51, relheight=0.49, relwidth=0.32)
        self.TNotebook2_7.configure(takefocus="")
        self.TNotebook2_7_t0 = tk.Frame(self.TNotebook2_7)
        self.TNotebook2_7.add(self.TNotebook2_7_t0, padding=3)
        self.TNotebook2_7.tab(0, text="DMA Status", compound="left",underline="-1", )
        self.TNotebook2_7_t0.configure(background="#d9d9d9")
        self.TNotebook2_7_t0.configure(highlightbackground="#d9d9d9")
        self.TNotebook2_7_t0.configure(highlightcolor="black")
        
        self.TNotebook2_8 = ttk.Notebook(top)
        self.TNotebook2_8.place(relx=0.013, rely=0.51, relheight=0.49, relwidth=0.32)
        self.TNotebook2_8.configure(takefocus="")
        self.TNotebook2_8_t0 = tk.Frame(self.TNotebook2_8)
        self.TNotebook2_8.add(self.TNotebook2_8_t0, padding=3)
        self.TNotebook2_8.tab(0, text="RAM",compound="left",underline="-1",)
        self.TNotebook2_8_t0.configure(background="#d9d9d9")
        self.TNotebook2_8_t0.configure(highlightbackground="#d9d9d9")
        self.TNotebook2_8_t0.configure(highlightcolor="black")


        
        ####################   TEXT BOXES   ####################
        
        self.binary = tk.Text(self.TNotebook1_t0)
        self.binary.place(relx=0.0, rely=0.0, relheight=1.013, relwidth=1.017)
        self.binary.configure(background="#000040")
        self.binary.configure(font="-family {Segoe UI} -size 9")
        self.binary.configure(foreground="#ffffff")
        self.binary.configure(highlightbackground="#d9d9d9")
        self.binary.configure(highlightcolor="black")
        self.binary.configure(insertbackground="black")
        self.binary.configure(selectbackground="#c4c4c4")
        self.binary.configure(selectforeground="#ffffff")
        self.binary.configure(wrap="word")
        
        self.init_io1 = tk.Text(self.TNotebook1_t1)
        self.init_io1.place(relx=0.0, rely=0.0, relheight=1.013, relwidth=1.017)
        self.init_io1.configure(background="#000040")
        self.init_io1.configure(font="-family {Segoe UI} -size 9")
        self.init_io1.configure(foreground="#ffffff")
        self.init_io1.configure(highlightbackground="#d9d9d9")
        self.init_io1.configure(highlightcolor="black")
        self.init_io1.configure(insertbackground="black")
        self.init_io1.configure(selectbackground="#c4c4c4")
        self.init_io1.configure(selectforeground="#ffffff")
        self.init_io1.configure(wrap="word")

        self.init_io2 = tk.Text(self.TNotebook1_t2)
        self.init_io2.place(relx=0.0, rely=0.0, relheight=1.013, relwidth=1.017)
        self.init_io2.configure(background="#000040")
        self.init_io2.configure(font="-family {Segoe UI} -size 9")
        self.init_io2.configure(foreground="#ffffff")
        self.init_io2.configure(highlightbackground="#d9d9d9")
        self.init_io2.configure(highlightcolor="black")
        self.init_io2.configure(insertbackground="black")
        self.init_io2.configure(selectbackground="#c4c4c4")
        self.init_io2.configure(selectforeground="#ffffff")
        self.init_io2.configure(wrap="word")
        
        self.io1 = tk.Text(self.TNotebook3_t0)
        self.io1.place(relx=0.0, rely=0.0, relheight=1.013, relwidth=1.017)
        self.io1.configure(background="#000040")
        self.io1.configure(font="-family {Segoe UI} -size 9")
        self.io1.configure(foreground="#ffffff")
        self.io1.configure(highlightbackground="#d9d9d9")
        self.io1.configure(highlightcolor="black")
        self.io1.configure(insertbackground="black")
        self.io1.configure(selectbackground="#c4c4c4")
        self.io1.configure(selectforeground="#ffffff")
        self.io1.configure(wrap="word")

        self.io2 = tk.Text(self.TNotebook3_t1)
        self.io2.place(relx=0.0, rely=0.0, relheight=1.013, relwidth=1.017)
        self.io2.configure(background="#000040")
        self.io2.configure(font="-family {Segoe UI} -size 9")
        self.io2.configure(foreground="#ffffff")
        self.io2.configure(highlightbackground="#d9d9d9")
        self.io2.configure(highlightcolor="black")
        self.io2.configure(insertbackground="black")
        self.io2.configure(selectbackground="#c4c4c4")
        self.io2.configure(selectforeground="#ffffff")
        self.io2.configure(wrap="word")
        
        self.dma = tk.Text(self.TNotebook2_7_t0)
        self.dma.place(relx=0.0, rely=0.0, relheight=1.013, relwidth=1.017)
        self.dma.configure(background="#000040")
        self.dma.configure(font="-family {Segoe UI} -size 9")
        self.dma.configure(foreground="#ffffff")
        self.dma.configure(highlightbackground="#d9d9d9")
        self.dma.configure(highlightcolor="black")
        self.dma.configure(insertbackground="black")
        self.dma.configure(selectbackground="#c4c4c4")
        self.dma.configure(selectforeground="#ffffff")
        self.dma.configure(wrap="word")
        
        self.ram = tk.Text(self.TNotebook2_8_t0)
        self.ram.place(relx=0.0, rely=0.0, relheight=1.013, relwidth=1.017)
        self.ram.configure(background="#000040")
        self.ram.configure(font="-family {Segoe UI} -size 9")
        self.ram.configure(foreground="#ffffff")
        self.ram.configure(highlightbackground="#d9d9d9")
        self.ram.configure(highlightcolor="black")
        self.ram.configure(insertbackground="black")
        self.ram.configure(selectbackground="#c4c4c4")
        self.ram.configure(selectforeground="#ffffff")
        self.ram.configure(wrap="word")
        
        self.processor = tk.Text(self.TNotebook2_t0)
        self.processor.place(relx=0.0, rely=0.0, relheight=1.013, relwidth=1.017)
        self.processor.configure(background="#000040")
        self.processor.configure(font="-family {Segoe UI} -size 9")
        self.processor.configure(foreground="#ffffff")
        self.processor.configure(highlightbackground="#d9d9d9")
        self.processor.configure(highlightcolor="black")
        self.processor.configure(insertbackground="black")
        self.processor.configure(selectbackground="#c4c4c4")
        self.processor.configure(selectforeground="#ffffff")
        self.processor.configure(wrap="word")
        
        ####################   BUTTONS   ####################
        
        self.RUN_ME = ttk.Button(top)
        self.RUN_ME.place(relx=0.734, rely=0.598, height=55, width=146)
        self.RUN_ME.configure(takefocus="")
        self.RUN_ME.configure(text='''RUN ME 
يا بشمهندس 
        :D''')
        self.RUN_ME.bind('<Button-1>', lambda b1:RUN_ME(b1))

        
        self.RUN_ONE_STEP = ttk.Button(top)
        self.RUN_ONE_STEP.place(relx=0.734, rely=0.7, height=55, width=146)
        self.RUN_ONE_STEP.configure(takefocus="")
        self.RUN_ONE_STEP.configure(text='''RUN ONE STEP بس 
         يا بشمهندس 
                 :D''')
        self.RUN_ONE_STEP.bind('<Button-1>', lambda b1:RUN_ONE_STEP(b1))
        print("here")
        # global step_count
        # self.step_count = 1

        self.IO1_INT = ttk.Button(top)
        self.IO1_INT.place(relx=0.734, rely=0.802, height=65, width=66)
        self.IO1_INT.configure(takefocus="")
        self.IO1_INT.configure(text='''I/O 1
  INT''')
        self.IO1_INT.bind('<Button-1>', lambda b1:IO1_INT(b1))


        self.IO2_INT = ttk.Button(top)
        self.IO2_INT.place(relx=0.839, rely=0.802, height=65, width=66)
        self.IO2_INT.configure(takefocus="")
        self.IO2_INT.configure(text='''I/O 2
  INT''')
        self.IO2_INT.bind('<Button-1>', lambda b1:IO2_INT(b1))
        ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    
    
if __name__ == '__main__':
    create_window()

