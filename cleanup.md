<!-- TOP -->
<div class="top">
  <img class="scenario-academy-logo" src="https://datastax-academy.github.io/katapod-shared-assets/images/ds-academy-2023.svg" />
  <div class="scenario-title-section">
    <span class="scenario-title">AstraDB SSTable Sideloader</span>
  </div>
</div>

<!-- NAVIGATION -->
<div id="navigation-top" class="navigation-top">
 <a title="Back" href='command:katapod.loadPage?[{"step":"step4"}]' 
   class="btn btn-dark navigation-top-left">⬅️ Back
 </a>
<span class="step-count">Epilogue: cleanup</span>
 <a title="Next" href='command:katapod.loadPage?[{"step":"finish"}]' 
    class="btn btn-dark navigation-top-right">Next ➡️
  </a>
</div>

<!-- CONTENT -->

<div class="step-title">Epilogue: cleanup</div>

![Phase 6](images/p6.png)

#### _🎯 Goal: cleanly deleting all resources that are no longer needed now that the migration is over._

Kill the processes running on the terminals to simulate web application and endless `curl` for loop:

```bash
### {"terminalId": "api", "macrosBefore": ["ctrl_c"]}
# A Ctrl-C to stop the running process ...
echo "killed api"
```

```bash
### {"terminalId": "client", "macrosBefore": ["ctrl_c"]}
# A Ctrl-C to stop the running process ...
echo "killed api-client"
```

Then, **destroy Origin** (gulp!). In this case it is easy,
it's just a single-node Cassandra cluster. _Note: in an
actual production setup, you probably do not want to take this step lightly
(and presumably it would be a bit more than one node)!_

```bash
### host
VOLUME_CASSANDRA_ORIGIN_1=`docker inspect cassandra-origin-1 | jq -r '.[].Mounts[] | select( .Type=="volume" ).Name'`
docker rm -f cassandra-origin-1
docker volume rm ${VOLUME_CASSANDRA_ORIGIN_1}
```

Finally, remove any remaining intermediate directories or configuration files that were generated during this hands-on workshop.
If you want to start from scratch and don't want to spin up a new VM, run the following steps:

```bash
### host
# rm -rf <root> ^H^H^H^H^H
rm -f $HOME/.astrarc
rm -f $HOME/sideloader-test-katapod/.env
rm -f $HOME/sideloader-test-katapod/secure-connect*zip
rm -f $HOME/.astra/scb/scb_*.zip
rm -f $HOME/.bash_history
touch $HOME/.bash_history
rm -f $HOME/.viminfo
```

Now, **optionally** if you want to be able to go back to step 0 and run through everything all over again, you should execute the following steps to
provision a brand new C* container locally with some initial rows populated.

```bash
### host
docker run \
  --name cassandra-origin-1 \
  -v ${PWD}/origin_config/cassandra-4.0.yaml:/etc/cassandra/cassandra.yaml \
  -d \
  cassandra:4.0
sleep 10
docker exec cassandra-origin-1 bash -c "
  apt-get update && apt-get install -y \
    python-is-python3 \
    unzip \
    python3-venv \
    jq \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    sudo && \
  curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\" && \
  unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws && \
  apt-get clean && rm -rf /var/lib/apt/lists/*
"
docker exec cassandra-origin-1 bash -c "
  apt-get update -y && apt-get install -y wget tar && wget -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xvf azcopy.tar.gz && mv azcopy_linux_amd64_*/azcopy /usr/local/bin/ && rm -rf azcopy.tar.gz azcopy_linux_amd64_* && azcopy --version
"
```

#### _🗒️ Well, this is really the end. Time to wrap it up._

<!-- NAVIGATION -->
<div id="navigation-bottom" class="navigation-bottom">
 <a title="Back" href='command:katapod.loadPage?[{"step":"step4"}]'
   class="btn btn-dark navigation-bottom-left">⬅️ Back
 </a>
 <a title="Next" href='command:katapod.loadPage?[{"step":"finish"}]'
    class="btn btn-dark navigation-bottom-right">Next ➡️
  </a>
</div>
