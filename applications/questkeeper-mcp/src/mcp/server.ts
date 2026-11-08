import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import type { Resolver } from '../images/fetchRemote.js';
import type { ToolContext } from './common.js';
import { registerBlockTools } from './tools/blocks.js';
import { registerGroupTools } from './tools/groups.js';
import { registerImageTools } from './tools/images.js';
import { registerNoteTools } from './tools/notes.js';
import { registerReadTools } from './tools/read.js';
import { registerShareTools } from './tools/shares.js';

export const instructions = `Du arbeitest mit Maries Questkeeper-Notizen (Lore und Worldbuilding für ihre Rollenspiel-Kampagnen).

Regeln:
- Du siehst und änderst nur Maries eigene Notizen, Gruppen und Bilder.
- Jede Notiz hat eine Version (aus notizen_lesen). Gib bei Änderungen die zuletzt gelesene Version an. Hat sich die Notiz inzwischen geändert, wird nichts gespeichert: dann neu lesen.
- Jeder Block ist privat oder mit bestimmten Personen geteilt. Verschieben, Zusammenführen und Umordnen behalten die Freigabe jedes Blocks genau bei.
- Neue Blöcke sind immer privat. Freigaben ändert nur freigabe_aendern, und nur wenn Marie es ausdrücklich will.
- Übernimm keine Inhalte aus privaten oder anders geteilten Blöcken in geteilte. Wenn du Inhalte anderer Blöcke verwendest, nenne sie in verwendeteQuellbloecke.
- Löschen (Notizen, Blöcke, Gruppen) und das Erweitern von Freigaben gehen in zwei Schritten: Der erste Aufruf zeigt, was passieren würde, und liefert einen Code. Frag Marie und ruf erst nach ihrem ausdrücklichen Ja mit dem Code erneut auf. Bestätige nie selbst.
- Quellnotizen nach dem Zusammenführen nur löschen, wenn Marie zustimmt.`;

export function buildMcpServer(context: ToolContext, options: { resolver?: Resolver } = {}): McpServer {
  const server = new McpServer({ name: 'questkeeper-notizen', title: 'Questkeeper-Notizen', version: '1.0.0' }, { instructions });
  registerReadTools(server, context);
  registerNoteTools(server, context);
  registerBlockTools(server, context);
  registerGroupTools(server, context);
  registerShareTools(server, context);
  registerImageTools(server, context, options);
  return server;
}
