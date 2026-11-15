const input = document.getElementById("endpoint");
const message = document.getElementById("message");
document.getElementById("connect").addEventListener("click", () => {
  let url;
  try { url = new URL(input.value.trim()); }
  catch { message.textContent = "Enter a valid HTTPS noVNC URL."; return; }
  if (url.protocol !== "https:" || !url.hostname || url.username || url.password) {
    message.textContent = "Use an HTTPS URL without embedded credentials.";
    return;
  }
  if (!url.pathname.endsWith("/vnc.html")) {
    message.textContent = "Enter the full noVNC address ending in /vnc.html.";
    return;
  }
  message.textContent = "Opening your noVNC endpoint in a new tab.";
  window.open(url.href, "_blank", "noopener,noreferrer");
});
