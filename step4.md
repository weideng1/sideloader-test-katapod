<!-- TOP -->
<div class="top">
  <img class="scenario-academy-logo" src="https://datastax-academy.github.io/katapod-shared-assets/images/ds-academy-2023.svg" />
  <div class="scenario-title-section">
    <span class="scenario-title">SSTable Sideloader</span>
  </div>
</div>

<!-- NAVIGATION -->
<div id="navigation-top" class="navigation-top">
 <a title="Back" href='command:katapod.loadPage?[{"step":"step3"}]' 
   class="btn btn-dark navigation-top-left">⬅️ Back
 </a>
<span class="step-count">Step 4 (Azure)</span>
 <a title="Next" href='command:katapod.loadPage?[{"step":"cleanup"}]' 
    class="btn btn-dark navigation-top-right">Next ➡️
  </a>
</div>

<!-- CONTENT -->

<div class="step-title">Phase 2: migrate data</div>

![Phase 2](images/p2.png)

#### _🎯 Goal: ensuring historical data, inserted before the introduction of the ZDM Proxy, is present on the Target database._

In order to completely migrate to Target, you must take care
of the _whole_ contents of the database. To this end
you will use the Sideloader, an AstraDB service enabling you to provide a snapshot of your data so that it can be automatically uploaded to Target. You interact with the Sideloader through dedicated DevOps APIs.

Verify that the entries inserted before the switch to using the ZDM Proxy are **not** found on Target.
To do so, launch this command:

```bash
### host
astra db cqlsh sstsldev_azure_4525_vector \
  -k zdmapp \
  -e "PAGING OFF; SELECT * FROM zdmapp.user_status WHERE user='eva' limit 500;"
```

You should see just the few rows written once you restarted the API to take advantage of the ZDM Proxy.

If you're sure Origin never had snapshot before, skip this, otherwise, execute the following to clear the snapshots on the origin database:
```bash
### {"terminalId": "host"}
docker exec \
  -it cassandra-origin-1 \
  nodetool clearsnapshot --all
```

Take a snapshot of all the data in the keyspace `zdmapp` on Origin, calling your snapshot `data_migration_snapshot` :
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
docker exec \
  -it cassandra-origin-1 \
  nodetool snapshot -t data_migration_snapshot zdmapp
```

Next you have to initialize the Sideloader data migration for Target. The initialization API returns immediately and gives you a `migrationID`, which will be needed in the rest of the process.
Additionally, the API asynchronously creates a migration directory into a secure bucket, and some credentials for read and write access.

Execute the following command to call the initialization API, storing the `migrationID` into an environment variable:
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
source /workspace/sideloader-test-katapod/.env
export MIGRATION_ID=$(curl -s -X POST \
    -H "Authorization: Bearer ${ASTRA_DB_APPLICATION_TOKEN}" \
    https://api.dev.cloud.datastax.com/v2/databases/${ASTRA_DB_ID}/migrations/initialize \
    | jq '.migrationID' | tr -d '"')
sed -i "/^MIGRATION_ID=/d" /workspace/sideloader-test-katapod/.env
echo "MIGRATION_ID=\"$MIGRATION_ID\"" >> /workspace/sideloader-test-katapod/.env
```

Periodically check the status of your migration until you see it switching to `ReceivingFiles`:
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
curl -s -X GET \
    -H "Authorization: Bearer ${ASTRA_DB_APPLICATION_TOKEN}" \
    https://api.dev.cloud.datastax.com/v2/databases/${ASTRA_DB_ID}/migrations/${MIGRATION_ID} \
    | jq .status
```

If you see this error message: `parse error: Invalid numeric literal at line 1, column 9`, just wait for a couple of minutes and try again.

When the status switches to `ReceivingFiles`, the initialization is complete. Run the check status command again with the full output.
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
curl -s -X GET \
    -H "Authorization: Bearer ${ASTRA_DB_APPLICATION_TOKEN}" \
    https://api.dev.cloud.datastax.com/v2/databases/${ASTRA_DB_ID}/migrations/${MIGRATION_ID} \
    | jq .
```

At this point, the status response contains several values that will be needed in the next steps.
These values are:
 - The migration directory to which the snapshot must be uploaded.
 - The credentials components that grant access to the migration directory.

Run the following command to store these values into environment variables: 
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
curl -s -X GET \
    -H "Authorization: Bearer ${ASTRA_DB_APPLICATION_TOKEN}" \
    https://api.dev.cloud.datastax.com/v2/databases/${ASTRA_DB_ID}/migrations/${MIGRATION_ID} \
    | jq . > init_complete_output.json
export MIGRATION_DIR=$(jq '.uploadBucketDir' init_complete_output.json | tr -d '"')
export AZURE_SAS_TOKEN=$(jq '.uploadCredentials.keys.url' init_complete_output.json | tr -d '"' | sed 's/^[^?]*?//')
rm -f init_complete_output.json
```

Now you are ready to upload your snapshot to the migration directory. To do so, you will use the AWS CLI that is pre-installed on your Origin node. Remember that your Origin node runs as a Docker container, so the command below needs to pass the required environment variables from the host to the container.

Run the following command:
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
docker exec \
  -e MIGRATION_DIR \
  -e AZURE_SAS_TOKEN \
  -it cassandra-origin-1 bash -c '
    for dir in $(find /var/lib/cassandra/data/ -type d -path "*/snapshots/data_migration_snapshot*"); do
      REL_PATH=${dir#"/var/lib/cassandra/data/"}  # Remove the base path
      azcopy sync "$dir" "${MIGRATION_DIR}node1/$REL_PATH/"?${AZURE_SAS_TOKEN} --recursive
    done
  '
```

Check that the data has been uploaded correctly to the migration directory:
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
docker exec \
  -e MIGRATION_DIR \
  -e AZURE_SAS_TOKEN \
  -it cassandra-origin-1 \
  azcopy list ${MIGRATION_DIR}?${AZURE_SAS_TOKEN}
```

When the upload is complete, execute the following to clear the snapshots on the origin database:
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
docker exec \
  -it cassandra-origin-1 \
  nodetool clearsnapshot --all
```

Now, you are finally ready to launch the migration by calling the following API:
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
curl -s -X POST \
    -H "Authorization: Bearer ${ASTRA_DB_APPLICATION_TOKEN}" \
    https://api.dev.cloud.datastax.com/v2/databases/${ASTRA_DB_ID}/migrations/${MIGRATION_ID}/launch \
    | jq .
```

This API returns immediately after launching a long-running background process that imports your snapshot into Target.

You can monitor the process through the same status API call as above:
```bash
### {"terminalId": "host", "backgroundColor": "#C5DDD2"}
curl -s -X GET \
    -H "Authorization: Bearer ${ASTRA_DB_APPLICATION_TOKEN}" \
    https://api.dev.cloud.datastax.com/v2/databases/${ASTRA_DB_ID}/migrations/${MIGRATION_ID} \
    | jq -r '"\(.status)\n\(.progressInfo)"'
```
The final status for a successful migration is `MigrationDone`. 

Once the Sideloader process has completed, you will see that now _all_ rows are
on Target as well.

To verify this, launch this command:

```bash
### host
astra db cqlsh sstsldev_azure_4525_vector \
  -k zdmapp \
  -e "PAGING OFF; SELECT * FROM zdmapp.user_status WHERE user='eva' limit 500;"
```

<!-- NAVIGATION -->
<div id="navigation-bottom" class="navigation-bottom">
 <a title="Back" href='command:katapod.loadPage?[{"step":"step3"}]'
   class="btn btn-dark navigation-bottom-left">⬅️ Back
 </a>
 <a title="Next" href='command:katapod.loadPage?[{"step":"cleanup"}]'
    class="btn btn-dark navigation-bottom-right">Next ➡️
  </a>
</div>
