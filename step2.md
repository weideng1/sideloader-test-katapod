<!-- TOP -->
<div class="top">
  <img class="scenario-academy-logo" src="https://datastax-academy.github.io/katapod-shared-assets/images/ds-academy-2023.svg" />
  <div class="scenario-title-section">
    <span class="scenario-title">SSTable Sideloader</span>
  </div>
</div>

<!-- NAVIGATION -->
<div id="navigation-top" class="navigation-top">
  <a title="Back" href='command:katapod.loadPage?[{"step":"step1"}]' 
    class="btn btn-dark navigation-top-left">⬅️ Back
  </a>
  <span class="step-count">Step 2</span>
  <a title="Next" href='command:katapod.loadPage?[{"step":"step3"}]' 
    class="btn btn-dark navigation-top-right">Next ➡️
  </a>
</div>

<!-- CONTENT -->

<div class="step-title">Preliminary step: set up Target</div>

![Phase 0b](images/p0b.png)

#### _🎯 Goal: Setup the Target database (Astra DB instance) and verifying it is ready for the migration._

**Note**: you are going to make use of the `astra-cli` [utility](https://docs.datastax.com/en/astra-classic/docs/astra-cli/introduction.html)
to perform most of the required steps from the console.
However, database creation and generation of an associated token are still done on the Astra Web UI:

- Create your [Astra account](https://astra.datastax.com/) if you haven't yet.
- Ensure you already have the database that you provided name at the beginning.
- Get a **"Database Administrator"** database token from the Astra UI and store it in a safe place ([detailed instructions](https://awesome-astra.github.io/docs/pages/astra/create-token/#c-procedure)). _You will need it later in the exercise._

Once this part is done, you can proceed in the "host" console.

If you forgot to create `zdmapp` keyspace as instructed earlier, you can run the following astra-cli command to create it:
```bash
### host
astra db create-keyspace -k zdmapp sstslprod_aws
```

Have the CLI prepare a `.env` file, useful to later retrieve the database ID:

```bash
### host
astra db create-dotenv -k zdmapp -d /workspace/sideloader-test-katapod sstslprod_aws
```

During creation of this file, the "secure connect bundle" zipfile, needed by
the sample application, has been downloaded as well at this path:

```bash
### host
grep ASTRA_DB_SECURE_BUNDLE_PATH /workspace/sideloader-test-katapod/.env
```

_Take a note of the zipfile full path, you'll need it later for the example API._

Finally, your Target database needs a schema matching the one in Origin.
Check the contents of the script file with

```bash
### host
cat /workspace/sideloader-test-katapod/astradb_config/astradb_schema.cql
```

and then execute it on the Astra DB instance:

```bash
### host
cd /workspace/sideloader-test-katapod/
astra db cqlsh sstslprod_aws -e "DROP TABLE zdmapp.user_status"
astra db cqlsh sstslprod_aws -f astradb_config/astradb_schema.cql
astra db cqlsh sstslprod_aws -e "SELECT * FROM zdmapp.user_status"
```

#### _🗒️ Your database and keyspace are created and have the right schema. Now you can start running Sideloader to load into Astra DB._

![Schema, phase 0b](images/schema0b_r.png)

<!-- NAVIGATION -->
<div id="navigation-bottom" class="navigation-bottom">
  <a title="Back" href='command:katapod.loadPage?[{"step":"step1"}]'
    class="btn btn-dark navigation-bottom-left">⬅️ Back
  </a>
  <a title="Next" href='command:katapod.loadPage?[{"step":"step3"}]'
    class="btn btn-dark navigation-bottom-right">Next ➡️
  </a>
</div>
