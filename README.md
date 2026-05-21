# Cowrie (Honeypot)

This is a small project I made while learning Docker, Linux administration, and shell scripting. I deployed a Cowrie honeypot on my server to observe how automated automated bots scan internet ports.

## The Problem
As soon as the honeypot went live, brute-force bots started spamming it with thousands of identical login attempts and commands every minute. The text output from Docker quickly became a mess. 

My initial attempts to filter logs with basic grep and awk commands kept breaking because bots used special characters (like brackets, quotes, or dollar signs) in their passwords and scripts. This caused parsing errors and duplicated the exact same data over and over, bloating the text files.

## How I Fixed It
I decided to separate the log processing into two parts: a background collector and a simple viewer.

1. logger_daemon.sh: A script that runs in the background and continuously monitors the live output from the Docker container. It cleans up formatting artifacts and extracts the attacker's IP address and port. Instead of calling external tools that break on special characters, it uses AWK internal memory arrays to track and filter out duplicate entries on the fly.
2. stats.sh: A simple terminal script that just reads the already cleaned files using tail. It outputs the latest unique login attempts and commands onto the screen instantly without putting load on the CPU.

## Project Structure
- logger_daemon.sh: Background log collector and deduplicator.
- stats.sh: Terminal viewer script.
- all_logins.txt: Output file containing unique IP:Port sockets and tried passwords.
- all_commands.txt: Output file containing unique commands typed by attackers.

## Setup and Usage

Make sure your Cowrie container is running under the name honeypot_cowrie.

Make both scripts executable:
chmod +x logger_daemon.sh stats.sh

Start the background tracking process:
./logger_daemon.sh

The script will safely detach into the background. Whenever you want to see the clean, non-repetitive list of recent actions, run the viewer:
./stats.sh

## How Data Flows

The project uses two plain text files to link the background collector and the terminal viewer together:

1. Docker Output > logger_daemon.sh > Filters duplicates > Saves clean data into all_logins.txt and all_commands.txt.
2. stats.sh -> Reads the last lines from all_logins.txt and all_commands.txt -> Displays them on your screen.

Because of this separation, the viewer script never interacts with Docker directly and doesn't waste CPU parsing raw logs every time you check the stats. 

You can also open both the all_commands.txt and all_logins.txt as a usuall txt file, to look throug them.
