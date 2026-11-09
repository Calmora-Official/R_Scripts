// ------------------------------------------------------------------
// CONFIGURATION – Replace these with your own values
// ------------------------------------------------------------------
const OWNER = "Calmora-Official";      // Your GitHub username
const REPO  = "R_Scripts";                 // Your repository name
const WORKER_URL = "https://rscript-publisher.yasmin-zaman.workers.dev/"; // Your Cloudflare Worker URL

// ------------------------------------------------------------------
// Publish form handler
// ------------------------------------------------------------------
document.getElementById("publish-form").addEventListener("submit", async (e) => {
  e.preventDefault();

  const name = document.getElementById("script-name").value.trim();
  const description = document.getElementById("script-desc").value.trim();
  const code = document.getElementById("script-code").value;

  if (!name || !description || !code) {
    alert("All fields are required.");
    return;
  }

  const safeName = name.replace(/[^a-zA-Z0-9_-]/g, "_");
  const statusEl = document.getElementById("status");
  statusEl.textContent = "Publishing…";

  try {
    // Send the request to your secure Cloudflare Worker, NOT GitHub directly
    const response = await fetch(WORKER_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        name: safeName,
        description: description,
        code: code
      })
    });

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`Worker error: ${err}`);
    }

    statusEl.textContent = "✅ Published! The script will appear shortly (refresh in a few seconds).";
    document.getElementById("publish-form").reset();
  } catch (err) {
    console.error(err);
    statusEl.textContent = "❌ Failed to publish. Check the console.";
  }
});

// ------------------------------------------------------------------
// Load and render the script list
// ------------------------------------------------------------------
async function loadScripts() {
  const listEl = document.getElementById("scripts-list");
  try {
    const res = await fetch("./scripts.json");
    if (!res.ok) {
      listEl.innerHTML = "<p>No scripts published yet.</p>";
      return;
    }
    const scripts = await res.json();
    if (scripts.length === 0) {
      listEl.innerHTML = "<p>No scripts published yet.</p>";
      return;
    }

    listEl.innerHTML = scripts.map((s) => {
      // The loader URL points to the raw file on GitHub Pages
      const loader = `loadstring(game:HttpGet("https://${OWNER}.github.io/${REPO}/scripts/${s.name}.lua"))()`;
      return `
        <div class="script-card">
          <h3>${s.name}</h3>
          <p>${s.description}</p>
          <div class="loader-code">${loader}</div>
        </div>
      `;
    }).join("");
  } catch (err) {
    console.error(err);
    listEl.innerHTML = "<p>Failed to load scripts.</p>";
  }
}

// Initial load
loadScripts();
