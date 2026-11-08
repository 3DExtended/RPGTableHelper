export function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

const style = `
  :root { color-scheme: light dark; --bg: #f6f3ee; --card: #fff; --text: #1f1b16; --muted: #6b6258; --accent: #7a4b1e; --error: #a1261b; --border: #ddd3c7; }
  @media (prefers-color-scheme: dark) { :root { --bg: #16130f; --card: #221d18; --text: #f1ebe3; --muted: #b3a797; --accent: #e0a96b; --error: #ff8a80; --border: #3b332b; } }
  * { box-sizing: border-box; }
  body { margin: 0; min-height: 100vh; display: grid; place-items: center; background: var(--bg); color: var(--text);
         font: 16px/1.5 system-ui, -apple-system, "Segoe UI", sans-serif; padding: 16px; }
  main { width: 100%; max-width: 420px; background: var(--card); border: 1px solid var(--border); border-radius: 14px; padding: 28px; }
  h1 { font-size: 1.35rem; margin: 0 0 12px; }
  p { margin: 0 0 12px; }
  .muted { color: var(--muted); font-size: .9rem; }
  label { display: block; font-weight: 600; margin: 16px 0 6px; }
  input[type=password], input[type=text], input[type=file] { width: 100%; padding: 10px 12px; font: inherit; border-radius: 8px;
         border: 1px solid var(--border); background: transparent; color: inherit; }
  .actions { display: flex; gap: 12px; margin-top: 22px; flex-wrap: wrap; }
  button { font: inherit; font-weight: 600; padding: 10px 16px; border-radius: 8px; border: 1px solid var(--accent); cursor: pointer; }
  button.primary { background: var(--accent); color: var(--card); }
  button.secondary { background: transparent; color: var(--accent); }
  .error { color: var(--error); font-weight: 600; }
  code { font-size: .9em; word-break: break-all; }
`;

export function page(title: string, body: string): string {
  return `<!doctype html>
<html lang="de">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="referrer" content="no-referrer">
<title>${escapeHtml(title)}</title>
<style>${style}</style>
</head>
<body><main>${body}</main></body>
</html>`;
}

export function loginPage(options: {
  requestId: string;
  clientName: string;
  redirectHost: string;
  askTotp: boolean;
  error?: string;
}): string {
  const error = options.error ? `<p class="error" role="alert">${escapeHtml(options.error)}</p>` : '';
  const totp = options.askTotp
    ? `<label for="totp">Code aus der Authenticator-App</label>
       <input id="totp" name="totp" type="text" inputmode="numeric" autocomplete="one-time-code" pattern="[0-9 ]{6,7}" required>`
    : '';
  return page(
    'Anmelden – QuestKeeper-Notizen',
    `<h1>QuestKeeper-Notizen</h1>
     <p><strong>${escapeHtml(options.clientName)}</strong> möchte deine Notizen, Gruppen und Bilder lesen und ändern.</p>
     <p class="muted">Nach der Anmeldung geht es zurück zu <code>${escapeHtml(options.redirectHost)}</code>.
       Wenn du das nicht gerade selbst angestoßen hast, brich ab.</p>
     ${error}
     <form method="post" action="authorize">
       <input type="hidden" name="request_id" value="${escapeHtml(options.requestId)}">
       <label for="password">Passwort</label>
       <input id="password" name="password" type="password" autocomplete="current-password" required autofocus>
       ${totp}
       <div class="actions">
         <button class="primary" type="submit" name="action" value="allow">Anmelden und erlauben</button>
         <button class="secondary" type="submit" name="action" value="deny" formnovalidate>Abbrechen</button>
       </div>
     </form>`,
  );
}

export function errorPage(message: string): string {
  return page(
    'Anmeldung nicht möglich',
    `<h1>Anmeldung nicht möglich</h1><p class="error">${escapeHtml(message)}</p>
     <p class="muted">Starte die Verbindung in Claude bitte neu.</p>`,
  );
}
