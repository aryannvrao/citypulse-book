TITLE: Docker: pack the API in a box
HOOK: Build once, run anywhere, and check it for known holes.

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and Mira is packing a server today.
M(cheer): Hi! My API works on my laptop, but the client machine has nothing installed.
B: That is the classic problem. Docker packs the whole setup into one box that runs the same everywhere.

== same | set=lab
LEFT: 🍱 : Sealed lunch tiffin
RIGHT: 📦 : Docker image
M: My lunch is packed at home, sealed, with everything inside. That is the image.
B: Right. Opening it and eating is the container, a running copy. The same food tastes the same anywhere.
M(think): So I can open many tiffins from one image?
B(happy): Yes. Stopping a container never changes the image it came from.

== talk | set=room
M(sad): Yesterday the server crashed, because a library quietly got a new version.
> 💥 : Crashed server
B(think): That is why we pin exact versions. Every package gets a fixed number, so nothing changes by surprise.
> 📌 : Pinned versions
M: And the Python version, the operating system and the folders?
B(happy): The Dockerfile records all of that. It is a short recipe that Docker follows from top to bottom.
> 📜 : Dockerfile recipe

== chain | set=server
B: Each Dockerfile line adds one layer. Docker reuses a layer when nothing above it changed.
> 🐍 : Base Python
> 📚 : Pinned packages
> 📂 : Your code
> 🚀 : Start command
M(think): So if I copy my code above the install, every small edit reinstalls everything?
B: Exactly. Copy the requirements file first, install, and copy the code afterwards.

== term | set=lab
B: Let us build the image and run it. The publish flag opens port 8000 on your laptop.
> $ docker build -t citypulse-api:p8 .
> = naming to docker.io/library/citypulse-api:p8 done
> $ docker run --rm -d --name cp-api -p 8000:8000 citypulse-api:p8
> = 7d1e0a9c4b21
M(think): Now I ask the server a question.
> $ curl -i localhost:8000/v1/health
> = HTTP/1.1 200 OK
M(cheer): Status 200! The server answers from inside its box.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: api : 🧩 : API container
NODE: db : 🐘 : Postgres
B: With Compose, the API and Postgres run as two boxes on one private network.
> hi api
M(think): So how does the API find the database, if localhost is my laptop?
B: Inside the network, localhost means the API box itself. The name db points to Postgres.
> api>db : connect to db
> hi db
M(happy): And the API waits until Postgres passes its health check first.
> db>api : healthy, start

== quiz | set=class
Q: EXPOSE 8000 is set, but port 8000 is unreachable. What fixes it?
- Change EXPOSE to port 8080
- Add an environment variable called PORT
* Add the publish flag 8000:8000
- Rebuild the image with no cache
M(think): EXPOSE sounds like it opens the port, but it only writes a note.
B(cheer): Right. The publish flag links your laptop to the container. EXPOSE alone only documents the port.

== trap | set=room
WRONG: USER 10001 but plain COPY lines
RIGHT: COPY --chown=10001:10001 models/
M(shock): I added user ten thousand and one, to be safer. Now the app crashes when it writes a file.
B: The copied folders still belong to root, so the new user cannot write to them.
M(think): So the fix is to set the owner on every copy line?
B: Yes. Then check the user number inside the container. It must not be zero.

== versus | set=lab
LEFT: 🔨 : Builder stage
RIGHT: 🚚 : Final stage
B: A multi stage build has two stages. The builder holds compilers and caches.
> L : Installs compilers and tools
> L : Creates the virtual environment
M(think): And the final stage starts clean?
> R : Starts from a clean base
> R : Copies only the venv folder
B: Exactly. The builder is thrown away, so the final image stays small and clean.

== table | set=server
HEAD: finding | severity | decision
ROW: OS package | HIGH | Upgrade
ROW: Library | CRITICAL | Upgrade
ROW: No fix yet | HIGH | Write reason
B: Trivy scans the image for known security holes, and gives each one a severity.
> rows 2
M(shock): A critical one in a library. I must upgrade it, then run the tests again.
> col 3
B: A finding with no fix still needs a written reason in the security readme. Never ignore it.

== recap | set=city
B: Let us lock in what we learned.
> A container is a running copy of an image
M: Copy requirements before code, so the install stays cached.
> Copy requirements before code
B: Services talk by name, not by localhost.
> Use the service name db
M: Run as user 10001, and check it.
> USER 10001 with chown
B(cheer): Scan with Trivy and write down every decision. Great work today, Mira!
> Scan, then record each decision
