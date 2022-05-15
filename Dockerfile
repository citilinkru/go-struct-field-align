FROM golangci/golangci-lint:v1.46 as builder

# copying nessesary files (config and script)
COPY .golangci.yml /
COPY align_fix.sh /

# installing fieldalignment go tool
RUN go install golang.org/x/tools/go/analysis/passes/fieldalignment/cmd/fieldalignment@latest

# installation jq (command-line JSON processor)
WORKDIR /bin
RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*
RUN wget "http://stedolan.github.io/jq/download/linux64/jq" && chmod 755 jq

#setting shell to bash instead of default bin/sh
SHELL ["/bin/bash", "-c"]

# setting entrypoint to a script
ENTRYPOINT ["/align_fix.sh"]
