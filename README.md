# CueShow-Prepper-2

## Table of contents
* [What is CSP2?](#what-is-csp2?)
* [What does the Multi Page Version do?](#what-does-the-multi-page-version-do?)
* [What does the Single Page Version do?](#what-does-the-signle-page-version-do?)
* [Automated Setlist Import (ASI)](#automated-setlist-import-(asi))
* [Installation guide](#installation-guide)
* [Setup](#setup)


## What is CSP2?
CueShow Prepper 2 is a plugin for lighting designers and operators who want to save time when setting up a new cue list show on a GrandMA2 console or onPC.
It is the successor of the CueShow Prepper v1.0 plugin and adds several improvements and new features compared to its predecessor. By running the plugin it opens a main menu to let you choose between two versions of the plugin:
Multi Page and Single Page. 


### What does the Multi Page Version do?
CSP2 Multi Page might be the most used version of CSP2. It creates one executor page per Song, on which you can find the song cue list.
If you use Multi Page in combination with ASI, you only have to enter the name of the setlist and the executor number for the song cue list on its respective page. Every further step is taken over by the plugin.
If you don’t use ASI, you’ll have to enter the total number of songs using digits. After that, you get asked to enter every single song name one after the other into the popup.
Multi Page creates one executor page per song with the belonging sequence assigned to the Executor you chose. Song pages as well as the sequences are named after the related song’s name.
Every Song consists of a Prep-Cue 0.1 (in blue), followed by the „usual“ cues and a NEXT-Cue 999 (in orange), that concatenates the songs with each other. If you want to change the order of the songs, you can simply reorder the song pages (but leave the sequences as they are).

__IMPORTANT: Don't move the song executor. It gets called by its executor number. Changing the executor number will break the concatenation!__

__IMPORTANT: Make sure, that there are no empty slots in the song page order.
Empty pages will break the concatenation!__

The plugin will also create three macros: <br>
__1. NEXT_CSP2:__<br>
   Concatenates the songs with each other. Normally you don’t have to use this one manually
   
__2. RESET_CSP2:__<br>
  Jumps to any song, determined by you via a popup.<br>
  __IMPORTANT: This macro uses the „Kill“-statement to jump to the other song.
  Make sure, that all Executors that should not be effected by this are kill protected! (For example virtual Executors for Hazers, DMX remote, etc.)__

__3. REMOVE_CSP2:__<br>
  Removes everything that was created by CSP2.
   This action has to be confirmed by you with entering „1“ into the popup.<br>
   __IMPORTANT: This macro deletes literally everything that was created by CSP2 - including the cue lists!__

Every song that has not been finished is colored in blue, while the song that is currently selected is colored in white and all finished songs are colored in red.
All pool- and page numbers used by the plugin to store it’s content are found by the plugin autonomously without harming your already existing objects. Both for the pages as well as for the macros, sequences, etc. CSP2 searches for consecutive free pool slots to store its objects. Free space in the page- and sequence pool is searched from pool number 101 upwards. The empty macro slots are searched beginning from macro 1 upwards. The final position of the objects will get printed for you in a message box popup, when the plugin is finished. You also can look up for them in the command line feedback, as well as in the system monitor.

### What does the Single Page Version do?
CSP2 Single Page works in most aspects just like the Multi Page-Version. The difference is, that Single Page stores all cue lists to one „Song Page“. That means, that all cue lists are at the same executor page. If you want to reorder the songs you have to reorder the executors.<br>
__IMPORTANT: Make sure, that there are no unassigned executors in the song executor order. Empty executors will break the concatenation!__

## Automated Setlist Import (ASI)
ASI was developed to speed up the usage of CSP by letting GrandMA labeling and counting the songs for your show automatically.
Therefore it reads the information about your show’s setlist out of an .txt-file.
What you have to know about ASI and how you can use it:
1. Copy the setlist into an empty .txt-file by just using copy and paste.
2. Make sure, that every song got it’s own line and each song is not longer than a line (1 song / line)
3. Make sure every song name consists of at least one letter or digit.
4. You can add information about the number of cues you need for that song (if you know this already) by adding three semicolons behind the song name and adding the number of required cues as a digit. For example:

   ``` Song number 4;;;7 ``` —> This will create the song „Song number 4“ as a sequence with 7 cues.
   
   If no semicolons are added or the number of cues is invalid, the song will be created with a default number of five cues.
5. Store the .txt-file, label it and move it either to your Desktop or the GMA2 plugins directory. 
6. You can now use ASI by typing the name of the setlist into the input-popup when the plugin asks you for it.
   _Please note: Enter the name of the setlist without the file suffix._
7. If you don’t want to use ASI, and enter the songs manually, you can just press „PLEASE“ when the plugin asks you for the name of the setlist, and leave the popup empty. Press „PLEASE“ again at the following popup, to start the manual setlist input.

__Tipp: Rather use short song names as they are easier to read and not at risk to get cut off by GrandMA2 due to limited label lengths.__<br>
__IMPORTANT: Known issue at the current version (only on console): Lines without semicolons (like line number 6 in the example above) will get registered as songs, but they won’t be labeled correctly. If you don’t want to add semicolons to all lines, it is recommended to use onPC for ASI.__

## Installation guide
Please follow these Steps for the installation of CSP2:
1. Move the required files to the right directory.<br>
  1.1 For onPC: Copy the folder CSP2 into: C:\\Program Data\\MA Lighting Technologies\\grandma\\gma2_V_X\\plugins.<br>
  1.2 For Console: Copy the folder CSP2 to a USB-Stick at: „STICK NAME"\\gma2\\plugins.
2. Open GrandMA2 onPC / start console.
3. Open a PLUGIN-Pool. You can find it under „System".
4. Right-click on a free plugin-field.
5. Click at "import" and choose „CSP2.xml"
6. Close the window.

## Setup
To run CSP2 on your GrandMA2 follow these steps:
1. Install CSP2
2. Prepare the Setlist for ASI (optional) (Page 6)
3. Run CSP2 by clicking at the plugin or by typing „Plugin CSP2“ in the Command Line.
4. Confirm that you read the manual.
5. Select if you want to use CSP2 in either Multi Page or Single Page mode. (Pages 4 + 5)
6. Enter the name of the setlist for ASI (optional), else press „PLEASE“. If you chose to enter the songs manually:
6.1. Enter the number of songs in total.
6.2. Enter each song name one by one.
7. (Only if you chose Multi Page Mode) Enter the executor number for the song sequence.
8. Note down the macro numbers. They are shown you in an appearing popup, but also in the command line feedback and the system monitor window.

## Technologies:
  - Lua
  - XML
