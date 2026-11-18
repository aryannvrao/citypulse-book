TITLE: Day 14: Cloud servers and SSH
HOOK: Lock a cloud server, prove it, then switch it off.

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Today our air quality script needs a computer that never sleeps. So we rent one in the cloud.

== talk | set=room
M(sad): My laptop sleeps every night, so the pollution readings stop coming in. I hate that.
> 💻 : Laptop asleep
B(happy): That is the problem a server solves. A server is a computer that stays on and answers requests from other computers.
> 🖥️ : Server
M(think): So I need one that is always on, and I rent it?
B: Yes. Renting computers over the internet is the cloud. Amazon's service is EC2, and each rented computer is a virtual machine, meaning software that acts like a real computer.
> word : RENT, NOT BUY

== same | set=city
LEFT: 🏠 : Renting a flat
RIGHT: 🖥️ : Cloud server
M: A flat has a gate, and anyone on the street can knock on it.
B: A cloud server is the same. Every server has an IP address, like a postal address, so anyone can knock on it.
M(think): So how do I keep strangers out?
B: With a security group. That is a firewall, which is software that allows or blocks traffic by rules.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: vm : 🖥️ : Cloud server
NODE: bot : 🤖 : Bot scanner
B: To log in, you use SSH, which stands for Secure Shell. It is an encrypted connection, meaning scrambled so others cannot read it, to the server's command line.
> hi vm
M: And who else can reach it?
> bot>vm : scan port 22
B: Automated bots scan the internet all day. A port is a numbered door, and port 22 is the door SSH uses.
> pc>vm : ssh login
M(happy): So I want my laptop to be the only visitor allowed through that door.

== chain | set=server
B: Launching a server takes a few steps. First you pick the official Ubuntu image, a saved copy of Linux, the operating system that runs most servers.
> 🧾 : Ubuntu image
M(confused): What is a key pair, and why do I need one?
> 🔑 : Key pair
B: The private half stays on your laptop, and the public half goes on the server. Only the matching pair opens the door, so no password is needed.
M(cheer): Then the security group, the firewall, is attached, and the machine starts running.
> 🔒 : Security group
> 🟢 : Running VM

== code | set=lab
| from_port = 22
| to_port = 22
| port = 80
| print(from_port <= port <= to_port)
B: Here is a tiny piece of Python that checks whether a port falls inside a firewall rule.
> line 1
> var from_port=22
M(think): So this rule opens only port 22, the SSH door.
> line 2
> var to_port=22
B: Now a visitor knocks on port 80, the web door. Is it inside the range?
> line 3
> var port=80
M(confused): So the answer should be no.
> line 4
> out False

== trap | set=lab
WRONG: Port 22 open to every address (0.0.0.0/0)
RIGHT: Port 22 from 203.0.113.47/32 only
M(shock): So I open port 22 to everyone, and I can never get locked out, right?
B: That is a classic trap. Bots from anywhere can then knock on your door all day. Allow only your own single address.
B(cheer): Look up your current address with a checker website, then add one rule for that address.

== term | set=room
B: Now we harden the SSH settings. Hardening means switching off the weak ways in.
> $ sudo sshd -t
> = nothing printed: the config is valid
M(think): No output means the file is valid. Now I reload it.
> $ sudo systemctl reload ssh
B: Reloading makes the SSH service read the new file. Keep your first session open, in case something goes wrong.
> $ sudo sshd -T | grep -i permitrootlogin
> = permitrootlogin no
M(happy): The effective setting says no, so the all powerful root administrator cannot log in over SSH.

== table | set=lab
HEAD: Rule | Source | Verdict
ROW: SSH 22 | Anyone | Unsafe
ROW: SSH 22 | One IP | Safe
M(think): I can put the rules in a table and spot the danger quickly.
B: Row one lets anyone reach the door, which is exactly what the scanners look for.
> rows 1
B(cheer): Row two lets in only my address, so I keep just that row.
> rows 2
> keep 2

== versus | set=lab
LEFT: 🔑 : SSH key
RIGHT: 🔓 : Password login
M(think): So why is a key better than a password?
> L : Private key never leaves your laptop
B: A password can be guessed, leaked, or tried by bots all day long.
> R : Bots can keep guessing
M(happy): A key is far longer than any password, so nobody can guess it.
> L : Far longer than any password
B: That is why we switch password logins off completely on the server.
> R : Password logins switched off

== quiz | set=class
Q: Your server accepts SSH from every address on the internet. What is the best fix?
- Leave it open, because it is convenient
- Open port 22 to more address ranges
* Allow port 22 from your own address only
- Switch off the firewall for a while
M(think): Let me reason. A door open to everyone lets every bot knock.
M(think): So I should narrow the rule, not remove the firewall.
B(cheer): Right. Allow only your own address, and the door stays shut to everyone else.

== recap | set=city
B: Let us lock in what we learned today.
> A cloud server is a rented computer
M: Only your own address may knock on the door.
> Security group: one address only
B: Use a key, not a password, and switch off weak logins.
> Keys beat passwords
M(cheer): Check every change with a command before you trust it.
> Verify with sshd -T
B(cheer): Stop the server when you finish, so the bill stops. Great work today, Mira!
> Stop the server when done
