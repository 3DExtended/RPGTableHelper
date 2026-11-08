import path from 'node:path';
import readline from 'node:readline';
import { hashPassword } from './auth/password.js';
import { revokeAllLogins } from './auth/tokenStore.js';
import { newTotpSecret } from './auth/totp.js';

/**
 * Helpers for setting the server up:
 *   passwort-hash    asks for a password and prints LOGIN_PASSWORD_HASH
 *   totp-geheimnis   prints a new LOGIN_TOTP_SECRET and the link for an authenticator app
 *   abmelden         ends every login at once (Claude has to sign in again)
 */

function askHidden(question: string): Promise<string> {
  return new Promise((resolve) => {
    if (!process.stdin.isTTY) {
      let input = '';
      process.stdin.setEncoding('utf8');
      process.stdin.on('data', (chunk) => (input += chunk));
      process.stdin.on('end', () => resolve(input.replace(/\r?\n$/, '')));
      return;
    }
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout, terminal: true });
    const output = rl as unknown as { _writeToOutput: (text: string) => void };
    process.stdout.write(question);
    output._writeToOutput = () => undefined;
    rl.question('', (answer) => {
      rl.close();
      process.stdout.write('\n');
      resolve(answer);
    });
  });
}

async function main(): Promise<void> {
  const [command] = process.argv.slice(2);
  switch (command) {
    case 'passwort-hash': {
      const password = await askHidden('Passwort: ');
      if (password.length < 12) {
        process.stderr.write('Bitte mindestens 12 Zeichen.\n');
        process.exit(1);
      }
      if (process.stdin.isTTY) {
        const again = await askHidden('Noch einmal: ');
        if (again !== password) {
          process.stderr.write('Die Eingaben unterscheiden sich.\n');
          process.exit(1);
        }
      }
      process.stdout.write(`LOGIN_PASSWORD_HASH=${await hashPassword(password)}\n`);
      return;
    }
    case 'totp-geheimnis': {
      const secret = newTotpSecret();
      const label = encodeURIComponent('Questkeeper-Notizen:Marie');
      process.stdout.write(`LOGIN_TOTP_SECRET=${secret}\n`);
      process.stdout.write(`In die Authenticator-App (als Link oder QR-Code):\notpauth://totp/${label}?secret=${secret}&issuer=Questkeeper-Notizen&digits=6&period=30\n`);
      return;
    }
    case 'abmelden': {
      const dataDir = path.resolve(process.env.DATA_DIR ?? './data');
      revokeAllLogins(dataDir);
      process.stdout.write(`Alle Anmeldungen beendet (${dataDir}). Claude muss sich neu verbinden.\n`);
      return;
    }
    default:
      process.stdout.write('Befehle: passwort-hash | totp-geheimnis | abmelden\n');
      process.exit(command ? 1 : 0);
  }
}

void main();
