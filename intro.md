<!-- TOP -->
<div class="top">
  <img class="scenario-academy-logo" src="https://datastax-academy.github.io/katapod-shared-assets/images/ds-academy-2023.svg" />
  <div class="scenario-title-section">
    <span class="scenario-title">SSTable Sideloader</span>
  </div>
</div>

<!-- CONTENT -->
<main>
    <br/>
    <div class="container px-4 py-2">
      <div class="row g-4 py-2 row-cols-1 row-cols-lg-1">
        <div class="feature col div-choice">
          <div class="scenario-description">An interactive Sideloader hands-on lab</div>
          <ul>
            <li><span class="scenario-description-attribute">Difficulty</span>: Intermediate</li>
            <li><span class="scenario-description-attribute">Duration</span>: 10 minutes</li>
          </ul>
          <details class="katapod-details"><summary>This is a Katapod interactive lab. Expand for usage tips</summary>
            <p>
              <i>
                This hands-on lab is built using the Katapod engine. If you have never encountered it before, this is how you use it:
              </i>
              <ul>
                <li>
                  You will proceed through a series of steps on the left panel, advancing to the next step by the click of a button.
                </li>
                <li>
                  On the right part of the lab, one or more consoles are spawned for you to execute commands and interact with the system.
                </li>
                <li>
                  Each step provides instructions and explanations on what is going on.
                </li>
                <li>
                  In particular, click on code blocks to execute them in their target console.
                </li>
                <li>
                  Commands that are executed already are marked as such. Usually you can execute a command as many times as you want (though this might not always be what you want to do).
                </li>
              </ul>
              <i><strong>Note:</strong> please do not refresh your browser tab unless necessary, otherwise you will lose the content in the right-hand console. Most of the state will remain, though.</i>
            </p>
          </details>
        </div>
      </div>
      <div class="row g-4 py-2 row-cols-1 row-cols-lg-1">
        <div class="feature col div-choice">
          <div class="scenario-description">
            <strong>Outline of this lab:</strong>
          </div>
          <div class="scenario-description-attribute">
            <p>
              This is a guided end-to-end Sideloader hands-on experience
              designed to run entirely in your browser. You will start with a running client application
              backed by a local Cassandra installation, and will go through all steps required
              to migrate its SSTables from a snapshot to an Astra DB instance.
            </p>
            <p>
              This interactive lab is designed using the steps described in detail in the Sideloader Documentation page,
              which is a recommended reading before starting a Sideloader migration in production.
            </p>
            <p>
              <strong>About Origin and the client application:</strong>
              In this lab, the Origin database is a Cassandra single-node cluster running locally, which is being
              provisioned while you are reading this.
              The lab provides a simple client application, a HTTP REST API used to read and write
              the "status" of "users" (e.g. <i>Away, Busy, Online</i>). This is a simple Python FastAPI application.
            </p>
          </div>
        </div>
      </div>
      <div class="row g-4 py-2 row-cols-1 row-cols-lg-1">
        <div class="feature col div-choice">
          <div class="scenario-description">References:</div>
          <ul>
            <li><span class="scenario-description-attribute"><a href="https://docs.datastax.com/en/astra-db-serverless/sideloader/sideloader-overview.html" target="_blank">AstraDB SSTable Sideloader documentation</a></span></li>
            <li><span class="scenario-description-attribute"><a href="https://astra.datastax.com/" target="_blank">Astra DB</a></span></li>
          </ul>
        </div>
      </div>
    </div>
</main>

<!-- NAVIGATION -->
<div id="navigation-bottom" class="navigation-bottom">
 <a title="Start" href='command:katapod.loadPage?[{"step":"step1"}]'
    class="btn btn-dark navigation-bottom-right">Start ➡️
  </a>
</div>
