FROM ubuntu:24.04
LABEL maintainer="gaip@gaip.com"

# 1. Install 'git' along with curl
RUN apt-get update && apt-get install -y curl git

# 2. Use 'git clone' (not just clone)
# Updated URL to the original repo, change back to 'gaip' if you have a fork
RUN git clone https://github.com/bregman-arie/devops-exercises.git

WORKDIR /devops-exercises

# 3. Ensure run.sh exists and is executable before running it
# If run.sh is not in the repo root, this will fail.
# chmod might be needed if the script doesn't have +x permissions.
RUN chmod +x run.sh && ./run.sh

CMD ["/bin/bash"]