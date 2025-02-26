<!-- TOP -->
<div class="top">
  <img class="scenario-academy-logo" src="https://datastax-academy.github.io/katapod-shared-assets/images/ds-academy-2023.svg" />
  <div class="scenario-title-section">
    <span class="scenario-title">SSTable Sideloader</span>
  </div>
</div>

<!-- NAVIGATION -->
<div id="navigation-top" class="navigation-top">
  <a title="Back" href='command:katapod.loadPage?[{"step":"intro"}]' 
    class="btn btn-dark navigation-top-left">⬅️ Back
  </a>
  <span class="step-count">Step 1</span>
  <a title="Next" href='command:katapod.loadPage?[{"step":"step2"}]' 
    class="btn btn-dark navigation-top-right">Next ➡️
  </a>
</div>

<!-- CONTENT -->

<div class="step-title">Preliminary step: Origin and sample application</div>

#### _🎯 Goal: making sure that Origin is ready and that there is a sample client application reading and writing on it._

**Note**: please wait for message _"Ready for Step 1"_ on the
the first console ("host-console") before proceeding.

First, you will simply check the Origin database and make sure that
the sample client application, which accesses it, is properly running.
First have a look at the contents of the table in Origin with this CQL query
(sample rows have been inserted already):

```bash
### host
docker exec \
  -it cassandra-origin-1 \
  cqlsh -u cassandra -p cassandra \
  -e "SELECT * FROM zdmapp.user_status WHERE user='eva';"
```

The parameters to connect to Origin are pre-filled in file `client_application/.env`,
so that you can immediately launch the client application
(an API to handle "status updates" by various "users").
The following command instructs it to use Origin:

```bash
### api
cd /workspace/sideloader-test-katapod/client_application/
CLIENT_CONNECTION_MODE=CASSANDRA uvicorn api:app
```

Test the API with a few calls: first check Eva's last three status updates, to compare with the `SELECT` results above:

```bash
### host
curl -s -XGET "localhost:8000/status/eva?entries=3" | jq
```

_Note: you can customize the `entries` query parameter in all API GET calls to your needs._

Then write a new status:

```bash
### client
curl -s -XPOST "localhost:8000/status/eva/New" | jq
```

Try the read again and check the output to see the new status:

```bash
### host
curl -s -XGET localhost:8000/status/eva | jq
```

The next API invocations will usually manipulate the output to make it more compact, as in:

```bash
### host
curl -s -XGET "localhost:8000/status/eva?entries=3" | jq -r '.[] | "\(.when)\t\(.status)"'
```

Now start a loop that periodically inserts a new (timestamped) status for Eva.
You'll keep it running througout the practice, to put the "zero-downtime" aspect to test:

```bash
### client
while true; do
  NEW_STATUS="ModeCassandra_`date +'%H-%M-%S'`";
  echo -n "Setting status to ${NEW_STATUS} ... ";
  curl -s -XPOST -o /dev/null "localhost:8000/status/eva/${NEW_STATUS}";
  echo "done. Sleeping a little ... ";
  sleep 20;
done
```

Feel free to play with the GET endpoint to see the trickle of new rows in the API response.

#### _🗒️ You have a working application backed by a Cassandra cluster. Time to start preparing for a migration!_

![Schema, phase 0a](images/schema0a_r.png)

<!-- NAVIGATION -->
<div id="navigation-top" class="navigation-top">
  <a title="Back" href='command:katapod.loadPage?[{"step":"intro"}]' 
    class="btn btn-dark navigation-top-left">⬅️ Back
  </a>
  <a title="Next" href='command:katapod.loadPage?[{"step":"step2"}]' 
    class="btn btn-dark navigation-top-right">Next ➡️
  </a>
</div>
